/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * pixman.vapi
 * Copyright (C) Nicolas Bruguier 2009 <gandalfn@club-internet.fr>
 * 
 * maia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

[CCode (cprefix = "Pixman", lower_case_cprefix = "pixman_", cheader_filename = "pixman.h")]
namespace Pixman 
{
	[SimpleType]
	[CCode (cname = "pixman_fixed_t")]
	[IntegerType (rank = 6)]
	public struct Fixed {
		[CCode (cname = "pixman_fixed_to_double")]
		public Pixman.double to_double();
		[CCode (cname = "pixman_fixed_to_int")]
		public Pixman.int to_int();
		[CCode (cname = "pixman_fixed_ceil")]
		public Fixed ceil();
	}

	[CCode (cname = "int")]
	[IntegerType (rank = 6)]
	public struct int {
		[CCode (cname = "pixman_int_to_fixed")]
		public Fixed to_fixed();
	}

	[CCode (cname = "double", default_value = "0.0")]
	[FloatingType (rank = 2)]
	public struct double {
		[CCode (cname = "pixman_double_to_fixed")]
		public Fixed to_fixed();
	}

	[CCode (cname = "pixman_box32_t")]
	public struct Box32 {
		public int32 x1;
		public int32 y1;
		public int32 x2;
		public int32 y2;
	}

	[CCode (cname = "pixman_region32_t")]
	public struct Region32 {
		public Box32 extents;

		public void init ();
		public void init_rect (int x, int y, uint width, uint height);
		public bool init_rects (Box32 boxes, int count);
		public void init_with_extents (Box32 extents);
		public void fini ();

		public bool copy (Region32 inRegion);

		public bool not_empty ();
		[CCode (cname = "pixman_region32_extents")]
		public unowned Box32* get_extents();
		public unowned Box32[] rectangles();
		public bool subtract (Region32 reg_m, Region32 reg_s);
		public bool union (Region32 reg_m, Region32 reg_s);
		public bool intersect (Region32 reg_m, Region32 reg_s);
	}
}
