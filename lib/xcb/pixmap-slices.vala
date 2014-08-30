/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * pixmap-cache.vala
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

internal class Maia.Xcb.PixmapSlices : GLib.Object
{
    // types
    private struct Slice
    {
        // properties
        public Graphic.Point position;
        public Xcb.Pixmap    pixmap;

        // methods
        public Slice (int inScreen, int inDepth, Graphic.Rectangle inArea)
        {
            // Set position
            position = inArea.origin;

            // Create pixmap
            pixmap = new Xcb.Pixmap (inScreen, (uint8)inDepth, (int)inArea.size.width, (int)inArea.size.height);
        }
    }

    // properties
    private Graphic.Size m_Size = Graphic.Size (0, 0);
    private Slice[,]     m_Slices = null;

    // accessors
    public int screen { get; construct; default = 0; }

    public int depth { get; construct; default = 32; }

    public Graphic.Size slice_size { get; construct; }

    public Graphic.Size size {
        get {
            return m_Size;
        }
        set {
            if (!m_Size.equal (value))
            {
                m_Size = Graphic.Size (double.max (1, value.width), double.max (1, value.height));

                Slice[,] old_nodes = null;

                if (m_Slices != null) old_nodes = m_Slices;

                allocate ();

                if (old_nodes != null)
                {
                    for (int row = 0; row < old_nodes.length[0]; ++row)
                    {
                        for (int column = 0; column < old_nodes.length[1]; ++column)
                        {
                            var slice_area = Graphic.Rectangle (0, 0,
                                                               old_nodes[row, column].pixmap.size.width,
                                                               old_nodes[row, column].pixmap.size.height);

                            set (old_nodes[row, column].pixmap, old_nodes[row, column].position, slice_area);
                        }
                    }
                }
            }
        }
    }

    // methods
    public PixmapSlices (int inScreen, int inDepth, Graphic.Size inSliceSize, Graphic.Size inSize)
    {
        GLib.Object (screen: inScreen, depth: inDepth, slice_size: inSliceSize, size: inSize);
    }

    private void
    allocate ()
        requires (!size.is_empty ())
    {
        Graphic.Size pixmap_size = Graphic.Size (double.min (slice_size.width, size.width),
                                                 double.min (slice_size.height, size.height));

        int columns = (int)GLib.Math.floor (size.width / slice_size.width) + 1;
        int rows = (int)GLib.Math.floor (size.height / slice_size.height) + 1;
        m_Slices = new Slice[rows, columns];

        for (int row = 0; row < rows; ++row)
        {
            for (int column = 0; column < columns; ++column)
            {
                Graphic.Rectangle area = Graphic.Rectangle (column * pixmap_size.width, row * pixmap_size.height,
                                                            double.min (pixmap_size.width, size.width - (column * pixmap_size.width)),
                                                            double.min (pixmap_size.height, size.height - (row * pixmap_size.height)));
                m_Slices[row, column] = Slice (screen, depth, area);
            }
        }
    }

    public new void
    get (Pixmap inPixmap, Graphic.Point inPosition, Graphic.Rectangle inRepaintArea)
    {
        Graphic.Rectangle src_area = Graphic.Rectangle (inPosition.x, inPosition.y, inPixmap.size.width, inPixmap.size.height);
        src_area.intersect (inRepaintArea);

        for (int row = 0; row < m_Slices.length[0]; ++row)
        {
            for (int column = 0; column < m_Slices.length[1]; ++column)
            {
                Graphic.Rectangle dst_area = Graphic.Rectangle (m_Slices[row, column].position.x,
                                                                m_Slices[row, column].position.y,
                                                                m_Slices[row, column].pixmap.size.width,
                                                                m_Slices[row, column].pixmap.size.height);
                dst_area.intersect (src_area);

                if (!dst_area.is_empty ())
                {
                    Graphic.Point pos = dst_area.origin;
                    pos.translate (inPosition.invert ());
                    dst_area.translate (m_Slices[row, column].position.invert ());

                    m_Slices[row, column].pixmap.copy_area (inPixmap, dst_area, pos);
                }
            }
        }
    }

    public new void
    set (Pixmap inPixmap, Graphic.Point inPosition, Graphic.Rectangle inRepaintArea)
    {
        Graphic.Rectangle src_area = Graphic.Rectangle (inPosition.x, inPosition.y, inPixmap.size.width, inPixmap.size.height);
        src_area.intersect (inRepaintArea);

        for (int row = 0; row < m_Slices.length[0]; ++row)
        {
            for (int column = 0; column < m_Slices.length[1]; ++column)
            {
                Graphic.Rectangle dst_area = Graphic.Rectangle (m_Slices[row, column].position.x,
                                                                m_Slices[row, column].position.y,
                                                                m_Slices[row, column].pixmap.size.width,
                                                                m_Slices[row, column].pixmap.size.height);
                Graphic.Rectangle tmp = src_area;
                tmp.intersect (dst_area);
                if (!tmp.is_empty ())
                {
                    Graphic.Point pos = tmp.origin;
                    pos.translate (m_Slices[row, column].position.invert ());
                    tmp.translate (inPosition.invert ());

                    inPixmap.copy_area (m_Slices[row, column].pixmap, tmp, pos);
                }
            }
        }
    }
}
