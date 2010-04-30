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

package eu.stefaner.elasticlists.data {		/**	 * 	DataItem 	 * 	 * 	base class for ContentItem and FacetValue	 * 	stores and dispatches selection and filtering state	 *	 *	@langversion ActionScript 3.0	 *	@playerversion Flash 9.0	 *	 *	@author moritz@stefaner.eu	 */	import flash.events.Event;	import flash.events.EventDispatcher;	public class DataItem extends EventDispatcher {		protected var _selected : Boolean = false;		protected var _highlighted : Boolean = false;		protected var _filteredOut : Boolean = false;		public var props : Object = {};		// events		public static var SELECTION_STATUS_CHANGE : String = "SELECTION_STATUS_CHANGE";		public static const HIGHLIGHT_STATUS_CHANGE : String = "HIGHLIGHT_STATUS_CHANGE";
		public function DataItem(o : Object = null) {			super();			if(o != null) {				props = o;			}		}
		public function get selected() : Boolean { 			return _selected; 		}
		public function set selected( arg : Boolean ) : void { 			if(arg == _selected) {				return;			}			_selected = arg; 			dispatchEvent(new Event(DataItem.SELECTION_STATUS_CHANGE));		}
		public function toggleSelected() : void { 			selected = !selected;		}
		public function get filteredOut() : Boolean { 			return _filteredOut; 		}
		public function set filteredOut( arg : Boolean ) : void { 			_filteredOut = arg; 		}		public function get highlighted() : Boolean {			return _highlighted;		}		public function set highlighted(arg : Boolean) : void {			if(arg == _highlighted) {				return;			}			_highlighted = arg; 			dispatchEvent(new Event(DataItem.HIGHLIGHT_STATUS_CHANGE));		}	}}