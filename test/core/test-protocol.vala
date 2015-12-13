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
            print(@"$(get_type().name())\n");
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

        assert (msg != null);
        assert (msg["val"] != null);
        assert (msg["str"] != null);
        assert (msg["count"] != null);

        Test.message(@"$((int32)msg["count"].get())");
        Test.message(@"$((string)msg2["str"].get())");

        assert ((int)msg["count"].get() == 5);

        assert (msg2 != null);

        assert (((Protocol.Message)msg2["test"].get())["val"] != null);
        assert (((Protocol.Message)msg2["test"].get())["str"] != null);
        assert (((Protocol.Message)msg2["test"].get())["count"] != null);
        assert (msg2["val"] != null);

        assert (msg3 != null);

        Core.Array<uint32> array = (Core.Array<uint32>)msg3["array"].get ();
        assert (array != null);
        array.insert (13);
        array.insert (24);
        array.insert (5);
        array.insert (47);

        Test.message(@"$(msg3.to_variant ().print (false))");

        Test.message (@"signature test: $(msg), signature test2: $(msg2), signature test3: $(msg3)");
    }

    public void
    test_protocol_event ()
    {
        ProtocolEventArgs evt = new ProtocolEventArgs ();
        assert (evt["val"] != null);
        assert (evt["str"] != null);

        evt["val"].set ((uint32)34);
        evt["str"].set ("test str");

        assert ((uint32)evt["val"].get () == 34);
        assert ((string)evt["str"].get () == "test str");

        Test.message (@"serialize: $(evt.serialize.print(false))");

        ProtocolEventArgs evt2 = new ProtocolEventArgs ();
        evt2.serialize = evt.serialize;

        assert ((uint32)evt2["val"].get () == 34);
        assert ((string)evt2["str"].get () == "test str");

        Test.message (@"serialize: $(evt2.serialize.print(false))");
    }

    public void
    test_protocol_inherit_event ()
    {
        InheritProtocolEventArgs evt = new InheritProtocolEventArgs ();
        assert (evt["val"] != null);
        assert (evt["str"] != null);

        evt["val"].set ((uint32)34);
        evt["str"].set ("test str");
        evt["count"].set ((uint32)1);

        assert ((uint32)evt["val"].get () == 34);
        assert ((string)evt["str"].get () == "test str");
        assert ((uint32)evt["count"].get () == 1);

        Test.message (@"serialize: $(evt.serialize.print(false))");

        InheritProtocolEventArgs evt2 = new InheritProtocolEventArgs ();
        evt2.serialize = evt.serialize;
        evt2["count"].set ((uint32)2);

        assert ((uint32)evt2["val"].get () == 34);
        assert ((string)evt2["str"].get () == "test str");
        assert ((uint32)evt2["count"].get () == 2);

        Test.message (@"serialize: $(evt2.serialize.print(false))");
    }
}
