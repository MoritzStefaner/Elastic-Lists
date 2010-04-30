/**
 * @author migurski
 * $Id: BlueMarbleMapProvider.as 647 2008-08-25 23:38:15Z tom $
 */
package com.modestmaps.mapproviders
{
	import com.modestmaps.core.Coordinate;
	
	public class BlueMarbleMapProvider 
		extends AbstractMapProvider
		implements IMapProvider
	{
	    public function BlueMarbleMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
        {
            super(minZoom, Math.min(9, maxZoom));
	    }
	
	    public function toString():String
	    {
	        return "BLUE_MARBLE";
	    }
	
	    public function getTileUrls(coord:Coordinate):Array
	    {
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        return [ 'http://s3.amazonaws.com/com.modestmaps.bluemarble/' + 
	        		 (sourceCoord.zoom) + '-r' + (sourceCoord.row) + '-c' + (sourceCoord.column) +
	        	    '.jpg' ];
	    }
	    
	}
}