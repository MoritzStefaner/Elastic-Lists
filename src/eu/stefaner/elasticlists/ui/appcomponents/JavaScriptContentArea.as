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

package eu.stefaner.elasticlists.ui.appcomponents {	import eu.stefaner.elasticlists.App;	import eu.stefaner.elasticlists.ui.appcomponents.ContentArea;	import org.osflash.thunderbolt.Logger;	import flash.events.Event;	import flash.external.ExternalInterface;	/**	 * @author mo	 */	public class JavaScriptContentArea extends ContentArea {		public function JavaScriptContentArea() {			super();		}		override public function init(app:App):void {			this.app = app;			app.addEventListener(App.FILTERS_CHANGED, onFilteredContentItemsChanged, false, 0, true);		}		override public function onFilteredContentItemsChanged(e:Event):void {				if(ExternalInterface.available) {				var resultsArray = app.model.filteredContentItems.map(function(a) {					return a.rawValues;				});				ExternalInterface.call("onFilteredContentItemsChanged", resultsArray);			} else {				Logger.warn("ExternalInterface not available");			}		};	}}