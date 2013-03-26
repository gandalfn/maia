/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * attribute.vala
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

public class Maia.Manifest.Attribute : Object
{
    // Properties
    private string m_Value;

    /**
     * Create a new attribute
     *
     * @param inValue attribute value
     */
    public Attribute (string inValue)
    {
        m_Value = inValue;
    }

    /**
     * Get the attribute value
     *
     * @return attribute value
     */
    public new string
    get ()
    {
        return m_Value;
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    can_append_child (Object inChild)
    {
        return inChild is Attribute;
    }

    /**
     * {@inheritDoc}
     */
    public override int
    compare (Object inObject)
    {
        // do not sort child attributes
        return 0;
    }
}
