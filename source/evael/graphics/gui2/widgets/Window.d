module evael.graphics.gui2.widgets.window;

import evael.graphics.gui2.widgets.widget;

import evael.utils.rectangle;

/**
 * Window flags.
 */
enum WindowFlags
{
	Title = nk_panel_flags.NK_WINDOW_TITLE,
	Resizable = nk_panel_flags.NK_WINDOW_SCALABLE,
	Movable = nk_panel_flags.NK_WINDOW_MOVABLE,
	Minimizable = nk_panel_flags.NK_WINDOW_MINIMIZABLE,
	Border = nk_panel_flags.NK_WINDOW_BORDER,
	Background = nk_panel_flags.NK_WINDOW_BACKGROUND
}

/**
 * Window.
 */
class Window : Widget
{
	/// Window title
	private string m_title;

	/// Window flags
	private nk_flags m_flags;

	/// Widgets
	private Widget[] m_widgets;
	
	/// Window rect
	private nk_rect m_rect;

	public override void draw()
	{
		if (nk_begin(this.nuklearContext, cast(char*) this.m_title.ptr, this.m_rect, this.m_flags))
		{
			foreach (widget; this.m_widgets)
			{
				widget.draw();
			}
		}
		nk_end(this.nuklearContext);
	}

	public void add(Widget widget)
	{
		this.m_widgets ~= widget;

		widget.nuklearContext = this.nuklearContext;
	}

	@nogc
	@property nothrow
	{
		public Window title(in string value)
		{
			this.m_title = value;
			this.updateFlag(NK_WINDOW_TITLE, value.length > 0);
			return this;
		}

		public Window flags(in WindowFlags value)
		{
			this.m_flags = value;
			return this;
		}

		public Window border(in bool value = true)
		{
			this.updateFlag(WindowFlags.Background, value);
			return this;
		}

		public Window minimizable(in bool value = true)
		{
			this.updateFlag(WindowFlags.Minimizable, value);
			return this;
		}

		public Window movable(in bool value = true)
		{
			this.updateFlag(WindowFlags.Movable, value);
			return this;
		}

		public Window resizable(in bool value = true)
		{
			this.updateFlag(WindowFlags.Resizable, value);
			return this;
		}

		public Window rect(in Rectangle!float value)
		{
			this.m_rect = nk_rect(value.left, value.bottom, value.size.width, value.size.height);
			return this;
		}
	}

	@nogc
	public void updateFlag(in nk_flags flag, in bool value) nothrow
	{
		this.m_flags = (value ? (this.m_flags | flag) : (this.m_flags & ~flag));
	}
}