/**
 * MapProvider for Open Street Map data.
 * 
 * @author migurski
 * $Id: OpenStreetMapProvider.as 647 2008-08-25 23:38:15Z tom $
 */
package com.modestmaps.mapproviders
{ 
	import com.modestmaps.core.Coordinate;
	
	public class OpenStreetMapProvider
		extends AbstractMapProvider
		implements IMapProvider
	{
	    public function OpenStreetMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
        {
            super(minZoom, maxZoom);
        }

	    public function toString() : String
	    {
	        return "OPEN_STREET_MAP";
	    }
	
	    public function getTileUrls(coord:Coordinate):Array
	    {
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        return [ 'http://tile.openstreetmap.org/'+(sourceCoord.zoom)+'/'+(sourceCoord.column)+'/'+(sourceCoord.row)+'.png' ];
	    }
	    
	}
}