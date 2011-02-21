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

            int len = inName.length;
            char* str = (char*)inName;
            for (int cpt = 0; cpt < (len + 1) / 2; ++cpt)
            {
                m_FingerPrint = m_FingerPrint * 27 + str[cpt];
                m_FingerPrint = m_FingerPrint * 27 + str[len - 1 - cpt];
            }
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
    static unowned Node? s_Root = null;
    static Node[]        s_AtomTable = null;
    static int           s_LastAtom = 0;

    // static methods
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
            char* o = (char*)s_AtomTable;
            int l = s_AtomTable.length;
            s_AtomTable.resize (s_LastAtom * 2);
            char* n = (char*)s_AtomTable;
            if (o != n)
            {
                for (int cpt = 0; cpt < l; ++cpt)
                {
                    if (s_AtomTable[cpt].m_Left != null)
                        s_AtomTable[cpt].m_Left = (Node?)((char*)s_AtomTable[cpt].m_Left + (n - o));
                    if (s_AtomTable[cpt].m_Right != null)
                        s_AtomTable[cpt].m_Right = (Node?)((char*)s_AtomTable[cpt].m_Right + (n - o));
                }
                nd = (void*)((char*)nd + (n - o));
                s_Root = (Node?)((Node*)s_AtomTable + 1);
            }
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
}