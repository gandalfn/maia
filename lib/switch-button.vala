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
    private unowned Label? m_Label;
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
    public Graphic.Pattern shadow_pattern { get; set; default = new Graphic.Color (0.8, 0.8, 0.8); }

    /**
     * Line pattern of switch
     */
    public Graphic.Pattern line_pattern { get; set; default = null; }

    // methods
    construct
    {
        // Set default property
        fill_pattern = new Item.StatePatterns (Item.State.NORMAL, new Graphic.Color (1, 1, 1));
        stroke_pattern = new Item.StatePatterns (Item.State.NORMAL, new Graphic.Color (0, 0, 0));

        // get toggle label
        m_Label = find (GLib.Quark.from_string ("%s-label".printf (name)), false) as Label;

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

        if (m_Label != null)
        {
            // get size of label
            Graphic.Size size_label = m_Label.size;

            if (size_label.is_empty () || m_Label.text == null || m_Label.text.strip() == "")
            {
                string text = m_Label.text;
                m_Label.text = "Z";
                size_label = m_Label.size;
                m_Label.position = Graphic.Point (0, 0);
                ret = Graphic.Size (size_label.height * 2, size_label.height);
                m_Label.text = text;
                size_label = m_Label.size;
            }
            else
            {
                // set position of label
                if (m_Label.position.x != size_label.height + spacing)
                {
                    m_Label.position = Graphic.Point ((size_label.height * 2) + spacing, 0);
#if MAIA_DEBUG
                    Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "label item position : %s", m_Label.position.to_string ());
#endif
                }

                ret = Graphic.Size ((size_label.height * 2) + spacing + size_label.width, size_label.height);
            }
        }

        return ret;
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            // Translate to align in center
            inContext.translate (Graphic.Point (area.extents.size.width / 2, area.extents.size.height / 2));
            inContext.translate (Graphic.Point (-size.width / 2, -size.height / 2));

            // Draw label
            base.paint (inContext, inArea);

            double size_width = size.height * 2.0;
            double size_height = size.height / 2.0;
            double offset = size.height / 4.0;

            // Draw switch box
            var path = new Graphic.Path ();
            path.rectangle (0, offset, size_width, size_height, size_height / 2.0, size_height / 2.0);
            inContext.pattern = shadow_pattern;
            inContext.fill (path);

            path = new Graphic.Path ();
            double start = size_height;
            double end = size_width - size_height;
            path.arc (start + (switch_progress * (end - start)), offset + (size_height / 2.0), size_height, size_height, 0, 2 * GLib.Math.PI);
            inContext.pattern = fill_pattern[Item.State.NORMAL] ?? new Graphic.Color (0.7, 0.7, 0.7);
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
