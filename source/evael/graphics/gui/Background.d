module evael.graphics.gui.Background;

import evael.graphics.gui.StateList;

import evael.utils.Color;

import jsonizer;

alias ColorStateList = StateList!Color;

struct Background
{
	mixin JsonizeMe;
	
	enum Type : ubyte
	{
		Transparent,
		Solid,
		Sprite
	}
	
	private @jsonize("type") Type m_type;
	private @jsonize("colorStateList") ColorStateList m_colorStateList;

	@nogc 
	public this()(in auto ref Type type, auto ref ColorStateList value) nothrow
	{
		this.m_type = type;
		this.m_colorStateList = value;
	}

	/**
	 * Properties
	 */
	@nogc 
	@property nothrow
	{
		public Type type() const
		{
			return this.m_type;
		}

		public void type(in Type value)
		{
			this.m_type = value;
		}
		
		public void colorStateList()(in auto ref ColorStateList value)
		{
			this.m_colorStateList = value;
		}

		public auto colorStateList()
		{
			return this.m_colorStateList;
		}
		
	  /*  public void sprite()(in auto ref Sprite value) nothrow @nogc
		{
			this.m_data.sprite = value;
		}*/
	}

}