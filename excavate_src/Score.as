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

class Score extends Sprite 
{
	//Internal Properties
	private var input_    : Input;
	private var scoreobj_ : ScoreObject; 
	
	//3D Related
	
	//Getter | Setter
	
	//Methods
	public function Score(input: Input, scoreobj: ScoreObject) {
	    input_ = input;
		scoreobj_ = scoreobj;
		trace( scoreobj_.score );
		startTweeningTheListing();
	}
	
	private function startTweeningTheListing():void {
	    if( scoreobj_.houses > 0 ) showListing(scoreobj_.houses, "smallhouse.png", "房子", 0);
		if( scoreobj_.trees > 0 )  showListing(scoreobj_.trees,  "smalltree.png", "樹木", 1);
		if( scoreobj_.score > 10 ) showImportant("people1.jpg", "林卻阿嬤的家", 2);
		if( scoreobj_.score > 20 ) showImportant("people2.jpg", "阿添伯的屋子", 3);
		if( scoreobj_.score > 30 ) showImportant("people3.jpg", "湯伯伯的房間", 4);
		if( scoreobj_.score > 40 ) showImportant("people4.jpg", "秀琴阿姨的家", 5);
		showTotal(6);
	}
	
	private function showListing(n:uint, file_name:String, item_name:String, delay:Number):void {
	    
	}
	
	private function showImportant(file_name:String, item_name:String, delay:Number):void {
	}
	
	private function showTotal(delay:Number):void {
	    if( scoreobj_.score < 10 ) {
		
		} else {
		
		}
	}
	
	//Helpers
}

} //package