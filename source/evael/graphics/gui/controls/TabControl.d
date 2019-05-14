module evael.graphics.gui.controls.TabControl;

import evael.graphics.gui.controls.Container;
import evael.graphics.gui.controls.Button;

import evael.utils.Math;

import evael.utils.Size;
import evael.utils.Color;

class TabControl : Container
{
	private TabPage[] m_tabs;

	private TabPage m_currentTab;

	private float m_currentTabPosition;

	public this(in float x, in float y, in int width = 0, in int height = 0)
	{
		this(vec2(x, y), Size!int(width, height));
	}

	public this(in vec2 position, in Size!int size)
	{
		super(position, size);

		this.m_currentTabPosition = 0.0f;
	}

	public override void draw(in float deltaTime)
	{
		//super.drawWithoutChildren(deltaTime);

		foreach(control; this.m_controls)
		{
			control.draw(deltaTime);
		}
	}

	public void addTab(TabPage tab)
	{
		if(this.m_currentTab is null)
		{
			this.m_currentTab = tab;
		}
		else tab.hide();

		// We update tabpage size
		tab.size = Size!int(this.m_size.width, this.m_size.height - 30);

		auto button = new Button(tab.displayName, this.m_currentTabPosition, this.m_size.height - 30);
		// button.borderColor = Color.DarkGrey;

		button.onClickEvent = (sender) 
		{ 
			// We hide last page
			if(this.m_currentTab != tab)
			{
				this.m_currentTab.hide(); 
				tab.show();
				this.m_currentTab = tab;

				// button.borderColor = Color.Black;
			}
		};

		this.addChild(tab);
		this.addChild(button);

//		this.m_currentTabPosition += this.m_font.getTextWidth(tab.name) + 20;

		this.m_tabs ~= tab;
	}
}

class TabPage : Container
{
	private wstring m_displayName;

	public this(in wstring name)
	{
		super(vec2(0, 0), Size!int(0, 0));

		this.m_displayName = name;
	}

	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);
	}

	@property
	public wstring displayName() const nothrow
	{
		return this.m_displayName;
	}
}