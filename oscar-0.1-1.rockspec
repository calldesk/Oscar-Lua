package = "Oscar"
version = "0.1-1"
source = {
   url = "git://github.com/sensout/Oscar-Lua"
}
description = {
   summary = "Oscar's lua client",
   detailed = [[
      This is a simple lua client for the Oscar REST api at sensout.com.
   ]],
   homepage = "http://oscar.sensout.com",
}
dependencies = {
   "lua >= 5.1",
   "luasec >= 0.5",
   "luasocket >= 3.0rc1-1",
   "luajson >= 1.3"
}
build = {
   type = "builtin",
   modules = {
      Oscar = "Oscar.lua"
   }
}