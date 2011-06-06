/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atomic-iterator.vala
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

public class Maia.AtomicIterator<T>
{
    private AtomicNode<T> m_Last;
    private AtomicNode<T> m_Target;
    private AtomicNode<T> m_PreAux;
    private AtomicNode<T> m_PreCell;

    public AtomicIterator (AtomicNode<T> inFirst, AtomicNode<T> inLast)
    {
        m_Last = inLast;
        m_PreCell = inFirst;
        m_PreAux = inFirst.next;
        m_Target = null;

        update ();
    }

    internal void
    update ()
    {
        if (m_PreAux.next == m_Target)
            return;

        unowned AtomicNode<T>? p = m_PreAux;
        AtomicNode<T> n = p.next;
        m_Target = null;

        while (n != m_Last && n.data == null)
        {
            GLib.AtomicPointer.compare_and_exchange (&m_PreCell.next, p, n);
            p.unref ();
            p = n;
            n = p.next;
        }

        m_PreAux = p;
        m_Target = n;
    }

    internal bool
    try_insert (AtomicNode<T> inNode, AtomicNode<T> inAux)
    {
        inNode.next = inAux;
        GLib.AtomicPointer.set (&inAux.next, m_Target);

        bool ret = GLib.AtomicPointer.compare_and_exchange (&m_PreAux.next, m_Target, inNode);
        if (ret) 
            inNode.ref ();
        else
            inNode.next = null;

        return ret;
    }

    internal bool
    search (T inValue, CompareFunc<T> inFunc)
    {
        while (m_Target != m_Last)
        {
            int res = inFunc (m_Target.data.value, inValue);
            if (res == 0)
                return true;
            else if (res > 0)
                return false;
            else
                next ();
        }

        return false;
    }

    public bool
    next ()
    {
        if (m_Target == m_Last)
            return false;

        m_PreCell = m_Target;
        m_PreAux = m_Target.next;

        update ();

        return m_Target != m_Last;
    }

    public unowned T?
    get ()
    {
        return m_Target.data.value;
    }
}