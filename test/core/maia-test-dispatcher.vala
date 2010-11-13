/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-test-dispatcher.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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
    private Maia.Dispatcher dispatcher;
    private int count;

    public TestDispatcher ()
    {
        base ("dispatcher");

        add_test ("add-task", test_add_task);
        add_test ("sleep", test_sleep);
    }

    public override void
    set_up ()
    {
        dispatcher = new Dispatcher ();
        assert (dispatcher.state == Task.State.READY);
        assert (dispatcher.childs.nb_items == 0);
    }

    private void
    on_task_running (Notification inNotification)
    {
        Task task = (Task)inNotification.owner;

        Test.message ("running elapsed = %f s", Test.timer_elapsed ());
        if (count < 10)
        {
            task.sleep (500);
            ++count;
        }
        else
        {
            task.finish ();
        }
    }

    private void
    on_task_finished (Notification inNotification)
    {
        Test.message ("finished elapsed = %f s", Test.timer_elapsed ());
        dispatcher.finish ();
    }

    public void
    test_add_task ()
    {
        Task task = new Task ();
        task.parent = dispatcher;

        assert (task.parent != null);
        assert (dispatcher.childs.nb_items == 1);

        Pair<string, string> pair  = new Pair <string, string> ("test", "task");
        pair.parent = dispatcher;
        assert (pair.parent == null);
    }

    public void
    test_sleep ()
    {
        Task task = new Task ();

        count = 0;
        task.running.watch (new Observer (on_task_running, this));
        task.finished.watch (new Observer (on_task_finished, this));
        task.parent = dispatcher;

        Test.timer_start ();
        task.sleep (500);

        dispatcher.run ();
        assert (task.state == Task.State.TERMINATED);
        assert (dispatcher.state == Task.State.TERMINATED);
        assert (count >= 10);
    }
}
