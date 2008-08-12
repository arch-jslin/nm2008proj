/*
Copyright (c) 2008 Johnson Lin (a.k.a arch.jslin)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package excavate_src {

//Import Flash Standard packages
import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.text.*;

//Import Papervision3D
import org.papervision3d.core.proto.*;
import org.papervision3d.core.math.*;
import org.papervision3d.core.geom.*;
import org.papervision3d.core.geom.renderables.*;
import org.papervision3d.scenes.*;
import org.papervision3d.cameras.*;
import org.papervision3d.objects.primitives.*;
import org.papervision3d.objects.*;
import org.papervision3d.materials.*;
import org.papervision3d.materials.utils.*;
import org.papervision3d.materials.special.*;
import org.papervision3d.view.*;
import org.papervision3d.events.*;

//Import PeakDetection
import org.wiiflash.events.PeakEvent;

class World extends BasicView
{
    //Internal Properties
    private var input_     : Input;
    private var peakCount_ : uint   = 0;
    private var progress_  : Number = 0;
    private var spawnGap_  : Number = 100;
    private var nextSpawnP_: Number = spawnGap_;
    private var objsPerSpawn_: uint = 3;
    private var objZStart_ : Number = 0;
    private var objZEnd_   : Number = -1000;
    private var xInterval_ : Number = 500;
    private var yInterval_ : Number = 200;
    
    //3D Related
	private var sight_     : DisplayObject3D = new DisplayObject3D();
    private var objArray_  : Array = new Array(); //contains DisplayObject3D
    
    //getter | setter
    public function get peakCount():uint { return peakCount_; }
    public function get progress():Number{ return progress_; }
    public function get nextSpawnP():Number{ return nextSpawnP_; }
    
    //methods
    public function World(input: Input):void {
        super(800, 600, false, true, "Target");
        input_ = input;
        setup3D();
        setupEvents();
        initSpawn();
    }
    
    public function update():void {
        progress_ += convert_InputY_2_Progress();
        
        if( progress_ >= nextSpawnP_ ) {
            spawnObjects();
            nextSpawnP_ = progress_ + spawnGap_;
        }
        updateObjPositions();
        cleanUpObjects();
        
        singleRender();
    }
    
    private function isBlocked():Boolean {
        
    }
    
    private function convert_InputY_2_Progress():Number {
        return input_.dirY > 0 ? input_.dirY * 10 : 0;
    }
    
    private function convert_X_2_Height(x:Number):Number {
        return Math.cos((x / xInterval_) * Math.PI/2) * yInterval_;
    }
    
    //Magical formula....
    private function convert_Z_2_Height(z:Number):Number {
        return Math.cos((z / -objZEnd_) * Math.PI/2) * yInterval_ * 2 - (yInterval_/2);
    }
    
    private function spawnObjects():void {
        for( var i:uint = 0; i < objsPerSpawn_; ++i ) {
            var o: Plane = new Plane(new ColorMaterial(rand(16777216)), 300, 300, 4, 4); //temp
            o.extra = {hp: 3};
            
            //Magical formula....
            o.x = ( 2*i - objsPerSpawn_ ) * xInterval_ + rand(xInterval_ * 2) + camera.x;
            
            o.z = objZStart_ + rand2(10);
            o.y = convert_X_2_Height(o.x) + convert_Z_2_Height(o.z);
            o.rotationZ = rand2(20);
            objArray_.push( o );
            scene.addChild( o );
        }
    }
    
    private function initSpawn():void {
        var len: uint = Math.abs( objZEnd_ - objZStart_ ); 
        var times: uint = len / spawnGap_;
        for( var i:uint = 0; i < times; ++i ) {
            spawnObjects(); //must spawn first or you can't access objArray_[i]
            for( var j:uint = 0; j < objsPerSpawn_; ++j ) 
                objArray_[j + (i*objsPerSpawn_)].z -= len * (1 - (i+1)/times); //Nagical Indexes..
        }
    }
    
    private function updateObjPositions():void {
        for each( var o in objArray_ ) {
            o.z -= convert_InputY_2_Progress();
            o.y = convert_X_2_Height(o.x) + convert_Z_2_Height(o.z);
        }
        camera.x += input_.dirX * 10;
        sight_.x += input_.dirX * 10;
        camera.y = convert_X_2_Height(camera.x);
        sight_.y = convert_X_2_Height(sight_.x);
    }
    
    private function cleanUpObjects():void {
        while( objArray_[0] && objArray_[0].z < objZEnd_ ) {
            scene.removeChild( objArray_.shift() );
        }
    }
    
    private function setup3D():void {
    	viewport.autoClipping = true;
		viewport.autoCulling  = true;
        
        // Create camera
		camera.zoom = 6;
		camera.focus = 70;
        camera.x = 0;
		camera.y = 0;
		camera.z = -1250;
		camera.target = sight_;
    }
    
    private function setupEvents():void {
        input_.addEventListener(PeakEvent.PEAK, 
            function(){  
                peakCount_ += 1;
            } );
    }
    
	// ------------------------------------------------------------------ Helper

	protected function rand(i:Number):Number  { return Math.random()*i; }
	protected function rand2(i:Number):Number { return rand(i)*2 - i; }
    
}

}//package