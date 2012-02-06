/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * free-list.vala
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

namespace Maia.Memory
{
    // types
    public struct Node
    {
        internal Node* m_pNext;
    }

    [Compact]
    public class Pool
    {
        internal ulong m_Size;
        internal Node* m_pHead;

        public Pool (ulong inSize)
        {
            m_Size = inSize;
            m_pHead = GLib.malloc0 (m_Size + sizeof (Node));
        }

        public void
        release (void* inpVal)
        {
            char* ptr = (char*)inpVal;
            Node* pNode = (Node*)(ptr + m_Size);
            do
            {
                pNode->m_pNext = GLib.AtomicPointer.get (&m_pHead->m_pNext);
            } while (!GLib.AtomicPointer.compare_and_exchange(&m_pHead->m_pNext, pNode->m_pNext, pNode));
        }

        public void*
        allocate ()
        {
            void* pVal = null;
            Node* pNode = null;

            do
            {
                pNode = GLib.AtomicPointer.get (&m_pHead->m_pNext);
                if (pNode == null)
                {
                    pVal = GLib.malloc0 (m_Size + sizeof (Node));
                    return pVal;
                }
            } while (!GLib.AtomicPointer.compare_and_exchange(&m_pHead->m_pNext, pNode, pNode->m_pNext));

            pNode->m_pNext = null;

            char* ptr = (char*)pNode;
            pVal = (void*)(ptr - m_Size);

            return pVal;
        }
    }
}

struct Test
{
    static Maia.Memory.Pool? s_Pool = null;

    static Test?
    create ()
    {
        if (s_Pool == null)
            s_Pool = new Maia.Memory.Pool (sizeof (Test));
        return (Test?)s_Pool.allocate ();
    }

    Test ()
    {
    }

    static int main (string [] inArgs)
    {
        Test? test  = Test.create ();

        return 0;
    }
}