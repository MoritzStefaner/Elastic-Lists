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
	import eu.stefaner.elasticlists.App;
	import eu.stefaner.elasticlists.data.AsyncModel;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.data.Model;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;

	[SWF(backgroundColor="#DDDDDD", frameRate="31", width="1024", height="768")]

	public class UberblicElasticListsApp extends App {

		private var firstRun : Boolean = true;

		function UberblicElasticListsApp() {
			super();
			Logger.info("App constructed");
		}

		override protected function onDataLoaded(e : Event) : void {
			Logger.info("App.onDataLoaded");
			//
			if(firstRun) {
				firstRun = false;
				initDisplay();
				dispatchEvent(new Event(FACETS_CHANGED));
			}
			
			for each(var facet:Facet in model.facets) {
				facet.calcGlobalStats();
				facet.calcLocalStats();
			}
			
			dispatchEvent(new Event(FILTERS_CHANGED));
			dispatchEvent(new Event(CONTENTITEMS_CHANGED));
			
			contentArea.title_tf.text = (dataConnector as UberblicDataConnector).numResults + " RESULTS";
		}

		override public function applyFilters() : void {
			Logger.info("App.applyFilters");
			model.updateActiveFilters();
			loadData();
		}

		override protected function createModel() : Model {
			return new AsyncModel(this);
		}

		override protected function createDataConnector() : DataConnector {
			var d : UberblicDataConnector = new UberblicDataConnector(model);
			if(loaderInfo.parameters.queryURL) {
				d.baseURL = loaderInfo.parameters.queryURL; 
			}
			d.addEventListener(DataConnector.DATA_LOADED, onDataLoaded);
			return d;
		}
	}
}
