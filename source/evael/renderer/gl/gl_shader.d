module evael.renderer.gl.gl_shader;

import evael.renderer.shader;

class GLShader : Shader
{
    private uint m_programId;
    private uint m_vertexShaderId;
    private uint m_fragmentShaderId;

    /**
     * GLShader constructor.
     */
    @nogc
    public this(in uint programId, in uint vertexShaderId, in uint fragmentShaderId)
    {
        super();

        this.m_programId = programId;
        this.m_vertexShaderId = vertexShaderId;
        this.m_fragmentShaderId = fragmentShaderId;
    }

    @nogc
    @property nothrow
    {
        public uint programId() const
        {
            return this.m_programId;
        }
    }
}

