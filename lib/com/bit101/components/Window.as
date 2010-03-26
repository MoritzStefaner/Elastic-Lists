/**
 * Window.as
 * Keith Peters
 * version 0.9.1
 * 
 * A draggable window. Can be used as a container for other components.
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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Window extends Component
	{
		private var _title:String;
		private var _titleBar:Panel;
		private var _titleLabel:Label;
		private var _panel:Panel;
		private var _color:int = -1;
		private var _shadow:Boolean = true;
		private var _draggable:Boolean = true;
		private var _minimizeButton:Sprite;
		private var _hasMinimizeButton:Boolean = false;
		private var _minimized:Boolean = false;
		
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this Panel.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param title The string to display in the title bar.
		 */
		public function Window(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, title:String="Window")
		{
			_title = title;
			super(parent, xpos, ypos);
		}
		
		/**
		 * Initializes the component.
		 */
		override protected function init():void
		{
			super.init();
			setSize(100, 100);
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void
		{
			_titleBar = new Panel(this);
			_titleBar.buttonMode = true;
			_titleBar.useHandCursor = true;
			_titleBar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_titleBar.height = 20;
			_titleLabel = new Label(_titleBar.content, 5, 1, _title);
			
			_panel = new Panel(this, 0, 20);
			_panel.visible = !_minimized;
			
			_minimizeButton = new Sprite();
			_minimizeButton.graphics.beginFill(0, 0);
			_minimizeButton.graphics.drawRect(-10, -10, 20, 20);
			_minimizeButton.graphics.endFill();
			_minimizeButton.graphics.beginFill(0, .35);
			_minimizeButton.graphics.moveTo(-5, -3);
			_minimizeButton.graphics.lineTo(5, -3);
			_minimizeButton.graphics.lineTo(0, 4);
			_minimizeButton.graphics.lineTo(-5, -3);
			_minimizeButton.graphics.endFill();
			_minimizeButton.x = 10;
			_minimizeButton.y = 10;
			_minimizeButton.useHandCursor = true;
			_minimizeButton.buttonMode = true;
			_minimizeButton.addEventListener(MouseEvent.CLICK, onMinimize);
			
			filters = [getShadow(4, false)];
		}
		
		
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void
		{
			super.draw();
			_titleBar.color = _color;
			_panel.color = _color;
			_titleBar.width = width;
			_titleLabel.x = _hasMinimizeButton ? 20 : 5;
			_panel.setSize(_width, _height - 20);
		}


		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Internal mouseDown handler. Starts a drag.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			this.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			parent.addChild(this);
		}
		
		/**
		 * Internal mouseUp handler. Stops the drag.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			this.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMinimize(event:MouseEvent):void
		{
			minimized = !minimized;
		}
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Gets / sets whether or not this Window will have a drop shadow.
		 */
		public function set shadow(b:Boolean):void
		{
			_shadow = b;
			if(_shadow)
			{
				filters = [getShadow(4, false)];
			}
			else
			{
				filters = [];
			}
		}
		public function get shadow():Boolean
		{
			return _shadow;
		}
		
		/**
		 * Gets / sets the background color of this panel.
		 */
		public function set color(c:int):void
		{
			_color = c;
			invalidate();
		}
		public function get color():int
		{
			return _color;
		}
		
		/**
		 * Gets / sets the title shown in the title bar.
		 */
		public function set title(t:String):void
		{
			_title = t;
			_titleLabel.text = _title;
		}
		public function get title():String
		{
			return _title;
		}
		
		/**
		 * Container for content added to this panel. This is just a reference to the content of the internal Panel, which is masked, so best to add children to content, rather than directly to the window.
		 */
		public function get content():DisplayObjectContainer
		{
			return _panel.content;
		}
		
		/**
		 * Sets / gets whether or not the window will be draggable by the title bar.
		 */
		public function set draggable(b:Boolean):void
		{
			_draggable = b;
			_titleBar.buttonMode = _draggable;
			_titleBar.useHandCursor = _draggable;
			if(_draggable)
			{
				_titleBar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			else
			{
				_titleBar.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		public function get draggable():Boolean
		{
			return _draggable;
		}
		
		/**
		 * Gets / sets whether or not the window will show a minimize button that will toggle the window open and closed. A closed window will only show the title bar.
		 */
		public function set hasMinimizeButton(b:Boolean):void
		{
			_hasMinimizeButton = b;
			if(_hasMinimizeButton)
			{
				addChild(_minimizeButton);
			}
			else if(contains(_minimizeButton))
			{
				removeChild(_minimizeButton);
			}
			invalidate();
		}
		public function get hasMinimizeButton():Boolean
		{
			return _hasMinimizeButton;
		}
		
		/**
		 * Gets / sets whether the window is closed. A closed window will only show its title bar.
		 */
		public function set minimized(value:Boolean):void
		{
			_minimized = value;
			_panel.visible = !_minimized;
			if(_minimized)
			{
				_minimizeButton.rotation = -90;
			}
			else
			{
				_minimizeButton.rotation = 0;
			}
			dispatchEvent(new Event(Event.RESIZE));
		}
		public function get minimized():Boolean
		{
			return _minimized;
		}
		
		/**
		 * Gets the height of the component. A minimized window's height will only be that of its title bar.
		 */
		override public function get height():Number
		{
			if(_panel.visible)
			{
				return super.height;
			}
			else
			{
				return 20;
			}
		}
	}
}