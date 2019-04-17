module evael.utils.Rectangle;

import evael.utils.Size;
import evael.utils.Math;

/**
 * Rectangle.
 */
struct Rectangle(T = float, S = int)
{
	/// Rectangle bounds
	public T left, right, bottom, top;
	
	/// Rectangle size
	private Size!S m_size;
	
	public this(in T left, in T bottom, in S width, in S height)
	{
		this(Vector!(T, 2)(left, bottom), Size!S(width, height));
	}

	public this()(in T left, in T bottom, in auto ref Size!S size)
	{
		this(Vector!(T, 2)(left, bottom), size);
	}

	public this()(in auto ref Vector!(T, 2) position, in auto ref Size!S size)
	{
		this.left = position.x;
		this.bottom = position.y;

		this.m_size = size;

		this.right = this.left + this.m_size.width;
		this.top = this.bottom + this.m_size.height;
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

	@nogc
	@property nothrow
	{
		public ref const(Size!S) size() const
		{
			return this.m_size;
		}
	
		public void size()(in auto ref Size!S value)
		{
			this.m_size = value;
		}
	}
}

alias Rectangle!float Rectanglef;