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

package eu.stefaner.elasticlists.ui.facetboxes {	import eu.stefaner.elasticlists.App;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;

	import com.bit101.components.PushButton;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	/**	 *	Class description.	 *	 *	@langversion ActionScript 3.0	 *	@playerversion Flash 9.0	 *	 *	@author moritz@stefaner.eu	 *	@since  24.05.2008	 */	public class FacetBoxContainer extends Sprite { 

		public var app : App;		public var title_tf : TextField;		public var bg : Sprite;		public var resetButton : PushButton;		public var facet : Facet;		public var facetBox : FacetBox;

		/**		 *	@Constructor		 */		public function FacetBoxContainer(app : App) {			super();			initGraphics();			this.app = app;			app.addEventListener(App.FACETS_CHANGED, onFacetValuesLoaded);			app.addEventListener(App.FILTERS_CHANGED, onFacetsStatsChanged);		}

		override public function toString() : String {			if(facet) {				return "[FacetBoxContainer " + facet.label + "]";							} else {				return "[FacetBoxContainer]";							}		}

		public function init(facet : Facet, facetBox : FacetBox) : void {			trace("init " + facet);			this.facet = facet;			this.facetBox = facetBox;			facetBox.facet = facet;			title = facet.label;						addChild(facetBox);							facetBox.addEventListener(FacetBox.SELECTION_CHANGE, onSelectionChange, false, 1, true);			if(resetButton) {				resetButton.addEventListener(MouseEvent.CLICK, onResetClick);
			}
			// rescale if scaled on stage			initBounds();			layout();		};

		private function initGraphics() : void {			if(!bg) {				bg = DefaultGraphicsFactory.getFacetBoxContainerBackground();				addChild(bg);			}			if(!title_tf) {				title_tf = DefaultGraphicsFactory.getTitleTextField();				addChild(title_tf);			}
			/*
			if(!resetButton) {
				resetButton = DefaultGraphicsFactory.getButton(this, 0, 0, "reset");
				resetButton.width = 40;
			}
			 * 
			 */		}

		private function onResetClick(e : MouseEvent) : void {			facetBox.reset();		}

		private function initBounds() : void {			var w : Number = width * scaleX;			var h : Number = height * scaleY;			scaleX = scaleY = 1;			width = Math.floor(w);			height = Math.floor(h);		};

		private function onFacetValuesLoaded(e : Event = null) : void {			trace(this + ".onFacetValuesLoaded");		};

		private function onFacetsStatsChanged(e : Event = null) : void {			trace(this + ".onGlobalFacetValueStatsChanged");			facetBox.updateStats();		};

		private function onSelectionChange(e : Event = null) : void {			//dispatchEvent(new Event("onSelectionChange"));			trace(this + ".onSelectionChange");			app.applyFilters();		};

		//--------------------------------------		//  GETTER/SETTERS		//--------------------------------------		override public function set height( h : Number ) : void {			bg.height = h;			layout();		}

		protected function layout() : void {			title_tf.x = 2;			title_tf.y = 2;						if(facetBox) {				facetBox.x = 2;				facetBox.y = 22;				facetBox.height = height - facetBox.y - 2;				facetBox.width = width - 4;			}			if(resetButton) {				resetButton.x = width - 2 - resetButton.width;
				resetButton.y = 2;			}
		}

		override public function get height() : Number {			return bg.height;		}

		override public function set width( w : Number ) : void {			bg.width = w;			layout();		}

		override public function get width() : Number {			return bg.width;		}

		public function set title( value : String ) : void {			title_tf.text = value.toUpperCase();		}	}}