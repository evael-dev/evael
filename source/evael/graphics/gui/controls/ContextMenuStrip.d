module evael.graphics.gui.controls.ContextMenuStrip;

import std.conv;

import evael.graphics.gui.controls.Container;

import evael.utils.math;

import evael.utils.Size;
import evael.utils.Color;

class ContextMenuStrip : Container
{
	/// Item size
	private Size!int m_itemSize;

	/// Position for the next item
	private vec2 m_nextItemPosition;

	public this(in float x, in float y, in int width = 0)
	{
		this(vec2(x, y), Size!int(width, 0));
	}

	public this(in vec2 position, in Size!int size)
	{
		super(position, size);

		this.m_name = "contextMenuStrip";

		this.m_itemSize = Size!int(this.m_size.width, 0);

		this.m_movable = false;
	}

	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);
	}


	/**
	 * Adds item
	 * Params:
	 *		 itemText : item text
	 */
	public void addItem(in string itemText, OnClickEvent onClick)
	{
		this.addItem(itemText.to!wstring, onClick);
	}

	public void addItem(in wstring itemText, OnClickEvent onClick)
	{/*
		this.m_size.height = this.m_size.height + 20;

		// 1.0f = Border pixel
		this.m_nextItemPosition = vec2(1.0f, this.m_size.height - 19.0f);
*/
		auto item = new ContextMenuStripItem(this.m_controls.length, itemText, vec2(0), this.m_itemSize);
		item.onClickEvent = onClick;

		this.addChild(item);
	}

	/**
	 * Initializes control
	 */
	public override void initialize()
	{
		super.initialize();

		// Now that child controls have been correctly sized, we can defines ContextMenuStrip's height

		int y = 0;
		int height = 0;

		foreach(control; this.m_controls)
		{
			height += control.size.height;
			control.position = vec2(0, y);
			control.realPosition = control.position + this.m_realPosition;
			y += height;
		}

		this.m_size.height = height;
	}
}


class ContextMenuStripItem : Control
{
	/// Item text
	private wstring m_text;

	/// Item text position
	private vec2 m_textPosition;

	/// Item index
	private int m_index;

	public this(in int index, in wstring text, in vec2 position, in Size!int size)
	{
		super(position, size);

		this.m_name = "contextMenuStripItem";
		this.m_index = index;
		this.m_text = text;
	}


	/**
	 * Renders the item
	 */
	public override void draw(in float deltaTime)
	{
		if(!this.m_isVisible)
			return;

		super.draw(deltaTime);

		this.m_theme.font.draw(this.m_text, vec2(this.m_realPosition.x, this.m_realPosition.y) + this.m_textPosition, 
			this.m_theme.fontColor, this.m_theme.fontSize);
	}

	/**
	 * Initializes control
	 */
	public override void initialize()
	{
		if(this.m_text.length)
		{
			float[4] bounds = this.m_theme.font.getTextBounds(this.m_text, 0, this.m_theme.fontSize);

			immutable float w = bounds[2] - bounds[0];
			immutable float h = bounds[3] - bounds[1];

			if(w > this.m_size.width)
			{
				this.m_size.width = cast(int)w + 10;
			}

			if(h > this.m_size.height)
			{
				this.m_size.height = cast(int)h + 5;
			}

			import std.math : round;
			
			this.m_textPosition.x = 2.0f;
			this.m_textPosition.y = round(this.m_size.halfHeight - (h / 2));
		}

		super.initialize();
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
		this.switchState!(State.Clicked);
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
	}

	/**
	 * Event called when mouse enters in control's rect
	 * Params:
	 * 		 mousePosition : mouse position
	 */
	public override void onMouseMove(in ref vec2 mousePosition)
	{
		if(this.hasFocus)
		{
			return;
		}

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
	 * Event called when mouse leaves in control's rect
	 */
	public override void onMouseLeave()
	{
		super.onMouseLeave();

		this.switchState!(State.Normal);
	}

	/**
	 * Properties
	 */
	@property
	public int index() const nothrow @nogc
	{
		return this.m_index;
	}

}