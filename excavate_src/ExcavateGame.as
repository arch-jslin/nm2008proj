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

public final class ExcavateGame extends Sprite 
{
    //Internal Properties
    private var input_     : Input;
    private var world_     : World;
	private var gfxLayer_  : Sprite;
    
    //Methods
    public function ExcavateGame() {
        input_ = new Input(stage);
        world_ = new World(input_);
		gfxLayer_ = new Sprite();
        addChild(world_);
		addChild(gfxLayer_);
        showDebug();
        addEventListener( Event.ENTER_FRAME, mainLoop );
    }
    
    private function mainLoop(e:Event):void {
        input_.update();
        world_.update();
    }
    
    // ------------------------------------------------------------------ Debug
    
    //Stage objects (Debug)
    private var showDirX_  : TextField;
    private var showDirY_  : TextField;
    private var showCount_ : TextField;
    private var showPro_   : TextField;
    
    private function showDebug():void {
        showDirX_ = new TextField();
        showDirY_ = new TextField();
        showCount_= new TextField();
        showPro_  = new TextField();
        showDirX_.x = 10; showDirX_.y = 10;
        showDirY_.x = 10; showDirY_.y = 30;
        showCount_.x = 10; showCount_.y = 50; 
        showPro_.x = 10; showPro_.y = 70; 
        addEventListener(Event.ENTER_FRAME, 
            function(){ 
                showCount_.text = world_.peakCount.toString();
                showDirX_.text = input_.dirX.toString();
                showDirY_.text = input_.dirY.toString();
                showPro_.text = world_.progress.toString();
            } );
        addChild( showDirX_ );
        addChild( showDirY_ );
        addChild( showCount_ );
        addChild( showPro_ );
    }
}

} //package
