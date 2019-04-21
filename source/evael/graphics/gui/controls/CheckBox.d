module evael.graphics.gui.controls.CheckBox;

import evael.graphics.gui.controls.Control;

import evael.utils.math;

import evael.utils.Size;
import evael.utils.Color;

class CheckBox : Control
{
	private bool m_checked;

	/// Check rect color
	private Color m_color;

	private wstring m_text;

	private vec2 m_textPosition;

	public this(in wstring text, in float x, in float y, in int width = 13, in int height = 13)
	{
		this(text, vec2(x, y), Size!int(width, height));
	}

	public this(in wstring text, in vec2 position, in Size!int size)
	{
		super(position, size);

		this.m_name = "checkBox";
		this.m_checked = false;
		this.m_color = Color.Black;
		this.m_text = text;
	}

	public override void draw(in float deltaTime)
	{
		if(!this.m_isVisible)
			return;
	}

	/**
	 * Event called on mouse button release
	 * Params:
	 *		mouseButton : mouse button
	 */
	public override void onMouseUp(in MouseButton mouseButton)
	{
		super.onMouseUp(mouseButton);
		this.switchState!(State.Hovered);

		this.m_checked = !this.m_checked;
	}

	/**
	 * Event called when mouse enters in control's rect
	 * Params:
	 * 		 mousePosition : mouse position
	 */
	public override void onMouseMove(in ref vec2 mousePosition)
	{
		super.onMouseMove(mousePosition);

		if(this.isClicked)
		{
			this.switchState!(State.Clicked);
		}
		else
		{
			this.switchState!(State.Hovered);
		}
	}

	/**
	 * Event called when mouse leaves control's rect
	 */
	public override void onMouseLeave()
	{
		super.onMouseLeave();
		this.switchState!(State.Normal);
	}

	@property
	public bool checked() const nothrow
	{
		return this.m_checked;
	}


	@property
	public void color()(in auto ref Color value)
	{
		this.m_color = value;
	}
}