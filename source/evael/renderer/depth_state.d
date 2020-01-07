module evael.renderer.depth_state;

struct DepthState
{
	public bool enabled = false;
	public bool readOnly;

	public static DepthState Default = {
		enabled  : true,
		readOnly : false
	};
}