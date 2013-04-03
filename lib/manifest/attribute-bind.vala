/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * attribute-bind.vala
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

public class Maia.Manifest.AttributeBind : Attribute
{
    // Methods
    /**
     * Create a new attribute bind
     *
     * @param inOwner owner of attribute
     * @param inValue attribute bind value
     */
    public AttributeBind (Object inOwner, string inValue)
    {
        base (inOwner, inValue.substring (1));
    }

    public void
    bind (Object inDest, string inProperty, owned GLib.BindingTransformFunc? inFunc = null)
    {
        if (owner != null)
        {
            string[] split = get().split (".");

            owner.bind_property (split[0], inDest, inProperty,
                                 GLib.BindingFlags.DEFAULT | GLib.BindingFlags.SYNC_CREATE,
                                 (owned)inFunc);
       }
    }
}
