/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-event.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

internal abstract class Maia.XcbEvent : Event
{
    // accessors
    public abstract uint32 mask { get; }

    // methods
    public XcbEvent (uint32 inId, void* inOwner)
    {
        GLib.Object (id: inId, owner: inOwner);
    }

    public XcbEvent.with_args (uint32 inId, void* inOwner, EventArgs inArgs)
    {
        GLib.Object (id: inId, owner: inOwner, args: inArgs);
    }

    public override int
    compare (Object inOther)
        requires (inOther is XcbEvent)
    {
        int ret = 0;
        XcbEvent other = inOther as XcbEvent;

        ret = atom_compare (id, other.id);

        if (ret == 0)
        {
            ret = direct_compare (owner, other.owner);
        }

        return ret;
    }
}