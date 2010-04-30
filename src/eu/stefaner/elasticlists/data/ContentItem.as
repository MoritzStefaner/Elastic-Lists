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

package eu.stefaner.elasticlists.data {		/**	 * 	ContentItem 	 * 	 * 	data object representing a content item / search result etc.	 *	 *	@langversion ActionScript 3.0	 *	@playerversion Flash 9.0	 *	 *	@author moritz@stefaner.eu	 */	import flash.utils.Dictionary;	public class ContentItem extends DataItem {		// stores facet values (FacetValue objects) by facet (Facet object)
		public var facetValues:Dictionary;		// stores raw values, unparsed vales and additional info (title, description etc.)		public var rawValues:Object;		// title
		public var title:String;		// unique id		public var id:String;		// url		// ?		public var url:String;		//	CONSTRUCTOR:
		public function ContentItem(id:String) {			this.id = id;			facetValues = new Dictionary(true);			rawValues = new Object();					}
		override public function toString():String {			return "[Object ContentItem title:" + title + " id:" + id + "]";		};		public function addRawValue(key:String, v:*):void {			if(rawValues[key] == null) {				rawValues[key] = v;			} else if(!(rawValues[key] is Array)) {				rawValues[key] = new Array(rawValues[key]);				rawValues[key].push(v);			} else {				rawValues[key].push(v);			}		}	}}