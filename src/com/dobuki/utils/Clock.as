package com.dobuki.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class Clock
	{
		static private var clocks:Object = {};
		static private var interval:int = start();
		static private var lastCheck:int = 0;
		static private var sprite:Sprite;
		static private var frames:int = 0;
		
		static private function start():int {
			sprite = new Sprite();
			sprite.addEventListener(Event.ENTER_FRAME,clear);
			return 0;
		}
		
		static public var active:Boolean = true;

		static public function clockin(id:String):void {
			if(!active)
				return;
			if(!clocks[id])
				clocks[id] = {time:0,count:0};
			clocks[id].time -= getTimer();
			clocks[id].count++;
		}
		
		static public function clockout(id:String):void {
			if(!active)
				return;
			if(clocks[id])
				clocks[id].time += getTimer();
		}
		
		static private function clear(e:Event):void {
			if(!active)
				return;
			var now:int = getTimer();
			var diffTimer:int = now-lastCheck;
			frames ++;
			if(diffTimer>10000/24){
				trace('==================================');
				for(var id:String in clocks) {
					trace(id,clocks[id].time/frames,"/",clocks[id].count/frames,"(",clocks[id].time/clocks[id].count,")");
//					delete clocks[id];
				}
				lastCheck = now;
				frames = 0;
			}
		}
	}
}