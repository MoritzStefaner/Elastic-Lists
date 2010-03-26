/**
 * FPSMeter.as
 * Keith Peters
 * version 0.9.1
 * 
 * An simple component showing the frames per second the current movie is running at.
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
	import flash.utils.getTimer;
	
	
	public class FPSMeter extends Component
	{
		private var _label:Label;
		private var _startTime:int;
		private var _frames:int;
		private var _prefix:String = "";
		private var _fps:int;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this ColorChooser.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param prefix A string to put in front of the number value shown. Default is "FPS:".
		 */
		
		public function FPSMeter(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, prefix:String="FPS:")
		{
			super(parent, xpos, ypos);
			_prefix = prefix;
			_label = new Label(this, 0, 0);
			_frames = 0;
			_startTime = getTimer();
			if(stage != null)
			{
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/**
		 * Internal enterFrame handler to measure fps and update label.
		 */
		protected function onEnterFrame(event:Event):void
		{
			// Increment frame count each frame. When more than a second has passed, 
			// display number of accumulated frames and reset.
			// Thus FPS will only be calculated and displayed once per second.
			// There are more responsive methods that calculate FPS on every frame. 
			// This method is uses less CPU and avoids the "jitter" of those other methods.
			_frames++;
			var time:int = getTimer();
			var elapsed:int = time - _startTime;
			if(elapsed >= 1000)
			{
				_fps = Math.round(_frames * 1000 / elapsed);
				_label.text = _prefix + _fps.toString();
				_frames = 0;
				_startTime = time;
			}
		}
		
		/**
		 * Stops the meter if it is removed from stage.
		 */
		protected function onRemovedFromStage(event:Event):void
		{
			stop();
		}
		
		/**
		 * Stops the meter by removing the enterFrame listener.
		 */
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/**
		 * Starts the meter again if it has been stopped.
		 */
		public function start():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/**
		 * Sets or gets the prefix shown before the number. Defaults to "FPS:".
		 */
		public function set prefix(value:String):void
		{
			_prefix = value;
		}
		public function get prefix():String
		{
			return _prefix;
		}
		
		/**
		 * Returns the current calculated FPS.
		 */
		public function get fps():int
		{
			return _fps;
		}
	}
}