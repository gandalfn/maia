/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-core.vala
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

public class Maia.TestCore : Maia.TestCase
{
    public TestCore ()
    {
        base ("core");

        suite.add_suite (new TestSpinLock ().suite);
        suite.add_suite (new TestArray ().suite);
        suite.add_suite (new TestList ().suite);
        suite.add_suite (new TestSet ().suite);
        suite.add_suite (new TestMap ().suite);
        suite.add_suite (new TestObject ().suite);
        suite.add_suite (new TestDispatcher ().suite);
        suite.add_suite (new TestApplication ().suite);
        suite.add_suite (new TestEvent ().suite);
    }
}
