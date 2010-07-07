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

package eu.stefaner.elasticlists.ui.facetboxes.elasticlist {	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxElement;

	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;

	import com.bit101.components.VScrollBar;

	import flash.events.Event;
	import flash.geom.Rectangle;

	public class ElasticListBox extends FacetBox {
		public var scrollBar : VScrollBar;
		public function ElasticListBox() {			super();		}		override protected function initGraphics() : void {			super.initGraphics();						scrollBar = new VScrollBar(this, 0, 0, onScrollBarMoved);			addChild(scrollBar);		}		public function onScrollBarMoved(e : Event) : void {			contentsSprite.y = -scrollBar.value;
		}
		//---------------------------------------		// GETTER / SETTERS		//---------------------------------------		override protected function layout() : void {			super.layout();						scrollBar.x = width - scrollBar.width;			scrollBar.height = height;						for each (var sprite:FacetBoxElement in facetBoxElements) {				sprite.width = width;			}		}		override protected function getNewFacetBoxElement() : FacetBoxElement {			return new ElasticListEntry();		};		override protected function createTransitioner() : Transitioner {
			var t : Transitioner = super.createTransitioner();			t.addEventListener(TransitionEvent.STEP, onTransitionStep, false, 0, true);			return t;
		}
		override protected function onTransitionStep(event : Event) : void {			updateScrollBar();		}		private function updateScrollBar() : void {						var b : Rectangle = contentsSprite.getBounds(this);			if(b.height > height) {				scrollBar.setSliderParams(0, b.height - height, -contentsSprite.y);				scrollBar.visible = true;				scrollBar.setThumbPercent(height / b.height);			} else {				scrollBar.visible = false;			}
		}
	}}