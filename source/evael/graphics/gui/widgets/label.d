module evael.graphics.gui.widgets.label;

import evael.graphics.gui.widgets.widget;

class Label : Widget
{
	public enum Alignment
	{
		Left = nk_text_alignment.NK_TEXT_LEFT,
		Centered = nk_text_alignment.NK_TEXT_CENTERED,
		Righ = nk_text_alignment.NK_TEXT_RIGHT
	}

	private string m_text;

	private Alignment m_alignment;

	@nogc
	public this() nothrow
	{
		super();
		this.m_alignment = Alignment.Left;
	}

	public override void draw()
	{
		this.applyLayout();
		nk_label(this.nuklearContext, cast(char*) this.m_text.ptr, this.m_alignment);
	}

	@nogc
	@property nothrow
	{
		public Label text(in string value)
		{
			this.m_text = value;
			return this;
		}

		public Label alignment(in Alignment value)
		{
			this.m_alignment = value;
			return this;
		}
	}
}