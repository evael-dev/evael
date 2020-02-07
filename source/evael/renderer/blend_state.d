module evael.renderer.blend_state;

import evael.renderer.enums.blend_factor;
import evael.renderer.enums.blend_function;

/** 
 * BlendState specify pixel arithmetic for RGB and alpha components separately.
 */
struct BlendState
{
    /// Specifies how the red, green, and blue blending factors are computed
    public BlendFactor sourceRGB;

    /// Specifies how the red, green, and blue destination blending factors are computed.
    public BlendFactor destinationRGB;

    /// Specifies how the alpha source blending factor is computed.
    public BlendFactor sourceAlpha;

    /// Specifies how the alpha destination blending factor is computed.
    public BlendFactor destinationAlpha;

    /// Specifies how the red, green, and blue components of the source and destination colors are combined.
    public BlendFunction colorFunction;

    /// Specifies how the alpha component of the source and destination colors are combined.
    public BlendFunction alphaFunction;

    public bool enabled = true;

    public static BlendState Default = {
        sourceRGB        : BlendFactor.SourceAlpha,
        destinationRGB   : BlendFactor.InverseSourceAlpha,
        sourceAlpha      : BlendFactor.SourceAlpha,
        destinationAlpha : BlendFactor.InverseSourceAlpha,
        colorFunction    : BlendFunction.Add,
        alphaFunction    : BlendFunction.Add,
    };
}