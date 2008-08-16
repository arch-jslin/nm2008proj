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
import gs.easing.*;

class World extends BasicView
{
    //Internal Properties
    private var input_     : Input;
    private var peakCount_ : uint   = 0;
    private var progress_  : Number = 0;
    private var spawnGap_  : Number = 100;
    private var nextSpawnP_: Number = spawnGap_;
    private var objsPerSpawn_: uint = 3;
    private var objZStart_ : Number = 300;
    private var objZEnd_   : Number = -700;
    private var xInterval_ : Number = 1000;
    private var yInterval_ : Number = 200;
	private var houseVariations_ : uint = 9;
	private var treeVariations_  : uint = 5;
	private var inited_    : Boolean = false;
	private var scoreobj_  : ScoreObject;
    
    //caches
    private var currentFrameProgressCache_ : Number = 0;
    private var currentFrameXCache_        : Number = 0;
    private var isBlockedCache_            : Boolean = false;
    
    //3D Related
	private var sight_     : DisplayObject3D = new DisplayObject3D();
    private var blocker_   : Cube            = new Cube(new MaterialsList({all:new WireframeMaterial()}), 400, 1, 300, 1, 1, 1);
    private var hitarea_   : Cube            = new Cube(new MaterialsList({all:new WireframeMaterial(0)}), 10, 1, 200, 1, 1, 1);
    private var ground_    : Plane           = new Plane(new BitmapFileMaterial("png/ground_bigger.png"), 9000, 1350, 1, 1);
	private var ground2_   : Plane           = new Plane(new BitmapFileMaterial("png/ground_bigger.png"), 9000, 1350, 1, 1);
    private var objArray_  : Array = new Array(); //contains DisplayObject3D
	private var matArray_  : Array = new Array(); //contains BitmapFileMaterial
    
    //getter | setter
    public function get peakCount():uint { return peakCount_; }
    public function get progress():Number{ return progress_; }
    public function get nextSpawnP():Number{ return nextSpawnP_; }
    
    //methods
    public function World(input: Input, scoreobj: ScoreObject):void {
        super(800, 600, false, true, "Target");
        input_ = input;
		scoreobj_ = scoreobj;
		initBitmapMaterials();
        setup3D();
        setupEvents();
        //initSpawn();
    }
	
	public function initBitmapMaterials():void {
	    for( var i:uint = 0; i < houseVariations_ ; ++i )
		    matArray_.push( new BitmapFileMaterial("png/house"+uint_to_s(i,2)+".png") );
			
		for( var i:uint = 0; i < treeVariations_ ; ++i )
		    matArray_.push( new BitmapFileMaterial("png/tree"+uint_to_s(i,2)+".png") );
			
	    BitmapFileMaterial.callback = initSpawn;
	}
    
    public function update():void {
        isBlockedCache_            = isBlocked();
        currentFrameProgressCache_ = isBlockedCache_ ? 0 : convert_InputY_2_Progress();
        currentFrameXCache_        = convert_InputX_2_XMovement();
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
        //trace( isBlockedCache_ );
    }
    
    private function isBlocked():Boolean {
	    if( inited_ == false ) return true;
        for( var i:uint = 0 ; i < objsPerSpawn_; ++i ) 
            if ( !objArray_[i].extra["isDead"] && objArray_[i].hitTestObject(blocker_) )
                return true;
        return false;
    }
    
    private function convert_InputX_2_XMovement():Number {
        if( camera.x < -2*xInterval_ && input_.dirX < 0 ) return 0;
        if( camera.x > 2*xInterval_ && input_.dirX > 0 ) return 0;
        return input_.dirX * 10;
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
    
    private function calculate_Slope_By_X_Pos(x:Number):Number {
        return -15 * Math.sin((x / xInterval_) * Math.PI/2);
    }
    
    private function spawnObjects():void {
        for( var i:uint = 0; i < objsPerSpawn_; ++i ) {
            //var o: Plane = new Plane(new ColorMaterial(rand(16777216)), 450, 300, 4, 4); //temp
			var mat: BitmapFileMaterial = matArray_[uint_rand(houseVariations_ + treeVariations_)];
			var o: Plane = new Plane(mat, mat.bitmap.width/1.2, mat.bitmap.height/1.2, 1, 1);
			
            o.extra = {hp: 3, isDead: false, isDying: false}; 
            o.autoCalcScreenCoords = true;
            
            //Magical formula....
            //o.x = ( 2*i - objsPerSpawn_ ) * xInterval_ + rand(xInterval_ * 2) + camera.x;
			o.x = ( 2*i - objsPerSpawn_ ) * xInterval_ * 0.4 + rand(xInterval_)*0.8 + camera.x;
            
            o.z = objZStart_ + i*2; //i is a little bias to avoid z-fighting
            o.y = convert_X_2_Height(o.x) + convert_Z_2_Height(o.z) - (150 - o.material.bitmap.height/2)*1.5;
            o.rotationZ = calculate_Slope_By_X_Pos(o.x);//rand2(20);
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
		inited_ = true;
    }
    
    private function updateObjPositions():void {
        for each( var o in objArray_ ) {
            o.z -= currentFrameProgressCache_;
            if( !o.extra["isDying"] )
                o.y = convert_X_2_Height(o.x) + convert_Z_2_Height(o.z) - (150 - o.material.bitmap.height/2)*1.5;
        }
        camera.x += currentFrameXCache_;
        sight_.x += currentFrameXCache_;
        blocker_.x += currentFrameXCache_;
        hitarea_.x += currentFrameXCache_;
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
		camera.z = -950;
		camera.target = sight_;
        
        blocker_.z = -700;
        hitarea_.z = -760;  //Strange situation.
        ground_.y = convert_X_2_Height(ground_.x) - 450;
        ground_.z = 0;
		ground2_.y = convert_X_2_Height(ground2_.x) - 475;
		ground2_.z = -200; 
        scene.addChild( blocker_ );
        scene.addChild( hitarea_ );
        scene.addChild( ground_ );
		scene.addChild( ground2_ );
    }
    
    private function setupEvents():void {
        input_.addEventListener(PeakEvent.PEAK, 
            function(){  
                peakCount_ += 1;
                hitReaction( findHitObject() );
            } );
    }
    
    private function findHitObject():Plane/*DisplayObject3D*/ {
        var hitobj: Plane = null;
        for( var i:uint = 0; i < objArray_.length; ++i )
            if( !objArray_[i].extra["isDying"] && objArray_[i].hitTestObject(hitarea_) ) {
                hitobj = objArray_[i]; 
                break;
            }
        return hitobj;
    }
    
    private function hitReaction(obj: Plane/*DisplayObject3D*/):void {
        if( obj == null ) return;
        obj.extra["isDying"] = true;
		var delta_y:Number = obj.y - obj.material.bitmap.height/6;
		
		//trace( (obj.material as BitmapMaterial).texture.toString().charAt(4) ); 
		//Bad Magic: "png/t" or "png/h" ... the fourth character will be distinguishable
		var ch : String = (obj.material as BitmapMaterial).texture.toString().charAt(4);
		if( ch == "h" ) 
			scoreobj_.houses_ += 1;
		else if ( ch == "t" ) 
			scoreobj_.trees_ += 1;
		
		if( uint_rand(2) ) {
			TweenMax.to(obj, 0.66, {y:"-400", ease:Back.easeIn, overwrite:false, 
				onComplete:function(){obj.extra["isDead"] = true; scene.removeChild( obj );}});  //test
			TweenMax.to(obj, 0.05, {rotationZ:"-10", ease:Linear.easeOut, overwrite:false});
			TweenMax.to(obj, 0.05, {rotationZ:"15",  ease:Linear.easeOut, delay:0.05, overwrite:false});
			TweenMax.to(obj, 0.10, {rotationZ:"-25", ease:Linear.easeOut, delay:0.10, overwrite:false});
			TweenMax.to(obj, 0.10, {rotationZ:"25",  ease:Linear.easeOut, delay:0.20, overwrite:false});
			TweenMax.to(obj, 0.30, {rotationZ:"-30", ease:Linear.easeOut, delay:0.30, overwrite:false});
		}
		else
			TweenMax.to(obj, 1, {rotationX:"60", y:delta_y, scale:.75, ease:Bounce.easeOut, overwrite:false, 
				onComplete:function(){obj.extra["isDead"] = true; scene.removeChild(obj);}});
    }
    
	// ------------------------------------------------------------------ Helper

	protected function rand(i:Number):Number  { return Math.random()*i; }
	protected function uint_rand(i:uint):uint { return rand(i); }
	protected function rand2(i:Number):Number { return rand(i)*2 - i; }
	protected function uint_to_s(i:uint, digit:uint = 0):String {
	    if( digit == 0 ) return i.toString();
		else {
		    var s:String = i.toString();
			var lack_zero:uint = digit - s.length;
			var zeros:String = "";
			while( lack_zero > 0 ) {
			    zeros += "0";
				--lack_zero;
			}
			return zeros + s;
		}
	}
}

}//package