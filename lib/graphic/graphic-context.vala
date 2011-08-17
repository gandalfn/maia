/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * graphic-context.vala
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

public errordomain Maia.GraphicError
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

public abstract class Maia.GraphicContext : Object
{
    // accessors
    public abstract GraphicDevice  device  { get; }
    public abstract GraphicPattern pattern { get; }
    public abstract GraphicShape   shape   { get; }
    public abstract GraphicPaint   paint   { get; }

    public abstract Region?        clip { get; set; }

    // methods
    public abstract void save () throws GraphicError;
    public abstract void restore () throws GraphicError;
    public abstract void status () throws GraphicError;
}
