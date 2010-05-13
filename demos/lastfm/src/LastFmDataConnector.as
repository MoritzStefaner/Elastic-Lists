package {
	import eu.stefaner.elasticlists.data.ContentItem;
	import eu.stefaner.elasticlists.data.DataConnector;
	import eu.stefaner.elasticlists.data.Facet;
	import eu.stefaner.elasticlists.data.Model;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * @author mo
	 */
	public class LastFmDataConnector extends DataConnector {

		public function LastFmDataConnector(m : Model) {
			super(m);
		}

		override public function loadData(query : Dictionary = null) : void {
			startRequest("data/lastfm-bestof2009.xml");
		}

		override protected function onDataLoaded(e : Event) : void {
			Logger.info("data loaded");
			var f : Facet ; 
			
			f = model.registerFacet(new Facet("position"));
			f.sortFields = ["label"];
			f.sortOptions = Array.NUMERIC;
			
			f = model.registerFacet(new Facet("location"));
			
			model.registerFacet(new Facet("tag"));
			model.registerFacet(new Facet("listeners"));
		
			var xml : XML = new XML(e.target.data);
			for each (var artistXML:XML in xml..artist) {
				parseContentItemFromXML(artistXML);
			}
			dispatchEvent(new Event(DATA_LOADED));
		}

		override protected function parseContentItemFromXML(xml : XML) : ContentItem {
			var id : String;
			id = String(idCounter++);
			
			var contentItem : ContentItem = model.createContentItem(id);
			contentItem.title = xml.name.toString();
			
			var key : String, value : String;
			
			key = "position";
			value = xml.position.toString();
			model.assignFacetValueToContentItemByName(contentItem.id, key, String(Math.floor(int(value) / 100) * 100));
			contentItem.addRawValue(key, value);
			
			key = "location";
			value = xml.location.toString();
			model.assignFacetValueToContentItemByName(contentItem.id, key, value);
			contentItem.addRawValue(key, value);
			
			key = "tag";
			for each (var tagXML:XML in xml.tags.tag) {
				value = tagXML.name.toString();
				model.assignFacetValueToContentItemByName(contentItem.id, key, value);
				contentItem.addRawValue(key, value);
			}
			
			contentItem.addRawValue("thumbURL", xml.images.large.toString());
			
			return contentItem;
		}

		/*
		<artist>
		<position>1</position>
		<name>Lady GaGa</name>
		<location>New York, United States</location>
		<iso>US</iso>
		<url>http://www.last.fm/music/Lady+GaGa</url>
		<blurb><![CDATA[Given that <a title="Lady GaGa at last.fm" href="http://www.last.fmmusic/Lady+GaGa">Lady GaGa</a>'s style and sounds have dominated the year in pop it may only surprise a few of you that she's stormed to the top of our listener chart. Released in the UK in January (although other territories had it earlier) <a title="The Fame at Last.fm" href="http://www.last.fmmusic/Lady+GaGa/The+Fame"><i>The Fame</i></a> has proved to be the most impressive, assured, catchy and triumphant debut album of the year, and possibly for a lot longer than that too. A fully-formed star from the off, Lady GaGa brought electro, hip-hop, pop, dance and a little dash of rock to the party, a lively cocktail that proved tough to shake on radio stations, TV shows, soundtracks... pretty much anywhere with a speaker actually.
		If <i>The Fame</i> is the album of the year then surely <a title="'Poker Face' at Last.fm" href="http://www.last.fmmusic/Lady+GaGa/_/Poker+Face">'Poker Face'</a> is the defining track. While GaGa initially claimed the track was clearly about sex and gambling, the New York native <a title="NBC" href="http://www.nbcbayarea.com/entertainment/celebrity/Lady_GaGa_Entertains_Thousands_At_Palm_Springs_White_Party.html">later revealed</a> during a 2am set in Palm Springs that the track related to her experiences as a bisexual. It remains at the top of her <a title="Lady GaGa charts at last.fm" href="http://www.last.fmmusic/Lady+GaGa/+charts">artist scrobbles</a> week-in, week-out, often generating as many as double the plays of singles <a title="'LoveGame' at last.fm" href="http://www.last.fmmusic/Lady+GaGa/_/LoveGame">'LoveGame'</a> and <a title="'Paparazzi' at last.fm" href="http://www.last.fmmusic/Lady+GaGa/_/Paparazzi">'Paparazzi'</a>, and it has been such a success that <a title="Christopher Walken" href="http://www.youtube.com/watch?v=xy5JwYOlgvY">Christopher Walken</a> and  <a title="Cartman Poker Face" href="http://www.youtube.com/watch?v=SSEST-oQH68">Eric Cartman</a> have both been moved to cover it.
		Lady GaGa will be touring <a title="Lady GaGa events at last.fm" href="http://www.last.fmmusic/Lady+GaGa/+events">The Monster Ball</a> in support of new album<i> <a title="The Fame Monster at Last.fm" href="http://www.last.fmmusic/Lady+GaGa/The+Fame+Monster">The Fame Monster</a></i>; maybe you'll see her here next year?]]></blurb>
		<images>
		<small>http://userserve-ak.last.fm/serve/34/27576621.png</small>
		<medium>http://userserve-ak.last.fm/serve/64/27576621.png</medium>
		<large>http://userserve-ak.last.fm/serve/126/27576621.png</large>
		</images>
		<stats>
		<overall>
		<plays>35562384</plays>
		<listeners>955164</listeners>
		</overall>
		<year>
		<listeners>755309</listeners>
		<gigs>253</gigs>
		<festivals>54</festivals>
		<users_attended>15709</users_attended>
		</year>
		</stats>
		<tags>
		<tag>
		<name>pop</name>
		<url>http://www.last.fm/tag/pop</url>
		</tag>
		<tag>
		<name>dance</name>
		<url>http://www.last.fm/tag/dance</url>
		</tag>
		<tag>
		<name>electronic</name>
		<url>http://www.last.fm/tag/electronic</url>
		</tag>
		</tags>
		<album>
		<name>The Fame</name>
		<url>http://www.last.fm/music/Lady+GaGa/The+Fame</url>
		<images>
		<small>http://userserve-ak.last.fm/serve/34s/24408387.png</small>
		<medium>http://userserve-ak.last.fm/serve/64s/24408387.png</medium>
		<large>http://userserve-ak.last.fm/serve/126/24408387.png</large>
		</images>
		<stats>
		<overall>
		<plays>17626729</plays>
		<listeners>359732</listeners>
		</overall>
		<year>
		<plays>18487195</plays>
		</year>
		</stats>
		<tags>
		<tag>
		<name>pop</name>
		<url>http://www.last.fm/tag/pop</url>
		</tag>
		<tag>
		<name>albums i own</name>
		<url>http://www.last.fm/tag/albums%20i%20own</url>
		</tag>
		<tag>
		<name>dance</name>
		<url>http://www.last.fm/tag/dance</url>
		</tag>
		</tags>
		</album>
		</artist>

		 * 
		 */
		private function parseContentItemString(entry : String) : void {
			var keyValueStrings : Array = entry.split("\n");
			var c : ContentItem = model.createContentItem(String(idCounter++));
			for each (var keyValueString:String in keyValueStrings) {
				var a : Array = keyValueString.split(": ");
				var key : String = a[0];
				var value : String = a[1];
				var facet : Facet;
				
				if(model.facet(key)) {
					facet = model.facet(key); 
					// field belongs to a facet
					// wll create facet value if needed
					model.assignFacetValueToContentItemByName(c.id, facet.name, value);
				} 
				c.addRawValue(key, value);
				if(key == "name") c.title = value;
				if(key == "year") model.assignFacetValueToContentItemByName(c.id, "decade", String(Math.floor(Number(value) / 10) * 10));
			}
		}
	}
}
