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
    private var objZStart_ : Number = 500;
    private var objZEnd_   : Number = -500;
    
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
            spawnObject();
            nextSpawnP_ = progress_ + spawnGap_;
        }
        updateObjPositions();
        cleanUpObjects();
        
        singleRender();
    }
    
    private function convert_InputY_2_Progress():Number {
        return input_.dirY > 0 ? input_.dirY * 10 : 0;
    }
    
    private function spawnObject():void {
        var o: Plane = new Plane(new ColorMaterial(rand(16777216)), 300, 300, 1, 1); //temp
        o.extra = {hp: 3};
        o.x = rand2(500) + camera.x;
        o.z = objZStart_;
        objArray_.push( o );
        scene.addChild( o );
    }
    
    private function initSpawn():void {
        var len: uint = Math.abs( objZEnd_ - objZStart_ ); 
        var times: uint = len / spawnGap_;
        for( var i:uint = 0; i < times; ++i ) {
            spawnObject(); //must spawn first or you can't access objArray_[i]
            objArray_[i].z -= len * (1 - (i+1)/times);
        }
    }
    
    private function updateObjPositions():void {
        for each( var o in objArray_ ) {
            o.z -= convert_InputY_2_Progress();
        }
        camera.x += input_.dirX * 10;
        sight_.x += input_.dirX * 10;
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
		camera.z = -1000;
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