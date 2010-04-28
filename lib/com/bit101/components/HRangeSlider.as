package com.bit101.components
{
	import flash.display.DisplayObjectContainer;
	
	public class HRangeSlider extends RangeSlider
	{
		public function HRangeSlider(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultHandler:Function = null)
		{
			super(HORIZONTAL, parent, xpos, ypos, defaultHandler);
		}
	}
}