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

package eu.stefaner.elasticlists {
	import flash.external.ExternalInterface;
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.data.GeoFacet;
	import eu.stefaner.elasticlists.data.Model;
	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;
	import eu.stefaner.elasticlists.ui.appcomponents.ContentArea;
	import eu.stefaner.elasticlists.ui.appcomponents.DetailView;
	import eu.stefaner.elasticlists.ui.contentitem.ContentItemSprite;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxContainer;
	import eu.stefaner.elasticlists.ui.facetboxes.elasticlist.ElasticListBox;
	import eu.stefaner.elasticlists.ui.facetboxes.geo.GeoFacetBox;

	import com.bit101.components.HBox;
	import com.bit101.components.VBox;

	import org.osflash.thunderbolt.Logger;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;

	[SWF(backgroundColor="#EEEEEE", frameRate="31", width="1024", height="768")]

	/**
	 * App
	 *
	 * Main application class, associated with flash stage.
	 * Creates Model, DataConnector, DetailView etc., and  manages main application states
	 *
	 * For new applications, subclass and override as needed
	 * 
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10
	 * @version 1.0
	 *
	 * @author moritz@stefaner.eu
	 */
	public class App extends Sprite {

		/**
		 * Manages data and facet information 
		 */
		public var model : Model;
		/**
		 * provides connectivity to external data 
		 */
		public var dataConnector : DataConnector;
		/**
		 * displays the result set
		 */
		public var contentArea : ContentArea;
		/** display details for selected contentitem
		 * 
		 */
		public var detailView : DetailView;
		// events

		/** 
		 * dispatched when all facets are loaded and inited
		 * TODO: revisit - really needed?
		 */
		// 
		public static var FACETS_CHANGED : String = "FACETS_CHANGED";
		/**
		 * disptached when (visible or all) contentitems have changed
		 */
		public static var CONTENTITEMS_CHANGED : String = "CONTENTITEMS_CHANGED";
		/**
		 * disptached when facet values (or their stats) are changed 
		 */
		public static var FILTERS_CHANGED : String = "FILTERS_CHANGED";
		protected var vBox : VBox;
		protected var margin : Number = 15;
		protected var hBox : HBox;
		protected var titleTextField : TextField;
		/**
		 * constructor, calls @see startup
		 */
		public function App() {
			this.startUp();
		}

		/** 
		 * initialize @see model and @see dataConnector, starts loading data
		 */
		protected function startUp() : void {
			initStage();
			model = createModel();
			dataConnector = createDataConnector();
			dataConnector.addEventListener(DataConnector.DATA_LOADED, onDataLoaded);
			loadData();
		}

		/**
		 * set scale mode, alignment and add resize listener
		 */
		protected function initStage() : void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
		}

		/**
		 * Resize event handler
		 */
		protected function onResize(e : Event) : void {
			layout();
		}

		/**
		 * start loading data, calls @see eu.stefaner.elasticlists.data.DataConnector.loadData
		 */
		protected function loadData() : void {
			dataConnector.loadData();
		}

		/**
		 * start loading data, calls @see eu.stefaner.elasticlists.data.DataConnector.loadData
		 */
		protected function onDataLoaded(e : Event) : void {
			Logger.info("App.onDataLoaded");
			initDisplay();
			model.updateGlobalStats();
			
			dispatchEvent(new Event(FACETS_CHANGED));
			dispatchEvent(new Event(CONTENTITEMS_CHANGED));
			applyFilters();
		}

		protected function initDisplay() : void {
			// create facet boxes etc
			vBox = new VBox(this, margin, margin);
			vBox.spacing = margin;
			
			titleTextField = DefaultGraphicsFactory.getTitleTextField();
			titleTextField.text = "Elastic Lists test application";
			titleTextField.scaleX = titleTextField.scaleY = 2;
			if(loaderInfo.parameters.appTitle) {
				title = loaderInfo.parameters.appTitle; 
			} else {
				title = _title;
			}
			
			vBox.addChild(titleTextField);
			
			hBox = new HBox(vBox, 0, 0);
			hBox.spacing = margin * .33;
			
			for each (var facet:Facet in model.facets) {
				
				var f : FacetBoxContainer = new FacetBoxContainer(this);
				var facetBox : FacetBox;
				if(facet is GeoFacet) {
					facetBox = new GeoFacetBox();
				} else {
					facetBox = new ElasticListBox();
				}
				
				f.init(facet, facetBox);
				hBox.addChild(f);
				f.width = 180 + 180 * Number(facet is GeoFacet);
				f.height = 200;
			}

			contentArea = new ContentArea();
			contentArea.init(this);
			vBox.addChild(contentArea);
			
			layout();
		}

		protected function layout() : void {
			hBox.draw();
			vBox.draw();
			
			contentArea.width = stage.stageWidth - margin * 2;
			contentArea.height = stage.stageHeight - contentArea.getBounds(this).top - margin ;	
		}
		/*
		 * creates and returns the dataConnector
		 */
		protected function createDataConnector() : DataConnector {
			return new DataConnector(model);
		}

		/*
		 * creates and returns the model
		 */
		protected function createModel() : Model {
			return new Model(this);
		}

		public function createContentItem(id : String) : ContentItem {
			return new ContentItem(id);
		}

		/*
		 * called by ContentArea to get a sprite for a contentItem
		 */
		// 
		public function createContentItemSprite(contentItem : ContentItem) : ContentItemSprite {
			return new ContentItemSprite(contentItem);
		}

		/*
		 * called by FacetBoxContainer.onSelectionChange
		 * TODO: use events?
		 */
		public function applyFilters() : void {
			
			model.applyFilters();
			
			for each (var facet:Facet in model.facets) {
				facet.calcLocalStats();
			}
			
			dispatchEvent(new Event(FILTERS_CHANGED));
			
			if (contentArea.selectedContentItem && contentArea.selectedContentItem.filteredOut) {
				contentArea.selectedContentItem.selected = false;
			}
			
			showDetails(contentArea.selectedContentItem);
		}

		/** 
		 * show details for selected ContentItem
		 * called by ContentArea when item is clicked
		 */
		public function showDetails(selection : ContentItem = null) : void {
			if (detailView) {
				detailView.display(selection);
			}
		}

		private var _title : String = "Elastic Lists";

		public function get title() : String {
			return _title;
		}

		public function set title(title : String) : void {
			_title = title;
			if(titleTextField) titleTextField.text = title;
		}
	}
}