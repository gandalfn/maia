/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * highlight.vala
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

public class Maia.Highlight : Toggle
{
    // properties
    private Core.Animator  m_HighlightAnimator    = null;
    private uint           m_HighlightTransition  = 0;
    private double         m_HighlightProgress    = 0.0;

    // accessors
    internal override string tag {
        get {
            return "Highlight";
        }
    }

    internal override string main_data {
        owned get {
            return @"Grid.$(name)-content { " +
                   @"    Label.$(name)-label { " +
                   @"        yfill: false;" +
                   @"        yexpand: true;" +
                   @"        xexpand: true;" +
                   @"        xfill: true;" +
                   @"        state: @state;" +
                   @"        alignment: @alignment;" +
                   @"        shade-color: @shade-color;" +
                   @"        font-description: @font-description;" +
                   @"        stroke-pattern: @stroke-pattern;" +
                   @"        text: @label;" +
                   @"    }" +
                   @"}";
        }
    }

    [CCode (notify = false)]
    internal double highlight_progress {
        get {
            return m_HighlightProgress;
        }
        set {
            m_HighlightProgress = value;
            damage.post ();
        }
    }

    /**
     * Alignment of label ``left``, ``center`` or ``right``, default was ``center``
     */
    public Graphic.Glyph.Alignment alignment { get; set; default = Graphic.Glyph.Alignment.CENTER; }


    // methods
    construct
    {
        not_dumpable_attributes.insert ("highlight-progress");

        // create switch animator
        m_HighlightAnimator = new Core.Animator (60, 120);

        // connect activate changed
        notify["active"].connect (on_active_changed);
    }

    public Highlight (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    private void
    on_active_changed ()
    {
        m_HighlightAnimator.stop ();

        if (m_HighlightTransition > 0)
        {
            m_HighlightAnimator.remove_transition (m_HighlightTransition);
        }
        m_HighlightTransition = m_HighlightAnimator.add_transition (0, 1, Core.Animator.ProgressType.LINEAR);
        GLib.Value from = m_HighlightProgress;
        GLib.Value to = active ? 1.0 : 0.0;
        m_HighlightAnimator.add_transition_property (m_HighlightTransition, this, "highlight-progress", from, to);
        m_HighlightAnimator.start ();

    }

    internal override Graphic.Size
    childs_size_request ()
    {
        Graphic.Size ret = Graphic.Size (0, 0);

        if (main_content != null)
        {
            var area = Graphic.Rectangle (0, 0, border * 2.0, border * 2.0);

            // get size of label
            Graphic.Size main_content_size = main_content.size;
            area.union_ (Graphic.Rectangle (border, border, main_content_size.width, main_content_size.height));
            ret = area.size;
            ret.resize (border, border);
        }

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            if (main_content != null)
            {
                var item_size = area.extents.size;
                item_size.resize (-border * 2.0, -border * 2.0);
                var main_content_size = main_content.size;
                main_content.update (inContext, new Graphic.Region (Graphic.Rectangle (border, border + ((item_size.height - main_content_size.height) / 2.0),
                                                                                       item_size.width, main_content_size.height)));
            }

            damage_area ();
        }
    }
    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            // Paint hightlight if active
            if (m_HighlightProgress > 0)
            {
                var main_content_area = main_content.geometry.extents;
                main_content_area.translate (Graphic.Point (-border / 2.0, -border / 2.0));
                main_content_area.resize (Graphic.Size (border, border));

                var path = new Graphic.Path ();
                path.rectangle (double.max (main_content_area.origin.x, 0), double.max (main_content_area.origin.y, 0), main_content_area.size.width, main_content_area.size.height, 5, 5);

                if (stroke_pattern != null)
                {
                    var stroke_color = stroke_pattern[state] as Graphic.Color;

                    if (stroke_color != null)
                    {
                        inContext.pattern = new Graphic.Color (stroke_color.red, stroke_color.green, stroke_color.blue, stroke_color.alpha * m_HighlightProgress);
                    }
                    else
                    {
                        inContext.pattern = stroke_pattern[state];
                    }
                    inContext.line_width = line_width;
                    inContext.stroke (path);
                }

                if (fill_pattern != null)
                {
                    var fill_color = fill_pattern[state] as Graphic.Color;
                    if (fill_color != null)
                    {
                        inContext.pattern = new Graphic.Color (fill_color.red, fill_color.green, fill_color.blue, fill_color.alpha * m_HighlightProgress);
                    }
                    else
                    {
                        inContext.pattern = fill_pattern[state];
                    }
                    inContext.fill (path);
                }
            }

            // paint childs
            foreach (unowned Core.Object child in this)
            {
                if (child is Drawable)
                {
                    unowned Drawable drawable = (Drawable)child;
                    drawable.draw (inContext, area_to_child_item_space (drawable, inArea));
                }
            }
        }
        inContext.restore ();
    }
}
