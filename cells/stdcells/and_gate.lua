function parameters()
    pcell.add_parameters(
        { "nandfingers", 1 },
        { "notfingers", 1 },
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") }
    )
end

function layout(gate, _P)
    local subgate = pcell.create_layout("stdcells/1_inv_gate", "and_gate", {
        subgate = "nand_gate",
        subgatefingers = _P.nandfingers,
        notfingers = _P.notfingers,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth
    })
    gate:exchange(subgate)
end
