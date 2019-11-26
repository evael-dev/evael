module evael.renderer.shader;

import evael.renderer.enums.shader_type;
import evael.renderer.enums.attribute_type;
import evael.lib.memory;

public import std.typecons : Flag, Yes, No;

abstract class Shader : NoGCClass
{
    /**
     * Shader constructor.
     */
    @nogc
    public this()
    {
    }
}

struct ShaderAttribute
{
	public int layoutIndex;
	public AttributeType type;
	public int size;
	public Flag!"normalized" normalized;
}