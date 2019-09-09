module evael.graphics.gui.widgets.progress_bar;

import evael.graphics.gui.widgets.widget;

enum ProgressBarType
{
    Fixed = nk_modify.NK_FIXED,
    Modifiable = nk_modify.NK_MODIFIABLE
}

class ProgressBar : Widget
{
	private alias OnChangeEvent = void delegate(in size_t value);
	private OnChangeEvent m_onChangeEvent;

	private size_t m_value;
    private size_t m_max;

    private ProgressBarType m_type;

    @nogc
    public this() nothrow
    {
        super();
        this.m_value = 50;
        this.m_max = 100;
        this.m_type = ProgressBarType.Fixed;
    }

	public override void draw()
	{
		this.applyLayout();

        if (nk_progress(this.nuklearContext, &this.m_value, this.m_max, this.m_type))
        {
            if (this.m_onChangeEvent !is null)
            {
                this.m_onChangeEvent(this.m_value);
            }
        }
	}

	@nogc
	@property nothrow
	{
		public ProgressBar value(in size_t value)
		{
		    this.m_value = value;
			return this;
		}

		public ProgressBar max(in size_t value)
		{
		    this.m_max = value;
			return this;
		}

        public ProgressBar type(in ProgressBarType value)
        {
            this.m_type = value;
            return this;
        }

        public ProgressBar onChange(OnChangeEvent value)
		{
			this.m_onChangeEvent = value;
			return this;
		}
	}
}