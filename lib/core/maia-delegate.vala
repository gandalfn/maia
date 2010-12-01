/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-delegate.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public abstract class Maia.Delegate : Object
{
    internal static int
    compare_type_delegate (GLib.Type inType, Delegate inDelegate)
    {
        GLib.Type instance_type = GLib.Type.from_instance (inDelegate);
        return inType < instance_type ? -1 : (inType > instance_type ? 1 : 0);
    }

    public override int
    compare (Object inOther)
    {
        return compare_type_delegate (GLib.Type.from_instance (this), (Delegate)inOther);
    }
}