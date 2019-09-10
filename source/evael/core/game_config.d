module evael.core.game_config;

import inifiled;

struct GameConfig
{
	@INI("Paths")
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

	public static Paths paths;

	public static void load(in string configName)
	{	
		readINIFile(paths, configName);
	}
}
