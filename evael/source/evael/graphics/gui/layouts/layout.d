module evael.graphics.gui.layouts.layout;

import bindbc.nuklear : nk_context, nk_layout_row_dynamic, nk_layout_row_static;

import evael.graphics.gui.layouts.layout_params;
import evael.graphics.gui.layouts.layout_interface;

alias DynamicLayout = Layout!(LayoutType.Dynamic);
alias StaticLayout = Layout!(LayoutType.Static);

/**
 * Layout type.
 */
enum LayoutType
{
	Dynamic,
	Static
}

/**
 * Layout.
 */
class Layout(LayoutType T) : ILayout
{
	/// Layout params
	private LayoutParams m_params;

	@nogc
	public this(in LayoutParams params = LayoutParams()) nothrow
	{
		this.m_params = params;
	}

	@nogc
	public void apply(nk_context* nuklearContext) nothrow
	{
		// We could use nk_layout_row to avoid static if, but its not present in bindbc-nuklear
		static if (T == LayoutType.Dynamic)
		{
			nk_layout_row_dynamic(nuklearContext, this.m_params.height, this.m_params.columns);
		}
		else
		{
			nk_layout_row_static(nuklearContext, this.m_params.height, this.m_params.columns, this.m_params.width);
		}
	}
}