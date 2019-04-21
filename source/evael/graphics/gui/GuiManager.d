module evael.graphics.gui.GuiManager;

import std.algorithm;
import std.array : array;
import std.file : read;
import std.json : parseJSON, JSONValue;
import std.conv : to;
import std.string : format;
import jsonizer;

import evael.graphics.GUI;
import evael.graphics.GraphicsDevice;

import evael.system.AssetLoader;
import evael.system.Input;

import evael.utils.math;
import evael.utils.Rectangle;

/**
 * GuiManager.
 */
class GuiManager
{
	private GraphicsDevice m_graphicsDevice;
	private NVGcontext* m_nvg;

	/// Container list
	private Container[] m_containers;
	
	/// Control that have the focus
	private Container m_focusedControl;

	/// Control under the mouse
	private Container m_controlUnderMouse;

	/// Drag'n'dropped control
	private Control m_dragAndDropControl;

	private vec2 m_mousePosition;
	
	/// Default theme
	private Theme m_defaultTheme;

	/// Current theme
	private Theme m_currentTheme;

	private string[] m_customControlsTypes = ["button", "textBlock", "textBox", "progressBar", "textArea", "slider", 
			"panel", "listBox", "listBoxItem", "checkBox", "contextMenuStrip",
			"contextMenuStripItem", "pictureBox", "tooltip", "comboBox", "scrollBar"];
	
	/**
	 * GuiManager constructor.
	 */
	public this(GraphicsDevice graphics)
	{
		this.m_graphicsDevice = graphics;
        this.m_nvg = graphics.nvgContext;

		this.m_defaultTheme = this.loadTheme("medias\\ui\\themes\\default.json");
		this.m_currentTheme = this.m_defaultTheme;
	}
	
	/**
	 * GuiManager destructor.
	 */
	@nogc @safe
	public void dispose() pure nothrow
	{

	}

	public void update(in float deltaTime)
	{
		nvgBeginFrame(this.m_nvg, this.m_graphicsDevice.viewportSize.width, this.m_graphicsDevice.viewportSize.height, 1);
		
		foreach (control; this.m_containers)
		{
			control.draw(deltaTime);
		}
		
		nvgEndFrame(this.m_nvg);
	}

	public void fixedUpdate(in float deltaTime)
	{
		foreach (control; this.m_containers)
		{
			control.update(deltaTime);
		}
	}


	/**
	 * Adds a container and initializes it.
	 * Params:
	 *		 container : container to add
	 */
	public void add(Container container)
	{
		container.nvg = this.m_nvg;

		if (container.name in this.m_currentTheme.subThemes)
		{
			// This container have a custom theme
			container.theme = this.m_currentTheme.subThemes[container.name];
		}
		else
		{
			container.theme = this.m_currentTheme.copy();
		}

		container.initialize();

		this.m_containers ~= container;
	} 

	/**
	 * Removes a control.
	 * Params:
	 *		 control : control to remove
	 */
	public void remove(Control toRemove)
	{
		foreach (i, control; this.m_containers)
		{
			if (control == toRemove)
			{
				this.m_containers = this.m_containers.remove(i);
				return;
			}
		}
	}


	/**
	 * Loads a theme.
	 * Params:
	 *		fileName : theme to load
	 */
	public Theme loadTheme(in string fileName)
	{
		// We load base theme
		auto themeJson = fileName.read().to!string().parseJSON();
		auto theme = themeJson.fromJSON!(Theme);

		auto assetLoader = AssetLoader.getInstance();
		
		if (theme.font !is null)
		{
			theme.font = assetLoader.load!(Font)(theme.font.name, this.m_nvg);
			theme.iconFont = assetLoader.load!(Font)(theme.iconFont.name, this.m_nvg);			
		}

		theme.parent = null;
		theme.name = "base";
		theme.subThemes = loadSubThemes(theme, themeJson);

		return theme;
	}

	private Theme[string] loadSubThemes(Theme parentTheme, JSONValue json)
	{
		Theme[string] toRet;

		// We load controls themes
		foreach (controlType; this.m_customControlsTypes)
		{
			if (controlType in json)
			{
				auto controlJson = json[controlType];

				// Theme has been found for this control, inherited from base theme
				auto controlTheme = parentTheme.copy();
				controlTheme.parent = parentTheme;
				controlTheme.name = parentTheme.name ~ "." ~ controlType;

				// We need to update custom fields values
				foreach (i, dummy ; typeof(Theme.tupleof))
				{
					enum name = Theme.tupleof[i].stringof;
					enum type = typeof(Theme.tupleof[i]).stringof;

					static if (type != "Theme*")
					{
						if(name in controlJson)
						{
							static if(type == "BorderType")
							{
								mixin(`controlTheme.%s = controlJson["%s"].fromJSON!(Theme.%s);`.format(name, name, type));
							}
							else
							{
								mixin(`controlTheme.%s = controlJson["%s"].fromJSON!(%s);`.format(name, name, type));
							}
						}
					}
				}

				toRet[controlType] = controlTheme;

				controlTheme.subThemes = loadSubThemes(controlTheme, controlJson);
			}
			
		}

		return toRet;
	}

	
	/**
	 * Sets current theme.
	 * Params:
	 *		theme : current theme for next controls
	 */
	@nogc @safe
	public void setTheme()(in auto ref Theme theme) pure nothrow
	{
		this.m_currentTheme = theme;
	}

	/**
	 * Loads and sets current theme.
	 * Params:
	 *		themeName : theme to load
	 */
	public void setTheme(in string themeName)
	{
		this.m_currentTheme = this.loadTheme(themeName);
	}

	/**
	 * Adds a custom control type for theme loading.
	 * Params:
	 *		type : custom type
	 */
	public void addCustomControlType(in string type)
	{
		this.m_customControlsTypes ~= type;
	}
	
	/**
	 * Event called on mouse button click action.
	 * Params:
	 *		position : mouse position
	 *		mouseButton : clicked mouse button
	 */
	public void onMouseClick(in MouseButton mouseButton, in ref vec2 mousePosition)
	{
		if (this.m_controlUnderMouse !is null)
		{
			this.m_controlUnderMouse.onMouseClick(mouseButton, mousePosition);			
						
			if (this.m_dragAndDropControl is null || !this.m_dragAndDropControl.isClicked)
			{
				this.m_dragAndDropControl = this.getDeepestControlUnderMouse(this.m_mousePosition);
				
				if (this.m_dragAndDropControl !is null)
				{					
					if(this.m_dragAndDropControl.canBeDragged())
					{
						this.m_dragAndDropControl.positionBeforeDragAndDrop = this.m_dragAndDropControl.realPosition;
					}
					else
					{
						this.m_dragAndDropControl = null;
					}
				}
			}
		}
	}

	/**
	 * Event called on mouse button release action.
	 * Params:
	 *		position : mouse position
	 *		mouseButton : released mouse button
	 */
	public void onMouseUp(in MouseButton mouseButton)
	{
		if (this.m_controlUnderMouse !is null)
		{
			// We stop drag and drop only if user released the button used to drag the control
			if (this.m_dragAndDropControl !is null 
				&& (this.m_dragAndDropControl.draggingMouseButton.isNull || mouseButton == this.m_dragAndDropControl.draggingMouseButton))
			{
				// We need to check if mouse has been moved while clicked
				if (this.m_dragAndDropControl.realPosition != this.m_dragAndDropControl.positionBeforeDragAndDrop)
				{
					this.m_dragAndDropControl.onDrop(this.m_mousePosition);
					this.m_dragAndDropControl = null;
				}
			}

			this.m_controlUnderMouse.onMouseUp(mouseButton);

			if (this.m_controlUnderMouse.isFocusable)
			{
				this.focus(this.m_controlUnderMouse);
			}
		}
	}

	/**
	 * Event called on mouse movement action.
	 * Params:
	 *		position : mouse position
	 */
	public void onMouseMove(in ref vec2 position)
	{	
		scope (exit)
		{
			this.m_mousePosition = position;
		}
		
		// We draw the control that is under the mouse at the end
		if (this.m_controlUnderMouse !is null)
		{
			this.m_containers.sort!((a, b) => b == this.m_controlUnderMouse);
		}

		/**
		 * Special case : drag and drop
		 */
		if (this.m_dragAndDropControl !is null && this.m_dragAndDropControl.isClicked && this.m_dragAndDropControl.movable)
		{
			// Yes. We handle this.
			immutable newPosition = vec2(position.x - this.m_dragAndDropControl.size.halfWidth, position.y - this.m_dragAndDropControl.size.halfHeight);

			this.m_dragAndDropControl.position = newPosition;
			this.m_dragAndDropControl.realPosition = newPosition;

			this.m_dragAndDropControl.onDrag(position);
			
			return;
		}

		/**
		 * Normal case
		 */
		auto lastControlUnderMouse = this.m_controlUnderMouse;

		this.m_controlUnderMouse = this.getControlUnderMouse(position);

		if (this.m_controlUnderMouse !is null)
		{
			this.m_controlUnderMouse.onMouseMove(position);

			Control tooltipControl = this.m_controlUnderMouse;

			// We search for the control under the mouse and update the tooltip text
			auto deepestFocusedControl = this.getDeepestControlUnderMouse(position);
			
			// At this point we have the last-level container under the mouse, 
			// if his tooltiptext is set or if he doesn't have child control under mouse,
			// we will use his tooltiptext
			if (deepestFocusedControl.tooltipText !is null || deepestFocusedControl.controlUnderMouse is null)
			{
				tooltipControl = deepestFocusedControl;
			}
			else
			{
				tooltipControl = deepestFocusedControl.controlUnderMouse;
			}

			this.m_controlUnderMouse.tooltip.realPosition = vec2(position.x + 13, position.y + 5);			
			this.m_controlUnderMouse.tooltip.text = tooltipControl.tooltipText;
			this.m_controlUnderMouse.tooltip.show();
		}

		// We call onMouseLeave on last control under mouse if its different
		if (lastControlUnderMouse !is null && this.m_controlUnderMouse != lastControlUnderMouse)
		{
			lastControlUnderMouse.onMouseLeave();
		}
	}

	/**
	 * Event called on character input.
	 * Params:
	 *		text : 
	 */
	public void onText(in int text)
	{
		// %, esc, del, ctrl + a
		if (text == 37 || text == 27 || text == 8 || text == 1)
			return;

		if (this.m_focusedControl !is null)
		{
			this.m_focusedControl.onText(text);
		}
	}

	/**
	 * Event called on key action.
	 * Params:
	 *		key : pressed key
	 */
	public void onKey(in int key)
	{
		if(this.m_focusedControl !is null)
		{
			this.m_focusedControl.onKey(key);
		}
	}

	/**
	 * Returns the first-level container under the mouse.
	 */
	private Container getControlUnderMouse(in ref vec2 position)
	{
		foreach(container; this.m_containers)
		{
			if(!container.isVisible)
			{
				continue;
			}

			immutable rect = Rectanglef(container.position.x, container.position.y, container.size);

			if(rect.isIn(position))
			{
				return container;
			}
		}

		return null;
	}

	/**
	 * Returns the last-level container under the mouse.
	 */
	private Container getDeepestControlUnderMouse(in ref vec2 position)
	{
		auto control = this.getControlUnderMouse(position);

		if (control is null)
		{
			return null;
		}

		auto deepestFocusedControl = control;

		while (control !is null)
		{
			deepestFocusedControl = control;
			control = cast(Container) control.controlUnderMouse;
		}

		return deepestFocusedControl;
	}


	/**
	 * Returns a control by his id.
	 * Params:
	 *		 id : control id
	 */
	public Control getControlById(in uint id) nothrow	
	{
		auto range = this.m_containers.filter!(c => c.id == id).array;

		return range.length ? range[0] : null;
	}

	/**
	 * Removes all controls.
	 */
	@nogc @safe
	public void clear() pure nothrow
	{
		this.m_containers = null;
	}

	/**
	 * Gives focus to a control.
	 */
	public void focus(Container control)
	{
		control.focus();

		this.m_focusedControl = control;
	}

	/**
	 * Removes focus from a control.
	 */
	public void unfocus(Container control)
	{
		control.unfocus();

		this.m_focusedControl = null;
	}

	@nogc @safe
	@property pure nothrow
	{
		public Container focusedControl()
		{
			return this.m_focusedControl;
		}

		public Control controlUnderMouse()
		{
			return this.m_controlUnderMouse;
		}
	}
}