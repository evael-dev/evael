module evael.graphics.gui2.widgets.Window;

import evael.graphics.gui2.widgets.Widget;
import evael.graphics.gui2.layouts.ILayout;

import evael.utils.Rectangle;

class Window : Widget
{
	public enum Flags
	{
		Title = nk_panel_flags.NK_WINDOW_TITLE,
		Resizable = nk_panel_flags.NK_WINDOW_SCALABLE,
		Movable = nk_panel_flags.NK_WINDOW_MOVABLE,
		Minimizable = nk_panel_flags.NK_WINDOW_MINIMIZABLE,
		Border = nk_panel_flags.NK_WINDOW_BORDER,
		Background = nk_panel_flags.NK_WINDOW_BACKGROUND
	}

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
		this.nuklear.prepareNewFrame();

		if (nk_begin(this.nuklear.context, cast(char*) this.m_title.ptr, this.m_rect, this.m_flags))
		{
			foreach (widget; this.m_widgets)
			{
				widget.draw();
			}
		}
		nk_end(this.nuklear.context);
	}

	public void add(Widget widget)
	{
		this.m_widgets ~= widget;

		widget.nuklear = this.nuklear;
	}

	@nogc @safe
	@property pure nothrow
	{
		public Window title(in string value)
		{
			this.m_title = value;
			this.updateFlag(NK_WINDOW_TITLE, value.length > 0);
			return this;
		}

		public Window flags(in Flags value)
		{
			this.m_flags = value;
			return this;
		}

		public Window border(in bool value = true)
		{
			this.updateFlag(Flags.Background, value);
			return this;
		}

		public Window minimizable(in bool value = true)
		{
			this.updateFlag(Flags.Minimizable, value);
			return this;
		}

		public Window movable(in bool value = true)
		{
			this.updateFlag(Flags.Movable, value);
			return this;
		}

		public Window resizable(in bool value = true)
		{
			this.updateFlag(Flags.Resizable, value);
			return this;
		}

		public Window rect(in Rectangle!float value)
		{
			this.m_rect = nk_rect(value.left, value.bottom, value.size.width, value.size.height);
			return this;
		}
	}

	@nogc @safe
	public void updateFlag(in nk_flags flag, in bool value) pure nothrow
	{
		this.m_flags = (value ? (this.m_flags | flag) : (this.m_flags & ~flag));
	}
}