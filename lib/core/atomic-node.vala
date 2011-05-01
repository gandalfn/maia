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
public class Maia.AtomicNode<T>
{
    // static properties
    static AtomicNode* s_pFreeList = null;

    // properties
    public   T           data;
    internal int         ref_count_claim = 1;
    internal AtomicNode* pNext = null;

    // static methods
    private static inline int
    dec_and_test_and_set (ref int inVal)
    {
        int o = 2, n = 1;

        do
        {
            o = inVal;
            if (o >> 1 == 0)
                n = 1;
            else
                n = o - 2;
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
            n = o & ~1;
        } while (!GLib.AtomicInt.compare_and_exchange (ref inVal, o, n));
    }

    private static void
    reclaim<T> (AtomicNode<T>* inpNode)
    {
        AtomicNode<T>* pNode = null;

        do
        {
            pNode = (AtomicNode<T>*)GLib.AtomicPointer.get (&s_pFreeList);;
            GLib.AtomicPointer.set (&inpNode->pNext, pNode);
        } while (GLib.AtomicPointer.compare_and_exchange (&s_pFreeList, pNode, inpNode));

        inpNode->data = null;
    }

    private static AtomicNode<T>*
    safe_read<T> (AtomicNode<T>* inpNode)
    {
        while (true)
        {
            AtomicNode<T>* pNode = (AtomicNode<T>*)GLib.AtomicPointer.get (&inpNode);
            if (pNode == null)
                return null;
            GLib.AtomicInt.add (ref pNode->ref_count_claim, 2);
            if (pNode == GLib.AtomicPointer.get (&inpNode))
                return pNode;
            else
                pNode->unref<T> ();
        }
    }

    private static void
    release<T> (AtomicNode<T>* inpNode)
    {
        if (inpNode != null)
        {
            if (dec_and_test_and_set (ref inpNode->ref_count_claim) == 1)
                return;

            release<T> (inpNode->pNext);

            reclaim<T> (inpNode);
        }
    }

    internal AtomicNode (owned T? inData)
    {
        data = inData;
    }

    public static unowned AtomicNode<T>?
    create<T> (T? inData)
    {
        while (true)
        {
            AtomicNode<T>* pNode = safe_read<T> (s_pFreeList);
            if (pNode == null)
            {
                pNode = new AtomicNode<T> (inData);
                reclaim<T> (pNode);
                continue;
            }

            if (GLib.AtomicPointer.compare_and_exchange (&s_pFreeList, pNode, pNode->pNext))
            {
                clear_lowest_bit (ref pNode->ref_count_claim);
                pNode->data = inData;
                return pNode;
            }
            else
                pNode->unref<T> ();
        };
    }

    public unowned AtomicNode<T>?
    ref<T> ()
    {
        return safe_read<T> (this);
    }

    public void
    unref<T> ()
    {
        release<T> (this);
    }
}