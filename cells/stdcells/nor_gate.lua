function parameters()
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("pwidth", 2 * tech.get_dimension("Minimum Gate Width"))
    pcell.add_parameter("nwidth", 2 * tech.get_dimension("Minimum Gate Width"))
    pcell.add_parameter("shiftoutput", 0)
end

function layout(gate, _P)
    local base = pcell.create_layout("stdcells/nand_nor_layout_base", "nor_gate", {
        fingers = _P.fingers,
        gatetype = "nor",
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        shiftoutput = _P.shiftoutput
    })
    gate:exchange(base)
end
