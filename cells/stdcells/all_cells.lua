function parameters()
end

function layout(main, _P)
    local _1_inv_gate_ref = pcell.create_layout("stdcells/1_inv_gate", "1_inv_gate")
    main:add_child(_1_inv_gate_ref, "1_inv_gate")
    local _21_gate_ref = pcell.create_layout("stdcells/21_gate", "21_gate")
    main:add_child(_21_gate_ref, "21_gate")
    local _221_gate_ref = pcell.create_layout("stdcells/221_gate", "221_gate")
    main:add_child(_221_gate_ref, "221_gate")
    local _22_gate_ref = pcell.create_layout("stdcells/22_gate", "22_gate")
    main:add_child(_22_gate_ref, "22_gate")
    local and_gate_ref = pcell.create_layout("stdcells/and_gate", "and_gate")
    main:add_child(and_gate_ref, "and_gate")
    local buf_ref = pcell.create_layout("stdcells/buf", "buf")
    main:add_child(buf_ref, "buf")
    local cinv_ref = pcell.create_layout("stdcells/cinv", "cinv")
    main:add_child(cinv_ref, "cinv")
    local colstop_ref = pcell.create_layout("stdcells/colstop", "colstop")
    main:add_child(colstop_ref, "colstop")
    local dffnq_ref = pcell.create_layout("stdcells/dffnq", "dffnq")
    main:add_child(dffnq_ref, "dffnq")
    local dffpq_ref = pcell.create_layout("stdcells/dffpq", "dffpq")
    main:add_child(dffpq_ref, "dffpq")
    local dffprq_ref = pcell.create_layout("stdcells/dffprq", "dffprq")
    main:add_child(dffprq_ref, "dffprq")
    local endcell_ref = pcell.create_layout("stdcells/endcell", "endcell")
    main:add_child(endcell_ref, "endcell")
    local generic2bit_ref = pcell.create_layout("stdcells/generic2bit", "generic2bit")
    main:add_child(generic2bit_ref, "generic2bit")
    local half_adder_ref = pcell.create_layout("stdcells/half_adder", "half_adder")
    main:add_child(half_adder_ref, "half_adder")
    local harness_ref = pcell.create_layout("stdcells/harness", "harness")
    main:add_child(harness_ref, "harness")
    local isogate_ref = pcell.create_layout("stdcells/isogate", "isogate")
    main:add_child(isogate_ref, "isogate")
    local latch_cell_ref = pcell.create_layout("stdcells/latch_cell", "latch_cell")
    main:add_child(latch_cell_ref, "latch_cell")
    local latch_ref = pcell.create_layout("stdcells/latch", "latch")
    main:add_child(latch_ref, "latch")
    local mux_ref = pcell.create_layout("stdcells/mux", "mux")
    main:add_child(mux_ref, "mux")
    local nand_gate_ref = pcell.create_layout("stdcells/nand_gate", "nand_gate")
    main:add_child(nand_gate_ref, "nand_gate")
    local nor_gate_ref = pcell.create_layout("stdcells/nor_gate", "nor_gate")
    main:add_child(nor_gate_ref, "nor_gate")
    local not_gate_ref = pcell.create_layout("stdcells/not_gate", "not_gate")
    main:add_child(not_gate_ref, "not_gate")
    local or_gate_ref = pcell.create_layout("stdcells/or_gate", "or_gate")
    main:add_child(or_gate_ref, "or_gate")
    local register_ref = pcell.create_layout("stdcells/register", "register")
    main:add_child(register_ref, "register")
    --local rowstop_ref = pcell.create_layout("stdcells/rowstop", "rowstop")
    --main:add_child(rowstop_ref, "rowstop")
    local shiftregister_ref = pcell.create_layout("stdcells/shiftregister", "shiftregister")
    main:add_child(shiftregister_ref, "shiftregister")
    local tbuf_ref = pcell.create_layout("stdcells/tbuf", "tbuf")
    main:add_child(tbuf_ref, "tbuf")
    local test_ref = pcell.create_layout("stdcells/test", "test")
    main:add_child(test_ref, "test")
    local tgate_ref = pcell.create_layout("stdcells/tgate", "tgate")
    main:add_child(tgate_ref, "tgate")
    local xor_gate_ref = pcell.create_layout("stdcells/xor_gate", "xor_gate")
    main:add_child(xor_gate_ref, "xor_gate")
end
