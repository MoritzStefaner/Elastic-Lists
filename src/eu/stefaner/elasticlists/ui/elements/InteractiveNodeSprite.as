/*
   
Copyright 2010, Moritz Stefaner

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
   
 */

package eu.stefaner.elasticlists.ui.elements {		import eu.stefaner.elasticlists.data.DataItem;	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;
	import flare.vis.data.NodeSprite;
	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.text.TextField;
	/**	 *	Base class for ContentItemSprites, FacetBoxElements	 *	provides click handler, selection state etc.	 *	 *	@langversion ActionScript 3.0	 *	@playerversion Flash 9.0	 *	 *	@author moritz@stefaner.eu	 *	@since  23.11.2007	 */	public class InteractiveNodeSprite extends NodeSprite {
		private var _label : String;		private var _selected : Boolean = false;		public var filteredOut : Boolean = false;		public var bg : Sprite;		public var title_tf : TextField;		public var selectionMarker : Sprite;
		public function InteractiveNodeSprite(o : Object = null) {			super();			if(o != null) {				data = o;			}						addEventListener(Event.ADDED_TO_STAGE, onStageInit);		}
		protected function onStageInit(event : Event) : void {			initGraphics();
			renderer = null;
			
			buttonMode = true;			mouseChildren = false;						addEventListener(MouseEvent.CLICK, onClick);						addEventListener(MouseEvent.ROLL_OVER, onRollOver);			addEventListener(MouseEvent.ROLL_OUT, onRollOut);						onSelectionStatusChange();		}
		protected function initGraphics() : void {			if(bg == null) {				bg = DefaultGraphicsFactory.getContentItemBackground();				addChild(bg);			}			if(selectionMarker == null) {				selectionMarker = DefaultGraphicsFactory.getSelectionMarker();				addChild(selectionMarker);			}						if(title_tf == null) {				title_tf = DefaultGraphicsFactory.getTextField();				addChild(title_tf);			}		}
		//--------------------------------------		//  CLASS METHODS		//--------------------------------------					// REVISIT: needed?		public static function getVisibility(n : InteractiveNodeSprite) : Boolean {			return !n.data.filteredOut;		};
		//--------------------------------------		//  GETTER/SETTERS		//--------------------------------------				/** Object storing backing data values. */		override public function get data() : Object { 			return DataItem(_data); 		}
		override public function set data(d : Object) : void {			if(!d is DataItem) {				throw new Error("InteractiveNodeSprite needs a DataItem as data");			} 			_data = DataItem(d); 			_data.addEventListener(DataItem.SELECTION_STATUS_CHANGE, onSelectionStatusChange, false, 0, true);						onSelectionStatusChange();		}
		// label				public function set label( arg : String ) : void { 			_label = arg;			if(title_tf) {				title_tf.text = arg ? arg : "";			}		}
		public function get label() : String { 			return _label; 		}
		// height				override public function set height( h : Number ) : void { 			bg.height = selectionMarker.height = h;					}
		override public function get height() : Number { 			return bg.height; 		}	
		// width		override public function set width( w : Number ) : void { 			bg.width = selectionMarker.width = w;		}
		override public function get width() : Number { 			return bg.width; 		}
		// selected		public function set selected( arg : Boolean ) : void { 			_selected = arg;			if(selectionMarker) {				selectionMarker.visible = arg;				selectionMarker.alpha = 1;			}		}
		public function get selected() : Boolean { 			return _selected; 		}
		public function onSelectionStatusChange(e : Event = null) : void {			selected = data.selected;		};
		// MOUSE EVENTS		protected function onRollOver(e : MouseEvent) : void {			selectionMarker.visible = true;			selectionMarker.alpha = .5;		};
		protected function onRollOut(e : MouseEvent) : void {			if(selected) {				selectionMarker.visible = true;				selectionMarker.alpha = 1;			} else {				selectionMarker.visible = false;				selectionMarker.alpha = .5;			}				};
		protected function onClick(e : MouseEvent) : void {			data.toggleSelected();		};	}}