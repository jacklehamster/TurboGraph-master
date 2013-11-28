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
	import com.dobuki.CacheSprite;
	
	import flash.geom.Rectangle;

	/**	▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ ▅ ▇ ▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ 
	 **		TURBOINFO
	 ** Corresponds to one unique class. Each class can contain many images depending on the snapshotIndex, which usually corresponds
	 *  to each frame in a MovieClip.
	 * 	Each request for a bitmapData goes through the following workflow:
	 * 	- MovieClip's class => TurboInfo
	 * 	- TurboInfo + snapshotIndex (usually the frame) => BitmapInfo
	 * 	- BitmapInfo (via md5) => GlobalBitmapCache
	 * 	- GlobalBitmapCache returns the bitmapData
	 **/
	public class TurboInfo
	{
		public var cacheSprite:CacheSprite;
		public var mcrect:Rectangle;
		public var isBox:Boolean;
		public var frames:Object;
		public var count:int = 0;
		public var Constructor:Class;
		
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