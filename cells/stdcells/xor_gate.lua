--[[
    VDD ----*-----------------------*
            |                       |
            |                       |
          |-|                     |-|
    A ---o|                ~A ---o|
          |-|                     |-|
            |                       |
          |-|                     |-|
   ~B ---o|                 B ---o|
          |-|                     |-|
            |                       |
            *-----------------------*-------o A XOR B
            |                       |
          |-|                     |-|
   ~B ----|                 B ----|
          |-|                     |-|
            |                       |
          |-|                     |-|
   ~A ----|                 A ----|
          |-|                     |-|
            |                       |
            |                       |
    VSS ----*-----------------------*
--]]

function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.add_parameter("fingers", 1, { posvals = set(1) })
    pcell.add_parameter("shiftoutput", 0)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    -- inverter A
    pcell.push_overwrites("stdcells/base", { compact = false })
    local inva = pcell.create_layout("stdcells/not_gate", { inputpos = "lower", shiftoutput = xpitch / 2 })
    gate:merge_into_shallow(inva)
    pcell.pop_overwrites("stdcells/base")

    -- inverter B
    pcell.push_overwrites("stdcells/base", { connectoutput = false })
    local invb = pcell.create_layout("stdcells/not_gate", { inputpos = "upper" })
    invb:move_anchor("left", invb:get_anchor("right"))
    gate:merge_into_shallow(invb)
    pcell.pop_overwrites("stdcells/base")

    local block = object.create()

    local harness = pcell.create_layout("stdcells/harness", { 
        drawgatecontacts = true,
        gatecontactpos = { "lower", "center", "center", "upper", "center", "lower" },
        pcontactpos = { "power", "outer", "outer", "outer", nil, "power", "power" },
        ncontactpos = { "power", "power", nil, "inner", "outer", "outer", "power" },
    })
    harness:move_anchor("left", invb:get_anchor("right"))
    gate:merge_into_shallow(harness)

    -- gate contact metal blobs (DRC)
    geometry.rectanglebltr(block,generics.metal(1), 
        harness:get_anchor("G2cc"):translate(-bp.glength / 2, -bp.routingwidth / 2), 
        point.combine_12(harness:get_anchor("G2cc"), harness:get_anchor("G4cc")):translate(bp.glength / 2, bp.routingwidth / 2)
    )
    geometry.rectanglebltr(block, generics.metal(1), 
        point.combine_12(harness:get_anchor("G3cc"), harness:get_anchor("G2cc")):translate(-bp.glength / 2, -bp.routingwidth / 2),
        point.combine_12(harness:get_anchor("G3cc"), harness:get_anchor("G4cc")):translate( bp.glength / 2,  bp.routingwidth / 2)
    )

    -- short pmos
    geometry.rectanglebltr(block, generics.metal(1), 
        harness:get_anchor("pSDc2"):translate(0, -bp.sdwidth / 2), 
        harness:get_anchor("pSDc3"):translate(0,  bp.sdwidth / 2)
    )

    -- short nmos
    geometry.rectanglebltr(block, generics.metal(1), 
        harness:get_anchor("nSDc5"):translate(0, -bp.sdwidth / 2), 
        harness:get_anchor("nSDc6"):translate(0,  bp.sdwidth / 2)
    )

    -- place block
    for i = 1, _P.fingers do
        local shift = 4 * (i - 1) - (_P.fingers - 1)
        if i % 2 == 0 then
            --gate:merge_into_shallow(block:copy():flipx():translate(-shift * xpitch, 0))
            gate:merge_into_shallow(block:copy())
        else
            --gate:merge_into_shallow(block:copy():translate(-shift * xpitch, 0))
            gate:merge_into_shallow(block:copy())
        end
    end

    gate:inherit_alignment_box(inva)
    gate:inherit_alignment_box(harness)

    -- output connection
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        harness:get_anchor("pSDc4"), {
            point.combine_12(harness:get_anchor("pSDc4"), invb:get_anchor("OTRi")):translate(xpitch, bp.sdwidth / 2),
            harness:get_anchor("G6cc"):translate(xpitch, 0),
            0, -- toggle xy
            harness:get_anchor("nSDi4"):translate(0, -bp.sdwidth / 2)
        }), bp.sdwidth)

    -- B
    geometry.path(gate, generics.metal(2), {
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")),
        harness:get_anchor("G4cc")
        }, bp.sdwidth)
    -- not A
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        point.combine_12(inva:get_anchor("O"), harness:get_anchor("G1cc")), {
            invb:get_anchor("I"):translate(xpitch, 0),
            harness:get_anchor("G2cc"):translate(0, -bp.sdwidth / 2),
        }), bp.sdwidth)
    geometry.path(gate, generics.metal(1), geometry.path_points_xy(
        invb:get_anchor("OTRi"):translate(0, bp.sdwidth / 2), { 
            harness:get_anchor("G3cc"),
            0, -- toggle xy
            point.combine_12(harness:get_anchor("G2cc"), harness:get_anchor("G1cc")),
            invb:get_anchor("OBRi"):translate(0, -bp.sdwidth / 2)
        }), bp.sdwidth)
    geometry.path(gate, generics.metal(2), {
        inva:get_anchor("I"),
        harness:get_anchor("G1cc")
    }, bp.sdwidth)
    geometry.path(gate, generics.metal(2), geometry.path_points_yx(
        point.combine_12(invb:get_anchor("O"), inva:get_anchor("I")), {
            -bp.routingwidth - bp.routingspace,
            harness:get_anchor("G6cc")
        }), bp.sdwidth)
    geometry.path(gate, generics.metal(2), {
        harness:get_anchor("G2cc"),
        harness:get_anchor("G5cc"),
        }, bp.sdwidth)

    -- M1 -> M2 vias
    geometry.viabltr(gate, 1, 2,
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")):translate(-xpitch - bp.routingwidth / 2 - bp.routingspace, -bp.sdwidth / 2),
        point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")):translate( xpitch + bp.routingwidth / 2 + bp.routingspace,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        inva:get_anchor("I"):translate(-xpitch - bp.routingwidth / 2 - bp.routingspace, -bp.sdwidth / 2),
        inva:get_anchor("I"):translate( xpitch + bp.routingwidth / 2 + bp.routingspace,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        invb:get_anchor("I"):translate(-xpitch - bp.routingwidth / 2 - bp.routingspace, -bp.sdwidth / 2),
        invb:get_anchor("I"):translate( xpitch + bp.routingwidth / 2 + bp.routingspace,  bp.sdwidth / 2)
    )

    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G1cc"):translate(-xpitch - math.max(bp.glength, bp.routingwidth) / 2 - bp.routingspace, -bp.sdwidth / 2),
        harness:get_anchor("G1cc"):translate( xpitch + bp.routingwidth / 2 + bp.routingspace, bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G2cc"):translate(-math.max(bp.glength, bp.routingwidth) / 2, -bp.sdwidth / 2),
        harness:get_anchor("G2cc"):translate( math.max(bp.glength, bp.routingwidth) / 2,  bp.sdwidth / 2)
    )

    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G6cc"):translate(-bp.routingwidth / 2, -bp.routingwidth / 2),
        point.combine_12(harness:get_anchor("G6cc"), harness:get_anchor("G4cc")):translate( bp.routingwidth / 2,  bp.routingwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G5cc"):translate(-2 * xpitch + math.max(bp.glength, bp.routingwidth) / 2 + bp.routingspace, -bp.sdwidth / 2),
        harness:get_anchor("G5cc"):translate( 1 * xpitch - math.max(bp.glength, bp.routingwidth) / 2 - bp.routingspace,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2,
        harness:get_anchor("G4cc"):translate(-1 * xpitch + math.max(bp.glength, bp.routingwidth) / 2 + bp.routingspace, -bp.sdwidth / 2),
        harness:get_anchor("G4cc"):translate( 2 * xpitch - math.max(bp.glength, bp.routingwidth) / 2 - bp.routingspace,  bp.sdwidth / 2)
    )

    gate:add_port("A", generics.metal(1), inva:get_anchor("I"))
    gate:add_port("B", generics.metal(1), point.combine_12(inva:get_anchor("I"), invb:get_anchor("I")))
    gate:add_port("O", generics.metal(1), point.create(3 * xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metal(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metal(1), harness:get_anchor("bottom"))
end
