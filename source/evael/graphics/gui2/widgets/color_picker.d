module evael.graphics.gui2.widgets.color_picker;

import evael.graphics.gui2.widgets.widget;

import evael.utils.color;

class ColorPicker : Widget
{
	private alias OnSelectEvent = void delegate(Color color);
	private OnSelectEvent m_onSelectEvent;

	private nk_colorf m_color;

	@nogc
	public this() nothrow
	{
		super();
		this.m_color = nk_colorf(1.0, 1.0, 1.0, 1.0);
	}

	public override void draw()
	{
		this.applyLayout();
		if (nk_combo_begin_color(this.nuklearContext, nk_rgb_cf(this.m_color), nk_vec2(nk_widget_width(this.nuklearContext), 400))) {
			nk_layout_row_dynamic(this.nuklearContext, 120, 1);
			this.m_color = nk_color_picker(this.nuklearContext, this.m_color, NK_RGBA);
			nk_layout_row_dynamic(this.nuklearContext, 25, 1);
			this.m_color.r = nk_propertyf(this.nuklearContext, "#R:", 0, this.m_color.r, 1.0f, 0.01f,0.005f);
			this.m_color.g = nk_propertyf(this.nuklearContext, "#G:", 0, this.m_color.g, 1.0f, 0.01f,0.005f);
			this.m_color.b = nk_propertyf(this.nuklearContext, "#B:", 0, this.m_color.b, 1.0f, 0.01f,0.005f);
			this.m_color.a = nk_propertyf(this.nuklearContext, "#A:", 0, this.m_color.a, 1.0f, 0.01f,0.005f);
			nk_combo_end(this.nuklearContext);

			static nk_colorf lastColor;

			if (this.m_color != lastColor && this.m_onSelectEvent !is null)
			{
				lastColor = this.m_color;
				this.m_onSelectEvent(Color(this.m_color.r, this.m_color.g, this.m_color.b, this.m_color.a));
			}
		}
	}

	@nogc
	@property nothrow
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