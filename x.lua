#!/usr/bin/env lua

local function do_warn(msg)
    if warn then
        warn(msg)
    elseif print then
        print("warning: " .. msg)
    else
        error(msg)
    end
end

local function make_package_file_searcher(packages_file_path)
    local handle, _ = io.open(packages_file_path)
    if handle then
        local package_list = {}
        local line_count = 0
        for l in handle:lines("l") do
            line_count = line_count + 1
            local name, path = string.match(l, "^(.+)%w*=%w*(.+)")
            if (not name) or (not path) then
                do_warn("could not accept line " .. line_count ..
                            " in .lua_packages: " .. l)
            else
                package_list[name] = path
            end
        end
        handle:close()
        return function(name)
            if string.sub(name, 1, 2) == '@' then
                local package_name, lasts = string.match(name, "^@(w+)(.*)")
                local package_path = package_list[package_name]
                if package_path then
                    return require(package_path .. lasts)
                else
                    return "could not found package " .. package_name ..
                               " in .lua_packages"
                end
            end
        end
    else
        return function(...) return nil end
    end
end

local function inject_searcher(t, packages_file_path)
    if io then
        table.insert(t, make_package_file_searcher(packages_file_path))
    end
end

local function string_startswith(s, prefix)
    return string.sub(s, 1, (#prefix) + 1) == prefix
end

local function repl(flags)
    -- most code of this function is copied from https://github.com/hoelzro/lua-repl/blob/master/rep.lua ,
    -- which is under a classic MIT/X11 license. So:
    --
    -- Copyright (c) 2011-2015 Rob Hoelz <rob@hoelz.ro>
    --
    -- Permission is hereby granted, free of charge, to any person obtaining a copy of
    -- this software and associated documentation files (the "Software"), to deal in
    -- the Software without restriction, including without limitation the rights to
    -- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    -- the Software, and to permit persons to whom the Software is furnished to do so,
    -- subject to the following conditions:
    --
    -- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    if not io then
        do_warn("io library does not exists, exit.")
    else
        local stat, repl = pcall(require, 'repl.console')
        if not stat then error "luarepl must be installed to use repl" end
        local rcfile_loaded = repl:loadplugin('rcfile')
        if not rcfile_loaded then
            local has_linenoise = pcall(require, 'linenoise')
            if has_linenoise then
                repl:loadplugin('linenoise')
            else
                pcall(repl.loadplugin, repl, 'rlwarp')
            end
            pcall(repl.loadplugin, repl, 'pretty_print')
            repl:loadplugin('history')
            repl:loadplugin('completion')
            repl:loadplugin('autoreturn')
        end
        print(_VERSION)
        inject_searcher(package.searchers, flags.packages_file)
        repl:run()
    end
end

local function run_script(flags)
    local script_path = flags.script
    inject_searcher(package.searchers, flags.packages_file)
    dofile(script_path)
end

local function main(args)
    local flags = {}
    for _, value in ipairs(args) do
        if string_startswith(value, "--packages=") then
            local packages_file_path = string.match(value, "--packages=(.*)")
            flags.packages_file = packages_file_path
        elseif value == '--show-debug-info' then
            flags.show_debug_info = true
        elseif (not string_startswith(value, "-")) then
            flags.script = value
        end
    end
    if not flags.packages_file then flags.packages_file = './.lua_packages' end
    if flags.script then
        run_script(flags)
    elseif flags.show_debug_info then
        print(_VERSION)
        print("Package List File: " .. flags.packages_file)
        print("Use Package List File: " ..
                  tostring(table.pack(io.open(flags.packages_file))[1]))
        print("luarepl: " .. tostring(pcall(require, 'repl')))
    else
        repl(flags)
    end
end

main(table.pack(...))
