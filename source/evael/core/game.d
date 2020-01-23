module evael.core.game;

import std.typecons;

import evael.core.game_state;
import evael.core.game_config;

import evael.renderer;
import evael.system;
import evael.utils;
import evael.init;

import evael.lib.memory;
import evael.lib.containers : Array;

/**
 * Game
 */
class Game : NoGCClass
{
	private GameConfig m_config;
	private GraphicsDevice m_graphicsDevice;
	private InputHandler m_inputHandler;
	private Window m_window;

	private AssetLoader    m_assetLoader;
	//private EntityManager  m_entityManager;
	private I18n           m_i18n;

	/// Current game state.
	private GameState m_currentGameState;

	/// Tasks of other thread that will be processed by main thread.
	private alias OnEvent = void delegate();
	private Array!OnEvent m_events;

	private alias Task = Tuple!(long, OnEvent);
	private Array!Task m_scheduledTasks;

	/// Indicates if the game is still running.
	private bool m_running;

	/// Values for fixed timestep game loop.
	private float m_tickrate;       // How many times world will be updated per second.
	private float m_deltaTime;      // Time that elapsed since the last tick in ms.
	private int   m_maxFrameSkip;

	private GameState[string] m_gameStates;

	/**
	 * Game constructor.
	 * Params:
	 *      settings : window settings
	 *      contextSettings : gl context settings
	 */
	@nogc
	public this(in string title = "My D Game!", GameConfig config = GameConfig("./config.ini"))
	{
		loadExternalLibraries();
		
		this.m_config = config;

		this.m_assetLoader = AssetLoader.getInstance();

		this.m_inputHandler = MemoryHelper.create!InputHandler();

		this.m_window = MemoryHelper.create!Window(title, config.graphicsSettings);
		this.m_window.onWindowClose = bindDelegate(&this.onWindowClose);
		this.m_window.onWindowSize = bindDelegate(&this.onWindowResize);
		this.m_window.onScroll = bindDelegate(&this.onMouseWheel);
		this.m_window.onKey = bindDelegate(&this.onKey);
		this.m_window.onChar = bindDelegate(&this.onText);
		this.m_window.onCursorPos = bindDelegate(&this.onMouseMove);
		this.m_window.onMouseButton = bindDelegate(&this.onMouseButton);

		this.m_graphicsDevice = MemoryHelper.create!GraphicsDevice(config.graphicsSettings, this.m_window.glfwWindow);

		this.m_tickrate = 64.0f;
		this.m_deltaTime = 1000.0f / this.m_tickrate;
		this.m_maxFrameSkip = 5;

		this.m_running = true;
/*
		this.m_audioDevice = MemoryHelper.create!AudioDevice();
		//this.m_entityManager = new EntityManager();


		this.m_i18n = new I18n();
		this.m_i18n.setLocale("fr");*/
	}

	/**
	 * Game destructor.
	 */
	@nogc
	public ~this()
	{
		this.m_running = false;

		this.m_events.dispose();

		foreach (gameState; this.m_gameStates.byValue)
		{
			MemoryHelper.dispose(gameState);
		}

		MemoryHelper.dispose(this.m_graphicsDevice);
		MemoryHelper.dispose(this.m_window);
		MemoryHelper.dispose(this.m_inputHandler);

		this.m_assetLoader.dispose();

		unloadExternalLibraries();
	}

	/**
	 * Deault game loop.
	 */
	public void run()
	{
		float nextGameTick = getCurrentTime();

		int loops = 0;

		while (this.m_running)
		{	
			immutable currentTick = getCurrentTime();
			loops = 0;

			while (currentTick > nextGameTick && loops < this.m_maxFrameSkip)
			{
				this.fixedUpdate();

				nextGameTick += this.m_deltaTime;
				loops++;               
			}

			immutable interpolation = cast(float) (currentTick + this.m_deltaTime - nextGameTick) / cast(float) this.m_deltaTime;

			this.update(interpolation);    
			this.pollEvents();
		}
	}

	/**
	 * Processes game logic at fixed time rate, defined by m_tickrate.
	 */
	public void fixedUpdate()
	{
		synchronized(this)
		{
			for (; this.m_events.length ;)
			{
				this.m_events[0]();
				this.m_events.removeAt(0);
			}
		}

		this.m_currentGameState.fixedUpdate();        
	}

	/**
	 * Processes game rendering.
	 * Params:
	 *      interpolation : 
	 */
	public void update(in float interpolation)
	{
		this.m_inputHandler.update();        
		this.m_currentGameState.update(interpolation);
	}

	/**
	 * Defines current game state.
	 * Params:
	 *		params : params
	 *
	 * Note: intentionnaly not annotated with @nogc.
	 */
	public void setGameState(T)(Variant[] params = null)
	{
		T* gameState = cast(T*) (T.stringof in this.m_gameStates);
		
		if (this.m_currentGameState !is null)
		{
			this.m_currentGameState.onExit();
		}

		if (gameState is null) 
		{
			T gs = MemoryHelper.create!T();
			(cast(GameState) gs).setParent(this);
			this.m_gameStates[T.stringof] = gs;
			this.m_currentGameState = gs;
		}
		else this.m_currentGameState = *gameState;

		this.m_currentGameState.onInit(params);
	}

	/**
	 * Sets window mouse cursor.
	 * Params:
	 *      cursor : new cursor toset
	 */
	@nogc
	public void setCursor(in Cursor cursor) nothrow
	{
		this.m_window.setCursor(cursor);
	}

	/**
	 * Polls window events.
	 */
	@nogc
	public void pollEvents() nothrow
	{
		this.m_window.pollEvents();
	}

	/**
	 * Adds event that will be processed by the main thread.
	 * Params:
	 *      event : event delegate
	 */
	@nogc
	public void addEvent(OnEvent event)
	{
		synchronized(this)
		{
			this.m_events.insert(event);
		}
	}

	/**
	 * Adds scheduled event that will be processed by the main thread.
	 * Params:
	 *      time : time in seconds before executing the task
	 *      task : task delegate
	 */
	@nogc
	public void addScheduledTask(in float time, OnEvent task) nothrow
	{
		auto taskTuple = tuple(cast(long) (1000 * time), task);

		// Before adding a new tuple, we search for a free task slot
		foreach (i, ref t; this.m_scheduledTasks)
		{
			// Free slot check
			if (t[1] is null)
			{
				this.m_scheduledTasks[i] = taskTuple;
				return;
			}
		}

		this.m_scheduledTasks.insert(taskTuple);
	}

	extern(C) nothrow
	{
		/**
		 * Event called on mouse button action.
		 * Params:
		 *		button : mouse button
		 *		action : press or release
		 */
		public void onMouseButton(GLFWwindow* window, int button, int action, int dunno)
		{
			try
			{
				immutable bool pressed = action == GLFW_PRESS;
				immutable MouseButton mouseButton = cast(MouseButton) button;

				this.m_inputHandler.onMouseButton(mouseButton, pressed);

				if (pressed)
				{
					this.m_currentGameState.onMouseClick(mouseButton, this.m_inputHandler.mousePosition);
				}
				else
				{
					this.m_currentGameState.onMouseUp(mouseButton, this.m_inputHandler.mousePosition);
				}
			}
			catch(Exception e)
			{
			}
		}

		/**
		 * Event called on mouse movement.
		 * Params:
		 *		x : x mouse coord
		 *		y : y moue coord
		 */
		public void onMouseMove(GLFWwindow* window, double x, double y)
		{
			try
			{
				immutable position = vec2(x, y);
				this.m_inputHandler.onMouseMove(position);
				this.m_currentGameState.onMouseMove(position);
			}
			catch(Exception e)
			{
			}
		}
		
		/**
		 * Event called on mouse wheel action.
		 * Params:
		 *      window : window
		 *      xoffset : xoffset
		 *      yoffset : yoffset
		 */
		public void onMouseWheel(GLFWwindow* window, double xoffset, double yoffset)
		{
			try
			{
				this.m_currentGameState.onMouseWheel(cast(int)xoffset);
			}
			catch(Exception e)
			{
			}
		}

		/**
		 * Event called on character input.
		 * Params:
		 *      window : window
		 *      codepoint : codepoint
		 */
		public void onText(GLFWwindow* window, uint codepoint)
		{
			try
			{
				this.m_currentGameState.onText(codepoint);
			}
			catch(Exception e)
			{
			}
		}

		/**
		 * Event called on key action.
		 * Params:
		 *      window : window
		 *      key : key
		 *      scancode : scancode
		 *      action : action (key press or release)
		 *      mods : mods
		 */
		public void onKey(GLFWwindow* window, int key, int scancode, int action, int mods)
		{
			try
			{
				immutable Key ekey = cast(Key) key;
				action == GLFW_RELEASE ? this.m_currentGameState.onKeyDown(ekey) : this.m_currentGameState.onKeyUp(ekey);
			}
			catch(Exception e)
			{
			}
		}

		/**
		 * Event called on window resize action.
		 * Params:
		 *      window : window
		 *      width : new width
		 *      height : new height
		 */
		public void onWindowResize(GLFWwindow* window, int width, int height)
		{
		}

		/**
		 * Event called on window close action.
		 * Params:
		 *      window : window
		 */
		public void onWindowClose(GLFWwindow* window)
		{
			this.m_running = false;
		}
	}

	/**
	 * Properties.
	 */
	@nogc
	@property nothrow
	{
		public AssetLoader assetLoader()
		{
			return this.m_assetLoader;
		}

		/*public EntityManager entityManager()
		{
			return this.m_entityManager;
		}*/

		public GameState currentGameState()
		{
			return this.m_currentGameState;
		}

		public I18n i18n()
		{
			return this.m_i18n;
		}

		public InputHandler inputHandler()
		{
			return this.m_inputHandler;
		}

		public bool running() const
		{
			return this.m_running;
		}

		public float deltaTime() const
		{
			return this.m_deltaTime;
		}

		public void tickrate(in float value)
		{
			this.m_tickrate = value;
			this.m_deltaTime = 1000.0f / this.m_tickrate;
		}

		public int maxFrameSkip() const
		{
			return this.m_maxFrameSkip;
		}

		public void maxFrameSkip(in int value)
		{
			this.m_maxFrameSkip = value;
		}

		public Window window()
		{
			return this.m_window;
		}
	}
}