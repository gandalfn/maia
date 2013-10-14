/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * image.vala
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

public abstract class Maia.Graphic.Image : Graphic.Pattern
{
    // accessors
    public virtual string?           filename  { get; set; default = null; }
    public virtual Graphic.Size      size      { get; set; default = Graphic.Size (0, 0); }
    public virtual Graphic.Transform transform { get; set; default = new Graphic.Transform.identity (); }
    public virtual Surface? surface {
        get {
            return null;
        }
    }

    // methods
    public static Image?
    create (string inFilename, Graphic.Size inSize = Graphic.Size (0, 0))
    {
        Image? ret = null;

        if (GLib.FileUtils.test (inFilename, GLib.FileTest.EXISTS) && !GLib.FileUtils.test (inFilename, GLib.FileTest.IS_DIR))
        {
            var file = GLib.File.new_for_path (inFilename);

            try
            {
                var info = file.query_info (GLib.FileAttribute.STANDARD_CONTENT_TYPE, 0);
                string content = info.get_content_type ();
                Log.debug (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "filename: %s content: %s", inFilename, content);
                switch (content)
                {
                    case "image/png":
                        ret = GLib.Object.new (typeof (ImagePng), filename: inFilename, size: inSize) as Image;
                        break;

                    case "image/jpg":
                    case "image/jpeg":
                        ret = GLib.Object.new (typeof (ImageJpg), filename: inFilename, size: inSize) as Image;
                        break;

                    case "image/svg":
                    case "image/svg+xml":
                        ret = GLib.Object.new (typeof (ImageSvg), filename: inFilename, size: inSize) as Image;
                        break;

                    case "image/gif":
                        ret = GLib.Object.new (typeof (ImageGif), filename: inFilename, size: inSize) as Image;
                        break;

                    default:
                        Log.error (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "%s unknown image type %s", inFilename, content);
                        break;
                }
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "Error on load filename %s: %s", inFilename, err.message);
            }
        }
        else
        {
            Log.debug (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, "Invalid filename %s", inFilename);
        }

        return ret;
    }
}
