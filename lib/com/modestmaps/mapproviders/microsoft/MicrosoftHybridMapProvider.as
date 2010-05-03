package com.modestmaps.mapproviders.microsoft
{
	/**
	 * @author darren
	 * $Id: MicrosoftHybridMapProvider.as 647 2008-08-25 23:38:15Z tom $
	 */
	public class MicrosoftHybridMapProvider extends MicrosoftProvider
	{
		public function MicrosoftHybridMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
		{
			super(HYBRID, true, minZoom, maxZoom);
		}
	}
}