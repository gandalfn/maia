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

[CCode (cheader_filename="xcb/xcb.h,xcb/xcb_cursor.h")]
namespace Xcb.Util
{
    [Compact, CCode (cname = "xcb_cursor_context_t", free_function = "xcb_cursor_context_free", cheader_filename="xcb/xcb_cursor.h")]
    public class CursorContext {
        [CCode (cname = "xcb_cursor_context_new")]
        static int _create (Connection connection, Screen screen, out CursorContext ctx);
        public static CursorContext? create (Connection connection, Screen screen)
        {
            CursorContext ctx;
            if (_create (connection, screen, out ctx) < 0)
                return null;

            return ctx;
        }

        [CCode (cname = "xcb_cursor_load_cursor")]
        public Cursor @get (string inName);
    }
}
