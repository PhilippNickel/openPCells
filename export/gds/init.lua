local M = {}

local __libname = "opclib"
local __textmode = false

local __userunit = 0.001
local __databaseunit = 1e-9

local __labelsize = 1

local recordtypes = gdstypetable.recordtypes
local datatypes = gdstypetable.datatypes

local function _number_to_gdsfloat(num, width)
    local data = {}
    if num == 0 then
        for i = 1, width do
            data[i] = 0x00
        end
        return data
    end
    local sign = false
    if num < 0.0 then
        sign = true
        num = -num
    end
    local exp = 0
    while num >= 1 do
        num = num / 16
        exp = exp + 1
    end
    while num < 0.0625 do
        num = num * 16
        exp = exp - 1
    end
    if sign then
        data[1] = 0x80 + ((exp + 64) & 0x7f)
    else
        data[1] = 0x00 + ((exp + 64) & 0x7f)
    end
    for i = 2, width do
        local int, frac = math.modf(num * 256)
        num = frac
        data[i] = int
    end
    return data
end

local datatable = {
    [datatypes.NONE] = nil,
    [datatypes.BIT_ARRAY] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(binarylib.split_in_bytes(num, 2)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.TWO_BYTE_INTEGER] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(binarylib.split_in_bytes(num, 2)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.FOUR_BYTE_INTEGER] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(binarylib.split_in_bytes(num, 4)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.FOUR_BYTE_REAL] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in _number_to_gdsfloat(num, 4) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.EIGHT_BYTE_REAL] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(_number_to_gdsfloat(num, 8)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.ASCII_STRING] = function(str) return { string.byte(str, 1, #str) } end,
}

local function _assemble_data(recordtype, datatype, content)
    local data = {
        0x00, 0x00, -- dummy bytes for length, will be filled later
        recordtype, datatype
    }
    local func = datatable[datatype]
    if func then
        for _, b in ipairs(func(content)) do
            table.insert(data, b)
        end
    end
    -- pad with final zero if #data is odd
    if #data % 2 ~= 0 then
        table.insert(data, 0x00)
    end
    local lenbytes = binarylib.split_in_bytes(#data, 2)
    data[1], data[2] = lenbytes[1], lenbytes[2]
    return data
end

local __content = bytebuffer.create()

local function _write_text_record(recordtype, datatype, content)
    if datatype == datatypes.NONE then
        table.insert(__content, string.format("%12s #(%4d)\n", recordtype.name, 4))
    else
        local data = _assemble_data(recordtype.code, datatype, content)
        local str
        if datatype == datatypes.NONE then
        elseif datatype == datatypes.BIT_ARRAY or
               datatype == datatypes.TWO_BYTE_INTEGER or
               datatype == datatypes.FOUR_BYTE_INTEGER or
               datatype == datatypes.FOUR_BYTE_REAL or
               datatype == datatypes.EIGHT_BYTE_REAL then
            str = table.concat(content, " ")
        elseif datatype == datatypes.ASCII_STRING then
            str = content
        end
        table.insert(__content, string.format("%12s #(%4d): { %s }\n", recordtype.name, #data, str))
    end
end

local function _write_raw_byte(datum)
    __content:append_byte(datum)
end
local function _write_raw_two_bytes(datum)
    __content:append_two_bytes(datum)
end
local function _write_raw_four_bytes(datum)
    __content:append_four_bytes(datum)
end
local function _write_binary_record(recordtype, datatype, content)
    local data = _assemble_data(recordtype.code, datatype, content)
    for _, datum in ipairs(data) do
        _write_raw_byte(datum)
    end
end
local function _write_nondata_four_bytes_record(recordtype)
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(recordtype)
    __content:append_byte(datatypes.NONE)
end

-- function "pointer" which (affected by __textmode option)
local _write_record = _write_binary_record

local function _unpack_points(pts)
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    local stream = {}
    for _, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        table.insert(stream, multiplier * x)
        table.insert(stream, multiplier * y)
    end
    return stream
end

-- public interface
function M.finalize()
    if __textmode then
        return table.concat(__content)
    else
        return __content:str()
    end
end

function M.get_extension()
    if __textmode then
        return "gdstext"
    else
        return "gds"
    end
end

function M.set_options(opt)
    if opt.libname then __libname = opt.libname end

    if opt.userunit then
        __userunit = tonumber(opt.userunit)
    end
    if opt.databaseunit then
        __databaseunit = tonumber(opt.databaseunit)
    end

    if opt.textmode then -- enable textmode
        __textmode = true
        _write_record = _write_text_record
        __content = {}
    end

    if opt.disablepath then
        M.write_path = nil
    end

    if opt.labelsize then
        __labelsize = opt.labelsize
    end
end

function M.get_layer(S)
    local lpp = S:get_lpp():get()
    return { layer = lpp.layer, purpose = lpp.purpose }
end

function M.at_begin()
    _write_record(recordtypes.HEADER, datatypes.TWO_BYTE_INTEGER, { 258 }) -- release 6.0
    local date = os.date("*t")
    _write_record(recordtypes.BGNLIB, datatypes.TWO_BYTE_INTEGER, { 
        date.year, date.month, date.day, date.hour, date.min, date.sec, -- last modification time
        date.year, date.month, date.day, date.hour, date.min, date.sec  -- last access time
    })
    _write_record(recordtypes.LIBNAME, datatypes.ASCII_STRING, __libname)
    _write_record(recordtypes.UNITS, datatypes.EIGHT_BYTE_REAL, { __userunit, __databaseunit })
end

function M.at_end()
    _write_record(recordtypes.ENDLIB, datatypes.NONE)
end

function M.at_begin_cell(cellname)
    local date = os.date("*t")
    _write_record(recordtypes.BGNSTR, datatypes.TWO_BYTE_INTEGER, { 
        date.year, date.month, date.day, date.hour, date.min, date.sec, -- last modification time
        date.year, date.month, date.day, date.hour, date.min, date.sec  -- last access time
    })
    _write_record(recordtypes.STRNAME, datatypes.ASCII_STRING, cellname)
end

function M.at_end_cell()
    _write_record(recordtypes.ENDSTR, datatypes.NONE)
end

function M.write_rectangle(layer, bl, tr)
    -- BOUNDARY
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x08)
    __content:append_byte(0x00)

    -- LAYER
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0d)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.layer)

    -- DATATYPE
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0e)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.purpose)

    -- XY
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    local blx, bly = bl:unwrap()
    local trx, try = tr:unwrap()
    blx = blx * multiplier
    bly = bly * multiplier
    trx = trx * multiplier
    try = try * multiplier
    __content:append_byte(0x00)
    __content:append_byte(0x2c)
    __content:append_byte(0x10) -- XY
    __content:append_byte(0x03) -- FOUR_BYTE_INTEGER
    __content:append_four_bytes(blx)
    __content:append_four_bytes(bly)
    __content:append_four_bytes(trx)
    __content:append_four_bytes(bly)
    __content:append_four_bytes(trx)
    __content:append_four_bytes(try)
    __content:append_four_bytes(blx)
    __content:append_four_bytes(try)
    __content:append_four_bytes(blx)
    __content:append_four_bytes(bly)

    -- ENDEL
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x11)
    __content:append_byte(0x00)
end

function M.write_polygon(layer, pts)
    -- BOUNDARY
    _write_raw_byte(0x00)
    _write_raw_byte(0x04)
    _write_raw_byte(0x08)
    _write_raw_byte(0x00)

    -- LAYER
    _write_raw_byte(0x00)
    _write_raw_byte(0x06)
    _write_raw_byte(0x0d)
    _write_raw_byte(0x02)
    _write_raw_two_bytes(layer.layer)

    -- DATATYPE
    _write_raw_byte(0x00)
    _write_raw_byte(0x06)
    _write_raw_byte(0x0e)
    _write_raw_byte(0x02)
    _write_raw_two_bytes(layer.purpose)

    local ptstream = _unpack_points(pts)
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    _write_nondata_four_bytes_record(0x11) -- ENDEL
end

function M.write_path(layer, pts, width, extension)
    _write_nondata_four_bytes_record(0x09) -- PATH
    _write_raw_byte(0x00)
    _write_raw_byte(0x06)
    _write_raw_byte(0x0d) -- LAYER
    _write_raw_byte(0x02) -- TWO_BYTE_INTEGER
    _write_raw_two_bytes(layer.layer)
    _write_raw_byte(0x00)
    _write_raw_byte(0x06)
    _write_raw_byte(0x0e) -- DATATYPE
    _write_raw_byte(0x02) -- TWO_BYTE_INTEGER
    _write_raw_two_bytes(layer.purpose)

    _write_raw_byte(0x00)
    _write_raw_byte(0x06)
    _write_raw_byte(0x21) -- PATHTYPE
    _write_raw_byte(0x02) -- TWO_BYTE_INTEGER
    _write_raw_byte(0x00)
    if extension == "round" then
        _write_raw_byte(0x01)
    elseif extension == "cap" then
        _write_raw_byte(0x02)
    elseif type(extension) == "table" then
        _write_raw_byte(0x04)
    else
        _write_raw_byte(0x00)
    end

    _write_raw_byte(0x00)
    _write_raw_byte(0x08)
    _write_raw_byte(0x0f) -- WIDTH
    _write_raw_byte(0x03) -- FOUR_BYTE_INTEGER
    _write_raw_four_bytes(width)
    -- these records have to come after WIDTH (at least for klayout, but they also are in this order in the GDS manual)
    if type(extension) == "table" then
        _write_record(recordtypes.BGNEXTN, datatypes.FOUR_BYTE_INTEGER, { extension[1] })
        _write_record(recordtypes.ENDEXTN, datatypes.FOUR_BYTE_INTEGER, { extension[2] })
    end
    local ptstream = _unpack_points(pts)
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    _write_nondata_four_bytes_record(0x11) -- ENDEL
end

function M.write_cell_reference(identifier, x, y, orientation)
    _write_nondata_four_bytes_record(0x0a) -- ENDEL
    _write_record(recordtypes.SNAME, datatypes.ASCII_STRING, identifier)
    if orientation == "fx" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "fy" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
    elseif orientation == "R180" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x0000 })
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "R90" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x0000 })
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 90 })
    end
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    _write_raw_byte(0x00)
    _write_raw_byte(0x0c)
    _write_raw_byte(0x10) -- XY
    _write_raw_byte(0x03) -- FOUR_BYTE_INTEGER
    _write_raw_four_bytes(x * multiplier)
    _write_raw_four_bytes(y * multiplier)

    _write_nondata_four_bytes_record(0x11) -- ENDEL
end

function M.write_cell_array(identifier, x, y, orientation, xrep, yrep, xpitch, ypitch)
    _write_record(recordtypes.AREF, datatypes.NONE)
    _write_record(recordtypes.SNAME, datatypes.ASCII_STRING, identifier)
    if orientation == "fx" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "fy" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
    elseif orientation == "R180" then
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    end
    _write_record(recordtypes.COLROW, datatypes.TWO_BYTE_INTEGER, { xrep, yrep })
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, 
        _unpack_points({ point.create(x, y), point.create(x + xrep * xpitch, y), point.create(x, y + yrep * ypitch) }))
    _write_record(recordtypes.ENDEL, datatypes.NONE)
end

function M.write_port(name, layer, where)
    _write_record(recordtypes.TEXT, datatypes.NONE)
    _write_record(recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(recordtypes.TEXTTYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose })
    _write_record(recordtypes.PRESENTATION, datatypes.BIT_ARRAY, { 0x0005 }) -- center:center presentation
    _write_record(recordtypes.MAG, datatypes.EIGHT_BYTE_REAL, { __labelsize * __databaseunit })
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, _unpack_points({ where }))
    _write_record(recordtypes.STRING, datatypes.ASCII_STRING, name)
    _write_record(recordtypes.ENDEL, datatypes.NONE)
end

return M
