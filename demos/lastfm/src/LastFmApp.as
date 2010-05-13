package {
	import eu.stefaner.elasticlists.App;
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.ui.contentitem.ContentItemSprite;

	/**
	 * @author mo
	 */
	[SWF(backgroundColor="#DDDDDD", frameRate="31", width="1024", height="768")]

	public class LastFmApp extends App {

		public function LastFmApp() {
			super();
		}

		override protected function createDataConnector() : DataConnector {
			return new LastFmDataConnector(model);
		}

		override public function createContentItemSprite(contentItem : ContentItem) : ContentItemSprite {
			return new LastFmArtistSprite(contentItem);
		}
	}
}
