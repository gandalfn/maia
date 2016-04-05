/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * checkbutton.vala
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

public class Maia.CheckButton : Toggle
{
    // properties
    private Core.Animator  m_CheckAnimator    = null;
    private uint           m_CheckTransition  = 0;
    private double         m_CheckProgress    = 0.0;

    // accessors
    internal override string tag {
        get {
            return "CheckButton";
        }
    }

    [CCode (notify = false)]
    internal double check_progress {
        get {
            return m_CheckProgress;
        }
        set {
            m_CheckProgress = value;
            damage.post ();
        }
    }

    public double spacing { get; set; default = 5; }
    public StatePatterns line_pattern { get; set; }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("check-progress");

        // Set default patterns
        fill_pattern[State.NORMAL] = new Graphic.Color (1, 1, 1);
        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);
        line_pattern = new StatePatterns.va (State.NORMAL, new Graphic.Color (0, 0, 0));

        // create switch animator
        m_CheckAnimator = new Core.Animator (30, 180);

        // connect activate changed
        notify["active"].connect (on_active_changed);
    }

    public CheckButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    private void
    on_active_changed ()
    {
        m_CheckAnimator.stop ();

        if (m_CheckTransition > 0)
        {
            m_CheckAnimator.remove_transition (m_CheckTransition);
        }
        m_CheckTransition = m_CheckAnimator.add_transition (0, 1, Core.Animator.ProgressType.LINEAR);
        GLib.Value from = m_CheckProgress;
        GLib.Value to = active ? 1.0 : 0.0;
        m_CheckAnimator.add_transition_property (m_CheckTransition, this, "check-progress", from, to);
        m_CheckAnimator.start ();

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
            if (main_content_size.is_empty ())
            {
                // create a fake label
                var label = new Label ("fake", "Z");
                label.font_description = font_description;
                main_content_size = label.size;
                area.union_ (Graphic.Rectangle (border, border, main_content_size.height, main_content_size.height));
            }
            else
            {
                area.union_ (Graphic.Rectangle (border + main_content_size.height + spacing, border, main_content_size.width, main_content_size.height));
            }
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
                if (!main_content_size.is_empty ())
                {
                    main_content.update (inContext, new Graphic.Region (Graphic.Rectangle (border + main_content_size.height + spacing,
                                                                                      border + ((item_size.height - main_content_size.height) / 2.0),
                                                                                      item_size.width - (main_content_size.height + spacing), main_content_size.height)));
                }
            }

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            var main_content_size = (main_content.geometry == null) ? Graphic.Size (0, 0) : main_content.geometry.extents.size;
            if (main_content_size.is_empty ())
            {
                main_content_size = size;
                main_content_size.resize (-border * 2.0, -border * 2.0);
            }
            else
            {
                var child_area = area_to_child_item_space (main_content, inArea);
                main_content.draw (inContext, child_area);
            }

            var item_size = area.extents.size;
            item_size.resize (-border * 2.0, -border * 2.0);

            // Translate to align in height center
            inContext.translate (Graphic.Point (border, double.max (border, border + (item_size.height - main_content_size.height) / 2)));

            // Paint check box
            Graphic.Color color = fill_pattern[state] as Graphic.Color ?? new Graphic.Color (0.7, 0.7, 0.7);
            Graphic.Color shade = new Graphic.Color.shade (color, 0.6);

            var path = new Graphic.Path ();
            path.rectangle (0, 0, main_content_size.height, main_content_size.height, 5, 5);
            inContext.pattern = shade;
            inContext.fill (path);

            path = new Graphic.Path ();
            path.rectangle (1.5, 1.5, main_content_size.height - 3, main_content_size.height - 3, 5, 5);
            inContext.pattern = color;
            inContext.fill (path);

            // Paint check if active
            if (active && m_CheckProgress > 0.0)
            {
                var line_color = line_pattern[state] as Graphic.Color;
                if (line_color != null)
                {
                    var start = Graphic.Point (0, 0);
                    var end = Graphic.Point (main_content_size.height, 0);
                    var gradient = new Graphic.LinearGradient (start, end);

                    gradient.add (new Graphic.Gradient.ColorStop (0.0, line_color));
                    gradient.add (new Graphic.Gradient.ColorStop (m_CheckProgress, line_color));
                    gradient.add (new Graphic.Gradient.ColorStop (m_CheckProgress, new Graphic.Color (0, 0, 0, 0)));
                    gradient.add (new Graphic.Gradient.ColorStop (1.0, new Graphic.Color (0, 0, 0, 0)));
                    inContext.pattern = gradient;
                }
                else
                {
                    inContext.pattern = line_pattern[state];
                }

                path = new Graphic.Path ();
                path.move_to  (0.5 + (main_content_size.height * 0.2), (main_content_size.height * 0.5));
                path.line_to  (0.5 + (main_content_size.height * 0.4), (main_content_size.height * 0.7));
                path.curve_to (0.5 + (main_content_size.height * 0.4), (main_content_size.height * 0.7),
                               0.5 + (main_content_size.height * 0.5), (main_content_size.height * 0.4),
                               0.5 + (main_content_size.height * 0.7), (main_content_size.height * 0.05));
                inContext.stroke (path);
            }
        }
        inContext.restore ();
    }
}
