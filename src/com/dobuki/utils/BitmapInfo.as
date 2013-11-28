package com.dobuki.utils
{
	import com.dobuki.TurboGraph;
	import com.dobuki.events.TurboEvent;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import by.blooddy.crypto.MD5;

	public class BitmapInfo
	{
//		public var bitmapData:BitmapData;
		public var lastUsed:int;
		public var owner:TurboInfo;
		public var snapshotIndex:String;
		public var md5:String;
		public var rect:Rectangle;
		
		static public var globalBitmapCache:Object = {};
		
		public function BitmapInfo(owner:TurboInfo,snapshotIndex:String,time:int,bitmapData:BitmapData,turboGraph:TurboGraph):void {
			this.owner = owner;
			this.snapshotIndex = snapshotIndex;
			this.lastUsed = time;
			this.md5 = MD5.hashBytes(bitmapData.getPixels(bitmapData.rect));
			
			var globalCache:GlobalBitmapCache = BitmapInfo.globalBitmapCache[md5];
			
			if(globalCache && globalCache.bitmapData) {
				bitmapData.dispose();
				bitmapData = null;
			}
			else if(globalCache) {
				globalCache.revived++;
				globalCache.reset(bitmapData);
			}
			else {
				globalCache = new GlobalBitmapCache(bitmapData);
				BitmapInfo.globalBitmapCache[md5] = globalCache;
				turboGraph.dispatchEvent(new TurboEvent(TurboEvent.NEW_BITMAP,{bitmapData:bitmapData,md5:md5,Constructor:owner.Constructor,snapshotIndex:snapshotIndex}));
			}
			globalCache.bitmapInfos.push(this);
			if(lastUsed>globalCache.lastUsed)
				globalCache.lastUsed = lastUsed;
		}
		
		public function get bitmapData():BitmapData {
			var globalCache:GlobalBitmapCache = BitmapInfo.globalBitmapCache[md5];
			return globalCache.bitmapData;
		}
	}
}