module evael.graphics.gui.controls.ProgressBar;

import std.conv : to;
import std.math;

import evael.graphics.gui.controls.Control;

import evael.utils.math;

import evael.utils.Size;
import evael.utils.Color;

class ProgressBar : Control
{
	/// Max value
	private float m_maxValue;

	/// Current value
	private float m_currentValue;

	/// Bar position
	private vec2 m_barPosition;

	/// Bar data in vbo
	private uint m_barVerticesPtr, m_barColorsPtr;

	/// Value of 1 bar pixel
	private float m_indentation;

	/// Draw progressbar background ?
	private bool m_drawBackground;

	/// Draw animation bar ?
	private bool m_drawAnimationBar;

	/// Filled bar
	private int m_barWidth;

	/// Bar color
	private Color m_color;

	public this(in float x, in float y, in int width, in int height = 22)
	{
		super(vec2(x, y), Size!int(width ,height));

		this.m_name = "progressBar";

		this.m_barPosition = vec2(2.0f, 2.0f);

		this.m_maxValue = 100.0f;
		this.m_currentValue = 1.0f;

		this.m_drawAnimationBar = false;
	}

	/**
	 * Renders the ProgressBar
	 */
	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);

		immutable x = this.m_realPosition.x;
		immutable y = this.m_realPosition.y;
		immutable w = this.m_size.width;
		immutable h = this.m_size.height;

		immutable cornerRadius = this.m_theme.cornerRadius;

		auto vg = this.m_nvg;
		
		// Filled part
		nvgBeginPath(vg);
		nvgRoundedRect(vg, x, y, this.m_barWidth, h, cornerRadius);
		nvgFillColor(vg, this.m_color.asNvg);
		nvgFill(vg);
	}

	/**
	 * Initializes control
	 */
	public override void initialize()
	{
		super.initialize();

		// Formula : (36000 / 70) / 70 = 514 / 70 = 7,xx, one pixel is ~7
		this.m_indentation = this.m_size.width / this.m_maxValue;

		this.m_barWidth = cast(int)ceil(this.m_currentValue * this.m_indentation);

		if(this.m_barWidth > this.m_size.width)
		{
			this.m_barWidth = this.m_size.width;
		}

		this.m_tooltipText = this.m_currentValue.to!wstring() ~ " / " ~ this.m_maxValue.to!wstring();
	}

	public void opUnary(string op)()
	{
        mixin("this.value = this.m_currentValue " ~ op[0] ~ " 1;");
    }

	@property
	{
		public void maxValue(in float value)
		{
			this.m_maxValue = value;

			// If control is already initialized, we have to update the bar manually
			if(this.m_initialized)
			{
				this.m_tooltipText = this.m_currentValue.to!wstring() ~ " / " ~ this.m_maxValue.to!wstring();
			}
		}
		
		public float maxValue() const nothrow @nogc
		{
			return this.m_maxValue;
		}

		public void value(in float cvalue) nothrow @nogc
		{
			this.m_currentValue = cvalue;

			if(this.m_initialized)
			{
				this.m_barWidth = cast(int)ceil(this.m_currentValue * this.m_indentation);

				if(this.m_barWidth > this.m_size.width)
				{
					this.m_barWidth = this.m_size.width;
				}
			}
		}

		public float value() const nothrow @nogc
		{
			return this.m_currentValue;
		}
		public void color()(in auto ref Color value)
		{
			this.m_color = value;
		}
	}
}