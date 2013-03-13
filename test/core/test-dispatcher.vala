/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-dispatcher.vala
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

public class Maia.TestDispatcher : Maia.TestCase
{
    private Maia.Dispatcher dispatcher = null;
    private int count;
    private int count_tictac_delay;

    public TestDispatcher ()
    {
        base ("dispatcher");

        add_test ("add-task", test_add_task);
        add_test ("sleep", test_sleep);
        add_test ("timeout", test_timeout);
    }

    public override void
    set_up ()
    {
        dispatcher = new Dispatcher ();
        assert (dispatcher.state == Task.State.READY);
        assert (dispatcher.nb_childs == 1);
    }

    public override void
    tear_down ()
    {
        dispatcher = null;
        tictac = null;
    }

    private void
    on_task_running (Task? inTask)
    {
        Test.message ("running elapsed = %f s", Test.timer_elapsed ());
        if (count < 10)
        {
            Test.message ("sleep 0x%lx", (ulong)inTask);
            inTask.sleep (50);
            ++count;
        }
        else
        {
            Test.message ("finish 0x%lx", (ulong)inTask);
            inTask.finish ();
        }
    }

    private void
    on_task_finished ()
    {
        Test.message ("finished elapsed = %f s", Test.timer_elapsed ());
        dispatcher.finish ();
    }

    private bool
    on_timeout_elapsed ()
    {
        bool ret = true;

        Test.message ("timeout elapsed = %f s", Test.timer_elapsed ());
        if (count < 10)
        {
            ++count;
        }
        else
        {
            ret = false;
        }

        Test.timer_start ();

        return ret;
    }

    public void
    test_add_task ()
    {
        Task task = new Task ();
        task.parent = dispatcher;

        assert (task.parent != null);
        assert (dispatcher.nb_childs == 2);
    }

    public void
    test_sleep ()
    {
        Task task = new Task ();

        count = 0;
        task.running.connect (() => { on_task_running (task); });
        task.finished.connect (on_task_finished);
        task.parent = dispatcher;

        Test.timer_start ();
        task.sleep (50);

        dispatcher.run ();
        assert (task.state == Task.State.TERMINATED);
        assert (dispatcher.state == Task.State.TERMINATED);
        assert (count >= 10);
    }

    public void
    test_timeout ()
    {
        Timeout timeout = new Timeout (50);

        count = 0;
        timeout.elapsed.connect (on_timeout_elapsed);
        timeout.finished.connect (on_task_finished);
        timeout.parent = dispatcher;

        Test.timer_start ();

        dispatcher.run ();
        assert (timeout.state == Task.State.TERMINATED);
        assert (dispatcher.state == Task.State.TERMINATED);
        assert (count >= 10);
    }
}
