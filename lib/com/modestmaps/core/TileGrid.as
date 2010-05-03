package com.modestmaps.core 
{
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.mapproviders.IMapProvider;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class TileGrid extends Sprite
	{
		// OPTIONS
		///////////////////////////////
		
		// TODO: split these out into a TileGridOptions class and allow mass setting/getting?
		
		protected static const DEFAULT_MAX_PARENT_SEARCH:int = 5;
		protected static const DEFAULT_MAX_PARENT_LOAD:int = 0; // enable this to load lower zoom tiles first
		protected static const DEFAULT_MAX_CHILD_SEARCH:int = 1;
		protected static const DEFAULT_MAX_TILES_TO_KEEP:int = 256; // 256*256*4bytes = 0.25MB ... so 256 tiles is 64MB of memory, minimum!
		protected static const DEFAULT_TILE_BUFFER:int = 0;
		protected static const DEFAULT_ENFORCE_BOUNDS:Boolean = true;
		protected static const DEFAULT_MAX_OPEN_REQUESTS:int = 4; // TODO: should this be split into max-new-requests-per-frame, too?
		protected static const DEFAULT_ROUND_POSITIONS:Boolean = true;
		protected static const DEFAULT_ROUND_SCALES:Boolean = true;
		protected static const DEFAULT_CACHE_LOADERS:Boolean = false;  // !!! only enable this if you have crossdomain permissions to access Loader content
		protected static const DEFAULT_SMOOTH_CONTENT:Boolean = false; // !!! only enable this if you have crossdomain permissions to access Loader content
		protected static const DEFAULT_MAX_LOADER_CACHE_SIZE:int = 0; // !!! suggest 256 or so

		/** if we don't have a tile at currentZoom, onRender will look for tiles up to 5 levels out.
		 *  set this to 0 if you only want the current zoom level's tiles
		 *  WARNING: tiles will get scaled up A LOT for this, but maybe it beats blank tiles? */ 
		public var maxParentSearch:int = DEFAULT_MAX_PARENT_SEARCH;
		/** if we don't have a tile at currentZoom, onRender will look for tiles up to one levels further in.
		 *  set this to 0 if you only want the current zoom level's tiles
 		 *  WARNING: bad, bad nasty recursion possibilities really soon if you go much above 1
		 *  - it works, but you probably don't want to change this number :) */
		public var maxChildSearch:int = DEFAULT_MAX_CHILD_SEARCH;

		/** if maxParentSearch is enabled, setting maxParentLoad to between 1 and maxParentSearch
		 *   will make requests for lower zoom levels first */
		public var maxParentLoad:int = DEFAULT_MAX_PARENT_LOAD;

		/** this is the maximum size of tileCache (visible tiles will also be kept in the cache) */		
		public var maxTilesToKeep:int = DEFAULT_MAX_TILES_TO_KEEP;
		
		// 0 or 1, really: 2 will load *lots* of extra tiles
		public var tileBuffer:int = DEFAULT_TILE_BUFFER;
		
		// how many Loaders are allowed to be open at once?
		public var maxOpenRequests:int = DEFAULT_MAX_OPEN_REQUESTS;

		/** set this to true to enable enforcing of map bounds from the map provider's limits */
		public var enforceBoundsEnabled:Boolean = DEFAULT_ENFORCE_BOUNDS;
		
		/** set this to false, along with roundScalesEnabled, if you need a map to stay 'fixed' in place as it changes size */
		public var roundPositionsEnabled:Boolean = DEFAULT_ROUND_POSITIONS;
		
		/** set this to false, along with roundPositionsEnabled, if you need a map to stay 'fixed' in place as it changes size */
		public var roundScalesEnabled:Boolean = DEFAULT_ROUND_SCALES;

		/** set this to true to enable bitmap smoothing on tiles - requires crossdomain.xml permissions so won't work online with most providers */
		public var smoothContent:Boolean = DEFAULT_SMOOTH_CONTENT;
		
		/** with tile providers that you have crossdomain.xml support for, 
		 *  it's possible to avoid extra requests by reusing bitmapdata. enable cacheLoaders to try and do that */
		public static var cacheLoaders:Boolean = DEFAULT_CACHE_LOADERS;
		public static var maxLoaderCacheSize:int = DEFAULT_MAX_LOADER_CACHE_SIZE;
		protected static var loaderCache:Object = {};
		protected static var cachedUrls:Array = [];
		
		///////////////////////////////
		// END OPTIONS

        // TILE_WIDTH and TILE_HEIGHT are now tileWidth and tileHeight
        // this was needed for the NASA DailyPlanetProvider which has 512x512px tiles
		// public static const TILE_WIDTH:Number = 256;
		// public static const TILE_HEIGHT:Number = 256;        
        
        // read-only, kept up to date by calculateBounds()
        protected var _minZoom:Number;
        protected var _maxZoom:Number;

		protected var minTx:Number, maxTx:Number, minTy:Number, maxTy:Number;

		// read-only, convenience for tileWidth/Height
		protected var _tileWidth:Number;
		protected var _tileHeight:Number;

		// pan and zoom etc are stored in here
		// NB: this matrix is never applied to a DisplayObject's transform
		//     because it would require scaling tile positions to compensate.
		//     Instead, we adapt its values such that the current zoom level
		//     is approximately scale 1, and positions make sense in screen pixels
		protected var worldMatrix:Matrix;
		
		// this turns screen points into coordinates
		protected var _invertedMatrix:Matrix; // use lazy getter for this
		
		// the corners and center of the screen, in map coordinates
		// (these also have lazy getters)
		protected var _topLeftCoordinate:Coordinate;
		protected var _bottomRightCoordinate:Coordinate;
		protected var _centerCoordinate:Coordinate;

		// where the tiles live:
		protected var well:Sprite;

		protected var provider:IMapProvider;

		protected var tileQueue:TileQueue;

		protected var tileCache:TileCache;

		protected var tilePool:TilePool;
		
		// per-tile, the array of images we're going to load, which can be empty
		// TODO: document this in IMapProvider, so that provider implementers know
		// they are free to check the bounds of their overlays and don't have to serve
		// millions of 404s
		protected var layersNeeded:Object = {};

		// keys we've recently seen
		protected var recentlySeen:Array = [];
		
		// open requests
		protected var openRequests:Array = [];

		// keeping track for dispatching MapEvent.ALL_TILES_LOADED and MapEvent.BEGIN_TILE_LOADING
		protected var previousOpenRequests:int = 0;
		
		// currently visible tiles
		protected var visibleTiles:Array = [];
				
		// number of tiles we're failing to show
		protected var blankCount:int = 0;

		// a textfield with lots of stats
		public var debugField:TextField;
		
		// for stats:
		protected var lastFrameTime:Number;
		protected var fps:Number = 30;

		// what zoom level of tiles is 'correct'?
		protected var _currentTileZoom:int; 
		// so we know if we're going in or out
		protected var previousTileZoom:int;		
		
		// for sorting the queue:
		protected var centerRow:Number;
		protected var centerColumn:Number;

		// for pan events
		protected var startPan:Coordinate;
		public var panning:Boolean;
		
		// previous mouse position when dragging 
		protected var pmouse:Point;
		
		// for zoom events
		protected var startZoom:Number = -1;
		public var zooming:Boolean;
		
		protected var mapWidth:Number;
		protected var mapHeight:Number;
		
		protected var draggable:Boolean;

		// setting this.dirty = true will request an Event.RENDER
		protected var _dirty:Boolean;

		// setting to true will dispatch a CHANGE event which Map will convert to an EXTENT_CHANGED for us
		protected var matrixChanged:Boolean = false;
		
		protected var queueTimer:Timer;
		
		public function TileGrid(w:Number, h:Number, draggable:Boolean, provider:IMapProvider)
		{
			doubleClickEnabled = true;
			
			//this.map = map;
			this.draggable = draggable;

			// don't call set map provider here, because it triggers a redraw and we're not ready for that
			this.provider = provider;
			
			// but do grab tile dimensions:
			_tileWidth = provider.tileWidth;
			_tileHeight = provider.tileHeight;

			// and calculate bounds from provider
			calculateBounds();
			
			this.tilePool = new TilePool(Tile);
			this.tileQueue = new TileQueue();
			this.tileCache = new TileCache(tilePool);

			this.mapWidth = w;
			this.mapHeight = h;

			debugField = new TextField();
			debugField.defaultTextFormat = new TextFormat(null, 12, 0x000000, false);
			debugField.backgroundColor = 0xffffff;
			debugField.background = true;
			debugField.text = "messages";
			debugField.x = mapWidth - debugField.width - 15; 
			debugField.y = mapHeight - debugField.height - 15;
 			debugField.name = 'text';
 			debugField.mouseEnabled = false;
 			debugField.selectable = false;
 			debugField.multiline = true;
 			debugField.wordWrap = false;
			
			lastFrameTime = getTimer();
			
			well = new Sprite();
			well.name = 'well';
			well.doubleClickEnabled = true;
			well.mouseEnabled = true;
			well.mouseChildren = false;
			addChild(well);

			worldMatrix = new Matrix();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			queueTimer = new Timer(200);
			queueTimer.addEventListener(TimerEvent.TIMER, processQueue);
		}
		
		/**
		 * Get the Tile instance that corresponds to a given coordinate.
		 */
		public function getCoordTile(coord:Coordinate):Tile
		{
		    // these get floored when they're cast as ints in tileKey()
		    var key:String = tileKey(coord.column, coord.row, coord.zoom);
		    return well.getChildByName(key) as Tile;
		}
		
		private function onAddedToStage(event:Event):void
		{
			if (draggable) {
				addEventListener(MouseEvent.MOUSE_DOWN, mousePressed, true);
			}
			addEventListener(Event.RENDER, onRender);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			queueTimer.start();
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			dirty = true;
			// force an on-render in case we were added in a render handler
			onRender();
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			if (hasEventListener(MouseEvent.MOUSE_DOWN)) {
				removeEventListener(MouseEvent.MOUSE_DOWN, mousePressed, true);
			}
			removeEventListener(Event.RENDER, onRender);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			queueTimer.stop();
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		/** The classes themselves serve as factories!
		 * 
		 * @param tileClass e.g. Tile, TweenTile, etc.
		 * 
		 * @see http://norvig.com/design-patterns/img013.gif  
		 */ 
		public function setTileClass(tileClass:Class):void
		{
			tilePool.setTileClass(tileClass);
			clearEverything();
		}
		
		/** processes the tileQueue and optionally outputs stats into debugField */
		protected function onEnterFrame(event:Event=null):void
		{
			if (debugField.parent) {
				// for stats...
				var frameDuration:Number = getTimer() - lastFrameTime;
				lastFrameTime = getTimer();
				
				fps = (0.9 * fps) + (0.1 * (1000.0/frameDuration));
	
	 			// report stats:
 				var tileChildren:int = 0;
				for (var i:int = 0; i < well.numChildren; i++) {
					tileChildren += Tile(well.getChildAt(i)).numChildren;
				}  
/* 				debugField.text = "fps: " + fps.toFixed(0)
						+ "\nmemory: " + (System.totalMemory/1048576).toFixed(1) + "MB"; */
 
				debugField.text = "tx: " + tx.toFixed(3)
						+ "\nty: " + tx.toFixed(3)
						+ "\nsc: " + scale.toFixed(4)
						+ "\nfps: " + fps.toFixed(0)
						+ "\ncurrent child count: " + well.numChildren
						+ "\ncurrent child of tile count: " + tileChildren
						+ "\nvisible tile count: " + visibleTiles.length
						+ "\nqueue length: " + tileQueue.length
						+ "\nblank count: " + blankCount
						+ "\nrequests: " + openRequests.length
						+ "\nfinished (cached) tiles: " + tileCache.size
						+ "\nrecently used tiles: " + recentlySeen.length
						+ "\ncachedLoaders: " + cachedUrls.length
						+ "\nTiles created: " + Tile.count
						+ "\nmemory: " + (System.totalMemory/1048576).toFixed(1) + "MB"; 
				debugField.width = debugField.textWidth+8;
				debugField.height = debugField.textHeight+4;
				debugField.x = mapWidth - debugField.width - 15; 
				debugField.y = mapHeight - debugField.height - 15;
			}
			
			//processQueue();
		}
		
		protected function onRendered():void
		{
			// listen out for this if you want to be sure map is in its final state before reprojecting markers etc.
			dispatchEvent(new MapEvent(MapEvent.RENDERED));
		}
		
		protected function onPanned():void
		{
			var pt:Point = coordinatePoint(startPan);
			dispatchEvent(new MapEvent(MapEvent.PANNED, pt.subtract(new Point(mapWidth/2, mapHeight/2))));			
		}
		
		protected function onZoomed():void
		{
			var zoomEvent:MapEvent = new MapEvent(MapEvent.ZOOMED_BY, zoomLevel-startZoom);
			// this might also be useful
		    zoomEvent.zoomLevel = zoomLevel;
	    	dispatchEvent(zoomEvent);			
		}
		
		protected function onChanged():void
		{
			// doesn't bubble, unlike MapEvent
			// Map will pick this up and dispatch MapEvent.EXTENT_CHANGED for us
			dispatchEvent(new Event(Event.CHANGE, false, false));			
		}
		
		protected function onBeginTileLoading():void
		{
			dispatchEvent(new MapEvent(MapEvent.BEGIN_TILE_LOADING));			
		}
		
		protected function onProgress():void
		{
		    // dispatch tile load progress
		    dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, previousOpenRequests - openRequests.length, previousOpenRequests));			
		}
		
		protected function onAllTilesLoaded():void
		{
			dispatchEvent(new MapEvent(MapEvent.ALL_TILES_LOADED));			
		}
		
		/** 
		 * figures out from worldMatrix which tiles we should be showing, adds them to the stage, adds them to the tileQueue if needed, etc.
		 * 
		 * from my recent testing, TileGrid.onRender takes < 5ms most of the time, and rarely >10ms
		 * (Flash Player 9, Firefox, Macbook Pro)
		 *  
		 */
		protected function onRender(event:Event=null):void
		{
			if (!dirty || !stage) {
				onRendered();
				return;
			}

			var boundsEnforced:Boolean = enforceBounds();

			if (zooming || panning) {
				if (panning) {
					onPanned();
				}	
				if (zooming) {
					onZoomed();
				}
			}
			else if (boundsEnforced) {
				onChanged();
			}
			else if (matrixChanged) {
				matrixChanged = false;
				onChanged();
			}
			
			// what zoom level of tiles should we be loading, taking into account min/max zoom?
			// (0 when scale == 1, 1 when scale == 2, 2 when scale == 4, etc.)
			var newZoom:int = Math.min(maxZoom, Math.max(minZoom, Math.round(zoomLevel)));
			
			// see if the newZoom is different to currentZoom
			// so we know which way we're zooming, if any:
			if (currentTileZoom != newZoom) {
				previousTileZoom = currentTileZoom;
			}
			
			// this is the level of tiles we'll be loading:
			_currentTileZoom = newZoom;
		
			// find start and end columns for the visible tiles, at current tile zoom
			// TODO: take account of potential rotation in worldMatrix (ask Tom about this if you need it)
			var tlC:Coordinate = topLeftCoordinate.zoomTo(currentTileZoom);
			var brC:Coordinate = bottomRightCoordinate.zoomTo(currentTileZoom);
			
			// optionally pad it out a little bit more with a tile buffer
			// TODO: investigate giving a directional bias to TILE_BUFFER when panning quickly
			// NB:- I'm pretty sure these calculations are accurate enough that using 
			//      Math.ceil for the maxCols will load one column too many -- Tom
			var minCol:int = Math.floor(tlC.column) - tileBuffer;
			var maxCol:int = Math.floor(brC.column) + tileBuffer;
			var minRow:int = Math.floor(tlC.row) - tileBuffer;
			var maxRow:int = Math.floor(brC.row) + tileBuffer;

			// loop over all tiles and find parent or child tiles from cache to compensate for unloaded tiles:			
			repopulateVisibleTiles(minCol, maxCol, minRow, maxRow);

			// move visible tiles to the end of recentlySeen if we're done loading them
			// the 'least recently seen' tiles will be removed from the tileCache below
			for each (var visibleTile:Tile in visibleTiles) {
				if (!layersNeeded[visibleTile.name]) {
					var ri:int = recentlySeen.indexOf(visibleTile.name); 
					if (ri >= 0) {
						recentlySeen.splice(ri, 1);
					}
					recentlySeen.push(visibleTile.name);
				}
			}

			// prune tiles from the well if they shouldn't be there (not currently in visibleTiles)
			// TODO: unless they're fading in or out?
			// (loop backwards so removal doesn't change i)
			for (var i:int = well.numChildren-1; i >= 0; i--) {
				var wellTile:Tile = well.getChildAt(i) as Tile;
				if (visibleTiles.indexOf(wellTile) < 0) {
					well.removeChild(wellTile);
					wellTile.hide();
					if (!tileCache.containsKey(wellTile.name)) {
						//trace("destroying tile that was in the well but never cached");
						delete layersNeeded[wellTile.name];
						if (tileQueue.contains(wellTile)) {
							tileQueue.remove(wellTile);
						}
						tilePool.returnTile(wellTile);
					}
				}
			}

			// position tiles such that currentZoom is approximately scale 1
			// and x and y make sense in pixels relative to tlC.column and tlC.row (topleft)
			positionTiles(tlC.column, tlC.row);

			// all the visible tiles will be at the end of recentlySeen
			// let's make sure we keep them around:
			var maxRecentlySeen:int = Math.max(visibleTiles.length, maxTilesToKeep);
			
			// prune cache of already seen tiles if it's getting too big:
 			if (recentlySeen.length > maxRecentlySeen) {

 				// can we sort so that biggest zoom levels get removed first, without removing currently visible tiles?
/* 				var visibleKeys:Array = recentlySeen.slice(recentlySeen.length - visibleTiles.length, recentlySeen.length);

				// take a look at everything else
				recentlySeen = recentlySeen.slice(0, recentlySeen.length - visibleTiles.length);
				recentlySeen = recentlySeen.sort(Array.DESCENDING);
				recentlySeen = recentlySeen.concat(visibleKeys); */
				
 				// throw away keys at the beginning of recentlySeen
				recentlySeen = recentlySeen.slice(recentlySeen.length - maxRecentlySeen, recentlySeen.length);
				
				// loop over our internal tile cache 
				// and throw out tiles not in recentlySeen
				tileCache.retainKeys(recentlySeen); 
			}
			
			// update centerRow and centerCol for sorting the tileQueue in processQueue()
			var center:Coordinate = centerCoordinate.zoomTo(currentTileZoom);
			centerRow = center.row;
			centerColumn = center.column;

			onRendered();

			dirty = false;
		}
				
		/**
		 * loops over given cols and rows and adds tiles to visibleTiles array and the well
		 * using child or parent tiles to compensate for tiles not yet available in the tileCache
		 */
		private function repopulateVisibleTiles(minCol:int, maxCol:int, minRow:int, maxRow:int):void
		{
			visibleTiles = []; 
			
			blankCount = 0; // keep count of how many tiles we missed?
		
			// for use in loops etc.
			var coord:Coordinate = new Coordinate(0,0,0);

			var searchedParentKeys:Object = {};
		
			// loop over currently visible tiles
			for (var col:int = minCol; col <= maxCol; col++) {
				for (var row:int = minRow; row <= maxRow; row++) {
					
					// create a string key for this tile
					var key:String = tileKey(col, row, currentTileZoom);
					
					// see if we already have this tile
					var tile:Tile = well.getChildByName(key) as Tile;
										
					// create it if not, and add it to the load queue
					if (!tile) {
						tile = tileCache.getTile(key);
						if (!tile) {
							tile = tilePool.getTile(col, row, currentTileZoom);
							tile.name = key;
 							coord.row = tile.row;
							coord.column = tile.column;
							coord.zoom = tile.zoom; 
							var urls:Array = provider.getTileUrls(coord);
							if (urls && urls.length > 0) {
								// keep a local copy of the URLs so we don't have to call this twice:
								layersNeeded[tile.name] = urls;
								tileQueue.push(tile);
							}
							else {
								tile.show();
							}
						}
						else {
							tile.show();
						}
						well.addChild(tile);
					}
					
 					visibleTiles.push(tile);
					
					var tileReady:Boolean = tile.isShowing() && (layersNeeded[tile.name] == null);
					
					//
					// if the tile isn't ready yet, we're going to reuse a parent tile
					// if there isn't a parent tile, and we're zooming out, we'll reuse child tiles
					// if we don't get all 4 child tiles, we'll look at more parent levels
					//
					// yes, this is quite involved, but it should be fast enough because most of the loops
					// don't get hit most of the time
					//
					
					if (!tileReady) {
					
						var foundParent:Boolean = false;
						var foundChildren:int = 0;
	
						if (currentTileZoom > previousTileZoom) {
							
							// if it still doesn't have enough images yet, or it's fading in, try a double size parent instead
		 					if (maxParentSearch > 0 && currentTileZoom > minZoom) {
	 							var firstParentKey:String = parentKey(col, row, currentTileZoom, currentTileZoom-1);
	 							if (!searchedParentKeys[firstParentKey]) {
		 							searchedParentKeys[firstParentKey] = true;
									if (ensureVisible(firstParentKey)) {
										foundParent = true;
									}
			 						if (!foundParent && (currentTileZoom - 1 < maxParentLoad)) {
										//trace("requesting parent tile at zoom", pzoom);
										var firstParentCoord:Array = parentCoord(col, row, currentTileZoom, currentTileZoom-1);
										visibleTiles.push(requestLoad(firstParentCoord[0], firstParentCoord[1], currentTileZoom-1));
									}									
	 							}
							}
							
						}
						else {
							 
							// currentZoom <= previousZoom, so we're zooming out
							// and therefore we might want to reuse 'smaller' tiles
							
							// if it doesn't have an image yet, see if we can make it from smaller images
		  					if (!foundParent && maxChildSearch > 0 && currentTileZoom < maxZoom) {
	 	  						for (var czoom:int = currentTileZoom+1; czoom <= Math.min(maxZoom, currentTileZoom+maxChildSearch); czoom++) {
			  						var ckeys:Array = childKeys(col, row, currentTileZoom, czoom);
									for each (var ckey:String in ckeys) {
										if (ensureVisible(ckey)) {
											foundChildren++;
										}
									} // ckeys
									if (foundChildren == ckeys.length) {
										break;
									} 
		  						} // czoom
		 					}
		 				}
	
						var stillNeedsAnImage:Boolean = !foundParent && foundChildren < 4; 					
	
						// if it still doesn't have an image yet, try more parent zooms
	 					if (stillNeedsAnImage && maxParentSearch > 1 && currentTileZoom > minZoom) {

			 				var startZoomSearch:int = currentTileZoom - 1;
			 				
			 				if (currentTileZoom > previousTileZoom) {
			 					// we already looked for parent level 1, and didn't find it, so:
			 					startZoomSearch -= 1;
			 				}
			 				
			 				var endZoomSearch:int = Math.max(minZoom, currentTileZoom-maxParentSearch);
			 				
	 						for (var pzoom:int = startZoomSearch; pzoom >= endZoomSearch; pzoom--) {
	 							var pkey:String = parentKey(col, row, currentTileZoom, pzoom);
	 							if (!searchedParentKeys[pkey]) {
		 							searchedParentKeys[pkey] = true;
									if (ensureVisible(pkey)) {								
										stillNeedsAnImage = false;
										break;
									}
			 						if (currentTileZoom - pzoom < maxParentLoad) {
										//trace("requesting parent tile at zoom", pzoom);
										var pcoord:Array = parentCoord(col, row, currentTileZoom, pzoom);
										visibleTiles.push(requestLoad(pcoord[0], pcoord[1], pzoom));
									}
								}
								else {
									break;
								}
	 						}
	 						
						}
											
						if (stillNeedsAnImage) {
							blankCount++;
						}

					} // if !tileReady
					
				} // for row
			} // for col
			
			// trace("zoomLevel", zoomLevel, "currentTileZoom", currentTileZoom, "blankCount", blankCount);
			
		} // repopulateVisibleTiles
		
		private function positionTiles(realMinCol:Number, realMinRow:Number):void
		{
 			// sort children by difference from current zoom level
 			// this means current is on top, +1 and -1 are next, then +2 and -2, etc.
			visibleTiles.sort(distanceFromCurrentZoomCompare, Array.DESCENDING);
			
/* 			var zooms:Array = visibleTiles.map(function(tile:Tile, ...rest):int {
				return tile.zoom;
			});
			trace("currentTileZoom", currentTileZoom);
			trace("tile zooms:", zooms); */

			// for fixing positions when we're between zoom levels:
 			var positionScaleCompensation:Number = Math.pow(2, zoomLevel-currentTileZoom);
			
 			// for positioning tile according to current transform, based on current tile zoom
 			var scaleFactors:Array = new Array(maxZoom+1);
			// scales to compensate for zoom differences between current grid zoom level				
 			var tileScales:Array = new Array(maxZoom+1);
			for (var z:int = 0; z <= maxZoom; z++) {
				scaleFactors[z] = Math.pow(2.0, currentTileZoom-z)
				
				// round up to the nearest pixel to avoid seams between zoom levels
				if (roundScalesEnabled) {
					tileScales[z] = Math.ceil(Math.pow(2, zoomLevel-z) * tileWidth) / tileWidth; 
				}
				else {
					tileScales[z] = Math.pow(2, zoomLevel-z);
				}
			}
			
			//trace();
			//trace("tile.zoom, tile.alpha, tile.numChildren ? tile.getChildAt(0).alpha : '', tile.isShowing() && (layersNeeded[tile.name] == null), tileCache.containsKey(tile.name)");
			
 			// apply the sorted depths, position all the tiles and also keep recentlySeen updated:
			for each (var tile:Tile in visibleTiles) {
			
				// if we set them all to numChildren-1, descending, they should end up correctly sorted
				well.setChildIndex(tile, well.numChildren-1);

 				var positionCol:Number = (scaleFactors[tile.zoom]*tile.column) - realMinCol;
 				var positionRow:Number = (scaleFactors[tile.zoom]*tile.row) - realMinRow;

				tile.scaleX = tile.scaleY = tileScales[tile.zoom];

  				if (!zooming && roundPositionsEnabled) {
	 				// this also helps the rare seams not fixed by rounding the tile scale, 
 					// but makes slow zooming uglier: 
 					// round, not floor, because the latter causes artifacts at lower zoom levels :(
					tile.x = Math.round(positionCol*tileWidth*positionScaleCompensation);
					tile.y = Math.round(positionRow*tileHeight*positionScaleCompensation);
				}
				else {
					tile.x = positionCol*tileWidth*positionScaleCompensation;
					tile.y = positionRow*tileHeight*positionScaleCompensation;
				}
				
			}
		}
		
		/** called by the onEnterFrame handler to manage the tileQueue
		 *  usual operation is extremely quick, ~1ms or so */
		private function processQueue(event:TimerEvent=null):void
		{
			if (openRequests.length < maxOpenRequests && tileQueue.length > 0) {

				// prune queue for tiles that aren't visible
				var removedTiles:Array = tileQueue.retainAll(visibleTiles);
				
				// keep layersNeeded tidy:
				for each (var removedTile:Tile in removedTiles) {
					delete layersNeeded[removedTile.name];
				}
				
				// note that queue is not the same as visible tiles, because things 
				// that have already been loaded are also in visible tiles. if we
				// reuse visible tiles for the queue we'll be loading the same things over and over
	
				if (maxParentLoad == 0) {
					// sort queue by distance from 'center'
					tileQueue.sortTiles(centerDistanceCompare);
				}
				else {
					tileQueue.sortTiles(zoomThenCenterCompare);					
				}
								
				// process the queue
				while (openRequests.length < maxOpenRequests && tileQueue.length > 0) {
					var tile:Tile = tileQueue.shift();
					// if it's still on the stage:
					if (tile.parent) {
						loadNextURLForTile(tile);
					}
				}
			}

			// you might want to wait for tiles to load before displaying other data, interface elements, etc.
			// these events take care of that for you...
			if (previousOpenRequests == 0 && openRequests.length > 0) {
				onBeginTileLoading();
			}
			else if (previousOpenRequests > 0)
			{
				// TODO: a custom event for load progress rather than overloading bytesloaded?
				onProgress();

			    // if we're finished...
			    if (openRequests.length == 0)
			    {
			    	onAllTilesLoaded();
    				// request redraw to take parent and child tiles off the stage if we haven't already
    				dirty = true;
    			}
			}
			
			previousOpenRequests = openRequests.length;
		}

		private function loadNextURLForTile(tile:Tile):void
		{
			// TODO: add urls to Tile?
			var urls:Array = layersNeeded[tile.name] as Array;
			if (urls && urls.length > 0) {
				var url:* = urls.shift();
				if (cacheLoaders && (url is String) && loaderCache[url]) {
					var original:Bitmap = loaderCache[url] as Bitmap;
					var bitmap:Bitmap = new Bitmap(original.bitmapData); 
					tile.addChild(bitmap);
					loadNextURLForTile(tile);
				}
				else {
					var tileLoader:Loader = new Loader();
					tileLoader.name = tile.name;
					try {
						if (cacheLoaders || smoothContent) {
							// check crossdomain permissions on tiles if we plan to access their bitmap content
							tileLoader.load((url is URLRequest) ? url : new URLRequest(url), new LoaderContext(true));
						}
						else {
							tileLoader.load((url is URLRequest) ? url : new URLRequest(url));
						}
						tileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadEnd, false, 0, true);
						tileLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false, 0, true);
						openRequests.push(tileLoader);
					}
					catch(error:Error) {
						tile.paintError();
					}
				}
			}
			else if (urls && urls.length == 0) {
				if (currentTileZoom-tile.zoom <= maxParentLoad) {
					tile.show();
				}
				else {
					tile.showNow();
				}
				tileCache.putTile(tile);					
				delete layersNeeded[tile.name];
			}			
		}

		private function zoomThenCenterCompare(t1:Tile, t2:Tile):int
		{
			if (t1.zoom == t2.zoom) {
				return centerDistanceCompare(t1, t2);
			}
			return t1.zoom < t2.zoom ? -1 : t1.zoom > t2.zoom ? 1 : 0; 
		}

		// for sorting arrays of tiles by distance from center Coordinate		
		private function centerDistanceCompare(t1:Tile, t2:Tile):int
		{
			if (t1.zoom == t2.zoom && t1.zoom == currentTileZoom && t2.zoom == currentTileZoom) {
				var d1:int = Math.pow(t1.row+0.5-centerRow,2) + Math.pow(t1.column+0.5-centerColumn,2); 
				var d2:int = Math.pow(t2.row+0.5-centerRow,2) + Math.pow(t2.column+0.5-centerColumn,2); 
				return d1 < d2 ? -1 : d1 > d2 ? 1 : 0; 
			}
			return Math.abs(t1.zoom-currentTileZoom) < Math.abs(t2.zoom-currentTileZoom) ? -1 : 1;
		}
		
		// for sorting arrays of tiles by distance from currentZoom		
		private function distanceFromCurrentZoomCompare(t1:Tile, t2:Tile):int
		{
			var d1:int = Math.abs(t1.zoom-currentTileZoom);
			var d2:int = Math.abs(t2.zoom-currentTileZoom);
			return d1 < d2 ? -1 : d1 > d2 ? 1 : zoomCompare(t2, t1); // t2, t1 so that big tiles are on top of small 
		}

		// for when tiles have same difference in zoom in distanceFromCurrentZoomCompare		
		private static function zoomCompare(t1:Tile, t2:Tile):int
		{
			return t1.zoom == t2.zoom ? 0 : t1.zoom > t2.zoom ? 1 : -1; 
		}

		// makes sure that if a tile with the given key exists in the cache that it is added to the well and added to visibleTiles
		// returns null if tile does not exist in cache
		private function ensureVisible(key:String):Tile
		{
			if (tileCache.containsKey(key)) {
				var tile:Tile = well.getChildByName(key) as Tile;
				if (!tile) {
					tile = tileCache.getTile(key);
					well.addChildAt(tile,0);
					if (currentTileZoom-tile.zoom <= maxParentLoad) {
						tile.show();
					}
					else {
						tile.showNow();						
					}
				}
				if (visibleTiles.indexOf(tile) < 0) {
					visibleTiles.push(tile); // don't get rid of it yet!
				}
				return tile;
			}
			return null;
 		}
		
		// for use in requestLoad
		private var tempCoord:Coordinate = new Coordinate(0,0,0);

		/** create a tile and add it to the queue - WARNING: this is buggy for the current zoom level, it's only used for parent zooms when maxParentLoad is > 0 */ 
		private function requestLoad(col:int, row:int, zoom:int):Tile
		{
			var key:String = tileKey(col, row, zoom);
			if (tileCache.containsKey(key)) throw new Error("requested load for an already cached tile");			
			var tile:Tile = well.getChildByName(key) as Tile; 
			if (!tile) {
				tile = tilePool.getTile(col, row, zoom);
				tile.name = key;
				tempCoord.row = row;
				tempCoord.column = col;
				tempCoord.zoom = zoom;
				var urls:Array = provider.getTileUrls(tempCoord);
				if (urls && urls.length > 0) {
					// keep a local copy of the URLs so we don't have to call this twice:
					layersNeeded[tile.name] = urls;
					tileQueue.push(tile);
				}
				else {
					// trace("no urls needed for that tile", tempCoord);
					tile.show();
				}
				well.addChild(tile);
			}
			return tile;
		}

		private static const zoomLetter:Array = "abcdefghijklmnopqrstuvwxyz".split('');
						
		/** zoom is translated into a letter so that keys can easily be sorted (alphanumerically) by zoom level */
		private function tileKey(col:int, row:int, zoom:int):String
		{
			return zoomLetter[zoom]+":"+col+":"+row;
		}
		
		// TODO: check that this does the right thing with negative row/col?
		private function parentKey(col:int, row:int, zoom:int, parentZoom:int):String
		{
			var scaleFactor:Number = Math.pow(2.0, zoom-parentZoom);
			var pcol:int = Math.floor(Number(col) / scaleFactor); 
			var prow:int = Math.floor(Number(row) / scaleFactor);
			return tileKey(pcol,prow,parentZoom);			
		}

		// used when maxParentLoad is > 0
		// TODO: check that this does the right thing with negative row/col?
		private function parentCoord(col:int, row:int, zoom:int, parentZoom:int):Array
		{
			var scaleFactor:Number = Math.pow(2.0, zoom-parentZoom);
			var pcol:int = Math.floor(Number(col) / scaleFactor); 
			var prow:int = Math.floor(Number(row) / scaleFactor);
			return [ pcol, prow ];			
		}		
		
		// TODO: check that this does the right thing with negative row/col?
		private function childKeys(col:int, row:int, zoom:int, childZoom:int):Array
		{
 			var scaleFactor:Number = Math.pow(2, zoom-childZoom); // one zoom in = 0.5
 			var rowColSpan:int = Math.pow(2, childZoom-zoom); // one zoom in = 2, two = 4
 			var keys:Array = [];
 			for (var ccol:int = col/scaleFactor; ccol < (col/scaleFactor)+rowColSpan; ccol++) {
 				for (var crow:int = row/scaleFactor; crow < (row/scaleFactor)+rowColSpan; crow++) {
 					keys.push(tileKey(ccol, crow, childZoom));
 				}
 			}
 			return keys;
		}
						
		private function onLoadEnd(event:Event):void
		{
			var loader:Loader = (event.target as LoaderInfo).loader;
			
			if (cacheLoaders && !loaderCache[loader.contentLoaderInfo.url]) {
				//trace('caching content for', loader.contentLoaderInfo.url);
				try {
					var content:Bitmap = loader.content as Bitmap;
					loaderCache[loader.contentLoaderInfo.url] = content;
					cachedUrls.push(loader.contentLoaderInfo.url);
					if (cachedUrls.length > maxLoaderCacheSize) {
						delete loaderCache[cachedUrls.shift()];
					}
				}
				catch (error:Error) {
					// ???
				}
			}
			
			if (smoothContent) {
				try {
					var smoothContent:Bitmap = loader.content as Bitmap;
					smoothContent.smoothing = true;
				}
				catch (error:Error) {
					// ???
				}
			}			

			// tidy up the request monitor
			var index:int = openRequests.indexOf(loader);
			if (index >= 0) {
				openRequests.splice(index,1);
			}
			
			var tile:Tile = well.getChildByName(loader.name) as Tile;
			if (tile) { 
				tile.addChild(loader);
				loadNextURLForTile(tile);
			}
			else {
				// we've loaded an image, but its parent tile has been removed
				// so we'll have to throw it away
			}
		}

		private function onLoadError(event:IOErrorEvent):void
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			for (var i:int = openRequests.length-1; i >= 0; i--) {
				var loader:Loader = openRequests[i] as Loader;
				if (loader.contentLoaderInfo == loaderInfo) {
					openRequests.splice(i,1);
					var tile:Tile = well.getChildByName(loader.name) as Tile;
					if (tile) {
						delete layersNeeded[tile.name];
						tile.paintError(tileWidth, tileHeight);
						if (currentTileZoom-tile.zoom <= maxParentLoad) {
							tile.show();
						}
						else {
							tile.showNow();
						}
					}
					break;
				}
			}
		}	
		
		public function mousePressed(event:MouseEvent):void
		{
			prepareForPanning(true);
			pmouse = new Point(event.stageX, event.stageY);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseDragged);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseReleased);
		}

		public function mouseReleased(event:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseDragged);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseReleased);
			donePanning();
			dirty = true;
			if (event is MouseEvent) {
				MouseEvent(event).updateAfterEvent();
			}
			else if (event.type == Event.MOUSE_LEAVE) {
				onRender();
			}
		}

		public function mouseDragged(event:MouseEvent):void
		{
			var mousePoint:Point = new Point(event.stageX, event.stageY);
			tx += mousePoint.x - pmouse.x;
			ty += mousePoint.y - pmouse.y;
			pmouse = mousePoint;
			dirty = true;
			event.updateAfterEvent();
		}	

		// today is all about lazy evaluation
		// this gets set to null by 'dirty = true'
		// and only calculated again if you need it
		protected function get invertedMatrix():Matrix
		{
			if (!_invertedMatrix) {
				_invertedMatrix = worldMatrix.clone();
				_invertedMatrix.invert();
				_invertedMatrix.scale(scale/tileWidth, scale/tileHeight);
			}
			return _invertedMatrix;
		}

		/** derived from map provider by calculateBounds(), read-only here for convenience */
		public function get minZoom():Number
		{
			return _minZoom;
		}
		/** derived from map provider by calculateBounds(), read-only here for convenience */
		public function get maxZoom():Number
		{
			return _maxZoom;
		}

		/** convenience method for tileWidth */
		public function get tileWidth():Number
		{
			return _tileWidth;
		}
		/** convenience method for tileHeight */
		public function get tileHeight():Number
		{
			return _tileHeight;
		}

		/** read-only, this is the level of tiles we'll be loading first */
		public function get currentTileZoom():Number
		{
			return _currentTileZoom;
		}


		public function get topLeftCoordinate():Coordinate
		{
			if (!_topLeftCoordinate) {
				var tl:Point = invertedMatrix.transformPoint(new Point());
				_topLeftCoordinate = new Coordinate(tl.y, tl.x, zoomLevel);			
			}
			return _topLeftCoordinate;
		}

		public function get bottomRightCoordinate():Coordinate
		{
			if (!_bottomRightCoordinate) {
				var br:Point = invertedMatrix.transformPoint(new Point(mapWidth, mapHeight));
				_bottomRightCoordinate = new Coordinate(br.y, br.x, zoomLevel);			
			}
			return _bottomRightCoordinate;
		}
						
		public function get centerCoordinate():Coordinate
		{
			if (!_centerCoordinate) {
				var c:Point = invertedMatrix.transformPoint(new Point(mapWidth/2, mapHeight/2));
				_centerCoordinate = new Coordinate(c.y, c.x, zoomLevel);
			} 
			return _centerCoordinate; 			
		}
		
		public function coordinatePoint(coord:Coordinate, context:DisplayObject=null):Point
		{
			// this is the same as coord.zoomTo, but doesn't make a new Coordinate:
			var zoomFactor:Number = Math.pow(2, zoomLevel - coord.zoom);
			//zoomFactor *= tileWidth/scale;
			var zoomedColumn:Number = coord.column * zoomFactor;
			var zoomedRow:Number = coord.row * zoomFactor;
			
 			var tl:Coordinate = topLeftCoordinate;
			var br:Coordinate = bottomRightCoordinate;
			
			var cols:Number = br.column - tl.column;
			var rows:Number = br.row - tl.row;
			
			var screenPoint:Point = new Point(mapWidth * (zoomedColumn-tl.column) / cols, mapHeight * (zoomedRow-tl.row) / rows); 
			
			//var screenPoint:Point = worldMatrix.transformPoint(new Point(zoomedColumn, zoomedRow));

			if (context && context != this)
            {
    			screenPoint = this.parent.localToGlobal(screenPoint);
    			screenPoint = context.globalToLocal(screenPoint);
            }

			return screenPoint; 
		}
		public function pointCoordinate(point:Point, context:DisplayObject=null):Coordinate
		{			
			if (context && context != this)
            {
    			point = context.localToGlobal(point);
    			point = this.globalToLocal(point);
            }
			
			var p:Point = invertedMatrix.transformPoint(point);
			return new Coordinate(p.y, p.x, zoomLevel);
		}
		
		public function prepareForPanning(dragging:Boolean=false):void
		{
			if (panning) {
				donePanning();
			}
			if (!dragging && draggable) {
				if (hasEventListener(MouseEvent.MOUSE_DOWN)) {
					removeEventListener(MouseEvent.MOUSE_DOWN, mousePressed, true);
				}
			}
			startPan = centerCoordinate.copy();
			panning = true;
			onStartPanning();
		}
		
		protected function onStartPanning():void
		{
			dispatchEvent(new MapEvent(MapEvent.START_PANNING));
		}
		
		public function donePanning():void
		{
			if (draggable) {
				if (!hasEventListener(MouseEvent.MOUSE_DOWN)) {
					addEventListener(MouseEvent.MOUSE_DOWN, mousePressed, true);
				}
			}
			startPan = null;
			panning = false;
			onStopPanning();
		}
		
		protected function onStopPanning():void
		{
			dispatchEvent(new MapEvent(MapEvent.STOP_PANNING));
		}
		
		public function prepareForZooming():void
		{
			if (startZoom >= 0) {
				doneZooming();
			}

			startZoom = zoomLevel;
			zooming = true;
			onStartZooming();
		}
		
		protected function onStartZooming():void
		{
			dispatchEvent(new MapEvent(MapEvent.START_ZOOMING, startZoom));
		}
			    		
		public function doneZooming():void
		{
			onStopZooming();
			startZoom = -1;
			zooming = false;
		}

		protected function onStopZooming():void
		{
		    var event:MapEvent = new MapEvent(MapEvent.STOP_ZOOMING, zoomLevel);
		    event.zoomDelta = zoomLevel - startZoom;
			dispatchEvent(event);
		}

		public function resetTiles(coord:Coordinate):void
		{
			var sc:Number = Math.pow(2, coord.zoom);

			worldMatrix.identity();
			worldMatrix.scale(sc, sc);
			worldMatrix.translate(mapWidth/2, mapHeight/2 );
			worldMatrix.translate(-tileWidth*coord.column, -tileHeight*coord.row);

			// reset the inverted matrix, request a redraw, etc.
			dirty = true;
		}

		public function get zoomLevel():Number
		{
			return Math.log(scale) / Math.LN2;
		}

		public function set zoomLevel(n:Number):void
		{
		    if (zoomLevel != n)
		    {
    			scale = Math.pow(2, n);						
            }
		}

		public function get scale():Number
		{
			return Math.sqrt(worldMatrix.a * worldMatrix.a + worldMatrix.b * worldMatrix.b);
		}

		public function set scale(n:Number):void
		{
		    if (scale != n)
		    {
		    	var needsStop:Boolean = false;
		    	if (!zooming) {
    				prepareForZooming();
    				needsStop = true;
    			}
    			
    			var sc:Number = n / scale;
    			worldMatrix.translate(-mapWidth/2, -mapHeight/2);
    			worldMatrix.scale(sc, sc);
    			worldMatrix.translate(mapWidth/2, mapHeight/2);
    			
    			dirty = true;	
    			
    			if (needsStop) {
    				doneZooming();
    			}
		    }
		}
				
		public function resizeTo(p:Point):void
		{
		    if (mapWidth != p.x || mapHeight != p.y)
		    {
		    	var dx:Number = p.x - mapWidth;
		    	var dy:Number = p.y - mapHeight;
		    	
		    	// maintain the center point:
		    	tx += dx/2;
		    	ty += dy/2;
		    	
    			mapWidth = p.x;
    			mapHeight = p.y;
    	        scrollRect = new Rectangle(0, 0, mapWidth, mapHeight);

				debugField.x = mapWidth - debugField.width - 15; 
				debugField.y = mapHeight - debugField.height - 15;
    			
    			dirty = true;

    			// force this but only for onResize
    			onRender();
		    }

			// this makes sure the well is clickable even without tiles
			well.graphics.clear();
			well.graphics.beginFill(0x000000, 0);
			well.graphics.drawRect(0, 0, mapWidth, mapHeight);
			well.graphics.endFill();
		}
		
		public function setMapProvider(provider:IMapProvider):void
		{
			this.provider = provider;

			_tileWidth = provider.tileWidth;
			_tileHeight = provider.tileHeight;
			
			calculateBounds();
			
			clearEverything();
		}
		
		protected function clearEverything():void
		{
			while (well.numChildren > 0) {			
				var tile:Tile = well.removeChildAt(0) as Tile;
				if (!tileCache.containsKey(tile.name)) {
					delete layersNeeded[tile.name];
					tilePool.returnTile(tile);
				}
			}
			
			for each (var loader:Loader in openRequests) {
				try {
					// la la I can't hear you
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadEnd);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
					loader.close();
				}
				catch (error:Error) {
					// close often doesn't work, no biggie
				}
			}
			openRequests = [];
			
			for (var key:String in layersNeeded) {
				delete layersNeeded[key];
			}
			layersNeeded = {}; 

			recentlySeen = [];
			
			tileQueue.clear();			
			tileCache.clear();
			
			dirty = true;
		}

		protected function calculateBounds():void
		{
			var limits:Array = provider.outerLimits();			
			var tl:Coordinate = limits[0] as Coordinate;
			var br:Coordinate = limits[1] as Coordinate;

			_maxZoom = Math.max(tl.zoom, br.zoom);  
			_minZoom = Math.min(tl.zoom, br.zoom);
			
			tl = tl.zoomTo(0);
			br = br.zoomTo(0);

			minTx = tl.column * tileWidth;
			maxTx = br.column * tileWidth;
			minTy = tl.row * tileHeight;
			maxTy = br.row * tileHeight;
		}
		
		/** called inside of onRender before events are fired
		 *  don't use setters inside of here to correct values otherwise we'll get stuck in a loop! */
 		protected function enforceBounds():Boolean
		{
			if (!enforceBoundsEnabled) {
				return false;
			}
			
			// TODO: should this modify things directly and return true?
 			if (zoomLevel < minZoom) {
				scale = Math.pow(2, minZoom);
			}
			else if (zoomLevel > maxZoom) {
				scale = Math.pow(2, maxZoom);
			} 

			var touched:Boolean = false;

/* 			this is potentially the way to wrap the x position
			but all the tiles flash and the values aren't quite right
			so wrapping the matrix needs more work :(
			
			var wrapTx:Number = 256 * scale;
			
			if (worldMatrix.tx > 0) {
				worldMatrix.tx = worldMatrix.tx - wrapTx; 
			}
			else if (worldMatrix.tx < -wrapTx) {
				worldMatrix.tx += wrapTx; 
			} */

			// to make sure we haven't gone too far
			// zoom topLeft and bottomRight coords to 0
			// so that they can be compared against minTx etc.
			
			var tl:Coordinate = topLeftCoordinate.zoomTo(0);
			var br:Coordinate = bottomRightCoordinate.zoomTo(0);
			
			var leftX:Number = tl.column * tileWidth;
			var rightX:Number = br.column * tileHeight;
			
   			if (rightX-leftX > maxTx-minTx) {
 				worldMatrix.tx = (mapWidth-(minTx+maxTx)*scale)/2;
				touched = true;
 			}
 			else if (leftX < minTx) {
 				worldMatrix.tx += (leftX-minTx)*scale;				
				touched = true;
			}
 			else if (rightX > maxTx) {
 				worldMatrix.tx += (rightX-maxTx)*scale;				
				touched = true;
			}

 			var upY:Number = tl.row * tileHeight;
			var downY:Number = br.row * tileWidth;

   			if (downY-upY > maxTy-minTy) {
 				worldMatrix.ty = (mapHeight-(minTy+maxTy)*scale)/2;
				touched = true;
 			}
			else if (upY < minTy) {
				worldMatrix.ty += (upY-minTy)*scale;
				touched = true;
			}
			else if (downY > maxTy) {
				worldMatrix.ty += (downY-maxTy)*scale;
				touched = true;
			} 

			if (touched) {
				_invertedMatrix = null;
				_topLeftCoordinate = null;
				_bottomRightCoordinate = null;
				_centerCoordinate = null;				
			}

			return touched;			
		}
		
		protected function set dirty(d:Boolean):void
		{
			_dirty = d;
			if (d) {
				if (stage) stage.invalidate();
				
				_invertedMatrix = null;
				_topLeftCoordinate = null;
				_bottomRightCoordinate = null;			
				_centerCoordinate = null;				
			}
		}
		
		protected function get dirty():Boolean
		{
			return _dirty;
		}

		public function getMatrix():Matrix
		{
			return worldMatrix.clone();
		}

		public function setMatrix(m:Matrix):void
		{
			worldMatrix = m;
			matrixChanged = true;
			dirty = true;
		}
		
		public function get a():Number
		{
			return worldMatrix.a;
		}
		public function get b():Number
		{
			return worldMatrix.b;
		}
		public function get c():Number
		{
			return worldMatrix.c;
		}
		public function get d():Number
		{
			return worldMatrix.d;
		}
		public function get tx():Number
		{
			return worldMatrix.tx;
		}
		public function get ty():Number
		{
			return worldMatrix.ty;
		}

		public function set a(n:Number):void
		{
			worldMatrix.a = n;
			dirty = true;
		}
		public function set b(n:Number):void
		{
			worldMatrix.b = n;
			dirty = true;
		}
		public function set c(n:Number):void
		{
			worldMatrix.c = n;
			dirty = true;
		}
		public function set d(n:Number):void
		{
			worldMatrix.d = n;
			dirty = true;
		}
		public function set tx(n:Number):void
		{
			worldMatrix.tx = n;
			dirty = true;
		}
		public function set ty(n:Number):void
		{
			worldMatrix.ty = n;
			dirty = true;
		}
								
	}
	
}

import com.modestmaps.core.Tile;
import flash.utils.Dictionary;
import com.modestmaps.Map;	

class TileQueue
{
	// Tiles we want to load:
	protected var queue:Array;
	
	public function TileQueue()
	{
		queue = [];
	}
	
	public function get length():Number 
	{
		return queue.length;
	}

	public function contains(tile:Tile):Boolean
	{
		return queue.indexOf(tile) >= 0;
	}

	public function remove(tile:Tile):void
	{
		var index:int = queue.indexOf(tile); 
		if (index >= 0) { 
			queue.splice(index, 1);
		}
	}
	
	public function push(tile:Tile):void
	{
 		if (contains(tile)) {
			throw new Error("that tile is already on the queue!");
		}
		queue.push(tile);
	}
	
	public function shift():Tile
	{
		return queue.shift() as Tile;
	}
	
	public function sortTiles(callback:Function):void
	{
		queue = queue.sort(callback);
	}
	
	public function retainAll(tiles:Array):Array
	{
		var removed:Array = [];
		for (var i:int = queue.length-1; i >= 0; i--) {
			var tile:Tile = queue[i] as Tile;
			if (tiles.indexOf(tile) < 0) {
				removed.push(tile);
				queue.splice(i,1);
			} 
		}
		return removed;
	}
	
	public function clear():void
	{
		queue = [];
	}
	
}

/** the alreadySeen Dictionary here will contain up to grid.maxTilesToKeep Tiles */
class TileCache
{
	// Tiles we've already seen and fully loaded, by key (.name)
	protected var alreadySeen:Dictionary;
	protected var tilePool:TilePool; // for handing tiles back!
	
	public function TileCache(tilePool:TilePool)
	{
		this.tilePool = tilePool;
		alreadySeen = new Dictionary();
	}
	
	public function get size():int
	{
		var alreadySeenCount:int = 0;
		for (var key:* in alreadySeen) {
			alreadySeenCount++;
		}
		return alreadySeenCount;		
	}
	
	public function putTile(tile:Tile):void
	{
		if (alreadySeen[tile.name]) {
			throw new Error("caching a tile that's already cached");
		}
 		if (tile.numChildren == 0) {
			throw new Error("tile added to cache has no children!");
		}
		alreadySeen[tile.name] = tile;
	}
	
	public function getTile(key:String):Tile
	{
		return alreadySeen[key] as Tile;
	}
	
	public function containsKey(key:String):Boolean
	{
		return alreadySeen[key] is Tile;
	}
	
	public function retainKeys(keys:Array):void
	{
		for (var key:String in alreadySeen) {
			if (keys.indexOf(key) < 0) {
				tilePool.returnTile(alreadySeen[key] as Tile);
				delete alreadySeen[key];
			}
		}		
	}
	
	public function clear():void
	{
		for (var key:String in alreadySeen) {
			tilePool.returnTile(alreadySeen[key] as Tile);
			delete alreadySeen[key];
		}
		alreadySeen = new Dictionary();		
	}
}

/** 
 *  This post http://lab.polygonal.de/2008/06/18/using-object-pools/
 *  suggests that using Object pools, especially for complex classes like Sprite
 *  is a lot faster than calling new Object().  The suggested implementation
 *  uses a linked list, but to get started with it here I'm using an Array.  
 *  
 *  If anyone wants to try it with a linked list and compare the times,
 *  it seems like it could be worth it :)
 */ 
class TilePool 
{
	protected static const MIN_POOL_SIZE:int = 256;
	protected static const MAX_NEW_TILES:int = 256;
	
	protected var pool:Array = [];
	protected var tileClass:Class;
	
	public function TilePool(tileClass:Class)
	{
		this.tileClass = tileClass;
	}

	public function setTileClass(tileClass:Class):void
	{
		this.tileClass = tileClass;
		pool = [];
	}

	public function getTile(column:int, row:int, zoom:int):Tile
	{
    	if (pool.length < MIN_POOL_SIZE) {
    		while (pool.length < MAX_NEW_TILES) {
    			pool.push(new tileClass(0,0,0));
    		}
    	}						
		var tile:Tile = pool.pop() as Tile;
		tile.init(column, row, zoom);
		return tile;
	}

	public function returnTile(tile:Tile):void
	{
		tile.destroy();
    	pool.push(tile);
	}
	
}