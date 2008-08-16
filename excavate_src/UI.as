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

//Import TweenMaxAS3
import gs.TweenMax;
import gs.easing.*;

class UI extends Sprite 
{
	//Internal Properties
	private var input_    : Input;
	private var hint_     : TextField;
	private var progress_ : TextField;
	private var counter_  : TextField;

	//Getter | Setter
	
	//Methods
	public function UI(input: Input) {
	    input_ = input;
		hint_  = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 30, 0xffffff, true);
		hint_.text = "甩動 Wii 搖桿以開始遊戲";
		hint_.x = 320;	hint_.y = 280;
		hint_.setTextFormat(tform);
		hint_.autoSize = TextFieldAutoSize.CENTER;
		addChild( hint_ );
		
		progress_ = new TextField();
		progress_.text = "0 / 100";
		progress_.x = 350; progress_.y = 520;
		var pform: TextFormat = new TextFormat("SimHei", 30, 0xffffff, true);
		progress_.setTextFormat(pform);
		progress_.autoSize = TextFieldAutoSize.CENTER;
		addChild( progress_ );
		
		counter_ = new TextField();
		counter_.text = "60";
		counter_.x = 350; counter_.y = 20;
		var cform: TextFormat = new TextFormat("SimHei", 30, 0x000000, true);
		counter_.setTextFormat(cform);
		counter_.autoSize = TextFieldAutoSize.CENTER;
		addChild( counter_ );
	}
	
	public function updateProgress(percent: Number): void {
	    progress_.text = percent + " / 100";
		var pform: TextFormat = new TextFormat("SimHei", 30, 0xffffff, true);
		progress_.setTextFormat(pform);
	}
	
	public function showCounter(count: uint): void {
		counter_.text = count.toString();
		var cform: TextFormat = new TextFormat("SimHei", 30, 0x000000, true);
		counter_.setTextFormat(cform);
	}
	
	public function hideHint():void {
		removeChild( hint_ );
	}
	
	//Helpers
}

} //package