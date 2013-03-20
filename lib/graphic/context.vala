/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * context.vala
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

public errordomain Maia.Graphic.Error
{
    SUCCESS,
    NOT_IMPLEMENTED,
    NO_MEMORY,
    END_ELEMENT,
    NO_CURRENT_POINT,
    INVALID_MATRIX,
    INVALID_STATUS,
    NULL_POINTER,
    INVALID_STRING,
    INVALID_PATH,
    SURFACE_FINISHED,
    SURFACE_TYPE_MISMATCH,
    PATTERN_TYPE_MISMATCH,
    UNKNOWN
}

public class Maia.Graphic.Context : Object
{
    // accessors
    public virtual Device  device  { get; construct set; }
    public virtual Pattern pattern { get; set; }

    // methods
    public Context (Device inDevice)
    {
        GLib.Object (device: inDevice);
    }

    public virtual void
    save () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Save context not implemented");
    }

    public virtual void
    restore () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Restore context not implemented");
    }

    public virtual void
    status  () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context status not implemented");
    }

    public virtual void
    clip (Path inPath) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context clip not implemented");
    }

    public virtual void
    paint () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context paint not implemented");
    }

    public virtual void
    fill (Path inPath) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context fill not implemented");
    }

    public virtual void
    stroke (Path inPath) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context stroke not implemented");
    }

    public virtual void
    render (Glyph inGlyph) throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("Context render not implemented");
    }
}
