package eu.stefaner.elasticlists.demos.warlogs {
	import flash.events.Event;

	import eu.stefaner.elasticlists.ui.appcomponents.ContentArea;
	import eu.stefaner.elasticlists.App;
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;
	import eu.stefaner.elasticlists.ui.contentitem.ContentItemSprite;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxContainer;
	import eu.stefaner.elasticlists.ui.facetboxes.elasticlist.ElasticListBox;
	import eu.stefaner.elasticlists.ui.facetboxes.geo.GeoFacetBox;
	import eu.stefaner.elasticlists.ui.facetboxes.slider.SliderFacetBox;

	import com.bit101.components.HBox;
	import com.bit101.components.Style;
	import com.bit101.components.VBox;

	import org.osflash.thunderbolt.Logger;

	import flash.text.AntiAliasType;

	/**
	 * @author mo
	 */
	public class ElasticListsWarLogsApp extends App {

		public function ElasticListsWarLogsApp() {
			super();
			Logger.info("warlogs app inited");
				/*FDT_IGNORE*/
			Style.fontName = (new RegularFont()).fontName;
			Style.fontSize = 11;
			Style.antiAliasType = AntiAliasType.ADVANCED;
			DefaultGraphicsFactory.regularFontName = (new RegularFont()).fontName;
			DefaultGraphicsFactory.boldFontName = (new BoldFont()).fontName;
			/*FDT_IGNORE*/
			DefaultGraphicsFactory.highlightColor = 0xE7BDBD;
		}

		override protected function createDataConnector() : DataConnector {
			return new WarlogsDataConnector(model);
		}

		override public function createContentItemSprite(contentItem : ContentItem) : ContentItemSprite {
			var c : ContentItemSprite = super.createContentItemSprite(contentItem);
			c.defaultWidth = 450;
			c.defaultHeight = 24;
			c.title_tf.multiline = true;
			return c;
		}

		override protected function initDisplay() : void {
			margin = 10;
			
			vBox = new VBox(this, 10, 40);
			vBox.spacing = margin;
			
			//titleTextField.alpha = 0;
			hBox = new HBox(vBox, 0, 0);
			hBox.spacing = margin;
			
			var f : FacetBoxContainer;
			var facetBox : FacetBox;
			var facet : Facet;
			
			f = new FacetBoxContainer(this);
			facet = model.facet("type");
			facetBox = new ElasticListBox();
			f.init(facet, facetBox);
			hBox.addChild(f);
			f.width = 160;
			f.height = 200;
			
			f = new FacetBoxContainer(this);
			facet = model.facet("category");
			facetBox = new ElasticListBox();
			f.init(facet, facetBox);
			hBox.addChild(f);
			f.width = 160;
			f.height = 200;
			
			f = new FacetBoxContainer(this);
			facet = model.facet("attackon");
			facetBox = new ElasticListBox();
			f.init(facet, facetBox);
			hBox.addChild(f);
			f.width = 160;
			f.height = 200;
			
			f = new FacetBoxContainer(this);
			facet = model.facet("geolocation");
			facetBox = new GeoFacetBox();
			f.init(facet, facetBox);
			f.width = 480 + margin * 2;
			f.height = 300 + margin;
			vBox.addChild(f);
			facetBox.maxItems = 10000;
			
			f = new FacetBoxContainer(this);
			facet = model.facet("date");
			facetBox = new SliderFacetBox();
			f.init(facet, facetBox);
			f.width = 480 + margin * 2;
			f.height = 100;			
			vBox.addChild(f);
			
			contentArea = new ContentArea();
			contentArea.layoutMode = ContentArea.LIST_LAYOUT;
			contentArea.init(this);
			contentArea.x = 530;
			contentArea.y = 20;
			contentArea.width = stage.stageWidth - contentArea.x - 10;
			contentArea.height = stage.stageHeight - contentArea.y - 10;
			
			addChild(contentArea);
		}

		override protected function onResize(e : Event) : void {
			super.onResize(e);
			contentArea.width = stage.stageWidth - contentArea.x - 10;
			contentArea.height = stage.stageHeight - contentArea.y - 10;
		}
	}
}
