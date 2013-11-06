package com.dobuki.utils
{
	import com.dobuki.CacheSprite;
	
	import flash.geom.Rectangle;

	public class TurboInfo
	{
		public var cacheSprite:CacheSprite;
		public var mcrect:Rectangle;
		public var isBox:Boolean;
		public var frames:Object;
		public var count:int = 0;
		public var Constructor:Class;
		public var framesMD5:String;
		
		static public const EMPTY:TurboInfo = new TurboInfo(null,null,null,false,null);
		
		public function TurboInfo(Constructor:Class,cacheSprite:CacheSprite,mcrect:Rectangle,isBox:Boolean,frames:Object):void {
			this.Constructor = Constructor;
			this.cacheSprite = cacheSprite;
			this.mcrect = mcrect;
			this.isBox = isBox;
			this.frames = frames;
		}
	}
}