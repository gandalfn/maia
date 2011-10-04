/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * set.vala
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

public class Maia.Set<V> : Collection<V>
{
    // Types
    private class Node<V>
    {
        // Properties
        private unowned Node<V>?     m_Parent;
        private Node<V>?             m_Right;
        private Node<V>?             m_Left;
        private int                  m_Depth;

        public V                     val;

        public Node<V> parent {
            get {
                return m_Parent;
            }
            set {
                m_Parent = value;

                calc_depth ();
            }
        }

        public Node<V> left {
            get {
                return m_Left;
            }
            set {
                m_Left = value;

                calc_depth ();
            }
        }

        public Node<V> right {
            get {
                return m_Right;
            }
            set {
                m_Right = value;

                calc_depth ();
            }
        }

        public Node (owned V inValue, Node<V>? inParent = null)
        {
            val = (owned)inValue;
            m_Depth = 1;
            right = null;
            left = null;
            parent = inParent;
        }

        private inline void
        calc_depth ()
        {
            int right_depth = m_Right != null ? m_Right.m_Depth : 0;
            int left_depth = m_Left != null ? m_Left.m_Depth : 0;

            m_Depth = int.max(right_depth, left_depth) + 1;

            if (m_Parent != null) m_Parent.calc_depth ();
        }

        public inline int
        balance_factor ()
        {
            int right_depth = m_Right != null ? m_Right.m_Depth : 0;
            int left_depth = m_Left != null ? m_Left.m_Depth : 0;

            return right_depth - left_depth;
        }

        public inline bool
        is_left ()
        {
            return m_Parent != null && m_Parent.m_Left == this;
        }

        public unowned Node<V>
        next ()
        {
            unowned Node<V> node = null;

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
                    Node<V> r = (owned)m_Parent.m_Right;
                    m_Parent.m_Right = null;
                    node = m_Parent.next ();
                    m_Parent.m_Right = r;
                }
            }

            return node;
        }
    }

    private class Iterator<V> : Maia.Iterator<V>
    {
        private Set<V>          m_Set;
        private unowned Node<V> m_Current;

        internal unowned Node<V> current {
            get {
                return m_Current;
            }
        }

        internal Iterator (Set<V>? inSet, Node<V>? inNode = null)
        {
            m_Set = inSet;
            m_Current = inNode;
            stamp = m_Set.stamp;
        }

        /**
         * {@inheritDoc}
         */
        internal override bool
        next ()
            requires (m_Set.stamp == stamp)
        {
            bool ret = false;

            if (m_Current == null && m_Set.m_Root != null)
            {
                m_Current = m_Set.m_Root;

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

        /**
         * {@inheritDoc}
         */
        internal override unowned V?
        @get ()
            requires (m_Set.stamp == stamp)
        {
            return m_Current.val;
        }

        /**
         * {@inheritDoc}
         */
        internal override void
        @foreach (ForeachFunc<V> inFunc)
        {
            if (m_Current == null && m_Set.m_Root != null)
            {
                m_Current = m_Set.m_Root;

                while (m_Current.left != null)
                    m_Current = m_Current.left;
            }

            for (;m_Current != null; m_Current = m_Current.next ())
            {
                if (!inFunc (m_Current.val))
                    return;
            }
        }
    }

    // Properties
    private int                  m_Size = 0;
    private Node<V>?             m_Root = null;

    /**
     * {@inheritDoc}
     */
    internal override int length {
        get {
            return m_Size;
        }
    }

    private unowned Node<V>?
    get_node (V inValue, out unowned Node<V>? outParent = null)
    {
        unowned Node<V> node = m_Root;
        CompareFunc<V> func = compare_func;

        while (node != null)
        {
            outParent = node;

            int res = func (inValue, node.val);
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
    remove_node (Node<V> inNode)
    {
        unowned Node<V> parent = inNode.parent;
        unowned Node<V> replace = inNode.left;
        if (replace != null)
        {
            while (replace.right != null)
                replace = replace.right;
        }

        if (replace == null)
        {
            if (inNode.right != null)
                inNode.right.parent = inNode.parent;

            if (inNode == m_Root)
                m_Root = inNode.right;
            else if (inNode.parent.left == inNode)
                inNode.parent.left = inNode.right;
            else
                inNode.parent.right = inNode.right;
        }
        else
        {
            inNode.val = replace.val;

            if (replace.left != null)
                replace.left.parent = replace.parent;

            if (replace.parent.left == replace)
                replace.parent.left = replace.left;
            else
                replace.parent.right = replace.left;
        }

        balance (parent);

        m_Size--;

        stamp++;
    }

    private void
    rotate_left (owned Node<V> inNode)
    {
        if (inNode == null)
            return;

        Node<V> pivot = inNode.right;
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
    rotate_right (owned Node<V>? inNode)
    {
        if (inNode == null)
            return;

        Node<V> pivot = inNode.left;
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
    balance (Node<V>? inNode)
    {
        if (inNode == null)
            return;

        int factor = inNode.balance_factor ();
        if (factor == 2)
        {
            int right = inNode.right.balance_factor ();
            if (right == -1)
                rotate_right (inNode.right);
            rotate_left (inNode);
        }
        else if (factor == -2)
        {
            int left = inNode.left.balance_factor ();
            if (left == 1)
                rotate_left (inNode.left);
            rotate_right (inNode);
        }

        balance (inNode.parent);
    }

    private string
    node_to_string (Node<V>? inNode)
    {
        string str = ";\n";
        if (inNode != null)
        {
            string left = "", right = "";
            string data = "\"" + to_string_func (inNode.val) + "\"";
            str = node_to_string (inNode.left);
            left = data + (str != ";\n" ? " -- " + str : str);
            str = node_to_string (inNode.right);
            right = data + (str != ";\n" ? " -- " + str : str);
            str = left + " " + right;
        }

        return str;
    }

    internal inline override unowned V?
    search<A> (A inValue, ValueCompareFunc<V, A> inFunc)
    {
        unowned Node<V> node = m_Root;
        int res;

        while (node != null)
        {
            res = inFunc (node.val, inValue);
            if (res < 0)
            {
                node = node.right;
            }
            else if (res > 0)
            {
                node = node.left;
            }
            else
            {
                return node.val;
            }
        }

        return null;
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    insert (V inValue)
    {
        unowned Node<V> parent = null;
        Node<V> node = get_node (inValue, out parent);

        if (node == null)
        {
            node = new Node<V> (inValue, parent);

            if (parent == null)
            {
                m_Root = node;
            }
            else if (compare_func (inValue, parent.val) > 0)
            {
                parent.right = node;
            }
            else
            {
                parent.left = node;
            }

            balance (node);

            m_Size++;

            stamp++;
        }
        else
        {
            node.val = inValue;
        }
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    remove (V inValue)
    {
        unowned Node<V> node = get_node (inValue);

        if (node != null) remove_node (node);
    }

    /**
     * Returns the iterator of the specified value in this set.
     *
     * @param inValue the value whose iterator is to be retrieved
     *
     * @return the iterator associated with the value, or null if the value
     *         couldn't be found
     */
    public new Maia.Iterator<V>
    @get (V inValue)
    {
        unowned Node<V> node = get_node (inValue);
        Maia.Iterator<V> iterator = null;

        if (node != null)
        {
            iterator = new Iterator<V> (this, node);
        }

        return iterator;
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    contains (V inValue)
    {
        return get_node (inValue) != null;
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    clear ()
    {
        while (m_Root != null)
            remove_node (m_Root);
        m_Root = null;
        m_Size = 0;
    }

    /**
     * Return dot representation of the set
     */
    public string
    to_dot ()
    {
        return "graph graphname {\n " + node_to_string (m_Root) + "}";
    }

    /**
     * {@inheritDoc}
     */
    internal override Maia.Iterator<V>
    iterator ()
    {
        return new Iterator<V> (this);
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    erase (Maia.Iterator<V> inIterator)
        requires (inIterator is Iterator<V>)
        requires (inIterator.stamp == stamp)
    {
        Iterator<V> iterator = inIterator as Iterator<V>;

        remove_node (iterator.current);
    }
}
