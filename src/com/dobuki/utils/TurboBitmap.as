package com.dobuki.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class TurboBitmap extends Bitmap
	{
		public var snapshotIndex:String = null;
		public function TurboBitmap(bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false, snapshotIndex:String = null)
		{
			super(bitmapData, pixelSnapping, smoothing);
			this.snapshotIndex = snapshotIndex;
		}
	}
}