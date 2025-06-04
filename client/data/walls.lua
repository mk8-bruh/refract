local light = require "data.light"
local material = require "data.material"
local textures = require "data.textures"

local walls = { -- { tint, thickness, texture, material, split[ light -> { reflect, refract } ] }
    { -- wall
        tint = {1, 1, 1},
        thickness = 0.1,
        texture = textures.wall,
        material = material.wall
    },
    { -- metal
        tint = {1, 1, 1},
        thickness = 0.1,
        texture = textures.metal,
        material = material.metal
    },
    { -- white
        tint = {1, 1, 1},
        thickness = 0.1,
        texture = textures.glass,
        material = material.glass
    },
    { -- red
        tint = {1, 0, 0},
        thickness = 0.1,
        texture = textures.glass,
        material = material.glass,
        split = {
            [light.white] = {
                refract = light.red,
                reflect = light.cyan
            },
            [light.green] = {
                reflect = light.green
            },
            [light.blue] = {
                reflect = light.blue
            },
            [light.yellow] = {
                refract = light.red,
                reflect = light.green
            },
            [light.cyan] = {
                reflect = light.cyan
            },
            [light.magenta] = {
                refract = light.red,
                reflect = light.blue
            }
        }
    },
    { -- green
        tint = {0, 1, 0},
        thickness = 0.1,
        texture = textures.glass,
        material = material.glass,
        split = {
            [light.white] = {
                refract = light.green,
                reflect = light.magenta
            },
            [light.red] = {
                reflect = light.red
            },
            [light.blue] = {
                reflect = light.blue
            },
            [light.yellow] = {
                refract = light.green,
                reflect = light.red
            },
            [light.cyan] = {
                refract = light.green,
                reflect = light.blue
            },
            [light.magenta] = {
                reflect = light.magenta
            }
        }
    },
    { -- blue
        tint = {0, 0, 1},
        thickness = 0.1,
        texture = textures.glass,
        material = material.glass,
        split = {
            [light.white] = {
                refract = light.blue,
                reflect = light.yellow
            },
            [light.red] = {
                reflect = light.red
            },
            [light.green] = {
                reflect = light.green
            },
            [light.yellow] = {
                reflect = light.yellow
            },
            [light.cyan] = {
                refract = light.blue,
                reflect = light.green
            },
            [light.magenta] = {
                refract = light.blue,
                reflect = light.red
            }
        }
    },
    { -- yellow
        tint = {1, 1, 0},
        thickness = 0.1,
        texture = textures.glass,
        material = material.glass,
        split = {
            [light.white] = {
                refract = light.yellow,
                reflect = light.blue
            },
            [light.red] = {
                refract = light.red
            },
            [light.green] = {
                refract = light.green
            },
            [light.blue] = {
                reflect = light.blue
            },
            [light.yellow] = {
                refract = light.yellow
            },
            [light.cyan] = {
                refract = light.green,
                reflect = light.blue
            },
            [light.magenta] = {
                refract = light.red,
                reflect = light.blue
            }
        }
    },
    { -- cyan
        tint = {0, 1, 1},
        thickness = 0.1,
        texture = textures.glass,
        material = material.glass,
        split = {
            [light.white] = {
                refract = light.cyan,
                reflect = light.red
            },
            [light.red] = {
                reflect = light.red
            },
            [light.green] = {
                refract = light.green
            },
            [light.blue] = {
                refract = light.blue
            },
            [light.yellow] = {
                refract = light.green,
                reflect = light.red
            },
            [light.cyan] = {
                refract = light.cyan
            },
            [light.magenta] = {
                refract = light.blue,
                reflect = light.red
            }
        }
    },
    { -- magenta
        tint = {1, 0, 1},
        thickness = 0.1,
        texture = textures.glass,
        material = material.glass,
        split = {
            [light.white] = {
                refract = light.magenta,
                reflect = light.green
            },
            [light.red] = {
                refract = light.red
            },
            [light.green] = {
                reflect = light.green
            },
            [light.blue] = {
                refract = light.blue
            },
            [light.yellow] = {
                refract = light.red,
                reflect = light.green
            },
            [light.cyan] = {
                refract = light.blue,
                reflect = light.green
            },
            [light.magenta] = {
                refract = light.magenta
            }
        }
    }
}
for i, wall in ipairs(walls) do
    wall.mask = i + 1
end

return walls