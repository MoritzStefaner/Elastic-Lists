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
package eu.stefaner.elasticlists.ui.appcomponents {
	/**	 *	Class description.	 *	 *	@langversion ActionScript 3.0	 *	@playerversion Flash 9.0	 *	 *	@author moritz@stefaner.eu	 *	@since  23.11.2007	 */
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.ui.DefaultGraphicsFactory;

	import flash.display.Sprite;
	import flash.text.TextField;

	public class DetailView extends Sprite {
		public var bg : Sprite;
		public var title_tf : TextField;

		public function DetailView() {
			super();
			initGraphics();
		}

		private function initGraphics() : void {
			if(!title_tf) {
				title_tf = DefaultGraphicsFactory.getTitleTextField();
				addChild(title_tf);
			}
		}

		public function display(c : ContentItem):void {
			try {
				title_tf.text = c.title;
			} catch(error : Error) {
			}
		}
	}
}