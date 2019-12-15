module evael.renderer.graphics_pipeline;

import evael.renderer.enums;
import evael.renderer.shader;
import evael.renderer.texture;
import evael.renderer.blend_state;

class GraphicsPipeline
{
    public uint primitiveType;

    public Shader shader;
    
    public Texture texture;
    
    public BlendState blendState;

    public this()
    {
    }
}