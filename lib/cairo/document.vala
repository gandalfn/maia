/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * document.vala
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

internal class Maia.Cairo.Document : Maia.Document
{
    // methods
    public Document (string inId, PageFormat inFormat)
    {
        base (inId, inFormat);
    }

    public override async void
    save (string inPdfFilename, double inDpi, GLib.Cancellable? inCancellable = null) throws Graphic.Error
    {
        // Get document page format
        Graphic.Size size = format.to_size ();

        // Create pdf surface
        global::Cairo.PdfSurface pdf_surface = new global::Cairo.PdfSurface (inPdfFilename, size.width, size.height);
        pdf_surface.set_fallback_resolution (inDpi, inDpi);

        // Create Surface
        Surface surface = new Surface (pdf_surface, (int)size.width, (int)size.height);

        // Create context
        Context ctx = new Context (surface);

        // Repaginate document
        geometry = null;
        var doc_size = size;

        // Draw document pages
        for (int cpt = 0; cpt < nb_pages; ++cpt)
        {
            if (inCancellable != null && inCancellable.is_cancelled())
            {
                return;
            }
            update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, doc_size.width, doc_size.height)));
            draw_page (ctx, cpt + 1);
            pdf_surface.show_page ();
            GLib.Idle.add (save.callback);
            yield;
        }

        // Invalidate document geometry for display refresh
        geometry = null;

        pdf_surface.flush ();
        pdf_surface.finish ();
    }
}
