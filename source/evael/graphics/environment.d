module evael.graphics.environment;

import evael.graphics.gl;

import evael.graphics.graphics_device;
import evael.graphics.shaders.basic_light_shader;
import evael.graphics.lights;

import evael.utils.math;

import dnogc.DynamicArray;

/**
 * Environment.
 */
class Environment
{
	enum MAX_POINTS_LIGHTS = 50;

	private GraphicsDevice m_graphicsDevice;

	/// Ambient light
	private AmbientLight m_ambientLight;

	/// Sun
	private DirectionalLight m_sun;

	private mat4 m_sunProjection;
	private mat4 m_sunView;

	/// Lights
	private DynamicArray!PointLight m_pointsLights;

	/**
	 * Environment constructor.
	 * Params:
	 *      graphics : graphics device
	 */
	public this(GraphicsDevice graphics) nothrow
	{
		this.m_graphicsDevice = graphics;

		this.m_sunProjection = orthoMatrix(-300.0f, 300.0f, -300.0f, 300.0f, -300.0f, 300.0f);

		this.m_ambientLight = new AmbientLight(vec3(1.0, 1.0, 1.0));

		this.m_sun = new DirectionalLight();
		this.m_sun.direction = vec3(1.0, 1.0, 1.0);
		this.m_sun.ambient = vec3(1.0, 1.0, 1.0);
		this.m_sun.diffuse = vec3(1.0, 1.0, 1.0);
		this.m_sun.specular = vec3(1.0, 1.0, 1.0);
	}

	/**
	 * Environment destructor.
	 */
	public void dispose()
	{
		this.m_pointsLights.dispose();
	}

	/**
	 * Adds a point light to the scene.
	 * Params:
	 *		light : point light
	 */
	@nogc
	public void addPointLight(PointLight light) nothrow
	{
		this.m_pointsLights ~= light;
	}


	/**
	 * Sets environment for the next frame.
	 */
	@nogc
	public void set() nothrow
	{
		this.setSun();
		this.setPointsLights();
		this.setAmbientLight();
	}

	/**
	 * Sets sun.
	 */
	@nogc
	private void setSun() nothrow
	{
		auto lightShader = cast(BasicLightShader) this.m_graphicsDevice.currentShader;

		gl.Uniform3fv(lightShader.dirLightDirectionLocation, 1, this.m_sun.direction.arrayof.ptr);
		gl.Uniform3fv(lightShader.dirLightAmbientLocation, 1, this.m_sun.ambient.arrayof.ptr);
		gl.Uniform3fv(lightShader.dirLightDiffuseLocation, 1, this.m_sun.diffuse.arrayof.ptr);
		gl.Uniform3fv(lightShader.dirLightSpecularLocation, 1, this.m_sun.specular.arrayof.ptr);
	}

	/**
	 * Sets ambient light.
	 */
	@nogc
	private void setAmbientLight() nothrow
	{
		auto lightShader = cast(BasicLightShader) this.m_graphicsDevice.currentShader;

		gl.Uniform3fv(lightShader.ambientLightValueLocation, 1, this.m_ambientLight.value.arrayof.ptr);
	}

	/**
	 * Sets points lights.
	 */
	@nogc
	private void setPointsLights() nothrow
	{
		if (this.m_pointsLights.length == 0)
			return;

		auto lightShader = cast(BasicLightShader) this.m_graphicsDevice.currentShader;

		gl.Uniform1i(lightShader.pointsLightsNumberLocation, cast(int) this.m_pointsLights.length);
		
		foreach (_i, light; this.m_pointsLights)
		{
			int i = cast(int) _i;
			gl.Uniform3fv(lightShader.pointsLightsLocation + (i * 1), 1, light.position.arrayof.ptr);
			gl.Uniform3fv(lightShader.pointsLightsLocation + MAX_POINTS_LIGHTS + (i * 1), 1, light.color.arrayof.ptr);
			gl.Uniform1f(lightShader.pointsLightsLocation + MAX_POINTS_LIGHTS * 2 + (i * 1), light.ambient);		
			gl.Uniform1f(lightShader.pointsLightsLocation + MAX_POINTS_LIGHTS * 3 + (i * 1), light.constant);
			gl.Uniform1f(lightShader.pointsLightsLocation + MAX_POINTS_LIGHTS * 4 + (i * 1), light.linear);
			gl.Uniform1f(lightShader.pointsLightsLocation + MAX_POINTS_LIGHTS * 5 + (i * 1), light.quadratic);
			gl.Uniform1i(lightShader.pointsLightsLocation + MAX_POINTS_LIGHTS * 6 + (i * 1), light.isEnabled);
		}
	}

	@nogc
	@property nothrow
	{
		public void sun(DirectionalLight value)
		{
			this.m_sun = value;
		}

		public DirectionalLight sun()
		{
			return this.m_sun;
		}

		public void ambientLight(AmbientLight value)
		{
			this.m_ambientLight = value;
		}

		public AmbientLight ambientLight()
		{
			return this.m_ambientLight;
		}
		
		public void sunView()(in auto ref mat4 value)
		{
			this.m_sunView = value;
		}

		public mat4 sunView()
		{
			return this.m_sunView;
		}

		public DynamicArray!PointLight pointsLights()
		{
			return this.m_pointsLights;
		}
	}
}