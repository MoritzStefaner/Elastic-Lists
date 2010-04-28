package eu.stefaner.elasticlists.ui {
	import flash.text.AntiAliasType;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author mo
	 */
	public class DefaultGraphicsFactory {

		[Embed(source="/assets/PTS55F.ttf", fontName="regularFont", advancedAntiAliasing="true", mimeType="application/x-font-truetype")]

		private var regularFont : Class;
		
		[Embed(source="/assets/Aller_Bd.ttf", fontName="boldFont",  fontWeight='bold',  advancedAntiAliasing="true", mimeType="application/x-font-truetype")]

		private var boldFont : Class;

		public static function getTextField() : TextField {
			var t : TextField = new TextField();
			t.autoSize = TextFieldAutoSize.LEFT;
			t.multiline = false;
			t.embedFonts = true;
			t.antiAliasType = AntiAliasType.ADVANCED;
			var tf : TextFormat = new TextFormat("regularFont", 10, 0x333333);
			t.defaultTextFormat = tf;
		
			return t;
		}

		public static function getFacetBoxContainerBackground() : Sprite {
			var s : Sprite = getPanelBackground();
			s.filters = [new DropShadowFilter(2, 45, 0, .2)];
			return s;
		}

		public static function getFacetBoxBackground() : Sprite {
			return getPanelBackground();
		}

		public static function getContentItemBackground() : Sprite {
			var s : Sprite = new Sprite();
			s.graphics.beginFill(0xFFFFFF);
			s.graphics.lineStyle(0, 0xCCCCCC, 1);
			s.graphics.drawRect(0, 0, 200, 100);
			//s.filters = [new DropShadowFilter(2, 45, 0, .2)];
			return s;
		}

		public static function getSelectionMarker() : Sprite {
			var s : Sprite = new Sprite();
			s.graphics.beginFill(0xDDFF99);
			s.graphics.drawRect(0, 0, 100, 100);
			return s;
		}

		public static function getTitleTextField() : TextField {
			var t : TextField = new TextField();
			t.autoSize = TextFieldAutoSize.LEFT;
			t.multiline = false;
			t.embedFonts = true;
			t.antiAliasType = AntiAliasType.ADVANCED;
			var tf : TextFormat = new TextFormat("boldFont", 12, 0x333333, true);
			t.defaultTextFormat = tf;
			return t;
		}

		public static function getPanelBackground() : Sprite {
			var s : Sprite = new Sprite();
			s.graphics.beginFill(0xFFFFFF, 1);
			s.graphics.drawRect(0, 0, 100, 100);
			return s;
		}

		public static function getContentAreaBackground() : Sprite {
			var s : Sprite = new Sprite();
			s.graphics.beginFill(0xF0F0F0, 0);
			s.graphics.drawRect(0, 0, 100, 100);
			return s;
		}

		public static function getElasticListEntryBackground() : Sprite {
			var s : Sprite = new Sprite();
			s.graphics.beginFill(0xFFFFFF);
			//s.graphics.lineStyle(0, 0xCCCCCC, 1);
			s.graphics.drawRect(0, 0, 200, 100);
			s.filters = [new DropShadowFilter(2, 45, 0, .2)];
			return s;
		}
	}
}
