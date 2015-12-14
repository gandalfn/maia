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
    private class ProtocolEventArgs : Core.EventArgs
    {
        public const string ProtoBuf = "message EventArgsProtocol {" +
                                       "     uint32 val;"   +
                                       "     string str;"   +
                                       "}";
        static construct
        {
            Core.EventArgs.register_protocol (typeof (ProtocolEventArgs),
                                              "EventArgsProtocol",
                                              ProtoBuf);
        }

        public ProtocolEventArgs ()
        {
        }
    }

    private class InheritProtocolEventArgs : ProtocolEventArgs
    {
        public new const string ProtoBuf = "message InheritEventArgsProtocol {" +
                                           "     EventArgsProtocol protocol;"   +
                                           "     uint32 count;"   +
                                           "}";

        static construct
        {
            Core.EventArgs.register_protocol (typeof (InheritProtocolEventArgs),
                                              "InheritEventArgsProtocol",
                                              ProtocolEventArgs.ProtoBuf +
                                              ProtoBuf);
        }

        public InheritProtocolEventArgs ()
        {
        }
    }

    public TestProtocol ()
    {
        base ("protocol");

        add_test ("simple", test_protocol_simple);
        add_test ("message", test_protocol_message);
        add_test ("event", test_protocol_event);
        add_test ("inherit-event", test_protocol_inherit_event);
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
                       "    int64 val;" +
                       "    string str;" +
                       "    int32 count;" +
                       "}";

        var buffer = new Protocol.Buffer.from_data (proto, proto.length);
        var msg = buffer["Test"];

        msg["val", 0] = 123;
        msg["str", 0] = "test";
        msg["count", 0] = 3;

        assert (msg != null);
        assert ((uint64)msg["val"] == 123);
        assert ((string)msg["str"] == "test");
        assert ((uint32)msg["count"] == 3);

        Test.message (@"signature: $(msg) serialized: $(msg.serialize.print(false))");
    }

    public void
    test_protocol_message ()
    {
        string proto = "message Test { " +
                       "    int64 val;" +
                       "    string str;" +
                       "    int32 count [default = 5];" +
                       "}" +
                       "message Test2 { " +
                       "    Test test;" +
                       "    double val;" +
                       "    string str [default = 'test chaine default'];" +
                       "}" +
                       "message Test3 { " +
                       "    repeated uint32 array;" +
                       "}";

        var buffer = new Protocol.Buffer.from_data (proto, proto.length);
        var msg = buffer["Test"];
        var msg2 = buffer["Test2"];
        var msg3 = buffer["Test3"];

        msg["val", 0] = 123;
        msg["str", 0] = "test";
        msg["count", 0] = 1;

        assert (msg != null);
        assert ((uint64)msg["val"] == 123);
        assert ((string)msg["str"] == "test");
        assert ((uint32)msg["count"] == 1);

        Test.message(@"msg: $(msg.serialize.print (false))");

        assert (msg2 != null);

        ((Protocol.Message)msg2["test"])["val", 0] = 321;
        ((Protocol.Message)msg2["test"])["str", 0] = "test 2";
        ((Protocol.Message)msg2["test"])["count", 0] = 2;
        msg2["val", 0] = 456.345;

        assert ((uint64)((Protocol.Message)msg2["test"])["val"] == 321);
        assert ((string)((Protocol.Message)msg2["test"])["val"] == "test 2");
        assert ((uint32)((Protocol.Message)msg2["test"])["val"] == 2);
        assert ((double)msg2["val"] == 456.345);

        Test.message(@"msg2: $(msg2.serialize.print (false))");

        assert (msg3 != null);
        msg3.add_value ("array", 12);
        msg3.add_value ("array", 34);
        msg3.add_value ("array", 56);
        msg3.add_value ("array", 78);

        assert ((uint32)msg3["array", 0] == 12);
        assert ((uint32)msg3["array", 1] == 34);
        assert ((uint32)msg3["array", 2] == 56);
        assert ((uint32)msg3["array", 3] == 78);

        Test.message(@"msg3: $(msg3.serialize.print (false))");

        Test.message (@"signature test: $(msg), signature test2: $(msg2), signature test3: $(msg3)");
    }

    public void
    test_protocol_event ()
    {
        ProtocolEventArgs evt = new ProtocolEventArgs ();

        evt["val", 0] = 34;
        evt["str", 0] = "test str";

        assert ((uint32)evt["val"] == 34);
        assert ((string)evt["str"] == "test str");

        Test.message (@"serialize: $(evt.serialize.print(false))");

        ProtocolEventArgs evt2 = new ProtocolEventArgs ();
        evt2.serialize = evt.serialize;

        assert ((uint32)evt2["val"] == 34);
        assert ((string)evt2["str"] == "test str");

        Test.message (@"serialize: $(evt2.serialize.print(false))");
    }

    public void
    test_protocol_inherit_event ()
    {
        InheritProtocolEventArgs evt = new InheritProtocolEventArgs ();

        evt["val", 0] = 34;
        evt["str", 0] = "test str";
        evt["count", 0] = 1;

        assert ((uint32)evt["val"] == 34);
        assert ((string)evt["str"] == "test str");
        assert ((uint32)evt["count"] == 1);

        Test.message (@"serialize: $(evt.serialize.print(false))");

        InheritProtocolEventArgs evt2 = new InheritProtocolEventArgs ();
        evt2.serialize = evt.serialize;
        evt2["count", 0] = 2;

        assert ((uint32)evt2["val"] == 34);
        assert ((string)evt2["str"] == "test str");
        assert ((uint32)evt2["count"] == 2);

        Test.message (@"serialize: $(evt2.serialize.print(false))");
    }
}
