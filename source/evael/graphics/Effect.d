module evael.graphics.Effect;

import evael.graphics.Drawable;
import evael.graphics.particles.ParticleEmitter;

import evael.utils.math;
import evael.utils.Size;

/**
 * Effect.
 */
class Effect : Drawable
{
	/// List of particle emitters.
	private ParticleEmitter[] m_particleEmitters;

	/**
	 * Effect constructor.
	 * Params:
	 *		position : position
	 */
	public this(in ref vec3 position)
	{
		super(position, Size!int(0, 0));
	}

	/**
	 * Renders the effect.
	 */
	public override void draw(in float deltaTime, mat4 view, mat4 projection)
	{
		if (!this.m_isVisible)
			return;

		foreach (emitter; this.m_particleEmitters)
		{
			emitter.position = this.m_position;
			emitter.draw(deltaTime, view, projection);
		}
	}

	/**
	 * Adds a new emitter to this effect.
	 * Params:
	 *		 emitter : particle emitter to add
	 */
	public void addEmitter(ParticleEmitter emitter)
	{
		this.m_particleEmitters ~= emitter;
	}
}