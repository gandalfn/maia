/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * box.vala
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

public class Maia.Cassowary.Box : Core.Object
{
    // Type
    [Flags]
    public enum Position
    {
        FREE,
        TOP,
        BOTTOM,
        LEFT,
        RIGHT
    }

    // properties
    private Variable                     m_Left;
    private Variable                     m_Right;
    private Variable                     m_Top;
    private Variable                     m_Bottom;
    private Variable                     m_Width;
    private Variable                     m_Height;
    private Variable                     m_WidthRequested;
    private Variable                     m_HeightRequested;
    private Variable                     m_XExpand;
    private Variable                     m_YExpand;
    private Core.Map<string, Constraint> m_Constraints;

    // accessors
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public int row = -1;
    public int column = -1;

    public Graphic.Point origin {
        get {
            return Graphic.Point (m_Left.@value, m_Top.@value);
        }
    }

    public Graphic.Size size {
        get {
            return Graphic.Size (m_Width.@value, m_Height.@value);
        }
    }

    // methods
    construct
    {
        m_Constraints = new Core.Map<string, Constraint> ();
    }

    public Box (string inName) throws Error
    {
        GLib.Object (id: GLib.Quark.from_string (inName));

        // Create variables
        m_Left            = new Variable.with_name (@"$(inName).left");
        m_Right           = new Variable.with_name (@"$(inName).right");
        m_Top             = new Variable.with_name (@"$(inName).top");
        m_Bottom          = new Variable.with_name (@"$(inName).bottom");
        m_Width           = new Variable.with_name (@"$(inName).width");
        m_Height          = new Variable.with_name (@"$(inName).height");
        m_WidthRequested  = new Variable.with_name (@"$(inName).width_requested");
        m_HeightRequested = new Variable.with_name (@"$(inName).height_requested");
        m_XExpand         = new Variable.with_name (@"$(inName).xexpand");
        m_YExpand         = new Variable.with_name (@"$(inName).yexpand");

        // All values must be positive
        m_Constraints["left >= 0"]             = new LinearInequality.with_variable_value (m_Left,            Operator.GEQ, 0);
        m_Constraints["right >= 0"]            = new LinearInequality.with_variable_value (m_Right,           Operator.GEQ, 0);
        m_Constraints["top >= 0"]              = new LinearInequality.with_variable_value (m_Top,             Operator.GEQ, 0);
        m_Constraints["bottom >= 0"]           = new LinearInequality.with_variable_value (m_Bottom,          Operator.GEQ, 0);
        m_Constraints["width >= 0"]            = new LinearInequality.with_variable_value (m_Width,           Operator.GEQ, 0);
        m_Constraints["height >= 0"]           = new LinearInequality.with_variable_value (m_Height,          Operator.GEQ, 0);
        m_Constraints["width_requested >= 0"]  = new LinearInequality.with_variable_value (m_WidthRequested,  Operator.GEQ, 0);
        m_Constraints["height_requested >= 0"] = new LinearInequality.with_variable_value (m_HeightRequested, Operator.GEQ, 0);
        m_Constraints["xexpand >= 0"]          = new LinearInequality.with_variable_value (m_XExpand,         Operator.GEQ, 0);
        m_Constraints["yexpand >= 0"]          = new LinearInequality.with_variable_value (m_YExpand,         Operator.GEQ, 0);

        // right = left + width
        m_Constraints["right = left + width"] = new LinearEquation.with_variable (m_Right, var_plus_expr (m_Left, new LinearExpression (m_Width)));

        // bottom = top + height
        m_Constraints["bottom = top + height"] = new LinearEquation.with_variable (m_Bottom, var_plus_expr (m_Top, new LinearExpression (m_Height)));

        // width = width_requested + xexpand
        m_Constraints["width = width_requested + xexpand"] = new LinearEquation.with_variable (m_Width, var_plus_expr (m_WidthRequested, new LinearExpression (m_XExpand)));

        // width = width_requested + xexpand
        m_Constraints["height = height_requested + yexpand"] = new LinearEquation.with_variable (m_Height, var_plus_expr (m_HeightRequested, new LinearExpression (m_YExpand)));
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Box;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        unowned Box? box = inObject as Box;
        if (box != null)
        {
            try
            {
                // Child box inside this box then box.right <= m_Width
                m_Constraints[@"$(box.name).right <= width"] = new LinearInequality.with_variable_expression (box.m_Right, Operator.LEQ, new LinearExpression (m_Width));
                // Child box inside this box then box.bottom <= m_Height
                m_Constraints[@"$(box.name).bottom <= height"] = new LinearInequality.with_variable_expression (box.m_Bottom, Operator.LEQ, new LinearExpression (m_Height));
            }
            catch (GLib.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.CANVAS_LAYOUT, @"Error on add child $(box.name) constraints for $name: $(err.message)");
            }
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        unowned Box? box = inObject as Box;
        if (box != null)
        {
            m_Constraints.unset (@"$(box.name).right <= width");
            m_Constraints.unset (@"$(box.name).bottom <= height");
        }

        base.remove_child (inObject);
    }

    internal override int
    compare (Core.Object  inObject)
    {
        unowned Box? box = inObject as Box;
        if (box != null)
        {
            // order item by row
            int ret = row - box.row;
            if (ret != 0)
            {
                return ret;
            }

            // if on same row order by column
            ret = column - box.column;
            if (ret != 0)
            {
                return ret;
            }
        }

        return base.compare (inObject);
    }

    internal override string
    to_string ()
    {
        string ret = @"box $name:\n";
        ret += @"  x:   $(m_Left.@value)\n";
        ret += @"  y:    $(m_Top.@value)\n";
        ret += @"  width:  $(m_Width.@value)\n";
        ret += @"  height: $(m_Height.@value)\n";
        ret += @"  xexpand: $(m_XExpand.@value)\n";
        ret += @"  yexpand: $(m_YExpand.@value)\n";

        foreach (var child in this)
        {
            ret += child.to_string ();
        }

        return ret;
    }

    public void
    set_position (Graphic.Point inPoint, Strength inStrength = Strength.required) throws Error
    {
        m_Constraints["left"] = new LinearEquation.with_variable_value (m_Left, inPoint.x, inStrength);
        m_Constraints["top"]  = new LinearEquation.with_variable_value (m_Top,  inPoint.y, inStrength);
    }

    public void
    set_size_request (Graphic.Size inSize, Strength inStrength = Strength.required) throws Error
    {
        m_Constraints[@"width_requested"] = new LinearEquation.with_variable_value (m_WidthRequested, inSize.width, inStrength);
        m_Constraints[@"height_requested"] = new LinearEquation.with_variable_value (m_HeightRequested, inSize.height, inStrength);
    }

    public void
    set_expand (Graphic.Point inExpand, Strength inStrength = Strength.required)
    {
        m_Constraints[@"xexpand"] = new LinearEquation.with_variable_value (m_XExpand, inExpand.x, inStrength);
        m_Constraints[@"yexpand"] = new LinearEquation.with_variable_value (m_YExpand, inExpand.y, inStrength);
    }

    public void
    above (Box inBox, double inSpacing = 0.0, Strength inStrength = Strength.required)
    {
        m_Constraints[@"bottom = $(inBox.name).top - spacing"] = new LinearEquation.with_variable (m_Bottom, var_minus_constant (inBox.m_Top, inSpacing), inStrength);
    }

    public void
    below (Box inBox, double inSpacing = 0.0, Strength inStrength = Strength.required)
    {
        m_Constraints[@"top = $(inBox.name).bottom + spacing"] = new LinearEquation.with_variable (m_Top, var_plus_constant (inBox.m_Bottom, inSpacing), inStrength);
    }

    public void
    left_of (Box inBox, double inSpacing = 0.0, Strength inStrength = Strength.required)
    {
        m_Constraints[@"right = $(inBox.name).left - spacing"] = new LinearEquation.with_variable (m_Right, var_minus_constant (inBox.m_Left, inSpacing), inStrength);
    }

    public void
    right_of (Box inBox, double inSpacing = 0.0, Strength inStrength = Strength.required)
    {
        m_Constraints[@"left = $(inBox.name).right + spacing"] = new LinearEquation.with_variable (m_Left, var_plus_constant (inBox.m_Right, inSpacing), inStrength);
    }

    public void
    same_width (Box inBox) throws Error
    {
        m_Constraints[@"width = $(inBox.name).width"] = new LinearInequality.with_variables (m_Right, Operator.GEQ, inBox.m_Right);
    }

    public void
    same_height (Box inBox) throws Error
    {
        m_Constraints[@"height = $(inBox.name).height"] = new LinearInequality.with_variables (m_Bottom, Operator.GEQ, inBox.m_Bottom);
    }

    public void
    add_box (Box inBox, Position inPosition = Position.FREE)
    {
        // Add box in this
        inBox.parent = this;

        // Anchor box
        attach (inBox, inPosition);
    }

    public void
    attach (Box inBox, Position inPosition = Position.FREE, Strength inStrength = Strength.required)
    {
        // Anchor box
        if (Position.TOP in inPosition)
        {
            m_Constraints[@"$(inBox.name).top = top"] = new LinearEquation.with_variable (inBox.m_Top, new LinearExpression (m_Top), inStrength);
        }
        if (Position.BOTTOM in inPosition)
        {
            m_Constraints[@"$(inBox.name).bottom = bottom"] = new LinearEquation.with_variable (inBox.m_Bottom, new LinearExpression (m_Bottom), inStrength);
        }
        if (Position.LEFT in inPosition)
        {
            m_Constraints[@"$(inBox.name).left = left"] = new LinearEquation.with_variable (inBox.m_Left, new LinearExpression (m_Left), inStrength);
        }
        if (Position.RIGHT in inPosition)
        {
            m_Constraints[@"$(inBox.name).right = right"] = new LinearEquation.with_variable (inBox.m_Right, new LinearExpression (m_Right), inStrength);
        }
    }

    public void
    build_constraints (SimplexSolver inSolver) throws Error
    {
        foreach (var child in this)
        {
            unowned Box box = child as Box;

            // Add constraints of child
            box.build_constraints (inSolver);
        }

        // Add constraints of box
        foreach (var pair in m_Constraints)
        {
            inSolver.add_constraint (pair.second);
        }
    }
}
