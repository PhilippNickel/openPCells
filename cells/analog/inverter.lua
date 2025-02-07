function parameters()
    pcell.add_parameters(
        { "fingers(Number of Fingers)",                                 2 },
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "oxidetype(Oxide Type)",                                      1 },
        { "gatemarker(Gate Marker Index)",                              1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",                     1 },
        { "nvthtype(NMOS Threshold Voltage Type)",                      1 },
        { "pmosflippedwell(PMOS Flipped Well) ",                        false },
        { "nmosflippedwell(NMOS Flipped Well)",                         false },
        { "glength(Gate Length)",                                       tech.get_dimension("Minimum Gate Length") },
        { "gspace(Gate Spacing)",                                       tech.get_dimension("Minimum Gate XSpace") },
        { "gatemetal",                                                  1 },
        { "sdwidth(Source/Drain Metal Width)",                          tech.get_dimension("Minimum M1 Width"), posvals = even() },
        { "gstwidth(Gate Metal Width)",                                 tech.get_dimension("Minimum M1 Width") },
        { "powerwidth(Power Rail Metal Width)",                         tech.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",                               tech.get_dimension("Minimum M1 Space") },
        { "separation(nMOS/pMOS Separation)",                           0 },
        { "drawleftdummy",  false },
        { "drawrightdummy",  false },
        { "outputmetal", 2, posvals = interval(2, inf) },
        { "dummycontheight", tech.get_dimension("Minimum M1 Width"), follow = "powerwidth" },
        { "shiftoutput", 0 },
        { "dummycontshift", 0 }
    )
end

function layout(inverter, _P)
    local xpitch = _P.gspace + _P.glength

    local gatecontactpos = util.fill_all_with(_P.fingers, "center")
    local contactpos = util.fill_odd_with(_P.fingers + 1, "fullpower", "full")
    if _P.drawleftdummy then
        table.insert(gatecontactpos, 1, "dummy")
        table.insert(contactpos, 1, "fullpower")
    end
    if _P.drawrightdummy then
        table.insert(gatecontactpos, "dummy")
        table.insert(contactpos, "fullpower")
    end

    local cmos = pcell.create_layout("basic/cmos", "cmos", {
        nvthtype = _P.nvthtype,
        pvthtype = _P.pvthtype,
        pmosflippedwell = _P.pmosflippedwell,
        nmosflippedwell = _P.nmosflippedwell,
        oxidetype = _P.oxidetype,
        gatemarker = _P.gatemarker,
        gatelength = _P.glength,
        gatespace = _P.gspace,
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
        powerwidth = _P.powerwidth,
        npowerspace = _P.powerspace,
        ppowerspace = _P.powerspace,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        gstwidth = _P.gstwidth,
        sdwidth = _P.sdwidth,
        separation = _P.separation,
        dummycontheight = _P.dummycontheight,
        dummycontshift = _P.dummycontshift,
    })
    inverter:merge_into(cmos)

    inverter:inherit_alignment_box(cmos)

    -- gate strap
    local dummyoffset = _P.drawleftdummy and 1 or 0
    if _P.fingers > 1 then
        if _P.gatemetal > 1 then
            geometry.viabltr(
                inverter, 1, _P.gatemetal,
                cmos:get_anchor(string.format("G%dbl", 1 + dummyoffset)),
                cmos:get_anchor(string.format("G%dtr", _P.fingers + dummyoffset))
            )
        else
            geometry.rectanglebltr(
                inverter, generics.metal(1),
                cmos:get_anchor(string.format("G%dbl", 1 + dummyoffset)),
                cmos:get_anchor(string.format("G%dtr", _P.fingers + dummyoffset))
            )
        end
    end

    -- signal transistors drain connections
    geometry.path_cshape(inverter, generics.metal(_P.outputmetal),
        cmos:get_anchor(string.format("pSD%dbr", 2 + dummyoffset)):translate(0, _P.sdwidth / 2),
        cmos:get_anchor(string.format("nSD%dtr", 2 + dummyoffset)):translate(0, -_P.sdwidth / 2),
        cmos:get_anchor(string.format("G%dcc", _P.fingers + dummyoffset)):translate(xpitch + _P.shiftoutput, 0),
        _P.sdwidth
    )

    for i = 2, _P.fingers + 1, 2 do
        geometry.viabltr(inverter, 1, _P.outputmetal,
            cmos:get_anchor(string.format("pSD%dbl", i + dummyoffset)),
            cmos:get_anchor(string.format("pSD%dtr", i + dummyoffset))
        )
        geometry.viabltr(inverter, 1, _P.outputmetal,
            cmos:get_anchor(string.format("nSD%dbl", i + dummyoffset)),
            cmos:get_anchor(string.format("nSD%dtr", i + dummyoffset))
        )
    end

    --[[
    -- anchors (Out Top/Bottom Left/Right center/inner/outer)
    --          ^      ^           ^               ^
    --    e.g.  O      T           L               c    -> OTLc
    gate:add_anchor("OTLc", harness:get_anchor(string.format("pSD%dcc", 1)))
    gate:add_anchor("OBLc", harness:get_anchor(string.format("nSD%dcc", 1)))
    gate:add_anchor("OTRc", harness:get_anchor(string.format("pSD%dcc", _P.fingers + 1)))
    gate:add_anchor("OBRc", harness:get_anchor(string.format("nSD%dcc", _P.fingers + 1)))
    gate:add_anchor("OTLi", harness:get_anchor(string.format("pSD%dbc", 1)))
    gate:add_anchor("OBLi", harness:get_anchor(string.format("nSD%dtc", 1)))
    gate:add_anchor("OTRi", harness:get_anchor(string.format("pSD%dbc", _P.fingers + 1)))
    gate:add_anchor("OBRi", harness:get_anchor(string.format("nSD%dtc", _P.fingers + 1)))
    gate:add_anchor("OTLo", harness:get_anchor(string.format("pSD%dtc", 1)))
    gate:add_anchor("OBLo", harness:get_anchor(string.format("nSD%dbc", 1)))
    gate:add_anchor("OTRo", harness:get_anchor(string.format("pSD%dtc", _P.fingers + 1)))
    gate:add_anchor("OBRo", harness:get_anchor(string.format("nSD%dbc", _P.fingers + 1)))

    -- ports
    if _P.swapoddcorrectiongate then
        gate:add_port("I", generics.metalport(1), harness:get_anchor("G2cc"))
    else
        gate:add_port("I", generics.metalport(1), harness:get_anchor("G1cc"))
    end
    --if _P.connectoutput then
        gate:add_port("O", generics.metalport(1), harness:get_anchor(string.format("G%dcc", _P.fingers)):translate(xpitch + _P.shiftoutput, 0))
    --end
    gate:add_port("VDD", generics.metalport(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metalport(1), harness:get_anchor("bottom"))
    --]]
end
