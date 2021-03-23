--[[
This file is part of the openPCells project.

This module provides a simple argument parser for the main program
--]]

local function _advance(state, num)
    num = num or 1
    state.i = state.i + num
end

local function _next_arg(args, state)
    _advance(state)
    return args[state.i]
end

local function _consume_until_hyphen(args, state)
    local t = {}
    while true do
        local arg = args[state.i + 1]
        if not arg or string.match(arg, "^-") then break end
        table.insert(t, arg)
        _advance(state)
    end
    return table.concat(t, " ")
end

local function _parse_key_value_pairs(str)
    local t = {}
    for k, v in string.gmatch(str, "(%w+)%s*=%s*(%S+)") do
        t[k] = v
    end
    return t
end

local function _display_help(self)
    local displaywidth <const> = 80
    local optwidth = 0
    for _, opt in ipairs(self.optionsdef) do
        if opt.short and not opt.long then
            optwidth = math.max(optwidth, string.len(string.format("%s", opt.short)))
        elseif not opt.short and opt.long then
            optwidth = math.max(optwidth, string.len(string.format("%s", opt.long)))
        else
            optwidth = math.max(optwidth, string.len(string.format("%s,%s", opt.short, opt.long)))
        end
    end
    local fmt = string.format("    %%-%ds    %%s", optwidth)
    print("openPCells generator")
    for _, opt in ipairs(self.optionsdef) do
        if opt.issection then
            print(opt.name)
        else
            local cmdstr
            if opt.short and not opt.long then
                cmdstr = string.format("%s", opt.short)
            elseif not opt.short and opt.long then
                cmdstr = string.format("%s", opt.long)
            else
                cmdstr = string.format("%s,%s", opt.short, opt.long)
            end

            -- break long help strings into lines
            local helpstrtab = {}
            local line = {}
            local linewidth = 0
            for word in string.gmatch(opt.help, "(%S+)") do
                local width = string.len(word)
                linewidth = linewidth + width
                if linewidth > displaywidth then
                    table.insert(helpstrtab, table.concat(line, " "))
                    line = {}
                    linewidth = 0
                end
                table.insert(line, word)
            end
            -- insert remaining part of the line
            table.insert(helpstrtab, table.concat(line, " "))

            local helpstr = table.concat(helpstrtab, string.format("\n%s", string.rep(" ", optwidth + 8))) -- +8 to compensate for spaces in format string

            print(string.format(fmt, cmdstr, helpstr))
        end
    end
    os.exit(0)
end

local function _display_version(self)
    print("openPCells (opc) 0.1.0")
    print("Copyright 2020-2021 Patrick Kurth")
    os.exit(0)
end

--local positional = _consumer_table_func("cellargs")
local positional = function(self, res, args)
    table.insert(res["cellargs"], args[self.state.i])
end

local function _get_action(self, args)
    local name = self.nameresolve[args[self.state.i]]
    local action = self.actions[name]
    if not action then
        if string.match(args[self.state.i], "^-") then
            error(string.format("commandline arguments: unknown option '%s'", args[self.state.i]))
        end
        return positional
    else
        return action
    end
end

local meta = {}
meta.__index = meta

local function _load_options(options)
    if not options then
        error("no commandline options filename name given")
    end
    local filename = string.format("%s/%s.lua", _get_opc_home(), options)
    local chunkname = string.format("@%s", options)

    local reader, msg = _get_reader(filename)
    if not reader then
        error(msg)
    end

    local env = {
        switch = function(t)
            t.func = function(self, res, args)
                res[t.name] = true
            end
            return t
        end,
        store = function(t)
            t.func = function(self, res, args)
                res[t.name] = _next_arg(args, self.state)
            end
            return t
        end,
        store_multiple = function(t)
            t.func = function(self, res, args)
                if not res[t.name] then res[t.name] = {} end
                table.insert(res[t.name], _next_arg(args, self.state))
            end
            return t
        end,
        consumer_string = function(t)
            t.func = function(self, res, args)
                res[t.name] = _consume_until_hyphen(args, self.state)
            end
            return t
        end,
        consumer_table = function(t)
            t.func = function(self, res, args)
                res[t.name] = _parse_key_value_pairs(_consume_until_hyphen(args, self.state))
            end
            return t
        end,
        section = function(name)
            return { issection = true, name = name }
        end
    }
    return _generic_load(reader, chunkname, nil, nil, env)
end

function meta.load_options(self, options)
    self.optionsdef = _load_options(options)
    table.insert(self.optionsdef, 1, { name = "help", short = "-h", long = "--help", help = "display this help and exit", func = _display_help })
    table.insert(self.optionsdef, 2, { name = "version", short = "-v", long = "--version", help = "display version and exit", func = _display_version })
    for key, opt in ipairs(self.optionsdef) do
        if not opt.issection then
            if opt.short then
                self.nameresolve[opt.short] = opt.name
            end
            if opt.long then
                self.nameresolve[opt.long] = opt.name
            end
            self.actions[opt.name] = opt.func
        end
    end
end

function meta.parse(self, args)
    while self.state.i <= #args do
        local action = _get_action(self, args)
        action(self, self.res, args)
        _advance(self.state)
    end
    -- split key=value pairs
    local cellargs = {}
    for k, v in string.gmatch(table.concat(self.res.cellargs, " "), "([%w/._]+)%s*=%s*(%S+)") do
        cellargs[k] = v
    end
    self.res.cellargs = cellargs
    return self.res
end

function meta.set_option(self, arg, value)
    local action = self.actions[arg]
end

local self = {
    state = { i = 1 },
    actions = {},
    nameresolve = {},
    res = { cellargs = {} }
}
setmetatable(self, meta)
return self
