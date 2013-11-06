package com.dobuki.utils
{
	import flash.display.BitmapData;

	public class GlobalBitmapCache
	{
		public var revived:int = 0;
		public var bitmapData:BitmapData;
		public var bitmapInfos:Vector.<BitmapInfo> = new Vector.<BitmapInfo>();
		public var lastUsed:int = 0;
		
		public function GlobalBitmapCache(bitmapData:BitmapData)
		{
			this.bitmapData = bitmapData;
		}
	}
}