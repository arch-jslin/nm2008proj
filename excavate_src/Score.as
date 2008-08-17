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
import flash.net.*;

//Import TweenMaxAS3
import gs.TweenMax;
import gs.easing.*;

class Score extends Sprite 
{
	//Internal Properties
	private var input_    : Input;
	private var scoreobj_ : ScoreObject; 
	private var finished_ : Boolean = false;
	
	//3D Related
	
	//Getter | Setter
	public function get finished():Boolean { return finished_; }
	
	//Methods
	public function Score(input: Input, scoreobj: ScoreObject) {
	    input_ = input;
		scoreobj_ = scoreobj;
		trace( scoreobj_.score );
		startTweeningTheListing();
	}
	
	private function startTweeningTheListing():void {
	    var d:uint = 0;		
	    showTitle("SCORE", d);
		showTotal(++d);
	    showListing(scoreobj_.houses, "png/smallhouse.png", "房子", ++d);
		showListing(scoreobj_.trees,  "png/smalltree.png", "樹木", ++d);
		if( scoreobj_.score > 10 ) showImportant("jpg/people1.jpg", "阿嬤ㄟ虔誠", ++d);
		if( scoreobj_.score > 20 ) showImportant("jpg/people2.jpg", "阿公ㄟ勤奮", ++d);
		if( scoreobj_.score > 30 ) showImportant("jpg/people3.jpg", "阿伯ㄟ悠閒", ++d);
		if( scoreobj_.score > 40 ) showImportant("jpg/people4.jpg", "阿姆ㄟ細心", ++d);
		
		var show_text:String = "";
		var file_name:String = "";
		if( scoreobj_.score < 10 ) {
			show_text = "你人真好，有空來坐坐";
			file_name = "jpg/good_ending.jpg";
		} else {
			file_name = "jpg/ending.jpg"
		}
		var ldr: Loader = new Loader();
		ldr.load(new URLRequest(file_name));
		ldr.x = 0; ldr.y = 25;
		addChild( ldr );
		++d;
		var i: uint = d-4;
		TweenMax.from(ldr, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:d + i*5});
		
		var title: TextField = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 30, 0xffffff, true);
		title.text = show_text;
		title.x = 300;	title.y = 250;
		title.setTextFormat(tform);
		title.autoSize = TextFieldAutoSize.CENTER;
		//title.embedFonts = true;
		TweenMax.from(title, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:d + i*5 + 2, 
		    onComplete:function(){
				addChild( title );
				finished_ = true;
			}});	
	}
	
	private function showTitle(item_name:String, d:Number):void {
		var title: TextField = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 30, 0, true);
		title.text = item_name;
		title.x = 50;	title.y = 30 + d * 60;
		title.setTextFormat(tform);
		title.autoSize = TextFieldAutoSize.LEFT;
		addChild( title );
		
		var i:int = d-4; //watch out... can't use unsigned int here....
		if( i >= 0 )
			TweenMax.from(title, 1, {x:"-400", ease:Expo.easeOut, overwrite:false, delay:d + i*5});
		else
			TweenMax.from(title, 1, {x:"-400", ease:Expo.easeOut, overwrite:false, delay:d});
	}
	
	private function showListing(n:uint, file_name:String, item_name:String, d:Number):void {
	    showTitle(item_name, d);
		
		var ldr: Loader = new Loader();
		ldr.load(new URLRequest(file_name));
		ldr.x = 620; ldr.y = 30 + d * 60;
		addChild( ldr );
		TweenMax.from(ldr, 1, {x:"-700", ease:Expo.easeOut, overwrite:false, delay:d});
		
		var title: TextField = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 30, 0, true);
		title.text = "x" + n;
		title.x = 700;	title.y = 30 + d * 60;
		title.setTextFormat(tform);
		title.autoSize = TextFieldAutoSize.LEFT;
		addChild( title );
		TweenMax.from(title, 1, {x:"-800", ease:Expo.easeOut, overwrite:false, delay:d});
	}
	
	private function showImportant(file_name:String, item_name:String, d:Number):void {
		showTitle(item_name, d);
	    var i: uint = d-4;
		var ldr: Loader = new Loader();
		ldr.load(new URLRequest(file_name));
		ldr.x = 405; ldr.y = -10;
		addChild( ldr );
		TweenMax.from(ldr, 1, {alpha:0, ease:Linear.easeInOut, overwrite:false, delay:d + i*5});
		TweenMax.to  (ldr, 1, {alpha:0, ease:Linear.easeInOut, overwrite:false, delay:d + i*5 + 4});
	}
	
	private function showTotal(d:Number):void {
	    showTitle("開發程度", d);
		
		var title: TextField = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 30, 0, true);
		title.text = scoreobj_.score + " / " + 100;
		title.x = 620;	title.y = 30 + d * 60;
		title.setTextFormat(tform);
		title.autoSize = TextFieldAutoSize.LEFT;
		addChild( title );
		TweenMax.from(title, 1, {x:"-800", ease:Expo.easeOut, overwrite:false, delay:d});
	}
	
	//Helpers
}

} //package