module evael.graphics.gui.widgets.slider;

import evael.graphics.gui.widgets.widget;

class Slider : Widget
{
	private alias OnChangeEvent = void delegate(in float value);
	private OnChangeEvent m_onChangeEvent;

	private float m_value;
    private float m_min;
    private float m_max;
    private float m_step;

    @nogc
    public this() nothrow
    {
        super();
        this.m_value = 0.0f;
        this.m_min = 0.0f;
        this.m_max = 1.0f;
        this.m_step = 0.1f;
    }

	public override void draw()
	{
		this.applyLayout();

        nk_slider_float(this.nuklearContext, this.m_min, &this.m_value, this.m_max, this.m_step);

        static float lastValue;

        if (this.m_value != lastValue && this.m_onChangeEvent !is null)
        {
            lastValue = this.m_value;
            this.m_onChangeEvent(this.m_value);
        }
	}

	@nogc
	@property nothrow
	{
		public Slider value(in float value)
		{
		    this.m_value = value;
			return this;
		}

        public float value()
		{
			return this.m_value;
		}

        public Slider min(in float value)
		{
			this.m_min = value;
			return this;
		}

        public Slider max(in float value)
		{
			this.m_max = value;
			return this;
		}

        public Slider step(in float value)
		{
			this.m_step = value;
			return this;
		}

        public Slider onChange(OnChangeEvent value)
		{
			this.m_onChangeEvent = value;
			return this;
		}
	}
}