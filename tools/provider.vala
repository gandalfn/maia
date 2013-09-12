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

public abstract class CanvasEditor.Provider : GLib.Object, Gtk.SourceCompletionProvider
{
    // constants
    public static const unichar[] c_Stoppers = {' ', '\t', '\n', '(', ';', '}', '{', '.'};

    // properties
    protected unowned Gtk.SourceBuffer m_Buffer;
    private Gtk.TextMark m_CompletionMark;
    private Gdk.Pixbuf m_Icon;
    private string m_Name;
    private int m_Priority;
    private Gtk.VBox m_BoxInfoFrame = new Gtk.VBox (false, 0);

    // methods
    public Provider (string inName, int inPriority, Gtk.SourceBuffer inBuffer)
    {
        m_Name = inName;
        m_Priority = inPriority;
        m_Buffer = inBuffer;
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

    public abstract GLib.List<Gtk.SourceCompletionItem>? get_file_proposals ();
}

public class CanvasEditor.DocumentProvider : Provider
{
    // properties
    private unowned Engine m_Engine;

    // methods
    public DocumentProvider (Gtk.SourceBuffer inBuffer, Engine inEngine)
    {
        base ("Document Word Completion", 5, inBuffer);
        m_Engine = inEngine;
    }

    public override GLib.List<Gtk.SourceCompletionItem>?
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

public class CanvasEditor.ManifestProvider : Provider
{
    // properties
    private Maia.Core.Set<string> m_Keywords;
    private Maia.Core.Set<string> m_Properties;

    // methods
    public ManifestProvider (Gtk.SourceBuffer inBuffer)
    {
        base ("Manifest Word Completion", 10, inBuffer);

        load_keywords ();
        load_properties ();
    }

    private void
    load_keywords ()
    {
        m_Keywords = new Maia.Core.Set<string> ();

        m_Keywords.insert ("Group");
        m_Keywords.insert ("Rectangle");
        m_Keywords.insert ("Path");
        m_Keywords.insert ("Image");
        m_Keywords.insert ("Label");
        m_Keywords.insert ("Entry");
        m_Keywords.insert ("Grid");
        m_Keywords.insert ("ToggleGroup");
        m_Keywords.insert ("Button");
        m_Keywords.insert ("CheckButton");
        m_Keywords.insert ("Highlight");
        m_Keywords.insert ("Document");
        m_Keywords.insert ("Model");
        m_Keywords.insert ("Column");
        m_Keywords.insert ("View");
        m_Keywords.insert ("DrawingArea");
        m_Keywords.insert ("Style");
        m_Keywords.insert ("Combo");
        m_Keywords.insert ("Popup");
        m_Keywords.insert ("Shortcut");
    }

    private void
    load_properties ()
    {
        m_Properties = new Maia.Core.Set<string> ();

        m_Properties.insert ("position");
        m_Properties.insert ("size");
        m_Properties.insert ("is-movable");
        m_Properties.insert ("is-resizable");
        m_Properties.insert ("visible");
        m_Properties.insert ("layer");
        m_Properties.insert ("background-pattern");
        m_Properties.insert ("fill-pattern");
        m_Properties.insert ("stroke-pattern");
        m_Properties.insert ("line-width");
        m_Properties.insert ("stroke-pattern");
        m_Properties.insert ("font-description");
        m_Properties.insert ("label");
        m_Properties.insert ("border");
        m_Properties.insert ("icon-filename");
        m_Properties.insert ("button-color");
        m_Properties.insert ("spacing");
        m_Properties.insert ("format");
        m_Properties.insert ("top-margin");
        m_Properties.insert ("bottom-margin");
        m_Properties.insert ("left-margin");
        m_Properties.insert ("right-margin");
        m_Properties.insert ("resolution");
        m_Properties.insert ("header");
        m_Properties.insert ("footer");
        m_Properties.insert ("anchor-size");
        m_Properties.insert ("selected-border");
        m_Properties.insert ("selected-border-line-width");
        m_Properties.insert ("selected-border-color");
        m_Properties.insert ("selected-border-line-width");
        m_Properties.insert ("text");
        m_Properties.insert ("lines");
        m_Properties.insert ("underline-width");
        m_Properties.insert ("homogeneous");
        m_Properties.insert ("row-spacing");
        m_Properties.insert ("border-line-width");
        m_Properties.insert ("grid-line-width");
        m_Properties.insert ("filename");
        m_Properties.insert ("path");
        m_Properties.insert ("group");
        m_Properties.insert ("active");
        m_Properties.insert ("orientation");
        m_Properties.insert ("model");
        m_Properties.insert ("row");
        m_Properties.insert ("rows");
        m_Properties.insert ("column");
        m_Properties.insert ("columns");
        m_Properties.insert ("xexpand");
        m_Properties.insert ("yexpand");
        m_Properties.insert ("xfill");
        m_Properties.insert ("yfill");
        m_Properties.insert ("xshrink");
        m_Properties.insert ("yshrink");
        m_Properties.insert ("xalign");
        m_Properties.insert ("yalign");
        m_Properties.insert ("top-padding");
        m_Properties.insert ("bottom-padding");
        m_Properties.insert ("left-padding");
        m_Properties.insert ("right-padding");
        m_Properties.insert ("border-width");
        m_Properties.insert ("style");
        m_Properties.insert ("section");
        m_Properties.insert ("angle");
        m_Properties.insert ("alignment");
        m_Properties.insert ("wrap-mode");
        m_Properties.insert ("ellipsize-mode");
    }

    private GLib.List<string>
    find_keywords (string inToFind)
    {
        GLib.List<string> list = new GLib.List<string> ();

        foreach (var keyword in m_Keywords)
        {
            if (keyword.length > inToFind.length && keyword.slice (0, inToFind.length) == inToFind)
            {
                list.prepend (keyword);
            }
        }
        list.reverse ();

        return list;
    }

    private GLib.List<string>
    find_properties (string inToFind)
    {
        GLib.List<string> list = new GLib.List<string> ();

        foreach (var property in m_Properties)
        {
            if (property.length > inToFind.length && property.slice (0, inToFind.length) == inToFind)
            {
                list.prepend (property);
            }
        }
        list.reverse ();

        return list;
    }

    public override GLib.List<Gtk.SourceCompletionItem>?
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

        foreach (var property in find_properties (to_find))
        {
            var item = new Gtk.SourceCompletionItem (property, property, null, null);
            props.append (item);
        }

        foreach (var keyword in find_keywords (to_find))
        {
            var item = new Gtk.SourceCompletionItem (keyword, keyword, null, null);
            props.append (item);
        }

        return props;
    }
}
