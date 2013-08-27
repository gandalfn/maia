/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * provider.vala
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

public class CanvasEditor.Provider : GLib.Object, Gtk.SourceCompletionProvider
{
    // constants
    public static const unichar[] c_Stoppers = {' ', '\n', '(', ';', '}', '{', '.'};

    // properties
    private unowned Gtk.SourceBuffer m_Buffer;
    private unowned Engine m_Engine;
    private Gtk.TextMark m_CompletionMark;
    private Gdk.Pixbuf m_Icon;
    private string m_Name = "Canvas Word Completion";
    private int m_Priority = 1;
    private Gtk.VBox m_BoxInfoFrame = new Gtk.VBox (false, 0);

    // methods
    public Provider (Gtk.SourceBuffer inBuffer, Engine inEngine)
    {
        m_Buffer = inBuffer;
        m_Engine = inEngine;
    }

    public string get_name ()
    {
        return m_Name;
    }

    public int get_priority ()
    {
        return m_Priority;
    }

    public bool match (Gtk.SourceCompletionContext inContext)
    {
        return true;
    }

    public void populate (Gtk.SourceCompletionContext inContext)
    {
        var file_props = get_file_proposals ();

        m_CompletionMark = m_Buffer.get_insert ();
        Gtk.TextIter iter;
        m_Buffer.get_iter_at_mark (out iter, m_CompletionMark);
        var line = iter.get_line () + 1;

        Gtk.TextIter iter_start;
        m_Buffer.get_iter_at_line (out iter_start, line - 1);

        if (file_props != null)
            inContext.add_proposals (this, file_props, true);
    }

    public unowned Gdk.Pixbuf? get_icon ()
    {
        if (m_Icon == null)
        {
            Gtk.IconTheme theme = Gtk.IconTheme.get_default ();
            try
            {
                m_Icon = theme.load_icon (Gtk.Stock.DIALOG_INFO, 16, 0);
            }
            catch (GLib.Error err)
            {
                warning ("Could not load icon theme: %s\n", err.message);
            }
        }

        return m_Icon;
    }

    public bool
    activate_proposal (Gtk.SourceCompletionProposal inProposal, Gtk.TextIter inIter)
    {
        Gtk.TextIter start;
        m_Buffer.get_iter_at_mark (out start, m_CompletionMark);

        inIter.backward_word_start ();

        m_Buffer.delete (ref start, ref inIter);
        m_Buffer.insert (ref start, inProposal.get_text (), inProposal.get_text ().length);

        return true;
    }

    public Gtk.SourceCompletionActivation
    get_activation ()
    {
        return Gtk.SourceCompletionActivation.INTERACTIVE |
               Gtk.SourceCompletionActivation.USER_REQUESTED;
    }

    public unowned Gtk.Widget? get_info_widget (Gtk.SourceCompletionProposal inProposal)
    {
        return m_BoxInfoFrame;
    }

    public int get_interactive_delta ()
    {
        return -1;
    }

    public bool
    get_start_iter (Gtk.SourceCompletionContext inContext, Gtk.SourceCompletionProposal inProposal, Gtk.TextIter inIter)
    {
        var mark = m_Buffer.get_insert ();
        Gtk.TextIter cursor_iter;
        m_Buffer.get_iter_at_mark (out cursor_iter, mark);

        inIter = cursor_iter;
        inIter.backward_word_start ();

        return true;
    }

    public void
    update_info (Gtk.SourceCompletionProposal inProposal, Gtk.SourceCompletionInfo inInfo)
    {
        return;
    }

    public GLib.List<Gtk.SourceCompletionItem>?
    get_file_proposals ()
    {
        string to_find = "";
        Gtk.TextIter iter, end;
        Gtk.TextBuffer buffer = m_Buffer;
        buffer.get_start_iter (out end);
        buffer.get_iter_at_offset (out iter, buffer.cursor_position);
        iter.backward_find_char ((c) => {
            bool valid = c in c_Stoppers;
            if (!valid)
                to_find += c.to_string ();
            return valid;
        }, end);

        to_find = to_find.reverse ();

        if (to_find == "")
            return null;

        var props = new GLib.List<Gtk.SourceCompletionItem> ();

        foreach (var word in m_Engine.find (to_find))
        {
            var item = new Gtk.SourceCompletionItem (word, word, null, null);
            props.append (item);
        }

        return props;
    }
}
