module evael.graphics.gui.controls.Tooltip;

import std.math : round;

import evael.graphics.gui.controls.Control;
import evael.graphics.gui.controls.TextBlock;

import evael.utils.Math;

import evael.utils.Size;
import evael.utils.Color;

/**
 * Tooltip.
 * Can't be a Container because Container have a tooltip member, so we handle textblock manually.
 */
class Tooltip : Control
{
	/// Tooltip text
	private TextBlock m_textBlock;

	public this()(in auto ref vec2 position)
	{
		super(position, Size!int(0, 0));

		this.m_name = "tooltip";		
	}

	public this(in float x = 0, in float y = 0)
	{
		this(vec2(x, y));

		this.m_textBlock = new TextBlock();
		this.m_textBlock.dock = Control.Dock.Fill;
		this.m_textBlock.color = Color.White;
	}

	public override void draw(in float deltaTime)
	{
		if (!this.m_isVisible || this.m_textBlock.text is null)
			return;

		this.m_textBlock.draw(deltaTime);
		
	}

	public override void initialize()
	{		
		this.m_textBlock.nvg = this.m_nvg;
		
		// Theme
		if(this.m_name in this.m_theme.subThemes)
		{
			this.m_textBlock.theme = this.m_theme.subThemes[this.m_name];
		}
		else
		{
			this.m_textBlock.theme = this.m_theme;
		}

		this.m_textBlock.initialize();

		super.initialize();
	}

	@property
	{
		public wstring text() const
		{
			return this.m_textBlock.text;
		}

		public void text(in wstring text)
		{
			this.m_textBlock.text = text;
		}

		public override void realPosition(in vec2 value)
		{
			// We do this because we need to calculate viewport rect in Control class
			super.realPosition = value;

			this.m_textBlock.realPosition = this.m_realPosition + this.m_textBlock.position;
		}
	}
}