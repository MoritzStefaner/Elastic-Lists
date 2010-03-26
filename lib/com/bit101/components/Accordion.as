/**
 * Accordion.as
 * Keith Peters
 * version 0.9.1
 * 
 * Essentially a VBox full of Windows. Only one Window will be expanded at any time.
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
	
	public class Accordion extends Component
	{
		private var _windows:Array;
		private var _winWidth:Number = 100;
		private var _winHeight:Number = 100;
		private var _vbox:VBox;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this Panel.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 */
		public function Accordion(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		/**
		 * Initializes the component.
		 */
		protected override function init():void
		{
			super.init();
			setSize(100, 120);
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren() : void
		{
			_vbox = new VBox(this);
			_vbox.spacing = 0;

			_windows = new Array();
			for(var i:int = 0; i < 2; i++)
			{
				var window:Window = new Window(_vbox, 0, 0, "Section " + (i + 1));
				window.hasMinimizeButton = true;
				window.draggable = false;
				window.addEventListener(Event.RESIZE, onWindowResize);
				if(i != 0) window.minimized = true;
				_windows.push(window);
			}
		}
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Adds a new window to the bottom of the accordion.
		 * @param title The title of the new window.
		 */
		public function addWindow(title:String):void
		{
			var window:Window = new Window(_vbox, 0, 0, title);
			window.hasMinimizeButton = true;
			window.minimized = true;
			window.draggable = false;
			window.addEventListener(Event.RESIZE, onWindowResize);
			_windows.push(window);
			setSize(_width, _height);
		}
		
		/**
		 * Sets the size of the component.
		 * @param w The width of the component.
		 * @param h The height of the component.
		 */
		override public function setSize(w:Number, h:Number) : void
		{
			super.setSize(w, h);
			_winWidth = w;
			_winHeight = h - (_windows.length - 1) * 20;
			for(var i:int = 0; i < _windows.length; i++)
			{
				_windows[i].setSize(_winWidth, _winHeight);
			}
		}
		
		/**
		 * Returns the Window at the specified index.
		 * @param index The index of the Window you want to get access to.
		 */
		public function getWindowAt(index:int):Window
		{
			return _windows[index];
		}

		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Called when any window is resized. If the window has been expanded, it closes all other windows.
		 */
		protected function onWindowResize(event:Event):void
		{
			var window:Window = event.target as Window;
			if(!window.minimized)
			{
				for(var i:int = 0; i < _windows.length; i++)
				{
					var win2:Window = _windows[i] as Window;
					if(win2 != window)
					{
						win2.minimized = true;
					}
				}
			}
		}
		
	}
}