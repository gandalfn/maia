/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    private Maia.TicTac tictac = null;
    private int count;
    private int count_tictac_delay;

    public TestDispatcher ()
    {
        base ("dispatcher");

        add_test ("add-task", test_add_task);
        add_test ("sleep", test_sleep);
        add_test ("timeout", test_timeout);
        add_test ("tictac", test_tictac);
        add_test ("tictac-delay", test_tictac_delay);
        add_test ("timeline", test_timeline);
    }

    public override void
    set_up ()
    {
        dispatcher = new Dispatcher ();
        assert (dispatcher.state == Task.State.READY);
        assert (dispatcher.childs.nb_items == 1);
    }

    public override void
    tear_down ()
    {
        dispatcher = null;
    }

    private void
    on_task_running (Task inTask)
    {
        Test.message ("running elapsed = %f s", Test.timer_elapsed ());
        if (count < 10)
        {
            inTask.sleep (50);
            ++count;
        }
        else
        {
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

    private bool
    on_timeout_tictac_delay_elapsed ()
    {
        bool ret = true;
        count_tictac_delay++;

        if ((count_tictac_delay % 2) != 0)
        {
            Test.message ("sleep tictac");
            tictac.sleep ();
        }
        else
        {
            Test.message ("wakeup tictac");
            tictac.wakeup ();
        }

        return ret;
    }

    private bool
    on_tictac_bell ()
    {
        bool ret = true;

        Test.message ("numframe = %u titac bell = %f s", count, Test.timer_elapsed ());
        if (count < 50)
        {
            ++count;
        }
        else
        {
            ret = false;
        }

        int delay = Test.rand_int_range (0, 30);
        Test.message ("delay %i ms", delay);
        Posix.usleep (delay * 1000);

        return ret;
    }

    private void
    on_timeline_new_frame (int inNumFrame)
    {
        Test.message ("numframe = %u timeline new frame = %f s", inNumFrame, Test.timer_elapsed ());
        int delay = Test.rand_int_range (0, 300);
        Test.message ("delay %i ms", delay);
        Posix.usleep (delay * 1000);
    }

    private void
    on_timeline_completed ()
    {
        Test.message ("completed elapsed = %f s", Test.timer_elapsed ());
        dispatcher.finish ();
    }

    public void
    test_add_task ()
    {
        Task task = new Task ();
        task.parent = dispatcher;

        assert (task.parent != null);
        assert (dispatcher.childs.nb_items == 2);
    }

    public void
    test_sleep ()
    {
        Task task = new Task ();

        count = 0;
        task.running.connect (on_task_running);
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

    public void
    test_tictac ()
    {
        tictac = new TicTac (50);

        count = 0;
        tictac.bell.connect (on_tictac_bell);
        tictac.finished.connect (on_task_finished);
        tictac.parent = dispatcher;

        Test.timer_start ();

        dispatcher.run ();
        assert (tictac.state == Task.State.TERMINATED);
        assert (dispatcher.state == Task.State.TERMINATED);
    }

    public void
    test_tictac_delay ()
    {
        Timeout timeout = new Timeout (350);
        timeout.elapsed.connect (on_timeout_tictac_delay_elapsed);
        timeout.parent = dispatcher;

        tictac = new TicTac (10);

        count = 0;
        count_tictac_delay = 0;
        tictac.bell.connect (on_tictac_bell);
        tictac.finished.connect (on_task_finished);
        tictac.parent = dispatcher;

        Test.timer_start ();

        dispatcher.run ();
        assert (tictac.state == Task.State.TERMINATED);
        assert (dispatcher.state == Task.State.TERMINATED);
    }

    public void
    test_timeline ()
    {
        Timeline timeline = new Timeline (60, 60, dispatcher);

        timeline.new_frame.connect (on_timeline_new_frame);
        timeline.completed.connect (on_timeline_completed);

        Test.timer_start ();

        timeline.start ();
        dispatcher.run ();

        assert (dispatcher.state == Task.State.TERMINATED);
    }
}
