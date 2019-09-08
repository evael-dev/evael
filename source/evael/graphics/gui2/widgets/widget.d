module evael.graphics.gui2.widgets.widget;

public import bindbc.nuklear;

import evael.graphics.gui2.layouts.layout_interface;

abstract class Widget
{
	public nk_context* nuklearContext;

	/// Widget layout (dynamic or static)
	protected ILayout m_layout;

    @nogc
    public this() nothrow
	{
		//this.m_layout = new 
	}

	public void draw();

	@nogc
	public void applyLayout() nothrow
	{
		if (this.m_layout !is null)
		{
			this.m_layout.apply(nuklearContext);
		}
	}

	@nogc
	@property nothrow
	{
		public auto layout(ILayout value)
		{
			this.m_layout = value;
			return this;
		}
	}
}