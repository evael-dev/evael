module evael.graphics.gui.Theme;

public 
{
	import evael.graphics.gui.Background;    
	import evael.graphics.Font;    
	import evael.utils.Color;
}

import std.typecons;

import jsonizer;

class Theme
{
	mixin JsonizeMe;

	/// Border type
	enum BorderType
	{
		Solid,
		None
	}
	
	@jsonize 
	{
		/// Border type
		public BorderType borderType = BorderType.Solid;
		
		/// Radius
		public float cornerRadius;

		/// Draw drop shadow ?
		public bool drawDropShadow = true;

		/// Draw text shadow ?
		public bool drawTextShadow = true;

		/* Fonts */
		public Font font;
		public Font iconFont;

		/* Font size */
		public int fontSize;

		/* Colors */
		public Color borderColor;
		public Color dropShadowColor;
		public Color fontColor;
		public Color disabledTextColor;

		/// Background
		public Background background;
		
		/// Scale
		public float scale = 1.0f;

		public Color[string] customColors;
	}

	public Theme parent;
	public Theme[string] subThemes;

	public string name;

	public Theme copy()
	{
		void* data = cast(void *)typeid(this).create();
		data[0 .. typeid(this).initializer.length] = (cast(void*)this)[0 .. typeid(this).initializer.length];

		return cast(Theme)data;
	}
}