package eu.stefaner.elasticlists.ui {
	import flash.text.TextFieldAutoSize;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * @author mo
	 */
	public class DefaultGraphicsFactory {

		public static function getTextField() : TextField {
			var t : TextField = new TextField();
			t.autoSize = TextFieldAutoSize.LEFT;
			t.multiline = false;
			var tf : TextFormat = new TextFormat("PF Ronda Seven", 8, 0x333333);
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
			s.graphics.drawRect(0, 0, 200, 100);
			s.filters = [new DropShadowFilter(2, 45, 0, .2)];
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
			var tf : TextFormat = new TextFormat("Arial", 11, 0x444444, true);
			t.defaultTextFormat = tf;
			return t;
		}

		public static function getPanelBackground() : Sprite {
			var s : Sprite = new Sprite();
			s.graphics.beginFill(0xF0F0F0, 1);
			s.graphics.drawRect(0, 0, 100, 100);
			return s;
		}
	}
}
