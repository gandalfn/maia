/*
 * Copyright (C) 2014  Nicolas Bruguier
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *  Nicolas Bruguier <gandalfn@club-internet.fr>
 */

using Xcb;

[CCode (cheader_filename="xcb/xcb.h,xcb/xcb_keysyms.h")]
namespace Xcb.Util
{
    [Compact, CCode (cname = "xcb_key_symbols_t", free_function = "xcb_key_symbols_free")]
    public class KeySymbols {
        [CCode (cname = "xcb_key_symbols_alloc")]
        public KeySymbols (Connection connection);

        [CCode (cname = "xcb_key_symbols_get_keysym")]
        public Keysym @get (Keycode keycode, int col);

        [CCode (cname = "xcb_key_symbols_get_keycode", array_null_terminated = true)]
        public Keycode[]? get_keycode (Keysym keysym);

        [CCode (cname = "xcb_key_press_lookup_keysym")]
        public Keysym key_press_lookup (KeyPressEvent event, int col);

        [CCode (cname = "xcb_key_release_lookup_keysym")]
        public Keysym key_release_lookup (KeyPressEvent event, int col);

        [CCode (cname = "xcb_refresh_keyboard_mapping")]
        public int refresh_keyboard_mapping (MappingNotifyEvent event);
    }

    [CCode (cname = "xcb_is_keypad_key")]
    public static bool is_keypad_key (Keysym sym);

    [CCode (cname = "xcb_is_private_keypad_key")]
    public static bool is_private_keypad_key (Keysym sym);

    [CCode (cname = "xcb_is_cursor_key")]
    public static bool is_cursor_key (Keysym sym);

    [CCode (cname = "xcb_is_pf_key")]
    public static bool is_pf_key (Keysym sym);

    [CCode (cname = "xcb_is_function_key")]
    public static bool is_function_key (Keysym sym);

    [CCode (cname = "xcb_is_misc_function_key")]
    public static bool is_misc_function_key (Keysym sym);

    [CCode (cname = "xcb_is_modifier_key")]
    public static bool is_modifier_key (Keysym sym);
}
