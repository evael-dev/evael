module evael.graphics.gui2.layouts.Layout;

import bindbc.nuklear : nk_layout_row_dynamic, nk_layout_row_static;

import evael.graphics.gui2.layouts.ILayout;
import evael.graphics.gui2.layouts.LayoutParams;

alias DynamicLayout = Layout!(LayoutType.Dynamic);
alias StaticLayout = Layout!(LayoutType.Static);

/// Layout type
enum LayoutType
{
	Dynamic,
	Static
}

class Layout(LayoutType T) : ILayout
{
	/// Layout params
	private LayoutParams m_params;

	@nogc @safe
	public this(in LayoutParams params = LayoutParams()) pure nothrow
	{
		this.m_params = params;
	}

	@nogc
	public void apply(NuklearGLFW nuklear) nothrow
	{
		// We could use nk_layout_row to avoid static if, but its not present in bindbc-nuklear
		static if (T == LayoutType.Dynamic)
		{
			nk_layout_row_dynamic(nuklear.context, this.m_params.height, this.m_params.columns);
		}
		else
		{
			nk_layout_row_static(nuklear.context, this.m_params.height, this.m_params.columns, this.m_params.width);
		}
	}
}