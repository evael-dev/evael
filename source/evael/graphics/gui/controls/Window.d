module evael.graphics.gui.controls.Window;

import evael.graphics.gui.controls.Container;

import evael.utils.Math;
import evael.utils.Size;

/**
 *
 */
class Window : Container
{
	/// Display title bar ?
	protected bool m_titleBar;

	/// Display close button ?
	protected bool m_closeButton;

	public this(in float x, in float y, in int width, in int height)
	{
		this(vec2(x, y,), Size!int(width, height));
	}

	public this()(in auto ref vec2 position, in auto ref Size!int size)
	{
		super(position, size);

		this.m_closeButton = true;
		this.m_titleBar = false;
	}

	/**
	 * Event called when mouse enters the control.
	 * Params:
	 *		position : mouse position
	 */
	public override void onMouseMove(in ref vec2 position)
	{	
		super.onMouseMove(position);

		// We draw the control that is under the mouse at the end
		if (this.m_controlUnderMouse !is null)
		{
			import std.algorithm : sort;

			this.m_controls.sort!((a, b) => a.zIndex < b.zIndex);

			//this.m_controls.sort!((a, b) => b == this.m_controlUnderMouse);
		}
	}

	public override void initialize()
	{
		if (this.m_titleBar)
		{
			import evael.graphics.gui.controls.Panel;
			import evael.graphics.gui.controls.Button;

			// Title panel
			auto panel = new Panel(0, 0, this.m_size.width - 4, 25);
			panel.dock = Control.Dock.Top;
			
			if(this.m_closeButton)
			{
				auto closeButton = new Button(-5, 2 , 20, 20);
				closeButton.type = Button.Type.Icon;
				closeButton.dock = Control.Dock.Right;
				closeButton.icon = Icon.Cross;
				closeButton.onClickEvent = (sender) { this.hide(); };

				panel.addChild(closeButton);
			}

			this.addChild(panel);
		}

		super.initialize();
	}

	@nogc 
	@property nothrow
	{
		public void titleBar(in bool value)
		{
			this.m_titleBar = value;
		}

		public void closeButton(in bool value)
		{
			this.m_closeButton = value;
		}
	}
}
