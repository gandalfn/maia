/*
 * surface-field.vala
 * Copyright (C) Nicolas Bruguier 2010-2015 <gandalfn@club-internet.fr>
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

internal class Maia.Protocol.SurfaceField : Field
{
    // accessors
    internal override Field.Type field_type {
        get {
            return Field.Type.SURFACE;
        }
    }

    internal override string @default {
        set {
        }
    }

    // methods
    public SurfaceField (string inName, bool inRepeated, string? inDefault)
    {
        base (inName, inRepeated, inDefault);
    }

    protected override GLib.Value
    create_value ()
    {
        GLib.Value ret = GLib.Value (field_type.to_gtype ());
        ret = new Graphic.Surface (1, 1);
        return ret;
    }

    internal override GLib.Variant
    get_variant (int inIndex)
        requires (inIndex < m_Values.length)
    {
        return ((Graphic.Surface)m_Values[inIndex]).serialize;
    }

    internal override void
    set_variant (int inIndex, GLib.Variant inVariant)
        requires (inIndex < m_Values.length)
        //requires (inVariant.get_type ().equal (field_type.to_variant_type ()))
    {
        ((Graphic.Surface)m_Values[inIndex]).serialize = inVariant;
    }
}
