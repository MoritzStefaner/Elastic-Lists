/**
 * List.as
 * Keith Peters
 * version 0.9.1
 * 
 * A scrolling list of selectable items. 
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
	
	public class List extends Component
	{
		protected var _items:Array;
		protected var _itemHolder:Sprite;
		protected var _panel:Panel;
		protected var _listItemHeight:Number = 20;
		protected var _listItemClass:Class =ListItem;
		protected var _scrollbar:VScrollBar;
		protected var _selectedIndex:int = -1;
		protected var _defaultColor:uint = 0xffffff;
		protected var _selectedColor:uint = 0xdddddd;
		protected var _rolloverColor:uint = 0xeeeeee;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this List.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param items An array of items to display in the list. Either strings or objects with label property.
		 */
		public function List(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null)
		{
			if(items != null)
			{
				_items = items;
			}
			else
			{
				_items = new Array();
			}
			super(parent, xpos, ypos);
		}
		
		/**
		 * Initilizes the component.
		 */
		protected override function init() : void
		{
			super.init();
			setSize(100, 100);
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren() : void
		{
			super.addChildren();
			_panel = new Panel(this, 0, 0);
			_panel.color = _defaultColor;
			_itemHolder = new Sprite();
			_panel.content.addChild(_itemHolder);
			_scrollbar = new VScrollBar(this, 0, 0, onScroll);
		}
		
		/**
		 * Creates all the list items based on data.
		 */
		protected function makeListItems():void
		{
			while(_itemHolder.numChildren > 0) _itemHolder.removeChildAt(0);

			for(var i:int = 0; i < _items.length; i++)
			{
//				var label:String = "";
//				if(_items[i] is String)
//				{
//					label = _items[i];
//				}
//				else if(_items[i].label is String)
//				{
//					label = _items[i].label;
//				}
				var item:ListItem = new _listItemClass(_itemHolder, 0, i * _listItemHeight, _items[i]);
				item.setSize(width, _listItemHeight);
				item.defaultColor = _defaultColor;
				item.selectedColor = _selectedColor;
				item.rolloverColor = _rolloverColor;
				item.addEventListener(MouseEvent.CLICK, onSelect);
				if(i == _selectedIndex)
				{
					item.selected = true;
				}
			}
		}
		
		/**
		 * If the selected item is not in view, scrolls the list to make the selected item appear in the view.
		 */
		protected function scrollToSelection():void
		{
			if(_selectedIndex != -1)
			{
				var itemTop:Number = _itemHolder.y + _selectedIndex * _listItemHeight;
				var itemBottom:Number = itemTop + _listItemHeight;
				// if selected item is not in view...
				// move holder to put item in view
				// and update scrollbar
				if(itemTop < 0)
				{
					_itemHolder.y = -_selectedIndex * _listItemHeight;
				}
				else if(itemBottom > _height)
				{
					_itemHolder.y = -_selectedIndex * _listItemHeight - _listItemHeight + _height;
				}
			}
		}
		
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		public override function draw() : void
		{
			super.draw();
			
			_selectedIndex = Math.min(_selectedIndex, _items.length - 1);

			// list items
			makeListItems();
			scrollToSelection();
			
			// panel
			_panel.setSize(_width, _height);
			_panel.color = _defaultColor;
			_panel.draw();
			
			// scrollbar
			_scrollbar.x = _width - 10;
			var contentHeight:Number = _items.length * _listItemHeight;
			_scrollbar.setThumbPercent(_height / contentHeight); 
			var pageSize:Number = _height / _listItemHeight;
			_scrollbar.setSliderParams(0, Math.max(0, _items.length - pageSize), _itemHolder.y / _listItemHeight);
			_scrollbar.pageSize = pageSize;
			_scrollbar.height = _height;
			_scrollbar.draw();
		}
		
		/**
		 * Adds an item to the list.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 */
		public function addItem(item:Object):void
		{
			_items.push(item);
			invalidate();
		}
		
		/**
		 * Adds an item to the list at the specified index.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 * @param index The index at which to add the item.
		 */
		public function addItemAt(item:Object, index:int):void
		{
			index = Math.max(0, index);
			index = Math.min(_items.length, index);
			_items.splice(index, 0, item);
			invalidate();
		}
		
		/**
		 * Removes the referenced item from the list.
		 * @param item The item to remove. If a string, must match the item containing that string. If an object, must be a reference to the exact same object.
		 */
		public function removeItem(item:Object):void
		{
			var index:int = _items.indexOf(item);
			removeItemAt(index);
		}
		
		/**
		 * Removes the item from the list at the specified index
		 * @param index The index of the item to remove.
		 */
		public function removeItemAt(index:int):void
		{
			if(index < 0 || index >= _items.length) return;
			_items.splice(index, 1);
			invalidate();
		}
		
		/**
		 * Removes all items from the list.
		 */
		public function removeAll():void
		{
			_items.length = 0;
			invalidate();
		}
		
		
		
		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Called when a user selects an item in the list.
		 */
		protected function onSelect(event:Event):void
		{
			if(! (event.target is ListItem)) return;
			
			for(var i:int = 0; i < _itemHolder.numChildren; i++)
			{
				if(_itemHolder.getChildAt(i) == event.target) _selectedIndex = i;
				ListItem(_itemHolder.getChildAt(i)).selected = false;
			}
			ListItem(event.target).selected = true;
			dispatchEvent(new Event(Event.SELECT));
		}
		
		/**
		 * Called when the user scrolls the scroll bar.
		 */
		protected function onScroll(event:Event):void
		{
			_itemHolder.y = -_scrollbar.value * _listItemHeight;
		}
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Sets / gets the index of the selected list item.
		 */
		public function set selectedIndex(value:int):void
		{
			if(value >= 0 && value < _items.length)
			{
				_selectedIndex = value;
				invalidate();
				dispatchEvent(new Event(Event.SELECT));
			}
		}
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		/**
		 * Sets / gets the item in the list, if it exists.
		 */
		public function set selectedItem(item:Object):void
		{
			var index:int = _items.indexOf(item);
			if(index != -1)
			{
				_selectedIndex = index;
				invalidate();
				dispatchEvent(new Event(Event.SELECT));
			}
		}
		public function get selectedItem():Object
		{
			if(_selectedIndex >= 0 && _selectedIndex < _items.length)
			{
				return _items[_selectedIndex];
			}
			return null;
		}

		/**
		 * Sets/gets the default background color of list items.
		 */
		public function set defaultColor(value:uint):void
		{
			_defaultColor = value;
			invalidate();
		}
		public function get defaultColor():uint
		{
			return _defaultColor;
		}

		/**
		 * Sets/gets the selected background color of list items.
		 */
		public function set selectedColor(value:uint):void
		{
			_selectedColor = value;
			invalidate();
		}
		public function get selectedColor():uint
		{
			return _selectedColor;
		}

		/**
		 * Sets/gets the rollover background color of list items.
		 */
		public function set rolloverColor(value:uint):void
		{
			_rolloverColor = value;
			invalidate();
		}
		public function get rolloverColor():uint
		{
			return _rolloverColor;
		}

		/**
		 * Sets the height of each list item.
		 */
		public function set listItemHeight(value:Number):void
		{
			_listItemHeight = value;
			invalidate();
		}
		public function get listItemHeight():Number
		{
			return _listItemHeight;
		}

		/**
		 * Sets / gets the list of items to be shown.
		 */
		public function set items(value:Array):void
		{
			_items = value;
			invalidate();
		}
		public function get items():Array
		{
			return _items;
		}

		/**
		 * Sets / gets the class used to render list items. Must extend ListItem.
		 */
		public function set listItemClass(value:Class):void
		{
			_listItemClass = value;
			invalidate();
		}
		public function get listItemClass():Class
		{
			return _listItemClass;
		}

		
	}
}