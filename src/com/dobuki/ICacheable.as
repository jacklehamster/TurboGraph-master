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
	 **		ICACHEABLE
	 ** By default, snapshotIndex corresponds to each frame in a MovieClip. This can be overridden to have custom snapshotIndex.
	 * 	It's useful to overwrite the snapshotIndex for the following situation
	 * 	- The cached MovieClip is a textfield, so for each different text, we need to store a unique snapshotIndex
	 * 	- The cached MovieClip has a lot of frames of animation where the image does not change. In that case, we can specify
	 * 		that frames within a certain range X..Y will have the same snapshotIndex "X_Y". Note that you don't need to worry
	 * 		that much about this optimization, because the engine detects dupicate images and disposes them automatically.
	 * - The cached MovieClip is custom (like an avatar wearing various clothes). In that case, the snapshotIndex can be
	 * 		the frame along with the set of clothes (like "frame_1_hat1_shirt2_pants3"). This will ensure that each look will
	 * 		correspond to a different image
	 * - The cached MovieClip needs to accomodate for various filters. Then you can add the filter information inside snapshotIndex
	 **/
	public interface ICacheable
	{
		function get snapshotIndex():String;
	}
}