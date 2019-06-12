module evael.utils.Size;

struct Size(T)
{
	public T[2] values;
	public T halfWidth, halfHeight;
	
	public alias x = width;
	public alias y = height;
	
	@nogc
	public this(in T width, in T height) nothrow
	{
		this.values[0] = width;
		this.values[1] = height;
		this.halfWidth = width / 2;
		this.halfHeight = height / 2;
	}

	/**
	 * == and !=
	 */
	@nogc
	public bool opEquals(Size!T b) const nothrow
	{
		return this.values[0] == b.values[0] && this.values[1] == b.values[1];
	}

	/**
	 * += and -=
	 */
	@nogc
	public void opOpAssign(string op)(in auto ref Size s) nothrow
	{
		mixin(q{
			this.values[0] " ~ op ~ "= s.width;
			this.values[1] " ~ op ~ "= v.height;
		});
	}

	@nogc
	@property  
	{
		public T width() const
		{
			return this.values[0];
		}

		public T height() const
		{
			return this.values[1];
		}

		public void width(in T value)
		{
			this.values[0] = value;
			this.halfWidth = value / 2;
		}
		
		public void height(in T value)
		{
			this.values[1] = value;
			this.halfHeight = value / 2;
		}
	}
}

