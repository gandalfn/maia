/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * switch-button.vala
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

public class Maia.SwitchButton : Toggle
{
    // properties
    private Core.Animator  m_SwitchAnimator    = null;
    private uint           m_SwitchTransition  = 0;
    private double         m_SwitchProgress = 0.0;


    // accessors
    internal override string tag {
        get {
            return "SwitchButton";
        }
    }

    [CCode (notify = false)]
    internal double switch_progress {
        get {
            return m_SwitchProgress;
        }
        set {
            m_SwitchProgress = value;
            damage.post ();
        }
    }

    /**
     * Space between switch and label
     */
    public double spacing { get; set; default = 5; }

    /**
     * Shadow pattern of switch
     */
    public StatePatterns shadow_pattern { get; set; }

    /**
     * Line pattern of switch
     */
    public Graphic.Pattern line_pattern { get; set; default = null; }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("switch-progress");

        // Set default property
        fill_pattern[State.NORMAL] = new Graphic.Color (1, 1, 1);
        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);

        // create state patterns
        shadow_pattern = new StatePatterns.va (State.NORMAL, new Graphic.Color (0.8, 0.8, 0.8));

        // create switch animator
        m_SwitchAnimator = new Core.Animator (60, 120);

        // connect activate changed
        notify["active"].connect (on_active_changed);
    }

    public SwitchButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    private void
    on_active_changed ()
    {
        m_SwitchAnimator.stop ();

        if (m_SwitchTransition > 0)
        {
            m_SwitchAnimator.remove_transition (m_SwitchTransition);
        }
        m_SwitchTransition = m_SwitchAnimator.add_transition (0, 1, Core.Animator.ProgressType.EXPONENTIAL);
        GLib.Value from = m_SwitchProgress;
        GLib.Value to = active ? 1.0 : 0.0;
        m_SwitchAnimator.add_transition_property (m_SwitchTransition, this, "switch-progress", from, to);
        m_SwitchAnimator.start ();

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
                area.union_ (Graphic.Rectangle (border, border, main_content_size.height * 2.0, main_content_size.height));
            }
            else
            {
                area.union_ (Graphic.Rectangle (border + (main_content_size.height * 2.0) + spacing, border, main_content_size.width, main_content_size.height));
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
                    main_content.update (inContext, new Graphic.Region (Graphic.Rectangle (border + (main_content_size.height * 2.0) + spacing,
                                                                                      border + ((item_size.height - main_content_size.height) / 2.0),
                                                                                      item_size.width - ((main_content_size.height * 2.0) + spacing), main_content_size.height)));
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

            double size_width = main_content_size.height * 2.0;
            double size_height = main_content_size.height / 2.0;
            double offset = main_content_size.height / 4.0;

            // Draw switch box
            var path = new Graphic.Path ();
            path.rectangle (0, offset, size_width, size_height, size_height / 2.0, size_height / 2.0);
            inContext.pattern = shadow_pattern[state];
            inContext.fill (path);

            path = new Graphic.Path ();
            double start = size_height;
            double end = size_width - size_height;
            path.arc (start + (switch_progress * (end - start)), offset + (size_height / 2.0), size_height, size_height, 0, 2 * GLib.Math.PI);
            inContext.pattern = fill_pattern[state] ?? new Graphic.Color (0.7, 0.7, 0.7);
            inContext.fill (path);
            if (line_pattern != null)
            {
                inContext.line_width = line_width;
                inContext.pattern = line_pattern;
                inContext.stroke (path);
            }
        }
        inContext.restore ();
    }
}
