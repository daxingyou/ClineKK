
luaCallFun = nil
javaClassName = nil

if device.platform == "ios" then
    luaCallFun = require("cocos.cocos2d.luaoc")
elseif device.platform == "android" then
    luaCallFun = require("cocos.cocos2d.luaj")
    javaClassName = "org.cocos2dx.lua.AppActivity"
end

require("platform.RegisterFunction")
require("platform.UnitedPlatform")


registerLuaFunctions();
