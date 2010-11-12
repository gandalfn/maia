/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-object.vala
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

public abstract class Maia.Object
{
    // Types
    [CCode (has_target = false)]
    public delegate Object CreateFromParameter (GLib.Parameter[] inProperties);
    [CCode (has_target = false)]
    public delegate Object CreateFromString (string inValue);

    private struct CreateVTable
    {
        public CreateFromParameter create_from_paramaters;
        public CreateFromString    create_from_string;

        public CreateVTable (CreateFromParameter? inCreateFromParameters,
                             CreateFromString? inCreateFromString)
        {
            create_from_paramaters = inCreateFromParameters;
            create_from_string = inCreateFromString;
        }
    }

    // Static properties
    static Map<GLib.Type, CreateVTable?> s_Factory = null;

    // Properties
    private string                       m_Id = null;
    private unowned Object               m_Parent = null;
    private Array<Object>                m_Childs = null; 
    private Map<string, unowned Object>  m_IdentifiedChilds = null;

    // Accessors

    /**
     * Object identifier
     */
    public string id {
        get {
            return m_Id;
        }
        set {
            // object have a old id
            if (m_Parent != null && m_Id != null && m_Parent.m_IdentifiedChilds != null)
                // remove object from identified object
                m_Parent.m_IdentifiedChilds.unset (m_Id);

            // set identifier
            m_Id = value;

            // object have a parent
            if (m_Id != null && m_Parent != null)
            {
                m_Parent.create_child_arrays ();
                // add object in identified childs
                m_Parent.m_IdentifiedChilds[m_Id] = this;
            }
        }
    }

    /**
     * Object parent
     */
    public Object parent {
        get {
            return m_Parent;
        }
        set {
            // object have already a parent
            if (m_Parent != null && m_Parent.m_Childs != null)
            {
                // remove object from childs of old parent
                m_Parent.m_Childs.remove (this);
                // remove object from identified childs of old parent
                if (m_Id != null && m_Parent.m_IdentifiedChilds != null)
                    m_Parent.m_IdentifiedChilds.unset (m_Id);
            }

            // set parent property
            m_Parent = value;

            // add object to childs of parent
            if (m_Parent != null)
            {
                m_Parent.create_child_arrays ();
                m_Parent.m_Childs.insert (this);
                if (m_Id != null)
                    m_Parent.m_IdentifiedChilds[m_Id] = this;
            }
        }
    }

    /**
     * Object childs
     */
    public Array<Object> childs {
        get {
            create_child_arrays ();
            return m_Childs;
        }
    }

    static void
    object_to_string (GLib.Value inSrc, out GLib.Value outDest)
    {
        outDest = ((Object)inSrc).to_string ();
    }

    static void
    string_to_object (GLib.Value inSrc, out GLib.Value outDest)
    {
        if (s_Factory != null)
        {
            CreateVTable? vtable = s_Factory[outDest.get_gtype()];

            if (vtable != null)
            {
                outDest = vtable.create_from_string ((string)inSrc);
            }
        }
    }

    protected Object (string? inId = null, Object? inParent = null)
    {
        // Set properties
        if (inId != null) id = inId;
        if (inParent != null) parent = inParent;
    }

    private void
    create_child_arrays ()
    {
        if (m_Childs == null)
            m_Childs = new Array <Object> ();

        if (m_IdentifiedChilds == null)
            m_IdentifiedChilds = new Map<string, unowned Object> ();
    }

    /**
     * Determines whether this object contains the object identified by inId.
     *
     * @param inId the object id to locate in this object
     *
     * @return true if object is found, false otherwise
     */
    public bool
    contains (string inId)
    {
        return inId in m_IdentifiedChilds;
    }

    /**
     * Returns the object of the specified id in this object.
     *
     * @param inId the id whose object is to be retrieved
     *
     * @return the object associated with the id, or null if the id
     *         couldn't be found
     */
    public Object
    get_child (string inId)
    {
        return m_IdentifiedChilds[inId];
    }

    /**
     * Returns string representation of object
     *
     * @return string representation of object
     */
    public virtual string
    to_string ()
    {
        return m_Id;
    }

    /**
     * Check if an object equals this object 
     *
     * @param inOther the object to compare to
     *
     * @return true if object are same
     */
    public virtual bool
    equals (Object inOther)
    {
        return inOther == this;
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
        return (void*)this > (void*)inOther ? 1 : ((void*)this < (void*)inOther ? -1 : 0);
    }

    /**
     * Register a create function for a specified type. The function can be
     * called multiple time but only first call is really effective
     *
     * @param inType type to register
     * @param inFromParameters create function with parameters
     * @param inFromString create function with string (optional)
     */
    public static void
    register (GLib.Type inType, CreateFromParameter inFromParameters, CreateFromString? inFromString = null)
    {
        if (s_Factory == null)
            s_Factory = new Map<GLib.Type, CreateVTable?> ();

        CreateVTable? vtable = s_Factory[inType];

        if (vtable == null)
        {
            s_Factory[inType] = CreateVTable (inFromParameters, inFromString);

            if (inFromString != null)
            {
                GLib.Value.register_transform_func (typeof (string), inType,
                                                    (ValueTransform)string_to_object);
                GLib.Value.register_transform_func (inType, typeof (string),
                                                    (ValueTransform)object_to_string);
            }
        }
    }

    /**
     * Create a new object for a specified type. The create function must be
     * registered before.
     *
     * @param inType type of object
     * @param inProperties array of properties to pass of creation of object
     *
     * @return Object
     */
    public static Object?
    newv (GLib.Type inType, GLib.Parameter[] inProperties)
    {
        Object result = null;

        if (s_Factory != null)
        {
            CreateVTable? vtable = s_Factory[inType];

            if (vtable != null)
                result = vtable.create_from_paramaters (inProperties);
        }

        return result;
    }
}