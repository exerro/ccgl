
# Please note

This isn't under development at the moment and certainly isn't available for general use. The examples and wiki are more guidelines for my own development and how I want the API to look, and everything should be considered outdated as the codebase is likely far ahead of any docs or examples here. A few of the benchmarks do run though.

# CCGL

![CCGL Logo](https://i.imgur.com/1ZFZYhs.png)

CCGL is a graphics library for ComputerCraft/CC:Tweaked.

It aims to provide simple graphics capability with additional layers supporting
advanced 2D rendering (i.e. stackable affine transformations), 3D rendering (
both raytraced and raster based) and a custom language which compiles to optimised
Lua code and seamlessly interacts with the library.

It uses optimised structures and algorithms to achieve the very best performance,
even at maximum resolutions.

# Features

* RGB[A] colour support - built-in palette generation and mapping tools to use RGB
      colours for images
* Subpixel rendering - uses chars 128-159 to draw smaller pixels than usually allowed.
* Fast blit-to-term, letting you draw textures thousands of times per second.
* Polygon rasterisation - draw arbitrary (self-intersecting, concave) polygons.

# Developers

For documentation and examples, see the [wiki](https://github.com/exerro/ccgl/wiki).

# Screenshots

![Animated logo](https://i.imgur.com/xXTJvIg.gif)
![Triangles](https://i.imgur.com/TST864P.png)
![Colour wheel](https://i.imgur.com/VVnZWDY.png)
![HSV](https://i.imgur.com/CUTsuvq.png)
![UV](https://i.imgur.com/l6ebCaH.png)

# Future developments

* Flattened, compact storage loading/unloading.
* Shader parsing and compilation.
* Built in rendering pipelines for 2D and 3D graphics.
* `term` redirect support.
