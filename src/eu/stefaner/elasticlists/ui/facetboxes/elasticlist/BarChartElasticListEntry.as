package eu.stefaner.elasticlists.ui.facetboxes.elasticlist {
	import flash.display.Sprite;

	/**
	 * @author mo
	 */
	public class BarChartElasticListEntry extends ElasticListEntry {

		private var globalBar : Sprite;
		private var localBar : Sprite;

		public function BarChartElasticListEntry() {
			super();
			showTotals = false;
		}

		override protected function initGraphics() : void {
			super.initGraphics();
			globalBar = new Sprite();
			globalBar.graphics.beginFill(0xEEEEEE);
			globalBar.graphics.drawRect(0, 0, -1, 2);
			addChild(globalBar);
			
			localBar = new Sprite();
			localBar.graphics.beginFill(0xDDDDDD);
			localBar.graphics.drawRect(0, 0, -1, 6);
			addChild(localBar);
			addChild(title_tf);
			height = 22;
		}

		override protected function layout() : void {
			super.layout();
			globalBar.x = localBar.x = width - 50;
			localBar.y = 6;
			globalBar.y = 13;
		}

		override public function expand() : void {
			localBar.width = facetValue.localRatio * 30;
			globalBar.width = facetValue.globalRatio * 30;
			localBar.visible = globalBar.visible = true;
			mouseEnabled = true;
			container.transitioner.$(this).height = 22;
			container.transitioner.$(this).alpha = 1;
		}

		override public function collapse() : void {
			mouseEnabled = false;
			container.transitioner.$(this).height = COLLAPSED_HEIGHT;
			container.transitioner.$(this).alpha = .4;
			localBar.visible = globalBar.visible = false;	
		}
	}
}
