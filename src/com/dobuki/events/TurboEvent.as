package com.dobuki.events
{
	import flash.events.Event;
	
	public class TurboEvent extends Event
	{
		static public const NEW_BITMAP:String = "newBitmap";
	
		public var data:Object;
		
		public function TurboEvent(type:String,data:Object)
		{
			super(type);
			this.data = data;
		}
	}
}