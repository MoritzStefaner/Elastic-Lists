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
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;
	import eu.stefaner.elasticlists.ui.appcomponents.ContentArea;
	import eu.stefaner.elasticlists.ui.contentitem.ContentItemSprite;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxContainer;
	import eu.stefaner.elasticlists.ui.facetboxes.elasticlist.ElasticListBox;

	import com.bit101.components.HBox;
	import com.bit101.components.VBox;

	import flash.text.TextField;

	/**
	 * @author mo
	 */
	[SWF(backgroundColor="#DDDDDD", frameRate="31", width="1024", height="768")]

	public class NobelApp extends App {

		private var vBox : VBox;
		private var hBox : HBox;
		private var margin : Number = 15;

		public function NobelApp() {
			super();
		}

		override protected function createDataConnector() : DataConnector {
			return new NobelDataConnector(model);
		}

		override public function createContentItemSprite(contentItem : ContentItem) : ContentItemSprite {
			return new NobelPrizeWinner(contentItem);
		}

		override protected function initDisplay() : void {
			
			vBox = new VBox(this, margin, margin);
			vBox.spacing = margin;
			
			var tf : TextField = DefaultGraphicsFactory.getTitleTextField();
			tf.text = "Nobel prize winners 1901 - 2004";
			tf.scaleX = tf.scaleY = 2;
			
			vBox.addChild(tf);
			
			hBox = new HBox(vBox, 0, 0);
			hBox.spacing = margin * .33;
			var facetNames : Array = ["prize", "gender", "country", "decade", "year"];
			for each (var fn:String in facetNames) {
				var facet : Facet = model.getFacetByName(fn);
				var f : FacetBoxContainer = new FacetBoxContainer(this);
				var facetBox : FacetBox;
				facetBox = new ElasticListBox();
				
				f.init(facet, facetBox);
				hBox.addChild(f);
				f.width = 180;
				f.height = 240;
			}

			contentArea = new ContentArea();
			contentArea.RESULTS_TEXT = "{0} nobel prize winners found"; 
			contentArea.init(this);
			vBox.addChild(contentArea);
			
			layout();
		}

		override protected function layout() : void {
			hBox.draw();
			vBox.draw();
			
			contentArea.width = stage.stageWidth - margin * 2;
			contentArea.height = stage.stageHeight - contentArea.getBounds(this).top - margin ;	
		}
	}
}
