module evael.graphics.gui.controls.Control;

import std.conv;
import std.typecons;

public
{
    import derelict.nanovg.nanovg;
    
    import evael.graphics.gui.controls.ContextMenuStrip;
    import evael.graphics.gui.Theme;
    import evael.graphics.gui.State;
    import evael.graphics.gui.Icons;

    import evael.system.Input;
}

import evael.graphics.gui.animations.Animation;
import evael.graphics.gui.animations.AnimationSet;

import evael.graphics.Font;
import evael.graphics.Texture;

import evael.utils.Math;
import evael.utils.Size;
import evael.utils.Rectangle;

abstract class Control
{
    enum Dock : ubyte
    {
        None,
        Fill,
        Left,
        Bottom,
        Right,
        Top,
    }

    protected alias OnClickEvent = void delegate(Control sender);
    protected alias OnDragEvent = void delegate(Control sender, vec2 mousePosition);
    protected alias OnDropEvent = void delegate(Control sender, vec2 mousePosition);

    protected OnClickEvent m_onClickEvent;
    protected OnClickEvent m_onDoubleClickEvent;
    protected OnDragEvent m_onDragEvent;
    protected OnDropEvent m_onDropEvent;

    /// NanoVG context
    public NVGcontext* m_nvg;

    /// Control id
    private size_t m_id;

    /// Control theme
    protected Theme m_theme;

    /// Parent control
    protected Control m_parent;

    /// Control name, used in GuiManager when loading themes
    protected string m_name;

    /// Control position
    protected vec2 m_position;

    /// Control real position for borders in shader
    protected vec2 m_realPosition;

    /// Control position before drag and drop
    protected vec2 m_positionBeforeDragAndDrop;

    /// Control size
    protected Size!int m_size;

    /// Control texture
    protected Texture m_texture;

    /// Is control under the mouse ?
    protected bool m_hasFocus;

    /// Is control displayed  ?
    protected bool m_isVisible;

    /// Is control enabled ?
    protected bool m_isEnabled;

    /// Is control focusable ?
    protected bool m_isFocusable;

    /// Control has been initialized ?
    protected bool m_initialized;

    /// Control can be moved with mouse ?
    protected bool m_movable;

    /// Control opacity
    protected ubyte m_opacity;

    /// Dock
    protected Dock m_dock;

    /// Control tooltip
    protected wstring m_tooltipText;

    /// Texture coords
    protected Rectangle!float m_textureCoords;

    /// Last click tick for button double click detection
    private long m_lastClickTick;

    /// ContextMenu for this control
    protected ContextMenuStrip m_contextMenu;

    /// Last mouse position
    protected vec2 m_mousePosition;

    /// Current fill color
    protected Color m_fillColor;

    /// Clicked buttons
    protected bool[MouseButton] m_mouseButtonsStates;

    /// Last mouse button clicked
    protected MouseButton m_lastClickedMouseButton;

    /// Mouse button used to drag current control
    protected Nullable!MouseButton m_draggingMouseButton;

    /// z-index
    protected uint m_zIndex;

    /// Control animations
    protected AnimationSet m_animationSet;

    
    public this(in vec2 position, in Size!int size) nothrow
    {
        this.m_position = position;
        this.m_size = size;

        this.m_hasFocus = false;
        this.m_isVisible = true;
        this.m_isEnabled = true;
        this.m_isFocusable = false;
        this.m_movable = false;

        this.m_opacity = 255;

        this.m_textureCoords = Rectangle!float(0, 0, 0, 0);

        this.m_mouseButtonsStates = [MouseButton.Left : false, MouseButton.Right : false];
        this.m_draggingMouseButton = Nullable!MouseButton();
    }

    public void update(in float deltaTime)
    {
        if (this.m_animationSet !is null)
        {
            this.m_animationSet.update(deltaTime);
        }
    }

    /**
     * Draws the control
     */
    public void draw(in float deltaTime)
    {
        if (this.m_theme.background.type == Background.Type.Transparent)
        {
            return;
        }

        immutable x = this.m_realPosition.x;
        immutable y = this.m_realPosition.y;
        immutable w = this.m_size.width;
        immutable h = this.m_size.height;

        immutable cornerRadius = this.m_theme.cornerRadius;

        auto vg = this.m_nvg;

        NVGpaint shadowPaint;
        NVGpaint headerPaint;

        // Control
        nvgSave(vg);

        nvgTranslate(vg, x, y);
        // nvgScale(vg, 2, 2);

        if(this.m_theme.background.type == Background.Type.Solid)
        {
            nvgBeginPath(vg);
            nvgRoundedRect(vg, 0, 0, w, h, cornerRadius);
            nvgFillColor(vg, this.m_fillColor.asNvg);
            nvgFill(vg);

            if (this.m_theme.drawDropShadow)
            {
                // Drop shadow
                shadowPaint = nvgBoxGradient(vg, 0, 0, w, h, cornerRadius, 10,
                        nvgRGBA(0, 0, 0, this.m_opacity), nvgRGBA(0, 0, 0, 0));

                nvgBeginPath(vg);
                nvgRect(vg, -10, -10, w + 20, h + 20);
                nvgRoundedRect(vg, 0, 0, w, h, cornerRadius);
                nvgPathWinding(vg, NVGsolidity.NVG_HOLE);
                nvgFillPaint(vg, shadowPaint);
                nvgFill(vg);
            }
        }

        // Border
        if (this.m_theme.borderType == Theme.BorderType.Solid)
        {
            nvgBeginPath(vg);
            nvgRoundedRect(vg, 0, 0, w, h, cornerRadius);
            nvgStrokeColor(vg, this.m_theme.borderColor.asNvg);
            nvgStroke(vg);
        }

        nvgRestore(vg);
    }

    /**
     * Event called on mouse button click
     * Params:
     *		mouseButton : mouse button
     *		mousePosition : mouse position
     */
    public void onMouseClick(in MouseButton mouseButton, in ref vec2 mousePosition)
    {
        import evael.utils.Functions;

        this.m_mouseButtonsStates[mouseButton] = true;
        this.m_lastClickedMouseButton = mouseButton;

        immutable long currentAppTick = timeSinceProgramStarted().total!"msecs";

        // We check for fast double click
        if (currentAppTick - this.m_lastClickTick < 400)
        {
            // Avoid triple click
            this.m_lastClickTick = 0;

            if (this.m_onDoubleClickEvent !is null)
            {
                this.m_onDoubleClickEvent(this);
            }

            return;
        }

        this.m_lastClickTick = currentAppTick;
    }

    /**
     * Event called on mouse button release
     * Params:
     *		mouseButton : mouse button
     */
    public void onMouseUp(in MouseButton mouseButton)
    {
        this.m_mouseButtonsStates[mouseButton] = false;

        if (this.m_onClickEvent !is null && this.m_isEnabled)
        {
            this.m_onClickEvent(this);
        }
    }

    /**
     * Event called when mouse enters in control's rect
     * Params:
     * 		 mousePosition : mouse position
     */
    public void onMouseMove(in ref vec2 mousePosition)
    {
        this.m_mousePosition = mousePosition;
    }

    /**
     * Event called when mouse leaves control's rect
     */
    public void onMouseLeave()
    {

    }

    /**
     * Event called on character input
     * Params:
     *		text :
     */
    public void onText(in int key)
    {

    }

    /**
     * Event called on key input
     * Params:
     *		key : pressed key
     */
    public void onKey(in int key)
    {

    }

    /**
     * Event called when control has been dragged
     * Params:
     *		mousePosition : mouse position
     */
    public void onDrag(in ref vec2 mousePosition)
    {
        // We set drag and drop mousebutton
        if (this.m_draggingMouseButton.isNull)
        {
            this.m_draggingMouseButton = Nullable!MouseButton(this.m_lastClickedMouseButton);
        }

        if (this.m_onDragEvent !is null)
        {
            this.m_onDragEvent(this, mousePosition);
        }
    }

    /**
     * Event called when control has been dropped
     * Params:
     *		mousePosition : mouse position
     */
    public void onDrop(in ref vec2 mousePosition)
    {
        // We unset drag and drop mousebutton
        if (this.m_draggingMouseButton.isNull)
        {
            this.m_draggingMouseButton = Nullable!MouseButton();
        }

        if (this.m_onDropEvent !is null)
        {
            this.m_onDropEvent(this, mousePosition);
        }
    }

    /**
     * Control gains focus
     */
    public void onFocus()
    {

    }

    /**
     * Control lose focus
     */
    public void onUnfocus()
    {

    }

    /**
     * Condition for drag and drop of this control
     */
    public bool canBeDragged() nothrow
    {
        return this.m_movable;
    }

    /**
     * Initializes control
     */
    public void initialize()
    {
        this.m_initialized = true;

        this.m_fillColor = this.m_theme.background.colorStateList.normal;

        if (this.m_parent !is null)
        {
            this.m_realPosition = this.m_position + this.m_parent.m_realPosition;
        }
        else
        {
            this.m_realPosition = this.m_position;
        }

        if (this.m_contextMenu !is null)
        {
            this.m_contextMenu.initialize();
        }

        // We create a nvg id for the texture
        if (this.m_texture !is null)
        {
            if (this.m_nvg !is null && this.m_texture.nvgId == 0)
            {
                this.m_texture.nvgId = nvglCreateImageFromHandleGL3(this.m_nvg,
                        this.m_texture.id, this.m_texture.size.width,
                        this.m_texture.size.height, 0);
            }
        }
    }

    /**
     * Displays the control
     */
    public void show() nothrow @nogc
    {
        this.m_isVisible = true;
    }

    /**
     * Hides the control
     */
    public void hide() nothrow @nogc
    {
        this.m_isVisible = false;
    }

    /**
     * Gives focus to the control
     */
    public void focus()
    {
        this.m_hasFocus = true;

        this.onFocus();
    }

    /**
     * Removes focus from the control
     */
    public void unfocus()
    {
        this.m_hasFocus = false;

        this.onUnfocus();
    }

    /**
     * Enables the control
     */
    public void enable()
    {
        this.m_isEnabled = true;
    }

    /**
     * Disables the control
     */
    public void disable()
    {
        this.m_isEnabled = false;
        this.switchState!(State.Disabled);
    }

    /**
     * Switchs control state
     */
    public void switchState(State state)() nothrow
    {
        this.m_fillColor = this.m_theme.background.colorStateList.fromEnum!(state)();
    }

    /**
     * Starts a single animation
     * Params:
     *      animation :
     */
    public void startAnimation(Animation animation)
    {
        auto animationSet = new AnimationSet();
        animationSet.add(animation);

        this.startAnimation(animationSet);
    }

    /**
     * Starts a set of animations
     * Params:
     *      animationSet : animations
     */
    public void startAnimation(AnimationSet animationSet)
    {
        this.m_animationSet = animationSet;
        this.m_animationSet.control = this;

        this.m_animationSet.onSequenceEndEvent = () {
            this.m_animationSet.dispose();
            this.m_animationSet = null;
        };
    }

    @property public void opacity(in ubyte value)   @nogc
    {
        this.m_fillColor.a = value;
        this.m_opacity = value;

        if (this.theme !is null)
        {
            this.m_theme.borderColor.a = value;
            this.m_theme.fontColor.a = value;
        }
    }

    /**
     * Properties
     */
    @property
    {
        public void nvg(NVGcontext* nvg) nothrow @nogc
        {
            this.m_nvg = nvg;
        }

        public Theme theme() nothrow @nogc
        {
            return this.m_theme;
        }

        public void theme(Theme value) nothrow @nogc
        {
            this.m_theme = value;
        }

        public size_t id() const nothrow @nogc
        {
            return this.m_id;
        }

        public void id(in size_t value) nothrow @nogc
        {
            this.m_id = value;
        }

        public ubyte opacity() nothrow
        {
            return this.m_opacity;
        }

        public ref const(vec2) position() const nothrow @nogc
        {
            return this.m_position;
        }

        public void position(in vec2 value) nothrow @nogc
        {
            this.m_position = value;
        }

        public ref const(vec2) realPosition() const nothrow @nogc
        {
            return this.m_realPosition;
        }

        public void realPosition(in vec2 value) nothrow @nogc
        {
            this.m_realPosition = value;
        }

        public ref const(vec2) positionBeforeDragAndDrop() const nothrow @nogc
        {
            return this.m_positionBeforeDragAndDrop;
        }

        public void positionBeforeDragAndDrop(in vec2 value) nothrow @nogc
        {
            this.m_positionBeforeDragAndDrop = value;
        }

        public ref const(Size!int) size() const nothrow @nogc
        {
            return this.m_size;
        }

        public void size(in Size!int value) nothrow @nogc
        {
            this.m_size = value;
        }

        public Texture texture() nothrow @nogc
        {
            return this.m_texture;
        }

        public void texture(Texture value) nothrow @nogc
        {
            this.m_texture = value;

            // Default texcoords : full texture
            if (this.m_texture !is null)
            {
                if (this.m_nvg !is null && this.m_texture.nvgId == 0)
                {
                    this.m_texture.nvgId = nvglCreateImageFromHandleGL3(this.m_nvg,
                            this.m_texture.id, this.m_texture.size.width,
                            this.m_texture.size.height, 0);
                }

                this.m_textureCoords = Rectanglef(0, 0,
                        this.m_texture.size.width, this.m_texture.size.height);
            }
        }

        public bool hasFocus() const nothrow @nogc
        {
            return this.m_hasFocus;
        }

        public bool isVisible() const nothrow @nogc
        {
            return this.m_isVisible;
        }

        public void isVisible(in bool value) nothrow @nogc
        {
            this.m_isVisible = value;
        }

        public Control parent() nothrow @nogc
        {
            return this.m_parent;
        }

        public void parent(Control value) nothrow @nogc
        {
            this.m_parent = value;
        }

        public bool isClicked() const nothrow
        {
            return this.m_mouseButtonsStates[MouseButton.Left]
                || this.m_mouseButtonsStates[MouseButton.Right];
        }

        public bool isEnabled() const nothrow @nogc
        {
            return this.m_isEnabled;
        }

        public bool movable() const nothrow @nogc
        {
            return this.m_movable;
        }

        public void movable(in bool value) nothrow @nogc
        {
            this.m_movable = value;
        }

        public bool isFocusable() const nothrow @nogc
        {
            return this.m_isFocusable;
        }

        public void isFocusable(in bool value) nothrow @nogc
        {
            this.m_isFocusable = value;
        }

        public Dock dock() const nothrow @nogc
        {
            return this.m_dock;
        }

        public void dock(Dock value) nothrow @nogc
        {
            this.m_dock = value;
        }

        public void onClickEvent(OnClickEvent callback) nothrow @nogc
        {
            this.m_onClickEvent = callback;
        }

        public void onDoubleClickEvent(OnClickEvent callback) nothrow @nogc
        {
            this.m_onDoubleClickEvent = callback;
        }

        public wstring tooltipText() const nothrow @nogc
        {
            return this.m_tooltipText;
        }

        public void tooltipText(in wstring tooltip) nothrow @nogc
        {
            this.m_tooltipText = tooltip;
        }

        public void tooltipText(in string tooltip)
        {
            this.m_tooltipText = to!wstring(tooltip);
        }

        public ContextMenuStrip contextMenu() nothrow @nogc
        {
            return this.m_contextMenu;
        }

        public void onDragEvent(OnDragEvent callback) nothrow @nogc
        {
            this.m_onDragEvent = callback;
        }

        public void onDropEvent(OnDropEvent callback) nothrow @nogc
        {
            this.m_onDropEvent = callback;
        }

        public void textureCoords(in Rectangle!float value) nothrow @nogc
        {
            this.m_textureCoords = value;
        }

        public string name() const nothrow @nogc
        {
            return this.m_name;
        }

        public void name(in string value) nothrow @nogc
        {
            this.m_name = value;
        }

        public const(bool[MouseButton]) mouseButtonsStates() const nothrow @nogc
        {
            return this.m_mouseButtonsStates;
        }

        public MouseButton lastClickedMouseButton() const nothrow @nogc
        {
            return this.m_lastClickedMouseButton;
        }

        public Nullable!MouseButton draggingMouseButton() const nothrow @nogc
        {
            return this.m_draggingMouseButton;
        }

        public ref const(Color) fillColor() const nothrow @nogc
        {
            return this.m_fillColor;
        }

        public void fillColor(in Color value) nothrow @nogc
        {
            this.m_fillColor = value;
        }

        public uint zIndex() const nothrow @nogc
        {
            return this.m_zIndex;
        }

        public void zIndex(in uint value) nothrow @nogc
        {
            this.m_zIndex = value;
        }
    }
}
