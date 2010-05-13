package eu.stefaner.elasticlists.ui.facetboxes.slider {
	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxElement;

	import flash.display.Sprite;

	/**
	 * @author mo
	 */
	public class SliderFacetBoxElement extends FacetBoxElement {

		private var localBar : Sprite;
		private var globalBar : Sprite;

		public function SliderFacetBoxElement() {
			super();
		}

		override protected function initGraphics() : void {
			if(bg == null) {
				bg = DefaultGraphicsFactory.getSliderFacetBoxElementBackground();
				addChild(bg);
			}

			if(selectionMarker == null) {
				selectionMarker = DefaultGraphicsFactory.getSelectionMarker();
				addChild(selectionMarker);
			}
			
			if(title_tf == null) {
				title_tf = DefaultGraphicsFactory.getTextField();
				addChild(title_tf);
			}
			
			if(globalBar == null) {
				globalBar = DefaultGraphicsFactory.getSliderFacetBoxElementGlobalBar();
				addChild(globalBar);
			}
			
			if(localBar == null) {
				localBar = DefaultGraphicsFactory.getSliderFacetBoxElementLocalBar();
				addChild(localBar);
			}
			bg.alpha = 0;
		}

		protected function layout() : void {
			title_tf.width = Math.min(width, title_tf.textWidth + 2);
			title_tf.x = width * .5 - title_tf.width * .5;
			title_tf.y = height - 16;
			localBar.width = width * .84;
			globalBar.width = width * .84;
			localBar.x = width * .5 - 1;
			globalBar.x = width * .5 + 1;
			localBar.y = height - 18;
			globalBar.y = height - 18;
		}

		override public function set height( h : Number ) : void {
			bg.height = h;
			selectionMarker.height = h;
			layout();
		}

		override public function get height() : Number {
			return bg.height;
		}

		override public function set width( w : Number ) : void {
			selectionMarker.width = bg.width = w;
			layout();
		}

		override public function get width() : Number {
			return bg.width;
		}

		override public function updateStats() : void {
			container.transitioner.$(localBar).height = facetValue.localRatio * (height - 18 - 5);
			container.transitioner.$(globalBar).height = facetValue.globalRatio * (height - 18 - 5);
		}
	}
}
