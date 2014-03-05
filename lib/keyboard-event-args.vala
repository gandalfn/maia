/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * keyboard-event-args.vala
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

public class Maia.KeyboardEventArgs : Maia.Core.EventArgs
{
    // type
    public enum State
    {
        INVALID,
        PRESS,
        RELEASE
    }

    // properties
    private State    m_State;
    private Modifier m_Modifier;
    private Key      m_Key;
    private unichar  m_Character;

    // accessors
    public override GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(yyuu)", m_State, m_Modifier, m_Key, m_Character);
        }
        set {
            if (value != null)
            {
                value.get ("(yyuu)", out m_State, out m_Modifier, out m_Key, out m_Character);
            }
            else
            {
                m_State = State.INVALID;
                m_Modifier = Modifier.NONE;
                m_Key = Key.VoidSymbol;
                m_Character = 0;
            }
        }
    }

    public State state {
        get {
            return m_State;
        }
    }

    public Modifier modifier {
        get {
            return m_Modifier;
        }
    }

    public Key key {
        get {
            return m_Key;
        }
    }

    public unichar character {
        get {
            return m_Character;
        }
    }

    // methods
    public KeyboardEventArgs (State inState, Modifier inModifier, Key inKey, unichar inChar)
    {
        base ();

        m_State = inState;
        m_Modifier = inModifier;
        m_Key = inKey;
        m_Character = inChar;
    }
}
