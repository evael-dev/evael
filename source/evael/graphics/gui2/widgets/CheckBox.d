module evael.graphics.gui2.widgets.CheckBox;

import evael.graphics.gui2.widgets.Widget;

class CheckBox : Widget
{
	private alias OnChangeEvent = void delegate(in bool value);
	private OnChangeEvent m_onChangeEvent;

	private string m_text;

	private int m_checked;

	public override void draw()
	{
		this.applyLayout();
		if (nk_checkbox_label(this.nuklearContext, cast(char*) this.m_text.ptr, &this.m_checked))
		{
			if (this.m_onChangeEvent !is null)
			{
				this.m_onChangeEvent(this.m_checked == 1);
			}
		}
	}

	@nogc @safe
	@property pure nothrow
	{
		public CheckBox text(in string value)
		{
			this.m_text = value;
			return this;
		}

		public CheckBox checked(in bool value)
		{
			this.m_checked = value;
			return this;
		}

		public CheckBox onChange(OnChangeEvent value)
		{
			this.m_onChangeEvent = value;
			return this;
		}
	}
}