/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * report.vala
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

internal class Maia.Cairo.Report : Maia.Report
{
    // methods
    public Report (string inPdfFilename, double inDpi = 96)
    {
        base (inPdfFilename, inDpi);
    }

    public override async void
    save (GLib.Cancellable? inCancellable = null) throws Graphic.Error
        requires (documents.length > 0)
    {
        // Get document page format
        Graphic.Size size = documents[0].format.to_size ();

        // Create pdf surface
        global::Cairo.PdfSurface pdf_surface = new global::Cairo.PdfSurface (filename, size.width, size.height);
        pdf_surface.set_fallback_resolution (resolution, resolution);

        // Create Surface
        Maia.Graphic.Surface surface = new Maia.Graphic.Surface.from_native (pdf_surface, (int)size.width, (int)size.height);

        // Create context
        Maia.Graphic.Context ctx = new Maia.Graphic.Context (surface);

        // Calculate the number of pages
        uint nb_pages = 0;
        Graphic.Size doc_size = Graphic.Size (0, 0);
        foreach (unowned Maia.Document document in documents)
        {
            // Repaginate document
            document.need_update = true;
            doc_size = document.size;

            // Count nb pages
            nb_pages += document.nb_pages;
        }

        uint start = 0;
        foreach (unowned Maia.Document document in documents)
        {
            // Set delta and nb pages
            document.set_qdata<uint> (Maia.Document.s_PageBeginQuark, start);
            document.set_qdata<uint> (Maia.Document.s_PageTotalQuark, nb_pages);

            // Notify start page change
            GLib.Signal.emit_by_name (document, "notify::start_page");

            // Notify nb pages changed
            GLib.Signal.emit_by_name (document, "notify::nb_pages");

            // Get document size
            doc_size = document.size;

            // Draw document pages
            for (int cpt = 0; cpt < document.nb_pages; ++cpt)
            {
                if (inCancellable != null && inCancellable.is_cancelled())
                {
                    return;
                }
                document.update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, doc_size.width, doc_size.height)));
                document.damage_area ();
                document.draw_page (ctx, cpt + 1);
                pdf_surface.show_page ();
                pdf_surface.flush ();
                GLib.Idle.add (save.callback);
                yield;
            }

            // unset delta and nb pages
            document.set_qdata<uint> (Maia.Document.s_PageBeginQuark, 0);
            document.set_qdata<uint> (Maia.Document.s_PageTotalQuark, 0);

            // Notify nb pages changes
            GLib.Signal.emit_by_name (document, "notify::start_page");

            // Notify nb pages changed
            GLib.Signal.emit_by_name (document, "notify::nb_pages");

            // Increment start page
            start += document.nb_pages;

            // force repaginate on next redraw
            document.need_update = true;
        }
        pdf_surface.flush ();
        pdf_surface.finish ();

        GLib.Idle.add (save.callback);
        yield;
    }
}
