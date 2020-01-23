module evael.core.game_state;

import evael.core.game;

import evael.system.input;
import evael.system.asset_loader;

import evael.utils.math;

import evael.lib.memory;

public import std.variant;

/**
 * GameState.
 */
abstract class GameState : NoGCClass
{
	protected Game m_game;
	protected AssetLoader m_assetLoader;

	/**
	 * GameState constructor.
	 */
	@nogc
	public this()
	{
		
	}

	/**
	 * GameState destructor.
	 */
	@nogc
	public ~this()
	{
	} 

	/**
	 * Processes game logic at fixed time rate, defined by m_tickrate.
	 */
	public abstract void fixedUpdate();	
	
	/**
	 * Processes game rendering.
	 * Params:
	 *      interpolation : 
	 */
	public abstract void update(in float interpolation);

	/**
	 * Event called when current game state is defined as the main state.
	 * Params:
	 *		params : 
	 */
	public void onInit(Variant[] params = null)
	{

	}

	/**
	 * Event called when current game state ends.
	 * Params:
	 *		params : 
	 */
	public void onExit()
	{

	}

	/**
	 * Event called on mouse button click action.
	 * Params:
	 *		mouseButton : clicked mouse button
	 *		position : mouse position
	 */
	public void onMouseClick(in MouseButton mouseButton, in ref vec2 position)
	{
		// this.m_guiManager.onMouseClick(mouseButton, position);
	}

	/**
	 * Event called on mouse button release action.
	 * Params:
	 *		mouseButton : released mouse button
	 *		position : mouse position
	 */
	public void onMouseUp(in MouseButton mouseButton, in ref vec2 position)
	{
		// this.m_guiManager.onMouseUp(mouseButton);
	}

	/**
	 * Event called on mouse movement action.
	 * Params:
	 *		position : mouse position
	 */
	public void onMouseMove(in ref vec2 position)
	{		
		// this.m_guiManager.onMouseMove(position);
	}

	/**
	 * Event called on mouse wheel action.
	 * Params:
	 *		delta : delta value
	 */
	public void onMouseWheel(in int delta)
	{

	}

	/**
	 * Event called on character input.
	 * Params:
	 *		text : 
	 */
	public void onText(in int text)
	{
		// this.m_guiManager.onText(text);
	}

	/**
	 * Event called on key down action.
	 * Params:
	 *		key : pressed key
	 */
	public void onKeyDown(in Key key)
	{
		// this.m_guiManager.onKey(key);
	}

	/**
	 * Event called on key up action.
	 * Params:
	 *		key : released key
	 */
	public void onKeyUp(in Key key)
	{
		// this.m_guiManager.onKey(key);
	}

	/**
	 * Sets game state parent.
	 * Called only one time by Game class.
	 */
	@nogc
	package void setParent(Game game) nothrow
	{
		this.m_game = game;
		// this.m_guiManager = game.guiManager;
		this.m_assetLoader = game.assetLoader;
	}

	// TODO: use evael-ecs
	/*public Entity createEntity()
	{
		return this.m_game.entityManager.createEntity();
	}*/

	@nogc
	@property nothrow
	{
		public Game game()
		{
			return this.m_game;
		}

		/*public GuiManager guiManager()
		{
			return this.m_guiManager;
		}*/

		/*public EntityManager entityManager()
		{
			return this.m_game.entityManager;
		}*/
	}
}