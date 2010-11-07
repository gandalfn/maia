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

public class Maia.Tree<K, V> : Vala.Iterable <V>
{
    public delegate string ToStringFunc (void* inData);

    // Types
    private class Node<K, V>
    {
        // Properties
        private unowned Node<K, V>?  m_Parent;
        private Node<K, V>?          m_Right;
        private Node<K, V>?          m_Left;
        private int                  m_Depth;

        public K                     key;
        public V                     val;

        public Node<K, V> parent {
            get {
                return m_Parent;
            }
            set {
                m_Parent = value;

                calc_depth ();
            }
        }

        public Node<K, V> left {
            get {
                return m_Left;
            }
            set {
                m_Left = value;

                calc_depth ();
            }
        }

        public Node<K, V> right {
            get {
                return m_Right;
            }
            set {
                m_Right = value;

                calc_depth ();
            }
        }

        public int balance_factor {
            get {
                int right_depth = m_Right != null ? m_Right.m_Depth : 0;
                int left_depth = m_Left != null ? m_Left.m_Depth : 0;
                
                return right_depth - left_depth;
            }
        }

        public Node (owned K inKey, owned V? inValue, Node<K, V>? inParent = null)
        {
            key = (owned)inKey;
            val = inValue != null ? (owned)inValue : null;
            m_Depth = 1;
            right = null;
            left = null;
            parent = inParent;
        }

        private void
        calc_depth ()
        {
            int right_depth = m_Right != null ? m_Right.m_Depth : 0;
            int left_depth = m_Left != null ? m_Left.m_Depth : 0;

            m_Depth = int.max(right_depth, left_depth) + 1;

            if (m_Parent != null) m_Parent.calc_depth ();
        }

        public bool
        is_left ()
        {
            return m_Parent != null && m_Parent.m_Left == this;
        }

        public unowned Node<K, V>
        next ()
        {
            unowned Node<K, V> node = null;

            if (m_Right != null)
            {
                node = m_Right;
                while (node.m_Left != null)
                    node = node.m_Left;
            }
            else
            {
                if (is_left ())
                {
                    node = m_Parent;
                }
                else if (m_Parent != null)
                {
                    Node<K, V> r = (owned)m_Parent.m_Right;
                    m_Parent.m_Right = null;
                    node = m_Parent.next ();
                    m_Parent.m_Right = r;
                }
            }

            return node;
        }
    }

    private class Iterator<K, V> : Vala.Iterator <V>
    {
        private Tree<K, V> m_Tree;
        private unowned Node<K, V> m_Current;

        internal Iterator (Tree<K, V> inTree)
        {
            m_Tree = inTree;
            m_Current = null;
        }

        public override bool
        next ()
        {
            bool ret = false;

            if (m_Current == null && m_Tree.m_Root != null)
            {
                m_Current = m_Tree.m_Root;

                while (m_Current.left != null)
                    m_Current = m_Current.left;

                ret = true;
            }
            else if (m_Current != null)
            {
                m_Current = m_Current.next ();
                ret = m_Current != null;
            }

            return ret;
        }

        public override V?
        @get ()
        {
            return m_Current.val;
        }
    }

    // Properties
    private int                  m_Size = 0;
    private Node<K, V>?          m_Root = null;
    private GLib.CompareDataFunc m_CompareFunc = null;
    private ToStringFunc         m_ToStringFunc = null;

    public int nb_items {
        get {
            return m_Size;
        }
    }

    /**
     * The elements compare testing function.
     */
    public GLib.CompareDataFunc compare_func {
        get {
            return m_CompareFunc;
        }
    }

    public class Tree (GLib.CompareDataFunc inFunc, ToStringFunc? inToStringFunc = null)
    {
        m_CompareFunc = inFunc;
        m_ToStringFunc = inToStringFunc;
    }

    private unowned Node<K, V>?
    get_node (K inKey, out unowned Node<K, V>? outParent = null)
    {
        unowned Node<K, V> node = m_Root;

        while (node != null)
        {
            outParent = node;

            int res = m_CompareFunc (inKey, node.key);
            if (res > 0)
            {
                node = node.right;
            }
            else if (res < 0)
            {
                node = node.left;
            }
            else
            {
                return node;
            }
        }

        return null;
    }

    private void
    rotate_left (owned Node<K, V> inNode)
    {
        if (inNode == null)
            return;

        Node<K, V> pivot = inNode.right;
        if (inNode.parent != null)
        {
            if (inNode.parent.right == inNode)
                inNode.parent.right = pivot;
            else
                inNode.parent.left = pivot;
        }
        pivot.parent = inNode.parent;

        if (pivot.left != null)
            pivot.left.parent = inNode;
        inNode.right = pivot.left;

        inNode.parent = pivot;
        pivot.left = (owned)inNode;
        if (pivot.left == m_Root)
            m_Root = pivot;
    }

    private void
    rotate_right (owned Node<K, V>? inNode)
    {
        if (inNode == null)
            return;

        Node<K, V> pivot = inNode.left;
        if (inNode.parent != null)
        {
            if (inNode.parent.left == inNode)
                inNode.parent.left = pivot;
            else
                inNode.parent.right = pivot;
        }
        pivot.parent = inNode.parent;

        if (pivot.right != null)
            pivot.right.parent = inNode;
        inNode.left = pivot.right;

        inNode.parent = pivot;
        pivot.right = (owned)inNode;
        if (pivot.right == m_Root)
            m_Root = pivot;
    }

    private void
    balance (Node<K, V>? inNode)
    {
        if (inNode == null)
            return;

        int factor = inNode.balance_factor;
        if (factor == 2)
        {
            int right = inNode.right.balance_factor;
            if (right == -1)
                rotate_right (inNode.right);
            rotate_left (inNode);
        }
        else if (factor == -2)
        {
            int left = inNode.left.balance_factor;
            if (left == 1)
                rotate_left (inNode.left);
            rotate_right (inNode);
        }

        balance (inNode.parent);
    }

    private string
    node_to_string (Node<K, V>? inNode)
    {
        string str = ";\n";
        if (inNode != null)
        {
            string left = "", right = "";
            string data = "\"" + m_ToStringFunc (inNode.val) + "\"";
            str = node_to_string (inNode.left);
            left = data + (str != ";\n" ? " -- " + str : str);
            str = node_to_string (inNode.right);
            right = data + (str != ";\n" ? " -- " + str : str);
            str = left + " " + right;
        }

        return str;
    }

    /**
     * Determines whether this tree contains the specified key.
     *
     * @param inKey the key to locate in the tree
     *
     * @return true if key is found, false otherwise
     */
    public bool
    contains (K inKey)
    {
        return get_node (inKey) != null;
    }

    /**
     * Returns the value of the specified key in this tree.
     *
     * @param inKey the key whose value is to be retrieved
     *
     * @return the value associated with the key, or null if the key
     *         couldn't be found
     */
    public new unowned V?
    @get (K inKey)
    {
        unowned Node<K, V> node = get_node (inKey);

        return node == null ? null : node.val;
    }

    /**
     * Inserts a new key and value into this tree.
     *
     * @param inKey the key to insert
     * @param inValue the value to associate with the key
     */
    public virtual void
    @set (K inKey, V inValue)
    {
        unowned Node<K, V> parent = null;
        Node<K, V> node = get_node (inKey, out parent);

        if (node == null)
        {
            node = new Node<K, V> (inKey, inValue, parent);

            if (parent == null)
            {
                m_Root = node;
            }
            else if (m_CompareFunc (inKey, parent.key) > 0)
            {
                parent.right = node;
            }
            else
            {
                parent.left = node;
            }

            balance (node);

            m_Size++;
        }
        else
        {
            node.val = inValue;
        }
    }

    /**
     * Removes the specified key from this tree.
     *
     * @param inKey the key to remove from the tree
     */
    public virtual void
    unset (K inKey)
    {
        unowned Node<K, V> node = get_node (inKey);

        if (node != null)
        {
            unowned Node<K, V> parent = node.parent;
            unowned Node<K, V> replace = node.left;
            if (replace != null)
            {
                while (replace.right != null)
                    replace = replace.right;
            }

            if (replace == null)
            {
                if (node.right != null)
                    node.right.parent = node.parent;

                if (node == m_Root)
                    m_Root = node.right;
                else if (node.parent.left == node)
                    node.parent.left = node.right;
                else
                    node.parent.right = node.right;
            }
            else
            {
                node.key = replace.key;
                node.val = replace.val;

                if (replace.left != null)
                    replace.left.parent = replace.parent;

                if (replace.parent.left == replace)
                    replace.parent.left = replace.left;
                else
                    replace.parent.right = replace.left;
            }

            balance (parent);

            m_Size--;
        }
    }

    /**
     * Removes all items from this tree.
     */
    public void
    clear ()
    {
        m_Root = null;
        m_Size = 0;
    }

    /**
     * Return dot representation of the tree
     */
    public string
    to_dot ()
    {
        return "graph graphname {\n " + node_to_string (m_Root) + "}";
    }

    /**
     * {@inheritDoc}
     */
    public override Type
    get_element_type ()
    {
        return typeof (V);
    }

    /**
     * {@inheritDoc}
     */
    public override Vala.Iterator<V>
    iterator ()
    {
        return new Iterator<K, V> (this);
    }
}