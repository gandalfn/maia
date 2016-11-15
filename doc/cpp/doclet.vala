/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * doclet.vala
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

public class Valadoc.Cpp.DoxygenComment : Valadoc.Content.ContentVisitor
{
    public Api.Node node_reference;

    public bool is_dbus;
    public string brief_comment;
    public string long_comment;
    public string returns;
    public Gee.LinkedList<string> parameters = new Gee.LinkedList<string> ();
    public Gee.LinkedList<string> versioning = new Gee.LinkedList<string> ();
    public string[] see_also = new string[]{};

    private StringBuilder current_builder = new StringBuilder ();
    private bool in_brief_comment = true;
    private ErrorReporter reporter;

    public DoxygenComment (ErrorReporter reporter, Api.Node? node_reference = null)
    {
        this.node_reference = node_reference;
        this.reporter = reporter;
    }

    public void
    convert (Valadoc.Content.Comment comment, bool is_dbus = false)
    {
        this.is_dbus = is_dbus;
        comment.accept (this);

        long_comment = current_builder.str.strip ();
        if (long_comment == "")
        {
            long_comment = null;
        }
    }

    public override void
    visit_comment (Valadoc.Content.Comment c)
    {
        c.accept_children (this);
    }

    public override void
    visit_embedded (Valadoc.Content.Embedded em)
    {
        current_builder.append_printf ("\\image %s", em.url);
        if (em.caption != null)
        {
            current_builder.append_printf (" \"%s\"", em.caption);
        }
        current_builder.append ("\n");

        em.accept_children (this);
    }

    public override void
    visit_headline (Valadoc.Content.Headline hl)
    {
        current_builder.append ("\\par ");
        hl.accept_children (this);
        current_builder.append ("\n");
    }

    public override void
    visit_wiki_link (Valadoc.Content.WikiLink link)
    {
        if (link.content.size > 0)
        {
            link.accept_children (this);
        }
        else
        {
            current_builder.append (link.name);
        }
    }

    public override void
    visit_link (Valadoc.Content.Link link)
    {
        current_builder.append_printf ("\\htmlonly <a href=\"%s\">", link.url);
        link.accept_children (this);
        current_builder.append ("</a>\\endhtmlonly\n");
    }

    public override void
    visit_symbol_link (Valadoc.Content.SymbolLink sl)
    {
        current_builder.append_printf ("\\link %s", sl.given_symbol_name);
    }

    public override void
    visit_list (Valadoc.Content.List list)
    {
        list.accept_children (this);
    }

    public override void
    visit_list_item (Valadoc.Content.ListItem item)
    {
        current_builder.append ("\\li ");
        item.accept_children (this);
        current_builder.append ("\n");
    }

    public override void
    visit_paragraph (Valadoc.Content.Paragraph para)
    {
        if (!in_brief_comment)
        {
            current_builder.append ("\\par \n");
        }
        para.accept_children (this);

        if (in_brief_comment)
        {
            brief_comment = current_builder.str;
            current_builder = new StringBuilder ();
            in_brief_comment = false;
        }
        else
        {
            current_builder.append ("\n");
        }
    }

    public override void
    visit_warning (Valadoc.Content.Warning element)
    {
        current_builder.append ("\\warning ");
        element.accept_children (this);
        current_builder.append ("\n");
    }

    public override void
    visit_note (Valadoc.Content.Note element)
    {
        current_builder.append ("\\note ");
        element.accept_children (this);
        current_builder.append ("\n");
    }

    public override void
    visit_page (Valadoc.Content.Page page)
    {
        page.accept_children (this);
    }

    public override void
    visit_run (Valadoc.Content.Run run)
    {
        switch (run.style)
        {
            case Valadoc.Content.Run.Style.BOLD:
                current_builder.append ("\\b ");
                break;

            case Valadoc.Content.Run.Style.ITALIC:
                current_builder.append ("\\e ");
                break;

            case Valadoc.Content.Run.Style.UNDERLINED:
                break;

            case Valadoc.Content.Run.Style.MONOSPACED:
                current_builder.append ("\\c ");
                break;
        }
        run.accept_children (this);
    }

    public override void
    visit_source_code (Valadoc.Content.SourceCode code)
    {
        current_builder.append ("\\code");
        current_builder.append (code.code);
        current_builder.append ("\\endcode\n");
    }

    public override void
    visit_table (Valadoc.Content.Table t)
    {
        t.accept_children (this);
    }

    public override void
    visit_table_row (Valadoc.Content.TableRow row)
    {
        current_builder.append ("\\li ");
        row.accept_children (this);
        current_builder.append ("\n");
    }

    public override void
    visit_table_cell (Valadoc.Content.TableCell cell)
    {
        cell.accept_children (this);
    }

    public override void
    visit_taglet (Valadoc.Content.Taglet t)
    {
        var old_builder = (owned)current_builder;
        current_builder = new StringBuilder ();

        t.accept_children (this);
        if (t is Valadoc.Taglets.Param)
        {
            parameters.add ("\\param %s %s\n".printf (((Valadoc.Taglets.Param)t).parameter_name, current_builder.str));
        }
        else if (t is Valadoc.Taglets.InheritDoc)
        {
            ((Taglets.InheritDoc)t).produce_content().accept (this);
        }
        else if (t is Valadoc.Taglets.Return)
        {
            returns = "\\return %s\n".printf (current_builder.str);
        }
        else if (t is Valadoc.Taglets.Since)
        {
            versioning.add ("\\since %s\n".printf (((Taglets.Since)t).version));
        }
        else if (t is Valadoc.Taglets.Deprecated)
        {
            versioning.add ("\\deprecated %s\n".printf (current_builder.str));
        }
        else if (t is Valadoc.Taglets.See)
        {
            var see = (Valadoc.Taglets.See)t;
            var see_also = this.see_also; // vala bug
            see_also += "\\link %s\n".printf (see.symbol_name);
        }
        else if (t is Valadoc.Taglets.Link)
        {
            ((Taglets.Link)t).produce_content().accept (this);
        }
        else if (t is Valadoc.Taglets.Throws)
        {
            var taglet = (Taglets.Throws) t;
            var link = taglet.error_domain_name;
            old_builder.append_printf ("\throws %s %s\n",
                                       link,
                                       current_builder.str);
        }
        else
        {
            reporter.simple_warning ("Cpp", "Taglet not supported"); // TODO
        }
        current_builder = (owned)old_builder;
    }

    public override void
    visit_text (Valadoc.Content.Text t)
    {
        current_builder.append (Markup.escape_text (t.content));
        t.accept_children (this);
    }
}

public class Valadoc.Cpp.Doclet : Valadoc.Api.Visitor, Valadoc.Doclet
{
    private Valadoc.ErrorReporter reporter;
    private Valadoc.GtkdocRenderer renderer;
    private Valadoc.MarkupWriter m_Writer;
    private Valadoc.Settings m_Settings;
    private bool enable_property = true;
    private bool enable_signal = true;
    private string current_class = null;

    private string
    format (string inStr)
    {
        string ret = inStr;
        ret = ret.replace ("<para>", "");
        ret = ret.replace ("</para>", "");
        ret = ret.replace ("<blockquote>", "“");
        ret = ret.replace ("</blockquote>", "“");
        ret = ret.replace ("“\n", "“");
        ret = ret.replace ("“ ", "“");
        return Valadoc.MarkupWriter.escape (ret.strip ());
    }

    public void
    process (Valadoc.Settings inSettings, Valadoc.Api.Tree inTree, Valadoc.ErrorReporter inReporter)
    {
        m_Settings = inSettings;
        renderer = new Valadoc.GtkdocRenderer ();
        reporter = inReporter;
        GLib.DirUtils.create_with_parents (m_Settings.path, 0777);
        inTree.accept (this);
    }

    /**
     * Visit tree
     *
     * @param inTree tree
     */
    public override void
    visit_tree (Valadoc.Api.Tree inTree)
    {
        inTree.accept_children (this);
    }

    public override void
    visit_package (Valadoc.Api.Package inPackage)
    {
        if (!inPackage.is_browsable (m_Settings))
        {
            return;
        }

        string pkg_name = inPackage.name;

        string filepath = GLib.Path.build_filename (m_Settings.path, pkg_name.down () + "_docs.xml");

        var stream = GLib.FileStream.open (filepath, "w");
        m_Writer = new Valadoc.MarkupWriter ((str) => {
            stream.puts (str);
        }, false);

        m_Writer.start_tag ("root");
        inPackage.accept_all_children (this);
        m_Writer.end_tag ("root");
    }

    public override void
    visit_namespace (Valadoc.Api.Namespace inItem)
    {
        inItem.accept_all_children (this);
    }

    public override void
    visit_interface (Valadoc.Api.Interface inItem)
    {
        current_class = inItem.get_cname ();
        inItem.accept_all_children (this);
        current_class = null;
    }

    public override void
    visit_class (Valadoc.Api.Class inItem)
    {
        Valadoc.Content.Comment? doctree = inItem.documentation;
        if (doctree != null)
        {
            var converter = new DoxygenComment (reporter, inItem);
            converter.convert (doctree);
            string comment = "";
            if (converter.brief_comment != null)
            {
                comment += "%s\n\n".printf (converter.brief_comment);
            }
            if (converter.long_comment != null)
            {
                comment += "%s\n".printf (converter.long_comment);
            }
            try
            {
                GLib.FileUtils.set_contents (@"$(m_Settings.directory)/$(inItem.get_cname ()).doc", comment);
            }
            catch (GLib.Error err)
            {

            }
        }
        current_class = inItem.get_cname ();
        inItem.accept_all_children (this);
        current_class = null;
    }

    public override void
    visit_struct (Valadoc.Api.Struct inItem)
    {
        inItem.accept_all_children (this);
    }

    public override void
    visit_error_domain (Valadoc.Api.ErrorDomain inItem)
    {
        inItem.accept_all_children (this);
    }

    public override void
    visit_enum (Valadoc.Api.Enum inItem)
    {
        Valadoc.Content.Comment? doctree = inItem.documentation;
        if (doctree != null)
        {
            m_Writer.start_tag ("enum", { "name", inItem.get_cname () });
            m_Writer.start_tag ("description");
            renderer.render (doctree);
            m_Writer.text (format (renderer.content));
            m_Writer.end_tag ("description");
            var enum_values = inItem.get_children_by_type (Valadoc.Api.NodeType.ENUM_VALUE);
            if (enum_values.size > 0)
            {
                m_Writer.start_tag ("parameters");
                foreach (var enum_value in enum_values)
                {
                    if (enum_value.documentation != null)
                    {
                        unowned Valadoc.Api.EnumValue enum_val = enum_value as Valadoc.Api.EnumValue;
                        m_Writer.start_tag ("parameter", { "name", enum_val.get_cname () });
                        m_Writer.start_tag ("parameter_description");
                        renderer.render (enum_value.documentation);
                        m_Writer.text (format (renderer.content));
                        m_Writer.end_tag ("parameter_description");
                        m_Writer.end_tag ("parameter");
                    }
                }
                m_Writer.end_tag ("parameters");
            }
            m_Writer.end_tag ("enum");
        }
    }

    public override void
    visit_property (Valadoc.Api.Property inItem)
    {
        if (enable_property && current_class != null)
        {
            Valadoc.Content.Comment? doctree = inItem.documentation;

            if (doctree != null)
            {
                string[] attributes = {};
                attributes += "name";
                attributes += current_class + "::" + inItem.get_cname ();
                m_Writer.start_tag ("property", attributes);
                m_Writer.start_tag ("description");
                renderer.render (doctree);
                m_Writer.text (format (renderer.content));
                m_Writer.end_tag ("description");
                m_Writer.end_tag ("property");
                if (inItem.getter != null)
                {
                    m_Writer.start_tag ("function", { "name", inItem.getter.get_cname () });
                    m_Writer.start_tag ("description");
                    renderer.render (doctree);
                    m_Writer.text ("An accessor function to get : " + format (renderer.content));
                    m_Writer.end_tag ("description");
                    m_Writer.end_tag ("function");
                }
                if (inItem.setter != null)
                {
                    m_Writer.start_tag ("function", { "name", inItem.setter.get_cname () });
                    m_Writer.start_tag ("description");
                    renderer.render (doctree);
                    m_Writer.text ("An accessor function to set : " + format (renderer.content));
                    m_Writer.end_tag ("description");
                    m_Writer.end_tag ("function");
                }
            }
        }
    }

    public override void
    visit_constant (Valadoc.Api.Constant inItem)
    {
        inItem.accept_all_children (this);
    }

    public override void
    visit_field (Valadoc.Api.Field inItem)
    {
        inItem.accept_all_children (this);
    }

    public override void
    visit_error_code (Valadoc.Api.ErrorCode inItem)
    {
        inItem.accept_all_children (this);
    }

    public override void
    visit_enum_value (Valadoc.Api.EnumValue inItem)
    {
        inItem.accept_all_children (this);
    }

    public override void
    visit_delegate (Valadoc.Api.Delegate inItem)
    {
        inItem.accept_all_children (this);
    }

    public override void
    visit_signal (Valadoc.Api.Signal inItem)
    {
        if (enable_signal)
        {
            Valadoc.Content.Comment? doctree = inItem.documentation;
            if (doctree != null)
            {
                string[] attributes = {};
                attributes += "name";
                attributes += inItem.get_cname ();
                m_Writer.start_tag ("signal", attributes);
                m_Writer.start_tag ("description");
                renderer.render (doctree);
                m_Writer.text (format (renderer.content));
                m_Writer.end_tag ("description");
                m_Writer.end_tag ("signal");
            }
        }
    }

    public override void
    visit_method (Valadoc.Api.Method inItem)
    {
        Valadoc.Content.Comment? doctree = inItem.documentation;
        if (doctree != null)
        {
            m_Writer.start_tag ("function", { "name", inItem.get_cname () });
            m_Writer.start_tag ("description");
            renderer.render_symbol (doctree);
            m_Writer.text ("format (renderer.content));
            m_Writer.end_tag ("description");

            var taglets = doctree.find_taglets (inItem, typeof (Valadoc.Taglets.Param));
            if (taglets.size > 0)
            {
                m_Writer.start_tag ("parameters");
                m_Writer.start_tag ("parameter", { "name", "self"});
                m_Writer.end_tag ("parameter");

                foreach (var taglet in taglets)
                {
                    unowned Valadoc.Taglets.Param? param_taglet = taglet as Valadoc.Taglets.Param;
                    m_Writer.start_tag ("parameter", { "name", param_taglet.parameter_name });
                    m_Writer.start_tag ("parameter_description");
                    renderer.render_children (taglet);
                    m_Writer.text (format (renderer.content));
                    m_Writer.end_tag ("parameter_description");
                    m_Writer.end_tag ("parameter");
                }
                m_Writer.end_tag ("parameters");
            }
            taglets = doctree.find_taglets (inItem, typeof (Valadoc.Taglets.Return));
            if (taglets.size > 0)
            {
                foreach (var taglet in taglets)
                {
                    m_Writer.start_tag ("return");
                    renderer.render_children (taglet);
                    m_Writer.text (format (renderer.content));
                    m_Writer.end_tag ("return");
                }
            }
            m_Writer.end_tag ("function");
        }
    }
}


public GLib.Type
register_plugin (Valadoc.ModuleLoader module_loader)
{
    return typeof (Valadoc.Cpp.Doclet);
}
