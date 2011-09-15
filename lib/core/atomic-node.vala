/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atomic-node.vala
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

[Compact]
[CCode (ref_function = "maia_atomic_node_ref", unref_function = "maia_atomic_node_unref")]
public class Maia.AtomicNode<T>
{
    // types
    public class Data<T>
    {
        public T value;

        public Data (owned T inValue)
        {
            value = (owned)inValue;
        }
    }

    // static properties
    static AtomicNode<T> s_FreeList;

    // properties
    public   Data<T>?      data = null;
    internal int           ref_count_claim = 1;
    internal AtomicNode<T> next = null;

    // static methods
    private static inline int
    dec_and_test_and_set (ref int inVal)
    {
        int o = 2, n = 1;

        do
        {
            o = inVal;
            n = o - 2;
            if (n <= 0)
                n = 1;
        } while (!GLib.AtomicInt.compare_and_exchange (ref inVal, o, n));

        return (o - n) & 1;
    }

    private static inline void
    clear_lowest_bit (ref int inVal)
    {
        int o = 2, n = 1;

        do
        {
            o = inVal;
            n = o - 1;
        } while (!GLib.AtomicInt.compare_and_exchange (ref inVal, o, n));
    }

    private static void
    reclaim (AtomicNode<T> inNode)
    {
        void* node = null;

        do
        {
            node = GLib.AtomicPointer.get (&s_FreeList);
            GLib.AtomicPointer.set (&inNode.next, node);
        } while (!GLib.AtomicPointer.compare_and_exchange (&s_FreeList, node, inNode));

        inNode.data = null;
    }

    private static unowned AtomicNode<T>?
    safe_read (AtomicNode<T> inNode)
    {
        while (true)
        {
            void* node = GLib.AtomicPointer.get (&inNode);
            if (node == null)
                return null;
            GLib.AtomicInt.add (ref ((AtomicNode<T>)node).ref_count_claim, 2);
            if (node == GLib.AtomicPointer.get (&inNode))
                return ((AtomicNode<T>)node);
            else
                ((AtomicNode<T>)node).unref ();
        }
    }

    private static void
    release (AtomicNode<T>? inNode)
    {
        if (inNode != null)
        {
            if (dec_and_test_and_set (ref inNode.ref_count_claim) == 0)
                return;

            release (inNode.next);

            reclaim (inNode);
        }
    }

    internal AtomicNode (owned Data<T>? inData)
    {
        data = (owned)inData;
    }

    public static AtomicNode<T>?
    create (owned Data<T>? inData)
    {
        while (true)
        {
            unowned AtomicNode<T> node = s_FreeList;
            if (node == null)
            {
                AtomicNode<T> n = new AtomicNode<T> (null);
                GLib.AtomicPointer.compare_and_exchange (&s_FreeList, node, n);
                continue;
            }

            if (GLib.AtomicPointer.compare_and_exchange (&s_FreeList, node, node.next))
            {
                clear_lowest_bit (ref node.ref_count_claim);
                node.data = (owned)inData;
                node.next = null;
                return node;
            }
        };
    }

    public static AtomicNode<T>?
    create_aux ()
    {
        return create (null);
    }

    public unowned AtomicNode<T>?
    ref ()
    {
        return safe_read<T> (this);
    }

    public void
    unref ()
    {
        release<T> (this);
    }
}