/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * init.vala
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

namespace Maia.Cairo
{
    static bool s_Initialized = false;

    public static void
    init ()
    {
        if (!s_Initialized)
        {
            Core.Any.delegate (typeof (Graphic.Region),   typeof (Region));
            Core.Any.delegate (typeof (Graphic.Glyph),    typeof (Glyph));
            Core.Any.delegate (typeof (Graphic.Surface),  typeof (Surface));
            Core.Any.delegate (typeof (Graphic.Context),  typeof (Context));
            Core.Any.delegate (typeof (Graphic.ImagePng), typeof (ImagePng));

            s_Initialized = true;
        }
    }

    public static async void
    save_document (string inPdfFilename, double inDpi, owned Document inDocument, GLib.Cancellable? inCancellable = null) throws Graphic.Error
    {
        // Get document page format
        Graphic.Size size = inDocument.format.to_size ();

        // Create pdf surface
        global::Cairo.PdfSurface pdf_surface = new global::Cairo.PdfSurface (inPdfFilename, size.width, size.height);
        pdf_surface.set_fallback_resolution (inDpi, inDpi);

        // Create Surface
        Surface surface = new Surface (pdf_surface, (int)size.width, (int)size.height);

        // Create context
        Context ctx = new Context (surface);

        // Repaginate document
        inDocument.geometry = null;
        var doc_size = inDocument.size;

        // Draw document pages
        for (int cpt = 0; cpt < inDocument.nb_pages; ++cpt)
        {
            if (inCancellable != null && inCancellable.is_cancelled())
            {
                return;
            }
            inDocument.update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, doc_size.width, doc_size.height)));
            inDocument.draw_page (ctx, cpt + 1);
            pdf_surface.show_page ();
            GLib.Idle.add (save_document.callback);
            yield;
        }

        // Invalidate document geometry for display refresh
        inDocument.geometry = null;

        pdf_surface.flush ();
        pdf_surface.finish ();
    }

    public static async void
    generate_report (string inPdfFilename, double inDpi, owned Document[] inDocuments, GLib.Cancellable? inCancellable = null) throws Graphic.Error
        requires (inDocuments.length > 0)
    {
        // Get document page format
        Graphic.Size size = inDocuments[0].format.to_size ();

        // Create pdf surface
        global::Cairo.PdfSurface pdf_surface = new global::Cairo.PdfSurface (inPdfFilename, size.width, size.height);
        pdf_surface.set_fallback_resolution (inDpi, inDpi);

        // Create Surface
        Surface surface = new Surface (pdf_surface, (int)size.width, (int)size.height);

        // Create context
        Context ctx = new Context (surface);

        // Calculate the number of pages
        uint nb_pages = 0;
        Graphic.Size doc_size = Graphic.Size (0, 0);
        foreach (unowned Document document in inDocuments)
        {
            // Repaginate document
            document.position = Graphic.Point (0, 0);
            doc_size = document.size;

            nb_pages += document.nb_pages;
        }

        uint start = 0;
        foreach (unowned Document document in inDocuments)
        {
            // Set delta and nb pages
            document.set_qdata<uint> (Document.s_PageBeginQuark, start);
            document.set_qdata<uint> (Document.s_PageTotalQuark, nb_pages);

            // Repaginate document
            document.position = Graphic.Point (0, 0);
            doc_size = document.size;
            start += document.nb_pages;

            // Draw document pages
            for (int cpt = 0; cpt < document.nb_pages; ++cpt)
            {
                if (inCancellable != null && inCancellable.is_cancelled())
                {
                    return;
                }
                document.update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, doc_size.width, doc_size.height)));
                document.draw_page (ctx, cpt + 1);
                pdf_surface.show_page ();
                pdf_surface.flush ();
                GLib.Idle.add (generate_report.callback);
                yield;
            }

            // unset delta and nb pages
            document.set_qdata<uint> (Document.s_PageBeginQuark, 0);
            document.set_qdata<uint> (Document.s_PageTotalQuark, 0);

            // Invalidate document geometry for display refresh
            document.geometry = null;
        }
        pdf_surface.flush ();
        pdf_surface.finish ();

        GLib.Idle.add (generate_report.callback);
        yield;
    }
}
