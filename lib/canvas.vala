/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * canvas.vala
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

public interface Maia.Canvas : GLib.Object
{
    // accessors
    public abstract Window window { get; }
    public abstract Item   root   { get; set; default = null; }

    // methods
    /**
     * Clear canvas
     */
    public void
    clear ()
    {
        if (root != null) root.parent = null;

        root = null;
    }

    /**
     * Load canvas mainfest
     *
     * @param inManifest manifest content buffer
     * @param inRoot root id in manifest
     *
     * @throws ParseError when somethings goes wrong
     */
    public void
    load (string inManifest, string? inRoot = null) throws Core.ParseError
    {
        // clear canvas
        clear ();

        // Load manifest
        Manifest.Document manifest = new Manifest.Document.from_buffer (inManifest, inManifest.length);

        // Load manifest content
        root = manifest[inRoot] as Item;
    }

    /**
     * Load canvas mainfest
     *
     * @param inFilename manifest filename
     * @param inRoot root id in manifest
     *
     * @throws ParseError when somethings goes wrong
     */
    public void
    load_from_file (string inFilename, string? inRoot = null) throws Core.ParseError
    {
        // clear canvas
        clear ();

        // Load manifest
        Manifest.Document manifest = new Manifest.Document (inFilename);

        // Load manifest content
        root = manifest[inRoot] as Item;
    }
}
