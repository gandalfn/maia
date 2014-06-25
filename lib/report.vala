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

public class Maia.Report : Core.Object
{
    // accessors
    public Core.Array<Document> documents { get; private set; }
    public string filename { get; construct; default = null; }
    public double resolution { get; construct; default = 96; }
    
    // methods
    construct
    {
        documents = new Core.Array<Document> ();
    }

    public Report (string inPdfFilename, double inDpi = 96)
    {
        GLib.Object (filename: inPdfFilename, resolution: inDpi);
    }
    
    public void
    add_document (Document inDocument)
    {
        documents.insert (inDocument);
    }

    public void
    remove_document (Document inDocument)
    {
        documents.remove (inDocument);
    }

    public virtual async void
    save (GLib.Cancellable? inCancellable = null) throws Graphic.Error
        requires (documents.length > 0)
    {
        throw new Graphic.Error.NOT_IMPLEMENTED ("Report save not implemented");
    }
}
