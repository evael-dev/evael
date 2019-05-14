module evael.graphics.models.Iqm;

import std.stdio;
import std.math;
import std.exception : enforce;
import std.string : format;
import std.conv : to;

import core.stdc.string : memcpy;
import core.stdc.string : strlen;

import evael.graphics.GraphicsDevice;
import evael.graphics.shaders.IqmShader;
import evael.graphics.Vertex;
import evael.graphics.models.Model;
import evael.graphics.models.Animation;
import evael.graphics.models.BoundingBox;

import evael.system.Asset;
import evael.system.AssetLoader;

import evael.utils.Math;
import evael.utils.Color;

class Iqm : Model
{
	static enum IQM_VERSION = 2;

	struct IqmHeader
	{
		char[16] magic;
		uint fileVersion;
		uint fileSize;
		uint flags;
		uint num_text, ofs_text;
		uint num_meshes, ofs_meshes;
		uint num_vertexarrays, num_vertexes, ofs_vertexarrays;
		uint num_triangles, ofs_triangles, ofs_adjacency;
		uint num_joints, ofs_joints;
		uint num_poses, ofs_poses;
		uint num_animations, ofs_anims;
		uint num_frames, num_framechannels, ofs_frames, ofs_bounds;
		uint num_comment, ofs_comment;
		uint num_extensions, ofs_extensions;
	}
	
	struct IqmMesh
	{
		uint name;
		uint material;
		uint firstVertex, vertexesNumber;
		uint firstTriangle, trianglesNumber;
	}
	
	enum IqmAttribute: ubyte
	{
		Position     = 0,
		TexCoord	 = 1,
		Normal       = 2,
		Tangent      = 3,
		BlendIndexes = 4,
		BlendWeights = 5,
		Color        = 6,
		Custom       = 0x10
	}
	
	enum IqmType : ubyte
	{
		Byte   = 0,
		UByte  = 1,
		Short  = 2,
		UShort = 3,
		Int    = 4,
		Uint   = 5,
		Half   = 6,
		Float  = 7,
		Double = 8,
	}
	
	struct IqmTriangle
	{
		uint[3] vertex;
	}
	
	struct IqmJoint
	{
		uint name;
		int parent;
		float[3] translate;
		float[4] rotate;
		float[3] scale;
	}
	
	struct IqmPose
	{
		int parent;
		uint mask;
		float[10] channeloffset;
		float[10] channelscale;
	}
	
	struct IqmAnim
	{
		uint name;
		uint firstFrame, framesNumber;
		float deltaTime;
		uint flags;
	}
	
	enum IQM_LOOP = 1<<0;
	
	struct IqmVertexArray
	{
		uint type;
		uint flags;
		uint format;
		uint size;
		uint offset;
	}

	struct IqmBounds
	{
		float[3] bbmin, bbmax;
		float xyradius, radius;
	}
		
	private float* m_inPositions;
	private float* m_inNormals;
	private float* m_inTexCoords;
	
	private ubyte* m_inColors;	
	private ubyte* m_inBlendIndex;
	private ubyte* m_inBlendWeight;
	
	/// Model triangles
	private IqmTriangle* m_triangles;
	
	/// Model meshes
	private IqmMesh* m_meshes;
	
	/// Header
	private IqmHeader m_header;
	
	/// Textures for meshes
	private uint[] m_textures;
	
	private IqmJoint* m_rawJoints;
	private IqmPose* m_rawPoses;
	private IqmAnim* m_rawAnimations;
	private BoundingBox* m_bounds;
	
	public mat4[] m_baseframe; 
	public mat4[] m_inversebaseframe;
	public mat4[] m_outframe;
	public mat4[] m_frames;

	/// Animations list
	private Animation[string] m_animations;
    
    /// Joints list
    private uint[string] m_joints;
    
	private BoundingBox[] m_boundingBoxes;
	
	private uint m_vao, m_vertexBuffer, m_indexBuffer;
	
	public this(GraphicsDevice graphicsDevice)
	{
		super(graphicsDevice);
	}


	public override void dispose()
	{

	}
	
	/**
	 * Draws the model
	 */
	public override void draw(in float deltaTime, mat4 view, mat4 projection)
	{
		auto iqmShader = cast(IqmShader)this.m_graphicsDevice.currentShader;

		this.m_graphicsDevice.setMatrix(this.m_shader.viewMatrix, view.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.projectionMatrix, projection.arrayof.ptr);

        this.m_graphicsDevice.setEnvironment();

		this.m_graphicsDevice.bindVAO(this.m_vao);
		this.m_graphicsDevice.setMatrix(iqmShader.boneMatrices, this.m_outframe[0].arrayof.ptr, this.m_header.num_joints);
        		
		IqmTriangle* tris = null;
		foreach(i; 0..this.m_header.num_meshes)
		{
			const(IqmMesh*) mesh = &this.m_meshes[i];
			
			if(this.m_textures != null)
			{
				if(i < this.m_textures.length)
                {
					this.m_graphicsDevice.bindTexture(this.m_textures[i]);
                }
			}
			
			this.m_graphicsDevice.drawIndexedPrimitives!(PrimitiveType.Triangle)(mesh.trianglesNumber, &tris[mesh.firstTriangle]);
		}

		this.m_graphicsDevice.bindVAO(0);		
	}

    
    public void drawShadowPass(in float deltaTime) 
    {
		auto iqmShader = cast(IqmShader)this.m_graphicsDevice.currentShader;

		this.m_graphicsDevice.bindVAO(this.m_vao);
		this.m_graphicsDevice.setMatrix(iqmShader.boneMatrices, this.m_outframe[0].arrayof.ptr, this.m_header.num_joints);

		IqmTriangle* tris = null;
		foreach(i; 0..this.m_header.num_meshes)
		{
			const(IqmMesh*) mesh = &this.m_meshes[i];
			this.m_graphicsDevice.drawIndexedPrimitives!(PrimitiveType.Triangle)(mesh.trianglesNumber, &tris[mesh.firstTriangle]);
		}

		this.m_graphicsDevice.bindVAO(0);
    }
	
	public override void drawInstances(in bool bindTexture = true)
	{

	}

	/**
	 * Play a specific frame
	 * Params:
	 *		frame : frame to play
	 */
	public void playFrame(in float frame)
	{
		int frame1 = cast(int)floor(frame);
		int frame2 = frame1 + 1;

		immutable float frameoffset = frame - frame1;

		frame1 %= this.m_header.num_frames;
		frame2 %= this.m_header.num_frames;

		mat4* mat1 = &this.m_frames[frame1 * this.m_header.num_joints];
		mat4* mat2 = &this.m_frames[frame2 * this.m_header.num_joints];

		float c = 1 - frameoffset;
		for(size_t i = 0; i < this.m_header.num_joints; i++)
		{
			mat4 mat = (mat1[i] * c) + (mat2[i] * frameoffset);

			if(this.m_rawJoints[i].parent >= 0) 
            {
				this.m_outframe[i] = this.m_outframe[this.m_rawJoints[i].parent] * mat;
            }
			else this.m_outframe[i] = mat;
		}

	}

	/**
	 * Loads IQM model
	 * Params:
	 *		fileName : model to load
	 */
	static Iqm load(in string fileName)
	{
		import evael.utils.Config;

		auto file = File(Config.Paths.models!string ~ fileName);
		scope(exit) file.close();

		auto iqm = new Iqm(GraphicsDevice.getInstance());

		// Reading header
		file.rawRead((&iqm.m_header)[0..1]);

		if(iqm.m_header.fileVersion != IQM_VERSION || iqm.m_header.fileSize > (16<<20)) 
        {
			throw new Exception(format("Model \"%s\" is invalid.", fileName));
        }

		ubyte[] buffer = new ubyte[iqm.m_header.fileSize];

		// Reading model data
		file.rawRead(buffer[IqmHeader.sizeof..iqm.m_header.fileSize - IqmHeader.sizeof]);

		if(iqm.m_header.num_meshes > 0 && !loadMeshes(iqm, buffer))
        {
			throw new Exception(format("Model \"%s\" : meshes loading failed.", fileName));
        }

		if(iqm.m_header.num_animations > 0 && !loadAnimations(iqm, buffer))
        {
			throw new Exception(format("Model \"%s\" : animations loading failed.", fileName));
        }

		return iqm;

	}

	/**
	 * Loads iqm meshes
	 * Params:
	 *		buffer : model data
	 */
	static bool loadMeshes(Iqm iqm, in ubyte[] buffer)
	{
		iqm.m_outframe = new mat4[iqm.m_header.num_joints];

		char* name = cast(char*)&buffer[iqm.m_header.ofs_text + 1];

		IqmVertexArray* vas = cast(IqmVertexArray*)&buffer[iqm.m_header.ofs_vertexarrays];

		for(size_t i = 0; i < iqm.m_header.num_vertexarrays; i++)
		{
			IqmVertexArray *va = &vas[i];

			switch(va.type)
			{
				case IqmAttribute.Position: 
					if(va.format != IqmType.Float || va.size != 3)
						return false; 

					iqm.m_inPositions = cast(float *)&buffer[va.offset]; 
					break;

				case IqmAttribute.Normal: 
					if(va.format != IqmType.Float || va.size != 3)
						return false;

					iqm.m_inNormals = cast(float*)&buffer[va.offset];
					break;

				case IqmAttribute.TexCoord: 
					if(va.format != IqmType.Float || va.size != 2) 
						return false; 

					iqm.m_inTexCoords = cast(float*)&buffer[va.offset]; 
					break;

				case IqmAttribute.BlendIndexes: 
					if(va.size != 4)
						return false;

					iqm.m_inBlendIndex = cast(ubyte*)&buffer[va.offset];
					break;

				case IqmAttribute.BlendWeights: 
					if(va.size != 4)
						return false;

					iqm.m_inBlendWeight = cast(ubyte*)&buffer[va.offset]; 
					break;
					
				case IqmAttribute.Color:
					
					iqm.m_inColors = cast(ubyte*)&buffer[va.offset];
					break;
					
				default:
					break;
			}
		}

		iqm.m_triangles = cast(IqmTriangle*)&buffer[iqm.m_header.ofs_triangles];
		iqm.m_meshes = cast(IqmMesh*)&buffer[iqm.m_header.ofs_meshes];
		iqm.m_rawJoints = cast(IqmJoint*)&buffer[iqm.m_header.ofs_joints];

		iqm.m_baseframe = new mat4[iqm.m_header.num_joints];
		iqm.m_inversebaseframe = new mat4[iqm.m_header.num_joints];

		for(size_t i = 0; i < iqm.m_header.num_joints; i++)
		{
			IqmJoint* j = &iqm.m_rawJoints[i];
            
 			Quaternionf quat = Quaternionf(j.rotate);
            quat.normalize();
             
            mat4 joinMatrix = quat.toMatrix4x4();
            joinMatrix *= scaleMatrix(vec3(j.scale));            
            joinMatrix.arrayof[3] = j.translate[0];
            joinMatrix.arrayof[7] = j.translate[1];
            joinMatrix.arrayof[11] = j.translate[2];
            joinMatrix.arrayof[15] = 1;
            
			iqm.m_baseframe[i] = joinMatrix;
			iqm.m_inversebaseframe[i] = iqm.m_baseframe[i].inverse();

			if(j.parent >= 0) 
			{
				iqm.m_baseframe[i] = iqm.m_baseframe[j.parent] * iqm.m_baseframe[i];
				iqm.m_inversebaseframe[i] = iqm.m_inversebaseframe[i] * iqm.m_inversebaseframe[j.parent];
			}
            
            // We add the joint in the list for attaching weapons to models
            char* joinName = &name[j.name - 1];
            iqm.m_joints[cast(string)joinName[0..strlen(joinName)]] = i;
		}

		import evael.graphics.Texture;

		for(size_t i = 0; i < iqm.m_header.num_meshes; i++)
		{
			IqmMesh* mesh = &iqm.m_meshes[i];
			char* textureName = &name[mesh.material - 1];

			if(*textureName != '\0')
			{
				debug
				{
					char* meshName = &name[mesh.name - 1];
					/*writefln("Loaded mesh: %s", meshName[0..strlen(meshName)]);
					writefln("Loaded texture: %s", textureName[0..strlen(textureName)]);*/
				}

				immutable string str = textureName[0..strlen(textureName)].idup;
				
				if(str.length <= 8 || (str.length > 8 && str[0..8] != "Material"))
				{
					iqm.m_textures ~= AssetLoader.getInstance().load!(Texture)(str).id;
				}
			}
		}

		generateBuffers(iqm);

		return true;
	}

	/**
	 * Loads iqm animations
	 * Params:
	 *		buffer : model data
	 */
	static bool loadAnimations(Iqm iqm, in ubyte[] buffer)
	{
		if(iqm.m_header.num_poses != iqm.m_header.num_joints)
			return false;

		char* str = cast(char *)&buffer[iqm.m_header.ofs_text + 1];
		iqm.m_rawAnimations = cast(IqmAnim*)&buffer[iqm.m_header.ofs_anims];
		iqm.m_rawPoses = cast(IqmPose*)&buffer[iqm.m_header.ofs_poses];
		iqm.m_bounds = cast(BoundingBox*)&buffer[iqm.m_header.ofs_bounds];
		IqmBounds* tB = cast(IqmBounds*)&buffer[iqm.m_header.ofs_bounds];

		iqm.m_frames = new mat4[iqm.m_header.num_frames * iqm.m_header.num_poses];
		ushort* framedata = cast(ushort*)&buffer[iqm.m_header.ofs_frames];

		// debug writeln("Frames : ", iqm.m_header.num_frames);

		for(size_t i = 0; i < iqm.m_header.num_frames; i++)
		{
			BoundingBox* bb = &iqm.m_bounds[i];
			iqm.m_boundingBoxes ~= *bb;

			for(size_t j = 0; j < iqm.m_header.num_poses; j++)
			{
				IqmPose *p = &iqm.m_rawPoses[j];
				Quaternionf rotate;
                
				vec3 translate, scale;
				translate.x = p.channeloffset[0]; if(p.mask&0x01) translate.x = translate.x + *framedata++ * p.channelscale[0];
				translate.y = p.channeloffset[1]; if(p.mask&0x02) translate.y = translate.y + *framedata++ * p.channelscale[1];
				translate.z = p.channeloffset[2]; if(p.mask&0x04) translate.z = translate.z + *framedata++ * p.channelscale[2];
				rotate.x = p.channeloffset[3]; if(p.mask&0x08) rotate.x = rotate.x + (*framedata++ * p.channelscale[3]);
				rotate.y = p.channeloffset[4]; if(p.mask&0x10) rotate.y = rotate.y + (*framedata++ * p.channelscale[4]);
				rotate.z = p.channeloffset[5]; if(p.mask&0x20) rotate.z = rotate.z + (*framedata++ * p.channelscale[5]);
				rotate.w = p.channeloffset[6]; if(p.mask&0x40) rotate.w = rotate.w + (*framedata++ * p.channelscale[6]);
                scale.x = p.channeloffset[7]; if(p.mask&0x80) scale.x = scale.x + *framedata++ * p.channelscale[7];
				scale.y = p.channeloffset[8]; if(p.mask&0x100) scale.y = scale.y + *framedata++ * p.channelscale[8];
				scale.z = p.channeloffset[9]; if(p.mask&0x200) scale.z = scale.z + *framedata++ * p.channelscale[9];
                
				rotate.normalize();
                
				mat4 m = rotate.toMatrix4x4();
            	m *= scaleMatrix(scale);            
                m.arrayof[4] = translate.x;
                m.arrayof[7] = translate.y;
                m.arrayof[11] = translate.z;
                m.arrayof[15] = 1;
                           
				if(p.parent >= 0)
                {
					iqm.m_frames[i * iqm.m_header.num_poses + j] = iqm.m_baseframe[p.parent] * m * iqm.m_inversebaseframe[j];
                }
				else 
                {
                    iqm.m_frames[i * iqm.m_header.num_poses + j] = m * iqm.m_inversebaseframe[j];
                }
                
			}
		}

		/*foreach(b; 0..iqm.m_header.num_frames)
		{
			IqmBounds* bb = &tB[b];
			writeln("\t\t", *bb);
		}*/

		for(size_t i = 0; i < iqm.m_header.num_animations; i++)
		{
			IqmAnim* animation = &iqm.m_rawAnimations[i];

			char* animName = &str[animation.name - 1];
			immutable string animationName = to!string(animName[0..strlen(animName)]);

			iqm.m_animations[animationName] = Animation(animation.framesNumber, 
															 animation.firstFrame, 
															 animation.firstFrame + animation.framesNumber - 1);
			debug
			{
				/*writefln("Loaded anim: %s", animationName);
				writefln("\t\tFirst frame: %d\n\t\tLast frame: %d", animation.firstFrame, animation.firstFrame + animation.framesNumber - 1);*/
			}
		}

		iqm.playFrame(0);

		return true;
	}

	/**
	 * Generates vbo and ibo
	 * Params:
	 *		iqm : data to send
	 */
	static void generateBuffers(Iqm iqm)
	{
		IqmVertex[] vertices = new IqmVertex[iqm.m_header.num_vertexes];

		static immutable ubyte[4] color = 255;

		for(int i = 0; i < cast(int)iqm.m_header.num_vertexes; i++)
		{
			IqmVertex *v = &vertices[i];

			memcpy(cast(float*)v.position.arrayof.ptr,			&iqm.m_inPositions[i*3],	v.position.sizeof);
			memcpy(cast(float*)v.normal.arrayof.ptr,			&iqm.m_inNormals[i*3],		v.normal.sizeof);
			memcpy(cast(float*)v.textureCoordinate.arrayof.ptr, &iqm.m_inTexCoords[i*2],	v.textureCoordinate.sizeof);

			if(iqm.m_inColors != null)
			{
				memcpy(cast(ubyte*)v.color.ptr, &iqm.m_inColors[i*4], v.color.sizeof);
			}
			else
			{
				memcpy(cast(ubyte*)v.color.ptr, &color,	v.color.sizeof);				
			}

			// Animated model
			if(iqm.m_header.num_animations > 0)
			{
				memcpy(cast(ubyte*)v.blendIndex.arrayof.ptr, &iqm.m_inBlendIndex[i*4], v.blendIndex.sizeof);
				memcpy(cast(ubyte*)v.blendWeight.arrayof.ptr, &iqm.m_inBlendWeight[i*4], v.blendWeight.sizeof);
			}
		}

		auto graphicsDevice = GraphicsDevice.getInstance();

		iqm.m_vao = graphicsDevice.generateVAO();
		iqm.m_vertexBuffer = graphicsDevice.createVertexBuffer(IqmVertex.sizeof * iqm.m_header.num_vertexes, vertices.ptr);
		iqm.m_indexBuffer = graphicsDevice.createIndexBuffer(IqmTriangle.sizeof * iqm.m_header.num_triangles,  iqm.m_triangles);

		graphicsDevice.setVertexBuffer!(IqmVertex)(iqm.m_vertexBuffer);
		
		graphicsDevice.bindVAO(0);
	}

	@property
	public ref Animation getAnimation(in string name) nothrow
	{
		// TODO : this func is called all the fucking day ?
		/*try
		{
			debug writeln("Asking for animation ", name);
		}
		catch(Exception e)
		{

		}*/

		return this.m_animations[name];
	}

	/**
	 * Properties
	 */
	@property
	{
		public IqmHeader header() const nothrow @nogc
		{
			return this.m_header;
		}
		
		public uint joints(in string name) const nothrow
		{
			return this.m_joints[name];
		}

		public ref mat4[] outFrames() nothrow @nogc
		{
			return this.m_outframe;
		}
		
		public bool hasAnimation() const nothrow @nogc
		{
			return this.m_header.num_animations > 0;
		}

		public BoundingBox* boundingBoxes() nothrow @nogc
		{
			return this.m_bounds;
		}

		public bool hasTextures() const nothrow @nogc
		{
			return this.m_textures.length > 0;
		}
	}
}
