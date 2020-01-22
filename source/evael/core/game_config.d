module evael.core.game_config;

import inifiled;

import evael.utils.size;

/*
 * Global game config.
 */
@INI("Game config")
struct GameConfig
{
	private string m_configName;

	/*
	 * Graphics related settings.
	 */
	@INI("Graphics")
	public GraphicsSettings graphicsSettings;

	@INI("Paths")
	public Paths paths;

	public this(in string configName)
	{	
		readINIFile(this, configName);
		this.m_configName = configName;
	}

	public void save()
	{
		writeINIFile(this, this.m_configName);
	}
}

@INI("Graphics settings")
struct GraphicsSettings
{
	@INI("Window width")
	public uint width;

	@INI("Window height")
	public uint height;
	
	@INI("Fullscreen window?")
	public bool fullscreen = false;

	@INI("Resizable window?")
	public bool resizable = false;

	@INI("VSync enabled?")
	public bool vsync = false;
}

@INI("Assets paths")
struct Paths
{
	@INI
	public string shaders;
	@INI
	public string fonts;
	@INI
	public string models;
	@INI
	public string textures;
	@INI
	public string sounds;
}
