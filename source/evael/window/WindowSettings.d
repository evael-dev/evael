module evael.Window.WindowSettings;

import evael.utils.Size;

/**
 * WindowSettings.
 */
struct WindowSettings
{
	public string title = "My D Game";

	/// Window resolution
	public Size!int resolution = Size!int(1024, 768);
	
	/// Fullscreen window ?
	public bool fullscreen = false;

	/// Resizable window ? (can't be changed at runtime)
	public bool resizable = false;

	/// VSync ?
	public bool vsync = false;
}