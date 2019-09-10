/+++module evael.physics.physics_2d.Space;

// import chipmunk;

import dlib.math;

class Space
{
	/*private cpSpace* m_space;

	mixin(ChipmunkProperty!(float, "test"));*/

	/**
	 * Space constructor.
	 */
	public this()
	{
		this.m_space = cpSpaceNew();
	}

	/**
	 * Space destructor.
	 */
	public void dispose()
	{
		assert(this.m_space !is null);
		cpSpaceFree(this.m_space);
	}

	/**
	 * Properties
	 */
	@property
	{
		public void gravity(in vec2 gravity)
		{
			cpSpaceSetGravity(this.m_space, cpv(gravity.x, gravity.y));
		}
	}
}

template ChipmunkProperty(Type, string name)
{
	public string chipmunkPropertyImpl()
	{
		return "";
	}

	enum ChipmunkProperty = chipmunkPropertyImpl;
}+++/