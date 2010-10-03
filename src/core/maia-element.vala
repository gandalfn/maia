/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-element.vala
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

public abstract class Maia.Element : Object
{
    /**
     * Element identifier
     */
    public uint32 id { get; protected set; default = 0; }

    /**
     * Parent element if any of this element
     */
    public virtual Element parent { get; protected set; default = null; }

    /**
     * Indicate if element is visible
     */
    public virtual bool visible { get; set; default = false; }

    /**
     * Element geometry
     */
    private Region m_Geometry = null;
    public virtual Region geometry {
        get {
            return m_Geometry;
        }
        protected set {
            m_Geometry = value;
            geometry_changed ();
        }
    }

    /**
     * Element opaque region 
     */
    public virtual Region opaque { get; protected set; default = null; }

    /**
     * Element transformation
     */
    public virtual Transform transform { get; protected set; default = new Transform.identity (); }

    /**
     * Geometry changed event
     */
    public signal void geometry_changed ();

    /**
     * Check if elements are same
     *
     * @param inElement element to compare to
     *
     * @return `true` if elements are same
     */
    public bool 
    equal (Element inElement)
    {
        return id == inElement.id;
    }
}
