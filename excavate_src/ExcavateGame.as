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

import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.text.*;

//import PeakDetection
import org.wiiflash.events.PeakEvent;

public final class ExcavateGame extends Sprite 
{
    //Properties
    private var input_     : Input;
    private var peakCount_ : uint;
    
    //Stage objects
    public var showDirX_  : TextField;
    public var showDirY_  : TextField;
    public var showCount_ : TextField;
    
    //Methods
    public function ExcavateGame() {
        showDirX_  = new TextField();
        showDirY_  = new TextField();
        showCount_ = new TextField();
        showDirX_.x = 10; showDirX_.y = 10;
        showDirY_.x = 10; showDirY_.y = 30;
        showCount_.x = 10; showCount_.y = 50; 
        peakCount_ = 0;
        input_ = new Input(stage);
        input_.addEventListener(PeakEvent.PEAK, 
            function(){  
                peakCount_ += 1;
                showCount_.text = peakCount_.toString();
            } );
        addEventListener(Event.ENTER_FRAME, 
            function(){ 
                input_.update();
                showDirX_.text = input_.dirX.toString();
                showDirY_.text = input_.dirY.toString();
            } );
        addChild( showDirX_ );
        addChild( showDirY_ );
        addChild( showCount_ );
    }
}

} //package