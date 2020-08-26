# x.lua
Lua launcher with package redirecting support.

## Usage
### Basic
You may add `run` permission to x.lua for shorter call (`chmod +x x.lua`).
````
$ ./x.lua --help
x.lua                    start REPL (by lua-repl)
x.lua <lua_file_path>    run a script with x.lua's features
x.lua --show-debug-info  show debug infomation
x.lua --help             print this message
````

### REPL
x.lua made use of [lua-repl](https://github.com/hoelzro/lua-repl) for a pretty REPL. If you start REPL without lua-repl installed, x.lua will remind you.
You can install lua-repl by luarocks: `luarocks install luarepl`.

### Package Redirecting
x.lua can add a custom package searcher which redirect some specific package name to given path. Just add a file `.packages` like:
````
repl=/usr/local/lib/lua/5.3/repl/
luasocket=/usr/local/lib/lua/5.3/luasocket/
````
Then tell x.lua when start program:
````
$ x.lua some.lua --packages=.packages
````
In `some.lua`, require these package like:
````lua
require('@repl')
require('@luasocket/socket')
````
If you rename `.packages` to `.lua_packages`, you can call x.lua without `--packages` option.
````
$ x.lua some.lua
````

## License
GNU General Public License, version 3 or later.

    x.lua - Lua launcher with package redirecting support
    Copyright (C) 2020 thisLight
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

This project made use of some code from [lua-repl](https://github.com/hoelzro/lua-repl):

    Copyright (c) 2011-2015 Rob Hoelz <rob@hoelz.ro>
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

> You also should add the notice above from lua-repl if you include x.lua in your project.
