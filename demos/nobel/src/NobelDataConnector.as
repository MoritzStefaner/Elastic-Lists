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

package {
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.data.Model;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * @author mo
	 */
	public class NobelDataConnector extends DataConnector {

		public function NobelDataConnector(m : Model) {
			super(m);
		}

		override public function loadData(query : Dictionary = null) : void {
			startRequest("data/nobel.txt");
		}

		override protected function onDataLoaded(e : Event) : void {
			Logger.info("data loaded");
			var f : Facet ; 
			
			f = model.registerFacet(new Facet("year"));
			f.sortFields = ["label"];
			f.sortOptions = Array.NUMERIC | Array.DESCENDING;
			
			f = model.registerFacet(new Facet("decade"));
			f.sortFields = ["label"];
			f.sortOptions = Array.NUMERIC | Array.DESCENDING;
			
			model.registerFacet(new Facet("country"));
			model.registerFacet(new Facet("gender"));
			model.registerFacet(new Facet("prize"));
			
			var entries : Array = e.target.data.split("\n\n");
			for each (var entry:String in entries) {
				parseContentItemString(entry);
			}
			dispatchEvent(new Event(DATA_LOADED));
		}


		private function parseContentItemString(entry : String) : void {
			var keyValueStrings : Array = entry.split("\n");
			var c : ContentItem = model.createContentItem(String(idCounter++));
			for each (var keyValueString:String in keyValueStrings) {
				var a : Array = keyValueString.split(": ");
				var key : String = a[0];
				var value : String = a[1];
				var facet : Facet;
				
				if(facet = model.facet(key)) {
					// field belongs to a facet
					// wll create facet value if needed
					model.assignFacetValueToContentItemByName(c.id, facet.name, value);
				} 
				c.addRawValue(key, value);
				if(key == "name") c.title = value;
				if(key == "year") model.assignFacetValueToContentItemByName(c.id, "decade", String(Math.floor(Number(value) / 10) * 10));
			}
		}
	}
}
