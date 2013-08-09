/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-document.vala
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

public class Maia.TestDocument : Maia.TestCase
{
    public TestDocument ()
    {
        base ("document");

        add_test ("load", test_document_load);
        add_test ("parse", test_document_parse);
        add_test ("characters", test_document_characters);
    }

    public void
    test_document_load ()
    {
        string test = "Document.doc {" +
                      "}";

        try
        {
            new Manifest.Document.from_buffer (test, test.length);
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }
    }

    public void
    test_document_parse ()
    {
        string test =   "Document.doc {" +
                        "   prop1: property1;" +
                        "   prop2: property2;" +
                        "   Element.element1 {" +
                        "       prop1: propertyelement1;" +
                        "       prop2: propertyelement2;" +
                        "   }" +
                        "}";

        string[] elements = {};
        string[] attributes = {};
        string[] values = {};

        try
        {
            var manifest = new Manifest.Document.from_buffer (test, test.length);
            foreach (Core.Parser.Token token in manifest)
            {
                switch (token)
                {
                    case Core.Parser.Token.START_ELEMENT:
                        elements += manifest.element_tag + "." + manifest.element_id;
                        break;

                    case Core.Parser.Token.ATTRIBUTE:
                        attributes += manifest.attribute;
                        values += (string)manifest.scanner.transform (typeof (string));
                        break;
                }
            }
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }
        catch (Manifest.Error err)
        {
            Test.message (err.message);
            assert (false);
        }

        assert (elements.length == 2);
        assert (attributes.length == 4);
        assert (values.length == 4);
        assert (elements[0] == "Document.doc");
        assert (elements[1] == "Element.element1");

        assert (attributes[0] == "prop1");
        assert (attributes[1] == "prop2");
        assert (attributes[2] == "prop1");
        assert (attributes[3] == "prop2");

        assert (values[0] == "property1");
        assert (values[1] == "property2");
        assert (values[2] == "propertyelement1");
        assert (values[3] == "propertyelement2");
    }

    public void
    test_document_characters ()
    {
        string test =   "Document.doc {" +
                        "   prop1: property1;" +
                        "   prop2: property2;" +
                        "   Element.element1 {" +
                        "       prop1: propertyelement1;" +
                        "       prop2: propertyelement2;" +
                        "   }" +
                        "   Element.element2 {" +
                        "       [" +
                        "           Test.characters {" +
                        "               prop1: propertycharacters1;" +
                        "               prop2: propertycharacters1;" +
                        "               [" +
                        "                   test characters" +
                        "               ]" +
                        "           }" +
                        "       ]" +
                        "   }" +
                        "}";

        string[] elements = {};
        string[] attributes = {};
        string[] values = {};
        string[] characters = {};

        try
        {
            var manifest = new Manifest.Document.from_buffer (test, test.length);
            foreach (Core.Parser.Token token in manifest)
            {
                switch (token)
                {
                    case Core.Parser.Token.START_ELEMENT:
                        string element = manifest.element_tag + "." + manifest.element_id;
                        Test.message (@"element: $element");
                        elements += element;
                        break;

                    case Core.Parser.Token.ATTRIBUTE:
                        string attribute = manifest.attribute;
                        attributes += attribute;
                        string val = (string)manifest.scanner.transform (typeof (string));
                        values += val;
                        Test.message (@"attribute: $attribute, val: $val");
                        break;

                    case Core.Parser.Token.CHARACTERS:
                        string character = manifest.characters;
                        characters += character;
                        Test.message (@"character: $character");
                        break;
                }
            }
        }
        catch (Core.ParseError err)
        {
            Test.message (err.message);
            assert (false);
        }
        catch (Manifest.Error err)
        {
            Test.message (err.message);
            assert (false);
        }

        assert (elements.length == 3);
        assert (attributes.length == 4);
        assert (values.length == 4);
        assert (elements[0] == "Document.doc");
        assert (elements[1] == "Element.element1");
        assert (elements[2] == "Element.element2");

        assert (attributes[0] == "prop1");
        assert (attributes[1] == "prop2");
        assert (attributes[2] == "prop1");
        assert (attributes[3] == "prop2");

        assert (values[0] == "property1");
        assert (values[1] == "property2");
        assert (values[2] == "propertyelement1");
        assert (values[3] == "propertyelement2");

        assert (characters[0] ==  "Test.characters {               prop1: propertycharacters1;               prop2: propertycharacters1;               [                   test characters               ]           }");
    }
}
