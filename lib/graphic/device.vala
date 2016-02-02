/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * device.vala
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
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

public interface Maia.Graphic.Device : GLib.Object, Core.Serializable
{
    // static properties
    private static Core.Map<string, GLib.Type> s_Factory = null;

    // static methods
    public static void
    register (string inBackend, GLib.Type inType)
        requires (inType.is_a (typeof (Device)))
    {
        if (s_Factory == null)
        {
            s_Factory = new Core.Map<string, GLib.Type> ();
        }

        s_Factory[inBackend] = inType;
    }

    public static GLib.Type
    get_backend_type (string inBackend)
    {
        return s_Factory[inBackend];
    }

    // methods
    public abstract string backend { get; }
}
