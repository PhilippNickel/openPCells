function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")

    -- clock inverter/buffer
    local clockbuf = pcell.create_layout("stdcells/buf", "clockbuf")
    gate:merge_into(clockbuf)

    -- first clocked inverter
    local cinv1 = pcell.create_layout("stdcells/cinv", "cinv1"):move_anchor("left", clockbuf:get_anchor("right"))
    gate:merge_into(cinv1)

    -- intermediate inverter
    local inv = pcell.create_layout("stdcells/not_gate", "inv"):move_anchor("left", cinv1:get_anchor("right"))
    gate:merge_into(inv)
    
    -- second clocked inverter
    local cinv2 = pcell.create_layout("stdcells/cinv", "cinv2"):move_anchor("left", inv:get_anchor("right"))
    gate:merge_into(cinv2)

    -- draw connections
    geometry.path(gate, generics.metal(2), 
        geometry.path_points_yx(clockbuf:get_anchor("bout"), {
        cinv1:get_anchor("EP")
    }), bp.sdwidth)
    geometry.viabltr(gate, 1, 2, 
        clockbuf:get_anchor("bout"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        clockbuf:get_anchor("bout"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        cinv1:get_anchor("EP"):translate(-bp.glength / 2, -bp.sdwidth / 2),
        cinv1:get_anchor("EP"):translate( bp.glength / 2,  bp.sdwidth / 2)
    )
    geometry.path(gate, generics.metal(3), {
        clockbuf:get_anchor("iout"),
        cinv1:get_anchor("EP")
    }, bp.sdwidth)
    geometry.path(gate, generics.metal(2), {
        cinv1:get_anchor("EP"),
        point.combine_12(cinv1:get_anchor("EP"), cinv2:get_anchor("EN")),
        cinv2:get_anchor("EN")
    }, bp.sdwidth)
    --[[
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(cinv2:get_anchor("EN")))
    gate:merge_into(geometry.path(generics.metal(1), {
        cinv1:get_anchor("EN"),
        cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0),
        point.combine_12(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP")),
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), {
        point.combine_12(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP")),
        cinv2:get_anchor("EP"),
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(
        generics.via(1, 2), bp.sdwidth, bp.sdwidth
    ):translate(point.combine_12(cinv1:get_anchor("EN"):translate((bp.glength + bp.gspace) / 2, 0), cinv2:get_anchor("EP"))))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(cinv2:get_anchor("EP")))

    gate:merge_into(geometry.path(generics.metal(1), {
        cinv1:get_anchor("O"),
        inv:get_anchor("I")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), {
        inv:get_anchor("O"),
        cinv2:get_anchor("EP")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), {
        cinv2:get_anchor("O"),
        inv:get_anchor("I")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth):translate(cinv2:get_anchor("O")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(inv:get_anchor("I")))
    --]]

    -- ports
    gate:add_port("D", generics.metalport(1), inv:get_anchor("I"))
    gate:add_port("VDD", generics.metalport(1), inv:get_anchor("VDD"))
    gate:add_port("VSS", generics.metalport(1), inv:get_anchor("VSS"))
end
