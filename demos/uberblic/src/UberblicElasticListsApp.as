package {
	import eu.stefaner.elasticlists.App;
	import eu.stefaner.elasticlists.data.AsyncModel;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.data.FacetValue;
	import eu.stefaner.elasticlists.data.Model;
	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;
	import eu.stefaner.elasticlists.ui.appcomponents.ContentArea;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxContainer;
	import eu.stefaner.elasticlists.ui.facetboxes.elasticlist.ElasticListBox;

	import com.bit101.components.HBox;
	import com.bit101.components.VBox;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;
	import flash.text.TextField;

	/**
	 * @author mo
	 */
	public class UberblicElasticListsApp extends App {

		private var vBox : VBox;
		private var margin : Number = 10;
		private var hBox : HBox;
		private var firstRun : Boolean = true;

		function UberblicElasticListsApp() {
			super();
			Logger.info("App constructed");
		}

		override protected function initDisplay() : void {
			
			vBox = new VBox(this, margin, margin);
			vBox.spacing = margin;
			
			var tf : TextField = DefaultGraphicsFactory.getTitleTextField();
			tf.text = loaderInfo.parameters.appTitle ? loaderInfo.parameters.appTitle : "Elastic Lists test application";
			tf.scaleX = tf.scaleY = 2;
			
			vBox.addChild(tf);
			
			hBox = new HBox(vBox, 0, 0);
			hBox.spacing = margin * .33;
			
			for each (var facet:Facet in model.facets) {
				
				var f : FacetBoxContainer = new FacetBoxContainer(this);
				var facetBox : FacetBox;
				facetBox = new ElasticListBox();
				
				//facetBox.singleSelect = true;
				f.init(facet, facetBox);
				hBox.addChild(f);
				f.width = 180;
				f.height = 250;
			}

			contentArea = new ContentArea();
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
