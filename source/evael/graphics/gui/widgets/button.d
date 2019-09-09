module evael.graphics.gui.widgets.button;

import evael.graphics.gui.widgets.widget;

class Button : Widget
{
	private alias OnClickEvent = void delegate();
	private OnClickEvent m_onClickEvent;

	private string m_text;

	public override void draw()
	{
		this.applyLayout();
		if (nk_button_label(this.nuklearContext, cast(const(char)*) this.m_text.ptr))
		{
			if (this.m_onClickEvent !is null)
			{
				this.m_onClickEvent();
			}
		}
	}

	@nogc
	@property nothrow
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