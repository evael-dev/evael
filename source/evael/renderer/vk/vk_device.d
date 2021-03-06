module evael.renderer.vk.vk_device;

import erupted.vulkan_lib_loader;
import bindbc.glfw;

mixin(bindGLFW_Vulkan);

import evael.renderer.graphics_device;
import evael.renderer.vk.vk_command;
import evael.renderer.vk.vk_wrapper;

import evael.lib.memory;
import evael.lib.containers.array;

import evael.utils.functions : assumeNoGC;

import evael.system.window;

debug 
{
    import evael.renderer.vk.vk_debugger;
    import std.string : fromStringz;
    import std.experimental.logger: info, infof;
}

class VulkanDevice : GraphicsDevice
{
    private VkInstance m_instance;
    private VkPhysicalDevice m_physicalDevice;
    private VkDevice m_logicalDevice;
    private VkSurfaceKHR m_surface;
    
    private VkQueue m_graphicsQueue;
    private VkQueue m_presentQueue;

    private uint m_graphicsFamilyIndex;
    private uint m_presentFamilyIndex;
    
    debug private VulkanDebugger m_debugger;

    /**
     * VkDevice constructor.
     */
    @nogc
    public this(in ref GraphicsSettings graphicsSettings)
    {
        super(graphicsSettings);

        this.initializeGLFW();
        this.createInstance();
        this.selectPhysicalDevice();
        this.createLogicalDevice();
    }

    /**
     * VkDevice destructor.
     */
    @nogc
    public ~this()
    {
        vkDestroySurfaceKHR(this.m_instance, this.m_surface, null);
        vkDestroyDevice(this.m_logicalDevice, null);
        vkDestroyInstance(this.m_instance, null);
    }
    
    @nogc
    @property
    public override void window(GLFWwindow* win)
    {
        super.window = win;
        this.createSurface();
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
     * Initializes GLFW.
     */
    @nogc
    private void initializeGLFW()
    {
        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    }

    /*
     * Creates a vulkan instance.
     */
    @nogc
    private void createInstance()
    {
        /**
         * Loading functions for vulkan
         */
        loadGlobalLevelFunctions();
        loadGLFW_Vulkan();

        debug this.m_debugger = new VulkanDebugger();

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

        debug
        {
            VkDebugUtilsMessengerCreateInfoEXT debuggerInfo = this.m_debugger.info;
            createInfo.pNext = cast(VkDebugUtilsMessengerCreateInfoEXT*) &debuggerInfo;
            
            this.m_debugger.addDebugExtensions(createInfo,  glfwExtensions, glfwExtensionCount);
            this.m_debugger.addValidationLayers(createInfo);
        }
        
        enforce(vk.CreateInstance(&createInfo, null, &this.m_instance), "Error when trying to create Vulkan instance.");

        debug this.m_debugger.setupCallback(this.m_instance);

        loadInstanceLevelFunctions(this.m_instance);
    }

    @nogc
    private void createSurface()
    {
        auto result = glfwCreateWindowSurface(this.m_instance, this.m_window, null, &this.m_surface);

        // TODO: remove this trick when std.string.format is nogc
        assumeNoGC((VkResult r)
        {
            import std.string : format;
            enforce(r == VK_SUCCESS, "Error when trying to create window surface: %d.".format(r));
        })(result);
    }

    /*
     * Selects a physical device.
     */
    @nogc
    private void selectPhysicalDevice()
    {
        uint deviceCount = 0;
        vk.EnumeratePhysicalDevices(this.m_instance, &deviceCount, null);

        enforce(deviceCount > 0, "No graphics card that can handle Vulkan.");

        auto devices = Array!VkPhysicalDevice(deviceCount);
        devices.length = deviceCount;
        vk.EnumeratePhysicalDevices(this.m_instance, &deviceCount, devices.data.ptr);
        
        // We select the best suitable device
        foreach (ref device; devices)
        {
            if (this.isDeviceSuitable(device))
            {
                this.m_physicalDevice = device;
            }
        }

        enforce(this.m_physicalDevice !is null, "No graphics card that can handle specific Vulkan features.");
    }

    @nogc
    private bool isDeviceSuitable(ref VkPhysicalDevice device)
    {
        VkPhysicalDeviceProperties deviceProperties;
        VkPhysicalDeviceFeatures deviceFeatures;

        vkGetPhysicalDeviceProperties(device, &deviceProperties);
        vkGetPhysicalDeviceFeatures(device, &deviceFeatures);

        if (deviceProperties.deviceType != VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU)
            return false;
            
        if (deviceFeatures.geometryShader == false)
            return false;
        
        uint queueFamilyCount = 0;
        vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, null);

        auto queueFamilies = Array!VkQueueFamilyProperties(queueFamilyCount);
        queueFamilies.length = queueFamilyCount;

        vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, queueFamilies.data.ptr);
        
        foreach (i, ref queueFamily; queueFamilies)
        {
            if (queueFamily.queueFlags & VK_QUEUE_GRAPHICS_BIT) 
            {
                graphicsFamilyIndex = cast(uint) i;
                presentFamilyIndex = cast(uint) i;

                return true;
                this.m_physicalDevice = device;
                this.m_graphicsFamilyIndex = cast(uint) i;
                this.m_presentFamilyIndex = cast(uint) i;

                debug
                {
                    VkPhysicalDeviceProperties properties;
                    vkGetPhysicalDeviceProperties(device, &properties);
                    info("The following physical device has been selected: ");
                    info("\tPhysical device: ", properties.deviceName.ptr.fromStringz);
                    info("\tAPI Version: ", VK_VERSION_MAJOR(properties.apiVersion), ".", VK_VERSION_MINOR(properties.apiVersion), ".", VK_VERSION_PATCH(properties.apiVersion));
                    info("\tDriver Version: ", properties.driverVersion);
                    info("\tDevice type: ", properties.deviceType);
                }

                break;
            }
        }
    }

    @nogc
    public void createLogicalDevice()
    {
        VkDeviceQueueCreateInfo queueCreateInfo;
        queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
        queueCreateInfo.queueFamilyIndex = this.m_graphicsFamilyIndex;
        queueCreateInfo.queueCount = 1;

        immutable float queuePriority = 1.0f;
        queueCreateInfo.pQueuePriorities = &queuePriority;

        VkPhysicalDeviceFeatures deviceFeatures;
        
        VkDeviceCreateInfo createInfo = {
            sType: VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            pQueueCreateInfos: &queueCreateInfo,
            queueCreateInfoCount: 1,
            pEnabledFeatures: &deviceFeatures,
            enabledExtensionCount
        };

        enforce(
            vk.CreateDevice(this.m_physicalDevice, &createInfo, null, &this.m_logicalDevice), 
            "Error when trying to create the logical device."
        );

        loadDeviceLevelFunctions(this.m_logicalDevice);

        vkGetDeviceQueue(this.m_logicalDevice, this.m_graphicsFamilyIndex, 0, &this.m_graphicsQueue);
        vkGetDeviceQueue(this.m_logicalDevice, this.m_presentFamilyIndex, 0, &this.m_presentQueue);
    }

    public uint findQueueFamilies()
    {
        return 0;
    }
}