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
			
			f = model.createFacet("year");
			f.sortFields = ["label"];
			f.sortOptions = Array.NUMERIC | Array.DESCENDING;
			
			f = model.createFacet("decade");
			f.sortFields = ["label"];
			f.sortOptions = Array.NUMERIC | Array.DESCENDING;
			
			model.createFacet("country");
			model.createFacet("gender");
			model.createFacet("prize");
			var entries : Array = e.target.data.split("\n\n");
			for each (var entry:String in entries) {
				parseContentItemString(entry);
			}
			dispatchEvent(new Event(DATA_LOADED));
		}

		private var idCounter : Number = 0;

		private function parseContentItemString(entry : String) : void {
			var keyValueStrings : Array = entry.split("\n");
			var c : ContentItem = model.createContentItem(String(idCounter++));
			for each (var keyValueString:String in keyValueStrings) {
				var a : Array = keyValueString.split(": ");
				var key : String = a[0];
				var value : String = a[1];
				var facet : Facet;
				
				if(facet = model.getFacetByName(key)) {
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
