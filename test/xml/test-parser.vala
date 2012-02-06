/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-parser.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

public class Maia.TestParser : Maia.TestCase
{
    const string cSimpleXML = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                              "<!-- Comment -->" +
                              "<root>" +
                              "    <element1 property1=\"e1val1\" property2=\"e1val2\"/>" +
                              "    <element2 property1=\"e2val1\" property2=\"e2val2\" property3=\"e2val3\">" +
                              "         e2text" +
                              "    </element2>" +
                              " </root>";

    public TestParser ()
    {
        base ("parser");

        add_test ("simple", test_parser_simple);
        //add_test ("filename", test_parser_file);
    }

    public void
    test_parser_simple ()
    {
        try
        {
            Maia.XmlParser parser = new Maia.XmlParser.from_buffer (cSimpleXML, cSimpleXML.length);

            foreach (Maia.Parser.Token token in parser)
            {
                switch (token)
                {
                    case Maia.Parser.Token.START_ELEMENT:
                        assert (parser.element != null);
                        Test.message ("Start element %s", parser.element);

                        if (parser.element == "root")
                            assert (parser.attributes.length == 0);

                        if (parser.element == "element1")
                            assert (parser.attributes.length == 2);

                        if (parser.element == "element2")
                            assert (parser.attributes.length == 3);

                        foreach (Maia.Pair<string, string> attribute in parser.attributes)
                        {
                            Test.message ("  attribute %s: %s", attribute.first, attribute.second);

                            if (parser.element == "element1")
                            {
                                if (attribute.first == "property1")
                                    assert (attribute.second == "e1val1");
                                if (attribute.first == "property2")
                                    assert (attribute.second == "e1val2");
                            }
                            if (parser.element == "element2")
                            {
                                if (attribute.first == "property1")
                                    assert (attribute.second == "e2val1");
                                if (attribute.first == "property2")
                                    assert (attribute.second == "e2val2");
                                if (attribute.first == "property3")
                                    assert (attribute.second == "e2val3");
                            }
                        }
                        break;
                    case Maia.Parser.Token.END_ELEMENT:
                        assert (parser.element != null);
                        Test.message ("End element %s", parser.element);
                        break;
                    case Maia.Parser.Token.CHARACTERS:
                        assert (parser.element != null);
                        assert (parser.characters != null);
                        Test.message ("  characters: %s", parser.characters);
                        assert (parser.element == "element2");
                        break;
                    default:
                        assert(false);
                        break;
                }
            }
        }
        catch (Maia.ParseError err)
        {
            Test.message ("%s", err.message);
            assert (false);
        }
    }

    public void
    test_parser_file ()
    {
        try
        {
            Maia.XmlParser parser = new Maia.XmlParser("test-parser.xml");

            foreach (Maia.Parser.Token token in parser)
            {
                switch (token)
                {
                    case Maia.Parser.Token.START_ELEMENT:
                        assert (parser.element != null);
                        Test.message ("Start element %s", parser.element);
                        foreach (Maia.Pair<string, string> attribute in parser.attributes)
                        {
                            Test.message ("  attribute %s: %s", attribute.first, attribute.second);
                        }
                        break;
                    case Maia.Parser.Token.END_ELEMENT:
                        assert (parser.element != null);
                        Test.message ("End element %s", parser.element);
                        break;
                    case Maia.Parser.Token.CHARACTERS:
                        assert (parser.element != null);
                        assert (parser.characters != null);
                        Test.message ("  characters: %s", parser.characters);
                        break;
                    default:
                        assert(false);
                        break;
                }
            }
        }
        catch (Maia.ParseError err)
        {
            Test.message ("%s", err.message);
            assert (false);
        }
    }
}