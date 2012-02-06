/* -*- Mode: Vala indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cairo-graphic-context.vala
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

internal class Maia.CairoGraphicContext : GraphicContext
{
    // properties
    private Cairo.Context       m_Context    = null;
    private CairoGraphicDevice  m_Device     = null;
    private CairoGraphicPattern m_Pattern    = null;
    private CairoGraphicShape   m_Shape      = null;
    private CairoGraphicPaint   m_Paint      = null;

    private Region?             m_ClipRegion = null;

    // accessors
    public Cairo.Context context {
        get {
            if (m_Context == null && device != null)
            {
                m_Context = new Cairo.Context (m_Device.surface);
                m_Context.set_operator (Cairo.Operator.SOURCE);
            }

            return m_Context;
        }
    }

    public override GraphicDevice device {
        get {
            return m_Device;
        }
    }

    public override GraphicPattern pattern {
        get {
            return m_Pattern;
        }
    }

    public override GraphicPaint paint {
        get {
            return m_Paint;
        }
    }

    public override GraphicShape shape {
        get {
            return m_Shape;
        }
    }

    [CCode (notify = false)]
    public override Region? clip {
        get {
            return m_ClipRegion;
        }
        set {
            if (value == null)
            {
                m_Context.reset_clip ();
            }
            else
            {
                if (m_ClipRegion != null)
                {
                    m_ClipRegion.union (value);
                }
                else
                {
                    m_ClipRegion = value;
                }
                foreach (Rectangle rectangle in m_ClipRegion)
                {
                    context.rectangle (rectangle.origin.x, rectangle.origin.y,
                                         rectangle.size.width, rectangle.size.height);
                    context.clip ();
                }
            }
        }
    }

    // methods
    public CairoGraphicContext (CairoGraphicDevice inDevice)
    {
        m_Device = inDevice;
        m_Pattern = new CairoGraphicPattern (this);
        m_Shape = new CairoGraphicShape (this);
        m_Paint = new CairoGraphicPaint (this);
    }

    public override void
    save () throws GraphicError
    {
        m_Context.save ();
        status ();
    }

    public override void
    restore () throws GraphicError
    {
        m_Context.restore ();
        status ();
    }

    public override void
    status () throws GraphicError
    {
        Cairo.Status status = m_Context.status ();

        switch (status)
        {
            case Cairo.Status.SUCCESS:
                break;
            case Cairo.Status.NO_MEMORY:
                throw new Maia.GraphicError.NO_MEMORY ("out of memory");
            case Cairo.Status.INVALID_RESTORE:
                throw new Maia.GraphicError.END_ELEMENT ("call end element without matching begin element");
            case Cairo.Status.NO_CURRENT_POINT:
                throw new Maia.GraphicError.NO_CURRENT_POINT ("no current point defined");
            case Cairo.Status.INVALID_MATRIX:
                throw new Maia.GraphicError.INVALID_MATRIX ("invalid matrix (not invertible)");
            case Cairo.Status.NULL_POINTER:
                throw new Maia.GraphicError.NULL_POINTER ("null pointer");
            case Cairo.Status.INVALID_STRING:
                throw new Maia.GraphicError.INVALID_STRING ("input string not valid UTF-8");
            case Cairo.Status.INVALID_PATH_DATA:
                throw new Maia.GraphicError.INVALID_PATH ("input path not valid");
            case Cairo.Status.SURFACE_FINISHED:
                throw new Maia.GraphicError.SURFACE_FINISHED ("the target surface has been finished");
            case Cairo.Status.SURFACE_TYPE_MISMATCH:
                throw new Maia.GraphicError.SURFACE_TYPE_MISMATCH ("the surface type is not appropriate for the operation");
            case Cairo.Status.PATTERN_TYPE_MISMATCH:
                throw new Maia.GraphicError.PATTERN_TYPE_MISMATCH ("the pattern type is not appropriate for the operation");
            default:
                throw new Maia.GraphicError.UNKNOWN ("a unknown error occured");
        }
    }
}
