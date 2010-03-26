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

		private var baseURL : String = "http://platform.uberblic.org/api/faceted_search?num_results=100&offset=0&facets=starring,director,producer,source&query=type:[uo:Film]";
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
				for each (var fv:FacetValue in model.activeFilters[f]) {
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
				if (facetName == "type") continue;
				var f : Facet = model.getFacetByName(facetName);
				
				if(f == null) {
					// create facet if necessary
					f = model.createFacet(facetName);
					f.label = facetName;
				}
			
				var facetValue : FacetValue;
				
				// reset counts
				for each (facetValue in f.facetValues) {
					facetValue.totalNumContentItems = facetValue.numContentItems = 0;
				}
				
				// loop through results and adopt values
				for each(var facetValueItem:Object in response.facets[facetName]) {
					facetValue = f.getFacetValueByName(facetValueItem.res_id);
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
