module evael.graphics.gui2.widgets.Label;

import evael.graphics.gui2.widgets.Widget;

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

	@nogc @safe
	public this() pure nothrow
	{
		super();
		this.m_alignment = Alignment.Left;
	}

	public override void draw()
	{
		this.applyLayout();
		nk_label(this.nuklear.context, cast(char*) this.m_text.ptr, this.m_alignment);
	}

	@nogc @safe
	@property pure nothrow
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