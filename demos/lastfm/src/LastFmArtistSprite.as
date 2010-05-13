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
	public class LastFmArtistSprite extends ContentItemSprite {

		private var imageHolder : Sprite;
		private var picLoader : LoadingItem;
		private var titleBg : Sprite;
		private var imageMask : Sprite;

		public function LastFmArtistSprite(o : Object) {
			
			super(o);
		}

		override protected function initGraphics() : void {
			defaultWidth = 140;
			defaultHeight = 110;
			super.initGraphics();
			imageHolder = new Sprite();
			addChild(imageHolder);
			imageMask = new Sprite();
			imageMask.graphics.beginFill(0);
			imageMask.graphics.drawRect(0, 0, defaultWidth, defaultHeight);
			addChild(imageMask);
			imageHolder.mask = imageMask;
			
			titleBg = new Sprite();
			titleBg.graphics.beginFill(0xFFFFFF, .9);
			titleBg.graphics.drawRect(1, 0, defaultWidth - 2, 16);
			addChild(titleBg);		
			addChild(title_tf);
			
			try {
				picLoader = AssetLoader.loadImage(data.rawValues.thumbURL);
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
			titleBg.height = Math.min(16, h);
			titleBg.visible = title_tf.visible;
			updateImageSize();
		}

		override public function set width(w : Number) : void {
			super.width = w;
			titleBg.width = w - 2;
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
			imageMask.width = width;
			imageMask.height = height;
			imageHolder.x = width * .5 - imageHolder.width * .5;
			imageHolder.y = height * .5 - imageHolder.height * .5;
			//imageHolder.scaleX = imageHolder.scaleY = Math.min(width / defaultWidth, height / defaultHeight);
		}
	}
}
