/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-protocol.vala
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

public class Maia.TestProtocol : Maia.TestCase
{
    public TestProtocol ()
    {
        base ("protocol");

        add_test ("simple", test_protocol_simple);
        add_test ("message", test_protocol_message);
    }

    public override void
    set_up ()
    {
    }

    public override void
    tear_down ()
    {
    }

    public void
    test_protocol_simple ()
    {
        string proto = "message Test { " +
                       "    required int64 val;" +
                       "    required string str;" +
                       "    optional int32 count;" +
                       "}";

        var buffer = new Protocol.Buffer.from_data (proto, proto.length);
        var msg = buffer["Test"];

        assert (msg != null);
        assert (msg["val"] != null);
        assert (msg["str"] != null);
        assert (msg["count"] != null);
        Test.message (@"signature: $(msg)");
    }

    public void
    test_protocol_message ()
    {
        string proto = "message Test { " +
                       "    required int64 val;" +
                       "    required string str;" +
                       "    optional int32 count [default = 5];" +
                       "}" +
                       "message Test2 { " +
                       "    repeated Test test;" +
                       "    required double val;" +
                       "}";

        var buffer = new Protocol.Buffer.from_data (proto, proto.length);
        var msg = buffer["Test"];
        var msg2 = buffer["Test2"];

        assert (msg != null);
        assert (msg["val"] != null);
        assert (msg["str"] != null);
        assert (msg["count"] != null);
        assert (msg2 != null);
        assert (((Protocol.Message)msg2["test"].get())["val"] != null);
        assert (((Protocol.Message)msg2["test"].get())["str"] != null);
        assert (((Protocol.Message)msg2["test"].get())["count"] != null);
        assert (msg2["val"] != null);
        Test.message (@"signature test: $(msg), signature: $(msg2)");
    }
}
