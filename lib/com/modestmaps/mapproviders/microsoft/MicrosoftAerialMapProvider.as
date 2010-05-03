
package com.modestmaps.mapproviders.microsoft
{
	/**
	 * @author darren
	 * $Id: MicrosoftAerialMapProvider.as 647 2008-08-25 23:38:15Z tom $
	 */
	public class MicrosoftAerialMapProvider extends MicrosoftProvider
	{
		public function MicrosoftAerialMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
		{
			super(AERIAL, true, minZoom, maxZoom);
		}
	}
}