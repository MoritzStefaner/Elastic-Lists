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

package {
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;

	import eu.stefaner.elasticlists.data.AssetLoader;
	import eu.stefaner.elasticlists.ui.contentitem.ContentItemSprite;

	import flare.animate.Transitioner;

	import org.osflash.thunderbolt.Logger;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;

	/**
	 * @author mo
	 */
	public class NobelPrizeWinner extends ContentItemSprite {

		private var imageHolder : Sprite;
		private var picLoader : LoadingItem;
		private var titleBg : Sprite;

		public function NobelPrizeWinner(o : Object) {
			super(o);
			defaultWidth = 162;
			defaultHeight = 227;
		}

		override protected function initGraphics() : void {
			super.initGraphics();
			imageHolder = new Sprite();
			addChild(imageHolder);
			titleBg = new Sprite();
			titleBg.graphics.beginFill(0xFFFFFF, .9);
			titleBg.graphics.drawRect(0, 0, 162, 16);
			addChild(titleBg);		
			addChild(title_tf);
			try {
				picLoader = AssetLoader.loadImage(data.rawValues.photo);
				picLoader.addEventListener(BulkLoader.COMPLETE, onPicLoaded);
				picLoader.addEventListener(BulkLoader.ERROR, onPicLoadError);
				picLoader.maxTries = 1;
				//Logger.info("loading image", o.rawValues.photo);
			} catch (e : Error) {
				Logger.warn("bad img URL", data.rawValues.photo);
			}
		}

		private function onPicLoadError(event : ErrorEvent) : void {
			Logger.warn("error loading image", event);
		}

		private function onPicLoaded(event : Event) : void {
			imageHolder.addChild(picLoader.content as Bitmap);
			updateImageSize();
		}

		override public function set height(h : Number) : void {
			super.height = h;
			titleBg.height = Math.min(20, h);
			titleBg.visible = title_tf.visible;
			updateImageSize();
		}

		override public function set width(w : Number) : void {
			super.width = w;
			titleBg.width = w;
			titleBg.visible = title_tf.visible;
			updateImageSize();	
		}

		override public function show(t : Transitioner = null) : void {
			super.show(t);
			// TODO: too inefficient, need to look into this
			//if(picLoader) AssetLoader.makeImportant(picLoader);
		}

		override public function hide(t : Transitioner = null) : void {
			super.hide(t);
			// TODO: too inefficient, need to look into this
			//	if(picLoader) AssetLoader.makeUnimportant(picLoader);
		}

		private function updateImageSize() : void {
			imageHolder.scaleX = imageHolder.scaleY = Math.min(width / defaultWidth, height / defaultHeight);
		}
	}
}
