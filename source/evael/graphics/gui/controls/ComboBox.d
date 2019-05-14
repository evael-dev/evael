module evael.graphics.gui.controls.ComboBox;

import evael.graphics.gui.controls.Button;
import evael.graphics.gui.controls.ListBox;
import evael.graphics.gui.controls.TextBlock;
import evael.graphics.gui.controls.Container;

import evael.utils.Math;

import evael.utils.Size;
import evael.utils.Color;

class ComboBox : Container
{
    protected alias OnItemSelected = void delegate(ListBoxItem item);
	protected OnItemSelected m_onItemSelectedEvent;

    private ListBox m_listBox;

    /// Initial ComboBox size (when collapsed)
    private Size!int m_initialSize;

    /// Text displayed in ComboBox input
    private TextBlock m_text;

    /// Selected item
    private ListBoxItem m_selectedItem;

	public this(in vec2 position, in Size!int size, in int listHeight)
	{
		super(position, size);

        this.m_initialSize = size;
        this.m_autoResize = false;
		this.m_name = "comboBox";

        this.m_listBox = new ListBox(ListBox.Type.List, 0, size.height, size.width, listHeight);
        this.m_listBox.onItemSelectedEvent = &this.onItemSelected;
        
        this.m_listBox.hide();

        auto showListBoxButton = new Button(">");
        showListBoxButton.type = Button.Type.Icon;
        showListBoxButton.icon = Icon.DownOpenBig;
        showListBoxButton.dock = Dock.Right;
        showListBoxButton.onClickEvent = (sender) 
        {
            if(this.m_listBox.isVisible)
            {
                this.m_listBox.hide();
                this.m_size.height = size.height;
            }
            else
            {
                this.m_listBox.show();
                this.m_size.height = size.height + this.m_listBox.size.height;
            }
        };

        this.m_text = new TextBlock(5, 2, size.width - 40, size.height);
		this.m_text.textAlignement = TextBlock.TextAlignement.Left | TextBlock.TextAlignement.Top;

        this.addChild(showListBoxButton);
        this.addChild(this.m_text);
        this.addChild(this.m_listBox);
	}

	public this(in float x, in float y, in int width = 0, in int height = 0, in int listHeight = 200)
	{
		this(vec2(x, y), Size!int(width, height), listHeight);
	}

	public override void draw(in float deltaTime)
	{
		super.draw(deltaTime);
	}
    
    public override void initialize()
    {
        super.initialize();

        this.m_text.theme.background.type = Background.Type.Transparent;
    }

    /**
     * Adds item
     * Params:
     *      item : item to add
     */
    public void addItem(in string item)
    {
        this.m_listBox.addItem(item);
    }

    /**
     * Selects item by index
     * Params:
     *      index : item index in list
     */
    public void selectItem(in uint index)
    {
        this.onItemSelected(this.m_listBox.getItem(index));
    }

    /**
     * Event called when an item has been selected
     */
    private void onItemSelected(ListBoxItem item)
    {
        if(item is null)
        {
            return;
        }

        this.m_listBox.hide();
        this.m_size.height = this.m_initialSize.height;
    
        this.m_selectedItem = item;
        this.m_text.text = item.text;

        this.m_onItemSelectedEvent(item);
    }

    @property
    {
        public void onItemSelectedEvent(OnItemSelected callback) nothrow @nogc
		{
			this.m_onItemSelectedEvent = callback;
		}
    }
}