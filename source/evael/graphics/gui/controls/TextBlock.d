module evael.graphics.gui.controls.TextBlock;

import evael.graphics.gui.controls.Control;
import evael.graphics.Font;

import evael.utils.Math;
import evael.utils.Size;
import evael.utils.Color;

class TextBlock : Control
{
	enum Type
	{
		FixedSize,
		DynamicSize
	}

	enum TextAlignement
	{
		Center = (1u << 0),		// Vertical align
		Middle = (1u << 1),		// Horizontal align
		Top =    (1u << 2),
		Left =   (1u << 3),
		Bottom = (1u << 4),
		Right  = (1u << 5)
	}

	/// Textblock text
	private wstring m_text;

	/// Text position
	private vec2 m_textPosition;

	/// Text color
	private Color m_color;

	/// Text alignement
	private TextAlignement m_textAlignement;

	private int m_nvgTextAlignement;

	/// Type
	private Type m_type;

	/// Indicates if textblock use theme color or custom color
	private bool m_useThemeColor;

	public this()(in auto ref vec2 position, in auto ref Size!int size)
	{
		super(position, size);

		this.m_name = "textBlock";
		this.m_color = Color.Black;

		this.m_textAlignement = TextAlignement.Center | TextAlignement.Middle;
		this.m_type = Type.DynamicSize;

		this.m_useThemeColor = true;
	}

	public this(in float x = 0, in float y = 0)
	{
		this(vec2(x, y), Size!int(0, 0));
	}

	public this(in float x, in float y, in int width, in int height)
	{
		this(vec2(x, y), Size!int(width, height));

		this.m_type = Type.FixedSize;
	}

	public override void draw(in float deltaTime)
	{
		if (!this.m_isVisible)
			return;

		super.draw(deltaTime);

		auto color = this.m_useThemeColor ? this.m_theme.fontColor : this.m_color;

		this.m_theme.font.draw(this.m_text, vec2(this.m_realPosition.x, this.m_realPosition.y) + this.m_textPosition,
			color, this.m_theme.fontSize,  this.m_theme.drawTextShadow, this.m_nvgTextAlignement );
	}

	/**
	 */
	public override void initialize()
	{
		super.initialize();
		
		if(this.m_text.length)
		{
			this.text = this.m_text;
		}
	}

	@property
		public override void opacity(in ubyte value)   @nogc
		{
		super.opacity = value;

		if(!this.m_useThemeColor)
		{
			this.m_color.a = value;
		}
		}

	@property
	{
		public wstring text() const nothrow @nogc
		{
			return this.m_text;
		}


		public void text(in string value)
		{
			import std.conv;

			this.text = value.to!wstring();
		}

		public void text(in wstring value)
		{
			this.m_text = value;

			if(this.m_theme !is null && this.m_theme.font !is null)
			{
				if(this.m_type == Type.DynamicSize)
				{
					float[4] bounds = this.m_theme.font.getTextBounds(this.m_text, 0, this.m_theme.fontSize);

					immutable float w = bounds[2] - bounds[0];
					immutable float h = bounds[3] - bounds[1];
					
					this.m_size.width = cast(int)w + 10;
					this.m_size.height = cast(int)h + 5;

					this.m_textPosition.x = this.m_size.halfWidth;
					this.m_textPosition.y = this.m_size.halfHeight;
					this.m_nvgTextAlignement = NVGalign.NVG_ALIGN_CENTER | NVGalign.NVG_ALIGN_MIDDLE;
				}
				else if(this.m_type == Type.FixedSize)
				{
					this.m_nvgTextAlignement = 0;
					
					/**
					 * Vertical alignement
					 */
					if(this.m_textAlignement & TextAlignement.Center)
					{
						this.m_textPosition.y = this.m_size.halfHeight;
						this.m_nvgTextAlignement = NVGalign.NVG_ALIGN_CENTER;
					}

					if(this.m_textAlignement & TextAlignement.Bottom)
					{
						this.m_textPosition.y = this.m_size.height;
						this.m_nvgTextAlignement += NVGalign.NVG_ALIGN_BOTTOM;
					}

					if(this.m_textAlignement & TextAlignement.Top)
					{
						this.m_textPosition.y = 0;
						this.m_nvgTextAlignement += NVGalign.NVG_ALIGN_TOP;
					}

					/**
					 * Horizontal alignement
					 */
					if(this.m_textAlignement & TextAlignement.Middle)
					{
						this.m_textPosition.x = this.m_size.halfWidth;
						this.m_nvgTextAlignement += NVGalign.NVG_ALIGN_MIDDLE;
					}

					if(this.m_textAlignement & TextAlignement.Left)
					{
						this.m_textPosition.x = 0;
						this.m_nvgTextAlignement += NVGalign.NVG_ALIGN_LEFT;
					}

					if(this.m_textAlignement & TextAlignement.Right)
					{
						this.m_textPosition.x = this.m_size.width;
						this.m_nvgTextAlignement += NVGalign.NVG_ALIGN_RIGHT;
					}
				}
				else
				{
					/*wstring realText;

					int i, j;

					// We try to cut the text in multiple lines
					if(this.m_theme.font.getTextWidth(value) > this.m_size.width - this.m_position.x)
					{
						while(j < value.length)
						{
							j++;

							if(this.m_theme.font.getTextWidth(value[i..j]) >= (this.m_size.width - this.m_position.x - 3))
							{
								realText = realText ~ value[i..j] ~ '\n';
								i = j;
							}
						}

						realText ~= value[i..j];
					}
					else realText = value;

					this.m_text = realText;*/
				}
			}
		}

		public void color(in Color value) nothrow @nogc
		{
			this.m_color = value;
			this.m_useThemeColor = false;
		}

		public void textAlignement(in TextAlignement value) nothrow  @nogc
		{
			this.m_textAlignement = value;
		}
	}
}