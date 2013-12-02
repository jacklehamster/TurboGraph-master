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
	import flash.display.BitmapData;

	/**	▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ ▅ ▇ ▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ 
	 **		GLOBALBITMAPCACHE
	 ** Corresponds to one unique image, with one md5 id. Contains the bitmapData
	 * 	Each request for a bitmapData goes through the following workflow:
	 * 	- MovieClip's class => TurboInfo
	 * 	- TurboInfo + snapshotIndex (usually the frame) => BitmapInfo
	 * 	- BitmapInfo (via md5) => GlobalBitmapCache
	 * 	- GlobalBitmapCache returns the bitmapData
	 **/
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
		
		public function reset(bitmapData:BitmapData):void {
			bitmapInfos = new Vector.<BitmapInfo>();
			this.bitmapData = bitmapData;
		}
	}
}