evael
===========

Evael is a small 2D/3D game engine written in the D programming language. It is based on OpenGL 3.3.

It implements the following features:

- Asset loader (texture, models, shaders)
- Terrain rendering (blend map, normal map, height map)
- Model rendering (IQM, OBJ)
- Basic lighting support (directional light, point light)
- Shadow support
- Instancing (for OBJ models atm)
- Integrated custom GUI based on NanoVG (support multiple basic controls, theming, fonts...)
- GUI animations
- Input handling as event mode or immediate mode (onMouseAction() or isMouseButtonClicked())
- Entity Component System with decs

## Planned features

- Water rendering
- Network support
- Physics support
- Navigation support (recast & detour)
- Controller support
- more!

Some part of the code are old. They need to be updated:
 - Shaders sources
 - GUI (new theme system, clean drag and drop handling, clean controls code)
 - Models (write better loader and clean the code)
 - probably other parts...

## Build

You have to use [dub](https://code.dlang.org/download) to build the project.

Add this project as a dependency to your **dub.json**:

```json
"dependencies": {
    "evael": "~>x.x.x"
}
```

Documentation
===========

License
===========

Boost Software License - Version 1.0
