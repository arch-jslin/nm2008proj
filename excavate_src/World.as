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

//Import TweenMaxAS3
import gs.TweenMax;
import gs.easing.Elastic;

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
    
    //caches
    private var currentFrameProgressCache_ : Number = 0;
    private var isBlockedCache_            : Boolean = false;
    
    //3D Related
	private var sight_     : DisplayObject3D = new DisplayObject3D();
    private var blocker_   : Cube            = new Cube(new MaterialsList({all:new WireframeMaterial()}), 400, 1, 300, 1, 1, 1);
    private var hitarea_   : Cube            = new Cube(new MaterialsList({all:new WireframeMaterial(0)}), 10, 1, 200, 1, 1, 1);
    private var ground_    : Plane           = new Plane(new BitmapFileMaterial("png/ground.png"), 3000, 1000, 1, 1);
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
        isBlockedCache_            = isBlocked();
        currentFrameProgressCache_ = isBlockedCache_ ? 0 : convert_InputY_2_Progress();
        progress_ += currentFrameProgressCache_;
        
        if( progress_ >= nextSpawnP_ ) {
            spawnObjects();
            nextSpawnP_ = progress_ + spawnGap_;
        }
        updateObjPositions();
        cleanUpObjects();
        
        singleRender();
        
        //test
        //trace( (objArray_[0].screen.x + stage.width/2) + " " + (objArray_[0].screen.y + stage.height/2) );
        trace( isBlockedCache_ );
    }
    
    private function isBlocked():Boolean {
        for( var i:uint = 0 ; i < objsPerSpawn_; ++i ) 
            if ( !objArray_[i].extra["isDead"] && objArray_[i].hitTestObject(blocker_) )
                return true;
        return false;
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
            o.extra = {hp: 3, isDead: false}; 
            o.autoCalcScreenCoords = true;
            
            //Magical formula....
            o.x = ( 2*i - objsPerSpawn_ ) * xInterval_ + rand(xInterval_ * 2) + camera.x;
            
            o.z = objZStart_ + i*2; //i is a little bias to avoid z-fighting
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
                objArray_[j + (i*objsPerSpawn_)].z -= len * (1 - (i+1)/times); //Magical Indexes..
        }
    }
    
    private function updateObjPositions():void {
        for each( var o in objArray_ ) {
            o.z -= currentFrameProgressCache_;
            if( !o.extra["isDead"] )
                o.y = convert_X_2_Height(o.x) + convert_Z_2_Height(o.z);
        }
        camera.x += input_.dirX * 10;
        sight_.x += input_.dirX * 10;
        blocker_.x += input_.dirX * 10;
        hitarea_.x += input_.dirX * 10;
        camera.y = convert_X_2_Height(camera.x);
        sight_.y = convert_X_2_Height(sight_.x);
        blocker_.y = convert_X_2_Height(blocker_.x);
        hitarea_.y = convert_X_2_Height(hitarea_.x) - 50; //Magical 50 ...
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
        
        blocker_.z = -1000;
        hitarea_.z = -1100;  //Strange situation.
        ground_.y = convert_X_2_Height(ground_.x);
        ground_.z = -300;
        scene.addChild( blocker_ );
        scene.addChild( hitarea_ );
        scene.addChild( ground_ );
    }
    
    private function setupEvents():void {
        input_.addEventListener(PeakEvent.PEAK, 
            function(){  
                peakCount_ += 1;
                hitReaction( findHitObject() );
            } );
    }
    
    private function findHitObject():DisplayObject3D {
        var hitobj: DisplayObject3D = null;
        for( var i:uint = 0; i < objArray_.length; ++i )
            if( !objArray_[i].extra["isDead"] && objArray_[i].hitTestObject(hitarea_) ) {
                hitobj = objArray_[i]; 
                break;
            }
        return hitobj;
    }
    
    private function hitReaction(obj: DisplayObject3D):void {
        if( obj == null ) return;
        trace( "hit" );
        obj.extra["isDead"] = true;
        TweenMax.to(obj, 1, {y:"-400", ease:Elastic.easeIn, overwrite:false, onComplete:function(){scene.removeChild( obj );}});        
    }
    
	// ------------------------------------------------------------------ Helper

	protected function rand(i:Number):Number  { return Math.random()*i; }
	protected function rand2(i:Number):Number { return rand(i)*2 - i; }
    
}

}//package