module evael.graphics.gui.controls.Panel;

import evael.graphics.gui.controls.Container;

import evael.utils.Math;

import evael.utils.Size;
import evael.utils.Color;

class Panel : Container
{
	public this(in vec2 position, in Size!int size)
	{
		super(position, size);

		this.m_name = "panel";
	}

	public this(in float x, in float y, in int width = 0, in int height = 0)
	{
		this(vec2(x, y), Size!int(width, height));
	}


	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);
	}
}