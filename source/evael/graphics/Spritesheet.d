module evael.graphics.Spritesheet;

import std.typecons;
import std.math;

import evael.graphics.GL;

import evael.graphics.GraphicsDevice;
import evael.graphics.Texture;
import evael.graphics.Vertex;
import evael.graphics.shapes.Quad;
import evael.graphics.models.Animation;

import evael.utils.math;
import evael.utils.Color;
import evael.utils.Size;
import evael.utils.Rectangle;

import dnogc.DynamicArray;
import dnogc.Utils;

/**
 * Spritesheet
 * Draw animated sprite.
 */
class Spritesheet : Quad!Vertex2PositionColorTexture
{
	/// Sprite size
	private Size!int m_spriteSize;

	private vec2 m_currentSpritePosition;

	private Animation[string] m_animations;

	private Animation m_currentAnimation;
	private float m_currentAnimationFrame;

	/**
	 * Spritesheet constructor.
	 */
	public this()(GraphicsDevice graphics, Texture texture, in auto ref Size!int spriteSize)
	{
		this.m_texture = texture;
		this.m_spriteSize = spriteSize;
		this.m_currentSpritePosition = vec2(0, 0);
		this.m_currentAnimationFrame = 0.0f;
		
		immutable float v = 1.0f / this.m_texture.size.width;

		super(
			graphics, 
			[
				// Bottom-left vertex
				Vertex2PositionColorTexture(vec2(0, 0), Color.White, vec2(0, (this.m_currentSpritePosition.y + spriteSize.height) * v)),
				// Top-left vertex
				Vertex2PositionColorTexture(vec2(0, spriteSize.height), Color.White, vec2(0, 0)),
				// Bottom-right vertex
				Vertex2PositionColorTexture(vec2(spriteSize.width, 0), Color.White, vec2((this.m_currentSpritePosition.x + spriteSize.width) * v, (this.m_currentSpritePosition.y + spriteSize.height) * v)),
				// Top-right vertex
				Vertex2PositionColorTexture(vec2(spriteSize.width, spriteSize.height), Color.White, vec2((this.m_currentSpritePosition.x + spriteSize.width) * v, 0))
			]
			,
			[0, 1, 2, 2, 1, 3]
		);
	}

	public override void draw(in float deltaTime, mat4 view, mat4 projection)				
	{
		if (this.m_animations.length)
		{
			this.update(deltaTime);
		}

		super.draw(deltaTime, view, projection);
	}

	public void update(in float deltaTime)
	{
		this.m_currentAnimationFrame += this.m_currentAnimation.speed * deltaTime;

		if (this.m_currentAnimationFrame >= this.m_currentAnimation.endFrame)
		{
			this.m_currentAnimationFrame = this.m_currentAnimation.startFrame;
		}

		auto ss = this.m_spriteSize;
		auto frame = cast(int)this.m_currentAnimationFrame - 1;

		auto framePerWidth = this.m_texture.size.width / cast(float)ss.width;

		auto x = frame % framePerWidth;
		auto y = floor(frame / framePerWidth);

		this.m_currentSpritePosition.x = x * ss.width;
		this.m_currentSpritePosition.y = y * ss.height;

		immutable float v = 1.0f / this.m_texture.size.width;

		auto vertices =
		[
			// Bottom-left vertex
			Vertex2PositionColorTexture(vec2(0, 0), Color.White, 
				vec2(this.m_currentSpritePosition.x * v, (this.m_currentSpritePosition.y + ss.height) * v)),

			// Top-left vertex
			Vertex2PositionColorTexture(vec2(0, this.m_spriteSize.height), Color.White, 
				vec2(this.m_currentSpritePosition.x * v, this.m_currentSpritePosition.y * v)),

			// Bottom-right vertex
			Vertex2PositionColorTexture(vec2(this.m_spriteSize.width, 0), Color.White, 
				vec2((this.m_currentSpritePosition.x + ss.width) * v, (this.m_currentSpritePosition.y + ss.height) * v)),

			// Top-right vertex
			Vertex2PositionColorTexture(vec2(this.m_spriteSize.width, this.m_spriteSize.height), Color.White, 
				vec2((this.m_currentSpritePosition.x + ss.width) * v, this.m_currentSpritePosition.y * v))
		];

		this.m_graphicsDevice.sendVertexBufferData(this.m_vertexBuffer, 0, Vertex2PositionColorTexture.sizeof * vertices.length, vertices.ptr);
	}

	/**
	 * Adds animation.
	 * Params:
	 *      name: animation name
	 *      animation : animation
	 */
	public void addAnimation()(in string name, in auto ref Animation animation)
	{
		this.m_animations[name] = animation;
	}

	/**
	 * Sets current animation.
	 * Params:
	 *      name: animation name
	 */
	public void setAnimation(in string name)
	{
		assert(name in this.m_animations);
		this.m_currentAnimation = this.m_animations[name];
		this.m_currentAnimationFrame = this.m_currentAnimation.startFrame;
	}

	/**
	 * Sets current sprite texture coords.
	 * Params:
	 *      rect : texture rect
	 */
	public void setTextureCoords()(in auto ref Rectangle!float rect)
	{
		immutable float v = 1.0f / this.m_texture.size.width;

		auto vertices =
		[
			// Bottom-left vertex
			Vertex2PositionColorTexture(vec2(0, 0), Color.White, vec2(rect.left * v, rect.top * v)),

			// Top-left vertex
			Vertex2PositionColorTexture(vec2(0, rect.size.height), Color.White, vec2(rect.left * v, rect.bottom * v)),

			// Bottom-right vertex
			Vertex2PositionColorTexture(vec2(rect.size.width, 0), Color.White, vec2(rect.right * v, rect.top * v)),

			// Top-right vertex
			Vertex2PositionColorTexture(vec2(rect.size.width, rect.size.height), Color.White, vec2(rect.right * v, rect.bottom * v))
		];

		this.m_graphicsDevice.sendVertexBufferData(this.m_vertexBuffer, 0, Vertex2PositionColorTexture.sizeof * vertices.length, vertices.ptr);   
	}

	@nogc @safe
	@property pure nothrow
	{

	}
}