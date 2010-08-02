package eu.stefaner.elasticlists.demos.warlogs {
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.data.GeoFacet;
	import eu.stefaner.elasticlists.data.Model;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * @author mo
	 */
	public class WarlogsDataConnector extends DataConnector {

		public function WarlogsDataConnector(m : Model) {
			super(m);
		}

		override public function loadData(query : Dictionary = null) : void {
			startRequest("data/Afghanevents1_mod.txt");
		}

		override protected function onDataLoaded(e : Event) : void {
			Logger.info("data loaded", e.target.data.length);
			var f : Facet ; 
			var entries : Array = e.target.data.split(/\r\n|\r|\n/);
			model.registerFacet(new Facet("type", "Type"));
			//model.registerFacet(new Facet("guardian_category"));
			model.registerFacet(new Facet("category", "Category"));
			model.registerFacet(new Facet("attackon", "Attack on"));
			model.registerFacet(new Facet("date")).sortFields = [];
			model.registerFacet(new GeoFacet("geolocation", "Location"));
			// remove headers
			entries.shift();
			for each (var entry:String in entries) {
				parseContentItemString(entry);
				//Logger.info("parsing", entry);
			}
			dispatchEvent(new Event(DATA_LOADED));
		}

		private function parseContentItemString(entry : String) : void {
			var list : Array = entry.split("\t");
			var c : ContentItem = model.createContentItem(list.shift());
			c.addRawValue("url", list.shift());
			c.addRawValue("lat", Number(list.shift().replace(",", ".")));
			c.addRawValue("long", Number(list.shift().replace(",", ".")));
			c.addRawValue("bundle", list.shift());
			c.addRawValue("guardian_headline", list.shift());
			var dateArray : Array = list.shift().split(".");
			c.addRawValue("date", new Date(Number(dateArray[2].split(" ")[0]), Number(dateArray[1]) - 1, Number(dateArray[0])));
			c.addRawValue("type", list.shift());
			c.addRawValue("category", list.shift());
			c.addRawValue("guardian_category", list.shift());
			c.addRawValue("attackon", list.shift());
			c.addRawValue("dcolor", list.shift());
			c.title = c.rawValues.guardian_headline;
			c.url = c.rawValues.url;
			model.assignFacetValueToContentItemByName(c.id, "type", c.rawValues.type);
			//model.assignFacetValueToContentItemByName(c.id, "guardian_category", c.rawValues.guardian_category);
			model.assignFacetValueToContentItemByName(c.id, "category", c.rawValues.category);
			model.assignFacetValueToContentItemByName(c.id, "attackon", c.rawValues.attackon);
			model.assignFacetValueToContentItemByName(c.id, "date", getQuarter(c.rawValues.date));
			if(c.rawValues.lat > 0 && c.rawValues.long > 0) model.assignFacetValueToContentItemByName(c.id, "geolocation", c.rawValues.lat + "," + c.rawValues.long);
		}

		private function getQuarter(date : Date) : String {
			return ["I", "II", "III", "IV"][int(date.month / 3)] + "" + date.fullYear.toString().substring(2);
		}
	}
}
