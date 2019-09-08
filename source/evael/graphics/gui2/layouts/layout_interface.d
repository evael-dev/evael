module evael.graphics.gui2.layouts.layout_interface;

import bindbc.nuklear : nk_context;

/**
 * Layout interface.
 */
interface ILayout
{
	@nogc
	public void apply(nk_context* nuklear) nothrow; 
}