module evael.graphics.particles.ParticleEmitter;

import evael.graphics.Drawable;
import evael.graphics.GraphicsDevice;
import evael.graphics.Texture;
import evael.graphics.shaders.BasicShader;
import evael.graphics.particles.Particle;

import evael.system.AssetLoader;

import evael.utils.Math;
import evael.utils.Color;

class ParticleEmitter : Drawable
{
	private BasicShader m_updateShader;

	private uint m_query;
	private uint m_transformFeedbackBuffer;
	private uint[2] m_particleBuffer;

	private uint m_currentVertexBuffer;

	private ParticleEmitterDefinition m_emitterDefinition;

	/// Elapsed time since last frame
	private float m_elapsedTime;

	/// Current particles number
	private int m_particlesNumber;

	public this(GraphicsDevice graphics, ParticleEmitterDefinition definition)
	{
		this.m_graphicsDevice = graphics;
		this.m_emitterDefinition = definition;
		this.m_texture = definition.texture;

		this.m_particlesNumber = 1;
		this.m_elapsedTime = 0.8f;

		const(char*) [6] varyings = 
		[
			"vPosition",
			"vVelocity",
			"vColor",
			"fLifeTime",
			"fSize",
			"iType"
		];

		this.m_updateShader = AssetLoader.getInstance().load!(BasicShader)("ParticleInit", false);

		gl.TransformFeedbackVaryings(this.m_updateShader.programID, 6, varyings.ptr, GL_INTERLEAVED_ATTRIBS); 

		this.m_updateShader.link();

		auto particle =  Particle(vec3(0, 10, 0), vec3(0.0f, 0.0001f, 0.0f), vec3(0, 1, 0), 0.0f, 1, 0);

		//gl.GenTransformFeedbacks(1, &this.m_transformFeedbackBuffer); 
		gl.GenQueries(1, &this.m_query); 

		for (int i = 0; i < 2 ; i++) 
		{
			this.m_particleBuffer[i] = this.m_graphicsDevice.createVertexBuffer(Particle.sizeof * definition.maxParticlesNumber, &particle, BufferUsage.DynamicDraw);		   
		}

		this.m_shader = AssetLoader.getInstance().load!(BasicShader)("Particle");
	}

	public void dispose()
	{
		this.m_graphicsDevice.deleteBuffer(this.m_particleBuffer[0]);
		this.m_graphicsDevice.deleteBuffer(this.m_particleBuffer[1]);
	}

    public override void draw(in float deltaTime, mat4 view, mat4 projection)
	{
		this.m_graphicsDevice.bindTexture(this.m_texture);

		this.update(deltaTime);
			
		this.m_currentVertexBuffer = 1 - this.m_currentVertexBuffer;

		gl.BlendFunc(GL_SRC_ALPHA, GL_ONE); 
		gl.DepthMask(false);

		this.m_graphicsDevice.disable(EnableCap.RasterizeDiscard);
		
		this.m_graphicsDevice.enableShader(this.m_shader);

		//this.m_graphicsDevice.setMatrix("modelView", modelView.ptr);
		//this.m_graphicsDevice.setMatrix("projection", projection.ptr);

		this.m_graphicsDevice.bindVertexBuffer(this.m_particleBuffer[this.m_currentVertexBuffer]);

		Particle *particle = null;
		/*gl.VertexAttribPointer(this.m_shader.getAttribute("vPosition"), 3, GL_FLOAT, false, Particle.sizeof, &particle.position);
		gl.VertexAttribPointer(this.m_shader.getAttribute("vColor"), 3, GL_FLOAT, false, Particle.sizeof, &particle.color);
		gl.VertexAttribPointer(this.m_shader.getAttribute("fLifeTime"), 1, GL_FLOAT, false, Particle.sizeof, &particle.lifeTime);
		gl.VertexAttribPointer(this.m_shader.getAttribute("fSize"), 1, GL_FLOAT, false, Particle.sizeof, &particle.size);
		gl.VertexAttribPointer(this.m_shader.getAttribute("iType"), 1, GL_INT, false, Particle.sizeof, &particle.type);
*/
		this.m_graphicsDevice.drawPrimitives!(PrimitiveType.Points)(this.m_particlesNumber);

		this.m_graphicsDevice.disableShader();

		gl.DepthMask(true);	
		gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	public void draw(in float deltaTime)
	{
		this.draw(deltaTime, this.m_graphicsDevice.viewMatrix, this.m_graphicsDevice.projectionMatrix);
	}

	private void update(in float deltaTime)
	{
		this.m_graphicsDevice.enableShader(this.m_updateShader);

		import std.random;

		auto randomSeed = vec3(uniform(-10.0f, 20.0f), uniform(-10, 20.0f), uniform(-10.0f, 20.0f));

		/*this.m_graphicsDevice.setUniform!("1f", float)("timePassed", deltaTime);
		this.m_graphicsDevice.setUniform!("3fv", float)("effectPosition", this.m_position.ptr);
		this.m_graphicsDevice.setUniform!("3fv", float)("effectColor", this.m_emitterDefinition.color.ptr);
		this.m_graphicsDevice.setUniform!("3fv", float)("effectGravity", this.m_emitterDefinition.gravity.ptr);
		this.m_graphicsDevice.setUniform!("3fv", float)("effectVelocityMin", this.m_emitterDefinition.velocityMin.ptr);
		this.m_graphicsDevice.setUniform!("3fv", float)("effectVelocityRange", this.m_emitterDefinition.velocityRange.ptr);

		this.m_graphicsDevice.setUniform!("1f", float)("effectLifeMin", this.m_emitterDefinition.lifeMin);
		this.m_graphicsDevice.setUniform!("1f", float)("effectLifeRange", this.m_emitterDefinition.lifeRange);

		this.m_graphicsDevice.setUniform!("1f", float)("effectSize", this.m_emitterDefinition.size);
*/
		this.m_elapsedTime += deltaTime; 

		if(this.m_elapsedTime > this.m_emitterDefinition.nextGenerationTime) 
		{ 
			//this.m_graphicsDevice.setUniform!("1i", int)("particlesCount", this.m_emitterDefinition.particlesNumberToGenerate);

			this.m_elapsedTime -= this.m_emitterDefinition.nextGenerationTime; 

			//this.m_graphicsDevice.setUniform!("3fv", float)("randomSeed", randomSeed.ptr);
		}
	//	else this.m_graphicsDevice.setUniform!("1i", int)("particlesCount", 0);

		this.m_graphicsDevice.enable(EnableCap.RasterizeDiscard);

		//glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, this.m_transformFeedbackBuffer);
		this.m_graphicsDevice.bindVertexBuffer(this.m_particleBuffer[this.m_currentVertexBuffer]);

		Particle *particle = null;
	/*	gl.VertexAttribPointer(this.m_updateShader.getAttribute("in_Position"), 3, GL_FLOAT, false, Particle.sizeof, &particle.position);
		gl.VertexAttribPointer(this.m_updateShader.getAttribute("in_Velocity"), 3, GL_FLOAT, false, Particle.sizeof, &particle.velocity);
		gl.VertexAttribPointer(this.m_updateShader.getAttribute("in_Color"), 3, GL_FLOAT, false, Particle.sizeof, &particle.color);
		gl.VertexAttribPointer(this.m_updateShader.getAttribute("in_LifeTime"), 1, GL_FLOAT, false, Particle.sizeof, &particle.lifeTime);
		gl.VertexAttribPointer(this.m_updateShader.getAttribute("in_Size"), 1, GL_FLOAT, false, Particle.sizeof, &particle.size);
		gl.VertexAttribPointer(this.m_updateShader.getAttribute("in_Type"), 1, GL_INT, false, Particle.sizeof, &particle.type);
*/
		gl.BindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, this.m_particleBuffer[1 - this.m_currentVertexBuffer]); 

		gl.BeginQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, this.m_query); 
		gl.BeginTransformFeedback(GL_POINTS);

		this.m_graphicsDevice.drawPrimitives!(PrimitiveType.Points)(this.m_particlesNumber);

		gl.EndTransformFeedback(); 

		gl.EndQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN); 
		gl.GetQueryObjectiv(this.m_query, GL_QUERY_RESULT, &this.m_particlesNumber); 

//		glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, 0); 

		this.m_graphicsDevice.disableShader();
	}
}

class ParticleEmitterDefinition
{
	/// Maximum particles 
	public uint maxParticlesNumber;

	/// Number of particles to generate each x time
	public uint particlesNumberToGenerate;

	public float nextGenerationTime;
	public float lifeMin, lifeRange, size;

	public vec3 velocityMin;
	public vec3 velocityRange;
	public vec3 gravity;
	public vec3 color;

	public Texture texture;

	public this(in uint maxParticlesNumber)
	{
		this.maxParticlesNumber = maxParticlesNumber;
	}

	public void setGeneratorProperties()(in auto ref vec3 velocityMin, in auto ref vec3 velocityMax, 
									   in auto ref vec3 gravity, 
									   auto ref Color color, in float lifeMin, in float lifeMax, in float size, in float nextGenerationTime, in int numberToGenerate)
	{
		this.velocityMin = velocityMin;
		this.velocityRange = velocityMax - velocityMin;

		this.gravity = gravity;
		this.color = vec3(color.asFloat()[0..3]);
		this.size = size;

		this.lifeMin = lifeMin;
		this.lifeRange = lifeMax - lifeMin;

		this.nextGenerationTime = nextGenerationTime;

		this.particlesNumberToGenerate = numberToGenerate;
	}
}