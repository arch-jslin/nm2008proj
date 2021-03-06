﻿/*
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
	
	private var arm_      : MovieClip;

	//Getter | Setter
	public function get arm():MovieClip { return arm_; }
	
	//Methods
	public function UI(input: Input) {
	    input_ = input;
		var ClassRef: Class = Class(getDefinitionByName("Excavator_Arm"));
		arm_ = new ClassRef();
		arm_.x = 400;
		arm_.y = 700;
		addChild( arm_ );
        
        hint_     = createTextBox("--- 載入中 ---\r--- 請稍待 ---", 30, 350, 280);
        progress_ = createTextBox("樹木: 00000   房舍: 00000", 30, 350, 520);
        counter_  = createTextBox("60", 40, 350, 40);
	}
    
    private function createTextBox(text:String, size:uint, x:int, y:int): TextField {
        var textbox: TextField = new TextField();
        var format: TextFormat = new TextFormat("SimHei", size, 0xffffff, true);
        format.align = TextFormatAlign.CENTER;
        textbox.defaultTextFormat = format;
        textbox.text = text;
        textbox.x = x; textbox.y = y;        
        textbox.autoSize = TextFieldAutoSize.CENTER;
        addChild( textbox );
        return textbox;
    }
	
	public function updateProgress(scoreobj: ScoreObject): void {
	    progress_.text =  "樹木: " + uint_to_s(scoreobj.trees, 5) + "   房舍: " + uint_to_s(scoreobj.houses, 5);
	}
	
    public function hideCounter(): void { counter_.visible = false; }
	public function showCounter(count: uint): void { counter_.text = count.toString(); counter_.visible = true; }
	public function hideHint():void { hint_.visible = false; }
	public function showHint(t:String):void { hint_.text = t; hint_.visible = true; }
	
	public function popUpItem(x:Number, y:Number, ch:String, val:uint):void {
	    var item: TextField = new TextField();
		if( ch == "h" )
			item.text = "拆除房舍 +" + val.toString();
		else if( ch == "t" )
		    item.text = "拆除樹木 +" + val.toString();
			
		item.x = x + stage.width/2 - 100; item.y = y + stage.height/2;
		var pform: TextFormat = new TextFormat("SimHei", 30, 0xffffff, true);
		item.setTextFormat(pform);
		item.autoSize = TextFieldAutoSize.CENTER;
		addChild( item );
		
		TweenMax.to(item, 1, {y:"-100", ease:Expo.easeOut, overwrite:false, 
			onComplete:function(){
				removeChild( item );
			}});
	}
	
	//Helpers
	//Duplicate of World.uint_to_s
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

} //package