/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-tree.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public class Maia.Tree<K, T>
{
    // Types
    private class Node<K, T>
    {
        public K                    m_Key;
        public T                    m_Data;
        public unowned Node<K, T>?  m_Parent;
        public Node<K, T>?          m_Right;
        public Node<K, T>?          m_Left;

        public Node (owned K inKey, owned T inData, Node<K, T>? inParent = null)
        {
            m_Key = (owned)inKey;
            m_Data = (owned)inData;
            m_Parent = inParent;
            m_Right = null;
            m_Left = null;
        }
    }

    // Properties
    private Node<K, T>?      m_Root = null;
    private GLib.CompareFunc m_CompareFunc = null;

    /**
     * The elements compare testing function.
     */
    public GLib.CompareFunc compare_func {
        get {
            return m_CompareFunc;
        }
    }

    public class Tree (GLib.CompareFunc inFunc)
    {
        m_CompareFunc = inFunc;
    }

    private unowned Node<K, T>?
    get_node (K inKey, out unowned Node<K, T>? outParent = null)
    {
        unowned Node<K, T> node = m_Root;

        while (node != null)
        {
            outParent = node;

            int res = m_CompareFunc (inKey, node.m_Key);
            if (res > 0)
            {
                node = node.m_Right;
            }
            else if (res < 0)
            {
                node = node.m_Left;
            }
            else
            {
                return node;
            }
        }

        return null;
    }

    private int
    node_depth (Node<K, T>? inNode)
    {
        if (inNode == null)
            return 0;

        int left_depth = node_depth (inNode.m_Left);
        int right_depth = node_depth (inNode.m_Right);

        return 1 + ((left_depth > right_depth) ? left_depth : right_depth);
    }

    private void
    rotate_left (owned Node<K, T> inNode)
    {
        if (inNode == null)
            return;

        Node<K, T> pivot = inNode.m_Right;
        if (inNode.m_Parent != null)
        {
            if (inNode.m_Parent.m_Right == inNode)
                inNode.m_Parent.m_Right = pivot;
            else
                inNode.m_Parent.m_Left = pivot;
        }
        pivot.m_Parent = inNode.m_Parent;

        if (pivot.m_Left != null)
            pivot.m_Left.m_Parent = inNode;
        inNode.m_Right = pivot.m_Left;

        inNode.m_Parent = pivot;
        pivot.m_Left = (owned)inNode;
        if (pivot.m_Left == m_Root)
            m_Root = pivot;
    }

    private void
    rotate_right (owned Node<K, T>? inNode)
    {
        if (inNode == null)
            return;

        Node<K, T> pivot = inNode.m_Left;
        if (inNode.m_Parent != null)
        {
            if (inNode.m_Parent.m_Left == inNode)
                inNode.m_Parent.m_Left = pivot;
            else
                inNode.m_Parent.m_Right = pivot;
        }
        pivot.m_Parent = inNode.m_Parent;

        if (pivot.m_Right != null)
            pivot.m_Right.m_Parent = inNode;
        inNode.m_Left = pivot.m_Right;

        inNode.m_Parent = pivot;
        pivot.m_Right = (owned)inNode;
        if (pivot.m_Right == m_Root)
            m_Root = pivot;
    }

    private void
    balance (Node<K, T>? inNode)
    {
        if (inNode == null)
            return;

        int root = node_depth(inNode.m_Right) - node_depth(inNode.m_Left);
        if (root == 2)
        {
            int right = node_depth(inNode.m_Right.m_Right) - node_depth(inNode.m_Right.m_Left);
            if (right == -1)
                rotate_right (inNode.m_Right);
            rotate_left (inNode);
        }
        else if (root == -2)
        {
            int left = node_depth(inNode.m_Left.m_Right) - node_depth(inNode.m_Left.m_Left);
            if (left == 1)
                rotate_left (inNode.m_Left);
            rotate_right (inNode);
        }

        balance (inNode.m_Parent);
    }

    public new unowned T?
    @get (K inKey)
    {
        unowned Node<K, T> node = get_node (inKey);

        return node == null ? null : node.m_Data;
    }

    public void
    @set (K inKey, T inData)
    {
        unowned Node<K, T> parent = null;
        Node<K, T> node = get_node (inKey, out parent);

        if (node == null)
        {
            node = new Node<K, T> (inKey, inData, parent);

            if (parent == null)
            {
                m_Root = node;
            }
            else if (m_CompareFunc (inKey, parent.m_Key) > 0)
            {
                parent.m_Right = node;
            }
            else
            {
                parent.m_Left = node;
            }

            balance (node);
        }
        else
        {
            node.m_Data = inData;
        }
    }
}