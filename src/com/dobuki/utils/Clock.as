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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	/**	▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ ▅ ▇ ▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ 
	 **		CLOCK
	 ** Utils used for calculating performance.
	 *	Usage:
	 * 		Clock.clockin(id);
	 * 		//	do something
	 * 		Clock.clockout(id);
	 * 
	 * 	Make sure the clock is active. It will display the agregated time stepping into that chunk of code
	 **/
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
		
		static public var active:Boolean = false;

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