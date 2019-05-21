module evael.graphics.gui.controls.Container;

import std.math;

public import evael.graphics.gui.controls.Control;
import evael.graphics.GUI;

import evael.utils.Math;
import evael.utils.Size;
import evael.utils.Rectangle;
import evael.utils.Color;

abstract class Container : Control
{
    /// Children list
    protected Control[] m_controls;

    /// Current focused child
    protected Control m_focusedControl;
    protected Control m_controlUnderMouse;

    /// Current selected control tooltip
    protected Tooltip m_tooltip;

    /// Container should be resized if a child control is bigger ?
    protected bool m_autoResize;

    protected ScrollBar m_verticalScrollBar, m_horizontalScrollBar;

    mixin(ControlGetter!("Button"));
    mixin(ControlGetter!("ListBox"));
    mixin(ControlGetter!("TextBox"));
    mixin(ControlGetter!("Window"));
    mixin(ControlGetter!("PictureBox"));
    mixin(ControlGetter!("TextArea"));
    mixin(ControlGetter!("TextBlock"));
    mixin(ControlGetter!("ProgressBar"));

    public this()(in auto ref vec2 position, in auto ref Size!int size)
    {
        super(position, size);

        this.m_autoResize = true;

        this.m_tooltip = new Tooltip();
        this.m_tooltip.id = int.max;
        this.m_tooltip.hide();

        this.addChild(this.m_tooltip);
    }

    public override void update(in float deltaTime)
    {
        super.update(deltaTime);

        foreach(control; this.m_controls)
        {
            control.update(deltaTime);
        }
    }

    /**
     * Draws the container with children
     */
    public override void draw(in float deltaTime)
    {
        if(!this.m_isVisible)
        {
            return;
        }

        super.draw(deltaTime);

        foreach(i; 1..this.m_controls.length)
        {
            this.m_controls[i].draw(deltaTime);
        }

        this.m_tooltip.draw(deltaTime);
    }

    /**
     * Event called on mouse button click
     * Params:
     *		mouseButton : mouse button
     *		mousePosition : mouse position
     */
    public override void onMouseClick(in MouseButton mouseButton, in ref vec2 mousePosition)
    {
        super.onMouseClick(mouseButton, mousePosition);

        if(this.m_controlUnderMouse !is null && this.m_controlUnderMouse.isEnabled)
        {
            this.m_controlUnderMouse.onMouseClick(mouseButton, mousePosition);
        }
    }

    /**
     * Event called on mouse button release
     * Params:
     *		mouseButton : mouse button
     */
    public override void onMouseUp(in MouseButton mouseButton)
    {
        super.onMouseUp(mouseButton);

        if(this.m_controlUnderMouse !is null && this.m_controlUnderMouse.isEnabled)
        {
            this.m_controlUnderMouse.onMouseUp(mouseButton);

            if(this.m_controlUnderMouse.isFocusable)
            {
                this.focusControl(this.m_controlUnderMouse);
            }
        }
    }

    /**
     * Event called when mouse enters in control's rect
     * Params:
     * 		 mousePosition : mouse position
     */
    public override void onMouseMove(in ref vec2 position)
    {
        super.onMouseMove(position);

        if(!this.m_isVisible)
            return;

        auto lastControlUnderMouse = this.m_controlUnderMouse;

        this.m_controlUnderMouse = this.getControlUnderMouse(position);

        if(this.m_controlUnderMouse !is null)
        {
			this.m_controlUnderMouse.onMouseMove(position);
		}

        // We unfocus last focused item
        if(lastControlUnderMouse !is null && lastControlUnderMouse != this.m_controlUnderMouse)
        {
            lastControlUnderMouse.onMouseLeave();
        }
    }

    /**
     * Event called when mouse leaves control's rect
     */
    public override void onMouseLeave()
    {
        super.onMouseLeave();

        // Mouse is leaving container, we hide the tooltip
        this.m_tooltip.hide();

        if(this.m_controlUnderMouse !is null && this.m_controlUnderMouse.isEnabled)
        {
            this.m_controlUnderMouse.onMouseLeave();
        }
    }

    /**
     * Event called on character input
     * Params:
     *		text :
     */
    public override void onText(in int key)
    {
        super.onText(key);

        if(this.m_focusedControl !is null && this.m_focusedControl.isEnabled)
        {
            this.m_focusedControl.onText(key);
        }
    }


    /**
     * Event called on key input
     * Params:
     *		key : pressed key
     */
    public override void onKey(in int key)
    {
        super.onKey(key);

        if(this.m_focusedControl !is null && this.m_focusedControl.isEnabled)
        {
            this.m_focusedControl.onKey(key);
        }
    }

    /**
     * Adds child control
     * Params:
     *		 control : control to add
     */
    public void addChild(Control control)
    {
        control.parent = this;

        // We check if item is added at runtime
        if(this.m_initialized)
        {
            control.nvg = this.m_nvg;

            if(control.name in this.m_theme.subThemes)
            {
                // This control have a custom theme
                control.theme = this.m_theme.subThemes[control.name].copy();
            }
            else
            {
                control.theme = this.m_theme.copy();
            }

            control.initialize();
            this.updateChildPosition(control);

        }

        this.m_controls ~= control;

        import std.algorithm : sort;

        this.m_controls.sort!((a, b) => a.zIndex < b.zIndex);
    }

    /**
     * Returns child control by id
     * Params:
     *		 id : id
     */
    public T getControl(T : Control)(in size_t id) nothrow @nogc
    {
        foreach (control; this.m_controls)
        {
            if (control.id == id)
            {
                return cast(T)control;
            }
        }

        return null;
    }

    /**
     * Returns the control under the mouse
     */
    private Control getControlUnderMouse(in ref vec2 position) nothrow
    {
        foreach_reverse(control; this.m_controls)
        {
            if(!control.isVisible)
                continue;

            immutable rect = Rectangle!float(control.realPosition.x, control.realPosition.y, control.size);

            if(rect.isIn(position))
            {
                return control;
            }
        }

        return null;
    }

    /**
     * Initializes control
     */
    public override void initialize()
    {
        super.initialize();

        // If we add this container directly in GuiManager, we need to do this
        if(this.m_name in this.m_theme.subThemes)
        {
            this.m_theme =	this.m_theme.subThemes[this.m_name].copy();
        }

        foreach(childControl; this.m_controls)
        {
            childControl.nvg = this.m_nvg;

            // write("Searching theme for ", childControl.name);

            if(childControl.name in this.m_theme.subThemes)
            {
                // writeln("... found! ", this.m_theme.subThemes[childControl.name].name);

                // This control have a custom theme
                childControl.theme = this.m_theme.subThemes[childControl.name].copy();
            }
            else
            {
                // writeln("... not found!");

                auto themePtr = this.m_theme.parent;

                while(themePtr)
                {
                    if(childControl.name in themePtr.subThemes)
                    {
                        childControl.theme = themePtr.subThemes[childControl.name].copy();
                        break;
                    }

                    themePtr = themePtr.parent;
                }

                if(!themePtr)
                {
                    childControl.theme = this.m_theme.copy();
                }

                // writeln("Child theme is ", childControl.theme.name);
            }

            childControl.initialize();

            if(this.m_autoResize)
            {
                if(childControl.size.width > this.m_size.width)
                {
                    this.m_size.width = childControl.size.width;
                }

                if(childControl.size.height > this.m_size.height)
                {
                    this.m_size.height = childControl.size.height;
                }
            }

            this.updateChildPosition(childControl);
        }
    }

    /**
     * Resize the container if a child control is bigger
     */
    public void reSize()
    {
        foreach(childControl; this.m_controls)
        {
            if(childControl.size.width > this.m_size.width)
            {
                this.m_size.width = childControl.size.width;
            }

            if(childControl.size.height > this.m_size.height)
            {
                this.m_size.height = childControl.size.height;
            }
        }
    }


    /**
     * Updates child control position using dock property
     * Params:
     *		 childControl : child control
     */
    protected void updateChildPosition(Control childControl)
    {
        switch(childControl.dock)
        {
            case Dock.Fill:
            {
                childControl.position = vec2(0, 0);
                childControl.size = this.m_size;
                break;
            }
            case Dock.Right:
            {
                childControl.position = vec2(this.m_size.width - childControl.size.width, childControl.position.y);
                childControl.realPosition = this.m_realPosition + childControl.position;

                childControl.size = Size!int(childControl.size.width, childControl.size.height);
                break;
            }
            case Dock.Top:
            {
                childControl.position = vec2(0, 0);
                childControl.realPosition = this.m_realPosition + childControl.position;

                childControl.size = Size!int(childControl.size.width, childControl.size.height);
                break;
            }
            case Dock.Bottom:
            {
                childControl.position = vec2(0, this.m_size.height - childControl.size.height);
                childControl.realPosition = this.m_realPosition + childControl.position;

                childControl.size = Size!int(this.m_size.width, childControl.size.height);
                break;
            }
            default:
                break;
        }
    }


    /**
     * Removes a control from control list
     * Params:
     *		 control : control to remove
     */
    public void remove(Control toRemove)
    {
        import std.algorithm : remove;

        foreach(i, control; this.m_controls)
        {
            if(control == toRemove)
            {
                this.m_controls = this.m_controls.remove(i);
                return;
            }
        }
    }

    /**
     * Gives focus to a control
     */
    public void focusControl(Control control)
    {
        control.focus();

        this.m_focusedControl = control;
    }

    /**
     * Removes focus from a control
     */
    public void unfocusControl(Control control)
    {
        control.unfocus();

        this.m_focusedControl = null;
    }

    @property
    public override void opacity(in ubyte value)   @nogc
    {
        super.opacity = value;

        foreach(control; this.m_controls)
        {
            control.opacity = value;
        }
    }

    @property
    {
        public override ref const(vec2) realPosition() const nothrow @nogc
        {
            return this.m_realPosition;
        }

        public override void realPosition(in vec2 value) nothrow
        {
            // We do this because we need to calculate viewport's rect in Control class
            super.realPosition = value;

            foreach(childControl; this.m_controls)
            {
                childControl.realPosition = this.m_realPosition + childControl.position;
            }
        }

        public Control[] controls() nothrow @nogc
        {
            return this.m_controls;
        }

        public Control focusedControl() nothrow @nogc
        {
            return this.m_focusedControl;
        }

        public Control controlUnderMouse() nothrow @nogc
        {
            return this.m_controlUnderMouse;
        }

        public Tooltip tooltip() nothrow @nogc
        {
            return this.m_tooltip;
        }
    }

    template ControlGetter(string controlClass)
    {
        enum ControlGetter =
            "public " ~ controlClass ~ " get" ~ controlClass ~ "(in uint id) nothrow @nogc
             {
                return this.getControl!(" ~ controlClass ~ ")(id);
             }";
    }
}