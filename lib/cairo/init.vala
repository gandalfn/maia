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
    save_document (string inPdfFilename, double inDpi, Document inDocument, GLib.Cancellable? inCancellable = null) throws Graphic.Error
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
        inDocument.update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, doc_size.width, doc_size.height)));

        // Draw document pages
        for (int cpt = 0; cpt < inDocument.nb_pages; ++cpt)
        {
            if (inCancellable != null && inCancellable.is_cancelled())
            {
                return;
            }
            inDocument.draw_page (ctx, cpt + 1);
            pdf_surface.show_page ();
            GLib.Idle.add (save_document.callback);
            yield;
        }

        // Invalidate document geometry for display refresh
        inDocument.geometry = null;
    }

    public static async void
    generate_report (string inPdfFilename, double inDpi, Document[] inDocuments, GLib.Cancellable? inCancellable = null) throws Graphic.Error
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

        foreach (unowned Document document in inDocuments)
        {
            // Repaginate document
            document.position = Graphic.Point (0, 0);
            var doc_size = document.size;
            document.update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, doc_size.width, doc_size.height)));

            // Draw document pages
            for (int cpt = 0; cpt < document.nb_pages; ++cpt)
            {
                if (inCancellable != null && inCancellable.is_cancelled())
                {
                    return;
                }
                document.draw_page (ctx, cpt + 1);
                pdf_surface.show_page ();
                GLib.Idle.add (generate_report.callback);
                yield;
            }

            // Invalidate document geometry for display refresh
            document.geometry = null;
        }
    }

    public static void
    document_page_to_png (string inPngFilename, Document inDocument, uint inNumPage) throws Graphic.Error
    {
        // Get document page format
        Graphic.Size size = inDocument.format.to_size ();

        // Create Surface
        Graphic.Surface surface = new Graphic.Surface ((int)size.width, (int)size.height);

        // Create context
        Context ctx = new Context (surface);

        // Repaginate document
        inDocument.geometry = null;
        var doc_size = inDocument.size;
        inDocument.update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, doc_size.width, doc_size.height)));

        // Draw document page
        inDocument.draw_page (ctx, inNumPage);

        // Save surface onto png
        (surface as Surface).surface.write_to_png (inPngFilename);

        // Invalidate document geometry for display refresh
        inDocument.geometry = null;
    }
}
