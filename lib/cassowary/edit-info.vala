/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * edit-info.vala
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

internal class Maia.Cassowary.EditInfo : Core.Object
{
    // properties
    private Constraint    m_Constraint;
    private SlackVariable m_EditPlus;
    private SlackVariable m_EditMinus;
    private int           m_Index;

    // accessors
    public int index {
        get {
            return m_Index;
        }
    }

    public Constraint constraint {
        get {
            return m_Constraint;
        }
    }

    public SlackVariable edit_plus {
        get {
            return m_EditPlus;
        }
    }

    public SlackVariable edit_minus {
        get {
            return m_EditMinus;
        }
    }

    public double prev_edit_constant;

    // methods
    public EditInfo (Constraint inConstraint, SlackVariable inEPlus, SlackVariable inEMinus,
                     double inPrevEditConstant, int inIndex)
    {
        m_Constraint = inConstraint;
        m_EditPlus = inEPlus;
        m_EditMinus = inEMinus;
        prev_edit_constant = inPrevEditConstant;
        m_Index = inIndex;
    }
}
