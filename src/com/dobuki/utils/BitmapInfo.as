package com.dobuki.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class BitmapInfo
	{
		public var bitmapData:BitmapData;
		public var lastUsed:int;
		public var owner:TurboInfo;
		public var snapshotIndex:String;
		public var md5:String;
		public var timeMatch:int;
		public var cache:Vector.<Bitmap>;
		public var cacheIndex:int;
		
		static public var globalBitmapCache:Object = {};
		
		public function BitmapInfo(owner:TurboInfo,snapshotIndex:String,bitmapData:BitmapData):void {
			this.owner = owner;
			this.bitmapData = bitmapData;
			this.snapshotIndex = snapshotIndex;
		}
	}
}