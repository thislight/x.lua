#!/usr/bin/env lua

-- Copyright (C) 2020 thisLight
-- 
-- This file is part of x.lua.
-- 
-- x.lua is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
-- 
-- x.lua is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with x.lua.  If not, see <http://www.gnu.org/licenses/>.
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
    -- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    -- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    -- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    -- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    -- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    -- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
        elseif value == '--help' then
            flags.show_help = true
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
    elseif flags.show_help then
        print("x.lua \t\t\t start REPL (by lua-repl)")
        print("x.lua <lua_file_path> \t run a script with x.lua's features")
        print("x.lua --show-debug-info  show debug infomation")
        print("x.lua --help \t\t print this message")
    else
        repl(flags)
    end
end

main(table.pack(...))
