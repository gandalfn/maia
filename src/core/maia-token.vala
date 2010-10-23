/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-token.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
 * 
 * libmaia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maiawm is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public abstract class Maia.Token : Object
{
    private string m_Id = null;
    private Token m_Parent = null;

    /**
     * Token identifier
     */
    public string id {
        get {
            return m_Id;
        }
    }

    /**
     * Parent token
     */
    public Token parent {
        get {
            return m_Parent;
        }
    }

    /**
     * Create a new token
     *
     * @param inId token identifier
     * @param inParent parent token
     */
    public Token (string inId, Token? inParent)
    {
        m_Id = inId;
        m_Parent = inParent;
    }
}