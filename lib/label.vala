/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * label.vala
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

public class Maia.Label : Widget, Manifest.Element
{
    // properties
    private Graphic.Glyph m_Glyph;

    // accessors
    public string tag {
        get {
            return "Label";
        }
    }

    public string font_description { get; construct set; default = null; }
    public string text             { get; construct set; default = null; }
    public Graphic.Color color     { get; construct set; default = null; }

    /**
     * {@inheritDoc}
     */
    public override Graphic.Size natural_size {
        get {
            if (device != null)
            {
                m_Glyph = new Graphic.Glyph (font_description);
                m_Glyph.text = text;
                Graphic.Context context = new Graphic.Context (device);
                m_Glyph.update (context);

                Graphic.Size size = m_Glyph.size;
                size.width += border * 2;
                size.height += border * 2;
                return size;
            }

            return ((View)this).natural_size;
        }
    }

    // methods
    public Label (string inText)
    {
        GLib.Object (text: inText);
    }

    public override void
    paint (Graphic.Context inContext, Graphic.Region inArea)
    {
        try
        {
            Graphic.Path clip_path = new Graphic.Path.from_region (inArea);
            inContext.save ();
            inContext.clip (clip_path);

            Graphic.LinearGradient gradient = new Graphic.LinearGradient ({ 0, 0 }, { 0, m_Glyph.size.height });
            gradient.add (new Graphic.Gradient.ColorStop (0,   new Graphic.Color (0.8, 0.8, 0.8, 1.0)));
            gradient.add (new Graphic.Gradient.ColorStop (0.5, new Graphic.Color (0.3, 0.3, 0.3, 1.0)));
            gradient.add (new Graphic.Gradient.ColorStop (1,   new Graphic.Color (0.1, 0.1, 0.1, 1.0)));
            inContext.pattern = gradient;
            Graphic.Path path = new Graphic.Path ();
            path.rectangle (0, 0, natural_size.width, natural_size.height, 5, 5);
            inContext.fill (path);

            inContext.translate ({ border, border });
            inContext.pattern = color;
            inContext.render (m_Glyph);
            inContext.restore ();
        }
        catch (Graphic.Error err)
        {
            Log.critical (GLib.Log.METHOD, "Error on paint: %s", err.message);
        }
    }
}
