package com.dobuki
{
	import com.dobuki.utils.BitmapInfo;
	import com.dobuki.utils.Clock;
	import com.dobuki.utils.GlobalBitmapCache;
	import com.dobuki.utils.TurboInfo;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import by.blooddy.crypto.MD5;

	public class TurboGraph
	{
		static private const BITMAP_LIFETIME:int = 30*1000;
		static private var _instance:TurboGraph = new TurboGraph();
		private var master:Sprite, _overlay:Sprite = new Sprite(), _debugOverlay:Sprite;
		private var dico:Dictionary = new Dictionary();
		private var topOverlays:Vector.<Sprite> = new<Sprite> [ _overlay ];
		static private var _active:Boolean;
		static public var debugging:Boolean = false;
		
		static private const notransform:Matrix = new Matrix();
		
		private var recycle:Vector.< Bitmap> = new Vector.<Bitmap>();
		private var now:int;
		private var displayedElements:Dictionary = new Dictionary(true);
		
		public function TurboGraph()
		{
			_instance = this;
			_overlay.mouseChildren = false;
			
			dico[null] = dico[MovieClip] = dico[Sprite] = TurboInfo.EMPTY;
		}
		
		private function get stage():Stage {
			return master.stage;
		}
		
		static public function get active():Boolean {
			return _active;
		}
		
		static public function showCursor(cursor:String):void {
			if(cursor && Mouse.cursor!=cursor) {
				Mouse.cursor = cursor;
			}
			_instance._overlay.mouseEnabled = cursor != null;
			if(cursor) {
				Mouse.show();
			}
			else {
				Mouse.hide();
			}
		}
		
		static public function debugArea(rect:Rectangle):void {
			
		}
		
		private function cleanUp(soft:Boolean):void {
			var info:TurboInfo, bitmapInfo:BitmapInfo;
			var list:Array = [];
			var count:int = 0, mergeCount:int = 0, reviveCount:int = 0;
			for each (info in dico) {
				if(info.Constructor) {
					for each(bitmapInfo in info.frames) {
						list.push(bitmapInfo);
						if(!bitmapInfo.md5) {
							bitmapInfo.md5 = MD5.hashBytes(bitmapInfo.bitmapData.getPixels(bitmapInfo.bitmapData.rect));
							var globalCache:GlobalBitmapCache = BitmapInfo.globalBitmapCache[bitmapInfo.md5];
							if(globalCache && globalCache.bitmapData) {
								bitmapInfo.bitmapData.dispose();
								bitmapInfo.bitmapData = globalCache.bitmapData;
								mergeCount++;
							}
							else if(globalCache) {
								reviveCount++;
								globalCache.revived++;
								globalCache.bitmapInfos = new Vector.<BitmapInfo>();
								globalCache.bitmapData = bitmapInfo.bitmapData;
							}
							else {
								globalCache = new GlobalBitmapCache(bitmapInfo.bitmapData);
								BitmapInfo.globalBitmapCache[bitmapInfo.md5] = globalCache;
							}
							globalCache.bitmapInfos.push(bitmapInfo);
							if(bitmapInfo.lastUsed>globalCache.lastUsed)
								globalCache.lastUsed = bitmapInfo.lastUsed;
						}
					}
				}
			};
			
			var freeMem:int = System.freeMemory;
			for (var md5:String in BitmapInfo.globalBitmapCache) {
				globalCache = BitmapInfo.globalBitmapCache[md5];
				if(globalCache.bitmapData) {
					if(!soft || now - globalCache.lastUsed > (1+globalCache.revived) * BITMAP_LIFETIME) {
						for each(bitmapInfo in globalCache.bitmapInfos) {
							bitmapInfo.bitmapData = null;
							delete bitmapInfo.owner.frames[bitmapInfo.snapshotIndex];
							bitmapInfo.owner.count--;
							if(!bitmapInfo.owner.count) {
								delete dico[bitmapInfo.owner.Constructor];
							}
						}
						globalCache.bitmapInfos = null;
						globalCache.bitmapData.dispose();
						globalCache.bitmapData = null;
						count++;
					}
				}
			}
			
			trace("Freed memory:",System.freeMemory-freeMem, "/",+(count+mergeCount)+" bitmaps ("+mergeCount+" merged)");
			if(reviveCount) {
				trace("Revived:",reviveCount);
			}
		}
		
		static public function cleanUp(soft:Boolean):void {
			_instance.cleanUp(soft);
		}
		
		static public function set active(value:Boolean):void {
			_active = value;
			if(_instance && _instance.master) {
				_instance.master.visible = !_active;
				_instance._overlay.visible = _active;
			}
		}
		
		static public function initialize(root:Sprite):void {
			_instance.master = root;
			_instance.master.addEventListener(Event.FRAME_CONSTRUCTED,_instance.loop);
			_instance.master.visible = !_active;
			_instance.master.stage.addChild(_instance._overlay);
			_instance._overlay.scrollRect = new Rectangle(0,0,_instance.stage.stageWidth,_instance.stage.stageHeight);
			active = true;
		}
		
		static public function get instance():TurboGraph {
			return _instance;
		}
		
		public function getTopOverlay(index:int):Sprite {
			if(master) {
				while(topOverlays.length<=index) {
					var overlay:Sprite = new Sprite();
					stage.addChild(overlay);
					topOverlays.push(overlay);
				}
				return topOverlays[index];
			}
			return null;
		}
		
		private function loop(e:Event):void {
			if(!_active)
				return;
			
			Clock.clockin("turbograph loop");
			
			//_overlay.graphics.clear();
			//_overlay.graphics.lineStyle(1,0xFF0000);
			
			if(_debugOverlay) {
				_debugOverlay.graphics.clear();
			}
			//drawCount = 0;
			var oldDisplayedElements:Dictionary = displayedElements;
			displayedElements = new Dictionary(true);
			now = getTimer();
			var sprites:Vector.<Sprite> = new Vector.<Sprite>();
			dig(master,sprites);
			process(sprites,oldDisplayedElements);
			for each(var bmp:Bitmap in oldDisplayedElements) {
				if(bmp.parent)
					bmp.parent.removeChild(bmp);
				recycle.push(bmp);
			}
			
			Clock.clockout("turbograph loop");
			
		}
		
		private function get debugOverlay():Sprite {
			return _debugOverlay ? _debugOverlay : stage.addChild(_debugOverlay = new Sprite()) as Sprite;
		}
		
		static public function getDisplay(sprite:Sprite):Bitmap {
			return _instance.displayedElements[sprite];
		}
		
		static public function debugDisplay(displayObject:DisplayObject,color:uint):void {
			var rect:Rectangle = displayObject.getBounds(_instance.master);
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
					for(var i:int=0;i<container.numChildren;i++) {
						var child:DisplayObject = container.getChildAt(i);
						if(child is CacheSprite) {
							info = new TurboInfo(
								Constructor,
								child as CacheSprite,
								child.getBounds(container),
								child is CacheBox,
								{}
							);
							child.visible = false;
							break;
						}
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
		
		private function process(sprites:Vector.<Sprite>,oldDisplayedElements:Dictionary):void {
			
			for each(var sprite:Sprite in sprites) {
				var Constructor:Class = Object(sprite).constructor;
				var info:TurboInfo = dico[Constructor];
				
				var topIndex:int = sprite is ITopMost ? (sprite as ITopMost).index : 0;
				var overlay:Sprite = getTopOverlay(topIndex);
				
				var mc:MovieClip = sprite as MovieClip;
				var rect:Rectangle = mc.getBounds(master);
				if(rect.width && rect.height && _instance._overlay.scrollRect.intersects(rect)) {
					var snapshotIndex:String = (mc is ICacheable) ? (mc as ICacheable).snapshotIndex :  mc.currentFrame.toString();
					var bitmapInfo:BitmapInfo = info.frames[snapshotIndex];
					if(!bitmapInfo) {
						var bounds:Rectangle = !info.isBox ? mc.getBounds(mc) : info.mcrect;
						if(!bounds.width || !bounds.height) {
							return;
						}
						
						bitmapInfo = new BitmapInfo(info,snapshotIndex,new BitmapData(bounds.width,bounds.height,true,0));
						bitmapInfo.bitmapData.draw(mc,new Matrix(1,0,0,1,-bounds.left,-bounds.top),null,null,null,true);
						info.frames[snapshotIndex] = bitmapInfo;
						info.count++;
						
						if(debugging) {
							debugOverlay.graphics.lineStyle(1,0xFF0000);
							debugOverlay.graphics.drawRect(rect.x,rect.y,rect.width,rect.height);
						}
					}
					
					var bmp:Bitmap = oldDisplayedElements[sprite] as Bitmap;
					if(bmp) {
						delete oldDisplayedElements[sprite];
					}
					else {
						bmp = recycle.pop();
						if(!bmp) {
							bmp = new Bitmap(bitmapInfo.bitmapData,PixelSnapping.ALWAYS);
						}
					}
					
					overlay.addChild(bmp);
					if(bmp.bitmapData != bitmapInfo.bitmapData)
						bmp.bitmapData = bitmapInfo.bitmapData;
					if(!info.isBox) {
						bmp.transform.matrix = notransform;
						bmp.x = (rect.x);
						bmp.y = (rect.y);
						var dwidth:Number = bmp.width-rect.width;
						var dheight:Number = bmp.height-rect.height;
						if(dwidth<-1 || dwidth>1 || dheight<-1 || dheight>1) {
							bmp.width = rect.width;
							bmp.height = rect.height;
						}
					}
					else {
						var point:Point = mc.localToGlobal(info.mcrect.topLeft);
						var transformMatrix:Matrix = mc.transform.concatenatedMatrix;
						bmp.transform.matrix = transformMatrix;
						bmp.x = (point.x);
						bmp.y = (point.y);
					}
					bitmapInfo.lastUsed = now;
					if(bitmapInfo.md5) {
						(BitmapInfo.globalBitmapCache[bitmapInfo.md5] as GlobalBitmapCache).lastUsed = now; 
					}
					displayedElements[mc] = bmp;
				}				
			}
		}		
	}
}

