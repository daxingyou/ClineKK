local RoomLogic = class("RoomLogic")
local RoomDeal = require("net.room.RoomDeal")

local _roomLogic = nil;

function RoomLogic:getInstance()
    if _roomLogic == nil then
        _roomLogic = RoomLogic.new();
    end

    return _roomLogic;
end

function RoomLogic:ctor()
    self:createSocket()
    self.ip = ""
    self.port = 0
    self.connected = false
    self.lockSend = false
    self.checkCode = 0
    self.loginResult = {}
    self.roomList = {}
    self.isBindEvent = false;
    self.mainID = 180
    self.bAssistID = 116
    self.m_iHeartCount = 0
    self.m_maxHeartCount = 3

    -- // 当前选中的房间
    self._selectedRoom = nil;
    -- // 是否登录
    self._logined = false;

    -- // 房间规则
    self._gameRoomRule = 0;

    --// 牌桌状态
    self.deskStation = {};
    self.deskStation.bDeskStation = {};--//桌子状态
    self.deskStation.bDeskLock = {};   --//锁定状态
    self.deskStation.iBasePoint = {};  --//桌子倍数
    self.deskStation.bVirtualDesk = {};--//虚拟状态

    for i=1,400 do
        self.deskStation.bDeskStation[i] = 0;
        self.deskStation.bDeskLock[i] = 0;
        self.deskStation.iBasePoint[i] = 0;
        self.deskStation.bVirtualDesk[i] = 0;
    end

    self.roomDeal = RoomDeal:getInstance()
end

function RoomLogic:createSocket()
    -- if self.socketLogic then
    --     self.socketLogic:release()
    --     self.socketLogic = nil
    -- end

    self.socketLogic = HNSocketLogic:create(function(msg)
        self:onSocketMessage(msg)
    end,"game")
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

function RoomLogic:clear()
    self:close();
    _roomLogic = nil;

    self.ip = ""
    self.port = 0
    self.connected = false
    self.lockSend = false
    self.checkCode = 0
    self.m_iHeartCount = 0
    self.m_maxHeartCount = 3

    self.roomList = {}

    -- // 当前选中的房间
    self._selectedRoom = {}
    -- // 是否登录
    self._logined = false

    -- // 房间规则
    self._gameRoomRule = 0

    self.socketLogic:release()

    -- RoomLogic = nil;
end

function RoomLogic:stopListener()
    if self.roomDeal then
        self.isBindEvent = false;
        self.roomDeal:stop();
    end
end

function RoomLogic:startListener()
    if self.roomDeal then
        if self.isBindEvent == true then
            return;
        end

        self.isBindEvent = true;
        self.roomDeal:start();
    end
end

function RoomLogic:close()
    luaPrint("游戏断开网络 roomlogic  close")
    -- self:stopListener();

    self.connected = false;
    -- self._logined = false;
    self.socketLogic:close();
    self.sendData:setCheckCode(0)
end

function RoomLogic:isConnect()
    return self.connected;
end

function RoomLogic:connect(ip,port)
    self:close();
    -- self:createSocket()
    self:stopListener();
    self:startListener();

    self.socketLogic:setHistorySockID(self.mainID, self.bAssistID);
    self.ip,self.port = ip,port
    luaPrint("RoomLogic:connect -------- self.ip "..self.ip.." self.port "..self.port)
    registerNetPort(self.port)

    local ret = false

    if isYouxidun == true and checkVersion() == 2 then
        ret = true
    end

    if ret then
        if initNet() then
            self.isToConnect = true
            getBestIP(self.port)
        end
    else
        if checkVersion() == 2 then
            if isUseNetSDK then
                self.isToConnect = true
                getBestIP()
            else
                self.socketLogic:openWithIp(self.ip,self.port)
            end
        else
            if isUseNetSDK and device.platform == "ios" then
                self.ip = "127.0.0.1"
                performWithDelay(display:getRunningScene(),function() self.socketLogic:openWithIp(self.ip,self.port) end, 0.3)
            else
                self.socketLogic:openWithIp(self.ip,self.port)
            end
        end
    end
end

function RoomLogic:send(mainID,assitantID,obj,config)
    self:startListener();

    -- local sendData = HNSocketProtocolData:new()
    self.sendData:clear()
    if mainID == 1 and assitantID == 5 then
    	self.sendData:setDataEncry(0)
    else
    	self.sendData:setDataEncry(1)
    end
    
    local objSize = config and getObjSize(config) or 0
    self.sendData:writeHead(objSize+20,mainID,assitantID or 0,0,self.checkCode)
    if obj then
        convertToC(self.sendData,obj,config)
    end
    
    self.socketLogic:setDataEncry(1);

    local ret = self.socketLogic:send(self.sendData)

    -- if 88 ~= mainID then
        luaPrint("RoomLogic send msg mainID "..mainID.." assitantID "..assitantID.." objSize "..objSize);
    -- end

    if ret <= 0 then
        self:close();
        if globalUnit and globalUnit.isEnterGame == true and Hall:isHaveGameLayer() == true then
            if globalUnit.m_gameConnectState ~= STATE.STATE_CONNECTING then
                Event:dispatchEvent("game","I_R_M_DisConnect");
                Event:dispatchEvent("game","I_RR_M_DisConnect");
            end
        end
    end

    return ret;
end

function RoomLogic:onSocketMessage(msg)
    local status = msg:getStatus()
    if socketRecv == status then
        local mainID = msg:getHead(2)
        local assitantID = msg:getHead(3)

        luaPrint("RoomLogic Recv mainID：",mainID,"assitantID：",assitantID)

        self:receiveNetHeart()

        if mainID == 88 and assitantID == 1 then
        else
            if mainID == RoomMsg.MDM_GM_GAME_NOTIFY and assitantID == 82 then
                self:onReceiveGameUserCut(msg)
            else
                Event:sendEvent(msg:getHead(2),msg,"game")
            end
        end
    elseif socketDisConnect1 == status or socketDisConnect2 == status or socketDisConnect3 == status or socketOutTime == status or socketError == status then
        luaPrint("roomlogic 断网  status "..status)
        self:close();
        if globalUnit and globalUnit.isEnterGame == true and Hall:isHaveGameLayer() == true then
            if globalUnit.m_gameConnectState ~= STATE.STATE_CONNECTING then
                Event:dispatchEvent("game","I_R_M_DisConnect");
                Event:dispatchEvent("game","I_RR_M_DisConnect");
            end
        else
            if display.getRunningScene():getChildByName("deskLayer") then
                dispatchEvent("I_R_M_DisConnect")
            end

            dispatchEvent("loginRoom")
        end
        -- performWithDelay(display.getRunningScene(),function() luaPrint("断线事件")  luaPrint(a..b) end,1)
    elseif SocketConnect == status then
        if isYouxidun == true and runMode == "release" then
            luaPrint("roomlogic等待通知服务器连接成功 "..tostring(isUseNetSDK))
            local cf = {{"roomid","INT"}}
            local msg = {}
            msg.roomid = self:getSelectedRoom().uRoomID
            luaDump(msg,"房间连接")
            self:send(RoomMsg.MDM_GR_CONNECT,RoomMsg.MDM_GP_GETCODE,msg,cf)
        else
            if isUseNetSDK and checkVersion() == 2 then
                self.socketLogic:sendSdk(self.port)
            else
                luaPrint("roomlogic等待通知服务器连接成功 "..tostring(isUseNetSDK))
                local cf = {{"roomid","INT"}}
                local msg = {}
                msg.roomid = self:getSelectedRoom().uRoomID
                luaDump(msg,"房间连接")
                self:send(RoomMsg.MDM_GR_CONNECT,RoomMsg.MDM_GP_GETCODE,msg,cf)
            end
        end
    elseif SocketSDK == status then
        local ret = false
        local message = ""
        if checkVersion("1.0.0") == 2 then
            local handlecode = msg:getHead(4)
            luaPrint("sdk第一个消息",handlecode)
            if handlecode == 1 then
                ret = true
            else
                local cf = {
                    {"ret", "CHARSTRING[1000]"}
                }
                local data = convertToLua(msg,cf)
                luaDump(data,"sdk第一个消息")

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

                message = str
            end
        else
            local cf = {
                {"ret", "CHARSTRING[1]"}
            }
            local data = convertToLua(msg,cf)
            luaDump(data,"sdk第一个消息")
            data = tonumber(data.ret)
            if data == 1 then
               ret = true
            else
                message = "连接游戏服务器失败"..tostring(data)
            end
        end

        if ret == true then
            luaPrint("roomlogic等待通知服务器连接成功 "..tostring(isUseNetSDK))
            local cf = {{"roomid","INT"}}
            local msg = {}
            msg.roomid = self:getSelectedRoom().uRoomID
            luaDump(msg,"房间连接")
            self:send(RoomMsg.MDM_GR_CONNECT,RoomMsg.MDM_GP_GETCODE,msg,cf)
        else
            LoadingLayer:removeLoading()
            local a,b = Hall:getGameName(Hall:getGameNameByNameID(GameCreator:getCurrentGameNameID()))

            if a ~= nil and globalUnit.gameName ~= nil then
                self:close()
                dispatchEvent("loginRoom")
                Hall:exitGame()
                dispatchEvent("onRoomLoginError",1);--通知VIP界面
            end

            addScrollMessage(message)
        end
    end
end

-- // 获取进入的房间信息
function RoomLogic:getSelectedRoom()
    return self._selectedRoom;
end

-- // 设置进入的房间信息
function RoomLogic:setSelectedRoom(room)
    self._selectedRoom = room;
end

-- // 获取房间规则
function RoomLogic:getRoomRule()
    return self._gameRoomRule;
end

-- // 设置房间规则
function RoomLogic:setRoomRule(roomRule)
    self._gameRoomRule = roomRule;
end

-- // 房间登录
function RoomLogic:login(uGameID)
    local msg = {};
    msg.uNameID = uGameID;
    msg.dwUserID = PlatformLogic.loginResult.dwUserID;
    msg.szMD5Pass = PlatformLogic.loginResult.szMD5Pass;
    msg.uRoomVer = 0;
    msg.uGameVer = 0;
    if not globalUnit.VipRoomList then
        globalUnit.nowTingId = 0
    end
    msg.iGuildId = globalUnit.nowTingId or 0;
    msg.szIP = getIPAddress()
    if globalUnit.m_gameConnectState == STATE.STATE_CONNECTING then
        if globalUnit.isDoudizhuBackRoom == true then
            msg.isReturn = true
            globalUnit.isDoudizhuBackRoom = nil
            luaPrint("login 1111111111111")
        else
            msg.isReturn = false
            luaPrint("login 00000000000")
        end        
    else
        if globalUnit.isDoudizhuBackRoom == false then
            msg.isReturn = false
            globalUnit.isDoudizhuBackRoom = nil
            luaPrint("login 222222222222")
        elseif globalUnit.isDoudizhuBackRoom == true then
            msg.isReturn = true
            globalUnit.isDoudizhuBackRoom = nil
            luaPrint("login 333333333")
        else
            luaPrint("login 44444444")
            msg.isReturn = globalUnit:getIsBackRoom()
        end
    end
    msg.szCityInfo = globalUnit.city
    luaDump(msg,"房间登录")
    self:send(RoomMsg.MDM_GR_LOGON, RoomMsg.ASS_GR_LOGON_BY_ID, msg, RoomMsg.MSG_GR_S_RoomLogon);
end

function RoomLogic:sendHeart()
    PlatformLogic:sendHeart()
    self:send(RoomMsg.MDM_CONNECT, RoomMsg.ASS_NET_TEST_1)
end

function RoomLogic:receiveNetHeart()
    luaPrint("roomlogic rece self.m_iHeartCount = "..self.m_iHeartCount)
    if self.m_iHeartCount > 0 then
        self.m_iHeartCount = self.m_iHeartCount - 1;
    else
        self.m_iHeartCount = 0;
    end
end

function RoomLogic:stopCheckNet()
    luaPrint("停止 roomLogic 心跳")
    if self.schedulerNet then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerNet)
        self.schedulerNet = nil;
    end
end

function RoomLogic:checkNet()
    self:stopCheckNet()
    luaPrint("启动 roomLogic 心跳")

    local func = function() 
            if globalUnit.isaccountQuit == true then
                return
            end

            if globalUnit and globalUnit.isEnterGame == true then
                if not self:isConnect() then
                    self:onGameDisconnect(function() self:checkNet() end)
                else
                    luaPrint("roomlogic send self.m_iHeartCount = "..self.m_iHeartCount)
                    if self.m_iHeartCount > self.m_maxHeartCount then
                        self.m_iHeartCount = 0
                        -- performWithDelay(display.getRunningScene(),function() luaPrint("游戏心跳断线事件")  luaPrint(a..b) end,1)
                        self:onGameDisconnect(function() self:checkNet() end)
                    else
                        self:sendHeart()
                        self.m_iHeartCount = self.m_iHeartCount + 1
                    end
                end
            else
                if self:isConnect() then
                    self:sendHeart()
                else
                    self.m_iHeartCount = 0
                    self:onGameDisconnect(function() self:checkNet() end)
                end
            end
        end
    self.schedulerNet = cc.Director:getInstance():getScheduler():scheduleScriptFunc(func, 4, false)
end

function RoomLogic:onGameDisconnect(callback)
    self:stopCheckNet()

    if globalUnit.isEnterGame ~= true then
        dispatchEvent("I_R_M_DisConnect")--二人牛牛特殊处理
        return
    end

    if globalUnit.isaccountQuit == true then
        return
    end

    local root = cc.Director:getInstance():getRunningScene()

    -- //--断线重连提示
    local node = root:getChildByTag(1421)
    if node then
        return
    end

    self:close()

    if callback == nil then
        callback = function() self:checkNet() end
    end

    local prompt = require("layer.GameRelineLayer"):create(callback)
    prompt:setTag(1421)
    root:addChild(prompt, gameZorder+1000)
    prompt:sureReline()
end

function RoomLogic:onReceiveGameUserCut(msg)
    local bCutStruct = {
        {"bDeskStation","BYTE"},
        {"bCut","BOOL"},
    }
    local msg = convertToLua(msg, bCutStruct)
    luaDump(msg,"断线头像处理")
    
    if globalUnit.m_gameConnectState ~= STATE.STATE_OVER then--//重连中状态
        -- //请求游戏状态信息 ,刷新桌子数据
        local msg = {}
        msg.bEnableWatch = 0

        self:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_GM_GAME_INFO,msg, RoomMsg.MSG_GM_S_ClientInfo)
    end

    local root = cc.Director:getInstance():getRunningScene()

    local node = root:getChildByTag(1421)
    if node then
        node:delayCloseLayer(0)
    end

    self.m_iHeartCount = 0
end

return RoomLogic