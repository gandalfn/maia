/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-timeline.vala
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

public class Maia.TestTimeline : Maia.TestCase
{
    const int FPS = 60;

    private Core.Timeline m_Timeline;
    private GLib.MainLoop m_Loop;
    private int m_Count;

    public TestTimeline ()
    {
        base ("timeline");

        add_test ("create", test_timeline_create);
        add_test ("run", test_timeline_run);
    }

    private void
    on_new_frame (Core.Notification inNotification)
    {
        unowned Core.Timeline.NewFrameNotification? notification = (Core.Timeline.NewFrameNotification)inNotification;

        m_Count = (int)notification.num_frame;
        double elapsed = Test.timer_elapsed () * 1000;
        Test.message (@"count = $m_Count elapsed = $elapsed");
        Test.timer_start ();
    }

    private void
    on_completed (Core.Notification inNotification)
    {
        m_Loop.quit ();
    }

    public override void
    set_up ()
    {
        m_Loop = new GLib.MainLoop ();
        m_Timeline = new Core.Timeline (FPS, FPS);
        m_Count = 0;
    }

    public override void
    tear_down ()
    {
        m_Timeline.stop ();
        m_Timeline = null;
    }

    public void
    test_timeline_create ()
    {
        assert (m_Timeline != null);
    }

    public void
    test_timeline_run ()
    {
        assert (m_Timeline != null);

        m_Timeline.new_frame.add_object_observer (on_new_frame);
        m_Timeline.completed.add_object_observer (on_completed);
        Test.timer_start ();
        m_Timeline.start ();
        m_Loop.run ();

        assert (m_Count != 0);
    }
}
