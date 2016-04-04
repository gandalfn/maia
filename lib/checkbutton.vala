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
    // accessors
    internal override string tag {
        get {
            return "CheckButton";
        }
    }

    public double spacing { get; set; default = 5; }
    public StatePatterns line_pattern { get; set; }

    // methods
    construct
    {
        fill_pattern[State.NORMAL] = new Graphic.Color (1, 1, 1);
        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);
        line_pattern = new StatePatterns.va (State.NORMAL, new Graphic.Color (0, 0, 0));
    }

    public CheckButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    internal override Graphic.Size
    childs_size_request ()
    {
        Graphic.Size ret = Graphic.Size (0, 0);

        if (content != null)
        {
            var area = Graphic.Rectangle (0, 0, border * 2.0, border * 2.0);

            // get size of label
            Graphic.Size content_size = content.size;

            if (content_size.is_empty () || label == null || label.length == 0 || label.strip().length == 0)
            {
                // create a fake label
                var label = new Label ("fake", "Z");
                content_size = label.size;
                print(@"$content_size\n");
            }

            area.union_ (Graphic.Rectangle (border + content_size.height + spacing, border, content_size.width, content_size.height));
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

            if (content != null)
            {
                var item_size = area.extents.size;
                item_size.resize (-border * 2.0, -border * 2.0);
                var content_size = content.size;
                content.update (inContext, new Graphic.Region (Graphic.Rectangle (border + content_size.height + spacing,
                                                                                  border + ((item_size.height - content_size.height) / 2.0),
                                                                                  item_size.width, content_size.height)));
            }

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            var content_size = content.size;

            // Draw content
            if (content_size.is_empty () || label == null || label.length == 0 || label.strip().length == 0)
            {
                base.paint (inContext, inArea);
            }

            var item_size = area.extents.size;
            item_size.resize (-border * 2.0, -border * 2.0);

            // Translate to align in height center
            inContext.translate (Graphic.Point (border, double.max (border, border + (item_size.height - content_size.height) / 2)));

            // Paint check box
            Graphic.Color color = fill_pattern[state] as Graphic.Color ?? new Graphic.Color (0.7, 0.7, 0.7);
            Graphic.Color shade = new Graphic.Color.shade (color, 0.6);

            var path = new Graphic.Path ();
            path.rectangle (0, 0, content_size.height, content_size.height, 5, 5);
            inContext.pattern = shade;
            inContext.fill (path);

            path = new Graphic.Path ();
            path.rectangle (1.5, 1.5, content_size.height - 3, content_size.height - 3, 5, 5);
            inContext.pattern = color;
            inContext.fill (path);

            // Paint check if active
            if (active)
            {
                path = new Graphic.Path ();
                path.move_to (0.5 + (content_size.height * 0.2), (content_size.height * 0.5));
                path.line_to (0.5 + (content_size.height * 0.4), (content_size.height * 0.7));
                path.curve_to (0.5 + (content_size.height * 0.4), (content_size.height * 0.7),
                               0.5 + (content_size.height * 0.5), (content_size.height * 0.4),
                               0.5 + (content_size.height * 0.70), (content_size.height * 0.05));
                inContext.pattern = line_pattern[state];
                inContext.stroke (path);
            }
        }
        inContext.restore ();
    }
}
