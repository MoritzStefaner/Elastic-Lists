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

package eu.stefaner.elasticlists.ui.facetboxes.elasticlist {
	import eu.stefaner.elasticlists.data.FacetValue;
	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxElement;

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	public class ElasticListEntry extends FacetBoxElement {

		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		protected static var COLLAPSED_HEIGHT : int = 2;
		protected static var MIN_HEIGHT : int = 20;
		protected static var MAX_HEIGHT : int = 36;
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var num_tf : TextField;
		public static var showTotals : Boolean = true;
		public static var SHOW_DISTINCTIVENESS : Boolean = true;

		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function ElasticListEntry() {
			super();
		}

		override public function init(c : FacetBox, d : FacetValue) : void {
			//override public function init(c:FacetBox, d:Object):void {
			super.init(c, d);

			//bg.height = height = ElasticListEntry.MAX_HEIGHT;
			selectionMarker.y = 1;
		}

		override protected function initGraphics() : void {
			if(!bg) {
				bg = DefaultGraphicsFactory.getElasticListEntryBackground();
				addChild(bg);
			}
			super.initGraphics();
			if(!num_tf) {
				num_tf = DefaultGraphicsFactory.getTextField();
				num_tf.defaultTextFormat.align = TextFormatAlign.RIGHT;
				addChild(num_tf);
			}
			title_tf.autoSize = TextFieldAutoSize.NONE;
			title_tf.multiline = false;
			num_tf.textColor = 0xAAAAAA;
			bg.graphics.lineStyle(0, 0, .2);
			bg.graphics.lineTo(bg.width, 0);
		}

		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		protected function layout() : void {
			title_tf.x = 2;
			title_tf.y = 2;
			title_tf.height = title_tf.textHeight + 5;
			num_tf.y = 2;
			num_tf.visible = title_tf.visible = height > 15;
			num_tf.x = width - num_tf.width - 3 - 16;
			title_tf.width = num_tf.x - title_tf.x;
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

		//---------------------------------------
		// STATS
		//---------------------------------------
		override public function updateStats() : void {
			super.updateStats();
			if (ElasticListEntry.showTotals && facetValue.totalNumContentItems && facetValue.totalNumContentItems != facetValue.numContentItems) {
				num_tf.text = facetValue.numContentItems + "/" + facetValue.totalNumContentItems;
			} else {
				num_tf.text = String(facetValue.numContentItems);
			}
			
			//num_tf.text = Math.round(100 * facetValue.distinctiveness) + "/" + facetValue.numContentItems + "/" + facetValue.totalNumContentItems;
			if(SHOW_DISTINCTIVENESS && !selected && facetValue.totalNumContentItems != facetValue.numContentItems) {
				bg.alpha = Math.max(.3, facetValue.distinctiveness + .3);
			} else {
				bg.alpha = 1;
			}
			
			if (facetValue.numContentItems) {
				expand();
			} else {
				collapse();
			}
		}

		//---------------------------------------
		// DISPLAY STATE
		//---------------------------------------
		override public function collapse() : void {
			container.transitioner.$(this).height = COLLAPSED_HEIGHT;
			container.transitioner.$(this).alpha = .4;
			mouseEnabled = false;
		}

		override public function expand() : void {
			var s : Number = facetValue.numContentItems > 1 ? ratioToSize(facetValue.localRatio) : MIN_HEIGHT;
			container.transitioner.$(this).height = s;
			container.transitioner.$(this).alpha = 1;
			mouseEnabled = true;
		}

		protected function ratioToSize(a : Number) : Number {
			var result : Number;
			if (!a) {
				a = 0;
			}
			var logScale : Number = 5;

			result = Math.floor(MAX_HEIGHT * Math.log(1 + a * logScale) / Math.log(logScale + 1));
			result = Math.min(MAX_HEIGHT, Math.max(MIN_HEIGHT, result));
			return result;
		}
	}
}