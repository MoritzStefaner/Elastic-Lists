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

package eu.stefaner.elasticlists.ui.facetboxes {		import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.data.FacetValue;	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;	import flare.animate.Transitioner;	import flash.display.Sprite;	import flash.events.Event;	import flash.utils.Dictionary;	/**	FacetBox class	 */	public class FacetBox extends Sprite {		protected static const TRANSITION_DURATION : Number = 1;
		//---------------------------------------		// PUBLIC VARIABLES		//---------------------------------------		public var bg : Sprite;				public var contentsSprite : Sprite;		public var facetBoxElements : Array = [];		public var facetBoxElementForDataObject : Dictionary = new Dictionary();		// animation transitioner		public var transitioner : Transitioner = Transitioner.instance(null);		// allow only single item selections?		public var singleSelect : Boolean = false;		// max displayed items (per filter context)		public var maxItems : uint = 100;		private var firstRun : Boolean = true;		public var _mask : Sprite;
		private var _facet : Facet;

		//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function FacetBox() {			initGraphics();			layout();		}		// on_selectionChange		public static var SELECTION_CHANGE : String = "SELECTION_CHANGE";		override public function toString() : String {			return "[FacetBox]";		}		public function init() : void {		}		//---------------------------------------		// EVENT HANDLERS		//---------------------------------------		protected function initGraphics() : void {			if(bg == null) {				bg = DefaultGraphicsFactory.getFacetBoxBackground();				addChild(bg);			}						if(contentsSprite == null) {				contentsSprite = new Sprite();				addChild(contentsSprite);			}						if(_mask == null) {				_mask = new Sprite();				_mask.graphics.beginFill(0);				_mask.graphics.drawRect(0, 0, 1, 1);								addChild(_mask);			}						contentsSprite.mask = _mask;		}		public function updateStats() : void {			trace(this + ".updateStats");			// REVISIT: in principle, this could be ONE transitioner for all facetBoxes			if(firstRun) {				renewTransitioner(true);				firstRun = false;			} else {				renewTransitioner();			}						var f : FacetBoxElement;						var max : int = maxItems;			for each (var facetValue:FacetValue in facet.facetValues) {				if(--max > 0) {					f = facetBoxElementForDataObject[facetValue] || createFacetBoxElement(facetValue);					f.updateStats();				} else {					break;				}			}						layout();			doPositioning();			transitioner.play();		}		public function reset() : void {			trace(this + ".reset");			for each (var f:FacetValue in facet.facetValues) {				f.selected = false;			}			dispatchEvent(new Event(FacetBox.SELECTION_CHANGE));		}		protected function createFacetBoxElement(facetValue : FacetValue) : FacetBoxElement {			var sprite : FacetBoxElement;						sprite = getNewFacetBoxElement();			sprite.init(this, facetValue);						contentsSprite.addChildAt(sprite, 0);			facetBoxElements.push(sprite);			facetBoxElementForDataObject[facetValue] = sprite;						return sprite;		}		protected function getNewFacetBoxElement() : FacetBoxElement {			// TODO: throw exception			// implement in subclass!			trace("!!! getNewFacetBoxElement must be implemented in subclass!");			return null;		}		public function onFacetBoxElementClick(target : FacetBoxElement) : void {			trace(this + ".onFacetBoxElementClick " + target);			if(singleSelect) {				for each (var facetValue:FacetValue in facet.facetValues) {					if(facetValue != target.facetValue) {						facetValue.selected = false;					}				}			}			target.facetValue.toggleSelected();			dispatchEvent(new Event(FacetBox.SELECTION_CHANGE));		}		//---------------------------------------		// GETTER / SETTERS		//---------------------------------------		override public function set height( h : Number ) : void {			bg.height = h;			layout();		}		override public function get height() : Number {			return bg.height;		}		override public function set width( w : Number ) : void {			bg.width = w;			layout();		}		override public function get width() : Number {			return bg.width;		}		protected function layout() : void {			_mask.width = width;			_mask.height = height;		}		protected function renewTransitioner(immediate : Boolean = false) : void {			if(transitioner && transitioner.running) {				transitioner.stop();			}			transitioner = createTransitioner();			transitioner.immediate = immediate;		}		protected function createTransitioner() : Transitioner {			return new Transitioner(TRANSITION_DURATION, null, true);		}		protected function onTransitionStep(event : Event) : void {
		}
		protected function onTransitionEnd(event : Event) : void {		}		//---------------------------------------		// DISPLAY STATE		//---------------------------------------		// renders a plain vertical list per default		// override in subclass as needed		protected function doPositioning() : void {			var yPos : Number = 1;			var max : int = maxItems;			var f : FacetBoxElement;			for each (var facetValue:FacetValue in facet.facetValues) {				if(--max > 0) {					f = facetBoxElementForDataObject[facetValue];					transitioner.$(f).y = Math.floor(yPos);					yPos += Math.floor(transitioner.$(f).height);					f.visible = true;					f.parent.addChildAt(f, 0);				} else if(facetBoxElementForDataObject[facetValue]) {
					f = facetBoxElementForDataObject[facetValue];					f.y = 0;					f.height = 0;					f.visible = false;				}			}			transitioner.$(contentsSprite).y = 0;		}
		
		public function get facet() : Facet {
			return _facet;
		}
		
		public function set facet(facet : Facet) : void {
			_facet = facet;
		}	}}