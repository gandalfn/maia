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
    public delegate Object CreateFromString (string inContent);

    private struct CreateVTable
    {
        public GLib.Type           m_Type;
        public CreateFromParameter m_FromParameters;
        public CreateFromString    m_FromString;
    }

    // Static properties
    static CreateVTable*                            s_Factory = null;
    static int                                      s_FactoryLength = 0;

    // Properties
    private string                                  m_Id = null;
    private unowned Object                          m_Parent = null;
    private List<Object>                            m_Childs = null; 
    private Vala.HashMap<string, unowned Object>    m_IdentifiedChilds = null;

    /**
     * Object identifier
     */
    public string id {
        get {
            return m_Id;
        }
        protected set {
            // object have a old id
            if (m_Parent != null && m_Id != null && m_Parent.m_IdentifiedChilds != null)
            {
                // remove object from identified object
                m_Parent.m_IdentifiedChilds.remove (m_Id);
            }

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
        protected set {
            // object have already a parent
            if (m_Parent != null && m_Parent.m_Childs != null)
            {
                // remove object from childs of old parent
                m_Parent.m_Childs.remove (this);
                // remove object from identified childs of old parent
                if (m_Id != null && m_Parent.m_IdentifiedChilds != null)
                {
                    m_Parent.m_IdentifiedChilds.remove (m_Id);
                }
            }

            // set parent property
            m_Parent = value;

            // add object to childs of parent
            if (m_Parent != null)
            {
                m_Parent.create_child_arrays ();
                m_Parent.m_Childs.add (this);
                if (m_Id != null)
                {
                    m_Parent.m_IdentifiedChilds[m_Id] = this;
                }
            }
        }
    }

    /**
     * Object childs
     */
    public List<Object> childs {
        get {
            return m_Childs;
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
        {
            m_Childs = new List <Object> ();
        }
        if (m_IdentifiedChilds == null)
        {
            m_IdentifiedChilds = new Vala.HashMap<string, unowned Object> ();
        }
    }

    private static CreateVTable*
    get_vtable (GLib.Type inType)
    {
        if (s_Factory != null)
        {
            int left = 0, right = s_FactoryLength - 1;

            if (right != -1)
            {
                while (right >= left)
                {
                    int medium = (left + right) / 2;
                    CreateVTable* vtable = &s_Factory[medium];

                    if (inType == vtable->m_Type)
                    {
                        return vtable;
                    }
                    else if (inType < vtable->m_Type)
                    {
                        right = medium - 1;
                    }
                    else
                    {
                        left = medium + 1;
                    }
                }
            }
        }

        return null;
    }

    public bool
    contains (string inId)
    {
        return inId in m_IdentifiedChilds;
    }

    public Object
    get_child (string inId)
    {
        return m_IdentifiedChilds[inId];
    }

    /**
     * Register a create function for a specified type. The function can be
     * called multiple time but only first call is really effective
     *
     * @param inType type to register
     * @param inFunc create function
     */
    public static void
    register (GLib.Type inType, CreateFromParameter? inFromParameters, CreateFromString? inFromString)
    {
        CreateVTable* vtable = get_vtable (inType);

        if (vtable == null)
        {
            int index = s_FactoryLength;

            s_FactoryLength++;
            if (s_Factory == null)
                s_Factory = GLib.Slice.alloc (s_FactoryLength * sizeof (CreateVTable));
            else
                s_Factory = GLib.Slice.copy (s_FactoryLength * sizeof (CreateVTable), s_Factory);

            while (index > 0 && s_Factory[index - 1].m_Type > inType)
            {
                s_Factory[index].m_Type = s_Factory[index - 1].m_Type;
                s_Factory[index].m_FromParameters = s_Factory[index - 1].m_FromParameters;
                s_Factory[index].m_FromString = s_Factory[index - 1].m_FromString;
                index--;
            }

            s_Factory[index].m_Type = inType;
            s_Factory[index].m_FromParameters = inFromParameters;
            s_Factory[index].m_FromString = inFromString;
        }
    }

    /**
     * Create a new object for a specified type. The create function must be
     * registered before.
     *
     * @param inType type of object
     * @param inProperties array of properties to pass of creation of object
     */
    public static Object
    newv (GLib.Type inType, GLib.Parameter[] inProperties)
    {
        Object result = null;
        CreateVTable* vtable = get_vtable (inType);

        if (vtable != null && vtable->m_FromParameters != null)
        {
            result = vtable->m_FromParameters (inProperties);
        }

        return result;
    }

    /**
     * Create a new object for a specified type. The create function must be
     * registered before.
     *
     * @param inType type of object
     * @param inContent string content to pass of creation of object
     */
    public static Object
    news (GLib.Type inType, string inContent)
    {
        Object result = null;
        CreateVTable* vtable = get_vtable (inType);

        if (vtable != null && vtable->m_FromString != null)
        {
            result = vtable->m_FromString (inContent);
        }

        return result;
    }
}