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

package {	import com.bit101.components.HBox;

	import eu.stefaner.elasticlists.App;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.ui.appcomponents.JavaScriptContentArea;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxContainer;
	import eu.stefaner.elasticlists.ui.facetboxes.elasticlist.ElasticListBox;

	import org.osflash.thunderbolt.Logger;
	[SWF(backgroundColor="#DDDDDD", frameRate="31", width="1024", height="768")]

	public class EADElasticListsApp extends eu.stefaner.elasticlists.App {

		function EADElasticListsApp() {			super();			Logger.info("App constructed");		}

		override protected function initDisplay() : void {						hBox = new HBox(this, 0, 0);			hBox.spacing = margin * .33;						for each (var facet:Facet in model.facets) {								var f : FacetBoxContainer = new FacetBoxContainer(this);				var facetBox : FacetBox;				facetBox = new ElasticListBox();								facetBox.singleSelect = true;								f.init(facet, facetBox);				hBox.addChild(f);				f.width = 180;				f.height = 200;			}						contentArea = new JavaScriptContentArea();			contentArea.init(this);		}	}}