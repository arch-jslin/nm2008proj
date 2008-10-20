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
import flash.media.*;
import flash.net.*;

//Import TweenMaxAS3
import gs.TweenMax;
import gs.easing.*;

class Intro extends Sprite 
{
	//Internal Properties
	private var input_      : Input;
	private var intro_text_ : MovieClip;
    private var bgm_  : Sound;
    private var bgmC_ : SoundChannel;
	
	//3D Related
	
	//Getter | Setter
	
	//Methods
	public function Intro(input: Input) {
	    input_ = input;
		var ClassRef:Class = Class(getDefinitionByName("Intro_1"));
		intro_text_ = new ClassRef();
		intro_text_.x = 400;
		intro_text_.y = 300;
		addChild( intro_text_ );
        
        loadSounds();
	}
    
    private function loadSounds():void {
		bgm_ = new Sound();
		bgm_.load(new URLRequest("mp3/startMusic.mp3"));
		bgmC_ = bgm_.play(0, 1);
        
        /* this can cause sound to fade in/out, though quite stupid. */
        var sT:SoundTransform = bgmC_.soundTransform; 
        sT.volume = 1; 
        bgmC_.soundTransform = sT;
        TweenMax.to(sT, 2, {delay: 5, volume:0, ease:Linear.easeOut, onUpdate:function(){ 
            bgmC_.soundTransform = sT; }
        });
    }
}

} //package