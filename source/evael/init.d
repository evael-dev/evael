module evael.init;

import std.experimental.logger;

import bindbc.openal;
import bindbc.glfw;
import bindbc.freeimage;
import bindbc.nuklear;

/**
 * Initializes external libs.
 */
@nogc
void loadExternalLibraries()
{
    debug
    {
        infof("GLFW:%d", loadGLFW());
        infof("OpenAL:%d", loadOpenAL());
        infof("FreeImage:%d", loadFreeImage());
        infof("Nuklear:%d", loadNuklear());
    }

    if (!glfwInit()) 
    {
        assert(0, "Error when calling glfwInit()");        
    }
}

@nogc
void unloadExternalLibraries() nothrow
{
    glfwTerminate();
}