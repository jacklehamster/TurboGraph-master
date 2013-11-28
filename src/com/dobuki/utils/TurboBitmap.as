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
	import flash.display.Bitmap;
	
	/**	▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ ▅ ▇ ▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ 
	 **		TURBOBITMAP
	 ** A derivation of bitmap that also contains a snapshotIndex. Used internally
	 **/
	public class TurboBitmap extends Bitmap
	{
		public var snapshotIndex:String = null;
		public function TurboBitmap(pixelSnapping:String="auto", smoothing:Boolean=false, snapshotIndex:String = null)
		{
			super(null, pixelSnapping, smoothing);
			this.snapshotIndex = snapshotIndex;
		}
	}
}