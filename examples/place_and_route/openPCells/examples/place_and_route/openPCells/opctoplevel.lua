function parameters() end
function layout(cell)
    local ref, name, child
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(2950, -50), point.create(3050, 50))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(2900, -100), point.create(3100, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(2900, -100), point.create(3100, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(-50, -50), point.create(50, 50))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, -100), point.create(100, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(-100, -100), point.create(100, 100))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(3000, 0), point.create(3000, 400), point.create(0, 400), point.create(0, 0), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(2999950, -50), point.create(3000050, 50))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(2999900, -100), point.create(3000100, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(2999900, -100), point.create(3000100, 100))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(3000000, 0), point.create(3000000, 400), point.create(2997000, 400), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(2996950, 350), point.create(2997050, 450))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(2996900, 300), point.create(2997100, 500))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(2996900, 300), point.create(2997100, 500))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(-50, 1919950), point.create(50, 1920050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, 1919900), point.create(100, 1920100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(-100, 1919900), point.create(100, 1920100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(-50, 1916350), point.create(50, 1916450))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, 1916300), point.create(100, 1916500))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(-100, 1916300), point.create(100, 1916500))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(0, 1920000), point.create(0, 1916400), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(2999950, 1919950), point.create(3000050, 1920050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(2999900, 1919900), point.create(3000100, 1920100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(2999900, 1919900), point.create(3000100, 1920100))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(3000000, 1920000), point.create(3000000, 1919600), point.create(2994000, 1919600), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(2993950, 1919550), point.create(2994050, 1919650))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(2993900, 1919500), point.create(2994100, 1919700))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(2993900, 1919500), point.create(2994100, 1919700))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(-50, 3839950), point.create(50, 3840050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(-100, 3839900), point.create(100, 3840100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(-100, 3839900), point.create(100, 3840100))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(0, 3840000), point.create(0, 3836400), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(3450, -50), point.create(3550, 50))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(3400, -100), point.create(3600, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(3400, -100), point.create(3600, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(450, -50), point.create(550, 50))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(400, -100), point.create(600, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(400, -100), point.create(600, 100))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(3500, 0), point.create(3500, -400), point.create(2500, -400), point.create(2500, 0), point.create(500, 0), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(3249950, -50), point.create(3250050, 50))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(3249900, -100), point.create(3250100, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(3249900, -100), point.create(3250100, 100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(3246950, -450), point.create(3247050, -350))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(3246900, -500), point.create(3247100, -300))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(3246900, -500), point.create(3247100, -300))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(3250000, 0), point.create(3250000, -400), point.create(3247000, -400), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(3249950, 1919950), point.create(3250050, 1920050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(3249900, 1919900), point.create(3250100, 1920100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(3249900, 1919900), point.create(3250100, 1920100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(3249950, 1915950), point.create(3250050, 1916050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(3249900, 1915900), point.create(3250100, 1916100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(3249900, 1915900), point.create(3250100, 1916100))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(3250000, 1920000), point.create(3250000, 1916000), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(249950, 1919950), point.create(250050, 1920050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(249900, 1919900), point.create(250100, 1920100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(249900, 1919900), point.create(250100, 1920100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(255950, 1919950), point.create(256050, 1920050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(255900, 1919900), point.create(256100, 1920100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(255900, 1919900), point.create(256100, 1920100))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(250000, 1920000), point.create(250000, 1920400), point.create(256000, 1920400), point.create(256000, 1920000), }, 200)
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 9, purpose = 0 } }), point.create(249950, 3839950), point.create(250050, 3840050))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 8, purpose = 0 } }), point.create(249900, 3839900), point.create(250100, 3840100))
    geometry.rectanglebltr(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), point.create(249900, 3839900), point.create(250100, 3840100))
    geometry.path(cell, generics.premapped(nil, { gds = { layer = 10, purpose = 0 } }), { point.create(250000, 3840000), point.create(250000, 3836800), }, 200)
    ref = pcell.create_layout("examples/place_and_route/openPCells/not_gate")
    child = cell:add_child(name, "not_gate")
    ref = pcell.create_layout("examples/place_and_route/openPCells/isogate")
    child = cell:add_child(name, "isogate")
    child:translate(750, 0)
    child = cell:add_child(name, "isogate")
    child:translate(1250, 0)
    child = cell:add_child(name, "isogate")
    child:translate(1750, 0)
    child = cell:add_child(name, "isogate")
    child:translate(2250, 0)
    child = cell:add_child(name, "not_gate")
    child:translate(3000, 0)
    child = cell:add_child(name, "isogate")
    child:translate(3750, 0)
    child = cell:add_child(name, "isogate")
    child:translate(4250, 0)
    child = cell:add_child(name, "isogate")
    child:translate(4750, 0)
    child = cell:add_child(name, "isogate")
    child:translate(5250, 0)
    child = cell:add_child(name, "not_gate")
    child:translate(6000, 0)
    child = cell:add_child(name, "not_gate")
    child:mirror_at_xaxis()
    child:translate(0, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(750, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(1250, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(1750, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(2250, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(2750, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(3250, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(3750, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(4250, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(4750, 4800)
    child = cell:add_child(name, "isogate")
    child:mirror_at_xaxis()
    child:translate(5250, 4800)
    child = cell:add_child(name, "not_gate")
    child:mirror_at_xaxis()
    child:translate(6000, 4800)
    child = cell:add_child(name, "not_gate")
    child:translate(0, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(750, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(1250, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(1750, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(2250, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(2750, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(3250, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(3750, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(4250, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(4750, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(5250, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(5750, 9600)
    child = cell:add_child(name, "isogate")
    child:translate(6250, 9600)
end