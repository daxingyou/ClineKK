local function checkObjSize(obj,objSize)
    if getObjSize(obj) == objSize then
        return true
    else
        luaPrint("the RoomMsg receive size is error!!!",getObjSize(obj) .. " objSize:" .. objSize)
        return true
    end
end

local _instance = nil;

local RoomDeal = class("RoomDeal")

function RoomDeal:getInstance()
    if _instance == nil then
        _instance = RoomDeal.new();
    end

    return _instance;
end

function RoomDeal:ctor()
    self.dataListener = {};
end

function RoomDeal:start()
    self:init();
end

function RoomDeal:stop()
    self:unBindEvent();
end

function RoomDeal:init()
    --注册事件
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GR_CONNECT,self,"game")          --// 连接
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GR_LOGON,self,"game")            --// 登录消息
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GR_USER_LIST,self,"game")        -- // 用户列表
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GR_USER_ACTION,self,"game")      -- // 用户动作
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GR_ROOM,self,"game")             --// 房间消息
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GM_GAME_FRAME,self,"game")       --// 框架消息
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GM_GAME_NOTIFY,self,"game")      --// 游戏消息
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GR_MANAGE,self,"game")             --// 封桌
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_CONNECT,self,"game")             --// 封桌
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GR_MESSAGE,self,"game")          --系统消息
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MDM_GP_EC_INFO,self,"game")          --电竞
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(RoomMsg.MZTW_ROOMINFO,self,"game")           --路子

    self.deskStation = {};
    self.deskStation.bDeskStation = {};
    self.deskStation.bDeskLock = {};
    self.deskStation.iBasePoint = {};
    self.deskStation.bVirtualDesk = {};

    for i=1,100 do
        self.deskStation.bDeskStation[i] = 0;   --//桌子状态
        self.deskStation.bDeskLock[i] = 0;  --//锁定状态
        self.deskStation.iBasePoint[i] = 0; --//桌子倍数
        self.deskStation.bVirtualDesk[i] = 0;--//虚拟状态
    end
end

function RoomDeal:unBindEvent()
    if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return;
    end

    for _, bindid in pairs(self.bindIds) do
        Event:unBindEvent(bindid)
    end
end

---注册网络数据接收通知
-- @param #int 监听的协议id
-- @param #obj listener 需实现回调函数 onReceiveCmdResponse(httpCode，data)
function RoomDeal:registerCmdReceiveNotify(cmdId, subId, listener)
    if self.dataListener == nil then
        self.dataListener = {}
    end
    
    if self.dataListener[cmdId] == nil then
        self.dataListener[cmdId] = {}
    end

    if self.dataListener[cmdId][subId] == nil then
        self.dataListener[cmdId][subId] = {}
    end

    if listener and listener.onReceiveCmdResponse then
        self.dataListener[cmdId][subId][tostring(listener)] = listener
    else
        luaPrint("RoomDeal: listener is nil or noHttpResponse() function not implemented!")
    end
end

---注销网络数据接收通知
-- @param #int cmdId 监听的协议id
-- @param #obj listener
function RoomDeal:unregisterCmdReceiveNotify(cmdId,subId,listener)
    if self.dataListener[cmdId] ~= nil and self.dataListener[cmdId][subId] ~= nil then
        self.dataListener[cmdId][subId][tostring(listener)] = nil
    end
end

function RoomDeal:clearAllRegisterCmdNotify()
    self.dataListener = {}
end

function RoomDeal:onReceiveCmdRespone(data)
    local mainID = tonumber(data:getHead(2));
    
    if 88 ~= mainID then
        luaPrint("RoomDeal:onReceiveCmdRespone(data) ----------- mainid "..mainID.." subID "..data:getHead(3));
    end

    if mainID == RoomMsg.MDM_GR_CONNECT then
        self:H_R_M_Connect(data);
    elseif mainID == RoomMsg.MDM_GR_LOGON then
        self:H_R_M_Login(data);
    elseif mainID == RoomMsg.MDM_GR_USER_LIST then
        self:H_R_M_UserList(data);
    elseif mainID == RoomMsg.MDM_GR_USER_ACTION then
        self:H_R_M_UserAction(data);
    elseif mainID == RoomMsg.MDM_GR_ROOM then
        self:H_R_M_Room(data);
    elseif mainID == RoomMsg.MDM_GM_GAME_FRAME then
        self:H_R_M_GameFrame(data);
    elseif mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
        if (Hall:getCurGameName() == "fishing" or Hall:getCurGameName() == "likuipiyu" or Hall:getCurGameName() == "jinchanbuyu") and not Hall:getHallBackRoom() then
            self:H_R_M_GameNotify(data);
        else
            self:dispatchEvent(mainID,data:getHead(3),data)
        end
    elseif mainID == RoomMsg.MDM_GR_MANAGE then
        self:H_R_M_Manage(data);
    elseif mainID == PlatformMsg.MDM_GP_USERINFO then
        self:MDM_GP_USERINFO(data);
    elseif mainID == RoomMsg.MDM_CONNECT then
        self:H_R_M_Heart(data);
    elseif mainID == RoomMsg.MDM_GR_MESSAGE then
        self:H_R_M_Message(data)
    elseif mainID == RoomMsg.MDM_GP_EC_INFO then
        self:dispatchEvent(mainID,data:getHead(3),data)
    elseif mainID == RoomMsg.MZTW_ROOMINFO then
        self:MZTW_ROOMINFO(data)
    else
        luaPrint("roomLogic recevie error mainID  : "..mainID.." subID : "..data:getHead(3));
    end
end

function RoomDeal:H_R_M_Heart(msg)
    -- luaPrint("H_R_M_Heart")
    Event:dispatchEvent("game","I_R_M_heart");
end

--连接
function RoomDeal:H_R_M_Connect(msg)
    if globalUnit.isEnterGame == true and RoomLogic:isConnect() == true then
        return;
    end

    local assistantID = msg:getHead(3)

    if assistantID == 3 then
        local msg = convertToLua(msg,RoomMsg.MSG_S_ConnectSuccess)
        -- RoomLogic.checkCode = math.floor((msg.i64CheckCode-GameConfig.SECRECT_KEY)/23)
        RoomLogic.checkCode = RoomLogic.socketLogic:getCheckCode()--msg.i64CheckCode;
        -- RoomLogic.socketLogic:setCheckCode(RoomLogic.checkCode)
        RoomLogic.sendData:setCheckCode(RoomLogic.checkCode)
        RoomLogic.connected = true
        luaPrint("RoomDeal:H_R_M_Connect(msg)")
        RoomLogic:checkNet()

        local getGameName = Hall:getCurGameName()

        --百人游戏获取，进场方式选择
        if getGameName then
            local gameType,sGameName = Hall:getGameName(getGameName)
            if gameType and globalUnit.bIsSelectDesk == nil then
                local cf = {{"channelID","INT"}}
                local msg = {}
                msg.channelID = channelID
                luaDump(msg,"房间桌子数据")
                RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.MDM_GP_GETROOMINFO,msg,cf)
                --performWithDelay(display.getRunningScene(),function() 
                  --  luaPrint("luzi =====")
                    --globalUnit.bIsSelectDesk = true
                   -- dispatchEvent("showRoomLuzi",globalUnit.bIsSelectDesk)
        --// 分发消息
        --Event:dispatchEvent("game","I_R_M_Connect",{data = deskNo});
          --       end, 0.3)
                return
            end
        end
        --// 分发消息
        Event:dispatchEvent("game","I_R_M_Connect",{data = deskNo});
    elseif assistantID == RoomMsg.MDM_GP_GETROOMINFO then
        local cf = {{"showLuzi","BOOL"}}
        local msg = convertToLua(msg,cf);
        luaDump(msg,"房子路子")
        globalUnit.bIsSelectDesk = msg.showLuzi
        dispatchEvent("showRoomLuzi",globalUnit.bIsSelectDesk)
        --// 分发消息
        local gameName = Hall:getCurGameName()
        if (gameName == "fqzs" or gameName == "benchibaoma") and globalUnit.bIsSelectDesk == false then
        else
            Event:dispatchEvent("game","I_R_M_Connect",{data = deskNo});
        end
    end
end

--登录消息
function RoomDeal:H_R_M_Login(msg)
    local mainID = msg:getHead(2);
    local assistantID = msg:getHead(3)
    local code = msg:getHead(4)
    luaPrint("--------房间的登陆成功-------------- assistantID "..assistantID.." code "..code)

    local message = "";
    -- // 异地登录
    if PlatformMsg.ASS_GP_LOGON_ALLO_PART == assistantID then
        message = "异地登录";
        --// 分发消息
        Event:dispatchEvent("game","I_R_M_Login",{message = message,code = code,success = false});
        dispatchEvent("roomLoginFail");
    -- // 设备锁定
    elseif PlatformMsg.ASS_GP_LOGON_LOCK_VALID == assistantID then
        message = "设备锁定";
        --// 分发消息
        Event:dispatchEvent("game","I_R_M_Login",{message = message,code = code,success = false});
        dispatchEvent("roomLoginFail");
    --// 登录成功
    elseif RoomMsg.ASS_GR_LOGON_SUCCESS == assistantID then
        message = "房间登录成功";

        local msg = convertToLua(msg,RoomMsg.MSG_GR_R_LogonResult);
        RoomLogic.loginResult = msg;
        RoomLogic._logined = (code == PlatformMsg.ERR_GP_LOGON_SUCCESS);

        --// 分发消息
        Event:dispatchEvent("game","I_R_M_Login",{message = message,code = code,success = true});
    -- // 登录错误
    elseif RoomMsg.ASS_GR_LOGON_ERROR == assistantID then
        luaPrint("登陆错误 code "..code)
        if code == RoomMsg.ERR_GR_USER_PASS_ERROR then
            message = GBKToUtf8("用户密码错误");
        elseif code == RoomMsg.ERR_GR_CONTEST_TIMEOUT then
            message = GBKToUtf8("连接超时");
        elseif code == RoomMsg.ERR_GR_IN_OTHER_ROOM then
            message = GBKToUtf8("正在其他房间");
        elseif code == RoomMsg.ERR_GR_ACCOUNTS_IN_USE then
            message = GBKToUtf8("帐号正在使用");
        elseif code == RoomMsg.ERR_GR_STOP_LOGON then
            message = GBKToUtf8("亲爱的玩家，此游戏房间在升级中，暂时禁止登录");
        elseif code == RoomMsg.ERR_GR_PEOPLE_FULL then
            message = GBKToUtf8("房间人数已经满");
        elseif code == RoomMsg.ERR_GR_GAME_END then
            message = GBKToUtf8("游戏已结束，请重新进游戏")
        elseif code == RoomMsg.ERR_GR_GUILDERR then
            message = GBKToUtf8("VIP厅ID错误")
        elseif code == RoomMsg.ERR_GR_GUILD_ROOMERR then
            message = GBKToUtf8("房间不存在")
        elseif code == RoomMsg.ERR_GR_USER_NO_FIND then
            message = GBKToUtf8("用户不存在")
        else
            message = GBKToUtf8("房间未知登录错误");
        end

        Event:dispatchEvent("game","I_R_M_Login",{message = message,code = code,success = false});
        dispatchEvent("roomLoginFail");
    -- // 登录完成
    elseif RoomMsg.ASS_GR_SEND_FINISH == assistantID then
        Event:dispatchEvent("game","I_R_M_LoginFinish");
    -- //匹配房间
    elseif RoomMsg.ASS_BEGIN_MATCH_ROOM == assistantID then
        luaPrint("匹配房间")
        Event:dispatchEvent("game","I_R_M_MatchDeskFinish",{code = code});
        dispatchEvent("I_R_M_MatchDeskFinish",{deskNo = code})
    elseif RoomMsg.ASS_END_MATCH_ROOM == assistantID then
        luaPrint("取消匹配")
        dispatchEvent("I_R_M_EndMatchRoom")
        dispatchEvent("roomLoginFail");
    elseif  RoomMsg.ERR_GR_NO_ENOUGH_ROOM_KEY == assistantID then
        LoadingLayer:removeLoading()
        GamePromptLayer:create():showPrompt(GBKToUtf8("您的金币不足，不能加入房间！"));
        local layer = display.getRunningScene():getChildByName("deskLayer")
        if layer then
            layer.isClickQuick = nil;
        end
        dispatchEvent("roomLoginFail");
    elseif  RoomMsg.ERR_GR_IN_ROOM == assistantID then
        LoadingLayer:removeLoading()
        GamePromptLayer:create():showPrompt(GBKToUtf8("您正在游戏中！"));
        dispatchEvent("roomLoginFail");
    elseif  RoomMsg.ERR_GR_GUILD_MATCHERR == assistantID then
        dispatchEvent("I_R_M_EndMatchRoom");

        if code == 1 then
            addScrollMessage("vip厅不存在,自动退出游戏。");
        elseif code == 2 then
            addScrollMessage("不在vip厅中,自动退出游戏。");
        elseif code == 3 then
            addScrollMessage("vip厅房间关闭,自动退出游戏。");
        end
        dispatchEvent("roomLoginFail");
    elseif RoomMsg.ASS_GR_GET_USEREXPAND == assistantID then
        local msg = convertToLua(msg,RoomMsg.UserInfoExpand);
        self:dispatchEvent(mainID,assistantID,{data = msg})
    elseif assistantID == RoomMsg.MDM_GP_GETROOMINFO then--借用登录消息的主id
        if globalUnit.bIsSelectDesk == nil then
            local cf = {{"showLuzi","BOOL"}}
            local msg = convertToLua(msg,cf);
            luaDump(msg,"房子路子")
            globalUnit.bIsSelectDesk = msg.showLuzi
 
            dispatchEvent("showRoomLuzi",globalUnit.bIsSelectDesk)
            --// 分发消息
            local gameName = Hall:getCurGameName()
            if (gameName == "fqzs" or gameName == "benchibaoma") and globalUnit.bIsSelectDesk == false then
                LoadingLayer:removeLoading()
                RoomLogic:close()
                dispatchEvent("loginRoom")
            else
                if globalUnit.bIsSelectDesk == false then
                    if PlatformLogic.loginResult.i64Money < globalUnit.nMinRoomKey then
                        addScrollMessage("抱歉，您的金币低于入场最低限制"..string.format("%.2f",goldConvert(globalUnit.nMinRoomKey)).."，不能进入该游戏房间！")
                        showBuyTip(true)
                        return
                    end
                end
                Event:dispatchEvent("game","I_R_M_Connect",{data = deskNo});
            end
        end
    end
end

 -- // 用户列表
function RoomDeal:H_R_M_UserList(msg)
    local assistantID = msg:getHead(3);
    local objectSize = msg:getHead(1) - 20;
    if assistantID == RoomMsg.ASS_GR_ONLINE_USER or assistantID == RoomMsg.ASS_GR_NETCUT_USER then
        local count = objectSize /getObjSize(RoomMsg.UserInfoStruct)
        for i=1,count do
            local user = convertToLua(msg,RoomMsg.UserInfoStruct)
            UserInfoModule:updateUser(user);
        end
    elseif assistantID == RoomMsg.ASS_GR_DESK_STATION then
        if not checkObjSize(RoomMsg.MSG_GR_DeskStation, msg:getHead(1) - 20) then
            return;
        end

        local msg = convertToLua(msg,RoomMsg.MSG_GR_DeskStation);
        RoomLogic.deskStation = msg;
    else

    end
end

--用户动作
function RoomDeal:H_R_M_UserAction(msg)
    local assistantID = msg:getHead(3)
    local messageHead = {};
    messageHead.uMessageSize = msg:getHead(1);
    messageHead.bMainID = msg:getHead(2);
    messageHead.bAssistantID = msg:getHead(3);
    messageHead.bHandleCode = msg:getHead(4);
    messageHead.bReserve = msg:getHead(5);

    luaPrint("收到用户动作 assistantID "..assistantID)

    local object = msg;
    local objectSize = msg:getHead(1) - 20;

     --// 排队坐下
    if RoomMsg.ASS_GR_QUEUE_USER_SIT == assistantID then
        self:H_R_M_QueueUserSit(messageHead, object, objectSize);    
    --// 用户进入房间
    elseif RoomMsg.ASS_GR_USER_COME == assistantID then
        self:H_R_M_UserCome(messageHead, object, objectSize);
    --// 用户离开房间
    elseif RoomMsg.ASS_GR_USER_LEFT == assistantID then
        self:H_R_M_UserLeft(messageHead, object, objectSize);
    --// 用户断线
    elseif RoomMsg.ASS_GR_USER_CUT == assistantID then
        self:H_R_M_UserCut(messageHead, object, objectSize);
    --// 用户站起（包含旁观站起）
    elseif RoomMsg.ASS_GR_USER_UP == assistantID or RoomMsg.ASS_GR_WATCH_UP == assistantID then
        self:H_R_M_UserUp(messageHead, object, objectSize);
    --// 坐下错误
    elseif RoomMsg.ASS_GR_SIT_ERROR == assistantID then
        self:H_R_M_SitError(messageHead, object, objectSize);
    --// 用户坐下
    elseif RoomMsg.ASS_GR_USER_SIT == assistantID or RoomMsg.ASS_GR_WATCH_SIT == assistantID then
        if not checkObjSize(RoomMsg.MSG_GR_R_UserSit, msg:getHead(1) - 20) then
            return
        end

        local count = objectSize /getObjSize(RoomMsg.MSG_GR_R_UserSit)
        local code = msg:getHead(4);
        for i=1,count do
            local msg = convertToLua(msg,RoomMsg.MSG_GR_R_UserSit);
            self:H_R_M_UserSit(code,msg);
        end
    --试玩场超时
    elseif RoomMsg.ASS_GR_EXPERCISE_OUTTIME == assistantID then
        dispatchEvent("playOutTime")
    end
end

-- // 房间消息
function RoomDeal:H_R_M_Room(msg)
    local objectSize = msg:getHead(1)-20
    local assistantID = msg:getHead(3)
    local messageHead = {};
    messageHead.uMessageSize = msg:getHead(1);
    messageHead.bMainID = msg:getHead(2);
    messageHead.bAssistantID = msg:getHead(3);
    messageHead.bHandleCode = msg:getHead(4);
    messageHead.bReserve = msg:getHead(5);

    -- // 游戏开始
    if RoomMsg.ASS_GR_GAME_BEGIN == assistantID then
        self:H_R_M_GameBegin(messageHead, msg, msg:getHead(1) - 20);
    -- // 游戏结算
    elseif RoomMsg.ASS_GR_USER_POINT == assistantID then
        self:H_R_M_UserPoint(messageHead, msg, msg:getHead(1) - 20);
    -- // 游戏结束
    elseif RoomMsg.ASS_GR_GAME_END == assistantID then
        self:H_R_M_GameEnd(messageHead, msg, msg:getHead(1) - 20);
    -- // 用户同意
    elseif RoomMsg.ASS_GR_USER_AGREE == assistantID then
        self:H_R_M_UserAgree(messageHead, msg, msg:getHead(1) - 20);
    -- // 及时更新金币和积分
    elseif RoomMsg.ASS_GR_INSTANT_UPDATE == assistantID then
        self:H_R_M_InstantUpdate(messageHead, msg, msg:getHead(1) - 20);
    -- // 用户比赛信息
    elseif RoomMsg.ASS_GR_USER_CONTEST == assistantID then
        self:H_R_M_UserContest(messageHead, msg, msg:getHead(1) - 20);
    -- // 比赛信息广播
    elseif RoomMsg.ASS_GR_CONTEST_APPLYINFO == assistantID then
        self:H_R_M_ContestNotic(messageHead, msg, msg:getHead(1) - 20);
    -- // 比赛结束
    elseif RoomMsg.ASS_GR_CONTEST_GAMEOVER == assistantID then
        self:H_R_M_ContestOver(messageHead, msg, msg:getHead(1) - 20);
    -- // 用户被淘汰
    elseif RoomMsg.ASS_GR_CONTEST_KICK == assistantID then
        self:H_R_M_ContestKick(messageHead, msg, msg:getHead(1) - 20);
    -- // 比赛等待结束
    elseif RoomMsg.ASS_GR_CONTEST_WAIT_GAMEOVER == assistantID then
        self:H_R_M_ContestWaitOver(messageHead, msg, msg:getHead(1) - 20);
    -- // 比赛初始化
    elseif RoomMsg.ASS_GR_INIT_CONTEST == assistantID then
        self:H_R_M_ContestInit(messageHead, msg, msg:getHead(1) - 20);
    -- // 比赛报名人数
    -- /*else if(RoomMsg.ASS_GR_CONTEST_PEOPLE == assistantID then
    --     H_R_M_ContestPeople(messageHead, object, objectSize);
    -- */
    -- // 个人参赛记录
    -- /*else if(RoomMsg.ASS_GR_CONTEST_RECORD == assistantID then
    -- {
    --     H_R_M_ContestRecord(messageHead, object, objectSize);
    -- }*/
    -- // 比赛奖励
    elseif RoomMsg.ASS_GR_CONTEST_AWARDS == assistantID then
        self:H_R_M_ContestAward(messageHead, object, objectSize);
    elseif VipMsg.ASS_GR_GUILD_DESKINFO == assistantID then
        local count = objectSize/getObjSize(VipMsg.GuildDesk)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,VipMsg.GuildDesk);
            table.insert(data, msg);
        end
        self:dispatchEvent(messageHead.bMainID,assistantID,{data={data,messageHead.bHandleCode}});  
    elseif VipMsg.ASS_GR_GUILD_DESKINFO_UPDATE == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GR_GuildDeskUpdate);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data=msg});

    elseif QukuailianMsg.ASS_GR_GET_HASH ==  assistantID then --区块链
        dispatchEvent("QUKUAILIAN_HASHCODE",msg);

    elseif QukuailianMsg.ASS_GR_HASH ==  assistantID then --区块链
        luaPrint("ASS_GR_HASH---28")
        dispatchEvent("QUKUAILIAN_RESULT",msg);
    elseif QukuailianMsg.ASS_GR_SEND_HASH ==  assistantID then --区块链
        luaPrint("ASS_GR_SEND_HASH---30")
        dispatchEvent("QUKUAILIAN_SEND",msg);
    elseif RoomMsg.ASS_GR_USERSCORELOG == assistantID then
        dispatchEvent("ASS_GR_USERSCORELOG",msg);
    elseif RoomMsg.ASS_GR_NEWUSERSCORELOG == assistantID then
        dispatchEvent("ASS_GR_NEWUSERSCORELOG",msg);	
    
    end

    -- //桌子需要被回收
    -- /*  else if (ASS_GR_DESKLOCKPASS_UNUSE == assistantID then
    --     {
    --         H_R_M_ContestAward(messageHead, object, objectSize);
    --     }*/
end

-- // 游戏开始
function RoomDeal:H_R_M_GameBegin(messageHead, object, objectSize)
    local deskNo = messageHead.bHandleCode;
    -- // 更新用户状态
    local func = {};
    func.bUserState = USER_PLAY_GAME;

    local condition = {};
    condition.deskNo = deskNo;

    UserInfoModule:transform(func, condition);

    --// 分发消息
    dispatchEvent("I_R_M_GameBegin",deskNo)
    Event:dispatchEvent("game","I_R_M_GameBegin",{data = deskNo});
end

-- // 游戏结算
function RoomDeal:H_R_M_UserPoint(messageHead, object, objectSize)
    -- // 判断是否是入库类型
    local isNormal  = function()
        local flag = bit:_and(RoomLogic:getRoomRule(), GRR_EXPERCISE_ROOM) or bit:_and(RoomLogic:getRoomRule(), GRR_CONTEST);

        return not flag;
    end
    
    local msg = object;
    local handCode = messageHead.bHandleCode;

    if handCode == 10 then --// 同步金币
        -- // 效验数据
        if not checkObjSize(RoomMsg.MSG_GR_S_RefalshMoney, objectSize) then
            luaPrint("MSG_GR_S_RefalshMoney size is error.");
            return;
        end

        msg = convertToLua(msg, RoomMsg.MSG_GR_S_RefalshMoney);
        -- // 处理数据
        local user = UserInfoModule:findUserByID(msg.dwUserID);

        if user == nil then
            return;
        end

        user.i64Money = msg.i64Money;

        -- // 更新自己数据
        if msg.dwUserID == PlatformLogic.loginResult.dwUserID then
            RoomLogic.loginResult.pUserInfoStruct = user;

            if isNormal() then
                PlatformLogic.loginResult.i64Money = PlatformLogic.loginResult.i64Money + user.i64Money;
            end
        end
    elseif handCode == 11 then --// 同步经验值
        -- // 效验数据
        if not checkObjSize(RoomMsg.MSG_GR_S_RefalshMoney, objectSize) then
            luaPrint("MSG_GR_S_RefalshMoney size is error.");
            return;
        end

        msg = convertToLua(msg, RoomMsg.MSG_GR_S_RefalshMoney);
        -- // 处理数据
        local user = UserInfoModule:findUserByID(msg.dwUserID);

        if user == nil then
            return;
        end

        user.dwPoint = msg.i64Money;

        -- // 更新自己数据
        if user.dwUserID == PlatformLogic.loginResult.dwUserID then
            RoomLogic.loginResult.pUserInfoStruct = user;
        end
    elseif handCode == 0 then   --// 同步经验值        
        if not checkObjSize(RoomMsg.MSG_GR_R_UserPoint, objectSize) then
            luaPrint("MSG_GR_R_UserPoint size is error.");
            return;
        end

        msg = convertToLua(msg, RoomMsg.MSG_GR_R_UserPoint);
        -- // 处理数据
        local user = UserInfoModule:findUserByID(msg.dwUserID);

        if user == nil then
            return;
        end

        -- // 更新用户信息
        user.dwPoint = user.dwPoint + msg.dwPoint;                              --//用户经验值
        user.i64Money = user.i64Money + msg.dwMoney;                            --//用户金币
        -- //pUserItem->dwSend += pUserPoint->dwSend;                          //赠送
        user.uWinCount = user.uWinCount + msg.bWinCount;                      --//胜局
        user.uLostCount = user.uLostCount + msg.bLostCount;                     --//输局
        user.uMidCount = user.uMidCount + msg.bMidCount;                        --//平局
        user.uCutCount = user.uCutCount + msg.bCutCount;                        --//逃局

        UserInfoModule:updateUser(user)

        dispatchEvent("H_R_M_UserPoint",user)

        -- // 更新自己数据
        if user.dwUserID == PlatformLogic.loginResult.dwUserID then
            RoomLogic.loginResult.pUserInfoStruct = user;

            if isNormal() then
                PlatformLogic.loginResult.i64Money = PlatformLogic.loginResult.i64Money + msg.dwMoney;
            end
        end
    elseif handCode == 100 then
        if not checkObjSize(RoomMsg.MSG_GR_R_UserPoint, objectSize) then
            luaPrint("MSG_GR_R_UserPoint size is error.");
            return;
        end

        msg = convertToLua(msg, RoomMsg.MSG_GR_R_UserPoint);
        -- // 处理数据
        local user = UserInfoModule:findUserByID(msg.dwUserID);

        if user == nil then
            return;
        end

        -- // 更新用户信息
        user.i64Money = msg.dwMoney;                            --//用户金币

        UserInfoModule:updateUser(user)

        dispatchEvent("H_R_M_UserPoint",user)

        -- // 更新自己数据
        if user.dwUserID == PlatformLogic.loginResult.dwUserID then
            RoomLogic.loginResult.pUserInfoStruct = user;

            if isNormal() then
                PlatformLogic.loginResult.i64Money = PlatformLogic.loginResult.i64Money + msg.dwMoney;
            end
        end
    end

     --// 分发消息
    Event:dispatchEvent("game","I_R_M_GamePoint",{data = msg});
end

-- // 游戏结束
function RoomDeal:H_R_M_GameEnd(messageHead, object, objectSize)
    local deskIndex = messageHead.bHandleCode;

    if not bit:_and(RoomLogic:getRoomRule(), GRR_CONTEST) or not bit:_and(RoomLogic:getRoomRule(), GRR_QUEUE_GAME) then
        UserInfoModule:transform({bDeskStation = INVALID_DESKSTATION, bDeskNO = INVALID_DESKNO, bUserState = USER_LOOK_STATE}, {bDeskNO = deskIndex});
    end

    --// 分发消息
    dispatchEvent("I_R_M_GameEnd",deskIndex)
    Event:dispatchEvent("game","I_R_M_GameEnd",{data = deskIndex});
end

-- // 用户同意
function RoomDeal:H_R_M_UserAgree(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.MSG_GR_R_UserAgree, objectSize) then
        luaPrint("MSG_GR_R_UserAgree size is error");
        return;
    end

    local msg = convertToLua(object, RoomMsg.MSG_GR_R_UserAgree);
    local users = UserInfoModule:findUserByDesk(msg.bDeskNO, msg.bDeskStation);
    
    if users ~= nil then
        UserInfoModule:transformByDeskStation(msg.bDeskNO, msg.bDeskStation,{bUserState = USER_ARGEE});
    end
    luaPrint("// 用户同意 RoomDeal:H_R_M_UserAgree(messageHead, object, objectSize) ")
    --// 分发消息
    Event:dispatchEvent("game","I_R_M_UserAgree",{data = msg});
end

-- // 及时更新金币和积分
function RoomDeal:H_R_M_InstantUpdate(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.MSG_GR_R_InstantUpdate, objectSize) then
        luaPrint("MSG_GR_R_InstantUpdate size is error");
        return;
    end

    local msg = convertToLua(msg, RoomMsg.MSG_GR_R_InstantUpdate);

    -- // 更新数据
    local user = UserInfoModule:findUserByID(msg.dwUserID);
    if user then
        local func = {};
        func.i64Money = user.i64Money + msg.i64Money;
        func.dwPoint = user.dwPoint + msg.dwPoint;

        local condition = {};
        condition.dwUserID = msg.dwUserID;

        UserInfoModule:transform(func, condition);
    end

    -- // 更新自己数据
    if msg.dwUserID == PlatformLogic.loginResult.dwUserID then
        RoomLogic.loginResult.pUserInfoStruct = msg;
        PlatformLogic.loginResult.i64Money = msg.dwMoney;
    end
end

-- // 用户比赛信息
function RoomDeal:H_R_M_UserContest(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.MSG_GR_ContestChange, objectSize) then
        luaPrint("MSG_GR_ContestChange size of error!");
        return;
    end

    local msg = convertToLua(msg, RoomMsg.MSG_GR_ContestChange);

    local user = UserInfoModule:findUserByID(msg.dwUserID);

    if user then
        local func = {};
        func.iRankNum = msg.iRankNum;--//  排行名次
        func.iRemainPeople = msg.iRemainPeople;--// 比赛中还剩下的人数
        func.i64ContestScore = msg.i64ContestScore;--// 比赛分数
        func.iContestCount = msg.iContestCount;--// 比赛局数

        local condition = {};
        condition.dwUserID = msg.dwUserID;

        UserInfoModule:transform(func, condition);
    end

    if msg.dwUserID ~= PlatformLogic.loginResult.dwUserID then
        return;
    end
    
    --// 分发消息
    Event:dispatchEvent("game","I_R_M_UserContest",{data = msg});
end

-- // 用户比赛信息
function RoomDeal:H_R_M_ContestNotic(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.MSG_GR_I_ContestInfo, objectSize) then
        luaPrint("MSG_GR_I_ContestInfo size of error!");
        return;
    end

    local msg = convertToLua(msg, RoomMsg.MSG_GR_ContestChange);

    --// 分发消息
    Event:dispatchEvent("game","I_R_M_ContestNotic",{data = msg});
end

-- // 比赛结束
function RoomDeal:H_R_M_ContestOver(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.MSG_GR_ContestAward, objectSize) then
        luaPrint("MSG_GR_ContestAward size of error!");
        return;
    end

    local msg = convertToLua(msg, RoomMsg.MSG_GR_ContestAward);

    --// 分发消息
    Event:dispatchEvent("game","I_R_M_ContestOver",{data = msg});
end

-- // 用户被淘汰
function RoomDeal:H_R_M_ContestKick(messageHead, object, objectSize)
    --// 分发消息
    Event:dispatchEvent("game","I_R_M_ContestKick",{data = msg});
end

-- // 比赛等待结束
function RoomDeal:H_R_M_ContestWaitOver(messageHead, object, objectSize)
    --// 分发消息
    Event:dispatchEvent("game","I_R_M_ContestWaitOver",{data = msg});
end

-- // 比赛初始化
function RoomDeal:H_R_M_ContestInit(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.MSG_GR_I_ContestInfo, objectSize) then
        luaPrint("MSG_GR_I_ContestInfo size of error!");
        return;
    end

    local msg = convertToLua(msg, RoomMsg.MSG_GR_ContestChange);

    local user = UserInfoModule:findUserByID(msg.dwUserID);

    if user then
        local func = {};
        func.iRankNum = msg.iRankNum;--//  排行名次
        func.iRemainPeople = msg.iRemainPeople;--// 比赛中还剩下的人数
        func.iContestCount = msg.iContestCount;--// 比赛局数

        local condition = {};
        condition.dwUserID = msg.dwUserID;

        UserInfoModule:transform(func, condition);
    end
end

-- // 获取报名数量
function RoomDeal:H_R_M_ContestPeople(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.NET_ROOM_CONTEST_PEOPLE_RESULT, objectSize) then
        luaPrint("NET_ROOM_CONTEST_PEOPLE_RESULT size of error!");
        return;
    end

    local msg = convertToLua(msg, RoomMsg.NET_ROOM_CONTEST_PEOPLE_RESULT);

    --// 分发消息
    Event:dispatchEvent("game","I_R_M_ContestPeople",{data = msg});
end

-- // 个人参赛记录
function RoomDeal:H_R_M_ContestRecord(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.NET_ROOM_CONTEST_RECORD_RESULT, objectSize) then
        luaPrint("NET_ROOM_CONTEST_RECORD_RESULT size of error!");
        return;
    end

    local msg = convertToLua(msg, RoomMsg.NET_ROOM_CONTEST_RECORD_RESULT);

    --// 分发消息
    Event:dispatchEvent("game","I_R_M_ContestRecord",{data = msg});
end

-- // 比赛奖励
function RoomDeal:H_R_M_ContestAward(messageHead, object, objectSize)
    -- UINT count = objectSize / sizeof(NET_ROOM_CONTEST_AWARD_RESULT);

    --     if(count > 0)
    --     {
    --         NET_ROOM_CONTEST_AWARD_RESULT* contestRecord = (NET_ROOM_CONTEST_AWARD_RESULT*)object;
    --         std::vector<NET_ROOM_CONTEST_AWARD_RESULT*> results(count);

    --         while(count > 0)
    --         {
    --             NET_ROOM_CONTEST_AWARD_RESULT* tmp = contestRecord++;
    --             results[count - 1] = tmp;
    --             count--;
    --         }

    --         // 分发房间数据
    --         dispatchFrameMessage([&results](IRoomMessageDelegate * delegate) -> bool
    --         {
    --             delegate->I_R_M_ContestAwards(&results);
    --             return false;
    --         });
    --     }
end

--框架消息
function RoomDeal:H_R_M_GameFrame(msg)
    local assistantID = msg:getHead(3)
    local messageHead = {};
    messageHead.uMessageSize = msg:getHead(1);
    messageHead.bMainID = msg:getHead(2);
    messageHead.bAssistantID = msg:getHead(3);
    messageHead.bHandleCode = msg:getHead(4);
    messageHead.bReserve = msg:getHead(5);
    local objectSize = msg:getHead(1) - 20;

    --// 游戏信息
    if RoomMsg.ASS_GM_GAME_INFO == assistantID then
        local msg = convertToLua(msg,RoomMsg.MSG_GM_S_GameInfo)
        -- luaDump(msg)
        luaPrint("roooim ---------------------------- "..msg.szPwd)
        self:H_R_M_GameInfo(messageHead, msg, objectSize);
    --// 游戏状态
    elseif RoomMsg.ASS_GM_GAME_STATION == assistantID then
        -- local msg = convertToLua(msg,GameMsg.TGSBase)
        self:H_R_M_GameStation(messageHead, msg, objectSize);--内部转换数据
    --// 普通聊天
    elseif RoomMsg.ASS_GM_NORMAL_TALK == assistantID then        
        local msg = convertToLua(msg,RoomMsg.MSG_GR_RS_NormalTalk)
        self:H_R_M_NormalTalk(messageHead, msg, objectSize);
    --// 游戏总局数结束
    elseif RoomMsg.ASS_GM_STATISTICS == assistantID then        
        -- local msg = convertToLua(msg,RoomMsg.Game_StatisticsMessage)
        self:H_R_M_GameAllEnd(messageHead, msg, objectSize);
    --// 游戏超时
    elseif RoomMsg.ASS_GM_DESKLOCKPASS_TIMEOUT == assistantID then
        self:H_R_M_RecycleDesk(messageHead, msg, objectSize);
    --//语音聊天
    elseif RoomMsg.ASS_VOICE_CHAT_MSG == assistantID or RoomMsg.ASS_VOICE_CHAT_MSG_FINISH == assistantID then
        local msg = convertToLua(msg,RoomMsg.MSG_GR_GCloudVoice)
        self:H_R_M_VoiceTalk(messageHead, msg, objectSize);
    --//继续下一局
    elseif RoomMsg.ASS_CONTINUE_NEXT_ROUND == assistantID then        
        local msg = convertToLua(msg,RoomMsg.MSG_GR_R_Continue_Next_Round)
        self:H_R_M_ContinueNextRound(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_JIUJI_TIPS == assistantID then--请求救济金
        local msg = convertToLua(msg, RoomMsg.JiuJiTips);
        -- self:H_R_M_RequestReliefMoney(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_JIUJI_RESULT == assistantID then--请求救济金结果
        local msg = convertToLua(msg, RoomMsg.JiujiResultStruct);
        -- self:H_R_M_RequestReliefMoneyResult(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_STORE_SCORE == assistantID then--存分
        local msg = convertToLua(msg, RoomMsg.StoreResultStruct);
        -- self:H_R_M_SaveScore(messageHead, msg, objectSize);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data=msg})
    elseif RoomMsg.ASS_GET_SCORE == assistantID then--取分
        local msg = convertToLua(msg, RoomMsg.StoreResultStruct);
        -- self:H_R_M_GetScore(messageHead, msg, objectSize);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data=msg})
    elseif RoomMsg.ASS_LEVEL_UP == assistantID then--升级
        local msg = convertToLua(msg, RoomMsg.UserLevelUp);
        -- self:H_R_M_UserLevelUp(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_GET_TASKLIST == assistantID then--请求任务列表
        local msg = convertToLua(msg, RoomMsg.TaskList);
        -- self:H_R_M_UserGetTaskList(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_UPDATE_TASK == assistantID then--领取任务奖励
        local msg = convertToLua(msg, RoomMsg.UpdateTask);
        -- self:H_R_M_UserRewarldRes(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_SEND_COMPLETETASK == assistantID then--完成任务数量
        local msg = convertToLua(msg, RoomMsg.CMD_GET_TASKCount);
        -- self:H_R_M_Taskcount(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_SEND_BUYMONEY == assistantID then--充值刷新金币
        local msg = convertToLua(msg, RoomMsg.BuyMoney);
        self:H_R_M_Buymoney(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_GET_GOODSINFO == assistantID then--获取
        local msg = convertToLua(msg, RoomMsg.CMD_C_GOODSINFO);
        self:dispatchEvent(messageHead.bMainID,assistantID,{head = messageHead, data = msg})
    elseif RoomMsg.ASS_UPDATE_GOODSINFO == assistantID then--更新
        local msg = convertToLua(msg, RoomMsg.CMD_S_UPDATE_GOODSINFO);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data = msg});
    elseif RoomMsg.ASS_SYN_GOODSINFO == assistantID then
        local msg = convertToLua(msg, RoomMsg.CMD_S_SYN_GOODSINFO);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data = msg});
    elseif RoomMsg.ASS_RETRY_MATCH == assistantID then--重新比赛
        local msg = convertToLua(msg, RoomMsg.RetryMatch);
        -- self:H_R_M_RetryMatch(messageHead, msg, objectSize);
    elseif RoomMsg.ASS_BUY_PaoTai == assistantID then
        local msg = convertToLua(msg, RoomMsg.BUY_PAOTAI);
        -- self:dispatchEvent(messageHead.bMainID,assistantID,{data = msg});
    elseif RoomMsg.ASS_ROOM_GUILD_CHANGE == assistantID then     --//公会修改
        -- local msg = convertToLua(msg, RoomMsg.BUY_PAOTAI);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data = messageHead.bHandleCode});
    end
end

--游戏消息
function RoomDeal:H_R_M_GameNotify(msg)
    local assistantID = msg:getHead(3)
    local messageHead = {};
    messageHead.uMessageSize = msg:getHead(1);
    messageHead.bMainID = msg:getHead(2);
    messageHead.bAssistantID = msg:getHead(3);
    messageHead.bHandleCode = msg:getHead(4);
    messageHead.bReserve = msg:getHead(5);
    local objectSize = msg:getHead(1) - 20;

    if messageHead.bMainID ==  RoomMsg.MDM_GM_GAME_NOTIFY and messageHead.bAssistantID == GameMsg.SUB_S_NEW_REWARD then
        local msg = convertToLua(msg, GameMsg.CMD_S_NewReward);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data = msg});
    elseif messageHead.bMainID ==  RoomMsg.MDM_GM_GAME_NOTIFY and messageHead.bAssistantID == GameMsg.SUB_S_HONGBAO_REWARD then
        local msg = convertToLua(msg, GameMsg.CMD_S_HongBaoReward);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data = msg});
    elseif messageHead.bMainID ==  RoomMsg.MDM_GM_GAME_NOTIFY and messageHead.bAssistantID == GameMsg.SUB_S_LOCK_FIRE then
        local msg = convertToLua(msg, GameMsg.CMD_S_LOCK_FIRE);
        self:dispatchEvent(messageHead.bMainID,assistantID,{data = msg});
    elseif messageHead.bAssistantID == GameMsg.SUB_S_ANDROID then        
        local msg = convertToLua(msg, GameMsg.CMD_S_Android)
        globalUnit.fishRobotData = msg
        dispatchEvent("robotData",msg)
    else
        Event:dispatchEvent("game","onGameMessage",{messageHead = messageHead, object = msg, objectSize = objectSize});
    end
end

-- // 封桌
function RoomDeal:H_R_M_Manage(msg)

end

--// 排队坐下
function RoomDeal:H_R_M_QueueUserSit(messageHead, object, objectSize)
        -- auto queueData = (int*)object;
        -- auto deskNo = (UINT)queueData[0];
        -- bool isFind = false;

        -- for(int i = 0; i < 3; i++)
        -- {
        --     if(PlatformLogic()->loginResult.dwUserID == queueData[3 * i + 1])
        --     {
        --         isFind = true;
        --     }
        -- }

        -- std::vector<QUEUE_USER_SIT_RESULT *> queueUsers;

        -- if(isFind)
        -- {
        --     for(int i = 0; i < 3; i++)
        --     {
        --         QUEUE_USER_SIT_RESULT * tmp = new QUEUE_USER_SIT_RESULT;
        --         tmp->dwUserID = queueData[3 * i + 1];
        --         tmp->bDeskStation = i;
        --         UserInfoStruct* userInfo = UserInfoModule()->findUser(tmp->dwUserID);

        --         if(nullptr != userInfo)
        --         {
        --             userInfo->bDeskNO = deskNo;
        --             userInfo->bDeskStation = tmp->bDeskStation;
        --             userInfo->bUserState = USER_ARGEE;
        --             userInfo->iRankNum = queueData[3 * i + 2];
        --             userInfo->iRemainPeople = queueData[3 * i + 3];
        --             //UserInfoModule()->addUser(userInfo);
        --         }

        --         queueUsers.push_back(tmp);
        --         //CC_SAFE_DELETE(tmp);
        --     }
        -- }

        -- // 分发游戏消息
        -- dispatchGameMessage([&deskNo, &queueUsers](IGameMessageDelegate * delegate) -> bool
        -- {
        --     delegate->I_R_M_QueueUserSit(deskNo, queueUsers);
        --     return false;
        -- });
        -- // 分发房间消息
        -- dispatchFrameMessage([&deskNo, &queueUsers](IRoomMessageDelegate * delegate) -> bool
        -- {
        --     delegate->I_R_M_QueueUserSit(deskNo, queueUsers);
        --     return false;
        -- });

        -- for(auto sit : queueUsers)
        -- {
        --     CC_SAFE_DELETE(sit);
        -- }

        -- queueUsers.clear();
end

--// 用户进入房间
function RoomDeal:H_R_M_UserCome(messageHead, object, objectSize)
    local msg = convertToLua(object, RoomMsg.MSG_GR_R_UserCome)
    local userInfo = UserInfoModule:findUserByID(msg.dwUserID);

    UserInfoModule:updateUser(msg.pUserInfoStruct)

    dispatchEvent("H_R_M_UserCome",msg.pUserInfoStruct)
end

--// 用户离开房间
function RoomDeal:H_R_M_UserLeft(messageHead, object, objectSize)
    local msg = convertToLua(object,RoomMsg.MSG_GR_R_UserLeft)

    local userInfo = UserInfoModule:findUserByID(msg.dwUserID);

    if userInfo ~= nil then
        UserInfoModule:removeUser(msg.dwUserID)
        dispatchEvent("H_R_M_UserLeft",userInfo)
    end
end

--// 用户断线
function RoomDeal:H_R_M_UserCut(messageHead, object, objectSize)
    if not checkObjSize(RoomMsg.MSG_GR_R_UserCut, objectSize) then
        luaPrint("MSG_GR_R_UserCut size of error!");
        return;
    end

    local msg = convertToLua(object,RoomMsg.MSG_GR_R_UserCut);

    local userInfo = UserInfoModule:findUserByID(msg.dwUserID);
    
    --// 更新用户数据
    if userInfo ~= nil then
        userInfo.bUserState = USER_CUT_GAME;
        UserInfoModule:updateUser(userInfo);
    end

     Event:dispatchEvent("game","I_R_M_UserCut",{dwUserID = msg.dwUserID, bDeskNO = msg.bDeskNO, bDeskStation = msg.bDeskStation});
end

--// 用户站起（包含旁观站起）
function RoomDeal:H_R_M_UserUp(messageHead, object, objectSize)
    if RoomMsg.ERR_GR_SIT_SUCCESS == messageHead.bHandleCode then
        if not checkObjSize(RoomMsg.MSG_GR_R_UserUp, objectSize) then
            luaPrint("MSG_GR_R_UserUp size of error!");
            return;
        end

        local msg = convertToLua(object,RoomMsg.MSG_GR_R_UserUp);
        if msg.bDeskIndex ~= INVALID_DESKNO then
            local isLocked = (msg.bLock ~= 0);
            local deskNo = msg.bDeskIndex;

            -- if isLocked then
            --     --// 锁桌
            --     self.deskStation.bDeskLock[math.floor(deskNo / 8 + 1)] = bit:_or(self.deskStation.bDeskLock[math.floor(deskNo / 8 + 1)], bit:_lshift(1, (deskNo % 8)));
            -- else
            --     --// 解锁
            --     self.deskStation.bDeskLock[math.floor(deskNo / 8 + 1)] = bit:_and(self.deskStation.bDeskLock[math.floor(deskNo / 8 + 1)], bit:_lshift(1, (deskNo % 8)));
            -- end
        end

        --// 更新自己信息
        if RoomLogic.loginResult.pUserInfoStruct ~= nil and msg.dwUserID == RoomLogic.loginResult.pUserInfoStruct.dwUserID then
            RoomLogic.loginResult.pUserInfoStruct.bDeskNO = msg.bDeskIndex;
            RoomLogic.loginResult.pUserInfoStruct.bDeskStation = msg.bDeskStation;

            RoomLogic.loginResult.pUserInfoStruct.bUserState = msg.bUserState;
        end

        local userInfo = UserInfoModule:findUserByID(msg.dwUserID);
        
        --// 更新用户数据
        if userInfo ~= nil then
            userInfo.bDeskNO = INVALID_DESKNO;
            userInfo.bDeskStation = INVALID_DESKSTATION;
            userInfo.bUserState = USER_LOOK_STATE;
            UserInfoModule:updateUser(userInfo);
        end

        UserInfoModule:removeUser(msg.dwUserID);

        --// 分发消息
        dispatchEvent("I_R_M_UserUp",{bDeskNO = msg.bDeskIndex})
        Event:dispatchEvent("game","I_R_M_UserUp",{data = msg, user = userInfo});
    else
        local message = self:getSitErrorReason(messageHead.bHandleCode);
        --// 分发消息   
        Event:dispatchEvent("game","I_R_M_SitError",message);
    end
end

--// 坐下错误
function RoomDeal:H_R_M_SitError(messageHead, object, objectSize)
    local message = self:getSitErrorReason(messageHead.bHandleCode);
    --// 分发消息   
    luaPrint("坐下失败 ----------- messageHead.bHandleCode "..messageHead.bHandleCode.." , "..message);     
    Event:dispatchEvent("game","I_R_M_SitError",message);

    dispatchEvent("roomLoginFail");
end

function RoomDeal:getSitErrorReason(handleCode)
    if handleCode == RoomMsg.ERR_GR_BEGIN_GAME then
        return "坐下此位置失败,游戏已经开始了!";
    elseif handleCode == RoomMsg.ERR_GR_ALREAD_USER then
        return "坐下此位置失败,下次动作快一点喔!";
    elseif handleCode == RoomMsg.ERR_GR_PASS_ERROR then
        return "游戏桌密码错误,请在游戏设置中重新设置您的携带密码!";
    elseif handleCode == RoomMsg.ERR_GR_IP_SAME then
        return "同桌玩家不允许有相同 IP 地址的玩家一起进行游戏!";
    elseif handleCode == RoomMsg.ERR_GR_IP_SAME_3 then
        return "同桌玩家不允许有 IP 地址前３位相同的玩家一起进行游戏!";
    elseif handleCode == RoomMsg.ERR_GR_IP_SAME_4 then
        return "同桌玩家不允许有IP 地址前４位相同的玩家一起进行游戏!";
    elseif handleCode == RoomMsg.ERR_GR_CUT_HIGH then
        return "同桌玩家认为您的逃跑率太高,不愿意和您游戏!";
    elseif handleCode == RoomMsg.ERR_GR_POINT_LOW then
        return "本桌玩家设置的进入条件，您不符合本桌进入条件!";
    elseif handleCode == RoomMsg.ERR_GR_POINT_HIGH then
        return "本桌玩家设置的进入条件，您不符合本桌进入条件!";
    elseif handleCode == RoomMsg.ERR_GR_NO_FRIEND then
        return "此桌有您不欢迎的玩家!";
    elseif handleCode == RoomMsg.ERR_GR_POINT_LIMIT then
        return "此游戏桌需要至少"..RoomLogic.loginResult.uLessPoint.."的金币,您的金币不够,不能游戏!";
    elseif handleCode == RoomMsg.ERR_GR_CAN_NOT_LEFT then
        return "您正在游戏中...";
    elseif handleCode == RoomMsg.ERR_GR_NOT_FIX_STATION then
        return "您不能加入此游戏桌游戏!";
    elseif handleCode == RoomMsg.ERR_GR_MATCH_FINISH then
        return "您的比赛已经结束了,不能继续参加比赛!";
    elseif handleCode == RoomMsg.ERR_GR_MATCH_WAIT then
        return "比赛排队中";
    elseif handleCode == RoomMsg.ERR_GR_UNENABLE_WATCH then
        return "不允许旁观游戏!";
    elseif handleCode == RoomMsg.ERR_GR_WAIT_DESK_RECYLE then
        return "桌子还没有回收，暂时不能用!";
    elseif handleCode == RoomMsg.ERR_GR_DESK_FULL then
        return "桌子已满!";
    else
        return "桌子坐下未知错误";
    end
end

--// 用户坐下（包含旁观坐下）
function RoomDeal:H_R_M_UserSit(handleCode, msg)
    if handleCode == RoomMsg.ERR_GR_SIT_SUCCESS then
        local userSit = msg;
        luaPrint("更新用户-----------")
        UserInfoModule:updateUser(userSit.pUserInfoStruct);

        --// 锁桌更新
        if userSit.bDeskIndex ~=  INVALID_DESKNO then
            local isLocked = (userSit.bLock ~= 0);
            local deskNo = userSit.bDeskIndex;

            -- if isLocked then
            --     --// 锁桌
            --     RoomLogic.deskStation.bDeskLock[math.floor(deskNo / 8 + 1)] = bit:_or(RoomLogic.deskStation.bDeskLock[math.floor(deskNo / 8 + 1)], bit:_lshift(1, (deskNo % 8)));
            -- else
            --     --// 解锁
            --     RoomLogic.deskStation.bDeskLock[math.floor(deskNo / 8 + 1)] = bit:_and(RoomLogic.deskStation.bDeskLock[math.floor(deskNo / 8 + 1)], bit:_lshift(1, (deskNo % 8)));
            -- end
        end

        --// 更新自己信息
        if RoomLogic.loginResult.pUserInfoStruct and userSit.dwUserID == RoomLogic.loginResult.pUserInfoStruct.dwUserID then
            RoomLogic.loginResult.pUserInfoStruct.bDeskNO = userSit.bDeskIndex;
            RoomLogic.loginResult.pUserInfoStruct.bDeskStation = userSit.bDeskStation;

            RoomLogic.loginResult.pUserInfoStruct.bUserState = userSit.bUserState;
        end

        local userInfo = UserInfoModule:findUserByID(userSit.dwUserID);
        
        --// 更新用户数据
        if userInfo ~= nil then
            userInfo.bDeskNO = userSit.bDeskIndex;
            userInfo.bDeskStation = userSit.bDeskStation;
            userInfo.bUserState = userSit.bUserState;
            UserInfoModule:updateUser(userInfo);
        end

        --// 分发消息
        dispatchEvent("I_R_M_UserSit",msg.pUserInfoStruct)
        Event:dispatchEvent("game","I_RR_M_UserSit",{data = userSit, user = userInfo});
        Event:dispatchEvent("game","I_R_M_UserSit",{data = userSit, user = userInfo});
    end
end

--// 游戏信息
function RoomDeal:H_R_M_GameInfo(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_GameInfo",{object = object});
end

--// 游戏状态
function RoomDeal:H_R_M_GameStation(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_GameStation",{object = object, objectSize = objectSize, messageHead = messageHead});
    dispatchEvent("H_R_M_GameStation",{object = object, objectSize = objectSize, messageHead = messageHead});
end

--// 游戏总结束
function RoomDeal:H_R_M_GameAllEnd(messageHead, object, objectSize)
    local Desk_state = 0;

    if messageHead.bHandleCode then
        Desk_state = messageHead.bHandleCode;
    end
    luaPrint("objectSize --- "..objectSize)
    Event:dispatchEvent("game","I_R_M_GameAllEnd",{object = object, objectSize = objectSize, Desk_state = Desk_state});    
end

--// 普通聊天（表情公用）
function RoomDeal:H_R_M_NormalTalk(messageHead, object, objectSize)
    --luaPrint("收到聊天消息")
    Event:dispatchEvent("game","I_R_M_NormalTalk",{object = object, objectSize = objectSize, messageHead = messageHead});  
end

--//桌子需要被回收
function RoomDeal:H_R_M_RecycleDesk(messageHead, object, objectSize)

    Event:dispatchEvent("game","I_R_M_RecycleDesk",{object = object, objectSize = objectSize, messageHead = messageHead});
end

--// 语音聊天（）
function RoomDeal:H_R_M_VoiceTalk(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_VoiceTalk",{bAssistantID = messageHead.bAssistantID, object = object, objectSize = objectSize});    
end

--//继续下一局
function RoomDeal:H_R_M_ContinueNextRound(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_ContinueNextRound",{bAssistantID = messageHead.bAssistantID,object = object, objectSize = objectSize});
end

--请求救济金
function RoomDeal:H_R_M_RequestReliefMoney(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_RequestReliefMoney",{bAssistantID = messageHead.bAssistantID,object = object, objectSize = objectSize});
end

--请求救济金结果
function RoomDeal:H_R_M_RequestReliefMoneyResult(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_RequestReliefMoneyResult",{bAssistantID = messageHead.bAssistantID,object = object, objectSize = objectSize});
end

--存取分结果
function RoomDeal:H_R_M_SaveScore(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_SaveScore",{bAssistantID = messageHead.bAssistantID,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_GetScore(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_GetScore",{bAssistantID = messageHead.bAssistantID,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_UserLevelUp(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_UserLevelUp",{bAssistantID = messageHead.bAssistantID,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_UserGetTaskList(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_UserGetTaskList",{messageHead = messageHead,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_UserRewarldRes(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_UserRewarldRes",{messageHead = messageHead,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_Taskcount(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_Taskcount",{messageHead = messageHead,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_Buymoney(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_Buymoney",{messageHead = messageHead,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_RetryMatch(messageHead, object, objectSize)
    Event:dispatchEvent("game","I_R_M_RetryMatch",{messageHead = messageHead,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_GetGoodsInfo(messageHead, object, objectSize)
    GameGoodsInfo:onReceiveGoodsInfo(messageHead, object);
    -- Event:dispatchEvent("game","I_R_M_GetGoodInfo",{messageHead = messageHead,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_UpdateGoodsInfo(messageHead, object, objectSize)
    GameGoodsInfo:onReceiveGoodsInfoChange(object);
    -- Event:dispatchEvent("game","I_R_M_UpdateGoodInfo",{messageHead = messageHead,object = object, objectSize = objectSize});
end

function RoomDeal:H_R_M_SynGoodsInfo(messageHead, object, objectSize)
    GameGoodsInfo:onReceiveGoodsInfoSyn(object);
end

function RoomDeal:MDM_GP_USERINFO(msg)
    local assistantID = msg:getHead(3)
    local handleID = msg:getHead(4)
    if PlatformMsg.ASS_GP_USERINFO_GET == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_USERINFO)

        Event:dispatchEvent("game","ASS_GP_USERINFO_GET_R", {data = msg, code = handleID});
    elseif PlatformMsg.ASS_GP_USERINFO_ACCEPT == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_R_LogonResult)

        Event:dispatchEvent("game","ASS_GP_USERINFO_ACCEPT_R", {data = msg, code = handleID});
    end
end

function RoomDeal:H_R_M_Message(msg)
    local assistantID = msg:getHead(3)

    if assistantID == RoomMsg.ASS_GR_SYSTEM_MESSAGE then
        local msg = convertToLua(msg,RoomMsg.MSG_GA_S_Message)
        luaDump(msg,"系统消息")
        addScrollMessage(msg.szMessage)
    end
end

function RoomDeal:MZTW_ROOMINFO(msg)
    local assistantID = msg:getHead(3)

    if assistantID == RoomMsg.ASS_ZTW_GAMERECORED then
        if globalUnit.bIsSelectDesk == true then
            dispatchEvent("ASS_ZTW_GAMERECORED",msg);
        end
    elseif assistantID == RoomMsg.ASS_ZTW_CHANGEGAMESTATION then
        dispatchEvent("ASS_ZTW_CHANGEGAMESTATION",msg);
    end
end

function RoomDeal:dispatchEvent(mainID, subID, data)
    if self.dataListener[mainID] ~= nil then
        if self.dataListener[mainID][subID] ~= nil then
            for k,listener in pairs(self.dataListener[mainID][subID]) do
                listener:onReceiveCmdResponse(mainID, subID, data);
            end
        else
            luaPrint("dispatchEvent 异常 subID = "..subID)
        end
    else
        luaPrint("dispatchEvent 异常 mainID = "..mainID)
    end
end

return RoomDeal;
