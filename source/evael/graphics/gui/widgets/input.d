module evael.graphics.gui.widgets.input;

import evael.graphics.gui.widgets.widget;

enum InputType
{
	Default,
    Ascii,
    Float,
    Decimal,
    Hexadecimal,
    Octet,
    Binary
}

class Input(InputType T) : Widget
{
	private alias OnSelectEvent = void delegate(in int value);
	private OnSelectEvent m_onSelectEvent;

	private string m_value;

	private nk_plugin_filter m_filter;

	@nogc
	public this() nothrow
	{
		this.m_value = "";
		final switch (T)
		{
			case InputType.Default: 	this.m_filter = nk_filter_default; break;
			case InputType.Ascii: 	    this.m_filter = nk_filter_ascii;   break;
			case InputType.Float: 	  	this.m_filter = nk_filter_float;   break;
			case InputType.Decimal: 	this.m_filter = nk_filter_decimal; break;
			case InputType.Hexadecimal: this.m_filter = nk_filter_hex;	   break;
			case InputType.Octet: 	    this.m_filter = nk_filter_oct; 	   break;
			case InputType.Binary: 	    this.m_filter = nk_filter_binary;  break;
		}
	}

	public override void draw()
	{
		this.applyLayout();
        nk_edit_string_zero_terminated(this.nuklearContext, NK_EDIT_FIELD, cast(char*) this.m_value.ptr, 256, this.m_filter);
	}

	@nogc
	@property nothrow
	{
		public Input text(in string value)
		{
			this.m_value = value;
			return this;
		}
	}
}