module evael.renderer.vk.vk_debugger;

import evael.renderer.vk.vk_wrapper;

import evael.lib.containers.array : Array;
import std.experimental.logger;
import std.string : format, fromStringz, toStringz;
import core.stdc.string : strcmp;

@nogc
private extern(System) VkBool32 debugCallback(
    VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
    VkDebugUtilsMessageTypeFlagsEXT messageType,
    const VkDebugUtilsMessengerCallbackDataEXT* pCallbackData,
    void* pUserData) nothrow
{
    import core.stdc.stdio : printf;

    printf("\nNew validation layer message:\n\tSeverity: %d\n\tType: %d\n\tMessage: %s\n\n", 
        messageSeverity, messageType, pCallbackData.pMessage
    );

    return VK_FALSE;
}

class VulkanDebugger
{
    private VkDebugUtilsMessengerEXT m_messenger;
    private VkDebugUtilsMessengerCreateInfoEXT m_info;

    private VkInstance m_vkInstance;

    private alias cstring = const(char*);
    private cstring[] m_validationLayers = ["VK_LAYER_LUNARG_standard_validation"];
    
    public this()
    {
        this.enforceValidationLayerSupport();
        
        VkDebugUtilsMessengerCreateInfoEXT createInfo = {
            sType: VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
            messageSeverity: VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT,
            messageType: VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT,
            pfnUserCallback: &debugCallback,
            pUserData: null
        };

        this.m_info = createInfo;
    }

    public ~this()
    {
        auto func = cast(PFN_vkDestroyDebugUtilsMessengerEXT) vkGetInstanceProcAddr(this.m_vkInstance, "vkDestroyDebugUtilsMessengerEXT");
        
        if (func != null) 
        {
            func(this.m_vkInstance, this.m_messenger, null);
        }
    }

    public void setupCallback(ref VkInstance instance)
    {
        auto func = cast (PFN_vkCreateDebugUtilsMessengerEXT) vkGetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT");

        if (func != null) 
        {
            this.m_vkInstance = instance;

            assert(
                func(instance, &this.m_info, null, &this.m_messenger) == VK_SUCCESS,
                "Error when trying to create debug messenger."
            );
        }
        
        assert("vkCreateDebugUtilsMessengerEXT extension not available.");
    }

    public void addDebugExtensions(ref VkInstanceCreateInfo createInfo, const(char*)* glfwExtensions, uint glfwExtensionCount)
    {
        // We need to select between VK_EXT_debug_utils and VK_EXT_debug_report
        string defaultDebugExtension = "VK_EXT_debug_report";
        auto availableExtensions = this.getAvailableExtensions();

        foreach (ref extension; availableExtensions)
        {
            string name = cast(string) (cast(char*) extension.extensionName).fromStringz();

            if(name == VK_EXT_DEBUG_UTILS_EXTENSION_NAME)
            {
                defaultDebugExtension = VK_EXT_DEBUG_UTILS_EXTENSION_NAME;
                break;
            }
        }

        cstring[] newGlfwExtensions = cast(cstring[]) glfwExtensions[0..glfwExtensionCount];
        newGlfwExtensions ~= defaultDebugExtension.toStringz();
        
        createInfo.enabledExtensionCount++;
        createInfo.ppEnabledExtensionNames = newGlfwExtensions.ptr;
    }
    
    public void addValidationLayers(ref VkInstanceCreateInfo createInfo)
    {
        createInfo.enabledLayerCount = cast(uint) this.m_validationLayers.length;
        createInfo.ppEnabledLayerNames = this.m_validationLayers.ptr;
    }

    public void enforceValidationLayerSupport()
    {
        uint layerCount;
        vk.EnumerateInstanceLayerProperties(&layerCount, null);

        auto availableLayers = new VkLayerProperties[](layerCount);

        vk.EnumerateInstanceLayerProperties(&layerCount, availableLayers.ptr);

        foreach (layerName; this.m_validationLayers) 
        {
            bool layerFound = false;

            foreach (ref layerProperties; availableLayers) 
            {
                if (strcmp(layerName, layerProperties.layerName.ptr) == 0)
                {
                    layerFound = true;
                    break;
                }
            }

            if (!layerFound) 
            {
                assert(false, "The following validation layer is not available: %s".format(layerName));
            }
        }
    }

    public VkExtensionProperties[] getAvailableExtensions()
    {
        uint extensionCount = 0;
        vk.EnumerateInstanceExtensionProperties(null, &extensionCount, null);

        auto extensions = new VkExtensionProperties[](extensionCount);

        vk.EnumerateInstanceExtensionProperties(null, &extensionCount, extensions.ptr);

        infof("Enumerating %d Vulkan extensions...", extensionCount);
        foreach (ref extension; extensions)
        {
            infof("\t%s", (cast(char*) extension.extensionName).fromStringz());
        }

        return extensions;
    }

    @property
    public VkDebugUtilsMessengerCreateInfoEXT info()
    {
        return this.m_info;
    }
}