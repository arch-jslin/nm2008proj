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

//import flash modules
import flash.events.*;
import flash.display.Stage;

//import WiiFlash
import org.wiiflash.*;
import org.wiiflash.events.*;
import org.wiiflash.utils.*;

//This class handles the events from wiimote and (optionally) the keyboard/mouse,
//to abstract away the tasks in the main Game.as

class Input implements IEventDispatcher
{
    //Properties
    private var wiimote_         : Wiimote = new Wiimote();
    private var peakDetector_    : HistoryPeakDetection = new HistoryPeakDetection(8, 128, 2);
    private var eventDispatcher_ : EventDispatcher;
    private var dirx_            : Number = 0;
    private var diry_            : Number = 0;
    private var keyStats_        : Array = new Array(256);
    
    private var DIRX_CALIBRATION : Number = -0.08;
    private var DIRY_CALIBRATION : Number = -0.09;
    
    //Getter | Setter
    public function get dirX():Number { return dirx_; }
    public function get dirY():Number { return diry_; }
    
    //Methods
    public function Input(stage: Stage) {
        eventDispatcher_ = new EventDispatcher(this);
        hookupEvents(stage);
        wiimote_.connect();
    }
    
    public function update():void {
        if( !wiimote_.connected || !wiimote_.hasNunchuk ) { 
            dirx_ = diry_ = 0;
        }
        dirx_ += 0.7 * ((-1)*int(keyStats_[65]) + int(keyStats_[68])); //KEY_A and KEY_D
        diry_ += 0.7 * ((-1)*int(keyStats_[83]) + int(keyStats_[87])); //KEY_W and KEY_S
    }
    
    private function hookupEvents(stage: Stage):void {
        stage.addEventListener( KeyboardEvent.KEY_DOWN, 
            function(k:KeyboardEvent){
                keyStats_[k.keyCode] = true;
                if( k.keyCode == 32 ) //WHITE_SPACE
                    eventDispatcher_.dispatchEvent( new PeakEvent() );
            } ); 
        stage.addEventListener( KeyboardEvent.KEY_UP, 
            function(k:KeyboardEvent){
                keyStats_[k.keyCode] = false;
            } ); 
        
        peakDetector_.addEventListener( PeakEvent.PEAK, 
            function() { 
                var sqY:Number = (wiimote_.sensorY * wiimote_.sensorY);
                var sqZ:Number = (wiimote_.sensorZ * wiimote_.sensorZ);
                //trace( sqY + sqZ );
                if( sqY + sqZ > 17 ) //Enforce a minimum force requirement to trigger a PEAK
                    eventDispatcher_.dispatchEvent( new PeakEvent() ); 
            } );
            
        wiimote_.addEventListener( WiimoteEvent.UPDATE,
            function(e:WiimoteEvent) {
                peakDetector_.addValue( wiimote_.sensorY + wiimote_.sensorZ );
                //trace( wiimote_.sensorZ );
                if( wiimote_.hasNunchuk ) {
                    dirx_ = wiimote_.nunchuk.stickX + DIRX_CALIBRATION;
                    diry_ = wiimote_.nunchuk.stickY + DIRY_CALIBRATION;
                }
            } );
    }
    
    //-----------------------------------------------------------------------------------
    // IEventDispatcher
    //-----------------------------------------------------------------------------------

    public function addEventListener( type: String, f: Function, capture: Boolean = false, priority: int = 0, weakRef: Boolean = false ): void {
        eventDispatcher_.addEventListener( type, f, capture, priority, weakRef );
    }
    
    public function dispatchEvent( e: Event ): Boolean {
        return eventDispatcher_.dispatchEvent( e );
    }
    
    public function hasEventListener( type: String ): Boolean {
        return eventDispatcher_.hasEventListener( type );
    }
    		
    public function removeEventListener( type: String, f: Function, capture: Boolean = false ):void {
        eventDispatcher_.removeEventListener( type, f, capture );
    }
    
    public function willTrigger( type: String ): Boolean {
        return eventDispatcher_.willTrigger( type );
    }
}

} //package