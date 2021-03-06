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

//Import PeakDetection
import org.wiiflash.events.PeakEvent;

//Import TweenMaxAS3
import gs.TweenMax;
import gs.easing.*;

public final class ExcavateGame extends Sprite 
{
    //Internal Properties
    private var input_         : Input;
    private var world_         : World;
	private var emitterLayer_  : Emitter;
	private var score_         : Score;
	private var scoreobj_      : ScoreObject;
	private var ui_            : UI;
	private var intro_         : Intro;
	
	private var startGame_     : Boolean = false;
	private var endGame_       : Boolean = false;
	private var timer_         : Timer;
    private var max_time_      : uint = 45;
	private var timecounter_   : uint = max_time_;
    
    //Methods
    public function ExcavateGame() {
	    stage.scaleMode = StageScaleMode.EXACT_FIT;
		stage.quality   = StageQuality.LOW;
        input_ =    new Input(stage);
		intro_ =    new Intro(input_);
		addChild(intro_);
		
		TweenMax.from(intro_, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:0});
		TweenMax.to  (intro_, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:4, 
			onComplete:function(){
				changeSceneFrom1_to_2();
				addEventListener( Event.ENTER_FRAME, mainLoop );
				input_.addEventListener(PeakEvent.PEAK, gameStartHandler);
		    }});
			
	    //showDebug();
    }
	
	private function gameStartHandler(e:Event):void {
		if( !startGame_ )
			gameStart();
	}
	
	private function programRestartHandler(e:Event):void {
		trace( score_ + " " + endGame_ + " " + (score_ ? score_.finished : " ") );
		if( score_ && endGame_ && score_.finished ) 
			programRestart();
	}
	
	private function changeSceneFrom1_to_2():void {
	    stage.quality   = StageQuality.LOW;
	    removeChild( intro_ );
		
		ui_    =    new UI(input_);
		scoreobj_ = new ScoreObject();
		emitterLayer_ = new Emitter(input_);
		world_ =    new World(input_, scoreobj_, ui_, emitterLayer_);
		
        addChild(world_);
		addChild(emitterLayer_);
		addChild(ui_);
        ui_.showCounter( timecounter_ );
	}
	
	private function changeSceneFrom2_to_3():void {
	
	}
	
	private function programRestart():void {
		removeChild( score_ );
		score_.stopSounds();
		startGame_ = false;
		endGame_   = false;
		timecounter_ = max_time_;
		
		intro_ =    new Intro(input_);
		addChild(intro_);
		TweenMax.from(intro_, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:0});
		TweenMax.to  (intro_, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay:4, 
			onComplete:function(){
				changeSceneFrom1_to_2();
				world_.initSpawn(); //I know this is bad, but since we have to do it here. Because all bitmap are already loaded.
				addEventListener( Event.ENTER_FRAME, mainLoop );
				input_.addEventListener(PeakEvent.PEAK, gameStartHandler);
		    }});
			
		input_.removeEventListener(PeakEvent.PEAK, programRestartHandler);
	}

	private function gameStart():void {
        if( !world_.inited ) return;
	    startGame_ = true;
		timer_ = new Timer(1000, max_time_);
		timer_.addEventListener(TimerEvent.TIMER, timerHandler);
		timer_.start();
		ui_.hideHint();
		
		input_.removeEventListener(PeakEvent.PEAK, gameStartHandler);
	}
    
    private function mainLoop(e:Event):void {
        input_.update();
        if( !startGame_ && !endGame_ ) 
			world_.pseudo_update();
		else if( startGame_ && !endGame_ ) {
		    world_.update();
			ui_.updateProgress( scoreobj_ );
		}
    }
	
	private function timerHandler(e:TimerEvent):void {
		timecounter_ -= 1;
		ui_.showCounter( timecounter_ );
	    //trace( timecounter_ + " " + scoreobj_.houses + " " + scoreobj_.trees );
		if( timecounter_ == 0 ) {
		    ui_.showHint( "時間到!" );
            timer_.stop();
		    endGame_ = true;
			world_.stopSounds();
			removeEventListener( Event.ENTER_FRAME, mainLoop );
			world_.removeEvents();
			TweenMax.to(world_, 1, {alpha:0, ease:Linear.easeOut, overwrite:false, delay: 2, 
			    onComplete:function(){
				    stage.quality   = StageQuality.HIGH;
					removeChild( world_ );
					removeChild( ui_ );
					removeChild( emitterLayer_ );
					score_ = new Score(input_, scoreobj_);
					addChild( score_ );
					TweenMax.from( score_, 1, {alpha:0, ease:Linear.easeOut, overwrite:false});
					
					input_.addEventListener(PeakEvent.PEAK, programRestartHandler);
				}});
		}
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
