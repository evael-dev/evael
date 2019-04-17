module evael.graphics.gui.controls.ListBox;

import std.math : round;
import std.conv;

import evael.graphics.gui.controls.Container;
import evael.graphics.gui.controls.ScrollBar;
import evael.graphics.gui.controls.Button;
import evael.graphics.Font;

import evael.utils.Math;

import evael.utils.Size;
import evael.utils.Rectangle;

class ListBox : Container, IScrollable
{
	enum Type
	{
		List,
		Columns,
		Tile
	}

	/// Column size
	private Size!int m_columnSize;

	/// Item size
	private Size!int m_itemSize;

	/// Position for the next column
	private vec2 m_nextColumnPosition;

	/// Position for the next item
	private vec2 m_nextItemPosition;

	/// Current selected item
	private Control m_selectedItem;

	/// Clickable columns
	private Button[] m_columns;

	/// Sub item index counter
	private ushort m_currentSubItemIndex;

	/// ListBox type
	private Type m_type;

	private uint m_currentIndex;
	
	protected alias OnItemSelected = void delegate(ListBoxItem item);
	protected OnItemSelected m_onItemSelectedEvent;

	public this(in Type type, in float x, in float y, in int width, in int height)
	{
		this(type, vec2(x, y,), Size!int(width, height));
	}

	public this(in Type type, in vec2 position, in Size!int size)
	{
		super(position, size);
		
		this.m_name = "listBox";
		this.m_itemSize = Size!int(this.m_size.width - 2, 20);
		this.m_nextItemPosition = vec2(1.0f, 1.0f);

		this.m_verticalScrollBar = new ScrollBar(0, 0, 20, this.m_size.height);
		this.m_verticalScrollBar.hide();

		this.type = type;

		this.addChild(this.m_verticalScrollBar);
	}

	/**
	 * Renders the listbox
	 */
	public override void draw(in float deltaTime)
	{
		if(!this.m_isVisible)
		{
			return;
		}
		
		Control.draw(deltaTime);

		for(int i = 1; i < this.m_controls.length; i++)
		{
			this.m_controls[i].draw(deltaTime);
		}

		// this.m_verticalScrollBar.draw(deltaTime);
	}
	
	/**
	 * Adds item
	 * Params:
	 *		 itemText : item text
	 *		 itemId : item identifier
	 */
	public ListBox addItem(in string itemText, in uint itemId = 0)
	{
		return this.addItem(to!wstring(itemText), itemId);
	}

	public ListBox addItem(in wstring itemText, in uint itemId = 0)
	{
		int width = this.m_size.width;

		if(this.m_type == Type.Columns)
		{
			width = this.m_columns[0].size.width;
		}

		auto item = new ListBoxItem(this.m_currentIndex++, itemText, this.m_nextItemPosition, Size!int(width - 2, this.m_itemSize.height));

		if(itemId != 0)
		{
			item.id = itemId;
		}

		this.addChild(item);

		this.m_nextItemPosition = vec2(this.m_nextItemPosition.x, this.m_nextItemPosition.y + this.m_itemSize.height);

		immutable uint itemsHeight = this.m_itemSize.height * this.m_controls.length / (this.m_columns.length + 1);

		if(itemsHeight > this.m_size.height)
		{
			this.m_verticalScrollBar.computeIncrementation(this.m_size.height, itemsHeight);

			// We check if guihandler already initialized controls, if not we wait him to do it
			// otherwise it means a new item is added at runtime
			if(this.m_initialized)
			{
				this.m_verticalScrollBar.middleButton.initialize();
			}

			this.m_verticalScrollBar.show();
		}

		// We prepare next sub item index
		this.m_currentSubItemIndex = 1;

		return this;
	}

	/**
	 * Adds text sub item
	 */
	public ListBox addSubItem(in wstring itemText)
	{
		assert(this.m_currentSubItemIndex < this.m_columns.length);
		assert(this.m_currentSubItemIndex > 0);

		int totalColumnsWidth = 0;

		foreach(columnIndex; 0..this.m_currentSubItemIndex)
			totalColumnsWidth += this.m_columns[columnIndex].size.width;

		auto subitem = new ListBoxItem(this.m_currentIndex++, itemText, vec2(totalColumnsWidth + this.m_currentSubItemIndex, this.m_nextItemPosition.y + this.m_itemSize.height), 
									   Size!int(this.m_columns[this.m_currentSubItemIndex].size.width - 2, this.m_itemSize.height));
		this.addChild(subitem);

		this.m_currentSubItemIndex++;

		return this;
	}


	/**
	 * Adds control sub item
	 */
	public ListBox addSubItem(Control control)
	{
		assert(this.m_currentSubItemIndex < this.m_columns.length);
		assert(this.m_currentSubItemIndex > 0);

		int totalColumnsWidth = 0;

		foreach(columnIndex; 0..this.m_currentSubItemIndex)
			totalColumnsWidth += this.m_columns[columnIndex].size.width;

		auto subitem = new ListBoxItem(this.m_currentIndex++, "", vec2(totalColumnsWidth + this.m_currentSubItemIndex, this.m_nextItemPosition.y + this.m_itemSize.height), 
									   Size!int(this.m_columns[this.m_currentSubItemIndex].size.width - 2, this.m_itemSize.height));

		subitem.addChild(control);

		this.addChild(subitem);

		this.m_currentSubItemIndex++;

		return this;
	}

	public ListBox addSubItem(Control[] controls)
	{
		assert(this.m_currentSubItemIndex < this.m_columns.length);
		assert(this.m_currentSubItemIndex > 0);

		int totalColumnsWidth = 0;

		foreach(columnIndex; 0..this.m_currentSubItemIndex)
			totalColumnsWidth += this.m_columns[columnIndex].size.width;

		auto subitem = new ListBoxItem(this.m_currentIndex++, "", vec2(totalColumnsWidth + this.m_currentSubItemIndex, this.m_nextItemPosition.y + this.m_itemSize.height), 
									   Size!int(this.m_columns[this.m_currentSubItemIndex].size.width - 2, this.m_itemSize.height));

		this.m_currentSubItemIndex++;

		float x = 0.0f;

		foreach(i, control; controls)
		{
			control.position = vec2(x, 0.0f);
			x += control.size.width + 3;

			subitem.addChild(control);
		}

		this.addChild(subitem);

		return this;
	}

	/**
	 * Adds column
	 * Params:
	 *		columntText : column title
	 *		width : column width
	 */
	public void addColumn(in wstring columnText, in int width)
	{
		auto columnButton = new Button(columnText, this.m_nextColumnPosition.x, this.m_nextColumnPosition.y, width - 2, this.m_columnSize.height);

		this.m_columns ~= columnButton;

		this.m_nextColumnPosition = vec2(this.m_nextColumnPosition.x + width, this.m_nextColumnPosition.y);

		this.addChild(columnButton);
	}

	/**
	 * Returns item by index
	 * Params:
	 *		index : item index
	 */
	public ListBoxItem getItem(in uint index)
	{
		// 1 tooltip + 1 scrollbar + columns 		
		immutable realIndex = 2 + (this.m_columns.length * (index + 1));

		assert(realIndex < this.m_controls.length, "Invalid index");
		
		return cast(ListBoxItem)this.m_controls[realIndex];
	}

 	/**
	 * Returns items by row index
	 * Params:
	 *		index : item index
	 */
	public ListBoxItem[] getItems(in uint index)
	{
		immutable uint itemIndex = 2 + (this.m_columns.length * (index + 1));

		return cast(ListBoxItem[])this.m_controls[itemIndex..itemIndex + this.m_columns.length];
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

		if(this.m_focusedControl !is null && this.m_focusedControl != this.m_selectedItem)
		{
			// Unfocus last selected item
			if(this.m_selectedItem !is null)
			{
				this.m_selectedItem.onMouseLeave();
			}

			this.m_selectedItem = this.m_focusedControl;

			if(this.m_onItemSelectedEvent !is null)
			{
				this.m_onItemSelectedEvent(cast(ListBoxItem)this.m_selectedItem);
			}
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
	}

	/**
	 * Event called when mouse enters in control's rect
	 * Params:
	 * 		 mousePosition : mouse position
	 */
	public override void onMouseMove(in ref vec2 mousePosition)
	{
		this.m_hasFocus = true;

		foreach(childControl; this.m_controls)
		{
			Rectangle!float rect = Rectangle!float(childControl.realPosition.x, childControl.realPosition.y, childControl.size);

			if(rect.isIn(mousePosition))
			{
				childControl.onMouseMove(mousePosition);

				// We focus this child control but first we unfocus the last one
				if(this.m_focusedControl !is null && this.m_focusedControl != childControl)
				{
					if(this.m_selectedItem != this.m_focusedControl)
						this.m_focusedControl.onMouseLeave();
				}

				this.m_focusedControl = childControl;
				return;
			}
		}

		// When mouse is moving in listbox but not in the items, this condition is checked.
		// We unfocus focused item only if its not the selected one
		if(this.m_focusedControl !is null && this.m_focusedControl.isEnabled && this.m_focusedControl != this.m_selectedItem)
		{
			this.m_focusedControl.onMouseLeave();

			if(this.m_focusedControl.isClicked == false)
				this.m_focusedControl = null;
		}
	}

	/**
	 * Event called when mouse leaves control's rect
	 */
	public override void onMouseLeave()
	{
		Control.onMouseLeave();

		// When mouse is leaving listbox's rect
		// We unfocus focused item only if its not the selected one
		if(this.m_focusedControl !is null && this.m_focusedControl.isEnabled && this.m_focusedControl != this.m_selectedItem)
		{
			this.m_focusedControl.onMouseLeave();
		}

		this.switchState!(State.Normal);
	}

	public void onScroll(ScrollBar.ScrollDirection direction, in float scrollBarPosition)
	{
		final switch(direction)
		{
			case ScrollBar.ScrollDirection.Bottom:
			case ScrollBar.ScrollDirection.Top:

				foreach(control; this.m_controls[1..$])
				{
					control.realPosition = vec2(this.m_realPosition.x + control.position.x, this.m_realPosition.y + control.position.y + scrollBarPosition);
				}

				break;

			case ScrollBar.ScrollDirection.Left:
				break;

			case ScrollBar.ScrollDirection.Right:
				break;
		}
	}

	public override void initialize()
	{
		super.initialize();
	}

	/**
	 * Properties
	 */
	@property
	{
		public Control selectedItem() nothrow @nogc
		{
			return this.m_selectedItem;
		}

		public int selectedIndex() const nothrow @nogc
		{
			if(this.m_selectedItem !is null)
			{
				return (cast(ListBoxItem)this.m_selectedItem).index;
			}

			return -1;
		}

		private void type(in Type value) nothrow @nogc
		{
			this.m_type = value;

			if(this.m_type == Type.Columns)
			{
				this.m_columnSize = Size!int(this.m_size.width - 2, 20);
				
				// 1.0f = Border pixel
				this.m_nextColumnPosition = vec2(1.0f, 1.0f);
				this.m_nextItemPosition = vec2(1.0f, 21.0f);
			}
		}

		public void onItemSelectedEvent(OnItemSelected callback) nothrow @nogc
		{
			this.m_onItemSelectedEvent = callback;
		}
	}
}

class ListBoxItem : Container
{
	/// Item text
	private wstring m_text;

	/// Item text position
	private vec2 m_textPosition;

	/// Item index
	private uint m_index;

	public this(in uint index,in  wstring text, in vec2 position, in Size!int size)
	{
		this(index, text, position, size);
	}

	public this(in uint index, in wstring text, in ref vec2 position, in ref Size!int size)
	{
		super(position, size);

		this.m_name = "listBoxItem";
		this.m_index = index;
		this.m_text = text;
	}

	/**
	 * Renders the item
	 */
	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);

		if(this.m_text.length)
		{
			this.m_theme.font.draw(this.m_text, vec2(this.m_realPosition.x + 2, this.m_realPosition.y), this.m_theme.fontColor, this.m_theme.fontSize);
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
	 * Event called when mouse leaves control's rect
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
	{
		public uint index() const nothrow @nogc
		{
			return this.m_index;
		}

		public wstring text() const nothrow @nogc
		{
			return this.m_text;
		}

		public void text(in wstring value) nothrow @nogc
		{
			this.m_text = value;
		}

		public void text(in string value)  
		{
			this.m_text = value.to!wstring();
		}
	}
}