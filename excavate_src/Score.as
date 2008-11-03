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
import flash.media.*;

//Import TweenMaxAS3
import gs.TweenMax;
import gs.easing.*;

class Score extends Sprite 
{
	//Internal Properties
	private var input_    : Input;
	private var scoreobj_ : ScoreObject; 
	private var finished_ : Boolean = false;
	private var scoreboard_:MovieClip;
    
    private var bg_ : Sprite = new Sprite();
    
    private var bgm_  : Sound;
    private var bgmC_ : SoundChannel;
	
	//3D Related
	
	//Getter | Setter
	public function get finished():Boolean { return finished_; }
	
	//Methods
	public function Score(input: Input, scoreobj: ScoreObject) {
	    input_ = input;
		scoreobj_ = scoreobj;
		trace( scoreobj_.score );
        addChild( bg_ );
        loadSounds();
		startTweeningTheListing();
	}
    
    private function loadSounds():void {
		bgm_ = new Sound();
		bgm_.load(new URLRequest("mp3/endMusic.mp3"));
		bgmC_ = bgm_.play(0, 1);
        
        /* this can cause sound to fade in/out, though quite stupid. */
        var sT:SoundTransform = bgmC_.soundTransform; 
        sT.volume = 0; 
        bgmC_.soundTransform = sT;
        TweenMax.to(sT, 3, {delay: 1, volume:1, ease:Linear.easeOut, onUpdate:function(){ 
            bgmC_.soundTransform = sT; }
        });
    }
    
    public function stopSounds():void { bgmC_.stop(); }
	
	private function startTweeningTheListing():void {
	    var d:uint = 0;		
	    showTitle("SCORE", d);
		showListing(scoreobj_.trees,  "png/smalltree.png", "樹木", ++d, 310);
	    showListing(scoreobj_.houses, "png/smallhouse.png", "房子", ++d, 270);
        showTotal((++d)+4);
		
		var ClassRef: Class = Class(getDefinitionByName("Scoreboard"));
		scoreboard_ = new ClassRef();
		addChild( scoreboard_ );
		TweenMax.from(scoreboard_, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:d+5});
		
		var show_text:String = "";
		var file_name:String = "";
		if( scoreobj_.score < 1 ) {
			show_text = "你人真好。\n\nYou're so kind.\r\r\r（按空白鍵重新開始）";
			file_name = "jpg/good_ending.jpg";
		} else {
		    show_text = "在快速的開發背後，我們失去了什麼？\n\nHow many things do we destruct\nfor the sake of construction?\r\r（按空白鍵重新開始）"
			file_name = "jpg/ending.jpg"
		}
		var ldr: Loader = new Loader();
		ldr.load(new URLRequest(file_name));
		ldr.x = 0; ldr.y = 25;
		addChild( ldr );
		++d;
		TweenMax.from(ldr, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:d + 8});
		
		var title: TextField = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 30, 0xffffff, true);
		title.text = show_text;
		title.x = 360;	title.y = 230;
		title.setTextFormat(tform);
		title.autoSize = TextFieldAutoSize.CENTER;

        var link: TextField = new TextField();
        var lform: TextFormat = new TextFormat("SimHei", 20, 0xffffff, true);
        lform.url = "http://blog.yam.com/yetank";
        link.htmlText = "Made by YET 青年環境智庫（連結點我）";
        link.x = 680; link.y = 500;
        link.setTextFormat(lform);
        link.autoSize = TextFieldAutoSize.RIGHT;
        
		TweenMax.from(title, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:d + 9, 
		    onComplete:function(){
				addChild( title );
                addChild( link );
				finished_ = true;
			}});	
	}
	
	private function showTitle(item_name:String, d:Number, x:Number = 50):void {
		var title: TextField = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 30, 0, true);
		title.text = item_name;
		title.x = x;	title.y = 30 + d * 60;
		title.setTextFormat(tform);
		title.autoSize = TextFieldAutoSize.LEFT;
		addChild( title );
        
		TweenMax.from(title, 1, {x:"-800", ease:Expo.easeOut, overwrite:false, delay:d});
	}
	
	private function showListing(n:uint, file_name:String, item_name:String, d:Number, x:Number):void {
	    showTitle(item_name, d, 630);
		
		var ldr: Loader = new Loader();
		ldr.load(new URLRequest(file_name));
		ldr.x = 40; ldr.y = 30 + d * 60;
		ldr.scaleX = ldr.scaleY = 0.8;
		addChild( ldr );
		TweenMax.from(ldr, 1, {x:"-700", ease:Expo.easeOut, overwrite:false, delay:d});
		
		var title: TextField = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 40, 0, true);
        title.defaultTextFormat = tform;
		title.text = "0"; //n.toString();
		title.x = x;	title.y = 25 + d * 60;
		title.autoSize = TextFieldAutoSize.LEFT;
		addChild( title );
		TweenMax.from(title, 1, {x:"-700", ease:Expo.easeOut, overwrite:false, delay:d});
        
        //make a counter effect
        var effect_dur:int = 5;
        var increment:Number = Number(n)/(effect_dur*30); 
        var val:Number = 0;
        var last_val:Number = 0;
        TweenMax.from(this, effect_dur, {overwrite:false, delay:d-1,
                      onUpdate:function(){ 
                          val += increment; title.text = int(val).toString(); 
                          if( val - last_val >= 100 ) {
                              last_val = val;
                              dropItem( item_name );
                          }
                      }, 
                      onComplete:function(){ title.text = n.toString();} });
	}
    
    private function dropItem(s: String):void {
		var ldr: Loader = new Loader();
        var name: String = (s == "樹木" ? "tree" : "house");
        var max: uint = (s == "樹木" ? 5 : 9);
		ldr.load(new URLRequest("png/"+name+uint_to_s(uint_rand(max),2)+".png"));
        bg_.addChild( ldr );
        ldr.x = rand(800); ldr.y = -100; ldr.rotation = rand2(180);
    	TweenMax.from(ldr, 2.5, {alpha:0.3, ease:Linear.easeOut, overwrite:false});
        TweenMax.to(ldr, 3.5, {y:"1050", ease:Linear.easeOut, overwrite:false});
        TweenMax.to(ldr, 2.5, {rotation:rand2(180).toString(), ease:Linear.easeOut, overwrite:false});
    }
	
	private function showImportant(file_name:String, item_name:String, d:Number):void {
		showTitle(item_name, d);
	    var i: uint = d-4;
		var ldr: Loader = new Loader();
		ldr.load(new URLRequest(file_name));
		ldr.x = 405; ldr.y = -10;
		addChild( ldr );
		TweenMax.from(ldr, 1, {alpha:0, ease:Linear.easeInOut, overwrite:false, delay:d + i*4});
		TweenMax.to  (ldr, 1, {alpha:0, ease:Linear.easeInOut, overwrite:false, delay:d + i*4 + 3});
	}
	
	private function showTotal(d:Number):void {
	    showTitle("總分", d);
		
		var title: TextField = new TextField();
		var tform: TextFormat = new TextFormat("SimHei", 40, 0, true);
		title.text = scoreobj_.score.toString();
		title.x = 160;	title.y = 30 + d * 60;
		title.setTextFormat(tform);
		title.autoSize = TextFieldAutoSize.LEFT;
		addChild( title );
		TweenMax.from(title, 1, {x:"-800", ease:Expo.easeOut, overwrite:false, delay:d});
	}
	
	//Helpers
    
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

} //package