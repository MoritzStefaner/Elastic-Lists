package com.bit101.components
{
	import flash.display.DisplayObjectContainer;
	
	public class VRangeSlider extends RangeSlider
	{
		public function VRangeSlider(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultHandler:Function = null)
		{
			super(VERTICAL, parent, xpos, ypos, defaultHandler);
		}
	}
}