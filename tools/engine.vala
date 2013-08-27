/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * engine.vala
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

[Flags]
public enum CanvasEditor.EngineFlags
{
    TEXT            = 0,
    COMMENT         = 1 << 0,
    SINGLE_COMMENT  = 1 << 1,
    STRING          = 1 << 2,
    SINGLE_QUOTED   = 1 << 3;

    public inline EngineFlags
    not (EngineFlags inFlags)
    {
        if (test (inFlags))
        {
            return this & ~inFlags;
        }

        return this | inFlags;
    }

    public inline bool
    test (EngineFlags inFlags)
    {
        return (this & inFlags) == inFlags;
    }
}

public class CanvasEditor.Engine : GLib.Object
{
    // constants
    const char[] c_Stoppers = {'\n', '>', '<', ':', ' ', '.', ';', '\t', '(', ')', ',', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '"', '\'', '&', '|', '{', '}' };

    // properties
    private Maia.Core.Set<string> m_Words = null;
    private EngineFlags m_Flags = EngineFlags.TEXT;

    // methods
    public Engine ()
    {
        m_Words = new Maia.Core.Set<string> ();
    }

    private void
    parse_text (string inText)
    {
        string current_word = "";
        for (int cpt = 0; cpt < inText.length; cpt++)
        {
            var text_char = inText[cpt];
            if (text_char in c_Stoppers)
            {
                if (text_char == '\n')
                    m_Flags &= ~EngineFlags.SINGLE_COMMENT;

                if (current_word != "")
                {
                    parse_word (current_word);
                    current_word = "";
                }
                if (text_char == '\'' && !m_Flags.test (EngineFlags.COMMENT))
                    m_Flags = m_Flags.not (EngineFlags.SINGLE_QUOTED);
                if (text_char == '"' && !m_Flags.test (EngineFlags.COMMENT))
                    m_Flags = m_Flags.not (EngineFlags.STRING);
            }
            else
                current_word += text_char.to_string ();
        }
    }

    private void
    parse_word (string inWord)
    {
        if (inWord.has_prefix ("//") && !m_Flags.test (EngineFlags.COMMENT))
            m_Flags |= EngineFlags.SINGLE_COMMENT;

        if (inWord.contains ("/*"))
            m_Flags |= EngineFlags.COMMENT;

        if (inWord.contains ("*/"))
        {
            m_Flags &= ~EngineFlags.COMMENT;
            return;
        }

        if (m_Flags != EngineFlags.TEXT)
            return;

        lock (m_Words)
        {
            m_Words.insert (inWord);
        }
    }

    public GLib.List<string>
    find (string inToFind)
    {
        GLib.List<string> list = new GLib.List<string> ();

        lock (m_Words)
        {
            foreach (var word in m_Words)
            {
                if (word.length > inToFind.length &&
                    (word.slice (0, inToFind.length) == inToFind ||
                     word.down().slice (0, inToFind.length) == inToFind.down ()))
                {
                    list.prepend (word);
                }
            }
        }
        return list;
    }


    public void
    parse (string inText)
    {
        lock (m_Words)
        {
            m_Words.clear ();

            parse_text (inText);
        }
    }
}
