local PlatformLogic = class("PlatformLogic")
local PlatformDeal = require("net.platform.PlatformDeal")

local _platformLogic = nil;

function PlatformLogic:getInstance()
    if _platformLogic == nil then
        _platformLogic = PlatformLogic.new();
    end

    return _platformLogic;
end

function PlatformLogic:ctor()
    self:createSocket()

    self.ip = GameConfig.A_SERVER_IP
    self.port = GameConfig.A_SERVER_PORT
    self.cServer = false
    self.connected = false
    self.lockSendValue = false
    self.checkCode = 0
    self.loginResult = {}
    self.isLogined = false;
    self.isBindEvent = false;
    self.centerMessage = nil;

    self.platformDeal = PlatformDeal:getInstance()
end

function PlatformLogic:createSocket()
    -- if self.socketLogic then
    --     self.socketLogic:release()
    --     self.socketLogic = nil
    -- end

    self.socketLogic = HNSocketLogic:create(function(msg)
        self:onSocketMessage(msg)
    end,"platform")
    self.socketLogic:setDataEncry(1)
    if self.socketLogic.setNetSwitch then
        --低版本直连，不通过sdk
        -- if checkVersion("1.0.0") ~= 2 and runMode == "release" then
        --     isUseNetSDK = false
        -- end

        if device.platform ~= "windows" then
            if isUseNetSDK == true then
                self.socketLogic:setNetSwitch(1)
            else
                self.socketLogic:setNetSwitch(0)
            end
        else
            self.socketLogic:setNetSwitch(0)
        end
    end
    self.socketLogic:retain()

    -- if self.sendData then
    --     self.sendData:release()
    --     self.sendData = nil
    -- end

    self.sendData = HNSocketProtocolData:new()
    self.sendData:retain()
    self.sendData:setDataEncry(1)
    self.sendData:setCheckCode(0)
end

function PlatformLogic:clear()
    self:close();
    _platformLogic = nil;

    self.ip = GameConfig.A_SERVER_IP
    self.port = GameConfig.A_SERVER_PORT
    self.cServer = false
    self.connected = false
    self.lockSendValue = false
    self.checkCode = 0
    self.loginResult = {}
    self.isLogined = false;
    
    self.socketLogic:release()

    PlatformLogic = nil;
end

function PlatformLogic:close()
    -- self:stopListener();
    luaPrint("platformLogic close 网络断开")
    self.connected = false;
    self.isLogined = false;

    self.socketLogic:close();
    self.sendData:setCheckCode(0)
end

function PlatformLogic:stopListener()
    if self.platformDeal then
        self.isBindEvent = false;
        self.platformDeal:stop();
    end
end

function PlatformLogic:startListener()
    if self.platformDeal then
        if self.isBindEvent == true then
            return;
        end

        self.isBindEvent = true;
        self.platformDeal:start();
    end
end

function PlatformLogic:isConnect()
    return self.connected;
end

function PlatformLogic:isLogined()
    return self.isLogined;
end

function PlatformLogic:lock()
    if self.lockSendValue then
        return true
    else
        self.lockSendValue = true
        return false
    end
end

function PlatformLogic:unlock()
    self.lockSendValue = false
end

function PlatformLogic:connect()
    self:close();
    -- self:createSocket()
    self:stopListener();
    self:startListener();
    luaPrint("PlatformLogic:connect -------- self.ip "..self.ip.." self.port "..self.port)
    registerNetPort(self.port)

    local ret = false

    if isYouxidun == true and checkVersion() == 2 then
        ret = true
    end

    if ret then
        local func = function()
            self.isToConnect = true

            if not HallLayer:getInstance() then
                if not self.sdkSuccect then
                    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求配置中,请稍后"), LOADING):removeTimer(10,function() globalUnit.isSDKInit = true end)
                end
            end
        end

        if GameConfig.serverVersionInfo.youXiDun == 1 then
            if initNet() then
                func()

                getBestIP(self.port)
            end
        else
            func()

            if initNet() then
                getBestIP(self.port)
            end
        end
    else
        if checkVersion() == 2 then
            if isUseNetSDK then
                self.isToConnect = true

                if not HallLayer:getInstance() then
                    if not self.sdkSuccect then
                        LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求配置中,请稍后"), LOADING):removeTimer(10,function() globalUnit.isSDKInit = true end)
                    end
                end

                getBestIP()
            else
                if not HallLayer:getInstance() then
                    if not self.cServer then
                        LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录A服中,请稍后"), LOADING):removeTimer(10,function() globalUnit.isSDKInit = true end)
                    else
                        LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录服中,请稍后"), LOADING):removeTimer(10,function() globalUnit.isSDKInit = true end)
                    end
                end
                self.socketLogic:openWithIp(self.ip,self.port)
            end
        else
            if isUseNetSDK and device.platform == "ios" then
                self.ip = "127.0.0.1"
                performWithDelay(display:getRunningScene(),
                    function()
                        if not HallLayer:getInstance() then
                            if not self.cServer then
                                if not self.sdkSuccect then
                                    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求配置中,请稍后"), LOADING):removeTimer(10,function() globalUnit.isSDKInit = true end)
                                else
                                    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录A服中,请稍后"), LOADING):removeTimer(10,function() globalUnit.isSDKInit = true end)
                                end
                            else
                                LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录服中,请稍后"), LOADING):removeTimer(10)
                            end
                        end
                        self.socketLogic:openWithIp(self.ip,self.port) end,
                    0.3)
            else
                if not HallLayer:getInstance() then
                    if not self.cServer then
                        LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录A服中,请稍后"), LOADING):removeTimer(10,function() globalUnit.isSDKInit = true end)
                    else
                        LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录服中,请稍后"), LOADING):removeTimer(10)
                    end
                end
                self.socketLogic:openWithIp(self.ip,self.port)
            end
        end
    end
end

function PlatformLogic:send(mainID,assitantID,obj,config)
    if 88 ~= mainID then
        self:startListener();
    end
    
    -- local sendData = HNSocketProtocolData:new()
    self.sendData:clear()
    self.sendData:setDataEncry(1);--设置通信数据是否加密 1 加密 其他不加密
    local objSize = config and getObjSize(config) or 0
    self.sendData:writeHead(objSize+20,mainID,assitantID or 0,0,self.checkCode)
    if obj then
        convertToC(self.sendData,obj,config)
    end

    self.socketLogic:setDataEncry(1);

    local ret = self.socketLogic:send(self.sendData)
    
    luaPrint("PlatformLogic send msg mainID "..mainID.." assitantID "..assitantID);

    if ret <= 0 then
        if globalUnit.isEnterGame == true and Hall:isHaveGameLayer() == true then
            if globalUnit.m_gameConnectState ~= STATE.STATE_CONNECTING then
                RoomLogic:close();
                Event:dispatchEvent("game","I_R_M_DisConnect");
                Event:dispatchEvent("game","I_RR_M_DisConnect");
            end
            return;
        end

        if globalUnit.m_gameConnectState ~= STATE.PLATFORM_STATE_CONNECTING then
            self:close();
            Event:dispatchEvent("platform","I_P_M_DisConnect");
        end
    end
end

function PlatformLogic:onSocketMessage(msg)
    local status = msg:getStatus()
    luaPrint("status ==================  ",status)
    if socketRecv == status then
        local mainID = msg:getHead(2)
        local assitantID = msg:getHead(3)
        luaPrint("PlatformLogic Recv mainID：",mainID,"assitantID：",assitantID," objSize", msg:getHead(1)," globalUnit.isEnterGame = ",tostring(globalUnit.isEnterGame))
        dispatchEvent("platformHeart")

        if mainID == 88 and assitantID == 1 then
        else
            Event:sendEvent(msg:getHead(2),msg,"platform")
        end
    elseif  socketDisConnect1 == status or socketDisConnect2 == status or socketDisConnect3 == status or socketOutTime == status or socketError == status then
        if globalUnit.isEnterGame == true then
            return;
        end

        if globalUnit.m_gameConnectState ~= STATE.PLATFORM_STATE_CONNECTING then
            self:close();
            luaPrint("发送网络断开事件 "..status);
            Event:dispatchEvent("platform","I_P_M_DisConnect");
        end

        uploadInfo("netDisConnect","消息收到断网状态 ="..tostring(status)..logInfo)
        -- performWithDelay(display.getRunningScene(),function() luaPrint("断线事件")  luaPrint(a..b) end,1)
    elseif SocketConnect == status then
        if isYouxidun == true and runMode == "release" then
            self:send(PlatformMsg.MDM_GP_CONNECT,PlatformMsg.MDM_GP_GETCODE)
        else
            if isUseNetSDK and checkVersion() == 2 then
                self.socketLogic:sendSdk(self.port)
            else
                self:send(PlatformMsg.MDM_GP_CONNECT,PlatformMsg.MDM_GP_GETCODE)
            end
        end
    elseif SocketSDK == status then
        if checkVersion("1.0.0") == 2 then
            local handlecode = msg:getHead(4)
            luaPrint("sdk第一个消息",handlecode)
            if handlecode == 1 then
                self:send(PlatformMsg.MDM_GP_CONNECT,PlatformMsg.MDM_GP_GETCODE)
            else
                local cf = {
                    {"ret", "CHARSTRING[1000]"}
                }
                local data = convertToLua(msg,cf)
                luaDump(data,"sdk第一个消息")
                LoadingLayer:removeLoading()
                local s = string.split(data.ret,"_")
                local str = "连接游戏服务器失败,错误代码:"..handlecode
                for k,v in pairs(s) do
                    if not isEmptyString(v) then
                        str = str..","
                    end
                    str = str..v
                    if k == 1 then
                        local va = tonumber(v)
                        if va == 1001 then
                            str = str.."(网络异常)"
                        elseif va == 2001 then
                            str = str.."(AppKey为空)"
                        elseif va == 2002 then
                            str = str.."(AppKey错误)"
                        elseif va == 2003 then
                            str = str.."(SDK未初始化)"
                        elseif va == 4001 then
                            str = str.."(获取IP失败)"
                        elseif va == 4002 then
                            str = str.."(获取IP频繁)"
                        elseif va == 5001 then
                            str = str.."(转发端口未启用)"
                        elseif va == 5002 then
                            str = str.."(节点连接失败)"
                        elseif va == 10000 then
                            str = str.."(未知错误)"
                        end
                    end
                end
                addScrollMessage(str)
            end
        else
            local cf = {
                {"ret", "CHARSTRING[1]"}
            }
            local data = convertToLua(msg,cf)
            luaDump(data,"sdk第一个消息")
            data = tonumber(data.ret)
            if data == 1 then
                self:send(PlatformMsg.MDM_GP_CONNECT,PlatformMsg.MDM_GP_GETCODE)
            else
                LoadingLayer:removeLoading()
                addScrollMessage("连接游戏服务器失败")
            end
        end
    end
end

-- // 获取房间列表
function PlatformLogic:getRoomList(uKindID, uNameID)
    local roomList = RoomInfoModule:getRoomInfoByNameID(uNameID)
    if #roomList == 0 then
        local msg = {};
        msg.uKindID = uKindID;
        msg.uNameID = uNameID;
        self:send(PlatformMsg.MDM_GP_LIST, PlatformMsg.ASS_GP_LIST_ROOM, msg, PlatformMsg.MSG_GP_SR_GetRoomStruct);
    else
        Event:dispatchEvent("platform","I_P_M_RoomList");
    end
end

function PlatformLogic:sendHeart()
    self:send(PlatformMsg.MDM_CONNECT, PlatformMsg.ASS_NET_TEST_1);
end

function PlatformLogic:sendJiGuangID(id)
    local msg = {};
    msg.UserID = self.loginResult.dwUserID;
    msg.device_info = id;
     if device.platform == "android" then
        msg.device_type = 0;
    elseif device.platform == "ios" then
        msg.device_type = 1;
    else
        msg.device_type = 2;
    end

    self:send(PlatformMsg.MDM_GP_LOGON, PlatformMsg.ASS_GP_GET_DEVICE, msg, PlatformMsg.MSG_GP_GET_DEVICE);
end

return PlatformLogic