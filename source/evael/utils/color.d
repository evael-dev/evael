module evael.utils.color;

/**
 * Color.
 */
struct Color
{
    /// Color's values
    private ubyte[4] m_values;

    /// Predefined colors
    public static Color White = Color(255, 255, 255),
                        Black = Color(0, 0, 0),
                        Red = Color(255, 0, 0),
                        Blue = Color(0, 0, 255),
                        Green = Color(0, 255, 0),
                        Grey = Color(223, 223, 223),
                        LightGrey = Color(240, 240, 240),
                        DarkGrey = Color(80, 80, 80),
                        Orange = Color(252, 148, 0),
                        LightOrange = Color(255, 195, 110),
                        Transparent = Color(255, 255, 255, 0);

    /**
     * Color constructor.
     * Params:
     * 		r : r
     *		g : g
     *		b : b
     *		a : a
     */
    @nogc
    public this(in ubyte r, in ubyte g, in ubyte b, in ubyte a = 255) nothrow
    {
        this.m_values = [r, g, b, a];
    }

    /**
     * Color constructor (float).
     */
    @nogc
    public this(in float r, in float g, in float b, in float a = 1.0f) nothrow
    {
        this.m_values = [cast(ubyte) (r * 255), cast(ubyte) (g * 255), cast(ubyte) (b * 255), cast(ubyte) (a * 255)];
    }

    @nogc
    public bool opEquals()(in ref Color c) const nothrow
    {
        return this.m_values[] == c.m_values[];
    }

    @nogc
    @property nothrow
    {
        public ubyte r() const
        {
            return this.m_values[0];
        }

        public ubyte g() const
        {
            return this.m_values[1];
        }

        public ubyte b() const
        {
            return this.m_values[2];
        }

        public ubyte a() const
        {
            return this.m_values[3];
        }

        public void a(in ubyte value)
        {
            this.m_values[3] = value;
        }
        
        public float[4] asFloat() const
        {
            return [this.m_values[0] / 255.0f, this.m_values[1] / 255.0f, this.m_values[2] / 255.0f, this.m_values[3] / 255.0f];
        }
        
        public auto ptr()
        {
            return this.m_values.ptr;
        }
    }
}