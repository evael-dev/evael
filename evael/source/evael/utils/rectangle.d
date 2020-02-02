module evael.utils.rectangle;

import evael.utils.size;
import evael.utils.math;

alias rectf = Rectangle!float;

/**
 * Rectangle.
 */
struct Rectangle(T = float, S = int)
{
	public T left, right, bottom, top;
	
	public Size!S size;
	
	@nogc
	public this(in T left, in T bottom, in S width, in S height) nothrow
	{
		this(Vector!(T, 2)(left, bottom), Size!S(width, height));
	}

	@nogc
	public this()(in T left, in T bottom, in auto ref Size!S size) nothrow
	{
		this(Vector!(T, 2)(left, bottom), size);
	}

	@nogc
	public this()(in auto ref Vector!(T, 2) position, in auto ref Size!S size) nothrow
	{
		this.left = position.x;
		this.bottom = position.y;

		this.size = size;

		this.right = this.left + this.size.width;
		this.top = this.bottom + this.size.height;
	}
 	
	@nogc
	public bool isIn()(in auto ref ivec2 position) const nothrow
	{
		return position.x >= this.left && position.x <= this.right && 
		   position.y >= this.bottom && position.y <= this.top;
	}

	@nogc
	public bool isIn()(in auto ref vec2 position) const nothrow
	{
		return position.x >= this.left && position.x <= this.right && 
		   position.y >= this.bottom && position.y <= this.top;
	}
}

alias Rectangle!float Rectanglef;