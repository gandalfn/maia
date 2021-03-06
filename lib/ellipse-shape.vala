/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * ellipse-shape.vala
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

public class Maia.EllipseShape : Shape
{
    // properties
    private Graphic.Point m_Begin;
    private Graphic.Point m_End;
    private double        m_Radius = 1.0;
    private double        m_Increment = 1.0;
    protected bool m_BeginClicked   = false;
    protected bool m_EndClicked     = false;
    protected bool m_EllipseClicked = false;

    // accessors
    internal override string tag {
        get {
            return "EllipseShape";
        }
    }

    public Graphic.Point begin {
        get {
            return m_Begin;
        }
        set {
            if (!m_Begin.equal (value))
            {
                m_Begin = value;
            }
        }
        default = Graphic.Point (-1, -1);
    }

    public Graphic.Point end {
        get {
            return m_End;
        }
        set {
            if (!m_End.equal (value))
            {
                m_End = value;
            }
        }
        default = Graphic.Point (-1, -1);
    }

    public double radius {
        get {
            return m_Radius;
        }
        set {
            if (m_Radius != value)
            {
                m_Radius = double.max (1.0, value);
            }
        }
        default = 1.0;
    }

    public double increment {
        get {
            return m_Increment;
        }
        set {
            if (m_Increment != value)
            {
                m_Increment = double.max (1.0, value);
            }
        }
        default = 1.0;
    }

    // methods
    construct
    {
        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);
    }

    public EllipseShape (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    clamp ()
    {
        var pos = position;

        // TODO take care of transform
        if (m_Begin.x < m_End.x && m_Begin.x >= 0)
        {
            pos.x += m_Begin.x;
            m_End.x -= m_Begin.x;
            m_Begin.x = 0;
        }
        else if (m_Begin.x > m_End.x && m_End.x >= 0)
        {
            pos.x += m_End.x;
            m_Begin.x -= m_End.x;
            m_End.x = 0;
        }

        if (m_Begin.y < m_End.y && m_Begin.y >= 0)
        {
            pos.y += m_Begin.y;
            m_End.y -= m_Begin.y;
            m_Begin.y = 0;
        }
        else if (m_Begin.y > m_End.y && m_End.y >= 0)
        {
            pos.y += m_End.y;
            m_Begin.y -= m_End.y;
            m_End.y = 0;
        }
        position = pos;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Size area = Graphic.Size (0, 0);

        clamp ();

        if (m_Begin.x < 0 && m_Begin.y < 0)
        {
            area.resize (caliper_size.width + (border * 2), caliper_size.height + (border * 2));
        }
        else if (m_End.x < 0 && m_End.y < 0)
        {
            double x1 = m_Begin.x;
            double y1 = m_Begin.y;

            if (x1 > 0)
            {
                var pos = position;
                pos.x += x1;
                if (pos.x < 0)
                {
                    x1 += -pos.x;
                    pos.x = 0;
                }
                else
                {
                    x1 = 0;
                }
                position = pos;

                m_Begin.x = x1;
            }

            if (y1 > 0)
            {
                var pos = position;
                pos.y += y1;
                if (pos.y < 0)
                {
                    y1 += -pos.y;
                    pos.y = 0;
                }
                else
                {
                    y1 = 0;
                }
                position = pos;

                m_Begin.y = y1;
            }

            area = Graphic.Size (double.max (x1, 0), double.max (y1, 0));
            area.resize (caliper_size.width + (border * 2), caliper_size.height + (border * 2));
        }
        else if (m_End.x >= 0 && m_End.y >= 0)
        {
            var areaEllipse = Graphic.Rectangle (0, 0, 0, 0);
            double width = GLib.Math.sqrt (((m_Begin.x - m_End.x) * (m_Begin.x - m_End.x)) + ((m_Begin.y - m_End.y) * (m_Begin.y - m_End.y)));
            areaEllipse.size.width = width;
            areaEllipse.size.height = m_Radius;

            double angle = GLib.Math.acos ((double.max (m_End.x, m_Begin.x) - double.min (m_End.x, m_Begin.x)) / areaEllipse.size.width);
            var transform = new Graphic.Transform.init_translate (areaEllipse.size.width / 2.0, areaEllipse.size.height / 2.0);
            transform.rotate (angle);
            areaEllipse.transform (transform);

            var begin = Graphic.Point (0, areaEllipse.size.height / 2.0);
            begin.transform (transform);
            var end = Graphic.Point (areaEllipse.size.width, areaEllipse.size.height / 2.0);
            end.transform (transform);

            area = areaEllipse.size;

            area.resize (caliper_size.width + (border * 2), caliper_size.height + (border * 2));
        }

        return area;
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            var item_area = area;
//~             var areaPath = new Graphic.Path ();
//~             areaPath.rectangle (0, 0, area.extents.size.width, area.extents.size.height);
//~             inContext.pattern = new Graphic.Color (1, 0, 0);
//~             inContext.stroke (areaPath);

            if (m_Begin.x >= 0 && m_Begin.y >= 0 && m_End.x >= 0 && m_End.y >= 0 && m_Radius >= 0)
            {
                Graphic.Point center = Graphic.Point ((m_Begin.x + m_End.x) / 2.0, (m_Begin.y + m_End.y) / 2.0);
                var areaEllipse = Graphic.Rectangle (0, 0, 0, 0);
                areaEllipse.size.width = GLib.Math.sqrt (((m_Begin.x - m_End.x) * (m_Begin.x - m_End.x)) + ((m_Begin.y - m_End.y) * (m_Begin.y - m_End.y)));
                areaEllipse.size.height = m_Radius;

                double angle = GLib.Math.acos ((double.max (m_End.x, m_Begin.x) - double.min (m_End.x, m_Begin.x)) / areaEllipse.size.width);
                if (m_End.y < m_Begin.y)
                {
                    angle *= -1.0;
                }
                if (m_End.x < m_Begin.x)
                {
                    angle *= -1.0;
                }

                var ellipse = new Graphic.Path ();
                ellipse.arc (0, 0, areaEllipse.size.width / 2.0, areaEllipse.size.height / 2.0, 0, 2 * GLib.Math.PI);

                inContext.save ();
                {
                    var transform = new Graphic.Transform.init_translate (item_area.extents.size.width / 2.0, item_area.extents.size.height / 2.0);
                    transform.rotate (angle);
                    inContext.transform = transform;

                    if (background_pattern[state] != null)
                    {
                        inContext.save ();
                        {
                            inContext.pattern = background_pattern[state];
                            inContext.translate (Graphic.Point (-1, 0));
                            inContext.stroke (ellipse);
                            inContext.translate (Graphic.Point (1, 0));

                            inContext.pattern = background_pattern[state];
                            inContext.translate (Graphic.Point (1, 0));
                            inContext.stroke (ellipse);
                            inContext.translate (Graphic.Point (-1, 0));

                            inContext.pattern = background_pattern[state];
                            inContext.translate (Graphic.Point (0, -1));
                            inContext.stroke (ellipse);
                            inContext.translate (Graphic.Point (0, 1));

                            inContext.pattern = background_pattern[state];
                            inContext.translate (Graphic.Point (0, 1));
                            inContext.stroke (ellipse);
                            inContext.translate (Graphic.Point (0, -1));
                        }
                        inContext.restore ();
                    }

                    inContext.pattern = stroke_pattern[state];
                    inContext.stroke (ellipse);
                }
                inContext.restore ();

                inContext.translate (Graphic.Point ((item_area.extents.size.width / 2.0) - center.x, (item_area.extents.size.height / 2.0) - center.y));
            }
            else
            {
                inContext.translate (Graphic.Point (item_area.extents.size.width / 2.0, item_area.extents.size.height / 2.0));
            }

            inContext.save ();
            {
                var begin_point = Graphic.Point (double.max (m_Begin.x, 0), double.max (m_Begin.y, 0));
                if (m_BeginClicked && (fill_pattern[state] as Graphic.Color) != null)
                {
                    var color = fill_pattern[state] as Graphic.Color;
                    var gradiant = new Graphic.RadialGradient (begin_point, 0, begin_point, double.max (caliper_size.width + border / 4.0, caliper_size.height + border / 4.0));
                    gradiant.add (new Graphic.Gradient.ColorStop (0, color));
                    gradiant.add (new Graphic.Gradient.ColorStop (0.8, new Graphic.Color (color.red, color.green, color.blue, 0.3)));
                    gradiant.add (new Graphic.Gradient.ColorStop (1, new Graphic.Color (color.red, color.green, color.blue, 0.0)));
                    inContext.pattern = gradiant;
                    var path = new Graphic.Path ();
                    path.arc (begin_point.x, begin_point.y, caliper_size.width + border / 4.0, caliper_size.height + border / 4.0, 0, 2* GLib.Math.PI);
                    inContext.fill (path);
                }

                inContext.translate (Graphic.Point (begin_point.x - caliper_size.width / 2.0, begin_point. y - caliper_size.height / 2.0));

                var caliper = new Graphic.Path.from_data (caliper.to_path (caliper_size));
                inContext.line_width = caliper_line_width;
                inContext.dash = Graphic.LineType.CONTINUE.to_dash (line_width);
                if (background_pattern[state] != null)
                {
                    inContext.save ();
                    {
                        inContext.pattern = background_pattern[state];
                        inContext.translate (Graphic.Point (-1, 0));
                        inContext.stroke (caliper);
                        inContext.translate (Graphic.Point (1, 0));

                        inContext.pattern = background_pattern[state];
                        inContext.translate (Graphic.Point (1, 0));
                        inContext.stroke (caliper);
                        inContext.translate (Graphic.Point (-1, 0));

                        inContext.pattern = background_pattern[state];
                        inContext.translate (Graphic.Point (0, -1));
                        inContext.stroke (caliper);
                        inContext.translate (Graphic.Point (0, 1));

                        inContext.pattern = background_pattern[state];
                        inContext.translate (Graphic.Point (0, 1));
                        inContext.stroke (caliper);
                        inContext.translate (Graphic.Point (0, -1));
                    }
                    inContext.restore ();
                }
                inContext.pattern = stroke_pattern[state];
                inContext.stroke (caliper);


            }
            inContext.restore ();

            if (m_End.x >= 0 && m_End.y >= 0)
            {
                inContext.save ();
                {
                    if (m_EndClicked && (fill_pattern[state] as Graphic.Color) != null)
                    {
                        var color = fill_pattern[state] as Graphic.Color;
                        var gradiant = new Graphic.RadialGradient (m_End, 0, m_End, double.max (caliper_size.width + border / 2.0, caliper_size.height + border / 2.0));
                        gradiant.add (new Graphic.Gradient.ColorStop (0, color));
                        gradiant.add (new Graphic.Gradient.ColorStop (0.8, new Graphic.Color (color.red, color.green, color.blue, 0.4)));
                        gradiant.add (new Graphic.Gradient.ColorStop (1, new Graphic.Color (color.red, color.green, color.blue, 0.0)));
                        inContext.pattern = gradiant;
                        var path = new Graphic.Path ();
                        path.arc (m_End.x, m_End.y, caliper_size.width + border / 2.0, caliper_size.height + border / 2.0, 0, 2* GLib.Math.PI);
                        inContext.fill (path);
                    }

                    inContext.translate (Graphic.Point (m_End.x - caliper_size.width / 2.0, m_End. y - caliper_size.height / 2.0));

                    var caliper = new Graphic.Path.from_data (caliper.to_path (caliper_size));
                    inContext.line_width = caliper_line_width;
                    inContext.dash = Graphic.LineType.CONTINUE.to_dash (line_width);
                    if (background_pattern[state] != null)
                    {
                        inContext.save ();
                        {
                            inContext.pattern = background_pattern[state];
                            inContext.translate (Graphic.Point (-1, 0));
                            inContext.stroke (caliper);
                            inContext.translate (Graphic.Point (1, 0));

                            inContext.pattern = background_pattern[state];
                            inContext.translate (Graphic.Point (1, 0));
                            inContext.stroke (caliper);
                            inContext.translate (Graphic.Point (-1, 0));

                            inContext.pattern = background_pattern[state];
                            inContext.translate (Graphic.Point (0, -1));
                            inContext.stroke (caliper);
                            inContext.translate (Graphic.Point (0, 1));

                            inContext.pattern = background_pattern[state];
                            inContext.translate (Graphic.Point (0, 1));
                            inContext.stroke (caliper);
                            inContext.translate (Graphic.Point (0, -1));
                        }
                        inContext.restore ();
                    }
                    inContext.pattern = stroke_pattern[state];
                    inContext.stroke (caliper);
                }
                inContext.restore ();
            }
        }
        inContext.restore ();
    }

    internal override void
    on_gesture (Gesture.Notification inNotification)
    {
        inNotification.proceed = true;
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (state == State.ACTIVE)
        {
            if (inButton == 1)
            {
                var item_area = area;
                Graphic.Point center = Graphic.Point ((m_Begin.x + m_End.x) / 2.0, (m_Begin.y + m_End.y) / 2.0);
                var begin_area = Graphic.Rectangle (m_Begin.x - (caliper_size.width / 2.0), m_Begin.y - (caliper_size.height / 2.0), caliper_size.width, caliper_size.height);
                var end_area = Graphic.Rectangle (m_End.x - (caliper_size.width / 2.0), m_End.y - (caliper_size.height / 2.0), caliper_size.width, caliper_size.height);
                begin_area.translate (Graphic.Point ((item_area.extents.size.width / 2.0) - center.x, (item_area.extents.size.height / 2.0) - center.y));
                end_area.translate (Graphic.Point ((item_area.extents.size.width / 2.0) - center.x, (item_area.extents.size.height / 2.0) - center.y));

                if (m_Begin.x < 0 && m_Begin.y < 0)
                {
                    Graphic.Point moved_point = inPoint;
                    if (moved_point.x < 0 || moved_point.y < 0)
                    {
                        position = Graphic.Point (double.max(0, position.x + (moved_point.x < 0 ? moved_point.x : 0)),
                                                  double.max(0, position.y + (moved_point.y < 0 ? moved_point.y : 0)));
                    }

                    m_Begin = Graphic.Point (double.max (0, moved_point.x), double.max (0, moved_point.y));
                    need_update = true;
                    geometry = null;

                    m_BeginClicked = true;

                    ret = true;
                }
                else if (!ret && m_End.x < 0 && m_End.y < 0)
                {
                    Graphic.Point moved_point = inPoint;
                    Graphic.Point static_point = m_Begin;
                    if (moved_point.x < 0 || moved_point.y < 0)
                    {
                        position = Graphic.Point (double.max(0, position.x + (moved_point.x < 0 ? moved_point.x : 0)),
                                                  double.max(0, position.y + (moved_point.y < 0 ? moved_point.y : 0)));
                        static_point.x += moved_point.x < 0 ? -moved_point.x : 0;
                        static_point.y += moved_point.y < 0 ? -moved_point.y : 0;
                    }

                    m_Begin = static_point;
                    m_End = Graphic.Point (double.max (0, moved_point.x), double.max (0, moved_point.y));
                    m_Radius = double.max (1.0, m_Radius);

                    need_update = true;
                    geometry = null;

                    m_EndClicked = true;

                    ret = true;
                }
                else if (m_Begin.x >= 0 && m_Begin.y >= 0 && inPoint in begin_area)
                {
                    m_BeginClicked = true;
                }
                else if (m_End.x >= 0 && m_End.y >= 0 && inPoint in end_area)
                {
                    m_EndClicked = true;
                }
            }
            else if (inButton == 4)
            {
                m_Radius = double.max (m_Radius - m_Increment, 1.0);
                need_update = true;
                geometry = null;
            }
            else if (inButton == 5)
            {
                m_Radius += m_Increment;
                need_update = true;
                geometry = null;
            }
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_release_event (inButton, inPoint);

        if (inButton == 1 && state == State.ACTIVE)
        {
            m_BeginClicked = false;
            m_EndClicked = false;

            damage.post ();
        }

        return ret;
    }

    internal override bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = base.on_motion_event (inPoint);

        if (state == State.ACTIVE)
        {
            if (m_BeginClicked || m_EndClicked)
            {
                var item_area = area;
                Graphic.Point center = Graphic.Point ((m_Begin.x + m_End.x) / 2.0, (m_Begin.y + m_End.y) / 2.0);
                Graphic.Point moved_point = inPoint;
                Graphic.Point static_point = m_BeginClicked ? m_End : m_Begin;

                moved_point.translate (Graphic.Point (center.x - (item_area.extents.size.width / 2.0), center.y - (item_area.extents.size.height / 2.0)));

                if (moved_point.x < 0 || moved_point.y < 0)
                {
                    var pos = position;
                    var static_pos = pos;
                    static_pos.translate (static_point);
                    pos.x += moved_point.x < 0 ? moved_point.x : 0;
                    pos.y += moved_point.y < 0 ? moved_point.y : 0;
                    if (pos.x < 0)
                    {
                        moved_point.x -= pos.x;
                        pos.x = 0;
                    }
                    if (pos.y < 0)
                    {
                        moved_point.y -= pos.y;
                        pos.y = 0;
                    }
                    position = pos;

                    static_point.x = static_pos.x - pos.x;
                    static_point.y = static_pos.y - pos.y;
                }

                if (m_BeginClicked)
                {
                    m_Begin = Graphic.Point (double.max (0, moved_point.x), double.max (0, moved_point.y));

                    if (m_End.x >= 0 && m_End.y >= 0)
                    {
                        m_End = static_point;
                    }
                }
                else if (m_EndClicked)
                {
                    m_End = Graphic.Point (double.max (0, moved_point.x), double.max (0, moved_point.y));
                    m_Begin = static_point;
                }
                need_update = true;
                geometry = null;
            }
        }

        return ret;
    }
}
