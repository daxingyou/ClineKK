local breakSocketHandle,debugXpCall = require("LuaDebugjit")("localhost",7003)
cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakSocketHandle, 0.3, false) 
--如果已经存在 __G__TRACKBACK__ 请将 debugXpCall 直接加入 __G__TRACKBACK__ 即可
--__G__TRACKBACK__ 方法不是必须 debugXpCall是实现的是在lua 脚本调用错误时进行代码错误定位 
function __G__TRACKBACK__(errorMessage)  
    debugXpCall();  
end  
local status, msg = xpcall(main, __G__TRACKBACK__)

cc.FileUtils:getInstance():setPopupNotify(false)

package.path = package.path .. ";script/?.lua"
package.path = package.path .. ";hall/?.lua"

require "config"
require "cocos.init"
require("common.CommonFunc")
require("channel")

function loadScript(path)
    package.loaded[path] = nil
    return require(path)
end

--保证1.0.2之前的版本安装新版本运行正常
local path = cc.FileUtils:getInstance():getWritablePath().."src/hall/common/CommonFunc.luac"

-- if safeX == nil and cc.FileUtils:getInstance():isFileExist(path) then
--     cc.FileUtils:getInstance():removeFile(path)
-- end

-- loadScript("common.CommonFunc")

-- if device.platform ~= "windows" then
--     checkCachFile()
-- end

GameConfig = loadScript("common.GameConfig")
loadScript("common.CommonFunc")
loadScript("common.BaseCommand")
loadScript("common.tools.BindTool")
HttpUtils = loadScript("common.http.HttpUtils")
FontConfig = loadScript("common.UI.FontConfig")

initConfig()

local function main()
    executeGameSart()
end

--加载游戏启动页
function executeGameSart()
    cc.Device:setKeepScreenOn(true)
    cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS)

    if device.platform == "windows" then
        if NO_UPDATE then
            gameStart()
        else
            require("layer.WelcomeLayer"):scene()
        end
    else
        if NO_UPDATE then
            gameStart()
        else
            require("layer.WelcomeLayer"):scene()
        end
    end
end

function gameUpdate()
    initUrl()

    if NO_UPDATE then
        gameStart()
    else
        require("launcher.UpdateLayer"):scene(1)
    end
end

function gameStart()
    Hall = require("Hall").new()

    Hall.startGame()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    luaPrint(msg)
end

-- for CCLuaEngine
function __G__TRACKBACK__(errorMessage)
    luaPrint("---------------------------------------- "..errorMessage)
    luaPrint("LUA ERROR: "..tostring(errorMessage).."\n")
    luaPrint(debug.traceback())
    luaPrint("----------------------------------------")

    local msg = "---------------------------------------- \n"..errorMessage.."\n".."LUA ERROR: "..tostring(errorMessage).."\n"..debug.traceback().."(----------------------------------------)"
    msg = string.gsub(msg, "\t", "    ")
    msg = string.gsub(msg, " ", "+")
    msg = string.gsub(msg, "\n", "%%0D%%0A")
    -- local str = gameName.."\\"..os.date("%Y%m%d").."\\"

    local str = "type=Lua&GameName="..gameName.."_"..runMode.."_"..channelID.."&LuaVersion="
    if GameConfig.GameVersion then
        str = str..GameConfig.GameVersion
    end

    if PlatformLogic and PlatformLogic.loginResult and PlatformLogic.loginResult.dwUserID then
        str = str.."&UserID="..PlatformLogic.loginResult.dwUserID.."&NickName="..PlatformLogic.loginResult.nickName.."&Platform="..device.platform
    else
        str = str.."&UserID=".."none".."&NickName=".."none".."&Platform="..device.platform
    end

    str = str.."&SysVersion="..getVersion()

    str = str.."&Model="..getPhoneModel()

    str = str.."&Information="..msg

    if isLoginLayer ~= true then
        local rootPath = {"cache/","res/","src/"};
        local writePath = cc.FileUtils:getInstance():getWritablePath()

        for k,v in pairs(rootPath) do
            local path1 = writePath..v
            if cc.FileUtils:getInstance():isDirectoryExist(path1) then
                cc.FileUtils:getInstance():removeDirectory(path1)
                if cc.FileUtils:getInstance():isDirectoryExist(path1) then
                    luaPrint("main path1 ="..path1.."删除失败")
                else
                    luaPrint("main path1 ="..path1.."删除成功")
                end
            else
                luaPrint("main path1 ="..path1.."不存在，无需删除")
            end
        end

        -- for key,v in pairs(package.loaded) do --删除对应子游戏的package.loaded
        --     local pos = string.find(key,  "common.")
        --     local pos1 = string.find(key,  "layer.")
        --     local pos2 = string.find(key,  "launcher.")
        --     local pos3 = string.find(key,  "platform.")
        --     local pos4 = string.find(key,  "tools.")
        --     local pos5 = string.find(key,  "logic.")
        --     local pos6 = string.find(key,  "net.")
        --     local pos7 = string.find(key,  "dataModel.")
        --     if pos or pos1 or pos2 or pos3 or pos4 or pos5 or pos6 or pos7 then 
        --         package.loaded[key] = nil
        --     end
        -- end

        loadScript("src/script/main")
    end
end

function requestHttp(url, responseType, data)
    if responseType == nil then
        responseType = "GET"
    end

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open(responseType, url)

    local function onReadyStateChanged()
        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)

    xhr:send(data)
end
