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
	/**	▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ ▅ ▇ ▇ ▅ █ ▅ ▇ ▂ ▃ ▁ ▁ ▅ ▃ ▅ ▅ ▄ 
	 **		CACHEBOX
	 ** CacheBox is a derivation of CacheSprite, which is a widget for identifying MovieClips that need to be processed for caching
	 *  The difference with CacheSprite is that CacheBox defines a bounding rectangle. The engine uses that rectangle to determine
	 *  the dimension of the bitmap to draw. This is used because getRect returns the wrong dimension if an object is blurry, so
	 *  in that case we need to define the dimension ourselves, which can be a bit larger than the actual sprite.
	 * 	Like for CacheSprite, you must define a MovieClip that derrives from CacheBox, but make sure it contains a rectangle that
	 * 	starts from point (0,0). To use CacheBox, include it into any MovieClip to cache and stretch the box to cover the entire
	 * 	image. Don't worry about the graphics in CacheBox, they will automatically disappear.
	 **/
	public class CacheBox extends CacheSprite
	{
	}
}