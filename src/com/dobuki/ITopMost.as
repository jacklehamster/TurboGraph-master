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
	 **		ITOPMOST
	 ** This interface is a helper to indicate that a bitmap should be above all other bitmaps. This is necessary in cases where
	 *  you mix and match the overlay produced by the engine with other stuff (maybe at the bottom, we have the engine overlay with
	 *  cached MovieClips,then on top of that you add your own UI, then we need more cached MovieClips above that.)
	 * 	- index: defines the layer where the bitmap should be placed. If index=0, the bitmap is placed at the normal layer (bottom).
	 **/
	public interface ITopMost
	{
		function get index():int;
	}
}