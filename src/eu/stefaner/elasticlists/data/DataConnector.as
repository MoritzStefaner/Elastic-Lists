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
package eu.stefaner.elasticlists.data {
	import br.com.stimuli.loading.BulkLoader;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	/**	 *	DataConnector	 *		 *	The DataConnector is customized for each Facet Browser application. 	 *	It operates directly on the model to create facets, facetvalues and content items from external (e.g. XML sources).	 *		 *		 *	@langversion ActionScript 3.0	 *	@playerversion Flash 9.0	 *	 *	@author moritz@stefaner.eu	 */
	public class DataConnector extends EventDispatcher {
		public var facetsURL : String = "data/facets.xml";
		public var contentItemsURL : String = "data/contentitems.xml";
		protected var model : Model;
		public static var DATA_LOADED : String = "onDataLoaded";
		private var loader : URLLoader;

		public function DataConnector(m : Model) {
			super();
			model = m;
		}

		public function loadData(query : Dictionary = null) : void {
			// either: loading multiple files
			AssetLoader.loadXML(facetsURL, "facets");
			AssetLoader.loadXML(contentItemsURL, "contentItems");
			AssetLoader.bulkLoader.addEventListener(BulkLoader.COMPLETE, onDataLoaded);
			// or: load one file			// startRequest(url);			// but then, also the onDataLoaded has to be adjusted (e.target.data contains loaded data then)			
		};

		protected function startRequest(s : String) : void {
			Logger.info("loading", s);
			if(loader) {
				loader.removeEventListener(Event.COMPLETE, onDataLoaded);
			}
			try {
				loader = new URLLoader();
				loader.load(new URLRequest(s));
			} catch (e : Error) {
				Logger.error(e.message);
			}
			loader.addEventListener(Event.COMPLETE, onDataLoaded);
		}

		protected function onDataLoaded(e : Event) : void {
			var xml : XML;
			// facets
			time = getTimer();
			xml = new XML(AssetLoader.bulkLoader.getXML("facets"));
			var f : Facet;
			var time : uint;
			for each(var facetXML:XML in xml.facet) {
				Logger.info("creating facet " + facetXML.name);
				f = model.registerFacet(new Facet(facetXML.name.toString(), facetXML.type.toString()));
				f.label = facetXML.label.toString();
				f.name = facetXML.name.toString();
				var facetValue : FacetValue;
				for each(var facetValueXML:XML in facetXML.facetValues.facetValue) {
					facetValue = f.createFacetValue(facetValueXML.name.toString());
					parseFacetValue(f, facetValue, facetValueXML);
				}
				/*				if(f is HierarchicalFacet) {					var i:uint = 0;					for each(var levelLabelXML:XML in facetXML.levelLabels.levelLabel) {						(f as HierarchicalFacet).levelLabels[i++] = levelLabelXML.toString();					}				}				 * 				 */
			}
			Logger.info("App.onFacetsLoaded ");
			// contentItems
			xml = new XML(AssetLoader.bulkLoader.getXML("contentItems"));
			var contentItem : ContentItem;
			for each(var contentItemXML:XML in xml..contentItem) {
				// will get or create contentItem
				parseContentItemFromXML(contentItemXML);
			}
			Logger.info("onContentItemsLoaded");
			dispatchEvent(new Event(DATA_LOADED));
		};

		private function parseFacetValue(facet : Facet, facetValue : FacetValue, xml : XML) : void {
			facetValue.label = xml.label.toString();
			facetValue.name = xml.name.toString();
			/*				// hierarchical			if (facetValue is HierarchicalFacetValue) {				for each(var childXML:XML in xml.facetValues.facetValue) {					var f:HierarchicalFacetValue = HierarchicalFacetValue(facet.createFacetValue(childXML.name.toString()));					(facetValue as HierarchicalFacetValue).addChild(f);					parseFacetValue(facet, f, childXML);				}			}			*/							// TODO: parse geo etc
		};

		protected var idCounter : Number = 0;

		protected function parseContentItemFromXML(xml : XML) : ContentItem {
			var id : String;
			if(xml.attribute("id")) {
				id = xml.attribute("id").toString();
			} else {
				id = String(idCounter++);
			}
			var contentItem : ContentItem = model.createContentItem(id);
			contentItem.title = xml.title.toString();
			var facet : Facet;
			var key : String;
			var value : String;
			for each(var attributeXML:XML in xml.children()) {
				key = attributeXML.name().toString();
				value = attributeXML.toString();
				if(model.facet(key)) {
					// field belongs to a facet
					// wll create facet value if needed
					model.assignFacetValueToContentItemByName(contentItem.id, key, value);
				}
				contentItem.addRawValue(key, value);
			}
			return contentItem;
		};

		protected function parseContentItemFromObject(o : Object) : ContentItem {
			var id : String;
			if(o.id) {
				id = String(o.id);
			} else {
				id = String(idCounter++);
			}
			var contentItem : ContentItem = model.createContentItem(id);
			for (var key:String in o) {
				var value : * = o[key];
				if( model.facet(key)) {
					// field belongs to a facet
					// wll create facet value if needed
					model.assignFacetValueToContentItemByName(contentItem.id, key, value);
				}
				contentItem.addRawValue(key, value);
			}
			return contentItem;
		}
	}
}