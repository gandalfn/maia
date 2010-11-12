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

    public TestDispatcher ()
    {
        base ("dispatcher");

        add_test ("task", test_task);
    }

    public override void
    set_up ()
    {
        dispatcher = new Dispatcher ();
    }

    private void
    on_task ()
    {
        Test.message ("elapsed = %f s", Test.timer_elapsed ());
        dispatcher.finish ();
    }

    public void
    test_task ()
    {
        Task task = new Task (on_task);
        task.parent = dispatcher;

        Test.timer_start ();
        task.sleep (500);

        dispatcher.run ();
    }
}
