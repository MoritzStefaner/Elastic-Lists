package com.modestmaps.mapproviders.microsoft
{
	/**
	 * @author darren
	 * $Id: MicrosoftRoadMapProvider.as 647 2008-08-25 23:38:15Z tom $
	 */
	public class MicrosoftRoadMapProvider extends MicrosoftProvider
	{
	    public function MicrosoftRoadMapProvider(hillShading:Boolean=true, minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
	    {
	        super(ROAD, hillShading, minZoom, maxZoom);
	    }
	}
}
