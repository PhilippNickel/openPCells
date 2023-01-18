-- multigate e.g cascaded multi input base gate with one gate kind
-- e.g. and_gate and 3 inputs
--
-- a1----AND 
--       AND----AND
-- a2----AND    AND
--              AND-----o1
-- a3-----------AND
--
function parameters()
    pcell.add_parameters(
        { "gate", "and_gate" },
        { "num_inputs", 3 },
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base");

    local nandref = pcell.create_layout("stdcells/nand_gate", "nand")
    local nand1 = gate:add_child(nandref, "nand1")
    local nand2 = gate:add_child(nandref, "nand2")
    local nand3 = gate:add_child(nandref, "nand3")

    local notref = pcell.create_layout("stdcells/not_gate", "not")
    local not1 = gate:add_child(notref, "not1")

    local isoref = pcell.create_layout("stdcells/isogate", "iso")
    local iso1 = gate:add_child(isoref, "iso1")
    local iso2 = gate:add_child(isoref, "iso2")
    local iso3 = gate:add_child(isoref, "iso3")

    iso1:move_anchor("left", nand1:get_anchor("right"))
    not1:move_anchor("left", iso1:get_anchor("right"))
    iso2:move_anchor("left", not1:get_anchor("right"))
    nand2:move_anchor("left", iso2:get_anchor("right"))
    iso3:move_anchor("left", nand2:get_anchor("right"))
    nand3:move_anchor("left", iso3:get_anchor("right"))

    gate:inherit_alignment_box(nand1)
    gate:inherit_alignment_box(nand3)

    -- draw connections
    geometry.path(gate, generics.metal(2), 
    geometry.path_points_yx(nand1:get_anchor("O"), {
        nand3:get_anchor("A")
    }), 
    bp.sdwidth)
    geometry.viabltr(gate, 1, 2, 
        nand1:get_anchor("O"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        nand1:get_anchor("O"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        nand3:get_anchor("A"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        nand3:get_anchor("A"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )

    geometry.path(gate, generics.metal(2), 
    geometry.path_points_xy(nand1:get_anchor("B"), {
        not1:get_anchor("I")
    }), 
    bp.sdwidth)
    geometry.viabltr(gate, 1, 2, 
        nand1:get_anchor("B"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        nand1:get_anchor("B"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        not1:get_anchor("I"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        not1:get_anchor("I"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )

    geometry.path(gate, generics.metal(2), 
    geometry.path_points_xy(not1:get_anchor("O"), {
        nand2:get_anchor("B")
    }), 
    bp.sdwidth)
    geometry.viabltr(gate, 1, 2, 
        not1:get_anchor("O"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        not1:get_anchor("O"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )
    geometry.viabltr(gate, 1, 2, 
        nand2:get_anchor("B"):translate(-bp.sdwidth / 2, -bp.sdwidth / 2),
        nand2:get_anchor("B"):translate( bp.sdwidth / 2,  bp.sdwidth / 2)
    )

    geometry.path(gate, generics.metal(1), 
    geometry.path_points_xy(nand2:get_anchor("O"), {
        nand3:get_anchor("B")
    }), 
    bp.sdwidth)

    --draw ports
    gate:add_port("IN", generics.metalport(1), nand2:get_anchor("A"))
    gate:add_port("IP", generics.metalport(1), nand1:get_anchor("A"))
    gate:add_port("SEL", generics.metalport(1), nand1:get_anchor("B"))
    gate:add_port("O", generics.metalport(1), nand3:get_anchor("O"))
    gate:add_port("VDD", generics.metalport(1), not1:get_anchor("VDD"))
    gate:add_port("VSS", generics.metalport(1), not1:get_anchor("VSS"))
end
