/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * source.vala
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

internal class Maia.Source : GLib.Source
{
    // types
    public delegate bool PrepareFunc (out int outTimeout);
    public delegate bool CheckFunc ();
    public delegate bool DispatchFunc (GLib.SourceFunc inCallback);

    // properties
    protected PrepareFunc  m_PrepareFunc;
    protected CheckFunc    m_CheckFunc;
    protected DispatchFunc m_DispatchFunc;

    public Source (owned PrepareFunc inPrepareFunc, owned CheckFunc inCheckFunc, owned DispatchFunc inDispatchFunc)
    {
        m_PrepareFunc = (owned)inPrepareFunc;
        m_CheckFunc = (owned)inCheckFunc;
        m_DispatchFunc = (owned)inDispatchFunc;
    }

    protected override bool
    prepare (out int outTimeout)
    {
        return m_PrepareFunc (out outTimeout);
    }

    protected override bool
    check ()
    {
        return m_CheckFunc ();
    }

    protected override bool
    dispatch (SourceFunc inCallback)
    {
        return m_DispatchFunc (inCallback);
    }
}
