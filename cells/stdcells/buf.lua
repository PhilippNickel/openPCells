function parameters()
    pcell.add_parameters(
        { "ifingers", 1 },
        { "ofingers", 1 },
        { "shiftinput1", 0 },
        { "shiftinput2", 0 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")

    local iinv = pcell.create_layout("stdcells/not_gate", "iinv", { 
        fingers = _P.ifingers, 
        shiftinput = _P.shiftinput1, 
        shiftoutput = bp.glength / 2 + bp.gspace / 2 
    })

    local oinv = pcell.create_layout("stdcells/not_gate", "oinv", { 
        fingers = _P.ofingers, 
        shiftinput = _P.shiftinput2, 
        shiftoutput = bp.glength / 2 + bp.gspace / 2 
    }):move_anchor("left", iinv:get_anchor("right"))
    gate:merge_into(iinv)
    gate:merge_into(oinv)

    -- draw connection
    local ishift = _P.ifingers % 2 == 0 and 0 or 1
    geometry.path(gate, generics.metal(1), 
        geometry.path_points_yx(iinv:get_anchor("O"), {
        oinv:get_anchor("I"),
    }), bp.sdwidth)

    gate:set_alignment_box(
        iinv:get_anchor("bottomleft"),
        oinv:get_anchor("topright")
    )

    -- anchors
    gate:add_anchor("in", iinv:get_anchor("I"))
    gate:add_anchor("iout", iinv:get_anchor("O"))
    gate:add_anchor("bout", oinv:get_anchor("O"))

    gate:add_anchor("OTR", oinv:get_anchor("OTRc"))
    gate:add_anchor("OBR", oinv:get_anchor("OBRc"))

    -- ports
    gate:add_port("I", generics.metalport(1), iinv:get_anchor("I"))
    gate:add_port("O", generics.metalport(1), oinv:get_anchor("O"))
    gate:add_port("VDD", generics.metalport(1), oinv:get_anchor("VDD"))
    gate:add_port("VSS", generics.metalport(1), oinv:get_anchor("VSS"))
end
