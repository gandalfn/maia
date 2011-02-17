/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * atom.vala
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

namespace Maia.Atom
{
    // types
    internal struct Node
    {
        public unowned Node?  m_Left;
        public unowned Node?  m_Right;
        public uint32         m_Pos;
        public uint32         m_FingerPrint;
        public string         m_Name;

        public Node (string inName)
        {
            m_Left = null;
            m_Right = null;
            m_Pos = 0;
            m_FingerPrint = 0;
            m_Name = inName;

            m_FingerPrint = mur_mur_hash ((void*)inName);
        }

        public Node.from_finger_print (uint inFingerPrint)
        {
            m_Left = null;
            m_Right = null;
            m_Pos = 0;
            m_FingerPrint = inFingerPrint;
            m_Name = null;
        }
    }

    // static properties
    static Node?  s_Root = null;
    static Node[] s_AtomTable = null;
    static int    s_LastAtom = 0;

    // static methods
    static uint
    mur_mur_hash (void* inKey)
    {
        uint m = 0x5bd1e995;
        int r = 24;
        uint l = 0;

        unowned uchar* data = (uchar*)inKey;

        uint h = 0;

        while (data[l] != 0     && data[l + 1] != 0 &&
               data[l + 2] != 0 && data[l + 3] != 0)
        {
            uint k = *(uint*)data;

            k *= m;
            k ^= k >> r;
            k *= m;
            h *= m;
            h ^= k;

            data += 4;
            l += 4;
        }

        uint t = 0;

        if (data[1] == 0)
        {
            t ^= data[0];
            h *= m;
        }
        else if (data[2] == 0)
        {
            t ^= data[1] << 8;
            t ^= data[0];
            h *= m;
        }
        else if (data[3] == 0)
        {
            t ^= data[2] << 16;
            t ^= data[1] << 8;
            t ^= data[0];
            h *= m;
        }

        h ^= h >> 13;
        h *= m;
        h ^= h >> 15;

        return h;
    }

    public static uint32
    from_string (string? inName)
    {
        if (inName == null) return 0;

        long len = inName.length;
        Node node = Node (inName);

        unowned Node? np = s_Root;
        void* nd = &s_Root;
        while (np != null)
        {
            if (node.m_FingerPrint < np.m_FingerPrint)
            {
                nd = &np.m_Left;
                np = np.m_Left;
            }
            else if (node.m_FingerPrint > np.m_FingerPrint)
            {
                nd = &np.m_Right;
                np = np.m_Right;
            }
            else if (np.m_Name == null)
            {
                nd = &np.m_Right;
                np = np.m_Right;
            }
            else
            {
                int comp = Posix.strncmp (node.m_Name, np.m_Name, len);
                if ((comp < 0) || ((comp == 0) && (len < (long)np.m_Name.length)))
                {
                    nd = &np.m_Left;
                    np = np.m_Left;
                }
                else if (comp > 0)
                {
                    nd = &np.m_Right;
                    np = np.m_Right;
                }
                else
                {
                    return np.m_Pos;
                }
            }
        }

        if (s_AtomTable == null)
        {
            s_AtomTable = new Node[100];
        }

        if (s_LastAtom + 1 >= s_AtomTable.length)
        {
            s_AtomTable.resize (s_LastAtom * 2);
        }

        s_LastAtom++;
        node.m_Pos = s_LastAtom;
        s_AtomTable [s_LastAtom] = node;
        *(Node**)nd = (Node*)s_AtomTable+s_LastAtom;

        return node.m_Pos;
    }

    public static uint32
    from_uint (uint inValue)
    {
        Node node = Node.from_finger_print (inValue);

        unowned Node? np = s_Root;
        void* nd = &s_Root;
        while (np != null)
        {
            if (node.m_FingerPrint < np.m_FingerPrint)
            {
                nd = &np.m_Left;
                np = np.m_Left;
            }
            else if (node.m_FingerPrint > np.m_FingerPrint)
            {
                nd = &np.m_Right;
                np = np.m_Right;
            }
            else if (node.m_FingerPrint == np.m_FingerPrint)
            {
                if (np.m_Name != null)
                {
                    nd = &np.m_Left;
                    np = np.m_Left;
                }
                else
                {
                    return np.m_Pos;
                }
            }
        }

        if (s_AtomTable == null)
        {
            s_AtomTable = new Node[100];
        }

        if (s_LastAtom + 1 >= s_AtomTable.length)
        {
            s_AtomTable.resize (s_LastAtom * 2);
        }

        s_LastAtom++;
        node.m_Pos = s_LastAtom;
        s_AtomTable [s_LastAtom] = node;
        *(Node**)nd = (Node*)s_AtomTable+s_LastAtom;

        return node.m_Pos;
    }

    public unowned string?
    to_string (uint32 inAtom)
    {
        return s_AtomTable != null && inAtom <= s_LastAtom ? s_AtomTable[inAtom].m_Name : null;
    }

    public uint
    to_uint (uint32 inAtom)
    {
        return s_AtomTable != null && inAtom <= s_LastAtom ? s_AtomTable[inAtom].m_FingerPrint : 0;
    }
}