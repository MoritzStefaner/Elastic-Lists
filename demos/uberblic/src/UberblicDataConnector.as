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
	import eu.stefaner.elasticlists.data.AsyncModel;
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.data.FacetValue;
	import eu.stefaner.elasticlists.data.Model;

	import com.adobe.serialization.json.JSON;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * @author mo
	 */
	public class UberblicDataConnector extends DataConnector {

		public  var baseURL : String = "http://platform.uberblic.org/api/faceted_search?num_results=100&offset=0&facets=starring,director,producer,source&query=type:[uo:Film]";
		public var numResults : Number;

		public function UberblicDataConnector(m : Model) {
			super(m);
		}

		override public function loadData(query : Dictionary = null) : void {
			var url : String = baseURL;
			Logger.info("filters", model.activeFilters);
			
			for (var f:* in model.activeFilters) {
				url += "%20" + f.name + ":[";
				var a : Array = [];
				for each (var fv:FacetValue in model.activeFilters[f].values) {
					a.push(fv.name);
				}
				url += a.toString() + "]";
			}
			
			startRequest(url);
		}

		override protected function onDataLoaded(e : Event) : void {
			Logger.info("data received", e.target.data);
			var response : * = JSON.decode(e.target.data);
			
			for (var facetName:String in response.facets) {
				// get facet
				var f : Facet = model.facet(facetName);
				
				if(f == null) {
					// create facet if necessary
					f = model.registerFacet(new Facet(facetName));
				}
			
				var facetValue : FacetValue;
				
				// reset counts
				for each (facetValue in f.facetValues) {
					facetValue.totalNumContentItems = facetValue.numContentItems = 0;
				}
				
				// loop through results and adopt values
				for each(var facetValueItem:Object in response.facets[facetName]) {
					facetValue = f.facetValue(facetValueItem.res_id);
					if(!facetValue) {
						// create value if necessary
						facetValue = f.createFacetValue(facetValueItem.res_id);
						if(facetValueItem.label) facetValue.label = facetValueItem.label;
					} 
					facetValue.totalNumContentItems = facetValue.numContentItems = facetValueItem.count;
				}
			}
			// contentitems
			(model as AsyncModel).clearContentItems();
			
			var c : ContentItem;
			for each (var item:Object in response.results) {
				c = model.createContentItem(item.resource_id);
				c.title = item.label;
			}
			
			numResults = Number(response.total);
			dispatchEvent(new Event(DATA_LOADED));
		}
	}
}
