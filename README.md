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
- Entity Component System with [decs](https://github.com/aldocd4/decs)

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

## Supported platforms

- Windows (tested)
- Linux?
- Android?

## Build

You have to use [dub](https://code.dlang.org/download) to build the project.

Add this project as a dependency to your **dub.json**:

```json
"dependencies": {
    "evael": "~>0.0.1"
}
```

## Disclaimer

Evael engine development is in an early stage, do not use it for production.


Documentation
===========

You can find tutorials on [this repository](https://github.com/evael-dev/evael-tutorials).

A base game template is provided [here](https://github.com/evael-dev/evael-game-template).

License
===========

Boost Software License - Version 1.0
