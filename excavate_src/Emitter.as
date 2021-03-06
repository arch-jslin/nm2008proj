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

class Emitter extends Sprite 
{
	//Internal Properties
	private var input_ : Input;
	//3D Related
	
	//Getter | Setter
	
	//Methods
	public function Emitter(input: Input) {
	    input_ = input;
	}
	
	public function exploding(x:Number, y:Number):void {

	}
	
	public function smoking(x:Number, y:Number):void {
	    var ClassRef: Class = Class(getDefinitionByName("Smoke"));
		var p: MovieClip = new ClassRef();
		
		p.x = x + stage.width/2 + rand2(75); 
		p.y = y + stage.height/2 + rand(-20);
		p.scaleX = 0.1;
		p.scaleY = 0.1;
		
		addChild( p );
		
		var dx:Number = p.x + 400;
		var dy:Number = p.y + rand(-400);
		var rot:Number = p.rotation + rand2(180);
		
		TweenMax.to(p, 1, {x:dx, y:dy, scaleX:2, scaleY:2, rotation:rot, alpha:0, delay:rand(0.6), ease:Linear.easeOut, overwrite:false, 
			onComplete:function(){
				removeChild( p );
			}});        
	}
	
	// ------------------------------------------------------------------ Helper

	protected function rand(i:Number):Number  { return Math.random()*i; }
	protected function uint_rand(i:uint):uint { return rand(i); }
	protected function rand2(i:Number):Number { return rand(i)*2 - i; }
}

} //package