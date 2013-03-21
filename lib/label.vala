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

public class Maia.Label : Widget, Element
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
            inContext.pattern = color;
            inContext.render (m_Glyph);
            inContext.restore ();
        }
        catch (Graphic.Error err)
        {
            Log.critical (GLib.Log.METHOD, "Error on paint: %s", err.message);
        }
    }

    public override void
    get_requested_size (out Graphic.Size outSize)
    {
        if (device != null)
        {
            m_Glyph = new Graphic.Glyph (font_description);
            m_Glyph.text = text;
            Graphic.Context context = new Graphic.Context (device);
            m_Glyph.update (context);
            outSize = m_Glyph.size;
        }
        else
            base.get_requested_size (out outSize);
    }
}
