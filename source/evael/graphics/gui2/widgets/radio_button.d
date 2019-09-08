module evael.graphics.gui2.widgets.radio_button;

import evael.graphics.gui2.widgets.widget;

class RadioButton : Widget
{
	private alias OnSelectEvent = void delegate();
	private OnSelectEvent m_onSelectEvent;

	private bool delegate() m_condition;

	private string m_text;

    @nogc
    public this() nothrow
    {
		super();
    }

	public override void draw()
	{
		this.applyLayout();

		immutable bool condition = this.m_condition();
		if (nk_option_label(this.nuklearContext, cast(char*) this.m_text.ptr, condition))
		{
			// RadioButton has been clicked.
			// If RadioButton is not selected, we trigger a select event
			if (condition == false && this.m_onSelectEvent !is null)
			{
				this.m_onSelectEvent();
			}
		}
	}

	@nogc
	@property nothrow
	{
		public RadioButton text(in string value)
		{
			this.m_text = value;
			return this;
		}

		public RadioButton condition(bool delegate() value)
		{
			this.m_condition = value;
			return this;
		}

		public RadioButton onSelect(OnSelectEvent value)
		{
			this.m_onSelectEvent = value;
			return this;
		}
	}

	@property
	public bool isSelected()
	{
		return this.m_condition();
	}
}