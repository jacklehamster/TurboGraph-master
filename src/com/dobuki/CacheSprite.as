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
	import flash.display.Sprite;
	
	/**	▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ ▅ ▇ ▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ 
	 **		CACHESPRITE
	 ** CacheSprite is a widget for identifying MovieClips that need to be processed for caching.
	 * 	To use this, design a widget MovieClip that derrive from CacheSprite. You can draw anything inside your widget, since
	 * 	it will automatically disappear, but don't make something too complex or Flash Pro can become very slow.
	 * 	Include the widget inside a MovieClip that needs caching. For better performance, try to ensure that including the
	 * 	widget does not extend the boundaries of the MovieClip.
	 * 
	 * 	Note: If a MovieClip contains both CacheBox and CacheSprite, then CacheBox is used.
	 *  If a MovieClip's children contains CacheBox or CacheSprite widgets, only the top most MovieClip with a direct child as a
	 *  CacheSprite/CacheBox widget is considered for Caching. The remaining widgets inside of children are ignored and will
	 *  disappear.
	 **/
	public class CacheSprite extends Sprite
	{
		public function CacheSprite()
		{
			super();
			visible = false;
		}
	}
}