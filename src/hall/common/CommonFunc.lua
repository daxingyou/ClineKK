local tables = require("cocos/framework/table")

--合并两个table
function mergeTables(...)
    local tabs = {...}
    if not tabs then
        return {}
    end
    local origin = tabs[1]
    for i = 2,#tabs do
        if origin then
            if tabs[i] then
                for k,v in pairs(tabs[i]) do
                    table.insert(origin,v)
                end
            end
        else
            origin = tabs[i]
        end
    end
    return origin
end

function onlineRemind()
    if PlatformLogic and PlatformLogic.loginResult and PlatformLogic.loginResult.dwUserID and isOnlineRemind == true then
        if PlatformLogic.loginResult.VIPLevel > 0 then
            isOnlineRemind = nil
            local url = GameConfig.tuiguanUrl.."/api/playerhandler.ashx?action=follow&agentId="..channelID.."&userId="..tostring(PlatformLogic.loginResult.dwUserID)
            luaPrint("online url ",url)
            HttpUtils:requestHttp(url,function(result, response)
                if result == true then
                    luaPrint("上线提醒 success")
                else
                    luaPrint("上线提醒 failed")
                end
            end)
        else
            luaPrint(PlatformLogic.loginResult.dwUserID,"上线了 等级 ",PlatformLogic.loginResult.VIPLevel," ,没有关注，不提醒")
        end
    end
end

function registerWx()
    if checkVersion("1.0.2") == 2 then
        if device.platform == "android" then
            local javaMethodName = "regToWX"
            local javaParams = {GameConfig.WX_APP_ID}
            local javaMethodSig = "(Ljava/lang/String;)V"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 regToWX")
            end
        elseif device.platform == "ios" then
            local args = {appID=GameConfig.WX_APP_ID}
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","registerWeixin",args)
            if ok == false then
                luaPrint("luaoc调用出错:registerWeixin")
            end
        end
    end
end

androidDeviceType = {
    language = 0,
    version = 1,
    mode = 2,
    brand = 3,
    product = 4,
    manufacturer = 5,
    board = 6,
    device = 7,
    display = 8,
    cpu = 9,
    cpu2 = 10,
    serial = 11,
    tags = 12,
    resolution = 13,
    netOperator = 14,
    netMode = 15,
    isNetConnect = 16,
    apiLevel = 17,
    processId = 18,
    processName = 19,
    createAppFolder = 20,
    isSDCardAvailable = 21,
    isPad = 22,
    ip = 23,
    netIp = 24,
    imei = 25
}

iosDeviceType = {
    display = 0,
    version = 1,
    iPhoneName = 2,
    APPVerion = 3,
    BatteryLevel = 4,
    SystemName = 5,
    SystemVersion = 6,
    IPAdres = 7,
    TotalMemorySize = 8,
    AvailableMemorySize = 9,
    CurrentBatteryLevel = 10,
    BatteryStat = 11,
    Language = 12,
    netOperator = 13
}

function getDeviceByID(id,net)
    if isEmptyString(net) then
        net = ""
    end

    if checkVersion("1.0.2") == 2 then
        if device.platform == "android" then
            local javaMethodName = "getDeviceByID"
            local javaParams = {id,net}
            local javaMethodSig = "(ILjava/lang/String;)Ljava/lang/String;"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 getDeviceByID")
            else
                return ret
            end
        elseif device.platform == "ios" then
            local args = {id=id,net=net}
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getDeviceByID",args)
            if ok == false then
                luaPrint("luaoc调用出错:getDeviceByID")
            else
                return ret
            end
        end
    end

    return ""
end

function wxpayNative(order,subject)
    if checkVersion("1.2.3") == 2 then
        if device.platform == "android" then
            local javaMethodName = "wxpayNative"
            local javaParams = {order,subject,true}
            local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Z)Ljava/lang/String;"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 wxpayNative")
            end
        elseif device.platform == "ios" then
            local args = {order=order,subject=subject,showLoading=true}
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","wxpayNative",args)
            if ok == false then
                luaPrint("luaoc调用出错:wxpayNative")
            end
        end
    end
end

function alipayNative(order,subject)
    if checkVersion("1.0.1") == 2 then
        if device.platform == "android" then
            local javaMethodName = "alipayNative"
            local javaParams = {order,subject,true}
            local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Z)Ljava/lang/String;"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 alipayNative")
            end
        elseif device.platform == "ios" then
            local args = {order=order,subject=subject,showLoading=true}
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","alipayNative",args)
            if ok == false then
                luaPrint("luaoc调用出错:alipayNative")
            end
        end
    end
end

function tuiguanUrlChange()
    if isSetTuiguangUrl == nil then
        local str = getWebBestIP("kktuiguang")
        local result = string.split(str,":")
        luaPrint("SettlementInfo 2 sdk result ====",str)
        if #result > 1 then
            local ip = result[1]
            local port = tonumber(result[2])
            if checkVersion("1.2.0") == 2 and GameConfig.serverVersionInfo.youXiDun == 1 then
                local qianzhui = string.split(GameConfig.tuiguanUrl,":")[1]
                GameConfig.tuiguanUrl = qianzhui.."://"..ip..":"..port
            elseif checkVersion("1.0.9") == 2 then
                local qianzhui = string.split(GameConfig.tuiguanUrl,":")[1]
                GameConfig.tuiguanUrl = qianzhui.."://"..ip..":"..port
            else
                GameConfig.tuiguanUrl = GameConfig.tuiguanUrl..":"..port
            end
        end
        isSetTuiguangUrl = true
    end
end

function encodeBase64(source_str)
    local b64chars = 'ABCDEFGQRW0123klmnop45HIJKLMNOP6789XYZabcdefghiSTUVjqrstuvwxyz+/'
    local s64 = ''
    local str = source_str
 
    while #str > 0 do
        local bytes_num = 0
        local buf = 0
 
        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end
 
        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end
 
        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end
 
    return s64
end
 
function decodeBase64(str64)
    local b64chars = 'ABCDEFGQRW0123klmnop45HIJKLMNOP6789XYZabcdefghiSTUVjqrstuvwxyz+/'
    local temp={}
    for i=1,64 do
        temp[string.sub(b64chars,i,i)] = i
    end
    temp['=']=0
    local str=""
    for i=1,#str64,4 do
        if i>#str64 then
            break
        end
        local data = 0
        local str_count=0
        for j=0,3 do
            local str1=string.sub(str64,i+j,i+j)
            if not temp[str1] then
                return
            end
            if temp[str1] < 1 then
                data = data * 64
            else
                data = data * 64 + temp[str1]-1
                str_count = str_count + 1
            end
        end
        for j=16,0,-8 do
            if str_count > 0 then
                str=str..string.char(math.floor(data/math.pow(2,j)))
                data=math.mod(data,math.pow(2,j))
                str_count = str_count - 1
            end
        end
    end
 
    local last = tonumber(string.byte(str, string.len(str), string.len(str)))
    if last == 0 then
        str = string.sub(str, 1, string.len(str) - 1)
    end
    return str
end

function trycall(script, traceback, ...)
    return xpcall(script, function (errors)

            -- get traceback
            traceback = traceback or debug.traceback

            -- decode it if errors is encoded table string
            if errors then
                local _, pos = errors:find("[@encode(error)]: ", 1, true)
                if pos then
                    -- strip traceback (maybe from coroutine.resume)
                    local errs = errors:sub(pos + 1)
                    local stack = nil
                    local stackpos = errs:find("}\nstack traceback:", 1, true)
                    if stackpos and stackpos > 1 then
                        stack = errs:sub(stackpos + 2)
                        errs  = errs:sub(1, stackpos)
                    end
                    errors, errs = errs:deserialize()
                    if not errors then
                        errors = errs
                    end
                    if type(errors) == "table" then
                        if stack then
                            errors._stack = stack
                        end
                        setmetatable(errors, 
                        { 
                            __tostring = function (self)
                                local result = self.errors
                                if not result then
                                    result = string.serialize(self, {strip = true, indent = false})
                                end
                                result = result or ""
                                if self._stack then
                                    result = result .. "\n" .. self._stack
                                end
                                return result
                            end,
                            __concat = function (self, other)
                                return tostring(self) .. tostring(other)
                            end
                        })
                    end
                    return errors
                end
            end
            return traceback(errors)
        end, ...)
end

-- traceback
-- function _traceback(errors)

--     -- no diagnosis info?
--     if not option.get("diagnosis") then
--         if errors then
--             -- remove the prefix info
--             local _, pos = errors:find(":%d+: ")
--             if pos then
--                 errors = errors:sub(pos + 1)
--             end
--         end
--         return errors
--     end

--     -- traceback exists?
--     if errors and errors:find("stack traceback:", 1, true) then
--         return errors
--     end

--     -- init results
--     local results = ""
--     if errors then
--         results = errors .. "\n"
--     end
--     results = results .. "stack traceback:\n"

--     -- make results
--     local level = 2    
--     while true do    

--         -- get debug info
--         local info = debug.getinfo(level, "Sln")

--         -- end?
--         if not info or (info.name and info.name == "xpcall") then
--             break
--         end

--         -- function?
--         if info.what == "C" then
--             results = results .. string.format("    [C]: in function '%s'\n", info.name)
--         elseif info.name then 
--             results = results .. string.format("    [%s:%d]: in function '%s'\n", info.short_src, info.currentline, info.name)    
--         elseif info.what == "main" then
--             results = results .. string.format("    [%s:%d]: in main chunk\n", info.short_src, info.currentline)    
--             break
--         else
--             results = results .. string.format("    [%s:%d]:\n", info.short_src, info.currentline)    
--         end

--         -- next
--         level = level + 1    
--     end    

--     -- ok?
--     return results
-- end

function try(block)
    -- get the try function
    local try = block[1]
    assert(try)

    -- get catch and finally functions
    local funcs = {}
    funcs.catch = block.catch
    funcs.finally = block.finally

    -- try to call it
    local results = tables.pack(trycall(try))
    local ok = results[1]

    if not ok then

        -- run the catch function
        if funcs and funcs.catch then
            funcs.catch(results[2])
        end
    end

    -- run the finally function
    if funcs and funcs.finally then
        funcs.finally(ok, tables.unpack(results, 2, results.n))
    end

    -- ok?
    if ok then
        return tables.unpack(results, 2, results.n)
    end
end

function ToStringEx(value)
    if type(value)=='table' then
       return TableToStr(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end

function TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..ToStringEx(key).."]="..ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..ToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..ToStringEx(value)
                end
            end
        end

        i = i+1
    end

     retstr = retstr.."}"
     return retstr
end

function StrToTable(str)
    if str == nil or type(str) ~= "string" then
        return
    end
    
    return loadstring("return " .. str)()
end

function getInternetIP()
    HttpUtils:requestHttp(GameConfig:getIPUrl(), function(result, response) getIPCallback(result, response) end)
end

function getIPCallback(result, response)
    if result == false then
    else
        local startPos = string.find(response,"{")
        local endPos = string.find(response,"}")
        local jsonStr = string.sub(response,startPos,endPos)
        local tb = json.decode(jsonStr)
        globalUnit.ip = tb.cip
        luaDump(tb,"ip请求成功------------------------"..tostring(GameConfig.serverVersionInfo.ipArea))
        local cname = tb.cname
        globalUnit.city = cname
        if not isEmptyString(cname) and runMode == "release" then
            if not isEmptyString(GameConfig.serverVersionInfo.ipArea) then
                local temp = string.split(GameConfig.serverVersionInfo.ipArea,"_")
                if not isEmptyTable(temp) then
                    for k,v in pairs(temp) do
                        local i,j = string.find(cname,v)
                        if i and j then
                            globalUnit.checkIpIsCanLogin = false
                            return
                        end
                    end
                end
            end
        end

        globalUnit.checkIpIsCanLogin = true
    end
end

function getQrUrl()
    if isEmptyString(globalUnit.tuiguanUrlQr) then
        SettlementInfo:sendConfigInfoRequest(9)
        return ""
    else
        return globalUnit.tuiguanUrlQr
    end
end

-- 短信校验码
function createCheckCode(r)
    local onlyString = onUnitedPlatformGetSerialNumber()

    local code = cc.UserDefault:getInstance():getStringForKey("checkcode","")

    if code == "" then
        code = onlyString
        cc.UserDefault:getInstance():setStringForKey("checkcode",onlyString)
    end

    local cf = {
        {"code","CHARSTRING[50]"}
    }
    local msg = {}
    msg.code = code

    local rd = math.random(10000,20000)
    if r ~= nil then
        rd = r
    end

    -- local sendData = HNSocketProtocolData:new()
    -- sendData:setDataEncry(1)
    -- sendData:setCheckCode(rd)

    -- sendData:writeHead(20+getObjSize(cf),200,200,0,rd)

    local RC4Engine = require("hall.common.RC4Engine");
    local msgConctol = RC4Engine.new();
    msgConctol:Setup(rd,5);

    local output = msgConctol:Process(msg.code,string.len(msg.code))

    -- convertToC(sendData,msg,cf)

    -- luaPrint("短信校验码",rd,code);
    -- luaDump(output,"output")

    return rd,code,output
end

function luaCrash()
    if runMode == "release" then
        if checkIsRunningInEmulator() or isEmulator() then
            -- cc.Director:getInstance():endToLua()
            -- exitGame()
            return true
        end
    end

    return false
end

-- 检查Android是否是模拟器
function checkAndroid()
    if device.platform == "ios" then
    elseif device.platform == "android" then
        if checkVersion() == 2 then
            local javaClassName = "org.cocos2dx.lua.AppActivity"
            local javaMethodName = "getmmethod"
            local javaParams = {}
            local javaMethodSig = "()I"
            local ok,ret  = require("cocos.cocos2d.luaj").callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 getmmethod")
            else
                return ret == 1
            end
        end
    else
        luaPrint("getmmethod!")
    end

    return false
end

function hasSimCard()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "hasSimCard"
            local javaParams = {}
            local javaMethodSig = "()I"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 hasSimCard")
            else
                return ret == 1
            end
        end
    end

    return true
end

function getProvidersName()
    local arg = "46000".."|".."46001".."|".."46002".."|".."46003".."|".."46005".."|".."46006".."|"
        .."46007".."|".."46008".."|".."46009".."|".."46010".."|".."46011".."|".."51503".."|".."51502"
        .."|".."45400".."|".."45401".."|".."45402".."|".."45404".."|".."45406".."|".."45410".."|".."45412"
        .."|".."45416".."|".."45418".."|".."46601".."|".."46606".."|".."46668".."|".."46688".."|".."46692"
        .."|".."46693".."|".."46697".."|".."46699"
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "getProvidersName"
            local javaParams = {arg}
            local javaMethodSig = "(Ljava/lang/String;)I"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 getProvidersName")
            else
                return ret == 1
            end
        end
    end

    return true
end

-- 模拟器
function checkIsRunningInEmulator()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsRunningInEmulator"
            local javaParams = {""}
            local javaMethodSig = "(Ljava/lang/String;)Z"
            if checkVersion("1.0.0") == 2 then
                javaParams = {"",0,4,0}
                javaMethodSig = "(Ljava/lang/String;III)Z"
            end
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsRunningInEmulator")
            else
                return ret
            end
        end
    end

    return false
end

-- 多开软件检测 LocalServerSocket端口占用
function checkIsRunningInVirtualApk()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsRunningInVirtualApk"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 isEmulator")
            else
                return ret
            end
        end
    end

    return false
end

-- 多开软件检测 文件路径检测
function checkIsRunningInVirtualApkByPrivateFile()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsRunningInVirtualApkByPrivateFile"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsRunningInVirtualApkByPrivateFile")
            else
                return ret
            end
        end
    end

    return false
end

-- 多开软件检测 应用列表检测
function checkIsRunningInVirtualApkByOriginApkPackageName()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsRunningInVirtualApkByOriginApkPackageName"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsRunningInVirtualApkByOriginApkPackageName")
            else
                return ret
            end
        end
    end

    return false
end

-- 多开软件检测 maps检测
function checkIsRunningInVirtualApkByMultiApkPackageName()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsRunningInVirtualApkByMultiApkPackageName"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsRunningInVirtualApkByMultiApkPackageName")
            else
                return ret
            end
        end
    end

    return false
end

-- 多开软件检测 ps检测
function checkIsRunningInVirtualApkByHasSameUid()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsRunningInVirtualApkByHasSameUid"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsRunningInVirtualApkByHasSameUid")
            else
                return ret
            end
        end
    end

    return false
end

-- 反调试方案
function checkIsDebug()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsDebug"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsDebug")
            else
                return ret
            end
        end
    end

    return false
end

-- 端口检测
function checkIsPortUsing()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsPortUsing"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsPortUsing")
            else
                return ret
            end
        end
    end

    return false
end

-- root检测
function checkIsRoot()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsRoot"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsRoot")
            else
                return ret
            end
        end
    end

    return false
end

-- Xposed框架检查
function checkIsXposedExist()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsXposedExist"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsXposedExist")
            else
                return ret
            end
        end
    end

    return false
end

-- Xposed框架检查
function checkXposedExistAndDisableIt()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkXposedExistAndDisableIt"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkXposedExistAndDisableIt")
            else
                return ret
            end
        end
    end

    return false
end

-- 反调试方案
function checkIsBeingTracedByJava()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsBeingTracedByJava"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsBeingTracedByJava")
            else
                return ret
            end
        end
    end

    return false
end

-- 检查usb充电状态
function checkIsUsbCharging()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "checkIsUsbCharging"
            local javaParams = {}
            local javaMethodSig = "()Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)

            if ok == false then
                luaPrint("luaoc调用出错 checkIsUsbCharging")
            else
                return ret
            end
        end
    end

    return false
end

function getSimulatorInfo()
    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local PKG_NAMES = {
                "com.mumu.launcher", "com.ami.duosupdater.ui", "com.ami.launchmetro", "com.ami.syncduosservices", 
                "com.bluestacks.home", "com.bluestacks.windowsfilemanager", "com.bluestacks.settings", "com.bluestacks.bluestackslocationprovider", 
                "com.bluestacks.appsettings", "com.bluestacks.bstfolder", "com.bluestacks.BstCommandProcessor", "com.bluestacks.s2p", "com.bluestacks.setup", 
                "com.bluestacks.appmart", "com.kaopu001.tiantianserver", "com.kpzs.helpercenter", "com.kaopu001.tiantianime", "com.android.development_settings", 
                "com.android.development", "com.android.customlocale2", "com.genymotion.superuser", "com.genymotion.clipboardproxy", "com.uc.xxzs.keyboard", 
                "com.uc.xxzs", "com.blue.huang17.agent", "com.blue.huang17.launcher", "com.blue.huang17.ime", "com.microvirt.guide", "com.microvirt.market", 
                "com.microvirt.memuime", "cn.itools.vm.launcher", "cn.itools.vm.proxy", "cn.itools.vm.softkeyboard", "cn.itools.avdmarket", "com.syd.IME", 
                "com.bignox.app.store.hd", "com.bignox.launcher", "com.bignox.app.phone", "com.bignox.app.noxservice", "com.android.noxpush", "com.haimawan.push",
                "me.haima.helpcenter", "com.windroy.launcher", "com.windroy.superuser", "com.windroy.launcher", "com.windroy.ime", "com.android.flysilkworm", 
                "com.android.emu.inputservice", "com.tiantian.ime", "com.microvirt.launcher", "me.le8.androidassist", "com.vphone.helper", "com.vphone.launcher", 
                "com.duoyi.giftcenter.giftcenter"
            }

            local str = "";
            for k,v in pairs(PKG_NAMES) do
                if k<#PKG_NAMES then
                    str = str..v.."|"
                else
                    str = str..v;
                end
            end

            local javaMethodName = "getSimulatorInfo"
            local javaParams = {str}
            local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 getSimulatorInfo")
            else
                return ret
            end
        end
    end

    return "";
end

function isEmulator()
    local PKG_NAMES = {
        "com.mumu.launcher", "com.ami.duosupdater.ui", "com.ami.launchmetro", "com.ami.syncduosservices", 
        "com.bluestacks.home", "com.bluestacks.windowsfilemanager", "com.bluestacks.settings", "com.bluestacks.bluestackslocationprovider", 
        "com.bluestacks.appsettings", "com.bluestacks.bstfolder", "com.bluestacks.BstCommandProcessor", "com.bluestacks.s2p", "com.bluestacks.setup", 
        "com.bluestacks.appmart", "com.kaopu001.tiantianserver", "com.kpzs.helpercenter", "com.kaopu001.tiantianime", "com.android.development_settings", 
        "com.android.development", "com.android.customlocale2", "com.genymotion.superuser", "com.genymotion.clipboardproxy", "com.uc.xxzs.keyboard", 
        "com.uc.xxzs", "com.blue.huang17.agent", "com.blue.huang17.launcher", "com.blue.huang17.ime", "com.microvirt.guide", "com.microvirt.market", 
        "com.microvirt.memuime", "cn.itools.vm.launcher", "cn.itools.vm.proxy", "cn.itools.vm.softkeyboard", "cn.itools.avdmarket", "com.syd.IME", 
        "com.bignox.app.store.hd", "com.bignox.launcher", "com.bignox.app.phone", "com.bignox.app.noxservice", "com.android.noxpush", "com.haimawan.push",
        "me.haima.helpcenter", "com.windroy.launcher", "com.windroy.superuser", "com.windroy.launcher", "com.windroy.ime", "com.android.flysilkworm", 
        "com.android.emu.inputservice", "com.tiantian.ime", "com.microvirt.launcher", "me.le8.androidassist", "com.vphone.helper", "com.vphone.launcher", 
        "com.duoyi.giftcenter.giftcenter"
    }

    local str = "";
    for k,v in pairs(PKG_NAMES) do
        if k<#PKG_NAMES then
            str = str..v.."|"
        else
            str = str..v;
        end
    end

    if device.platform == "android" then
        if checkVersion("1.0.0") == 2 then
            local javaMethodName = "isSimulator"
            local javaParams = {str}
            local javaMethodSig = "(Ljava/lang/String;)Z"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams,javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 isEmulator")
            else
                return ret
            end
        end
    end

    return false;
end

function subString(str,k)
    local ts = string.reverse(str)
    local i,j = string.find(ts,k,1,true)
    local m = string.len(ts)-i
    return string.sub(str,1,m)
end

--玩家购买提示
function requestBuyResult()
    local url = GameConfig:getPayResultUrl()..PlatformLogic.loginResult.dwUserID
    HttpUtils:requestHttp(url, function(result, response) buyResultCallback(result, response) end)
end

function buyResultCallback(result,response)
    luaPrint("buyResultCallback  result ",result)
    if result == true then
        local tb = json.decode(response)

        luaDump(tb,"buyResultCallback")

        if tb.State then
            local text = ""

            if tb.Value == 0 then
                text = "亲，恭喜您的充值已成功，金币已到达您的游戏账户，祝君好运！"
            elseif tb.Value == 1 then
                text = "亲，恭喜您的充值已成功，由于充值时您正在游戏中，金币已经帮您保存至保险柜中，祝君好运！"
            elseif tb.Value == 2 then
                text = "亲，恭喜您的人工充值已成功，金币已经帮您保存至保险柜中，祝君好运！"
            end

            if text ~= "" then
                GamePromptLayer:create(1):showPrompt(text,true)
            end
        end
    end
end

function checkIphoneX()
    local framesize = cc.Director:getInstance():getWinSize()

    local ratio = framesize.width / framesize.height

    if ratio >= 1.8 and ratio <= 2.4 then
        return true
    end

    return false
end

--全面屏适配
--node 背景图片 pType 节点设置坐标方式 0 默认 bg size  1 winsize 3 无背景图片
fitX = nil
safeX = 44
function iphoneXFit(node,pType)
    if not node or tolua.isnull(node) then
        return
    end

    if pType == nil then
        pType = 0
    end

    local framesize = cc.Director:getInstance():getWinSize()

    local ratio = framesize.width / framesize.height
    local x = node:getPositionX()
    local size = node:getContentSize()

    if ratio >= 1.8 and ratio <= 2.4 then
        if pType == 3 then
            -- if fitX == nil then
            local fitX1 = winSize.width/2 - 1280/2
            -- end

            local children = node:getChildren()

            for k,child in pairs(children) do
                child:setPositionX(child:getPositionX() + fitX1)
            end

            return
        end

        node:ignoreContentAdaptWithSize(false)
        if pType == 4 then
            node:setContentSize(cc.size(framesize.width,node:getContentSize().height))
        else
            node:setContentSize(cc.size(framesize.width,framesize.height))
        end
        node:setPositionX(framesize.width/2)

        local moveX = node:getContentSize().width/2 - size.width/2
        local tagrtX = 0

        if pType == 1 then
            moveX = node:getPositionX() - x
        end

        if pType ~= 3 then
            fitX = moveX
        end

        local children = node:getChildren()

        for k,child in pairs(children) do
            local name = child:getName()
            if name == "mask" then
                child:ignoreContentAdaptWithSize(false)
                child:setContentSize(cc.size(framesize.width,child:getContentSize().height))
                local nodes = child:getChildren()
                if nodes then
                    for k,node in pairs(nodes) do
                        node:setContentSize(cc.size(child:getContentSize().width, child:getContentSize().height))
                        node:setAnchorPoint(0,0.5)
                        node:setPosition(0,child:getContentSize().height/2)
                    end
                end
            end

            child:setPositionX(child:getPositionX() + moveX)
        end

        for k,child in pairs(children) do
            if child.pType == 0 then
                if tagrtX == 0 and child.pTarget ~= nil then
                    tagrtX = (child:getPositionX() - (safeX * 1.5 + child:getContentSize().width/2))
                    luaPrint("tagrtX  0 ======. "..tagrtX.."  "..tostring(child:getName()))
                    break
                end
            elseif child.pType == 1 then
                if tagrtX == 0 and child.pTarget ~= nil  then
                    tagrtX =  ((winSize.width - safeX * 1.5 - child:getContentSize().width/2) - child:getPositionX())
                    luaPrint("tagrtX 1 ======. "..tagrtX.."  "..tostring(child:getName()))
                    break
                end
            end
        end

        for k,child in pairs(children) do
            if child.pType == 0 then
                local x = child:getPositionX() - tagrtX
                if x >= 0 then
                    child:setPositionX(x)
                else
                    luaPrint("左 适配异常  ",child:getName())
                end
            elseif child.pType == 1 then
                local x = child:getPositionX() + tagrtX
                if x <= framesize.width then
                    child:setPositionX(x)
                else
                    luaPrint("右 适配异常  ",child:getName())
                end 
            end
        end
    end
end

function showWindow(msg,callback)
    local layer = display.newLayer()
    layer:setName("prompt")

    local winSize = cc.Director:getInstance():getWinSize()
    local pos =  cc.p(winSize.width/2,winSize.height/2)

    local bg = ccui.ImageView:create("common/commonBg0.png")
    bg:setPosition(pos)
    layer:addChild(bg)

    local size = bg:getContentSize()

    local title = ccui.ImageView:create("common/wenxintishi.png")
    title:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height-30));
    bg:addChild(title)

    local label = cc.Label:createWithSystemFont(msg,"Arial",26,cc.size(0,0),cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setColor(cc.c3b(128, 128, 128))
    label:setPosition(size.width/2,size.height*0.55)
    bg:addChild(label)

    local btnOk = ccui.Button:create("common/ok.png","common/ok-on.png")
    btnOk:setPosition(size.width/2, 70)
    btnOk:setAnchorPoint(0.5, 0)
    bg:addChild(btnOk)
    btnOk:addClickEventListener(function()
        performWithDelay(layer:getParent(),function() if callback then callback() end end,0.1)
        layer:removeSelf()
    end)

    return layer
end

--释放lua脚本
function releaseLuaRequire(path)
    package.loaded[path] = nil
    _G[path] = nil
end

function getVersion()
    if device.platform == "ios" then
        local ok,ret  = require("cocos.cocos2d.luaoc").callStaticMethod("MethodForLua","getVersion")
        if ok == false then
            luaPrint("luaoc调用出错:getVersion")
        else
            return ret
        end
    elseif device.platform == "android" then
        local javaClassName = "org.cocos2dx.lua.AppActivity"
        local javaMethodName = "getVersion"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = require("cocos.cocos2d.luaj").callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 getVersion")
        else
            return ret
        end
    else
        luaPrint("getVersion!")
    end

    return "1.0.0"
end

function getAppConfig(key)
    if device.platform == "android" then
        if checkVersion("99.99.99") == 2 then
            local javaClassName = "org.cocos2dx.lua.AppActivity"
            local javaMethodName = "getAppConfig"
            local javaParams = {key}
            local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
            local ok,ret  = require("cocos.cocos2d.luaj").callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 getAppConfig")
            else
                return ret
            end
        end
    elseif device.platform == "ios" then
        if checkVersion("1.0.0") == 2 then
            local args = {key=key}
            local ok,ret  = require("cocos.cocos2d.luaoc").callStaticMethod("MethodForLua","getAppConfig",args)
            if ok == false then
                luaPrint("luaoc调用出错:getAppConfig")
            else
                return ret
            end
        end
    end

    return ""
end

--版本缓存,强更时删除本地下载文件
function checkCachFile()
    --清理缓存控制
    local cacheVer = cc.UserDefault:getInstance():getStringForKey("cacheVer","")
    local curVer = getVersion()

    if cacheVer ~= "" and string.len(cacheVer) > 0 and cacheVer ~= curVer then
        local rootPath = {"cache/","res/","src/"}
        local writePath = cc.FileUtils:getInstance():getWritablePath()

        for k,v in pairs(rootPath) do
            local path = writePath..v
            if cc.FileUtils:getInstance():isDirectoryExist(path) then
                cc.FileUtils:getInstance():removeDirectory(path)
                if cc.FileUtils:getInstance():isDirectoryExist(path) then
                    luaPrint("checkCachFile path ="..path.."删除失败")
                else
                    luaPrint("checkCachFile path ="..path.."删除成功")
                end
            else
                luaPrint("checkCachFile path ="..path.."不存在，无需删除")
            end
        end

        cc.UserDefault:getInstance():setStringForKey("cacheVer",curVer)
        return true
    else
        luaPrint("版本相同不清除 cacheVer ="..cacheVer.." curVer ="..curVer)
        if cacheVer == "" then
            cc.UserDefault:getInstance():setStringForKey("cacheVer",curVer)
        end
    end

    return false
end

--删掉本地下载资源
function clearCacheResources()
    local rootPath = {"cache/","res/","src/"}
    local writePath = cc.FileUtils:getInstance():getWritablePath()

    for k,v in pairs(rootPath) do
        local path = writePath..v
        if cc.FileUtils:getInstance():isDirectoryExist(path) then
            cc.FileUtils:getInstance():removeDirectory(path)
            if cc.FileUtils:getInstance():isDirectoryExist(path) then
                luaPrint("checkCachFile path ="..path.."删除失败")
            else
                luaPrint("checkCachFile path ="..path.."删除成功")
            end
        else
            luaPrint("checkCachFile path ="..path.."不存在，无需删除")
        end
    end
end

function clearChildGameCacheResources()
    local userDefault = cc.UserDefault:getInstance()
    local path = userDefault:getStringForKey("updateChildGame", "")
    local spath = {}
    if not isEmptyString(path) then
        spath = string.split(path,"_")
    end

    local gameName = {"fishing","bairenniuniu","baijiale","longhudou",
                      "hongheidazhan","sweetparty","lianhuanduobao","yaoyiyao","shuihuzhuan",
                      "fqzs","saoleihongbao","shisanzhang","doudizhu","dezhoupuke","sanzhangpai","ershiyidian",
                      "shidianban","qiangzhuangniuniu","errenniuniu","superfruitgame","benchibaoma", "shisanzhanglq","likuipiyu","jinchanbuyu"}

    local rootPath = {}
    for k,v in pairs(spath) do
        if not isEmptyString(v) then
            table.insert(rootPath,"res/"..v.."/")
            table.insert(rootPath,"src/"..v.."/")
        end
    end

    for k,v in pairs(gameName) do
        if not isEmptyString(v) then
            table.insert(rootPath,"res/"..v.."/")
            table.insert(rootPath,"src/"..v.."/")
        end
    end

    luaDump(rootPath)

    local writePath = cc.FileUtils:getInstance():getWritablePath()

    for k,v in pairs(rootPath) do
        local path = writePath..v
        if cc.FileUtils:getInstance():isDirectoryExist(path) then
            cc.FileUtils:getInstance():removeDirectory(path)
            if cc.FileUtils:getInstance():isDirectoryExist(path) then
                luaPrint("checkCachFile path ="..path.."删除失败")
            else
                luaPrint("checkCachFile path ="..path.."删除成功")
            end
        else
            luaPrint("checkCachFile path ="..path.."不存在，无需删除")
        end
    end

    rootPath = {}
    for k,v in pairs(spath) do
        if not isEmptyString(v) then
            table.insert(rootPath,"res/"..v..".txt")
            table.insert(rootPath,"cache/"..v..".txt")
            table.insert(rootPath,"cache/oldz"..v..".txt")
        end
    end

    for k,v in pairs(gameName) do
        if not isEmptyString(v) then
            table.insert(rootPath,"res/"..v..".txt")
            table.insert(rootPath,"cache/"..v..".txt")
            table.insert(rootPath,"cache/oldz"..v..".txt")
        end
    end

    for k,v in pairs(rootPath) do
        if cc.FileUtils:getInstance():isFileExist(writePath..v) then
            cc.FileUtils:getInstance():removeFile(writePath..v)
            if cc.FileUtils:getInstance():isFileExist(writePath..v) then
                luaPrint("checkCachFile path ="..writePath..v.."删除失败")
            else
                luaPrint("checkCachFile path ="..writePath..v.."删除成功")
            end
        else
            luaPrint("checkCachFile path ="..writePath..v.."不存在，无需删除")
        end
    end
    userDefault:setStringForKey("updateChildGame", "")
end

--清理缓存
--plistName 指定的plist
--isSaveHallSpine 是否保留大厅spine缓存 false 不保留 非false 保留
function clearCache(plistName,isSaveHallSpine,isCheckSpine)
    if isCheckSpine ~= false then
        if isSaveHallSpine == false then
            removeUnuseSkeletonAnimation()
        else
            local name = {"doudizhu","buyuheji","bairenpinshi","kuaile30miao",
                          "longhudou","hongheidazhan","yaoyiyao","feiqinzoushou",
                          "dezhoupuke","sanzhangpai","21dian","10dianban","qiangzhuangpinshi",
                          "errenpinshi","benchibaoma","xinshouyucun","yongzhehaiwan","shenhailieshou",
                          "haiyangshenhua","saoleihongbao","chaojishuiguoji","shuihuzhuan","sweetparty","lianhuanduobao"}
            removeOtherUnuseSkeletonAnimation(name)
        end
    end

    removeAllArmature()

    if plistName then
        if type(plistName) == "table" then
            for k,v in pairs(plistName) do
                display.removeSpriteFrames(v..".plist",v..".png")
            end
        else
            display.removeSpriteFrames(plistName..".plist",plistName..".png")
        end
    end

    display.removeUnusedSpriteFrames()
end

armatureCache = {}
--清除所有骨骼动画
function removeAllArmature()
    if armatureCache == nil then
        return
    end

    for k,v in pairs(armatureCache) do
        removeArmature(v[1],false)
        display.removeImage(v[2])
    end

    display.removeImage("game/jiesuan/likai.png")
    display.removeImage("game/jiesuan/likai-on.png")
    display.removeImage("fishing/fishdead/siwangtexiao.png")
    display.removeImage("fishing/fishdead/siwangtexiao2.png")
    display.removeImage("fishing/fishdead/siwangtexiao3.png")
    display.removeImage("fishing/fishdead/siwangtexiao4.png")
    armatureCache = {}
end

--骨骼动画缓存
function addArmature(imagePath,plistPath,configFilePath)
    if armatureCache == nil then
        armatureCache = {}
    end

    if imagePath and plistPath and configFilePath then
        local name = io.pathinfo(configFilePath).basename
        if ccs.ArmatureDataManager:getInstance():getAnimationData(name) == nil then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(imagePath,plistPath,configFilePath)
            table.insert(armatureCache,{name,imagePath})
        end
    else
        addArmatureConfig(configFilePath)
    end
end

function addArmatureConfig(configFilePath)
    if armatureCache == nil then
        armatureCache = {}
    end

    if configFilePath then
        local name = io.pathinfo(configFilePath).basename
        if ccs.ArmatureDataManager:getInstance():getAnimationData(name) == nil then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(configFilePath)
            table.insert(armatureCache,{name,configFilePath})
        end
    end
end

--骨骼动画移除
function removeArmature(configFilePath,isRemove)
    if isRemove == nil then
        isRemove = true
    end

    if configFilePath then
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(configFilePath)
        if isRemove then
            for k,v in pairs(armatureCache) do
                if v[1] == configFilePath then
                    table.removebyvalue(armatureCache,v)
                    break
                end
            end
        end
    end
end

--创建骨骼动画
function createArmature(imagePath,plistPath,configFilePath)
    addArmature(imagePath,plistPath,configFilePath)
    return ccs.Armature:create(io.pathinfo(configFilePath).basename)
end

--域名判断
function netAddrVaild(netAddr)
    if netAddr == GameConfig.A_SERVER_IP then
        return true
    end

    return false
end

logInfo = ""

function luaPrint(...)
    if PlatformLogic and PlatformLogic.loginResult and PlatformLogic.loginResult.dwUserID then
        if string.len(logInfo) > 2000 then
            logInfo = ""
        end

        local buf1 = ""
        local buf = {...}

        for i=1, select("#", ...) do
            buf1 = buf1..tostring(buf[i])
        end

        logInfo = logInfo..buf1.."\n"
    else
        local buf1 = ""
        local buf = {...}

        for i=1, select("#", ...) do
            buf1 = buf1..tostring(buf[i])
        end

        logInfo = logInfo..buf1.."\n"
    end
    
    if device.platform ~= "windows" and GameConfig.serverVersionInfo.isLogPrint ~= 0 then
        --todo
    else
        print(...)
    end
end

function luaDump(value, desciption, nesting)
    if device.platform ~= "windows"  and GameConfig.serverVersionInfo.isLogPrint ~= 0 then
        --todo
    else
        if PlatformLogic and PlatformLogic.loginResult and PlatformLogic.loginResult.dwUserID then
            -- logInfo = ""
            dump(value, desciption, nesting)
        else
            local str = dump(value, desciption, nesting)
            if str ~= nil then
                logInfo = logInfo..str.."\n"
            end
        end
    end
end

function uploadLog()
    luaPrint("上传日志=======================  logInfo  ")
end

function uploadInfo(name,text)
end

function checkNumber(str,target)
    local s = string.gsub(str,"[%d]","")

    if not isEmptyString(s) then
        s = string.gsub(str,"[%D]","")

        if target then
            target:setText(s)
        end

        return false,s
    end

    return true,str
end

function getIPAddress()
    if device.platform == "windows" then
        return require("common.ip").execute()
    else
        if not isEmptyString(globalUnit.ip) then
            return globalUnit.ip
        else
            return ""--getIp()
        end
    end
end

--文件名判断
function fileNameVerify(fileName)
    local s = string.gsub(fileName,"[%w]","")--过滤数字和字母
    if not isEmptyString(s) then
        luaPrint("文件名只能包含数字和字母 "..s)
    end

    luaPrint("1111   s ="..s)
    local s = string.gsub(s, "[-%._/]", "")--过滤特定标点符号

    luaPrint("2222   s ="..s)
    if isEmptyString(s) then
        return true
    else
        return false
    end
end

--提示保存推广宣传图到可读写路径
function createQrImage()
    if checkVersion() == 2 then
        if schedulerQr then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerQr)
            schedulerQr = nil
        end

        local qrIndex = 1
        local fun = function()
            saveExtendImage("newExtend/qr.png",qrIndex)
            qrIndex = qrIndex + 1
            if qrIndex > 1 and schedulerQr then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerQr)
                schedulerQr = nil
            end
        end
        local sharedScheduler = cc.Director:getInstance():getScheduler()
        schedulerQr = sharedScheduler:scheduleScriptFunc(fun, 1.5, false)
    end
end

function getFirstPackageData(port)
     if device.platform == "android" then
        local javaMethodName = "createConnectMsg"
        local javaParams = {port}
        local javaMethodSig = "(I)Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 createConnectMsg")
            return ""
        else
            return ret
        end
    end
end

function getBestIP(port)
    luaPrint("getBestIP() ",isSDKSuccess)
    if isYouxidun == true and runMode == "release" then
        if checkVersion("1.0.0") == 2 and isSDKSuccess == 1 then
            local arg = onUnitedPlatformGetSerialNumber().."|".."QKDS.wD6V749t6q.ftnormal02ac.com".."|".."QKDS".."|"..port
            if device.platform == "android" then
                local javaMethodName = "getBestIP"
                local javaParams = {arg}
                local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
                local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
                if ok == false then
                    luaPrint("luaoc调用出错 getBestIP")
                else
                    connectToServer(ret)
                end
            elseif device.platform == "ios" then
                local args = {ArgString=arg}
                local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getBestIPYouxidun",args)
                if ok == false then
                    luaPrint("luaoc调用出错:getBestIPYouxidun")
                else
                    connectToServer(ret)
                end
            end
        elseif checkVersion("1.0.0") == 2 then
            local arg = ""
            local sourceID = {"3b7EJa0j","woxn63Ko"}

            if gSourceID == nil then
                math.randomseed(tostring(os.time()):reverse():sub(1,7))
                local num = math.random(1,#sourceID)
                gSourceID = sourceID[num]
            end

            if gSourceID == nil then
               gSourceID = sourceID[1]
            end

            arg = gSourceID

            if device.platform == "android" then
                local javaMethodName = "getLocalPort"
                local javaParams = {arg,port}
                local javaMethodSig = "(Ljava/lang/String;I)I"
                local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
                if ok == false then
                    luaPrint("luaoc调用出错 getLocalPort")
                else
                    connectToServer("127.0.0.1:"..tostring(ret))
                end
            elseif device.platform == "ios" then
                local args = {ArgString=arg,port=port}
                luaDump(args)
                local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getLocalPort",args)
                if ok == false then
                    luaPrint("luaoc调用出错:getLocalPort",ret)
                else
                    luaPrint("ret == ",ret)
                    connectToServer("127.0.0.1:"..tostring(ret))
                end
            end
        end
    end
end

function getWebBestIP(groupName)
    luaPrint("getWebBestIP() ",isSDKSuccess)
    if isYouxidun == true and runMode == "release" then
        if checkVersion("1.0.0") == 2 and isSDKSuccess == 1 then
            local arg = onUnitedPlatformGetSerialNumber().."|".."QKDS.wD6V749t6q.ftnormal02ac.com".."|"..groupName.."|".."80"
            if device.platform == "android" then
                local javaMethodName = "getBestIP"
                local javaParams = {arg}
                local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
                local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
                if ok == false then
                    luaPrint("luaoc调用出错 getBestIP")
                else
                    return ret
                end
            elseif device.platform == "ios" then
                local args = {ArgString=arg}
                local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getBestIPYouxidun",args)
                if ok == false then
                    luaPrint("luaoc调用出错:getBestIPYouxidun")
                else
                    return ret
                end
            end
        elseif checkVersion("1.0.0") == 2 then
            local arg = "1desOZdT"
            if device.platform == "android" then
                local javaMethodName = "getLocalPort"
                local javaParams = {arg,80}
                local javaMethodSig = "(Ljava/lang/String;I)I"
                local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
                if ok == false then
                    luaPrint("luaoc调用出错 getLocalPort")
                else
                    return "127.0.0.1:"..ret
                end
            elseif device.platform == "ios" then
                local args = {ArgString=arg,port=80}
                local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getLocalPort",args)
                if ok == false then
                    luaPrint("luaoc调用出错:getLocalPort")
                else
                    return "127.0.0.1:"..ret
                end
            end
        end
    end

    return ""
end

isUseNetSDK = true
isYouxidun = true

if runMode == "debug" then
end

--网络端口注册
function isNetPortRegister(port)
    if NetPortRegister[tostring(port)] ~= nil then
        return true
    else
        NetPortRegister[tostring(port)] = true
        return false
    end
end

--注册端口
function registerNetPort(port)
    if isUseNetSDK ~= true then
        return
    end

    --低版本直连，不通过sdk
    if checkVersion() ~= 2 and runMode == "release" then
        isUseNetSDK = false
        return
    end

    luaPrint("Net sdk 注册端口 "..port)

    if checkVersion() == 1 then
        if not isNetPortRegister(port) then
            if device.platform == "android" then
                setJavaPort(tostring(port))
            end
        end

        if device.platform == "ios" then
            -- registerForward(port,port)
            local args = {port=port}
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","registerPort",args)
            if ok == false then
                luaPrint("luaoc调用出错:registerPort")
            end
        end
    end
end

function initYouxidun(ArgString,isAutoSwitch)
    if isUseNetSDK ~= true or isYouxidun ~= true then
        return -2
    end

    --低版本直连，不通过sdk
    if checkVersion() ~= 2 and runMode == "release" then
        isUseNetSDK = false
        return -3
    end

    if device.platform == "android" then
        local javaMethodName = "initYouxidun"
        local javaParams = {ArgString}
        local javaMethodSig = "(Ljava/lang/String;)I"

        if checkVersion("1.0.0") == 2 then
            if GameConfig.serverVersionInfo.youXiDun ~= 1 and isAutoSwitch ~= 1 then
                javaMethodName = "initQsu"
            end
        elseif checkVersion("1.0.0") == 2 then
            javaMethodName = "initQsu"
        end

        luaPrint("initYouxidun ",javaMethodName,ArgString)

        local ok,ret  = require("cocos.cocos2d.luaj").callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 "..javaMethodName)
            ret = -4
        end

        return ret
    elseif device.platform == "ios" then
        local javaMethodName = "initYouxidun"
        local args = {ArgString=ArgString}

        if checkVersion("1.0.0") == 2 then
            if GameConfig.serverVersionInfo.youXiDun ~= 1 and isAutoSwitch ~= 1 then
                javaMethodName = "initQsu"
            end
        elseif checkVersion("1.0.0") == 2 then
            javaMethodName = "initQsu"
        end

        luaPrint("initYouxidun ",javaMethodName,ArgString)

        local ok,ret  = require("cocos.cocos2d.luaoc").callStaticMethod("MethodForLua",javaMethodName,args)
        if ok == false then
            luaPrint("luaoc调用出错:initYouxidun")
            ret = -4
        end

        return ret
    end

    return -5
end

--初始化网络相关
function initNet(isAutoSwitch)
    if isStopService then
        return
    end

    if device.platform == "windows" then
        isUseNetSDK = false
        isYouxidun = false
    end
  
    if isUseNetSDK ~= true then
        sdkKey = tostring(GameConfig.A_SERVER_IP)
        return
    end

    --低版本直连，不通过sdk
    if checkVersion() ~= 2 and runMode == "release" then
        isUseNetSDK = false
        sdkKey = tostring(GameConfig.A_SERVER_IP)
        return
    end

    if isYouxidun == true and runMode == "release" then
        if initSDKRet == 0 then
            return true
        end

        if GameConfig.serverVersionInfo.youXiDun ~= 1 and isAutoSwitch ~= 1 and isInitSDKing == true and isGetHotUpdate ~= true then
            return
        end

        local port = ""

        if checkVersion("1.0.0") == 2 then
            if GameConfig.serverVersionInfo.youXiDun == 1 or isAutoSwitch == 1 then
                port = "mipsqsnyj+geETI+r1c5gQm2HmoJVoWG6lZQjhxjgkYdoT-1C4rrWK2WJhLhBQIPWRs8e6N2uUJAYRTjb5znIL4g8+N3Qsv-F5jzhIWB4NOzZt8i3k7SL-nUoIxaeZ7DZVoIVdM85KIS7GIJzIjXZCXNMOO3ssutU+dHiRu5nvUXw_rUTknVqJdHrzLXZYkrMYY9-rbCDDnjbqL4pI5D3AVCqt+Q1hzpQnuRWoDJim4jooKft5-URCpbWE6wFhV4zKDoTbWp4-j3slrZgC_OAXWve1FSRouvE7bHeKZlBsVJe3VrYtH_g0q9zxRpTk9rNCLg97dKR6XdCiJi5F0vBJmb0nZTtTnTXTouoflIUKTb90zlrYGgBh7n3zONt4_vUV0fY0RKSKZxzHhMnbhJ1-C8b0qEPVK"
            else
                port = "WQE16F8366BC32NL"
            end
        elseif checkVersion("1.0.0") == 2 then
            port = "WQE16F8366BC32NL"
        else
            port = "mipsqsnyj+geETI+r1c5gQm2HmoJVoWG6lZQjhxjgkYdoT-1C4rrWK2WJhLhBQIPWRs8e6N2uUJAYRTjb5znIL4g8+N3Qsv-F5jzhIWB4NOzZt8i3k7SL-nUoIxaeZ7DZVoIVdM85KIS7GIJzIjXZCXNMOO3ssutU+dHiRu5nvUXw_rUTknVqJdHrzLXZYkrMYY9-rbCDDnjbqL4pI5D3AVCqt+Q1hzpQnuRWoDJim4jooKft5-URCpbWE6wFhV4zKDoTbWp4-j3slrZgC_OAXWve1FSRouvE7bHeKZlBsVJe3VrYtH_g0q9zxRpTk9rNCLg97dKR6XdCiJi5F0vBJmb0nZTtTnTXTouoflIUKTb90zlrYGgBh7n3zONt4_vUV0fY0RKSKZxzHhMnbhJ1-C8b0qEPVK"
        end

        if device.platform == "android" then
            if not isEmptyString(GameConfig.serverVersionInfo.ABFuAndroidKey) then
                port = GameConfig.serverVersionInfo.ABFuAndroidKey
            end
        end

        if device.platform == "ios" then
            port = ""

            if checkVersion("1.0.0") == 2 then
                if GameConfig.serverVersionInfo.youXiDun == 1 or isAutoSwitch == 1 then
                    port = "mipsqsnyj+geETI+r1c5gQm2HmoJVoWG6lZQjhxjgkYdoT-1C4rrWK2WJhLhBQIPWRs8e6N2uUJAYRTjb5znIL4g8+N3Qsv-F5jzhIWB4NOzZt8i3k7SL-nUoIxaeZ7DZVoIVdM85KIS7GIJzIjXZCXNMOO3ssutU+dHiRu5nvUXw_rUTknVqJdHrzLXZYkrMYY9-rbCDDnjbqL4pI5D3AVCqt+Q1hzpQnuRWoDJim4jooKft5-URCpbWE6wFhV4zKDoTbWp4-j3slrZgC_OAXWve1FSRouvE7bHeKZlBsVJe3VrYtH_g0q9zxRpTk9rNCLg97dKR6XdCiJi5F0vBJmb0nZTtTnTXTouoflIUKTb90zlrYGgBh7n3zONt4_vUV0fY0RKSKZxzHhMnbhJ1-C8b0qEPVK"
                else
                    port = "WQE16F8366BC32NL"
                end
            elseif checkVersion("1.0.0") == 2 then
                port = "WQE16F8366BC32NL"
            else
                port = "mipsqsnyj+geETI+r1c5gQm2HmoJVoWG6lZQjhxjgkYdoT-1C4rrWK2WJhLhBQIPWRs8e6N2uUJAYRTjb5znIL4g8+N3Qsv-F5jzhIWB4NOzZt8i3k7SL-nUoIxaeZ7DZVoIVdM85KIS7GIJzIjXZCXNMOO3ssutU+dHiRu5nvUXw_rUTknVqJdHrzLXZYkrMYY9-rbCDDnjbqL4pI5D3AVCqt+Q1hzpQnuRWoDJim4jooKft5-URCpbWE6wFhV4zKDoTbWp4-j3slrZgC_OAXWve1FSRouvE7bHeKZlBsVJe3VrYtH_g0q9zxRpTk9rNCLg97dKR6XdCiJi5F0vBJmb0nZTtTnTXTouoflIUKTb90zlrYGgBh7n3zONt4_vUV0fY0RKSKZxzHhMnbhJ1-C8b0qEPVK"
            end

            if not isEmptyString(GameConfig.serverVersionInfo.ABFuIosKey) then
                port = GameConfig.serverVersionInfo.ABFuIosKey
            end
        end

        sdkKey = tostring(port)

        isInitSDKing = true

        initSDKRet = initYouxidun(port,isAutoSwitch)

        if checkVersion("1.0.0") == 2 then
            if GameConfig.serverVersionInfo.youXiDun == 1 or isAutoSwitch == 1 then
                if initSDKRet ~= 0 then
                    addScrollMessage("游戏盾初始化失败"..tostring(initSDKRet))
                else
                    isSDKSuccess = 1
                    if isGetHotUpdate == true then
                        isGetHotUpdate = nil
                        performWithDelay(display.getRunningScene(),function() tuiguanUrlChange() dispatchEvent("reqestHotUpdate") end,0.3)
                        return true
                    end

                    if isChangeSDK == true and PlatformLogic.isToConnect == true then
                        isChangeSDK = nil
                        getBestIP(PlatformLogic.port)
                    end
                    return true
                end
            else
                initSDKRet = -6
                if schedulerSDK and not tolua.isnull(schedulerSDK) then
                    display.getRunningScene():stopAction(schedulerSDK)
                    schedulerSDK = nil
                end
                
                luaPrint("等待超级盾初始化结果")

                local tm = 7

                if isCloseQSu == true then
                    tm = 0.5
                end

                schedulerSDK = performWithDelay(display.getRunningScene(),function()
                    luaPrint("超级盾初始化失败")
                    schedulerSDK = nil
                    isChangeSDK = true
                    GameConfig.serverVersionInfo.youXiDun = 1
                    initNet(1)
                end,tm)
            end
        elseif checkVersion("1.0.0") == 2 then
            initSDKRet = -6
            if schedulerSDK and not tolua.isnull(schedulerSDK) then
                display.getRunningScene():stopAction(schedulerSDK)
                schedulerSDK = nil
            end

            schedulerSDK = performWithDelay(display.getRunningScene(),function() luaPrint("超级盾初始化失败") end,7)
        else
            if initSDKRet ~= 0 then
                luaPrint("游戏盾初始化失败"..tostring(initSDKRet))
                if isLoginLayer == true then
                    addScrollMessage("游戏盾初始化失败"..tostring(initSDKRet))
                end
            else
                isSDKSuccess = 1
                return true
            end
        end
    end
end

function closePort(port)
    if device.platform == "ios" then
        local ret = 0
        local args = {port=port}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","closePort",args)
        if ok == false then
            luaPrint("luaoc调用出错:closePort")
        end
    end
end

function setJavaPort(ArgString)
    if isUseNetSDK ~= true then
        return
    end

    --低版本直连，不通过sdk
    if checkVersion() ~= 2 and runMode == "release" then
        isUseNetSDK = false
        return
    end

    if device.platform=="android" then
        local javaMethodName = "setJavaPort"
        local javaParams = {ArgString}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 setJavaPort")
        else
            return true
        end
    end
end

function initJavaSocket(ArgString)
    if isUseNetSDK ~= true then
        return
    end

    --低版本直连，不通过sdk
    if checkVersion() ~= 2 and runMode == "release" then
        isUseNetSDK = false
        return
    end

    if device.platform=="android" then
        local javaMethodName = "initJavaSocket"
        local javaParams = {ArgString}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 initJavaSocket")
        else
            return true
        end
    end
end

--卸载所有模块
function unloadAllRequire()
    for key,v in pairs(package.loaded) do --删除对应子游戏的package.loaded
        local pos0 = string.find(key,  "common.")
        local pos1 = string.find(key,  "layer.")
        local pos2 = string.find(key,  "launcher.")
        local pos3 = string.find(key,  "platform.")
        local pos4 = string.find(key,  "tools.")
        local pos5 = string.find(key,  "logic.")
        -- local pos6 = string.find(key,  "net.")
        local pos7 = string.find(key,  "dataModel.")
        if pos0 or pos1 or pos2 or pos3 or pos4 or pos5 or pos6 or pos7 then 
            package.loaded[key] = nil
        end
    end
end

--关闭layer
function closeGameOpenHallLayer()
    local layer = display.getRunningScene():getChildByName("shopLayer")

    if layer then
        layer:removeSelf()
    end

    layer = display.getRunningScene():removeChildByName("bankLayer")

    if layer then
        layer:removeSelf()
    end
end

function isHaveGameListLayer()
    local scene = display.getRunningScene()

    if scene:getChildByName("dr") then
        return true
    else
        if scene:getChildByName("dz") then
            return true
        end
    end

    return false
end

--购买提示
function showBuyTip(isExit)
    local prompt = GamePromptLayer:create()
    prompt:showPrompt("金币不足，是否进行充值?",true)
    prompt:setAutoClose(10)
    prompt:setBtnClickCallBack(
        function()
            if isExit == true then
                LoadingLayer:removeLoading()
                if globalUnit.gameName then
                    local a,b = Hall:getGameName(globalUnit.gameName)
                    if a == nil then
                        RoomLogic:stopCheckNet()
                        RoomLogic:close()
                    end
                else
                    RoomLogic:stopCheckNet()
                    RoomLogic:close()
                end
                dispatchEvent("loginRoom")
                Hall:exitGame(2,function() globalUnit.isEnterGame = false end,0)
            end
            createShop()
        end,
        function()
            if isExit == true then
                LoadingLayer:removeLoading()
                if globalUnit.gameName then
                    local a,b = Hall:getGameName(globalUnit.gameName)
                    if a == nil then
                        RoomLogic:stopCheckNet()
                        RoomLogic:close()
                    end
                else
                    RoomLogic:stopCheckNet()
                    RoomLogic:close()
                end
                dispatchEvent("loginRoom")
                Hall:exitGame(2,function() globalUnit.isEnterGame = false end,0)
            end
        end
    )
end

--初始化充值 默认隐藏
function initShop(hallLayer)
    -- if device.platform ~= "windows" and SettlementInfo:getConfigInfoByID(serverConfig.chongzhiUrl) ~= 0 and not display.getRunningScene():getChildByName("RechargeLayer") then
    --     local layer = require("layer.popView.RechargeLayer"):create()
    --     layer:setLocalZOrder(9999)
    --     display.getRunningScene():addChild(layer)
    -- end
end

function showShop()
    -- if PlatformLogic.loginResult.Alipay == "" and PlatformLogic.loginResult.BankNo == "" then
    --     local prompt = GameMessageLayer:create("common/wenxintishi.png","亲爱的玩家，请先绑定支付宝或银行卡，方便兑换！","hall/qubangding")
    --     prompt:setBtnClickCallBack(
    --         function()
    --             if not display.getRunningScene():getChildByName("SettlementLayer") then
    --                 display.getRunningScene():addChild(require("layer.popView.SettlementLayer"):create(1),9999999)
    --             end
    --         end
    --     )
    --     display.getRunningScene():addChild(prompt,9999999)
    --     return
    -- end

    -- if SettlementInfo.weChatCount > 0 then
    --     if not display.getRunningScene():getChildByName("shopLayer") then
    --         local layer = require("layer.popView.ShopLayer"):create()
    --         if Hall:isHaveGameLayer() then
    --             layer:setLocalZOrder(99999)
    --             display.getRunningScene():addChild(layer)
    --         else
    --             local ret,blayer = isHaveBankLayer()
    --             if ret then
    --                 blayer:addChild(layer)
    --             else
    --                 display.getRunningScene():addChild(layer)
    --             end
    --         end
    --     end
    -- else
    --     openWeb(GameConfig:getWebPay()..PlatformLogic.loginResult.dwUserID)
    -- end
    -- local rechargeLayer = display.getRunningScene():getChildByName("RechargeLayer")
    -- if rechargeLayer ~= nil then
    --     rechargeLayer:reload();
    -- else
    --     openWeb(GameConfig:getWebPay()..PlatformLogic.loginResult.dwUserID)
    -- end

    if not showBindPhone(2) then
        if not showBindPhone(3) then
            if not display.getRunningScene():getChildByName("shopLayer") then
                local layer = require("layer.popView.NewShopLayer"):create()
                if Hall:isHaveGameLayer() then
                    layer:setLocalZOrder(99999)
                    display.getRunningScene():addChild(layer)
                else
                    local ret,blayer = isHaveBankLayer()
                    if ret then
                        blayer:addChild(layer)
                    else
                        display.getRunningScene():addChild(layer)
                    end
                end
            end
            playEffect("hall/sound/addMoney.mp3")
        end
    end
end

function createShop()
    -- SettlementInfo:sendWeChatRequest()
    showShop()
end

function createDir(dirPath, isLastCreate)
    local dirs = string.split(dirPath,"/")
    local nextDir = cc.FileUtils:getInstance():getWritablePath()
    local len = #dirs

    for k,v in pairs(dirs) do
        if k == 1 then
            nextDir = nextDir..v
        else
            nextDir = nextDir.."/"..v
        end
        -- luaPrint("next  :"..nextDir)
        if k ~= len then
            createDirectory(nextDir)
        elseif k == len and isLastCreate ~= false then
            createDirectory(nextDir)
        end
    end
end

function filter_spec_chars(s)
    local ss = {}
    local k = 1
    local dian = "•"
    local dian1 = "·"

    s = string.gsub(s, dian, "")
    if #s == 0 then
        luaPrint("0000-- s = "..s)
        return true
    end

    s = string.gsub(s, dian1, "")
    if #s == 0 then
        luaPrint("0000-==- s = "..s)
        return true
    end

    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        print(c.." , "..string.char(c))
        if c<192 then
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                table.insert(ss, string.char(c))
            end
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss) ~= s
end

function isEmoji(newName)
    return filter_spec_chars(newName)
    -- local len = string.utf8len(newName)--utf8解码长度
    -- luaPrint("len -----======-------   "..len)
    -- for i = 1, len do
    --     local str = string.byte(newName, i)
    --     if not isEmojiCharacter(str) then
    --         return true
    --     end
    -- end

    --     local byteLen = 1;
    --     if str>0 and str<=127 then
    --         byteLen = 1                                               --1字节字符
    --     elseif str>=192 and str<223 then
    --         byteLen = 2                                               --双字节字符
    --     elseif str>=224 and str<=239 then
    --         byteLen = 3                                               --汉字
    --     elseif str>=240 and str<=247 then
    --         str = 4                                               --4字节字符
    --     elseif str>=248 and str<=251 then
    --         byteLen = 5
    --     elseif str>=252 and str<=253 then
    --         byteLen = 6
    --     end

    --     -- local byteLen = string.len(str)--编码占多少字节
    --     luaPrint("byteLen ----------     "..byteLen.."  str = "..str)
    --     if byteLen > 3 then--超过三个字节的必须是emoji字符啊
    --         return true
    --     end

    --     if byteLen == 3 then
    --         if string.find(str, "[\226][\132-\173]") or string.find(str, "[\227][\128\138]") then
    --             return true--过滤部分三个字节表示的emoji字符，可能是早期的符号，用的还是三字节，坑。。。这里不保证完全正确，可能会过滤部分中文字。。。
    --         else
    --             luaPrint("过滤部分三个字节表示的emoji字符，可能是早期的符号，用的还是三字节，坑。。。这里不保证完全正确，可能会过滤部分中文字。。。")
    --         end
    --     end

    --     if byteLen == 1 then
    --         local ox = string.byte(str)
    --         if (33 <= ox and 47 >= ox) or (58 <= ox and 64 >= ox) or (91 <= ox and 96 >= ox) or (123 <= ox and 126 >= ox) or (str == "　") then
    --             return true--过滤ASCII字符中的部分标点，这里排除了空格，用编码来过滤有很好的扩展性，如果是标点可以直接用%p匹配。
    --         end
    --     end
    -- end
    -- return false
end

function isEmojiCharacter(codePoint)
       return (codePoint == 0x0) or (codePoint == 0x9) or (codePoint == 0xA) or
                (codePoint == 0xD) or ((codePoint >= 0x20) and (codePoint <= 0xD7FF)) or
                ((codePoint >= 0xE000)and (codePoint <= 0xFFFD)) or ((codePoint >= 0x10000) and (codePoint <= 0x10FFFF))
end

--账号升级提示
function showAccountUpgrade(isCreate)
    if isCreate == nil then
        isCreate = true
    end

    luaPrint("globalUnit:getLoginType() --------------   "..globalUnit:getLoginType().."  "..guestLogin.." "..SettlementInfo:getConfigInfoByID(6))
    local ret = false

    -- if isEmptyString(PlatformLogic.loginResult.szMobileNo) then
    --     ret = true
    --     if isCreate == true then
    --         -- if SettlementInfo:getConfigInfoByID(6) > 0 then
    --             local layer = require("layer.popView.AccountUpLayer"):create()
    --             display.getRunningScene():addChild(layer)
    --         -- else
    --         --     showSign()
    --         -- end
    --     end
    -- else
    --     if isCreate == true then
    --         local layer = require("layer.popView.activity.RegisterLayerUp"):create()
    --         display.getRunningScene():addChild(layer)
    --     end
    -- end

    if not isEmptyString(PlatformLogic.loginResult.szMobileNo) then
        ret = true;
    end

    if isCreate == true then
        if SettlementInfo:getConfigInfoByID(serverConfig.popWindow) == 1 then
            if not display.getRunningScene():getChildByName("RegisterLayerUp") then
                local layer = require("layer.popView.activity.RegisterLayerUp"):create(ret)
                display.getRunningScene():addChild(layer)
            end
        else
            showNoticeLayer()
        end
    end

    return ret
end

function showBindPhone(isCreate)
    if isCreate == nil then
        isCreate = true
    end

    local ret = false

    if isEmptyString(PlatformLogic.loginResult.szMobileNo) and PlatformLogic.loginResult.IsCommonUser ~= 1 then
        ret = true
        if isCreate == true then--and SettlementInfo:getConfigInfoByID(6) > 0 then
            if PlatformLogic.loginResult.UserChouShui > 0 and isShowAccountUpgrade == nil then
                local layer = require("layer.popView.AccountUpLayer"):create()
                display.getRunningScene():addChild(layer,9999)
            else
                if isShowAccountUpgrade == true then
                    display.getRunningScene():addChild(require("layer.popView.AccountUpLayer"):create(1),9999)
                else
                    isShowAccountUpgrade = true
                end
            end
        elseif isCreate == 1 then
            local layer = GameMessageLayer:create("common/wenxintishi.png","为了您的账户安全，请先绑定您的手机号码！","hall/qubangding")
            layer:setBtnClickCallBack(
                function()
                    local layer = require("layer.popView.BindPhoneLayer"):create()
                    display.getRunningScene():addChild(layer)
                end)
            display.getRunningScene():addChild(layer)
        elseif isCreate == 2 then
            display.getRunningScene():addChild(require("layer.popView.AccountUpLayer"):create(2),9999)
        end
    else
        isShowAccountUpgrade = true
        if isCreate == 3 then
            if isEmptyString(PlatformLogic.loginResult.szRealName) then
                ret = true
                display.getRunningScene():addChild(require("layer.popView.BindNameLayer"):create())
            end
        end
    end

    return ret
end

function showSign(isShow)
    if isShow == nil then
        if SettlementInfo:getConfigInfoByID(serverConfig.qianDao) == 1 and SignInInfo.isSignIn ~= true then
            local layer = require("layer.popView.activity.SignIn.SignInLayer"):create()
            display.getRunningScene():addChild(layer)
        else
            if isShowAccountUpgrade == nil then
                display.getRunningScene():addChild(require("layer.popView.NoticeLayer"):create())
            end
        end
    else
        if SettlementInfo:getConfigInfoByID(serverConfig.qianDao) == 1 then
            local layer = require("layer.popView.activity.SignIn.SignInLayer"):create()
            display.getRunningScene():addChild(layer)
        end
    end
end

function showLucky()
    local layer = require("layer.popView.activity.duobao.LuckyLayer"):create()
    display.getRunningScene():addChild(layer)
end

--中文字符判断
function stringIsHaveChinese(str,iType)
    if str == nil then
        return false
    end

    if iType == 1 then
        -- local s = string.gsub(str, "^.", "")--标点符号
        -- if #s > 0 then
        --     luaPrint("00 s = "..s)
        --     return false
        -- end

        local s = string.gsub(str, "%P", "")--标点符号
        local dian = "•"
        if #s > 0 then
            luaPrint("11 s = "..s)
            return false
        end

        local s = string.gsub(str, dian, "")
        if #s == 0 then
            luaPrint("00 s = "..s)
            return false
        end

        local dian1 = "·"
        local s = string.gsub(s, dian1, "")
        if #s == 0 then
            luaPrint("0000 s = "..s)
            return false
        else
            str = s
        end

        local s = string.gsub(str, "%C", "")--控制符
        if #s > 0 then
            luaPrint("22 s = "..s)
            return false
        end

        local s = string.gsub(str, "%A", "")--数字
        if #s > 0 then
            luaPrint("33 s = "..s)
            return false
        end

        local s = string.gsub(str, "%D", "")--数字
        if #s > 0 then
            luaPrint("44 s = "..s)
            return false
        end

        local s = string.gsub(str, "%W", "")--数字
        if #s > 0 then
            luaPrint("55 s = "..s)
            return false
        end

        local s = string.gsub(str, "%S", "")--数字
        if #s > 0 then
            luaPrint("66 s = "..s)
            return false
        end

        -- local s = string.gsub(str, "[^~！？。，、|：；’；【】《》]", "")--数字
        -- local s = string.gsub(str, "[^~！？。，、|；‘]", "")--数字
        -- if #s > 0 then
        --     luaPrint("77 s = "..s)
        --     return false
        -- end
    end

    local l = #string.gsub(str, "[^\128-\191]", "")

    luaPrint("l ---------------     "..l)

    return (l ~= 0)
end

--版本比较
local ret = nil
function checkVersion(minVer)
    if device.platform == "windows" then
        return 2
    end

    local curVer = "1.0.0"--GameConfig.serverVersionInfo.androidVer--最低可用版本
    if minVer ~= nil then
        curVer = minVer
    end

    if not isEmptyString(curVer) then
        curVer = string.split(curVer,".")
    else
        curVer = {"0"}
    end

    local localVer = {"0"}

    if localAppVersion == nil then
        localAppVersion = onUnitedPlatformGetVersion()
    end

    if not isEmptyString(localAppVersion) then
        localVer = string.split(localAppVersion,".")
    else
        localVer = {"0"}
    end

    luaDump(localVer,"最终比较值 localVer")
    luaDump(curVer,"最终比较值 curVer")

    if type(localVer) == "table" and type(curVer) == "table" then
        local len = #localVer

        if len > #curVer then
            len = #curVer
        end

        for i=1,len do
            local vl = tonumber(localVer[i])
            local vc = tonumber(curVer[i])
            if vl and vc then
                if vl > vc then
                    return 2
                elseif vl < vc then
                    return 1
                end
            end
        end

        if #localVer > #curVer then
             local f = true
            for k,v in pairs(localVer) do
                if k > len then
                    if tonumber(v) and tonumber(v) > 0 then
                        f = false
                        break
                    end
                end
            end

            if not f then
                return 2
            end
        elseif #localVer < #curVer then
            local f = true
            for k,v in pairs(curVer) do
                if k > len then
                    if tonumber(v) and tonumber(v) > 0 then
                        f = false
                        break
                    end
                end
            end

            if not f then
                return 1
            end
        end
    end

    return 2
end

function openWeChat()
    if checkVersion() ~= 2 then
        addScrollMessage("此版本不可用复制功能，请升级")
        return
    end

    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","openWx")
        if ok == false then
            luaPrint("luaoc调用出错:openWx")
        else
            return true
        end
    elseif device.platform == "android" then
        local javaMethodName = "openWx"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 openWx")
        else
            return true
        end
    elseif device.platform == "windows" then
        return true
    end
end

--生成二维码
function createExtendQr()
    if PlatformLogic.loginResult == nil or PlatformLogic.loginResult.dwUserID == nil or isEmptyString(globalUnit.tuiguanUrlQr) then
        return
    end

    local path = cc.FileUtils:getInstance():getWritablePath()..PlatformLogic.loginResult.dwUserID..".png"

    if cc.FileUtils:getInstance():isFileExist(path) then
        cc.FileUtils:getInstance():removeFile(path)
    end

    if not cc.FileUtils:getInstance():isFileExist(path) then
        if checkVersion() == 2 then
            if GameConfig.serverVersionInfo.androidUrl then
                createQr(globalUnit.tuiguanUrlQr,PlatformLogic.loginResult.dwUserID..".png")
            else
                createQr(globalUnit.tuiguanUrlQr,PlatformLogic.loginResult.dwUserID..".png")
            end
        else
            createQr(globalUnit.tuiguanUrlQr,PlatformLogic.loginResult.dwUserID..".png")
        end
    end
end

--推广图片保存
function saveExtendImage(path,tag)
    if tag > 1 then
        return
    end

    if PlatformLogic.loginResult and PlatformLogic.loginResult.dwUserID then
        createExtendQr()
        captureNodeScreen(path,tag)
    end
end

--节点截屏
function captureNodeScreen(path,tag)
    if PlatformLogic.loginResult == nil or PlatformLogic.loginResult.dwUserID == nil then
        return
    end

    local fileName = PlatformLogic.loginResult.dwUserID.."extend"..os.time()..".jpg"
    local targetPath = cc.FileUtils:getInstance():getWritablePath()..fileName

    -- if not cc.FileUtils:getInstance():isFileExist(targetPath) then
        local winSize = cc.Director:getInstance():getWinSize()
        local sprite = cc.Sprite:create(path)
        sprite:setPosition(0,0)
        sprite:setAnchorPoint(0,0)

        local title = ccui.ImageView:create("newExtend/title.png")
        title:setPosition(sprite:getContentSize().width/2,sprite:getContentSize().height-title:getContentSize().height/2)
        title:setAnchorPoint(0.5,1)
        sprite:addChild(title)

        local qrpath = cc.FileUtils:getInstance():getWritablePath()..PlatformLogic.loginResult.dwUserID..".png"
        local qr = ccui.ImageView:create(qrpath)
        qr:setScale(0.7)
        qr:setPosition(sprite:getContentSize().width/2,sprite:getContentSize().height*0.55)
        sprite:addChild(qr)

        local lable = FontConfig.createWithSystemFont(PlatformLogic.loginResult.dwUserID,30)
        lable:setPosition(cc.p(sprite:getContentSize().width*0.55,sprite:getContentSize().height*0.16))
        sprite:addChild(lable)

        local target  = cc.RenderTexture:create(sprite:getContentSize().width*sprite:getScale(), sprite:getContentSize().height*sprite:getScale(), cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0);

        target:begin()

        sprite:visit()

        target:endToLua()

        qrPath = targetPath

        target:saveToFile(fileName, cc.IMAGE_FORMAT_PNG, false)
    -- end
end

--保存图片到系统相册
function saveSystemPhoto(tag)
    local fileName = PlatformLogic.loginResult.dwUserID.."extend.jpg"
    local targetPath = cc.FileUtils:getInstance():getWritablePath()..fileName

    if type(tag) == "string" then
        targetPath = tag
    end

    if not cc.FileUtils:getInstance():isFileExist(targetPath) then
        return
    end

    if checkVersion() ~= 2 then
        addScrollMessage("此版本不可用复制功能，请升级")
    else
        if device.platform == "ios" then
            local args = {str=targetPath}
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","saveImage",args)
            if ok == false then
                luaPrint("luaoc调用出错:saveSystemPhoto")
            else
                addScrollMessage("保存成功，请到相册中查看")
                return true
            end
        elseif device.platform == "android" then
            local javaMethodName = "saveImage"
            local javaParams = {targetPath}
            local javaMethodSig = "(Ljava/lang/String;)V"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 saveSystemPhoto")
            else
                addScrollMessage("保存成功，请到相册中查看")
                return true
            end
        elseif device.platform == "windows" then
            luaPrint("保存成功 windows 路径"..targetPath)
            return true
        end
    end
end

--密码判断
function verifyNumberAndEnglish(str)
    local s = string.gsub(str,"[%w]","")
    if not isEmptyString(s) then
        luaPrint("密码只能包含数字和字母 "..s)
        return false,"密码只能包含数字和字母(请不要输入空格和回车等)",1
    end

    s = string.gsub(str,"[%a]","")

    if isEmptyString(s) then
        luaPrint("不能纯字母,密码必须包含数字和字母 "..s)
        return false,"不能纯字母,密码只能包含数字和字母",2
    end

    s = string.gsub(str,"[%d]","")

    if isEmptyString(s) then
        luaPrint("不能纯数字,密码必须包含数字和字母 "..s)
        return false,"不能纯数字,密码只能包含数字和字母",3
    end

    return true
end

-- 手机验证码获取回调
function getCodeCallback(result, response)
    if result == false then
        luaPrint("获取验证码错误")
        addScrollMessage("网络不好，请稍后重试")
        dispatchEvent("getCodeSuccess",false)
        -- GameConfig:getSwitchWebUrl()
    else
        local str = json.decode(response)
        -- luaDump(str,"验证码获取")
        if tonumber(str.State) == 1 then
            addScrollMessage("验证码获取成功")
            dispatchEvent("getCodeSuccess",str.question)
        else
            addScrollMessage(str.Msg)
            dispatchEvent("getCodeSuccess",false)
        end
    end
end

--创建裁剪对象
function createClipNode(parent)
    local node = cc.ClippingNode:create()
    node:setAlphaThreshold(0)
    local front = cc.Sprite:createWithSpriteFrame(parent:getSpriteFrame())
    node:setStencil(front)
    node:setInverted(false)
    node:setAnchorPoint(0.5,0.5)
    node:setPosition(parent:getContentSize().width/2,parent:getContentSize().height/2)
    parent:addChild(node)

    return node
end

--时间转换
function timeConvert(tm,format)
    tm = tonumber(tm)
    if format == 2 then
        return os.date("%Y年%m月%d日",tm)
    elseif format == 3 then
        return os.date("%Y年%m月%d日 %H:%M:%S",tm)
    elseif format == 4 then
        return os.date("%H:%M",tm)
    elseif format then
        return os.date("%m月%d日",tm)
    else
        return os.date("%m月%d日 %H:%M:%S",tm)
    end    
end

--全局音乐音效控制
function setEffectIsPlay(isPlay)
    if isPlay == nil then
        isPlay = true
    end

    if isPlay then
        cc.UserDefault:getInstance():setIntegerForKey(effectKey,1)
    else
        cc.UserDefault:getInstance():setIntegerForKey(effectKey,0)
        audio.stopAllEffects()
    end
end

function setMusicIsPlay(isPlay)
    if isPlay == nil then
        isPlay = true
    end

    if isPlay then
        cc.UserDefault:getInstance():setIntegerForKey(musicKey,1)
    else
        cc.UserDefault:getInstance():setIntegerForKey(musicKey,0)
        stopMusic()
    end
end

function getEffectIsPlay()
    return cc.UserDefault:getInstance():getIntegerForKey(effectKey,1) == 1
end

function getMusicIsPlay()
    return cc.UserDefault:getInstance():getIntegerForKey(musicKey,1) == 1
end

function playEffect(filename, isLoop)
    audio.playSound(filename, isLoop)
end

function playMusic(filename, isLoop)
    audio.playMusic(filename, isLoop)
end

function stopMusic()
    audio.stopMusic()
end

--复制
function copyToClipBoard(str)
    str = tostring(str)

    if checkVersion() ~= 2 then
        addScrollMessage("此版本不可用复制功能，请升级")
        return
    end

    if device.platform == "ios" then
        local args = {str=str}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","copy",args)
        if ok == false then
            luaPrint("luaoc调用出错:copy")
        else
            return true
        end
    elseif device.platform == "android" then
        local javaMethodName = "copy"
        local javaParams = {str}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 copy")
        else
            return true
        end
    elseif device.platform == "windows" then
        return true
    end

    return false
end

--黏贴
function pasteFromClipBoard()
    if checkVersion() ~= 2 then
        addScrollMessage("此版本不可用复制功能，请升级")
        return
    end

    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","paste")
        if ok == false then
            luaPrint("luaoc调用出错:paste")
        else
            paste(ret)
        end
    elseif device.platform == "android" then
        local javaMethodName = "paste"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 paste")
        else
            -- onPaste(ret)
        end
    elseif device.platform == "windows" then
        return true
    end

    return nil
end

function onPaste(str)
    paste(str)
end

function paste(str,flag)
    local ret = true
    if str == nil then
        str = 0
        ret = false
    end

    luaPrint("黏贴字符 "..str)

    if globalUnit.readUserID ~= true then
        -- if device.platform == "android" then
        --     if checkVersion("1.0.0") == 2 then
        --         local id = getConfig("userid")
        --         if not isEmptyString(id) then
        --             globalUnit.registerInfo.referee = tonumber(id)
        --             globalUnit.readUserID = true
        --             return
        --         end
        --     end
        -- end

        local userid = ""

        if tonumber(str) ~= nil then
            userid = tostring((tonumber(str)))
        end

        local ret = false

        if #userid < 6 and userid ~= "" then
            --todo
        else
            if tonumber(userid) == nil then
                --新的推广参数
                if not isEmptyString(str) then
                    local args = string.split(str,"_")
                    if not isEmptyTable(args) and #args >= 3 then
                        globalUnit.registerInfo.referee = tonumber(args[1])
                        globalUnit.gameChannel = tostring(args[2])
                        globalUnit.registerInfo.registerid = tonumber(args[3])
                        ret = true
                        cc.UserDefault:getInstance():setStringForKey("opinfo", str)
                    end
                end
            else
                ret = true
                globalUnit.registerInfo.referee = tonumber(userid)
                if globalUnit.registerInfo.referee < 0 then
                    globalUnit.registerInfo.referee = 0
                    userid = "0"
                end
                cc.UserDefault:getInstance():setStringForKey("referee", userid)
                globalUnit.readUserID = true
            end
        end

        if not ret then
            if flag == nil then
                local opinfo = cc.UserDefault:getInstance():getStringForKey("opinfo", "")
                if not isEmptyString(opinfo) then
                    local args = string.split(opinfo,"_")
                    if not isEmptyTable(args) and #args >= 3 then
                        globalUnit.registerInfo.referee = tonumber(args[1])
                        globalUnit.gameChannel = tostring(args[2])
                        globalUnit.registerInfo.registerid = tonumber(args[3])
                    end
                else
                    globalUnit.registerInfo.referee = tonumber(cc.UserDefault:getInstance():getStringForKey("referee", "0"))
                end
                globalUnit.readUserID = true
                -- local url = "http://"..GameConfig.tuiguanUrl.."/Public/GetUserIP.aspx?ip="..getIPAddress().."&AgentID="..channelID
                -- HttpUtils:requestHttp(url, function(result, response) getUserIdFromServer(result, response) end)
            elseif flag == false then
                globalUnit.registerInfo.referee = tonumber(cc.UserDefault:getInstance():getStringForKey("referee", "0"))
                globalUnit.readUserID = true
            end
        end
    end

    dispatchEvent("pasteString",str)
end

function getUserIdFromServer(result, response)
    if result == false then
    else
        paste(response,false)
    end
end

--返回玩家性别
function getUserSex(id,isBoy)
    if id == nil or type(id) ~= "number" then
        id = 1
    end

    if not cc.FileUtils:getInstance():isFileExist("head/"..id..".png") then
        if isBoy == true then
            id = 1
        else
            id = 6
        end
    end

    if id > 0 and id < 6 then
        return true
    else
        return false
    end
end

--头像路径 id 头像id  isBoy 性别 isReturn 是否返回id
function getHeadPath(id,isBoy,isReturn)
    if id == nil or type(id) ~= "number" then
        id = 1
    end

    if not cc.FileUtils:getInstance():isFileExist("head/"..id..".png") then
        if isBoy == true then
            id = 1
        else
            id = 6
        end
    end

    if isReturn ~= nil then
        return "head/"..id..".png",id
    else
        return "head/"..id..".png"
    end
end

--游戏内创建保险箱
--callback 回调函数 
-- 回调函数的参数
-- {
--     {"UserID","INT"},                             --//用户ID
--     {"Score","LLONG"},                            --//分数  
--     {"ret","INT"},                                --//存取分结果  
-- };
--isQu true 可以取，其他 不能取，默认不能取
function createBank(callback,isQu)
    if globalUnit.isEnterGame ~= true then
        return
    end

    local text = "保险箱"
    if globalUnit.isYuEbao == true then
        text = "余额宝"
    end

    if globalUnit.isTryPlay == true then
        addScrollMessage("体验场不能操作"..text)
        return
    end

    if isQu == nil then
        isQu = false
    end

    -- if  isEmptyString(PlatformLogic.loginResult.szMobileNo) then
    --     addScrollMessage("需先绑定手机号码")
    --     return
    -- end

    if PlatformLogic.loginResult.bSetBankPass == 0 then
        addScrollMessage("需先设置"..text.."密码")
        return
    end

    if isHaveBankLayer() then
        dispatchEvent("isCanSendGetScore", isQu)
        if isQu == false then
            addScrollMessage("游戏开奖中，请稍后进行取款操作")
        end
    else
        if isQu == true then
            local layer 

            if globalUnit.isYuEbao == true then
                layer = require("layer.popView.activity.yuebao.YuEBaoLayer"):create(callback)
            else
                layer = require("layer.popView.BankLayer"):create(callback)
            end

            if layer then
                layer:setName("bankLayer")
                display.getRunningScene():addChild(layer,99999)
            end
        else
            addScrollMessage("游戏开奖中，请稍后进行取款操作")
        end
    end
end

--是否有保险柜
function isHaveBankLayer()
    local layer = display.getRunningScene():getChildByName("bankLayer")
    if layer then
        return true,layer
    end

    return false
end

--全局滚动消息
function addScrollMessage(message)
    message = tostring(message)
    Hall:showNewScrollMessage(message)
end

--金币转换函数
function goldConvert(gold,isNum)
    if type(gold) ~= "number" then
        gold = tonumber(gold)
    end

    if isNum == nil then
        return gold/100
    else
        return string.format("%.2f", gold/100)
    end
end

--金币转换函数,保留四位小数
function goldConvertFour(gold,isNum)
    if type(gold) ~= "number" then
        gold = tonumber(gold)
    end

    if isNum == nil then
        return gold/10000
    elseif isNum == 2 then
        return string.format("%.2f", gold/10000)
    else
        return string.format("%.4f", gold/10000)
    end
end

function goldReconvert(gold)
    local s = tostring(gold)

    local i,j = string.find(s,"%.")

    if i and j then
        local s1 = string.sub(s,i+1,#s)

        -- luaPrint("s1 = "..s1)
        if #s1 == 1 then
            local rt,a = checkNumber(s)

            if rt == false then
                s = a.."0"
            end
        elseif #s1 == 2 then
            local rt,a = checkNumber(s)
            -- luaPrint("a = "..a)
            if rt == false then
                s = a
            end
        else
            s = string.sub(s,1,i+2)
            local rt,a = checkNumber(s)
            -- luaPrint("a = "..a)
            if rt == false then
                s = a
            end
        end
    else
        s = s.."00"
    end

    return math.ceil(tonumber(s))
end

--输入框
function createEditBox(parent,text,inputType,mode,size,path,color)
    local s = parent:getContentSize()
    color = color or cc.c3b(216,226,233)

    local editBg = ccui.ImageView:create("input/editBg.png")
    if parent.epath then
        editBg:loadTexture(parent.epath)
    end
    if path ~= nil then
        editBg:loadTexture(path)
    end

    if size then
        editBg:setScale9Enabled(true)
        editBg:setContentSize(size)
    end
    editBg:setPosition(cc.p(s.width+20, s.height*0.5))
    editBg:setAnchorPoint(0.0,0.5)
    parent:addChild(editBg)

    local phoneTextEdit = ccui.EditBox:create(editBg:getContentSize(),ccui.Scale9Sprite:create())
    phoneTextEdit:setAnchorPoint(cc.p(0.5,0.5))
    phoneTextEdit:setPosition(cc.p(editBg:getContentSize().width/2, editBg:getContentSize().height/2))
    phoneTextEdit:setFontSize(28)
    phoneTextEdit:setPlaceHolder(text)
    phoneTextEdit:setPlaceholderFontColor(color)
    phoneTextEdit:setPlaceholderFontSize(20)
    phoneTextEdit:setMaxLength(20)
    editBg:addChild(phoneTextEdit)

    if inputType == cc.EDITBOX_INPUT_MODE_PHONENUMBER then
        phoneTextEdit:setMaxLength(11)
    elseif inputType == cc.EDITBOX_INPUT_FLAG_PASSWORD then
        phoneTextEdit:setMaxLength(20)
    else
        phoneTextEdit:setMaxLength(20)
    end

    if mode == nil then
        phoneTextEdit:setInputFlag(inputType)
    else
        phoneTextEdit:setInputMode(inputType)        
    end

    return phoneTextEdit,editBg
end

--获取验证码按钮
function createPhoneCodeBtn(parent,callback,tm)
    tm = tm or 30

    local func = function(sender)
        local ret = true

        if isSetTuiguangUrl == nil then
            local str = getWebBestIP("kktuiguang")
            local result = string.split(str,":")
            luaPrint("SettlementInfo 3 sdk result ====",str)
            if #result > 1 then
                local ip = result[1]
                local port = tonumber(result[2])
                if checkVersion("1.0.0") == 2 and GameConfig.serverVersionInfo.youXiDun == 1 then
                    local qianzhui = string.split(GameConfig.tuiguanUrl,":")[1]
                    GameConfig.tuiguanUrl = qianzhui.."://"..ip..":"..port
                elseif checkVersion("1.0.0") == 2 then
                    local qianzhui = string.split(GameConfig.tuiguanUrl,":")[1]
                    GameConfig.tuiguanUrl = qianzhui.."://"..ip..":"..port
                else
                    GameConfig.tuiguanUrl = GameConfig.tuiguanUrl..":"..port
                end
            end
            isSetTuiguangUrl = true;
        end

        if callback then
           ret = callback(sender)
        end

        if not ret then
            return
        end

        -- sender:setEnabled(false)
        -- sender:loadTextures("input/getNo.png","input/getNo-on.png")

        -- local text = FontConfig.createWithCharMap(tm.."s","input/inputNum.png",16,23,"0",{{"s",":"}})
        -- text:setPosition(sender:getContentSize().width/2,sender:getContentSize().height/2)
        -- sender:addChild(text)
        -- text:setTag(tm)

        -- local fun = function() 
        --     local tag = text:getTag()

        --     tag = tag - 1

        --     if tag < 0 then
        --         text:removeSelf()
        --         sender:setEnabled(true)
        --         sender:loadTextures("input/get.png","input/get-on.png")
        --     else
        --         text:setText(tag.."s",{{"s",":"}})
        --         text:setTag(tag)
        --     end
        -- end

        -- schedule(text, fun, 1)
    end

    local codeBtn = ccui.Button:create("input/get.png","input/get-on.png")
    codeBtn:setAnchorPoint(cc.p(0,0.5))
    codeBtn:setPosition(parent:getContentSize().width+20, parent:getContentSize().height/2)
    parent:addChild(codeBtn)
    codeBtn:onClick(func)

    return codeBtn
end

function checkPhoneNum(var)
    if not var then
        return false
    end

    return string.match(var,"[1][%d]%d%d%d%d%d%d%d%d%d") == var
    -- local b = tonumber(var) -- b="number"
    -- luaPrint(b)
    -- if (b==nil) then
    --     luaPrint("is not number")
    --     return false
    -- end
    -- luaPrint("var=========="..var)

    -- if(#var ~= 11) then
    --     return false
    -- end

    -- local array =
    --     {
    --         "133","153","180","189", --电信
    --         "130","131","132","145", --联通
    --         "155","156","185","186",
    --         "134","135","136","137", --移动
    --         "138","139","147","150",
    --         "151","152","157","158",
    --         "159","182","187","188"
    --     }

    -- luaPrint(string.sub(var,0,3))


    -- for i = 1, #array do
    --     if(array[i] == string.sub(var,0,3)) then
    --         return true
    --     end
    -- end
    -- return false
end

function checkEmail(str)
    if string.len(str or "") < 6 then return false end
    local b,e = string.find(str or "", '@')
    local bstr = ""
    local estr = ""
    if b then
        bstr = string.sub(str, 1, b-1)
        estr = string.sub(str, e+1, -1)
    else
        return false
    end


    -- check the string before '@'
    local p1,p2 = string.find(bstr, "[%w_]+")
    if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end


    -- check the string after '@'
    if string.find(estr, "^[%.]+") then return false end
    if string.find(estr, "%.[%.]+") then return false end
    if string.find(estr, "@") then return false end
    if string.find(estr, "%s") then return false end --空白符
    if string.find(estr, "[%.]+$") then return false end

    _,count = string.gsub(estr, "%.", "")
    if (count < 1 ) or (count > 3) then
        return false
    end

    return true
end

function openWeb(url)
    if not isEmptyString(url) then
        luaPrint(url)
        cc.Application:getInstance():openURL(url)
    end
end

--随机数
function random(startNumber,endNumber)
    return math.random(startNumber,endNumber)
end

--节点中心位置
function getNodeCenter(node)
    local width = node:getContentSize().width;
    local height = node:getContentSize().height;

    return cc.p(width/2,height/2);
end

--屏幕中心位置
function getScreenCenter()
    local winSize = cc.Director:getInstance():getWinSize();
    return cc.p(winSize.width/2,winSize.height/2);
end

function loadNewCsb(self,csb,uiTable)
    if self then
        self.csbNode = cc.CSLoader:createNode(csb..".csb")
        self.csbNode:setCascadeOpacityEnabled(true)
        self.csbNode:setCascadeColorEnabled(true)
        self:addChild(self.csbNode)
        iphoneXFit(dealNewlUI(self,uiTable))
    else
        local node = cc.CSLoader:createNode(csb..".csb")
        node:setCascadeOpacityEnabled(true)
        node:setCascadeColorEnabled(true)
        dealNewlUI(node,uiTable)
        return node
    end    
end

function loadNewJson(self,json,uiTable)
    self.csbNode =  ccs.GUIReader:getInstance():widgetFromJsonFile(json..".json")
    self:addChild(self.csbNode)
    iphoneXFit(dealNewlUI(self,uiTable))
end

--获取node节点
--self csb父类即创建的layer
--uiTable想要获取的节点列表 形如
-- local uiTable = {
--         "loginBtn" = Button_login,--=前 变量名 =后 csb中控件名
--     }
function dealNewlUI(self,uiTable)
    local csbNode = self.csbNode
    if not csbNode then
        return
    end

    local node = nil

    for k,v in pairs(uiTable or {}) do
        local data = nil
        local tagrt = nil
        if type(v) == "table" then
            data = v[2]
            tagrt = v[3]
            v = v[1]
        end
        self[k] = ccui.Helper:seekNodeByName(csbNode,v)
        if self[k] then
            self[k].pType = data
            self[k].pTarget = tagrt

            if string.find(k,"_bg") ~= nil or string.find(v,"_bg") ~= nil then
                luaPrint("适配对象 k = "..k.." v = "..v)
                node = self[k]
            end

            if string.find(v,"Clip") ~= nil then--裁剪
                local node = cc.ClippingNode:create()
                node:setAlphaThreshold(0)
                local front = cc.Sprite:createWithSpriteFrame(self[k]:getSpriteFrame())
                node:setStencil(front)
                node:setInverted(false)
                node:setAnchorPoint(0.5,0.5)
                node:setPosition(self[k]:getContentSize().width/2,self[k]:getContentSize().height/2)
                self[k]:addChild(node)
                self[k] = node
            elseif string.find(v,"EditBox") ~= nil then--输入框
                local node = ccui.EditBox:create(self[k]:getCustomSize(),ccui.Scale9Sprite:create())
                node:setAnchorPoint(self[k]:getAnchorPoint())
                node:setPosition(self[k]:getPosition())
                node:setFontSize(self[k]:getFontSize())
                node:setFontColor(self[k]:getColor())
                node:setPlaceHolder(self[k]:getPlaceHolder())
                node:setPlaceholderFontColor(self[k]:getPlaceHolderColor())
                if self[k]:getMaxLength()>0 then
                    node:setMaxLength(self[k]:getMaxLength())
                end
                node:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE);
                node:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
                node:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
                self[k]:getParent():addChild(self.view)
                self[k]:removeFromParent();
                self[k] = node
            end
        end
    end

    return node
end

--table 长度
function getTableLength(value)
    return table.nums(value);
end

--零点坐标
function getZeroPosition()
    return cc.p(0,0);
end

-----add---------------------------------------------------------------------------------
function removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end

function cleanTable(localTable)
    for i=#localTable, 1, -1 do
        table.remove(localTable,i)
    end
end

function isEmptyString(pStr)
    if pStr == nil or pStr == "" then
        return true
    end
    return false
end

function isEmptyTable(localTable)
    if localTable == nil or (type(localTable) == "table" and next(localTable) == nil) then
        return true;
    end

    return false;
end

--截取昵称
function FormotGameNickName(nickname,len)
    if nickname==nil then
        return ""
    end

    local lengthUTF_8 = #(string.gsub(nickname, "[\128-\191]", ""))
    if lengthUTF_8 <= len then
        return nickname
    else
        local matchStr = "^"
        for var=1, len do
            matchStr = matchStr..".[\128-\191]*"
        end
        local str = string.match(nickname, matchStr)
        return string.format("%s..",str);
    end
end

--格式化数字
--超过6位数，截断万位，用万字替代
--超过9位数，截断亿位，用亿字替代
--num 数字
--iType 非空为数字图片
function FormatNumToString(num,iType)
 --type = 1  表示数字标签里有万亿 用":;" "<="代替 万 亿   
    num = num or 0

    local s = FormatFloatToNum(num);
    local len = string.len(tostring(s));
    
    if len >= 6 and len < 9 then
        if iType ~= nil then
            s = string.format("%.2f", num)-- .. ":;"
        else
            s = string.format("%.2f", num)-- .. "万"
        end
    elseif len >= 9 then
        if iType ~= nil then
            s = string.format("%.2f", num)-- .. "<="
        else
            s = string.format("%.2f", num)-- .. "亿"
        end
    else
        s = num;
    end

    return s;
end

function FormatFloatToNum(num)
    if num <= 0 then
       return math.ceil(num);
    end

    if num > 0 then
        return math.floor(num);
    end
end

function FormatDigitToString(num,limit)
    local s = num;
    local len = string.len(tostring(num));
    
    if len >= 5 and len < 9 then
        s = string.format("%."..limit.."f", num/10000) .. "万"
    elseif len >= 9 then
        s = string.format("%."..limit.."f", num/100000000) .. "亿"
    end
    return s;
end

--游戏中注册局部事件 所有事件都通过此接口注册
--target 触发事件的对象
--eventName 事件名
--func 处理函数
function bindEvent(target,eventName,func)
    return BindTool.bind(target,eventName,func)
end

--注销事件
function unbindEvent(handlerIndex)
    BindTool.unbind(handlerIndex)
end

--全局事件
function bindGlobalEvent(eventName,func)
    return BindTool.globalBind(eventName,func)
end

function dispatchEvent(eventName,values)
    BindTool.dispatchEvent(eventName,values)
end

--展示合伙人广告
function showAdvertising()
    local layer = require("layer.popView.activity.BossLayer"):create()
    if layer then
        display.getRunningScene():addChild(layer);
    end
end

--展示公告
function showNoticeLayer()
    if not display.getRunningScene():getChildByName("noticeLayer") then
        local layer = require("layer.popView.NoticeLayer"):create()
        if layer then
            display.getRunningScene():addChild(layer);
        end
    end
end

OpenInstallData_Install = nil

function getOpenInstall(callback)
    if checkVersion() == 2 and device.platform ~= "windows" then
        OpenInstall = require("openinstall.openinstall")

        local function jsonToTable(jsonStr)
            local str = jsonStr;
            -- local str = "{\"channelCode\":\"\",\"bindData\":\"{\"channel\":\"6428161593\",\"userid\":\"4073930\"}\"}";
            local str2 = string.gsub(str,"\\",'')
            local str3 = string.gsub(str2,"\"{\"","{\"")
            local str4 = string.gsub(str3,"\"}\"","\"}");
            local installTable = json.decode(str4);
            return installTable;
        end

        local function getInstallCallBack(result)
            luaPrint("安装参数回调:"..result)
            OpenInstallData_Install = jsonToTable(result);
            luaDump(OpenInstallData_Install, "getInstallCallBack--------OpenInstallData_Install")
            -- local str = '{\"channelCode\":\"\",\"bindData\":\"{\"channel\":\"6428161593\",\"userid\":\"4073930\"}\"}';
            
            if not isEmptyString(OpenInstallData_Install.bindData.registerid) then
                globalUnit.registerInfo.registerid = tonumber((tonumber(OpenInstallData_Install.bindData.registerid)))
            end

            if not isEmptyString(OpenInstallData_Install.bindData.userid) then
                globalUnit.registerInfo.referee = tonumber((tonumber(OpenInstallData_Install.bindData.userid)))
            end

            if not isEmptyString(OpenInstallData_Install.channelCode) then
                globalUnit.gameChannel = OpenInstallData_Install.channelCode
            else
                if not callback then
                    getGameChannel()
                end
            end

            local ret = false
            if isEmptyString(OpenInstallData_Install.bindData.registerid) or isEmptyString(OpenInstallData_Install.bindData.userid) then
                pasteFromClipBoard()
                if device.platform == "android" then
                    ret = true--android获取剪切板内容是异步的，延时执行回调
                end
            end

            if ret then
                if callback then
                    performWithDelay(display.getRunningScene(),callback,0.1)
                end
            else
                if callback then
                    callback()
                end
            end
        end

        OpenInstall:getInstall(10, getInstallCallBack)
    else
        if callback then
            callback()
        else
            getGameChannel()
            pasteFromClipBoard()
        end
    end
end

function openInstallReportRegister()
    if checkVersion() == 2 and device.platform ~= "windows" and isOpenInstallReport == nil then
        OpenInstall = require("openinstall.openinstall")
        if OpenInstallData_Install and OpenInstallData_Install.bindData and not isEmptyString(OpenInstallData_Install.bindData.userid) and not isEmptyString(OpenInstallData_Install.channelCode) then
            isOpenInstallReport = true
            OpenInstall:reportRegister()
        end
    end
end

function addSound()
    local num = 0;
    local str = "";
    math.randomseed(tostring(os.time()):reverse():sub(1,7))
    num = math.random(1,4);
    str = "hall/sound/game"..num..".mp3";
    if str ~= "" then
        playEffect(str)
    end
end

--打开推广界面
function createGeneralizeLayer()
    local layer;
    if SettlementInfo:getConfigInfoByID(47) == 0 then
        layer = require("layer.popView.newExtend.Generalize.GeneralizeLayer"):create()
    else
        layer = require("layer.popView.newExtend.newGeneralize.NewGeneralizeLayer"):create()
    end
    if layer then
        display.getRunningScene():addChild(layer);
    end
end

--打开余额宝界面
function showYuEBaoLayer()
    local layer;
    luaPrint("showYuEBao",PlatformLogic.loginResult.bSetBankPass);
    if PlatformLogic.loginResult.bSetBankPass == 0 then
        layer = require("layer.popView.activity.yuebao.ShengFenYanZheng"):create();
    else
        luaPrint("getBankPwd()",globalUnit:getBankPwd());
        layer = require("layer.popView.activity.yuebao.YuEBaoLayer"):create()
    end

    if layer then
        display.getRunningScene():addChild(layer)
    end
end

--文本数字动画
function changeNumAni(pNode,targetNum,bHide)
    if pNode == nil then
        return;
    end
    luaPrint("targetNum===========",targetNum)
    pNode:stopAllActions();
    schedule(pNode,function()
        local from = pNode:getString()*100;
        if from == 0 then
            from = targetNum;
        end
        local to = targetNum;
        local index = 0;
        local cha = to-from;
        if math.abs(cha) >= 100 then
            if cha > 0 then
                index = 100;
            else
                index = -100;
            end
        elseif math.abs(cha) < 100 and math.abs(cha) >=1 then
            if cha > 0 then
                index = 1;
            else
                index = -1;
            end
        end
        local cur = from + index;
        local remainderNum = cur%100;
        local remainderString = "";

        if remainderNum == 0 then--保留2位小数
            remainderString = remainderString..".00";
        else
            if remainderNum%10 == 0 then
                remainderString = remainderString.."0";
            end
        end
        if bHide then
            remainderString = "";
        end
        pNode:setString((cur/100)..remainderString);
        if cur == to then
            pNode:stopAllActions();
        end

    end,0.01)
end