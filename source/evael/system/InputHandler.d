module evael.system.InputHandler;

public import bindbc.glfw;

import std.traits : EnumMembers;

import evael.system.Input;

import evael.core.Game;
import evael.utils.Math;

/**
 * Input handler.
 * Handle mouse movements and mouse buttons / keys states.
 */
class InputHandler
{
	private Game m_game;

	private bool[ [EnumMembers!(MouseButton)].length ] m_mouseButtonsStates;

	private vec2 m_mousePosition;
	private bool m_mouseHasMoved;
	private bool m_mouseButtonClicked;

	/**
	 * InputHandler constructor.
	 */
	@nogc
	public this(Game game) nothrow
	{
		this.m_game = game;

		this.m_mouseButtonsStates = [false, false];
		this.m_mouseHasMoved = false;
		this.m_mouseButtonClicked = false;
	}

	/**
	 * InputHandler destructor.
	 */
	public void dispose()
	{

	}

	/**
	 * Updates input states and triggers events.
	 */
	public void update()
	{
		if (this.m_mouseHasMoved)
		{
			this.m_game.currentGameState.onMouseMove(this.m_mousePosition);
			this.m_mouseHasMoved = false;
		}

		if (this.m_mouseButtonClicked)
		{
			static bool[] lastMouseButtonsStates = [false, false];

			bool isMouseButtonPressed;
			int enumIndex;

			static foreach (e; [EnumMembers!(MouseButton)])
			{
				enumIndex = cast(int)e;
				isMouseButtonPressed = this.m_mouseButtonsStates[enumIndex];

				if (isMouseButtonPressed != lastMouseButtonsStates[enumIndex])
				{
					if (isMouseButtonPressed)
					{
						this.m_game.currentGameState.onMouseClick(this.m_mousePosition, e);
					}
					else this.m_game.currentGameState.onMouseUp(this.m_mousePosition, e);

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
	@nogc @safe
	public bool isMouseButtonClicked(in MouseButton button) pure nothrow
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
		return glfwGetKey(this.m_game.window.glfwWindow, key) == GLFW_PRESS;
	}

	@nogc @safe
	extern(C) pure nothrow
	{
		/**
		 * Event called on mouse button click action.
		 * Params:
		 *		button : mouse button
		 *		action : press or release
		 */
		public void onMouseClick(GLFWwindow* window, int button, int action, int dunno)
		{
			this.m_mouseButtonsStates[button] = (action == GLFW_PRESS);
			this.m_mouseButtonClicked = true;
		}

		/**
		 * Event called on mouse movement.
		 * Params:
		 *		x : x mouse coord
		 *		y : y moue coord
		 */
		public void onMouseMove(GLFWwindow* window, double x, double y)
		{
			this.m_mouseHasMoved = true;            
			this.m_mousePosition = vec2(x, y);
		}
	}

	@nogc @safe
	@property pure nothrow
	{
		public ref const(vec2) mousePosition() const
		{
			return this.m_mousePosition;
		}
	}
}