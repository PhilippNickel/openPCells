function parameters() end
function layout(cell)
    local ref, name, child
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 27, purpose = 0 } }), point.create(0, -150), point.create(500, 150))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 6, purpose = 0 } }), point.create(150, -2100), point.create(350, 0))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 1, purpose = 0 } }), point.create(-250, -1700), point.create(750, -700))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 5, purpose = 0 } }), point.create(-250, -2100), point.create(750, 0))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 27, purpose = 0 } }), point.create(0, -150), point.create(500, 150))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 6, purpose = 0 } }), point.create(150, 0), point.create(350, 2100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 1, purpose = 0 } }), point.create(-250, 700), point.create(750, 1700))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 4, purpose = 0 } }), point.create(-250, 0), point.create(750, 2100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 3, purpose = 0 } }), point.create(-250, 0), point.create(750, 2300))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, -2100), point.create(600, -1900))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, 1900), point.create(600, 2100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 1, purpose = 0 } }), point.create(0, 2300), point.create(500, 2500))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 5, purpose = 0 } }), point.create(-50, 2250), point.create(550, 2550))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(0, 2300), point.create(500, 2500))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(200, 2350), point.create(300, 2450))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(0, 2300), point.create(500, 2500))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 3, purpose = 0 } }), point.create(-50, 2250), point.create(550, 2550))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 1, purpose = 0 } }), point.create(0, -2500), point.create(500, -2300))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 4, purpose = 0 } }), point.create(-50, -2550), point.create(550, -2250))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(0, -2500), point.create(500, -2300))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(200, -2450), point.create(300, -2350))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(0, -2500), point.create(500, -2300))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 27, purpose = 0 } }), point.create(0, -150), point.create(500, 150))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(200, -2050), point.create(300, -1950))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(200, 1950), point.create(300, 2050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(150, -2100), point.create(350, -1900))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(150, 1900), point.create(350, 2100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 27, purpose = 0 } }), point.create(-100, -2150), point.create(600, -1850))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 27, purpose = 0 } }), point.create(-100, 1850), point.create(600, 2150))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(-50, 1250), point.create(50, 1350))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(-50, 1550), point.create(50, 1650))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, 1200), point.create(100, 1700))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, 1700), point.create(100, 1900))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(-50, -1650), point.create(50, -1550))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(-50, -1350), point.create(50, -1250))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, -1700), point.create(100, -1200))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, -1900), point.create(100, -1700))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(450, 1250), point.create(550, 1350))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(450, 1550), point.create(550, 1650))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(400, 1200), point.create(600, 1700))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(400, 1700), point.create(600, 1900))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(450, -1650), point.create(550, -1550))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 7, purpose = 0 } }), point.create(450, -1350), point.create(550, -1250))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(400, -1700), point.create(600, -1200))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(400, -1900), point.create(600, -1700))
end