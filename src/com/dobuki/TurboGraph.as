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
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import by.blooddy.crypto.MD5;

	public class TurboGraph
	{
		static private const SOFT:String = "soft";
		static private const HARD:String = "hard";
		
		static private const BITMAP_LIFETIME:int = 30*1000;
		static private var _instance:TurboGraph = new TurboGraph();
		private var master:Sprite, _overlay:Sprite = new Sprite(), _debugOverlay:Sprite;
		private var dico:Dictionary = new Dictionary();
		private var topOverlays:Vector.<Sprite> = new<Sprite> [ _overlay ];
		static private var _active:Boolean;
		static public var debugging:Boolean = false;
		private var framesCounter:int = 0, timeFrame:int = 0, fps:Number = 0;
		private var cleanupPending:String = null;
		
		static private const notransform:Matrix = new Matrix();
		
		private var recycle:Vector.<TurboBitmap> = new Vector.<TurboBitmap>();
		private var displayedElements:Dictionary = new Dictionary(true);
		private var now:int;
		
		public function TurboGraph()
		{
			_instance = this;
			_instance._overlay.mouseEnabled = _overlay.mouseChildren = false;
			
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
		}
		
		static public function debugArea(rect:Rectangle):void {
			
		}
		
		private function cleanUp(soft:Boolean):void {
			cleanupPending = soft?SOFT:HARD;;
		}
		
		private function cleanDuplicate(bitmapInfo:BitmapInfo):void {
			if(!bitmapInfo.md5) {
				bitmapInfo.md5 = MD5.hashBytes(bitmapInfo.bitmapData.getPixels(bitmapInfo.bitmapData.rect));
				var globalCache:GlobalBitmapCache = BitmapInfo.globalBitmapCache[bitmapInfo.md5];
				if(globalCache && globalCache.bitmapData) {
					bitmapInfo.bitmapData.dispose();
					bitmapInfo.bitmapData = globalCache.bitmapData;
				}
				else if(globalCache) {
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
		
		private function performPendingCleanup(soft:Boolean):void {
			var info:TurboInfo, bitmapInfo:BitmapInfo;
			var list:Array = [];
			for each (info in dico) {
				if(info.Constructor) {
					for each(bitmapInfo in info.frames) {
						list.push(bitmapInfo);
						cleanDuplicate(bitmapInfo)
					}
				}
			};
			
			for (var md5:String in BitmapInfo.globalBitmapCache) {
				var globalCache:GlobalBitmapCache = BitmapInfo.globalBitmapCache[md5];
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
					}
				}
			}
			
			//	removed bitmaps
			for each(var bmp:TurboBitmap in displayedElements) {
				recycleBitmap(bmp);
			}
			displayedElements = new Dictionary(true);
			for each(var overlay:Sprite in topOverlays) {
				while(overlay.numChildren) {
					overlay.removeChildAt(0);
				}
			}
			topOverlays = new<Sprite> [ _overlay ];
			
			//	clean debug overlay
			if(_debugOverlay) {
				_debugOverlay.graphics.clear();
				if(_debugOverlay.parent) {
					_debugOverlay.parent.removeChild(_debugOverlay);
				}
				_debugOverlay = null;
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
			_instance.master.addEventListener(Event.ENTER_FRAME,_instance.redraw);
			_instance.master.addEventListener(Event.RENDER,_instance.loop);
			_instance.master.visible = !_active;
			_instance.master.stage.addChild(_instance._overlay);
			_instance._overlay.scrollRect = new Rectangle(0,0,_instance.stage.stageWidth,_instance.stage.stageHeight);
			active = true;
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
			displayedElements = new Dictionary(true);
			oldDisplayedElements
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
		
		private function createBitmapInfo(sprite:Sprite,info:TurboInfo,snapshotIndex:String):BitmapInfo {
			var bounds:Rectangle = !info.isBox ? sprite.getBounds(sprite) : info.mcrect;
			if(!bounds.width || !bounds.height) {
				return null;
			}
			
			var bitmapInfo:BitmapInfo = new BitmapInfo(info,snapshotIndex,now,new BitmapData(bounds.width,bounds.height,true,0));
			bitmapInfo.bitmapData.draw(sprite,new Matrix(1,0,0,1,-bounds.left,-bounds.top),sprite.transform.concatenatedColorTransform,null,null,true);
			cleanDuplicate(bitmapInfo);
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
						bmp = new TurboBitmap(bitmapInfo.bitmapData,PixelSnapping.AUTO,true,snapshotIndex);
					}
				}
					
				overlay.addChild(bmp);
				if(bmp.bitmapData != bitmapInfo.bitmapData)
					bmp.bitmapData = bitmapInfo.bitmapData;
				
				var rect:Rectangle = bitmapInfo.rect;
				var point:Point = sprite.localToGlobal(rect.topLeft);
					
				
				var transformMatrix:Matrix = sprite.transform.concatenatedMatrix;
				bmp.transform.matrix = transformMatrix;
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
	}
}

