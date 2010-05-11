package eu.stefaner.elasticlists.ui.facetboxes.slider {
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
			slider.minimum = 0;
			slider.tick = 1;
		}

		private function onSliderChange(e : Event) : void {
			Logger.info("slider change", slider.lowValue, slider.highValue);
			slider.lowValue = Math.round(slider.lowValue);
			slider.highValue = Math.round(slider.highValue);
			Logger.info("slider change", slider.lowValue, slider.highValue);
		}

		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		override protected function layout() : void {
			super.layout();
			slider.width = width;
			slider.y = height - slider.height;
			slider.maximum = facetBoxElements.length;
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
		}
	}
}
