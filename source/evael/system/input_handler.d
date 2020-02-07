module evael.system.input_handler;

public import bindbc.glfw;

import std.traits : EnumMembers;

import evael.system.input;
import evael.utils.math;
import evael.lib.memory.no_gc_class;

/**
 * Input handler.
 * Handle mouse movements and mouse buttons / keys states.
 */
class InputHandler : NoGCClass
{
	private bool[ [EnumMembers!(MouseButton)].length ] m_mouseButtonsStates;

	private vec2 m_mousePosition;
	private bool m_mouseButtonClicked;
	
	/**
	 * InputHandler constructor.
	 */
	@nogc
	public this() nothrow
	{
		this.m_mouseButtonsStates = [false, false];
		this.m_mouseButtonClicked = false;
	}

	/**
	 * InputHandler destructor.
	 */
	@nogc
	public ~this()
	{

	}

	/**
	 * Updates input states and triggers events.
	 */
	public void update()
	{
		if (this.m_mouseButtonClicked)
		{
			static bool[2] lastMouseButtonsStates = [false, false];

			bool isMouseButtonPressed;
			int enumIndex;

			static foreach (e; [EnumMembers!(MouseButton)])
			{
				enumIndex = cast(int) e;
				isMouseButtonPressed = this.m_mouseButtonsStates[enumIndex];

				if (isMouseButtonPressed != lastMouseButtonsStates[enumIndex])
				{
					lastMouseButtonsStates[enumIndex] = isMouseButtonPressed;
				}
			}

			this.m_mouseButtonClicked = false;
		}
	}

	/**
	 * Checks if a specific mouse button is clicked.
	 * Params:
	 *      button : mouse button
	 */
	@nogc
	public bool isMouseButtonClicked(in MouseButton button) nothrow
	{
		return this.m_mouseButtonsStates[button] == GLFW_PRESS;
	}

	/**
	 * Checks if a specific key is pressed.
	 * Params:
	 *      key : key
	 */
	@nogc
	public bool isKeyPressed(in Key key) nothrow
	{
		// TODO: ASAP!!!
		return false;
	}

	/**
	 * Event called on mouse button action.
	 * Params:
	 *		button : mouse button
	 *		pressed : pressed or released
	 */
	@nogc
	public void onMouseButton(in MouseButton button, in bool pressed)
	{
		this.m_mouseButtonsStates[button] = pressed;
		this.m_mouseButtonClicked = true;
	}

	/**
	 * Event called on mouse movement.
	 * Params:
	 *		x : x mouse coord
	 *		y : y moue coord
	 */
	@nogc
	public void onMouseMove(in ref vec2 position)
	{
		this.m_mousePosition = position;
	}

	@nogc
	@property nothrow
	{
		public ref const(vec2) mousePosition() const
		{
			return this.m_mousePosition;
		}
	}
}