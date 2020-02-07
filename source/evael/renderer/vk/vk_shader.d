module evael.renderer.vk.vk_shader;

import evael.renderer.vk.vk_wrapper;
import evael.renderer.vk.vk_enum_converter;
import evael.renderer.shader;
import evael.renderer.enums.shader_type;

import evael.lib.memory;

public
{
    import evael.renderer.shader : ShaderAttribute;
}

class VulkanShader : Shader
{
    /**
     * GLShader constructor.
     */
    @nogc
    public this(in uint programId, in uint vertexShaderId, in uint fragmentShaderId)
    {
        super();

    }

    /**
     * GLShader destructor.
     */
    @nogc
    public ~this()
    {
        this.dispose();
    }

    // TODO: remove this when IAsset is cleaned.
    @nogc
    public void dispose()
    {

    }

    /**
     * Loads a shader from file.
     * Params:
     *		fileName : shader to load
     */
    public static VulkanShader load(in string fileName)
    {
        import std.file : readText;

        return VulkanShader.load(readText(fileName ~ ".vert"), readText(fileName ~ ".frag"));
    }


    /**
     * Loads a shader from source.
     * Params:
     *		vs : vertex shader
     *		fs : fragment shader
     */
    public static VulkanShader load(in string vs, in string fs)
    {
        immutable uint programId = 0;
        immutable uint vertexShaderId = 0;
        immutable uint fragmentShaderId = 0;

        auto shader = MemoryHelper.create!VulkanShader(programId, vertexShaderId, fragmentShaderId);

        return shader;
    }

    /**
     * Compiles a shader from a source.
     * Params:
     *		type : shader type
     */
    private static uint compileShader(in string sourceCode, in ShaderType type)
    {
        return 0;
    }

    @nogc
    @property nothrow
    {

    }
}

