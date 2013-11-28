/*

Copyright (C) 2013 Vincent Le Quang

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program;
if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

Contact : vincentlequang@gmail.com

*/


package com.dobuki.utils
{
	import com.dobuki.TurboGraph;
	import com.dobuki.events.TurboEvent;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import by.blooddy.crypto.MD5;

	/**	▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ ▅ ▇ ▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ 
	 **		BITMAPINFO
	 ** Correponds to one Constructor/snapshotIndex pair. Contains information on restoring the bitmap for that snapshotIndex
	 **/
	public class BitmapInfo
	{
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