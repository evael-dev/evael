module evael.graphics.gui2.widgets.Widget;

public import evael.graphics.gui2.NuklearGLFW;

import evael.graphics.gui2.layouts.ILayout;

abstract class Widget
{
	public NuklearGLFW nuklear;

	/// Widget layout (dynamic or static)
	protected ILayout m_layout;

    @nogc @safe
    public this() pure nothrow
	{
	}

	public void draw();

	@nogc
	public void applyLayout() nothrow
	{
		if (this.m_layout !is null)
		{
			this.m_layout.apply(this.nuklear);
		}
	}

	@nogc @safe
	@property pure nothrow
	{
		public auto layout(ILayout value)
		{
			this.m_layout = value;
			return this;
		}
	}
}