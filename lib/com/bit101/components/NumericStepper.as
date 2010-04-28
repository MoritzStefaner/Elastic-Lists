/**
 * NumericStepper.as
 * Keith Peters
 * version 0.9.1
 * 
 * A component allowing for entering a numeric value with the keyboard, or by pressing up/down buttons.
 * 
 * Copyright (c) 2010 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.bit101.components
{
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import org.osmf.events.TimeEvent;
	
	public class NumericStepper extends Component
	{
		protected const DELAY_TIME:int = 500;
		protected const REPEAT_TIME:int = 100; 
		protected const UP:String = "up";
		protected const DOWN:String = "down";
		
		protected var _minusBtn:PushButton;
		protected var _plusBtn:PushButton;
		protected var _valueText:InputText;
		protected var _value:Number = 0;
		protected var _step:Number = 1;
		protected var _labelPrecision:int = 1;
		protected var _max:Number = Number.POSITIVE_INFINITY;
		protected var _min:Number = Number.NEGATIVE_INFINITY;
		protected var _delayTimer:Timer;
		protected var _repeatTimer:Timer;
		protected var _direction:String;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this Slider.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function NumericStepper(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultHandler:Function = null)
		{
			super(parent, xpos, ypos);
			if(defaultHandler != null)
			{
				addEventListener(Event.CHANGE, defaultHandler);
			}
		}
		
		/**
		 * Initializes the component.
		 */
		protected override function init():void
		{
			super.init();
			setSize(80, 16);
			_delayTimer = new Timer(DELAY_TIME, 1);
			_delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDelayComplete);
			_repeatTimer = new Timer(REPEAT_TIME);
			_repeatTimer.addEventListener(TimerEvent.TIMER, onRepeat);
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren():void
		{
			_valueText = new InputText(this, 0, 0, "0", onValueTextChange);
			_valueText.restrict = "-0123456789."
			_minusBtn = new PushButton(this, 0, 0, "-");
			_minusBtn.addEventListener(MouseEvent.MOUSE_DOWN, onMinus);
			_minusBtn.setSize(16, 16);
			_plusBtn = new PushButton(this, 0, 0, "+");
			_plusBtn.addEventListener(MouseEvent.MOUSE_DOWN, onPlus);
			_plusBtn.setSize(16, 16);
		}
		
		protected function increment():void
		{
			if(_value + _step <= _max)
			{
				_value += _step;
				invalidate();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		protected function decrement():void
		{
			if(_value - _step >= _min)
			{
				_value -= _step;
				invalidate();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		public override function draw():void
		{
			_plusBtn.x = _width - 16;
			_minusBtn.x = _width - 32;
			_valueText.text = (Math.round(_value * Math.pow(10, _labelPrecision)) / Math.pow(10, _labelPrecision)).toString();
			_valueText.width = _width - 32;
			_valueText.draw();
		}
		
		
		
		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Called when the minus button is pressed. Decrements the value by the step amount.
		 */
		protected function onMinus(event:MouseEvent):void
		{
			decrement();
			_direction = DOWN;
			_delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Called when the plus button is pressed. Increments the value by the step amount.
		 */
		protected function onPlus(event:MouseEvent):void
		{
			increment();
			_direction = UP;
			_delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			_delayTimer.stop();
			_repeatTimer.stop();
		}
		
		/**
		 * Called when the value is changed manually.
		 */
		protected function onValueTextChange(event:Event):void
		{
			var newVal:Number = Number(_valueText.text);
			if(newVal <= _max && newVal >= _min)
			{
				_value = newVal;
				invalidate();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}

		protected function onDelayComplete(event:TimerEvent):void
		{
			_repeatTimer.start();
		}

		protected function onRepeat(event:TimerEvent):void
		{
			if(_direction == UP)
			{
				increment();
			}
			else
			{
				decrement();
			}
		}
		
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Sets / gets the current value of this component.
		 */
		public function set value(value:Number):void
		{
			if(value <= _max && value >= _min)
			{
				_value = value;
				invalidate();
			}
		}
		public function get value():Number
		{
			return _value;
		}

		/**
		 * Sets / gets the amount the value will change when the up or down button is pressed. Must be zero or positive.
		 */
		public function set step(value:Number):void
		{
			if(value < 0) 
			{
				throw new Error("NumericStepper step must be positive.");
			}
			_step = value;
		}
		public function get step():Number
		{
			return _step;
		}

		/**
		 * Sets / gets how many decimal points of precision will be shown.
		 */
		public function set labelPrecision(value:int):void
		{
			_labelPrecision = value;
			invalidate();
		}
		public function get labelPrecision():int
		{
			return _labelPrecision;
		}

		/**
		 * Sets / gets the maximum value for this component.
		 */
		public function set max(value:Number):void
		{
			_max = value;
			if(_value > _max)
			{
				_value = _max;
				invalidate();
			}
		}
		public function get max():Number
		{
			return _max;
		}

		/**
		 * Sets / gets the maximum value for this component.
		 */
		public function set min(value:Number):void
		{
			_min = value;
			if(_value < _min)
			{
				_value = _min;
				invalidate();
			}
		}
		public function get min():Number
		{
			return _min;
		}


	}
}