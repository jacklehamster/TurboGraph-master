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

package com.dobuki
{
	import com.dobuki.utils.BitmapInfo;
	import com.dobuki.utils.Clock;
	import com.dobuki.utils.GlobalBitmapCache;
	import com.dobuki.utils.TurboBitmap;
	import com.dobuki.utils.TurboInfo;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import by.blooddy.crypto.MD5;

	/**	▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ ▅ ▇ ▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ 
	 **		TURBOGRAPH
	 ** This main class is your access to the engine. It contains the code that does all the processing (digging for cached MovieClip
	 *  by traversing the display list, then processing them all into a flatten overlay that contains bitmap).
	 * 	To use TurboGraph, simply call: TurboGraph.initialize(root);
	 * 	This will make the root invisible, another layer will be created on the stage containing all bitmaps.
	 * 	Some optional features:
	 * 	- TurboGraph.addEventListener(TurboEvent.NEW_BITMAP,callback): This lets you detect when a new BitmapData has been created. It will
	 * 		not fired if a BitmatData has been detected as duplicate, and thus got removed immediately.
	 * 	- TurboGraph.active: You can turn TurboGraph on/off while it's running. This is useful to compare performance. TurboGraph is on by default
	 * 	- TurboGraph.debugging: In debug mode, you can see an overlay of rectangles indicating newly created bitmaps
	 *  - TurboGraph.colorTransformMode: If a cached MovieClip has been colored (through ColorTransform, not filter), then the engine
	 * 		can either apply it into the cached image upon drawing, or dynamically apply it to the bitmap.
	 * 		The colorTransform can also be ignored. By default, we apply the colorTransform upon drawing, which is the most performant.
	 * 		If the colorTransform will keep changing (like if you constantly change the alpha of MovieClips), then you should set this
	 * 		to COLORTRANSFORM_MODE_DYNAMIC.
	 *  - TurboGraph.showCursor: It's a helper function for changing the cursor. It didn't have to be there, but I found it useful personally.
	 *  - TurboGraph.frameRate: Returns the calculated frame per second.
	 * 	- TurboGraph.overlays / TurboGraph.getTopOverlay: This gives you access to the layer that holds all bitmaps
	 *  - TurboGraph.getDisplay: Pass the cached sprite as argument, the engine will return the corresponding bitmap
	 *  - TurboGraph.debugDisplay: Lets you draw your own rectangles in the engine's debug overlay
	 *  - TurboGraph.replaceBitmap: Lets you replace all instance of an image with a different image (using the md5 hash of the
	 * 		original image. This is useful if you want to reskin an application but don't want to mess with the Flash assets. You
	 * 		can just map all bitmaps to a different image.
	 *  - TurboGraph.cleanUp: Make a pass through and eliminate bitmaps and recoup memory. 
	 * 		A HARD cleanup removes all bitmaps, while a SOFT cleanup only removes the ones that have not been used for a while.
	 **/
	[Event(name="newBitmap", type="flash.events.TurboEvent")]
	public class TurboGraph extends EventDispatcher
	{
		static private const SOFT:String = "soft";
		static private const HARD:String = "hard";
		
		static public const COLORTRANSFORM_MODE_IGNORE:String = "ignore";
		static public const COLORTRANSFORM_MODE_DYNAMIC:String = "dynamic";
		static public const COLORTRANSFORM_MODE_CACHED:String = "cached";
		
		static private const BITMAP_LIFETIME:int = 30*1000;
		static private var _instance:TurboGraph = new TurboGraph();
		private var master:Sprite, _debugOverlay:Sprite;
		private var dico:Dictionary = new Dictionary();
		private var topOverlays:Vector.<Sprite> = new<Sprite> [ ];
		private var _active:Boolean = false,debugging:Boolean = false;
		private var framesCounter:int = 0, timeFrame:int = 0, fps:Number = 0;
		private var now:int = 0;
		private var cleanupPending:String = null;
		private var _colorTransformMode:String = COLORTRANSFORM_MODE_CACHED;
		
		static private const notransform:Matrix = new Matrix();
		
		private var recycle:Vector.<TurboBitmap> = new Vector.<TurboBitmap>();
		private var displayedElements:Dictionary = new Dictionary();
		
		public function TurboGraph()
		{
			_instance = this;
			
			dico[null] = dico[MovieClip] = dico[Sprite] = TurboInfo.EMPTY;
		}
		
		private function get stage():Stage {
			return master.stage;
		}
		
		static public function get active():Boolean {
			return _instance._active;
		}
		
		static public function get debugging():Boolean {
			return _instance.debugging;
		}
		
		static public function set debugging(value:Boolean):void {
			_instance.debugging = value;
		}
		
		static public function set colorTransformMode(value:String):void {
			_instance._colorTransformMode = value;
		}
		
		static public function get colorTransformMode():String {
			return _instance._colorTransformMode;
		}
		
		static public function showCursor(cursor:String):void {
			if(cursor && Mouse.cursor!=cursor) {
				Mouse.cursor = cursor;
			}
		}
		
		static public function cleanUp(soft:Boolean):void {
			_instance.cleanUp(soft);
		}
		
		static public function set active(value:Boolean):void {
			instance._active = value;
			if(_instance && _instance.master) {
				_instance.master.visible = !instance._active;
				for each(var overlay:Sprite in _instance.topOverlays) {
					overlay.visible = instance._active;
				}
			}
		}
		
		static public function initialize(root:Sprite):void {
			_instance.master = root;
			_instance.master.addEventListener(Event.ENTER_FRAME,_instance.redraw);
			_instance.master.addEventListener(Event.RENDER,_instance.loop);
			_instance.master.visible = !instance._active;
			_instance.master.stage.addChild(_instance.getTopOverlay(0));
			active = true;
		}
		
		static public function get overlays():Vector.<Sprite> {
			return _instance.topOverlays;
		}
		
		private function cleanUp(soft:Boolean):void {
			cleanupPending = soft?SOFT:HARD;;
		}
		
		private function performPendingCleanup(soft:Boolean):void {
			var info:TurboInfo, bitmapInfo:BitmapInfo;
			var list:Array = [];
			for each (info in dico) {
				if(info.Constructor) {
					for each(bitmapInfo in info.frames) {
						list.push(bitmapInfo);
					}
				}
			};
			
			for (var md5:String in BitmapInfo.globalBitmapCache) {
				var globalCache:GlobalBitmapCache = BitmapInfo.globalBitmapCache[md5];
				if(globalCache.bitmapData) {
					if(!soft || now - globalCache.lastUsed > (1+globalCache.revived) * BITMAP_LIFETIME) {
						for each(bitmapInfo in globalCache.bitmapInfos) {
							delete bitmapInfo.owner.frames[bitmapInfo.snapshotIndex];
							bitmapInfo.owner.count--;
							if(!bitmapInfo.owner.count) {
								delete dico[bitmapInfo.owner.Constructor];
							}
						}
						globalCache.bitmapInfos = null;
						globalCache.bitmapData.dispose();
						globalCache.bitmapData = null;
					}
				}
			}
			
			//	removed bitmaps
			for each(var bmp:TurboBitmap in displayedElements) {
				recycleBitmap(bmp);
			}
			displayedElements = new Dictionary();
			for each(var overlay:Sprite in topOverlays) {
				while(overlay.numChildren) {
					overlay.removeChildAt(0);
				}
			}
			
			//	clean debug overlay
			if(_debugOverlay) {
				_debugOverlay.graphics.clear();
				if(_debugOverlay.parent) {
					_debugOverlay.parent.removeChild(_debugOverlay);
				}
				_debugOverlay = null;
			}
		}
		
		private function redraw(e:Event):void {
			stage.invalidate()
		}
		
		static public function get instance():TurboGraph {
			return _instance;
		}
		
		public function getTopOverlay(index:int):Sprite {
			if(master) {
				while(topOverlays.length<=index) {
					var overlay:Sprite = new Sprite();
					overlay.mouseEnabled = overlay.mouseChildren = false;

					stage.addChild(overlay);
					topOverlays.push(overlay);
				}
				return topOverlays[index];
			}
			return null;
		}
		
		static public function get frameRate():Number {
			return _instance.fps;
		}
		
		private function loop(e:Event):void {
			now = getTimer();
			if(cleanupPending) {
				if(_debugOverlay) {
					_debugOverlay.graphics.clear();
				}
				performPendingCleanup(cleanupPending==SOFT);
				cleanupPending = null;
			}
			
			if(!_active)
				return;
			
			framesCounter++;
			if(now>timeFrame+1000) {
				fps = Math.round(framesCounter / (now-timeFrame)*100*1000)/100;
				timeFrame = now;
				framesCounter = 0;
			}
			
			
			Clock.clockin("turbograph loop");
			
			if(_debugOverlay) {
				_debugOverlay.graphics.clear();
			}
			
			var oldDisplayedElements:Dictionary = displayedElements;
			displayedElements = new Dictionary();
			var sprites:Vector.<Sprite> = new Vector.<Sprite>();
			dig(master,sprites);
			process(sprites,oldDisplayedElements);
			for each(var bmp:TurboBitmap in oldDisplayedElements) {
				recycleBitmap(bmp);
			}
			
			Clock.clockout("turbograph loop");
		}
		
		private function recycleBitmap(bmp:TurboBitmap):void {
			bmp.snapshotIndex = null;
			bmp.bitmapData = null;
			bmp.parent.removeChild(bmp);
			recycle.push(bmp);
		}
		
		private function get debugOverlay():Sprite {
			return _debugOverlay ? _debugOverlay : stage.addChild(_debugOverlay = new Sprite()) as Sprite;
		}
		
		static public function getDisplay(sprite:Sprite):TurboBitmap {
			var snapshotIndex:String = _instance.getSnapshotIndex(sprite);
			return _instance.displayedElements[sprite];
		}
		
		private function getSnapshotIndex(sprite:Sprite):String {
			return sprite is ICacheable ? (sprite as ICacheable).snapshotIndex : sprite is MovieClip ? (sprite as MovieClip).currentFrame.toString() : "0";
		}
		
		static public function debugDisplay(displayObject:DisplayObject,color:uint):void {
			var rect:Rectangle = displayObject.getRect(_instance.master);
			_instance.debugOverlay.graphics.lineStyle(1,color);
			_instance.debugOverlay.graphics.drawRect(rect.x,rect.y,rect.width,rect.height);
		}
		
		private function dig(container:DisplayObjectContainer,sprites:Vector.<Sprite>):void {
			if(!container.visible && container!=master) {
				return;
			}
			
			var Constructor:Class = Object(container).constructor;
			var info:TurboInfo = dico[Constructor];
			if(!info) {
				info = TurboInfo.EMPTY;
				if(container is Sprite) {
					var cacheSprite:CacheSprite = null;
					for(var i:int=0;i<container.numChildren;i++) {
						var child:CacheSprite = container.getChildAt(i) as CacheSprite;
						if(child) {
							if(!cacheSprite || child is CacheBox) {
								cacheSprite = child;
							}
							child.visible = false;
							break;
						}
					}
					if(cacheSprite) {
						var isCacheBox:Boolean = cacheSprite is CacheBox;
						info = new TurboInfo(
							Constructor,
							cacheSprite,
							isCacheBox ? cacheSprite.getBounds(container) : null,
							isCacheBox,
							{}
						);
					}
					
					dico[Constructor] = info;
				}
			}
			
			if(!info.frames) {
				for(i=0;i<container.numChildren;i++) {
					var childContainer:DisplayObjectContainer = container.getChildAt(i) as DisplayObjectContainer;
					if(childContainer) {
						dig(childContainer,sprites);
					}
				}
			}
			else {
				sprites.push(container as Sprite);
			}
		}
		
		static public function addEventListener(type:String, listener:Function):void {
			_instance.addEventListener(type, listener);
		}
		
		static public function removeEventListener(type:String, listener:Function):void {
			_instance.removeEventListener(type, listener);
		}
		
		private function createBitmapInfo(sprite:Sprite,info:TurboInfo,snapshotIndex:String):BitmapInfo {
			var bounds:Rectangle = !info.isBox ? sprite.getBounds(sprite) : info.mcrect;
			if(!bounds.width || !bounds.height) {
				return null;
			}
			var bitmapData:BitmapData = new BitmapData(bounds.width,bounds.height,true,0);
			var colorTransform:ColorTransform = _colorTransformMode==COLORTRANSFORM_MODE_CACHED ? sprite.transform.concatenatedColorTransform : null;
			bitmapData.draw(sprite,new Matrix(1,0,0,1,-bounds.left,-bounds.top),colorTransform,null,null,true);
			var bitmapInfo:BitmapInfo = new BitmapInfo(info,snapshotIndex,now,bitmapData,this);
			bitmapInfo.rect = bounds;
			info.frames[snapshotIndex] = bitmapInfo;
			info.count++;
			if(debugging)
				debugDisplay(sprite,0xFF6600);
			return bitmapInfo;
		}
		
		private function process(sprites:Vector.<Sprite>,oldDisplayedElements:Dictionary):void {
			
			for (var i:int=0; i<sprites.length; i++) {
				var sprite:Sprite = sprites[i];
				var Constructor:Class = Object(sprite).constructor;
				var info:TurboInfo = dico[Constructor];
				
				var topIndex:int = sprite is ITopMost ? (sprite as ITopMost).index : 0;
				var overlay:Sprite = getTopOverlay(topIndex);
				
				var snapshotIndex:String = getSnapshotIndex(sprite);
				var bitmapInfo:BitmapInfo = snapshotIndex ? info.frames[snapshotIndex] : null;
				if(!bitmapInfo) {
					bitmapInfo = createBitmapInfo(sprite,info,snapshotIndex);
					if(!bitmapInfo)
						continue;
				}
				
				var bmp:TurboBitmap = oldDisplayedElements[sprite] as TurboBitmap;
				if(bmp && bmp.snapshotIndex==snapshotIndex) {
					delete oldDisplayedElements[sprite];
				}
				else {
					bmp = recycle.pop();
					if(!bmp) {
						bmp = new TurboBitmap(PixelSnapping.AUTO,true,snapshotIndex);
					}
				}
					
				overlay.addChild(bmp);
				bmp.bitmapData = bitmapInfo.bitmapData;
				
				var rect:Rectangle = bitmapInfo.rect;
				var point:Point = sprite.localToGlobal(rect.topLeft);
				var transform:Transform = sprite.transform;
				var transformMatrix:Matrix = transform.concatenatedMatrix;
				bmp.transform.matrix = transformMatrix;
				if(_colorTransformMode==TurboGraph.COLORTRANSFORM_MODE_DYNAMIC) {
					bmp.transform.colorTransform = transform.concatenatedColorTransform;
				}
				bmp.x = (point.x);
				bmp.y = (point.y);
				
				if(debugging) {
					debugDisplay(sprite,info.isBox?0x00FFFF:0xFFFF00);
				}
				
				var timestamp:int = bitmapInfo.snapshotIndex ? now : 0;	//	dispose immediately if we don't have a snapshotIndex
				bitmapInfo.lastUsed = timestamp;
				(BitmapInfo.globalBitmapCache[bitmapInfo.md5] as GlobalBitmapCache).lastUsed = timestamp; 
				displayedElements[sprite] = bmp;
			}
		}
		
		static public function replaceBitmap(md5:String,bitmapData:BitmapData):void {
			var globalCache:GlobalBitmapCache = BitmapInfo.globalBitmapCache[md5];
			if(!globalCache) {
				globalCache = new GlobalBitmapCache(bitmapData);
				BitmapInfo.globalBitmapCache[md5] = globalCache;
			}
			else {
				globalCache.bitmapData = bitmapData;
			}
		}
	}
}

