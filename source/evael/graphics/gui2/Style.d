module evael.graphics.gui2.Style;

import bindbc.nuklear : nk_style_colors, nk_color;

import evael.utils.Color;

/**
 * Style.
 * Nuklear style.
 */
struct Style
{
	public Color[StyleColor.Count] colors;

	public void opIndexAssign(in Color color, in StyleColor styleColor)
	{
		this.colors[styleColor] = color;
	}

	public static White = Style([
		/* COLOR_TEXT */ Color(70, 70, 70, 255),
		/* COLOR_WINDOW */ Color(175, 175, 175, 255),
		/* COLOR_HEADER */ Color(175, 175, 175, 255),
		/* COLOR_BORDER */ Color(0, 0, 0, 255),
		/* COLOR_BUTTON */ Color(185, 185, 185, 255),
		/* COLOR_BUTTON_HOVER */ Color(170, 170, 170, 255),
		/* COLOR_BUTTON_ACTIVE */ Color(160, 160, 160, 255),
		/* COLOR_TOGGLE */ Color(150, 150, 150, 255),
		/* COLOR_TOGGLE_HOVER */ Color(120, 120, 120, 255),
		/* COLOR_TOGGLE_CURSOR */ Color(175, 175, 175, 255),
		/* COLOR_SELECT */ Color(190, 190, 190, 255),
		/* COLOR_SELECT_ACTIVE */ Color(175, 175, 175, 255),
		/* COLOR_SLIDER */ Color(190, 190, 190, 255),
		/* COLOR_SLIDER_CURSOR */ Color(80, 80, 80, 255),
		/* COLOR_SLIDER_CURSOR_HOVER */ Color(70, 70, 70, 255),
		/* COLOR_SLIDER_CURSOR_ACTIVE */ Color(60, 60, 60, 255),
		/* COLOR_PROPERTY */ Color(175, 175, 175, 255),
		/* COLOR_EDIT */ Color(150, 150, 150, 255),
		/* COLOR_EDIT_CURSOR */ Color(0, 0, 0, 255),
		/* COLOR_COMBO */ Color(175, 175, 175, 255),
		/* COLOR_CHART */ Color(160, 160, 160, 255),
		/* COLOR_CHART_COLOR */ Color(45, 45, 45, 255),
		/* COLOR_CHART_COLOR_HIGHLIGHT */ Color( 255, 0, 0, 255),
		/* COLOR_SCROLLBAR */ Color(180, 180, 180, 255),
		/* COLOR_SCROLLBAR_CURSOR */ Color(140, 140, 140, 255),
		/* COLOR_SCROLLBAR_CURSOR_HOVER */ Color(150, 150, 150, 255),
		/* COLOR_SCROLLBAR_CURSOR_ACTIVE */ Color(160, 160, 160, 255),
		/* COLOR_TAB_HEADER */ Color(180, 180, 180, 255)
	]);

	public static Red = Style([
		/* COLOR_TEXT */ Color(190, 190, 190, 255),
		/* COLOR_WINDOW */ Color(30, 33, 40, 215),
		/* COLOR_HEADER */ Color(181, 45, 69, 220),
		/* COLOR_BORDER */ Color(51, 55, 67, 255),
		/* COLOR_BUTTON */ Color(181, 45, 69, 255),
		/* COLOR_BUTTON_HOVER */ Color(190, 50, 70, 255),
		/* COLOR_BUTTON_ACTIVE */ Color(195, 55, 75, 255),
		/* COLOR_TOGGLE */ Color(51, 55, 67, 255),
		/* COLOR_TOGGLE_HOVER */ Color(45, 60, 60, 255),
		/* COLOR_TOGGLE_CURSOR */ Color(181, 45, 69, 255),
		/* COLOR_SELECT */ Color(51, 55, 67, 255),
		/* COLOR_SELECT_ACTIVE */ Color(181, 45, 69, 255),
		/* COLOR_SLIDER */ Color(51, 55, 67, 255),
		/* COLOR_SLIDER_CURSOR */ Color(181, 45, 69, 255),
		/* COLOR_SLIDER_CURSOR_HOVER */ Color(186, 50, 74, 255),
		/* COLOR_SLIDER_CURSOR_ACTIVE */ Color(191, 55, 79, 255),
		/* COLOR_PROPERTY */ Color(51, 55, 67, 255),
		/* COLOR_EDIT */ Color(51, 55, 67, 225),
		/* COLOR_EDIT_CURSOR */ Color(190, 190, 190, 255),
		/* COLOR_COMBO */ Color(51, 55, 67, 255),
		/* COLOR_CHART */ Color(51, 55, 67, 255),
		/* COLOR_CHART_COLOR */ Color(170, 40, 60, 255),
		/* COLOR_CHART_COLOR_HIGHLIGHT */ Color( 255, 0, 0, 255),
		/* COLOR_SCROLLBAR */ Color(30, 33, 40, 255),
		/* COLOR_SCROLLBAR_CURSOR */ Color(64, 84, 95, 255),
		/* COLOR_SCROLLBAR_CURSOR_HOVER */ Color(70, 90, 100, 255),
		/* COLOR_SCROLLBAR_CURSOR_ACTIVE */ Color(75, 95, 105, 255),
		/* COLOR_TAB_HEADER */ Color(181, 45, 69, 220)
	]);

	public static Blue = Style([
		/* COLOR_TEXT */ Color(20, 20, 20, 255),
		/* COLOR_WINDOW */ Color(202, 212, 214, 215),
		/* COLOR_HEADER */ Color(137, 182, 224, 220),
		/* COLOR_BORDER */ Color(140, 159, 173, 255),
		/* COLOR_BUTTON */ Color(137, 182, 224, 255),
		/* COLOR_BUTTON_HOVER */ Color(142, 187, 229, 255),
		/* COLOR_BUTTON_ACTIVE */ Color(147, 192, 234, 255),
		/* COLOR_TOGGLE */ Color(177, 210, 210, 255),
		/* COLOR_TOGGLE_HOVER */ Color(182, 215, 215, 255),
		/* COLOR_TOGGLE_CURSOR */ Color(137, 182, 224, 255),
		/* COLOR_SELECT */ Color(177, 210, 210, 255),
		/* COLOR_SELECT_ACTIVE */ Color(137, 182, 224, 255),
		/* COLOR_SLIDER */ Color(177, 210, 210, 255),
		/* COLOR_SLIDER_CURSOR */ Color(137, 182, 224, 245),
		/* COLOR_SLIDER_CURSOR_HOVER */ Color(142, 188, 229, 255),
		/* COLOR_SLIDER_CURSOR_ACTIVE */ Color(147, 193, 234, 255),
		/* COLOR_PROPERTY */ Color(210, 210, 210, 255),
		/* COLOR_EDIT */ Color(210, 210, 210, 225),
		/* COLOR_EDIT_CURSOR */ Color(20, 20, 20, 255),
		/* COLOR_COMBO */ Color(210, 210, 210, 255),
		/* COLOR_CHART */ Color(210, 210, 210, 255),
		/* COLOR_CHART_COLOR */ Color(137, 182, 224, 255),
		/* COLOR_CHART_COLOR_HIGHLIGHT */ Color( 255, 0, 0, 255),
		/* COLOR_SCROLLBAR */ Color(190, 200, 200, 255),
		/* COLOR_SCROLLBAR_CURSOR */ Color(64, 84, 95, 255),
		/* COLOR_SCROLLBAR_CURSOR_HOVER */ Color(70, 90, 100, 255),
		/* COLOR_SCROLLBAR_CURSOR_ACTIVE */ Color(75, 95, 105, 255),
		/* COLOR_TAB_HEADER */ Color(156, 193, 220, 255)
	]);

	public static Dark = Style([
		/* COLOR_TEXT */ Color(210, 210, 210, 255),
		/* COLOR_WINDOW */ Color(57, 67, 71, 215),
		/* COLOR_HEADER */ Color(51, 51, 56, 220),
		/* COLOR_BORDER */ Color(46, 46, 46, 255),
		/* COLOR_BUTTON */ Color(48, 83, 111, 255),
		/* COLOR_BUTTON_HOVER */ Color(58, 93, 121, 255),
		/* COLOR_BUTTON_ACTIVE */ Color(63, 98, 126, 255),
		/* COLOR_TOGGLE */ Color(50, 58, 61, 255),
		/* COLOR_TOGGLE_HOVER */ Color(45, 53, 56, 255),
		/* COLOR_TOGGLE_CURSOR */ Color(48, 83, 111, 255),
		/* COLOR_SELECT */ Color(57, 67, 61, 255),
		/* COLOR_SELECT_ACTIVE */ Color(48, 83, 111, 255),
		/* COLOR_SLIDER */ Color(50, 58, 61, 255),
		/* COLOR_SLIDER_CURSOR */ Color(48, 83, 111, 245),
		/* COLOR_SLIDER_CURSOR_HOVER */ Color(53, 88, 116, 255),
		/* COLOR_SLIDER_CURSOR_ACTIVE */ Color(58, 93, 121, 255),
		/* COLOR_PROPERTY */ Color(50, 58, 61, 255),
		/* COLOR_EDIT */ Color(50, 58, 61, 225),
		/* COLOR_EDIT_CURSOR */ Color(210, 210, 210, 255),
		/* COLOR_COMBO */ Color(50, 58, 61, 255),
		/* COLOR_CHART */ Color(50, 58, 61, 255),
		/* COLOR_CHART_COLOR */ Color(48, 83, 111, 255),
		/* COLOR_CHART_COLOR_HIGHLIGHT */ Color(255, 0, 0, 255),
		/* COLOR_SCROLLBAR */ Color(50, 58, 61, 255),
		/* COLOR_SCROLLBAR_CURSOR */ Color(48, 83, 111, 255),
		/* COLOR_SCROLLBAR_CURSOR_HOVER */ Color(53, 88, 116, 255),
		/* COLOR_SCROLLBAR_CURSOR_ACTIVE */ Color(58, 93, 121, 255),
		/* COLOR_TAB_HEADER */ Color(48, 83, 111, 255)
	]);
}

enum StyleColor
{
	Text = nk_style_colors.NK_COLOR_TEXT,
	Window = nk_style_colors.NK_COLOR_WINDOW,
	Header = nk_style_colors.NK_COLOR_HEADER,
	Border = nk_style_colors.NK_COLOR_BORDER,
	Button = nk_style_colors.NK_COLOR_BUTTON,
	ButtonHover = nk_style_colors.NK_COLOR_BUTTON_HOVER,
	ButtonActive = nk_style_colors.NK_COLOR_BUTTON_ACTIVE,
	Toggle = nk_style_colors.NK_COLOR_TOGGLE,
	ToggleHover = nk_style_colors.NK_COLOR_TOGGLE_HOVER,
	ToggleCursor = nk_style_colors.NK_COLOR_TOGGLE_CURSOR,
	Select = nk_style_colors.NK_COLOR_SELECT,
	SelectActive = nk_style_colors.NK_COLOR_SELECT_ACTIVE,
	Slider = nk_style_colors.NK_COLOR_SLIDER,
	SliderCursor = nk_style_colors.NK_COLOR_SLIDER_CURSOR,
	SliderCursorHover = nk_style_colors.NK_COLOR_SLIDER_CURSOR_HOVER,
	SliderCursorActive = nk_style_colors.NK_COLOR_SLIDER_CURSOR_ACTIVE,
	Property = nk_style_colors.NK_COLOR_PROPERTY,
	Edit = nk_style_colors.NK_COLOR_EDIT,
	EditCursor = nk_style_colors.NK_COLOR_EDIT_CURSOR,
	Combo = nk_style_colors.NK_COLOR_COMBO,
	Char = nk_style_colors.NK_COLOR_CHART,
	CharColor = nk_style_colors.NK_COLOR_CHART_COLOR,
	CharColorHighlight = nk_style_colors.NK_COLOR_CHART_COLOR_HIGHLIGHT,
	Scrollbar = nk_style_colors.NK_COLOR_SCROLLBAR,
	ScrollbarCursor = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR,
	ScrollbarHover = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR_HOVER,
	ScrollbarActive = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR_ACTIVE,
	TabHeader = nk_style_colors.NK_COLOR_TAB_HEADER,
	Count = nk_style_colors.NK_COLOR_COUNT
}