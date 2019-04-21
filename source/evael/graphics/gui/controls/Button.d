module evael.graphics.gui.controls.Button;

import evael.graphics.gui.controls.Control;
import evael.graphics.Font;

import evael.utils.math;

import evael.utils.Size;

class Button : Control
{
	public enum Type
	{
		Text = (1u << 0),
		Icon = (1u << 1)
	}

	/// Button text
	private wstring m_text;

	/// Text position
	private vec2 m_textPosition;

	/// Icon position
	private vec2 m_iconPosition;

	/// Button type
	private Type m_type;

	/// Button icon
	private Icon m_icon;

	public this(in float x, in float y, in int width = 0, in int height = 0)
	{
		this("", x, y, width, height);
	}
	
	public this(in wstring text, in float x = 0, in float y = 0, in int width = 0, in int height = 0)
	{
		this(text, vec2(x, y), Size!int(width, height));
	}

	public this(in wstring text, in vec2 position)
	{
		this(text, position, Size!int(0, 0));
	}

	public this(in wstring text, in vec2 position, in Size!int size)
	{
		super(position, size);

		this.m_name = "button";
		this.m_text = text;
		this.m_textPosition = vec2(0.0f, 0.0f);
		this.m_iconPosition = this.m_textPosition;
		this.m_type = Type.Text;
	}

	/**
	 * Renders the button
	 */
	public override void draw(in float deltaTime)
	{
		if(!this.m_isVisible)
			return;

		super.draw(deltaTime);

		if(this.m_type & Type.Text)
		{
			this.m_theme.font.draw(this.m_text, vec2(this.m_realPosition.x, this.m_realPosition.y) + this.m_textPosition, 
				this.m_theme.fontColor, this.m_theme.fontSize, this.m_theme.drawTextShadow);
		}

		if(this.m_type & Type.Icon)
		{
			this.m_theme.iconFont.draw(cpToUtf(this.m_icon), vec2(this.m_realPosition.x, this.m_realPosition.y) + this.m_iconPosition, 
				this.m_theme.fontColor, this.m_theme.fontSize);
		}
	}

	/**
	 * Event called on mouse button click
	 * Params:
	 *		mouseButton : mouse button	 
	 *		mousePosition : mouse position
	 */
	public override void onMouseClick(in MouseButton mouseButton, in ref vec2 mousePosition)
	{
		super.onMouseClick(mouseButton, mousePosition);

		if(this.m_isEnabled)
		{
			this.switchState!(State.Clicked);
		}
	}

	/**
	 * Event called on mouse button release
	 * Params:
	 *		mouseButton : mouse button
	 */
	public override void onMouseUp(in MouseButton mouseButton)
	{
		super.onMouseUp(mouseButton);

		if(this.m_isEnabled)
		{
			this.switchState!(State.Hovered);
		}
	}

	/**
	 * Event called when mouse enters in control's rect
	 * Params:
	 * 		 mousePosition : mouse position
	 */
	public override void onMouseMove(in ref vec2 mousePosition)
	{
		super.onMouseMove(mousePosition);

		if(this.m_isEnabled)
		{
			if(this.isClicked)
			{
				this.switchState!(State.Clicked);
			}
			else
			{
				this.switchState!(State.Hovered);
			}
		}
	}

	/**
	 * Event called when mouse leaves control's rect
	 */
	public override void onMouseLeave()
	{
		super.onMouseLeave();

		if(this.m_isEnabled)
		{
			this.switchState!(State.Normal);
		}
	}

	/**
	 * Initializes control
	 */
	public override void initialize()
	{
		float width = 0.0f, height = 0.0f;

		if(this.m_type & Type.Text && this.m_text.length)
		{
			immutable bounds = this.m_theme.font.getTextBounds(this.m_text, 0, this.m_theme.fontSize);

			width = bounds[2] - bounds[0];
			height = bounds[3] - bounds[1];
		}

		if (this.m_type & Type.Icon)
		{
			immutable bounds = this.m_theme.iconFont.getTextBounds(cpToUtf(this.m_icon), 0, this.m_theme.fontSize);

			width += bounds[2] - bounds[0];
			
			// We don't need to add heights together, we just take the highest value
			immutable iconHeight = bounds[3] - bounds[1];

			if(iconHeight > height)
			{
				height = iconHeight;
			}
		}

		if(width > this.m_size.width)
		{
			this.m_size.width = cast(int)width + 10;
		}

		if(height > this.m_size.height)
		{
			this.m_size.height = cast(int)height + 5;
		}

		import std.math : round;
		
		this.m_textPosition.x = round(this.m_size.halfWidth - (width / 2));
		this.m_textPosition.y = round(this.m_size.halfHeight - (height / 2));

		this.m_iconPosition = this.m_textPosition;
		
		super.initialize();
	}

	@property
	{
		public void type(in Type value) nothrow @nogc
		{
			this.m_type = value;
		}

		public void icon(in Icon value) nothrow @nogc
		{
			this.m_icon = value;
		}
	}


}