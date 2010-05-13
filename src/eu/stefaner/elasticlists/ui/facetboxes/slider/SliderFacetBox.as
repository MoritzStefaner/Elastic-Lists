package eu.stefaner.elasticlists.ui.facetboxes.slider {
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxElement;

	import com.bit101.components.HRangeSlider;
	import com.bit101.components.RangeSlider;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;

	/**
	 * @author mo
	 */
	public class SliderFacetBox extends FacetBox {

		private var slider : HRangeSlider;

		public function SliderFacetBox() {
			super();
		}

		override protected function initGraphics() : void {
			super.initGraphics();
			slider = new HRangeSlider(this, 0, 0);
			slider.addEventListener(RangeSlider.DRAG_END, onSliderChange);
			slider.labelMode = RangeSlider.NEVER;
			slider.tick = .01;
			slider.minimum = 0;
			slider.maximum = width;
		}

		private function onSliderChange(e : Event) : void {
			Logger.info("slider change", slider.lowValue, slider.highValue);
			updateFilterFromSliderPosition();
			dispatchEvent(new Event(FacetBox.SELECTION_CHANGE));
		}

		private function updateFilterFromSliderPosition() : void {
			if(slider.lowValue < facetBoxElements[1].x && slider.highValue > facetBoxElements[facetBoxElements.length - 1].x) {
				for each (var sprite:FacetBoxElement in facetBoxElements) {
					sprite.facetValue.selected = false;	
				}	
			} else {
				for each (var sprite:FacetBoxElement in facetBoxElements) {
					if(sprite.x < slider.lowValue || sprite.x >= slider.highValue) {
						sprite.facetValue.selected = false;
					} else {
						sprite.facetValue.selected = true;
					}
				}
			}
		}

		private function updateSliderPositionFromFilter() : void {
			var lowEndTargetPos : Number = -1;
			var highEndTargetPos : Number = -1;
			for each (var sprite:FacetBoxElement in facetBoxElements) {
				if(sprite.facetValue.selected && lowEndTargetPos == -1) {
					lowEndTargetPos = transitioner.$(sprite).x;
				}
				
				if(lowEndTargetPos != -1 && highEndTargetPos == -1 && !sprite.facetValue.selected) {
					highEndTargetPos = transitioner.$(sprite).x; 
				}
			}	
			transitioner.$(slider).lowValue = lowEndTargetPos != -1 ? lowEndTargetPos : 0;
			transitioner.$(slider).highValue = highEndTargetPos != -1 ? highEndTargetPos : slider.maximum;
		}

		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		override protected function layout() : void {
			super.layout();
			slider.width = width;
			slider.y = height - slider.height;
			slider.maximum = width;
		}

		override protected function getNewFacetBoxElement() : FacetBoxElement {
			return new SliderFacetBoxElement();
		};

		override protected function doPositioning() : void {
			var xx : Number = 0;
			for each (var sprite:FacetBoxElement in facetBoxElements) {
				sprite.height = height - slider.height;
				sprite.width = width / facetBoxElements.length;
				transitioner.$(sprite).x = xx;
				xx += sprite.width;
			}
			updateSliderPositionFromFilter();
		}

		override public function set facet(facet : Facet) : void {
			super.facet = facet;
			facet.filter.conjunctive = false;
		}
	}
}
