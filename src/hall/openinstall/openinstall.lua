
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local openinstall = class("openinstall")

local activityClassName = "org/cocos2dx/lua/AppActivity"
local openinstallClassName = "com/fm/openinstall/OpenInstall"

function openinstall:getInstall(s, callback)
	luaPrint("call getInstall start")
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local luaj = require "cocos.cocos2d.luaj"
		local args = {s, callback}
		local signs = "(II)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "getInstall", args, signs)
		if not ok then
			luaPrint("call getInstall fail"..ret)
		end
	end
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local args = {functionId = callback,time = s}
        local ok, ret = luaoc.callStaticMethod("LuaOpenInstallBridge","getInstall",args)
        if not ok then
            luaPrint("luaoc getInstall error:"..ret)
        end
    end
end


function openinstall:registerWakeupHandler(callback)
	luaPrint("call registerWakeupHandler start")
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local luaj = require "cocos.cocos2d.luaj"
		local args = {callback}
		local signs = "(I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "registerWakeupCallback", args, signs)
		if not ok then
			luaPrint("call registerWakeupHandler fail"..ret)
		end
	end
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local args = {functionId = callback}
        local ok, ret = luaoc.callStaticMethod("LuaOpenInstallBridge","registerWakeUpHandler",args)
        if not ok then
            luaPrint("luaoc registerWakeUpHandler error:"..ret)
        end
    end
end

function openinstall:reportRegister()
	luaPrint("call reportRegister start")
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local luaj = require "cocos.cocos2d.luaj"
		local args = {}
		local signs = "()V"
		local ok,ret = luaj.callStaticMethod(openinstallClassName, "reportRegister", args, signs)
		if not ok then
            luaPrint("call reportRegister fail"..ret)
		end
	end
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local ok, ret = luaoc.callStaticMethod("LuaOpenInstallBridge","reportRegister")
        if not ok then
            luaPrint("luaoc reportRegister error:"..ret)
        end
    end
end

function openinstall:reportEffectPoint(pointId, pointValue)
	luaPrint("call reportEffectPoint start")
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local luaj = require "cocos.cocos2d.luaj"
		local args = {pointId, pointValue}
		local signs = "(Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "reportEffectPoint", args, signs)
		if not ok then
            luaPrint("call reportEffectPoint fail"..ret)
		end
	end
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
        local luaoc = require "cocos.cocos2d.luaoc"
        local args = {pointId = pointId, pointValue = pointValue}
        local ok, ret = luaoc.callStaticMethod("LuaOpenInstallBridge","reportEffectPoint",args)
        if not ok then
            luaPrint("luaoc reportEffectPoint error:"..ret)
        end
    end
end

return openinstall
