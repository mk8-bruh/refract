return { -- { density, refract, reflect }
    wall = {
        refract = false,
        reflect = false
    },
    metal = {
        refract = false,
        reflect = true
    },
    glass = {
        density = 2,
        refract = true,
        reflect = true
    }
}