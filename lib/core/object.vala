/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * object.vala
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

public abstract class Maia.Object : Any
{
    // Types
    public class Iterator
    {
        private unowned Object? m_Current;

        internal Iterator (Object inObject)
        {
            m_Current = inObject.m_Head;
        }

        public unowned Object?
        next_value ()
        {
            unowned Object? ret = m_Current;

            if (m_Current != null)
                m_Current = m_Current.m_Next;

            return ret;
        }

        public unowned Object?
        get ()
        {
            return m_Current;
        }
    }

    // Properties
    private unowned Object? m_Parent;
    private Object?         m_Head;
    private unowned Object? m_Tail;
    private Object?         m_Next;
    private unowned Object? m_Prev;

    // accessors
    /**
     * Object identifier
     */
    public uint32 id { get; construct set; default = 0; }

    /**
     * Object parent
     */
    [CCode (notify = false)]
    public virtual Object parent {
        get {
            return m_Parent;
        }
        construct set {
            if (m_Parent != value)
            {
                ref ();

                // object have already a parent
                if (m_Parent != null)
                    m_Parent.remove_child (this);

                if (value != null)
                    value.insert_child (this);

                unref ();
            }
        }
    }

    // Methods
    ~Object ()
    {
        Log.audit ("Maia.~Object", "destroy %s", get_type ().name ());

        while (m_Head != null)
        {
            m_Head.parent = null;
        }
    }

    /**
     * Insert inObject in child list if can be append
     *
     * @param inObject object to add to childs object
     */
    protected virtual void
    insert_child (Object inObject)
    {
        if (can_append_child (inObject))
        {
            // set parent property
            inObject.m_Parent = this;

            // add object to childs of parent
            Log.debug (GLib.Log.METHOD, "Insert object %s to parent %s",
                       inObject.get_type ().name (), get_type ().name ());

            // child list is empty inset object has first
            if (m_Head == null && m_Tail == null)
            {
                m_Head = inObject;
                m_Head.m_Prev = null;
                m_Head.m_Next = null;
                m_Tail = m_Head;
            }
            // check if child must be inserted has first
            else if (m_Head.compare (inObject) > 0)
            {
                inObject.m_Next = m_Head;
                m_Head.m_Prev = inObject;
                m_Head = inObject;
            }
            else
            {
                // search from tail to head the child position
                unowned Object? found = null;
                for (unowned Object item = m_Tail; item != null; item = item.m_Prev)
                {
                    if (inObject.compare (item) >= 0)
                    {
                        found = item;
                        break;
                    }
                }

                // we found the first sibling object insert after
                if (found != null)
                {
                    if (found == m_Tail) m_Tail = inObject;
                    inObject.m_Prev = found;
                    inObject.m_Next = found.m_Next;
                    if (inObject.m_Next != null) inObject.m_Next.m_Prev = inObject;
                    found.m_Next = inObject;
                }
                // does not found any sibling child add to first position (normally never reached)
                else
                {
                    inObject.m_Next = m_Head;
                    m_Head.m_Prev = inObject;
                    m_Head = inObject;
                }
            }
        }
    }

    /**
     * Remove inObject from child list
     *
     * @param inObject object to remove from childs object
     */
    protected virtual void
    remove_child (Object inObject)
    {
        if (inObject.parent == this)
        {
            Log.debug ("Maia.Object.parent.set", "Remove object %s from parent %s",
                       inObject.get_type ().name (), get_type ().name ());

            unowned Object? next = inObject.m_Next;

            if (inObject == m_Head)
            {
                m_Head = inObject.m_Next;
            }
            else
            {
                inObject.m_Prev.m_Next = inObject.m_Next;
            }

            if (inObject == m_Tail)
            {
                m_Tail = inObject.m_Prev;
            }
            else
            {
                next.m_Prev = inObject.m_Prev;
            }

            inObject.m_Prev = null;
            inObject.m_Next = null;

            // unset parent object
            inObject.m_Parent = null;
        }
    }

    /**
     * Check object position in parent childs array
     */
    public void
    reorder ()
    {
        if (m_Parent != null)
        {
            bool need_reorder = false;
            unowned Object? sibling = null;

            // the child must be move before
            if (m_Prev != null && compare (m_Prev) < 0)
            {
                for (unowned Object item = m_Prev; item != null; item = item.m_Prev)
                {
                    if (item.compare (this) <= 0)
                    {
                        sibling = item;
                        break;
                    }
                }
                need_reorder = true;
            }
            // the child must be move after
            else if (m_Next != null && compare (m_Next) >= 0)
            {
                for (unowned Object item = m_Parent.m_Tail; item != this; item = item.m_Prev)
                {
                    if (item.compare (this) <= 0)
                    {
                        sibling = item;
                        break;
                    }
                }
                need_reorder = true;
            }

            // we need to reorder object
            if (need_reorder)
            {
                ref ();

                unowned Object? next = m_Next;

                // unlink object
                if (this == m_Head)
                {
                    m_Head = m_Next;
                }
                else
                {
                    m_Prev.m_Next = m_Next;
                }

                if (this == m_Tail)
                {
                    m_Tail = m_Prev;
                }
                else
                {
                    next.m_Prev = m_Prev;
                }

                // move child to after sibling
                if (sibling != null)
                {
                    if (sibling == m_Parent.m_Tail) m_Parent.m_Tail = this;
                    m_Prev = sibling;
                    m_Next = sibling.m_Next;
                    if (m_Next != null) m_Next.m_Prev = this;
                    sibling.m_Next = this;
                }
                // add child on head of parent childs
                else
                {
                    m_Next = m_Head;
                    m_Head.m_Prev = this;
                    m_Head = this;
                }

                unref ();
            }
        }
    }

    /**
     * Check if an object can be added to this object
     *
     * @param inChild object child to test
     *
     * @return `true` if the child object can be added to this node,
     *         `false` otherwise
     */
    public virtual bool
    can_append_child (Object inChild)
    {
        return true;
    }

    /**
     * Returns a Iterator that can be used for simple iteration over
     * childs object.
     *
     * @return a Iterator that can be used for simple iteration over childs
     *         object
     */
    public Iterator
    iterator ()
    {
        return new Iterator (this);
    }

    /**
     * Returns string representation of object
     *
     * @return string representation of object
     */
    public virtual string
    to_string ()
    {
        return id.to_string ();
    }

    /**
     * Add child to object
     *
     * @param inObject child to add
     */
    public void
    add (Object inObject)
    {
        inObject.parent = this;
    }

    /**
     * Determines whether this object contains the child object.
     *
     * @param inObject the child object to locate in the object
     *
     * @return true if child is found, false otherwise
     */
    public bool
    contains (Object inObject)
    {
        foreach (unowned Object child in this)
        {
            if (child.compare (inObject) == 0)
                return true;
        }

        return false;
    }

    /**
     * Compare this object with another
     *
     * @param inOther the object to compare to.
     *
     * @return < 0 if this object is lesser then inOther, > 0 if this object is
     *             greater than inObject, 0 otherwise.
     */
    public virtual int
    compare (Object inOther)
    {
        int ret = (int)(id - inOther.id);
        if (ret == 0)
        {
            ret = direct_compare (this, inOther);
        }

        return ret;
    }

    /**
     * Get the first child object
     *
     * @return the first child object else null if object have no child
     */
    public unowned Object?
    first ()
    {
        return m_Head;
    }

    /**
     * Get the last child object
     *
     * @return the last child object else null if object have no child
     */
    public unowned Object?
    last ()
    {
        return m_Tail;
    }
}
