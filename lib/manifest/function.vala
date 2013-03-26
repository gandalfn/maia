/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * function.vala
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

public class Maia.Manifest.Function : Attribute
{
    /**
     * Create a new function attribute
     *
     * @param inFunctionName function name
     */
    public Function (string inFunctionName)
    {
        base (inFunctionName);
    }

    public void
    parse (AttributeScanner inScanner) throws ParseError
    {
        foreach (Parser.Token token in inScanner)
        {
            switch (token)
            {
                case Parser.Token.START_ELEMENT:
                    Function function = new Function (inScanner.element);
                    function.parent = this;
                    function.parse (inScanner);
                    break;

                case Parser.Token.END_ELEMENT:
                    if (inScanner.element == get ())
                        return;
                    break;

                case Parser.Token.ATTRIBUTE:
                    Attribute attr = new Attribute (inScanner.attribute);
                    attr.parent = this;
                    break;

                case Parser.Token.EOF:
                    break;
            }
        }
    }
}
