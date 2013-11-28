package com.dobuki.utils
{
	import flash.display.Bitmap;
	
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