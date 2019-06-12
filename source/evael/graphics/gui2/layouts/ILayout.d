module evael.graphics.gui2.layouts.ILayout;

public import evael.graphics.gui2.NuklearGLFW : NuklearGLFW;

interface ILayout
{
	@nogc
	public void apply(NuklearGLFW nuklear) nothrow; 
}