module evael.core.Game;

import std.array : split;
import std.conv;
import std.typecons;

public import decs;

import dnogc.DynamicArray;

import evael.core.GameState;

import evael.graphics.GraphicsDevice;
import evael.graphics.Font;
import evael.graphics.gui2.GuiManager;

import evael.audio.AudioDevice;

import evael.system.AssetLoader;
import evael.system.InputHandler;
import evael.system.Input;
import evael.system.I18n;
import evael.system.Window;
import evael.system.WindowSettings;
import evael.system.GLContextSettings;
import evael.system.Cursor;

import evael.utils.Math;
import evael.utils.Singleton;
import evael.utils.Size;
import evael.utils.Config;
import evael.utils.Functions;

import evael.Init;

/**
 * Game
 */
class Game
{
	private Window         m_window;
	private GraphicsDevice m_graphicsDevice;
	private GuiManager     m_guiManager;
	private AssetLoader    m_assetLoader;
	private AudioDevice    m_audioDevice;
	private EntityManager  m_entityManager;
	private I18n           m_i18n;
	private InputHandler   m_inputHandler;

	/// Current game state.
	private GameState m_currentGameState;

	/// Tasks of other thread that will be processed by main thread.
	private alias OnEvent = void delegate();
	private DynamicArray!OnEvent m_events;

	private alias Task = Tuple!(long, OnEvent);
	private DynamicArray!Task m_scheduledTasks;

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
	public this(in WindowSettings settings, in GLContextSettings contextSettings = GLContextSettings())
	{
		loadExternalLibraries();
			   
		Config.load("./config.ini");

		this.m_window = new Window(settings, contextSettings);
		this.m_window.setWindowCloseCallback(bindDelegate(&this.onWindowClose));
		this.m_window.setWindowSizeCallback(bindDelegate(&this.onWindowResize));
		this.m_window.setScrollCallback(bindDelegate(&this.onMouseWheel));
		this.m_window.setKeyCallback(bindDelegate(&this.onKey));
		this.m_window.setCharCallback(bindDelegate(&this.onText));

		this.m_inputHandler = new InputHandler(this);

		this.m_window.setCursorPosCallback(bindDelegate(&this.m_inputHandler.onMouseMove));
		this.m_window.setMouseButtonCallback(bindDelegate(&this.m_inputHandler.onMouseClick));

		this.m_graphicsDevice = GraphicsDevice.getInstance();
		this.m_assetLoader = AssetLoader.getInstance();
		this.m_graphicsDevice.defaultFont = this.m_assetLoader.load!(Font)("Roboto-Regular.ttf", this.m_graphicsDevice.nvgContext);
		this.m_graphicsDevice.resolution = settings.resolution;
		this.m_guiManager = new GuiManager(this.m_graphicsDevice, this.m_window.glfwWindow);
		this.m_audioDevice = new AudioDevice();
		this.m_entityManager = new EntityManager();

		this.m_tickrate = 64.0f;
		this.m_deltaTime = 1000.0f / this.m_tickrate;
		this.m_maxFrameSkip = 5;

		this.m_i18n = new I18n();
		this.m_i18n.setLocale("fr");

		this.m_running = true;
	}

	/**
	 * Game destructor.
	 */
	public void dispose()
	{
		this.m_running = false;

		foreach (gameState; this.m_gameStates.byValue)
		{
			gameState.dispose();
		}

		this.m_window.dispose();
		this.m_events.dispose();
		this.m_currentGameState.dispose();
		this.m_audioDevice.dispose();
		this.m_graphicsDevice.dispose();
		this.m_guiManager.dispose();

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

            immutable interpolation = cast(float)(currentTick + this.m_deltaTime - nextGameTick) / cast(float) this.m_deltaTime;

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
				this.m_events.remove(0);
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
			T gs = new T();
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
			this.m_events ~= event;
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

		this.m_scheduledTasks ~= taskTuple;
	}

	extern(C) nothrow
	{
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
			if(action == GLFW_RELEASE)
			{
				try
				{
					this.m_currentGameState.onKey(key);
				}
				catch(Exception e)
				{
				}
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
			this.m_graphicsDevice.resolution = Size!int(width, height);
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
	@nogc @safe
	@property pure nothrow
	{
		public GraphicsDevice graphicsDevice()
		{
			return this.m_graphicsDevice;
		}

		public GuiManager guiManager()
		{
			return this.m_guiManager;
		}

		public AssetLoader assetLoader()
		{
			return this.m_assetLoader;
		}

		public EntityManager entityManager()
		{
			return this.m_entityManager;
		}

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