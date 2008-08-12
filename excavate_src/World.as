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

class World extends Sprite
{
    //Internal Properties
    private var input_     : Input;
    private var peakCount_ : uint   = 0;
    
    //3D Related
	private var view_      : BasicView       = new BasicView(800, 600, false, true, "Target");
	private var sight_     : DisplayObject3D = new DisplayObject3D();
    
    //getter | setter
    public function get peakCount():uint { return peakCount_; }
    
    //methods
    public function World(input: Input):void {
        input_ = input;
        setup3D();
        setupEvents();
    }
    
    public function render():void {
        view_.renderer.renderScene( view_.scene, view_.camera, view_.viewport );
    }
    
    private function setup3D():void {
    	view_.viewport.autoClipping = true;
		view_.viewport.autoCulling  = true;
        
        // Create camera
		view_.camera.zoom = 6;
		view_.camera.focus = 70;
        view_.camera.x = 0;
		view_.camera.y = 0;
		view_.camera.z = -1000;
		view_.camera.target = sight_;
        
        addChild(view_);
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