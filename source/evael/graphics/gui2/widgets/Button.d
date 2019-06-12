module evael.graphics.gui2.widgets.Button;

import evael.graphics.gui2.widgets.Widget;

class Button : Widget
{
	private alias OnClickEvent = void delegate();
	private OnClickEvent m_onClickEvent;

	private string m_text;

	public override void draw()
	{
		this.applyLayout();
		if (nk_button_label(this.nuklear.context, cast(const(char)*) this.m_text.ptr))
		{
			if (this.m_onClickEvent !is null)
			{
				this.m_onClickEvent();
			}
		}
	}

	@nogc @safe
	@property pure nothrow
	{
		public Button text(in string value)
		{
			this.m_text = value;
			return this;
		}

		public Button onClick(OnClickEvent value)
		{
			this.m_onClickEvent = value;
			return this;
		}
	}
}