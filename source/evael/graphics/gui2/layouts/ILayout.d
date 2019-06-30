module evael.graphics.gui2.layouts.ILayout;

import bindbc.nuklear : nk_context;

interface ILayout
{
	@nogc
	public void apply(nk_context* nuklear) nothrow; 
}