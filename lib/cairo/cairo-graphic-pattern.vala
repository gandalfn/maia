/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cairo-graphic-pattern.vala
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

internal class Maia.CairoGraphicPattern : GraphicPattern
{
    // properties
    private unowned CairoGraphicContext? m_Context = null;
    private GraphicColor                 m_Color;
    private Point                        m_SourceOffset;
    private GraphicDevice                m_Source;

    // accessors
    public override GraphicContext context {
        get {
            return m_Context;
        }
    }

    public override GraphicColor color {
        get {
            return m_Color;
        }
        set {
            m_Color = value;
            m_Context.context.set_source_rgba (value.red, value.green, 
                                               value.blue, value.alpha);
        }
    }

    public override Point source_offset { 
        get {
            return m_SourceOffset;
        }
        set {
            m_SourceOffset = value;
            m_Context.context.set_source_surface (((CairoGraphicDevice)m_Source).surface,
                                                  m_SourceOffset.x,
                                                  m_SourceOffset.y);
        }
    }

    public override GraphicDevice source {
        get {
            return m_Source;
        }
        set {
            if (value is CairoGraphicDevice)
            {
                m_Source = value;
                m_Context.context.set_source_surface (((CairoGraphicDevice)m_Source).surface,
                                                      m_SourceOffset.x,
                                                      m_SourceOffset.y);
            }
        }
    }

    // methods
    public CairoGraphicPattern (CairoGraphicContext inContext)
    {
        m_Context = inContext;
    }
}
