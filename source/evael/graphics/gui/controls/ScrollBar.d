module evael.graphics.gui.controls.ScrollBar;

import std.math;

import evael.graphics.gui.controls.Container;
import evael.graphics.gui.controls.Button;

import evael.utils.math;
import evael.utils.Size;
import evael.utils.Color;


interface IScrollable
{
	public void onScroll(ScrollBar.ScrollDirection direction, in float scrollBarPosition);
}

class ScrollBar : Container
{
	public enum ScrollDirection
	{
		Top,
		Bottom,
		Right,
		Left
	}

	public enum Alignement
	{
		Vertical,
		Horizontal
	}

	private float m_scrollIncrementation;
	private uint m_invisibleItemsHeight;

	private Button m_scrollButton;
	private Button m_scrollBottomButton;
	private Button m_scrollTopButton;

	public this(const float x, const float y, const int width, const int height)
	{
		this(vec2(x, y), Size!int(width, height));

		this.m_scrollIncrementation = 0.0f;
	}

	public this(const(vec2) position, const(Size!int) size)
	{
		super(position, size);

		this.m_name = "scrollBar";
		this.m_dock = Dock.Right;

		this.m_scrollIncrementation = 0.0f;

		this.m_scrollTopButton = new Button(0, 0, size.width, 20);
		this.m_scrollTopButton.dock = Dock.Top;
		this.m_scrollTopButton.type = Button.Type.Icon;
		this.m_scrollTopButton.icon = Icon.UpDir;

		this.m_scrollBottomButton = new Button(0, 0, size.width, 20);
		this.m_scrollBottomButton.dock = Dock.Bottom;
		this.m_scrollBottomButton.type = Button.Type.Icon;
		this.m_scrollBottomButton.icon = Icon.DownDir;

		this.m_scrollButton = new Button(0, 20, size.width, 20);

		this.addChild(this.m_scrollTopButton);
		this.addChild(this.m_scrollBottomButton);
		this.addChild(this.m_scrollButton);
	}

	/**
	 * Renders the scrollbar
	 */
	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);
	}

	/**
	 * Computes scrollbar's incrementation
	 * Params:
	 *		 controlHeight : scrollbar's parent control height
	 *		 itemsHeight : total height of scrollable items in parent control
	 */
	public void computeIncrementation(in uint controlHeight, in uint itemsHeight)
	{
		if(itemsHeight <= controlHeight)
		{
			this.m_scrollButton.hide();
			return;
		}

		this.m_scrollButton.show();

		this.m_invisibleItemsHeight = itemsHeight - controlHeight;

		if(this.m_invisibleItemsHeight > controlHeight)
		{
			// This is the formula.
			this.m_scrollIncrementation = cast(float)m_invisibleItemsHeight / (controlHeight - 10);

			this.m_scrollTopButton.onClickEvent = (sender) => (cast(IScrollable)this.m_parent).onScroll(ScrollDirection.Top, this.m_scrollIncrementation);
			this.m_scrollBottomButton.onClickEvent = (sender) => (cast(IScrollable)this.m_parent).onScroll(ScrollDirection.Bottom, -this.m_scrollIncrementation);
		}
		else 
		{
			// Scrolling is easy we don't need top and bottom buttons
			this.m_scrollBottomButton.hide();
			this.m_scrollTopButton.hide();

			
			this.m_scrollButton.size = Size!int(20, controlHeight - this.m_invisibleItemsHeight);
			this.m_scrollButton.position = vec2(0, 0);

		}
	}

	public override void initialize()
	{
		super.initialize();
	}


	/**
	 * Event called when mouse enters in control's rect
	 * Params:
	 * 		 mousePosition : mouse position
	 */
	public override void onMouseMove(in ref vec2 mousePosition)
	{	
		super.onMouseMove(mousePosition);

		static vec2 lastMousePosition;

		scope(exit)
		{
			lastMousePosition =	mousePosition;
		}

		if(this.m_scrollButton.isClicked && mousePosition.y != lastMousePosition.y)
		{
			vec2 buttonPosition = this.m_scrollButton.realPosition;

			immutable mouseDifference = (mousePosition.y - lastMousePosition.y);

			// Scroll top
			if(mousePosition.y > lastMousePosition.y)
			{
				// If we scroll over the limit, we go back
				if(this.m_scrollButton.realPosition.y + this.m_scrollButton.size.height + mouseDifference >= this.m_realPosition.y + this.m_size.height)
				{

					buttonPosition.y = this.m_realPosition.y + this.m_invisibleItemsHeight;
					this.m_scrollButton.realPosition = buttonPosition;

					(cast(IScrollable)this.m_parent).onScroll(ScrollDirection.Top, this.m_parent.realPosition.y - this.m_scrollButton.realPosition.y); 

					return;
				}

			}
			else
			{
				if(this.m_scrollButton.realPosition.y <= this.m_realPosition.y)
				{
					buttonPosition.y = this.m_realPosition.y;
					this.m_scrollButton.realPosition = buttonPosition;

					return;
				}
			}

			// Scrolling is between the limits
			buttonPosition.y = buttonPosition.y + mouseDifference;
			this.m_scrollButton.realPosition = buttonPosition;

			(cast(IScrollable)this.m_parent).onScroll(ScrollDirection.Top, this.m_parent.realPosition.y - this.m_scrollButton.realPosition.y); 
		}
	}

	/**
	 * Event called when mouse leaves control's rect
	 */
	public override void onMouseLeave()
	{
		if(this.m_scrollButton.isClicked)
		{
			this.m_scrollButton.onMouseUp(MouseButton.Left);
		}
	}

	@property
	public float incrementation() const
	{
		return this.m_scrollIncrementation;
	}

	@property
	public void incrementation(float value)
	{
		this.m_scrollIncrementation = value;
	}

	@property
	public Button middleButton()
	{
		return this.m_scrollButton;
	}

}
