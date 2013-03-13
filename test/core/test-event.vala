/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-event.vala
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

public class Foo : Maia.Object
{
    public class Args : Maia.EventArgs
    {
        public int a { get; construct; default = 0; }

        public Args (int inA)
        {
            GLib.Object (a: inA);
        }
    }

    public Maia.Event<Args> test_event;

    public Foo ()
    {
        test_event = new Maia.Event<Args> ("test-event", this);
    }
}

public class Maia.TestEvent : Maia.TestCase
{
    private Maia.Dispatcher dispatcher = null;
    private Maia.Timeout timeout = null;
    private Maia.SpinLock lck = Maia.SpinLock ();
    private Foo foo = null;
    public int count = 0;

    public TestEvent ()
    {
        base ("event");

        add_test ("simple-event", test_simple_event);
        add_test ("thread-event", test_thread_event);
    }

    public override void
    set_up ()
    {
        dispatcher = new Dispatcher ();
        foo = new Foo ();
        timeout = new Timeout (5);
        timeout.parent = dispatcher;
        timeout.elapsed.connect (on_timeout_elapsed);
        count = 0;
        assert (dispatcher.state == Task.State.READY);
        assert (dispatcher.nb_childs == 2);
    }

    public override void
    tear_down ()
    {
        dispatcher = null;
        foo = null;
        timeout = null;
    }

    private bool
    on_timeout_elapsed ()
    {
        lck.lock ();
        count++;
        foo.test_event.post (new Maia.EventArgs1<int> (count));

        Test.timer_start ();
        lck.unlock ();

        return count <= 507;
    }

    private void
    on_test_event (Foo.Args inArgs)
    {
        lck.lock ();
        Test.message ("%lx: Event received %i = %f s",
                      (ulong)Dispatcher.self.thread_id, inArgs.a, Test.timer_elapsed ());
        if (count > 507)
        {
            dispatcher.finish ();
        }
        lck.unlock ();
    }

    public void
    test_simple_event ()
    {
        foo.test_event.listen(on_test_event, dispatcher);

        dispatcher.run ();
    }

    public void
    test_thread_event ()
    {
        Dispatcher thread_dispatcher = new Dispatcher.thread ();
        foo.test_event.listen (on_test_event, thread_dispatcher);

        thread_dispatcher.run ();
        dispatcher.run ();
        thread_dispatcher.finish ();
    }
}
