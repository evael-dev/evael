module evael.graphics.gui2.widgets.ColorPicker;

import evael.graphics.gui2.widgets.Widget;

import evael.utils.Color;

class ColorPicker : Widget
{
	private alias OnSelectEvent = void delegate(Color color);
	private OnSelectEvent m_onSelectEvent;

	private nk_colorf m_color;

	@nogc @safe
	public this() pure nothrow
	{
		super();
		this.m_color = nk_colorf(1.0, 1.0, 1.0, 1.0);
	}

	public override void draw()
	{
		this.applyLayout();
		if (nk_combo_begin_color(this.nuklear.context, nk_rgb_cf(this.m_color), nk_vec2(nk_widget_width(this.nuklear.context), 400))) {
			nk_layout_row_dynamic(this.nuklear.context, 120, 1);
			this.m_color = nk_color_picker(this.nuklear.context, this.m_color, NK_RGBA);
			nk_layout_row_dynamic(this.nuklear.context, 25, 1);
			this.m_color.r = nk_propertyf(this.nuklear.context, "#R:", 0, this.m_color.r, 1.0f, 0.01f,0.005f);
			this.m_color.g = nk_propertyf(this.nuklear.context, "#G:", 0, this.m_color.g, 1.0f, 0.01f,0.005f);
			this.m_color.b = nk_propertyf(this.nuklear.context, "#B:", 0, this.m_color.b, 1.0f, 0.01f,0.005f);
			this.m_color.a = nk_propertyf(this.nuklear.context, "#A:", 0, this.m_color.a, 1.0f, 0.01f,0.005f);
			nk_combo_end(this.nuklear.context);

			static nk_colorf lastColor;

			if (this.m_color != lastColor && this.m_onSelectEvent !is null)
			{
				lastColor = this.m_color;
				this.m_onSelectEvent(Color(this.m_color.r, this.m_color.g, this.m_color.b, this.m_color.a));
			}
		}
	}

	@nogc @safe
	@property pure nothrow
	{
		public ColorPicker color(in Color value)
		{
			this.m_color = nk_colorf(value.r, value.g, value.b, value.a);
			return this;
		}

		public Color color()
		{
			return Color(this.m_color.r, this.m_color.g, this.m_color.b, this.m_color.a);
		}
		
		public ColorPicker onSelect(OnSelectEvent value)
		{
			this.m_onSelectEvent = value;
			return this;
		}
	}
}