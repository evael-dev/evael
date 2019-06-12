module evael.core.GameState;

import decs;

import evael.core.Game;

import evael.graphics.GraphicsDevice;
import evael.graphics.Drawable;
import evael.graphics.gui.GuiManager;

import evael.system.Input;
import evael.system.AssetLoader;

import evael.utils.Math;

public import std.variant;

/**
 * GameState.
 */
abstract class GameState
{
	protected Game 		 	 m_game;
	protected GraphicsDevice m_graphicsDevice;
	protected GuiManager  	 m_guiManager;
	protected AssetLoader 	 m_assetLoader;

	/// Indicates if mouse button is clicked
	protected bool m_mouseClicked;

	/**
	 * GameState constructor.
	 */
	@nogc @safe
	public this() pure nothrow
	{

	}

	/**
	 * GameState destructor.
	 */
	public void dispose()
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
		this.m_mouseClicked = true;

		this.m_guiManager.onMouseClick(mouseButton, position);
		this.m_game.nuklear.onMouseClick(mouseButton, position);
	}

	/**
	 * Event called on mouse button release action.
	 * Params:
	 *		mouseButton : released mouse button
	 *		position : mouse position
	 */
	public void onMouseUp(in MouseButton mouseButton, in ref vec2 position)
	{
		this.m_mouseClicked = false;

		this.m_guiManager.onMouseUp(mouseButton);
		this.m_game.nuklear.onMouseUp(mouseButton, position);	
	}

	/**
	 * Event called on mouse movement action.
	 * Params:
	 *		position : mouse position
	 */
	public void onMouseMove(in ref vec2 position)
	{		
		this.m_guiManager.onMouseMove(position);
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
		this.m_guiManager.onText(text);
	}

	/**
	 * Event called on key action.
	 * Params:
	 *		key : pressed key
	 */
	public void onKey(in int key)
	{
		this.m_guiManager.onKey(key);
	}

	/**
	 * Sets game state parent.
	 * Called only one time by Game class.
	 */
	@nogc @safe
	package void setParent(Game game) pure nothrow
	{
		this.m_game = game;
		this.m_graphicsDevice = game.graphicsDevice;
		this.m_guiManager = game.guiManager;
		this.m_assetLoader = game.assetLoader;
	}

	public Entity createEntity()
	{
		return this.m_game.entityManager.createEntity();
	}

	@nogc @safe
	@property pure nothrow
	{
		public Game game()
		{
			return this.m_game;
		}

		public GraphicsDevice graphicsDevice()
		{
			return this.m_graphicsDevice;
		}

		public GuiManager guiManager()
		{
			return this.m_guiManager;
		}

		public EntityManager entityManager()
		{
			return this.m_game.entityManager;
		}
	}
}