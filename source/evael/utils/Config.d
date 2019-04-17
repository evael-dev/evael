module evael.utils.Config;

debug import std.experimental.logger;

import ctini.rtini;

class Config
{
	public __gshared IniSection m_config;

	private alias m_config this;

	public static void load(const string configFile)
	{
		this.m_config = iniConfig(configFile);

		debug infof("Loading config file ", configFile);
	}
}
