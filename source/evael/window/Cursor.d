module evael.Window.Cursor;

import derelict.glfw3.glfw3;

/**
 * Cursors
 */
enum Cursor
{
	Arrow = GLFW_ARROW_CURSOR,
	Hand = GLFW_HAND_CURSOR,
	Crosshair = GLFW_CROSSHAIR_CURSOR,
	Ibeam = GLFW_IBEAM_CURSOR,
	HorizontalResize = GLFW_HRESIZE_CURSOR,
	VerticalResize = GLFW_VRESIZE_CURSOR
}
