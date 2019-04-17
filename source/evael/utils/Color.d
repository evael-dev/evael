module evael.utils.Color;

import derelict.nanovg.types : NVGcolor;
import derelict.nanovg.funcs : nvgRGBA;

import jsonizer;

/**
 * Color.
 */
struct Color
{
	mixin JsonizeMe;

	/// Color's values
	@jsonize("rgba") private ubyte[4] m_values;

	/// Predefined colors
	public static Color White = Color(255, 255, 255),
						Black = Color(0, 0, 0),
						Red = Color(255, 0, 0),
						Blue = Color(0, 0, 255),
						Green = Color(0, 255, 0),
						Grey = Color(223, 223, 223),
						LightGrey = Color(240, 240, 240),
						DarkGrey = Color(80, 80, 80),
						Orange = Color(252, 148, 0),
						LightOrange = Color(255, 195, 110),
						Transparent = Color(255, 255, 255, 0);

	/**
	 * Color constructor.
	 * Params:
	 * 		r : r
	 *		g : g
	 *		b : b
	 *		a : a
	 */
	@nogc @safe
	public this(in ubyte r, in ubyte g, in ubyte b, in ubyte a = 255) pure nothrow
	{
		this.m_values = [r, g, b, a];
	}

	@nogc @safe
	public bool opEquals()(in ref Color c) const pure nothrow
	{
		return this.m_values[] == c.m_values[];
	}

	@nogc @safe
	@property nothrow
	{
		public ubyte r() const
		{
			return this.m_values[0];
		}

		public ubyte g() const
		{
			return this.m_values[1];
		}

		public ubyte b() const
		{
			return this.m_values[2];
		}

		public ubyte a() const
		{
			return this.m_values[3];
		}

		public void a(in ubyte value)
		{
			this.m_values[3] = value;
		}
		
		@trusted
		public NVGcolor asNvg() const
		{
			return nvgRGBA(this.m_values[0], this.m_values[1], this.m_values[2], this.m_values[3]);
		}

		public float[4] asFloat() const
		{
			return [this.m_values[0] / 255.0f, this.m_values[1] / 255.0f, this.m_values[2] / 255.0f, this.m_values[3] / 255.0f];
		}
	}

	@nogc
	@property
	public auto ptr() pure nothrow
	{
		return this.m_values.ptr;
	}
}