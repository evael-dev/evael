module evael.graphics.gui2.widgets.property;

import evael.graphics.gui2.widgets.widget;

bool isAllowedType(T)()
{
    return is(T == int) || is(T == float) || is(T == double);
}

class Property(T) if(isAllowedType!T()) : Widget
{
    template NuklearPropertyFunction(string params)
    {
        enum NuklearPropertyFunction = "nk_property_" ~ T.stringof ~ "(" ~ params ~ ");";
    }

	private alias OnChangeEvent = void delegate(in T value);
	private OnChangeEvent m_onChangeEvent;

	private string m_text;

	private T m_value;
    private T m_min;
    private T m_max;
    private T m_step;

    @nogc
    public this() nothrow
    {
        super();
        this.m_value = T.init;
    }

	public override void draw()
	{
		this.applyLayout();

        mixin(NuklearPropertyFunction!(
			q{this.nuklearContext, cast(char*) this.m_text.ptr, this.m_min, &this.m_value, this.m_max, this.m_step, 1}
		));

        static T lastValue;

        if (this.m_value != lastValue && this.m_onChangeEvent !is null)
        {
            lastValue = this.m_value;
            this.m_onChangeEvent(this.m_value);
        }
	}

	@nogc
	@property nothrow
	{
        public Property!T text(in string value)
        {
            this.m_text = value;
            return this;
        }

		public Property!T value(T value)
		{
		    this.m_value = value;
			return this;
		}

        public T value()
		{
			return this.m_value;
		}

        public Property!T min(in T value)
		{
			this.m_min = value;
			return this;
		}

        public Property!T max(in T value)
		{
			this.m_max = value;
			return this;
		}

        public Property!T step(in T value)
		{
			this.m_step = value;
			return this;
		}

        public Property!T onChange(OnChangeEvent value)
		{
			this.m_onChangeEvent = value;
			return this;
		}
	}
}