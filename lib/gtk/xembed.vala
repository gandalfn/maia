/* xembed.vala
 *
 * Copyright (C) 2009  Jürg Billeter
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Nicolas Bruguier <gandalfn@club-internet.fr>
 */

namespace XEmbed {
	/** The version of the XEMBED protocol that this library supports.  */
	public const int VERSION = 1;

	/** The atom name of the XEMBED message */
	public const string ATOM = "_XEMBED";

	/** Flags for _XEMBED_INFO */
	[Flags]
	public enum InfoFlags {
		MAPPED  = (1 << 0),
		ALL     = 1
	}

	/** XEMBED messages */
	public enum MessageType {
		NOTIFY 					= 0,
		WINDOW_ACTIVATE			= 1,
		WINDOW_DEACTIVATE		= 2,
		REQUEST_FOCUS			= 3,
		FOCUS_IN				= 4,
		FOCUS_OUT				= 5,
		FOCUS_NEXT				= 6,
		FOCUS_PREV				= 7,
		GRAB_KEY				= 8,
		UNGRAB_KEY 				= 9,
		MODALITY_ON				= 10,
		MODALITY_OFF			= 11,
		REGISTER_ACCELERATOR 	= 12,
		UNREGISTER_ACCELERATOR	= 13,
		ACTIVATE_ACCELERATOR	= 14
	}

	/** Details for XEMBED_FOCUS_IN */
	public enum FocusInDetail {
		FOCUS_CURRENT 	= 0,
		FOCUS_FIRST		= 1,
		FOCUS_LAST		= 2
	}

	/** Modifiers field for XEMBED_REGISTER_ACCELERATOR */
	[Flags]
	public enum AcceleratorModifiers {
		MODIFIER_SHIFT		= (1 << 0),
		MODIFIER_CONTROL	= (1 << 1),
		MODIFIER_ALT		= (1 << 2),
		MODIFIER_SUPER		= (1 << 3),
		MODIFIER_HYPER		= (1 << 4)
	}

	/** Flags for XEMBED_ACTIVATE_ACCELERATOR */
	[Flags]
	public enum ActivateAccelerator {
		ACCELERATOR_OVERLOADED	= (1 << 0)
	}
}
