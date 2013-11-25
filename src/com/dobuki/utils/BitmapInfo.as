package com.dobuki.utils
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class BitmapInfo
	{
		public var bitmapData:BitmapData;
		public var lastUsed:int;
		public var owner:TurboInfo;
		public var snapshotIndex:String;
		public var md5:String;
		public var rect:Rectangle;
		
		static public var globalBitmapCache:Object = {};
		
		public function BitmapInfo(owner:TurboInfo,snapshotIndex:String,time:int,bitmapData:BitmapData):void {
			this.owner = owner;
			this.bitmapData = bitmapData;
			this.snapshotIndex = snapshotIndex;
			this.lastUsed = time;
		}
	}
}