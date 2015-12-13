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

public class Valadoc.Cpp.Doclet : Valadoc.Api.Visitor, Valadoc.Doclet
{
    private Valadoc.GtkdocRenderer renderer;
    private Valadoc.MarkupWriter m_Writer;
    private Valadoc.Settings m_Settings;
    private bool in_function = false;
    private bool have_parameters = false;
    private bool enable_property = false;
    private bool enable_signal = false;
    private string current_class = null;

    public void
    process (Valadoc.Settings inSettings, Valadoc.Api.Tree inTree, Valadoc.ErrorReporter inReporter)
    {
        m_Settings = inSettings;
        renderer = new Valadoc.GtkdocRenderer ();
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
        inItem.accept_all_children (this);
    }

    public override void
    visit_property (Valadoc.Api.Property inItem)
    {
        if (enable_property && current_class != null)
        {
            string[] attributes = {};
            attributes += "name";
            attributes += current_class + "::" + inItem.get_cname ();
            m_Writer.start_tag ("property", attributes);
            Valadoc.Content.Comment? doctree = inItem.documentation;
            if (doctree != null)
            {
                m_Writer.start_tag ("description");
                renderer.render (doctree);
                m_Writer.text (Valadoc.MarkupWriter.escape (renderer.content));
                m_Writer.end_tag ("description");
            }
            m_Writer.end_tag ("property");
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
                m_Writer.text (Valadoc.MarkupWriter.escape (renderer.content));
                m_Writer.end_tag ("description");
                m_Writer.end_tag ("signal");
            }
        }
    }

    public override void
    visit_formal_parameter (Valadoc.Api.FormalParameter inItem)
    {
        if (in_function)
        {
            Valadoc.Content.Comment? doctree = inItem.documentation;
            if (doctree != null)
            {
                if (!have_parameters)
                {
                    m_Writer.start_tag ("parameters");
                    have_parameters = true;
                }
                string[] attributes = {};
                attributes += "name";
                attributes += inItem.name;
                m_Writer.start_tag ("parameter", attributes);
                m_Writer.start_tag ("parameter_description");
                renderer.render (doctree);
                m_Writer.text (Valadoc.MarkupWriter.escape (renderer.content));
                m_Writer.end_tag ("parameter_description");
                m_Writer.end_tag ("parameter");
            }
        }
    }

    public override void
    visit_method (Valadoc.Api.Method inItem)
    {
        Valadoc.Content.Comment? doctree = inItem.documentation;
        if (doctree != null)
        {
            string[] attributes = {};
            attributes += "name";
            attributes += inItem.get_cname ();
            m_Writer.start_tag ("function", attributes);
            m_Writer.start_tag ("description");
            renderer.render_symbol (doctree);
            m_Writer.text (Valadoc.MarkupWriter.escape (renderer.content));
            m_Writer.end_tag ("description");
            in_function = true;
            have_parameters = false;
            inItem.accept_all_children (this);
            in_function = false;
            if (have_parameters)
            {
                m_Writer.end_tag ("parameters");
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
