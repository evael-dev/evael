module evael.renderer.vk.vk_device;

import evael.renderer.device;
import evael.renderer.vk.vk_command;
import evael.renderer.vk.vk_wrapper;

import evael.lib.memory;
import evael.lib.containers.array;

class VkDevice : Device
{
	private VkInstance m_vkInstance;

	/**
	 * VkDevice constructor.
	 */
	@nogc
	public this()
	{
		this.initialize();
	}

	/**
	 * VkDevice destructor.
	 */
	@nogc
	public ~this()
	{

	}
	
	@nogc
	public override void beginFrame(in Color color = Color.LightGrey)
	{

	}

	@nogc
	public override void endFrame()
	{

	}

	/*
	 * Initializes vulkan.
	 */
	@nogc
	public void initialize()
	{
		/**
		 * Loading functions for vulkan
		 */
		import erupted.vulkan_lib_loader;
    	import bindbc.glfw;

    	mixin(bindGLFW_Vulkan);
    	loadGlobalLevelFunctions();
		loadGLFW_Vulkan();

		VkApplicationInfo appInfo = {
			sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
			pApplicationName: "D Game",
			applicationVersion: VK_MAKE_VERSION(1, 0, 0),
			pEngineName: "No Engine",
			engineVersion: VK_MAKE_VERSION(1, 0, 0),
			apiVersion: VK_API_VERSION_1_0
		};


		uint glfwExtensionCount = 0;
		auto glfwExtensions = glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

		VkInstanceCreateInfo createInfo = 
		{ 
			sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
		 	pApplicationInfo: &appInfo,
			enabledExtensionCount: glfwExtensionCount,
			ppEnabledExtensionNames: glfwExtensions,
			enabledLayerCount: 0
		};
		
		auto result = vk.CreateInstance(&createInfo, null, &this.m_vkInstance);
		assert(result, "Error when trying to initialize Vulkan.");

		debug
		{
			import std.experimental.logger : info, infof;
			import evael.lib.containers.array : Array;
			
			uint extensionCount = 0;
			vkEnumerateInstanceExtensionProperties(null, &extensionCount, null);

			auto extensions = Array!VkExtensionProperties(extensionCount);
			extensions.length = extensionCount;

			vkEnumerateInstanceExtensionProperties(null, &extensionCount, extensions.data.ptr);

			infof("Enumerating %d Vulkan extensions...", extensionCount);
			foreach (ref extension; extensions)
			{
				info("Extension name: %s", extension.extensionName[0..extension.extensionName.length]);
			}

			extensions.dispose();
		}
	}
} 