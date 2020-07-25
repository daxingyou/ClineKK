local function checkObjSize(obj,objSize)
    if getObjSize(obj) == objSize then
        return true
    else
        luaPrint("the PlatformMsg receive size is error!!!",getObjSize(obj) .. " objSize:" .. objSize)
        return true
    end
end

local _instance = nil;

local PlatformDeal = class("PlatformDeal")

function PlatformDeal:getInstance()
    if _instance == nil then
        _instance = PlatformDeal.new();
    end

    return _instance;
end

function PlatformDeal:ctor()
    self.dataListener = {};
end

function PlatformDeal:start()
    self:init();
end

function PlatformDeal:stop()
    self:unBindEvent();
end

function PlatformDeal:init()
    --注册事件
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_CONNECT,self,"platform")  --// 平台连接
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_REQURE_GAME_PARA,self,"platform")
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_LOGON,self,"platform")    --// 平台登录
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_REGISTER,self,"platform") --// 注册
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_DESK_LOCK_PASS,self,"platform") --////桌子密码消息
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_LIST,self,"platform") --// 列表（类型、名称、房间、房间密码、房间人数、游戏人数）
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(UserLogoMsg.MDM_GR_USER_LOGO,self,"platform")  --// 头像相关
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_LOGONUSERS,self,"platform")  --// 登陆玩家数量
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_PROP,self,"platform")  --// 道具
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(ImMsg.MDM_GP_IM,self,"platform")  --// 好友
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_MESSAGE,self,"platform")  --// 消息
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_GIFT,self,"platform")  --// 平台连接
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_CHARMEXCHANGE,self,"platform")--兑换
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_USERINFO,self,"platform")--
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_CONNECT,self,"platform")--
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_PLAYER,self,"platform")    --// 角色系统
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_RANK,self,"platform")    --// 角色排行
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_MAIL,self,"platform")    --//邮件系统
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_TASK,self,"platform")    --//任务系统
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_VIP,self,"platform")    --//月卡系统
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_USERSCORE,self,"platform")    --//首冲
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_CONFIG,self,"platform")    ----物品配置系统
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_FISH_MATCH,self,"platform")    ----捕鱼比赛
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MZTW_USERINFO,self,"platform")
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_AGENCY,self,"platform")
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_CASH,self,"platform")
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_WEB_INFO,self,"platform")
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(PlatformMsg.MDM_GP_ACTIVITIES,self,"platform")
    self.bindIds[#self.bindIds + 1] = Event:bindEvent(VipMsg.MDM_GP_GUILD,self,"platform")
end

function PlatformDeal:unBindEvent()
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
function PlatformDeal:registerCmdReceiveNotify(cmdId, subId, listener)
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
        luaPrint("PlatformDeal: listener is nil or noHttpResponse() function not implemented!")
    end
end

---注销网络数据接收通知
-- @param #int cmdId 监听的协议id
-- @param #obj listener
function PlatformDeal:unregisterCmdReceiveNotify(cmdId,subId,listener)
    if self.dataListener[cmdId] ~= nil and self.dataListener[cmdId][subId] ~= nil then
        self.dataListener[cmdId][subId][tostring(listener)] = nil
    end
end

function PlatformDeal:clearAllRegisterCmdNotify()
    self.dataListener = {}
end

function PlatformDeal:onReceiveCmdRespone(data)
    local mainID = tonumber(data:getHead(2));

    if mainID == PlatformMsg.MDM_GP_CONNECT then
        self:H_P_M_Connect(data);
    elseif mainID == PlatformMsg.MDM_GP_REQURE_GAME_PARA then
        self:onConnectConterMessage(data);
    elseif mainID == PlatformMsg.MDM_GP_LOGON then
        self:H_P_M_Login(data);
    elseif mainID == PlatformMsg.MDM_GP_REGISTER then
        self:H_P_M_Regist(data);
    elseif mainID == PlatformMsg.MDM_GP_DESK_LOCK_PASS then
        self:MDM_GP_DESK_LOCK_PASS(data);
    elseif mainID == PlatformMsg.MDM_GP_LIST then
        self:H_P_M_List(data);
    elseif mainID == UserLogoMsg.MDM_GR_USER_LOGO then
        self:onUserUploadMessage(data);
    elseif mainID == PlatformMsg.MDM_GP_LOGONUSERS then
        self:H_P_M_LoginUsers(data);
    elseif mainID == PlatformMsg.MDM_GP_PROP then
        self:H_P_M_Prop(data);
    elseif mainID == ImMsg.MDM_GP_IM then
        self:onFriendInformMessage(data);
    elseif mainID == PlatformMsg.MDM_GP_MESSAGE then
        self:H_P_M_Message(data);
    elseif mainID == PlatformMsg.MDM_GP_GIFT then
        self:reveiveGiftNotify(data);
    elseif mainID == PlatformMsg.MDM_GP_CHARMEXCHANGE then
        self:H_P_M_GetList(data);
    elseif mainID == PlatformMsg.MDM_GP_USERINFO then
        self:MDM_GP_USERINFO(data);
    elseif mainID == PlatformMsg.MDM_CONNECT then
        self:H_P_M_Heart(data);
    elseif mainID == PlatformMsg.MDM_GP_PLAYER then--角色系统
        self:H_P_M_Player(data);
    elseif mainID == PlatformMsg.MDM_RANK then--角色排行  
        self:H_P_M_Ranking(data);
    elseif mainID == PlatformMsg.MDM_GP_MAIL then--邮件系统
        self:H_P_M_Mail(data);
    elseif mainID == PlatformMsg.MDM_TASK then--任务系统
        self:H_P_M_Task(data);
    elseif mainID == PlatformMsg.MDM_VIP then--月卡系统
        self:H_P_M_Yueka(data);
    elseif mainID == PlatformMsg.MDM_CONFIG then--物品配置系统
        self:H_P_M_GoodsConfig(data);
    elseif mainID == PlatformMsg.MDM_USERSCORE then--首冲系统
        self:H_P_M_Chongzhi(data);
    elseif mainID == PlatformMsg.MDM_FISH_MATCH then--捕鱼比赛
        self:H_P_M_FishMatch(data);
    elseif mainID == PlatformMsg.MZTW_USERINFO then
        self:H_P_M_MZTW(data)
    elseif mainID == PlatformMsg.MDM_AGENCY then
        self:H_P_M_AGENCY(data)
    elseif mainID == PlatformMsg.MDM_CASH then
        self:H_P_M_Cash(data)
    elseif mainID == PlatformMsg.MDM_GP_WEB_INFO then
        self:H_P_M_Web(data)
    elseif mainID == PlatformMsg.MDM_GP_ACTIVITIES then
        self:H_P_M_Activity(data)
    elseif mainID == VipMsg.MDM_GP_GUILD then
        self:H_P_M_Vip(data)
    else
        luaPrint("platformLogic recevie error mainID  : "..mainID.." subID : "..data:getHead(3));
    end
end

function PlatformDeal:H_P_M_Heart(msg)
    luaPrint("H_P_M_Heart")
end

--// 平台连接
function PlatformDeal:H_P_M_Connect(msg)
    local assistantID = msg:getHead(3)

    if assistantID == 3 then
        if not checkObjSize(PlatformMsg.MSG_S_ConnectSuccess,msg:getHead(1)-20) then
            return
        end

        local msg = convertToLua(msg,PlatformMsg.MSG_S_ConnectSuccess)
        luaDump(msg)
        -- PlatformLogic.checkCode = math.floor((msg.i64CheckCode-GameConfig.SECRECT_KEY)/23)
        PlatformLogic.checkCode = PlatformLogic.socketLogic:getCheckCode()--msg.i64CheckCode;
        -- PlatformLogic.socketLogic:setCheckCode(PlatformLogic.checkCode)
        PlatformLogic.sendData:setCheckCode(PlatformLogic.checkCode)
        if PlatformLogic.cServer then
            PlatformLogic.connected = true
            luaPrint("中心服务器连接完成")
            Event:dispatchEvent("platform","I_P_M_Connect",PlatformLogic.connected);
            if isTimeoutInit then
                isTimeoutInit = nil
                LoadingLayer:removeLoading()
            end
        else
            PlatformLogic:send(PlatformMsg.MDM_GP_REQURE_GAME_PARA, 0)
        end
    elseif assistantID == 4 then
        PlatformLogic:close()
    end
end

function ipVaild(ip)
    if ip == nil or ip == "" or type(ip) ~= "string" then
        return false
    end

    local ip = string.split(ip,".")

    for k,v in pairs(ip) do
        local n = tonumber(v)
        if n == nil then
            return false
        else
            if n < 0 or n > 255 then
                return false
            end
        end
    end

    return true
end

function portVaild(port)
    if port == nil or port == "" then
        return false
    end

    if tonumber(port) == nil then
        return false
    end

    return true
end

function PlatformDeal:onConnectConterMessage(msg)
    if not checkObjSize(PlatformMsg.CenterServerMsg,msg:getHead(1)-20) then
        return
    end
    local msg = convertToLua(msg,PlatformMsg.CenterServerMsg)
    luaDump(msg,"centermessage")
    PlatformLogic:close()

    if not ipVaild(msg.m_strMainserverIPAddr) and not netAddrVaild(msg.m_strMainserverIPAddr) then
        -- return
    end

    if not portVaild(msg.m_iMainserverPort) then
        return
    end

    PlatformLogic.cServer = true
    PlatformLogic.ip = msg.m_strMainserverIPAddr
    PlatformLogic.port = msg.m_iMainserverPort
    PlatformLogic.centerMessage = msg

    local username = cc.UserDefault:getInstance():getStringForKey(USERNAME_TEXT, "")
    local password = cc.UserDefault:getInstance():getStringForKey(PASSWORD_TEXT, "")
    luaPrint("globalUnit.isSDKInit ",globalUnit.isSDKInit, " username ",username," password ",password)

    if globalUnit.isSDKInit or (username ~= "" and password ~= "" and (globalUnit:getLoginType() == accountLogin or device.platform == "windows")) then
        if globalUnit.isSDKInit then
            isTimeoutInit = true
        end
        LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录服中,请稍后"), LOADING):removeTimer(10)
        PlatformLogic:connect()
    else
        LoadingLayer:removeLoading()
    end
end

--充值系统
function PlatformDeal:H_P_M_Chongzhi(msg)
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4);
    if PlatformMsg.ASS_GP_GET_SHOUCHONG == assistantID then  --
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_SHOUCHONG);
        Event:dispatchEvent("platform","ASS_GP_GET_SHOUCHONG",{data = msg, code = handCode});
        --luaDump(msg,"ASS_GP_GET_SHOUCHONG")
    end
end

--物品配置系统
function PlatformDeal:H_P_M_GoodsConfig(msg)
    local mainID = msg:getHead(2)
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4);
    local objectSize = msg:getHead(1)-20
    if PlatformMsg.ASS_GP_GET_CONFIG == assistantID then  --
        -- local data = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_CONFIG); --获取物品配置
        -- -- Event:dispatchEvent("platform","ASS_GP_GET_CONFIG",{data = msg, code = handCode});
        -- self:dispatchEvent(msg:getHead(2),assistantID,{data=data})
        local count = objectSize /getObjSize(PlatformMsg.MSG_GP_S_GET_CONFIG)
        for i=1,count do
            local data = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_CONFIG)
            self:dispatchEvent(msg:getHead(2),assistantID,{data=data})
        end
    elseif PlatformMsg.ASS_GP_GET_RAT == assistantID then--获取游戏税收比例
        local data = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_RAT)
        dispatchEvent("ASS_GP_GET_RAT",data);
    elseif PlatformMsg.ASS_GP_GET_CHARGE_URL == assistantID then
        self:dispatchEvent(mainID,assistantID,msg)
    end
end

--任务系统
function PlatformDeal:H_P_M_Task(msg)
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4);
    luaPrint("任务系统*********assistantID handCode"..assistantID.."---"..handCode)
    if PlatformMsg.ASS_GP_GET_TASKLIST == assistantID then  --
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_TASKLIST); --获取任务列表
        Event:dispatchEvent("platform","ASS_GP_GET_TASKLIST",{data = msg, code = handCode});
        luaDump(msg,"ASS_GP_GET_TASKLIST")
    elseif PlatformMsg.ASS_GP_UPDATE_TASK == assistantID then --领取
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_UPDATETASK);
        Event:dispatchEvent("platform","ASS_GP_UPDATE_TASK",{data = msg, code = handCode});
        luaDump(msg,"ASS_GP_UPDATE_TASK")
    end
end

--月卡系统
function PlatformDeal:H_P_M_Yueka(msg)
    local objectSize = msg:getHead(1)-20
    local assistantID = msg:getHead(3)
    local mainID = msg:getHead(2)
    local handCode = msg:getHead(4);
    luaPrint("月卡系统*********assistantID handCode"..assistantID.."---"..handCode)
    if PlatformMsg.ASS_GP_GET_VIP == assistantID then  --
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GETVIP); 
        -- Event:dispatchEvent("platform","ASS_GP_GET_VIP",{data = msg, code = handCode});
        -- luaDump(msg,"ASS_GP_GET_VIP")
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif PlatformMsg.ASS_GP_GET_YkScore == assistantID then 
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GETYKSCORE);
        Event:dispatchEvent("platform","ASS_GP_GET_YkScore",{data = msg, code = handCode});
        --luaDump(msg,"ASS_GP_GET_YkScore")
    elseif PlatformMsg.ASS_GP_GET_FavCompain == assistantID then 
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GETFavCom);
        Event:dispatchEvent("platform","ASS_GP_GET_FavCompain",{data = msg, code = handCode});
        --luaDump(msg,"ASS_GP_GET_FavCompain")
    elseif PlatformMsg.ASS_GP_GET_NewUserRewardStateList == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_NewUserRewardStateList);
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif PlatformMsg.ASS_GP_GET_NewUserReward == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_NewReward);
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif PlatformMsg.ASS_GP_GET_NewUserRewardList == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_SIGNLISTINFO);
        self:dispatchEvent(mainID,assistantID,{code=handCode,data=msg});
    elseif PlatformMsg.ASS_GP_GET_VipList == assistantID then    --7
        local count = objectSize /getObjSize(PlatformMsg.MSG_GP_S_GET_VIP_LIST)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_VIP_LIST);
            -- luaDump(msg,"获取Vip列表")
            table.insert(data, msg);
        end
        self:dispatchEvent(mainID,assistantID,{data=data});
    elseif PlatformMsg.ASS_GP_GET_UserVipReward == assistantID then   --8
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_VIP_REWARD);
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif PlatformMsg.ASS_GP_GET_PaoTaiList == assistantID then --9
        local count = objectSize /getObjSize(PlatformMsg.MSG_GP_S_GET_PAOTAILIST)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_PAOTAILIST);
            -- luaDump(msg,"获取炮台列表")
            table.insert(data, msg);
        end
        self:dispatchEvent(mainID,assistantID,{data=data});
    elseif PlatformMsg.ASS_GP_Get_UserPaoTai == assistantID then --10
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_USER_PAOTAI);
        -- luaDump(msg,"获取个人炮台信息")
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif PlatformMsg.ASS_GP_BUY_PaoTai == assistantID then --11
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_BUY_PAOTAI);
        -- luaDump(msg,"购买炮台")
        self:dispatchEvent(mainID,assistantID,{data=msg});
    end
end

--邮件系统
function PlatformDeal:H_P_M_Mail(msg)
    local mainID = msg:getHead(2)
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4)

    if PlatformMsg.ASS_GP_GET_MAILLIST == assistantID then
        -- msg.goodsList = divisionStr(msg.Goods);
        -- Event:dispatchEvent("platform","ASS_GP_GET_MAILLIST",{data = msg, code = handCode});
        self:dispatchEvent(mainID,assistantID,msg)
    elseif PlatformMsg.ASS_GP_GET_GOODS == assistantID then --获取邮件物品11
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_MAILSRESULT);
        Event:dispatchEvent("platform","ASS_GP_GET_GOODS",{data = msg, code = handCode});
    elseif PlatformMsg.ASS_GP_READ_MAIL == assistantID then --读邮件12
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_MAILSRESULT);
        -- Event:dispatchEvent("platform","ASS_GP_READ_MAIL",{data = msg, code = handCode});
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_DELETE_MAIL == assistantID then --删除邮件13
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_MAILSRESULT);
        -- Event:dispatchEvent("platform","ASS_GP_DELETE_MAIL",{data = msg, code = handCode});
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_GET_QUESTION == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_QUESTIONLIST);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}})
    elseif PlatformMsg.ASS_GP_ADD_QUESTION == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_ADDQUESTION);
        self:dispatchEvent(mainID,assistantID,{data=msg})
    end
end

--角色排行
function PlatformDeal:H_P_M_Ranking(msg)
    local objectSize = msg:getHead(1)-20
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4);
    luaPrint("*********排行assistantID handCode"..assistantID.."---"..handCode)
    if PlatformMsg.ASS_GP_GET_RANKLIST == assistantID then
        local count = objectSize /getObjSize(PlatformMsg.MSG_GET_RANK_LIST)
        local rankdata = {};
        for i=1,count do
            local msg = convertToLua(msg,PlatformMsg.MSG_GET_RANK_LIST);
            table.insert(rankdata, msg);
        end
        Event:dispatchEvent("platform","ASS_GP_GET_RANKLIST",{rankType = 1,data = rankdata, code = handCode});
    elseif PlatformMsg.ASS_GP_GET_BOSSRANKLIST == assistantID then
        local count = objectSize /getObjSize(PlatformMsg.MSG_GET_RANK_LIST)
        local rankdata = {};
        for i=1,count do
            local msg = convertToLua(msg,PlatformMsg.MSG_GET_BOSSRANK_LIST);
            luaDump(msg,"ASS_GP_GET_BOSSRANKLIST")
            table.insert(rankdata, msg);
        end
        Event:dispatchEvent("platform","ASS_GP_GET_RANKLIST",{rankType = 2,data = rankdata, code = handCode});
    end
end

--角色系统
function PlatformDeal:H_P_M_Player(msg)
    local objectSize = msg:getHead(1)-20
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4);
    local mainID = msg:getHead(2)
    
    if PlatformMsg.ASS_GP_ADD_PLAYER == assistantID then  --添加角色结果14
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_PLAYERRESULT);
        Event:dispatchEvent("platform","ASS_GP_ADD_PLAYER",{data = msg, code = handCode});
    elseif PlatformMsg.ASS_GP_LOGON_PLAYER_LIST == assistantID then --获取角色列表结果20
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_PLAYERLIST);
        Event:dispatchEvent("platform","ASS_GP_LOGON_PLAYER_LIST",{data = msg, code = handCode});
    elseif PlatformMsg.ASS_GP_SWITCH_PLAYER == assistantID then --获取切换角色结果15
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_PLAYERRESULT);
        Event:dispatchEvent("platform","ASS_GP_SWITCH_PLAYER",{data = msg, code = handCode});
    elseif PlatformMsg.ASS_GP_TRANS_PLAYER == assistantID then --获取转移角色结果16
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_TRANSPLAYER);
        Event:dispatchEvent("platform","ASS_GP_TRANS_PLAYER",{data = msg, code = handCode});
    elseif PlatformMsg.ASS_GP_CHANGE_PNAME == assistantID then --获取角色改名结果17
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_PLAYERRESULT);
        Event:dispatchEvent("platform","ASS_GP_CHANGE_PNAME",{data = msg, code = handCode});
    elseif PlatformMsg.ASS_GP_STORE_SCORE == assistantID then --获取角色存分结果18
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_PLAYERSCORE);
        Event:dispatchEvent("platform","ASS_GP_STORE_SCORE",{data = msg, code = handCode});
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_GET_SCORE == assistantID then --获取角色取分结果19
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_PLAYERSCORE);
        Event:dispatchEvent("platform","ASS_GP_GET_SCORE",{data = msg, code = handCode});
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_GET_JIUJI == assistantID then --获取救济金结果21
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_JIUJI);
        -- Event:dispatchEvent("platform","ASS_GP_GET_JIUJI",{data = msg, code = handCode});
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_JIUJI_TIP == assistantID then --获取救济金结果22
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_JIUJI);
        Event:dispatchEvent("platform","ASS_GP_JIUJI_TIP",{data = msg, code = handCode});
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_SET_BANKPASS == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_SETBANKPASSRESULT)
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_GET_BANKLOG == assistantID then
        local count = objectSize /getObjSize(PlatformMsg.MSG_GP_S_GETBANKLOG)
        local data = {}
        for i=1,count do
            local temp = convertToLua(msg,PlatformMsg.MSG_GP_S_GETBANKLOG)
            if temp and temp. bType ~= "" then
                table.insert(data,temp)
            end
        end
        self:dispatchEvent(mainID,assistantID,{data=data})
    elseif PlatformMsg.ASS_GP_GET_BANKREALTIME == assistantID then--余额宝
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_BANKREALTIME);
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_TRANSFER_INFO == assistantID then --转账对方信息
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_TRANSFERINFO);
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_TRANSFER_SCORE == assistantID then --转账返回信息
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_PLAYERSCORE);
        self:dispatchEvent(mainID,assistantID,{data=msg})
    end
end

function PlatformDeal:H_P_M_Login(msg)
    local assistantID = msg:getHead(3)
    if PlatformMsg.ASS_GP_LOGIN_SWITCH == assistantID then

    elseif PlatformMsg.ASS_GP_LOGON_SUCCESS == assistantID or PlatformMsg.ASS_GP_LOGON_ERROR == assistantID then
        if not checkObjSize(PlatformMsg.MSG_GP_R_LogonResult,msg:getHead(1)-20) then
            luaPrint("MSG_GP_R_LogonResult size is error");
            -- return
        end
        local handCode = msg:getHead(4);

        if handCode == PlatformMsg.ERR_GP_LOGON_SUCCESS then
            luaPrint("登陆成功")
            local msg = convertToLua(msg,PlatformMsg.MSG_GP_R_LogonResult)
            -- luaDump(msg)
            PlatformLogic.loginResult = msg;
            reyunSetLoginSuccess(PlatformLogic.loginResult.dwUserID)
            -- if not isEmptyString(PlatformLogic.loginResult.szMobileNo) then
            if PlatformLogic.loginResult.IsCommonUser == 1 then
                globalUnit:setLoginType(accountLogin)
            end
        end

        PlatformLogic.isLogined = (PlatformMsg.ERR_GP_LOGON_SUCCESS == handCode);            
        Event:dispatchEvent("platform","I_P_M_Login",{logined = PlatformLogic.isLogined, code = handCode});
        dispatchEvent("I_P_M_Login",{logined = PlatformLogic.isLogined, code = handCode})
    elseif PlatformMsg.ASS_GP_CHECK_PHONE == assistantID then--绑定手机号
        -- luaPrint("收到绑定手机号成功或失败的消息")
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_R_Check_Phone)
        Event:dispatchEvent("platform","ASS_GP_BindPhone",{code = msg.dwResult});
    elseif PlatformMsg.ASS_GP_LOGON_ALLO_PART == assistantID then
        dispatchEvent("accountQuit")
    end
end

function PlatformDeal:H_P_M_Regist(msg)
    local handCode = msg:getHead(4)
    
    if not checkObjSize(PlatformMsg.MSG_GP_S_Register,msg:getHead(1)-20) then
        luaPrint("MSG_GP_S_Register size is error");
        -- return
    end

    luaPrint("注册成功")
    local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_Register)
    Event:dispatchEvent("platform","I_P_M_Regist",{data = msg, code = handCode});
end

function PlatformDeal:MDM_GP_DESK_LOCK_PASS(msg)
    local assistantID = msg:getHead(3)
    local handleID = msg:getHead(4)
    if PlatformMsg.ASS_GP_GET_ROOM == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_Room_CutNet_User_struct)
        Event:dispatchEvent("platform","ASS_GP_GET_ROOM", {data = msg, code = handleID});
    elseif PlatformMsg.ASS_GP_DESK_LOCK_PASS == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_DESK_LOCK_PASS)
        Event:dispatchEvent("platform","ASS_GP_DESK_LOCK_PASS", {data = msg, code = handleID});
    elseif PlatformMsg.ASS_GP_GET_ROOM_CREATE_INFO == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_CreateDeskCost_RES)
        Event:dispatchEvent("platform","ASS_GP_GET_ROOM_CREATE_INFO",{data = msg, code = handleID});
    elseif PlatformMsg.ASS_GP_USE_ROOM_KEY == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_USE_ROOM_KEY)
        Event:dispatchEvent("platform","ASS_GP_USE_ROOM_KEY",{data = msg, code = handleID});
    elseif PlatformMsg.ASS_GET_MIN_ROOM_KEY_NUM == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY)
        -- GamesInfoModule:updateGameListGold(msg.iNameID,msg.nMinRoomKey);--记录金币场消耗金币
        RoomInfoModule:updateMinNeedGold(msg)
        Event:dispatchEvent("platform","ASS_GET_MIN_ROOM_KEY_NUM",{data = msg, code = handleID});
    elseif PlatformMsg.ASS_CREATE_ROOM_FOR_OTHER == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_USE_ROOM_KEY)
        Event:dispatchEvent("platform","ASS_CREATE_ROOM_FOR_OTHER",{data = msg, code = handleID});
    elseif PlatformMsg.ASS_ROOM_LIST == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_ROOMLIST)
        Event:dispatchEvent("platform","ASS_ROOM_LIST",{data = msg, code = handleID});
    elseif PlatformMsg.ASS_DISMISS == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_C_DISMISS)
        Event:dispatchEvent("platform","ASS_DISMISS",{data = msg, code = handleID});
    end 
end

function PlatformDeal:H_P_M_List(msg)
    local assistantID = msg:getHead(3)
    local messageHead = {};
    messageHead.uMessageSize = msg:getHead(1);
    messageHead.bMainID = msg:getHead(2);
    messageHead.bAssistantID = msg:getHead(3);
    messageHead.bHandleCode = msg:getHead(4);
    messageHead.bReserve = msg:getHead(5);
    local objectSize = msg:getHead(1) - 20;
    local object = msg;

    -- // 类型列表
    if PlatformMsg.ASS_GP_LIST_KIND == messageHead.bAssistantID then
        self:H_P_M_ListKind(messageHead, object, objectSize);
    -- // 名称列表
    elseif PlatformMsg.ASS_GP_LIST_NAME == messageHead.bAssistantID then
        self:H_P_M_ListName(messageHead, object, objectSize);
    -- // 人数列表
    elseif PlatformMsg.ASS_GP_LIST_COUNT == messageHead.bAssistantID then
        if not checkObjSize(PlatformMsg.DL_GP_RoomListPeoCountStruct, objectSize) then
            return;
        end

        -- // 房间人数
        if 0 == messageHead.bHandleCode then
            self:H_P_M_ListRoomUserCount(messageHead, object, objectSize);
        -- // 游戏人数
        else
            self:H_P_M_ListGameUserCount(messageHead, object, objectSize);
        end
    -- // 房间列表
    elseif PlatformMsg.ASS_GP_LIST_ROOM == messageHead.bAssistantID then
        self:H_P_M_ListRoom(messageHead, object, objectSize);
    -- // 房间密码
    elseif PlatformMsg.ASS_GP_ROOM_PASSWORD == messageHead.bAssistantID then
        self:H_P_M_ListRoomPassword(messageHead, object, objectSize);
    end
end

-- // 类型列表
function PlatformDeal:H_P_M_ListKind(messageHead, object, objectSize)
    local count = objectSize /getObjSize(ComStruct.ComKindInfo)
    for i=1,count do
        local msg = convertToLua(object,ComStruct.ComKindInfo)
         GamesInfoModule:addGameKind(msg);
    end
end

-- // 名称列表
function PlatformDeal:H_P_M_ListName(messageHead, object, objectSize)
    local count = objectSize /getObjSize(ComStruct.ComNameInfo)
    for i=1,count do
        local msg = convertToLua(object,ComStruct.ComNameInfo)
        GamesInfoModule:addGameName(msg);
        GameCreator:setGameKindId(msg.uNameID, msg.uKindID);
    end

    if PlatformMsg.ERR_GP_LIST_FINISH  == messageHead.bHandleCode then
        GamesInfoModule.isStart = nil;
        GamesInfoModule.isEnd = true;
        GamesInfoModule.copyGameList = nil;
        Event:dispatchEvent("platform","I_P_M_GameList");
    end
end

-- // 房间人数
function PlatformDeal:H_P_M_ListRoomUserCount(messageHead, object, objectSize)
    local count = objectSize /getObjSize(PlatformMsg.DL_GP_RoomListPeoCountStruct)
    for i=1,count do
        local msg = convertToLua(object,PlatformMsg.DL_GP_RoomListPeoCountStruct)

        local room = RoomInfoModule:getByRoomID(msg.uID);
        if room ~= nil then
            room.uPeopleCount = msg.uPeopleCount;
            room.uVirtualUser = msg.uVirtualUser;

            RoomInfoModule:updateRoom(room);

            Event:dispatchEvent("platform","I_P_M_RoomUserCount",{uID = msg.uID, uOnLineCount = msg.uOnLineCount, uVirtualUser = msg.uVirtualUser});
        end
    end
end

-- // 游戏人数
function PlatformDeal:H_P_M_ListGameUserCount(messageHead, object, objectSize)
    local count = objectSize /getObjSize(PlatformMsg.DL_GP_RoomListPeoCountStruct)

    for i=1,count do
        local msg = convertToLua(object,PlatformMsg.DL_GP_RoomListPeoCountStruct)
        luaDump(msg)
        Event:dispatchEvent("platform","I_P_M_GameUserCount",msg);
    end
end

-- // 房间列表
function PlatformDeal:H_P_M_ListRoom(messageHead, object, objectSize)
    luaPrint("房间列表 获取 objectSize = "..objectSize.."  , getObjSize(PlatformMsg.MSG_GP_SR_GetRoomStruct) == "..getObjSize(PlatformMsg.MSG_GP_SR_GetRoomStruct))
     if objectSize >= getObjSize(PlatformMsg.MSG_GP_SR_GetRoomStruct) then
        -- // 跳过房间ComRoomInfo数据前包含MSG_GP_SR_GetRoomStruct结构体，要跳过MSG_GP_SR_GetRoomStruct头。
        convertToLua(object,PlatformMsg.MSG_GP_SR_GetRoomStruct)
        luaPrint("objectSize === "..objectSize);
        luaPrint("getObjSize(PlatformMsg.MSG_GP_SR_GetRoomStruct) === "..getObjSize(PlatformMsg.MSG_GP_SR_GetRoomStruct))
        luaPrint("getObjSize(ComStruct.ComRoomInfo) == "..getObjSize(ComStruct.ComRoomInfo))
        local count = (objectSize - getObjSize(PlatformMsg.MSG_GP_SR_GetRoomStruct))/getObjSize(ComStruct.ComRoomInfo)
        luaPrint("房间列表 count "..count);
        if count > 0 then
            for i=1,count do
                luaPrint("convertToLua(object,ComStruct.ComRoomInfo) -----------")
                local roomInfo = convertToLua(object,ComStruct.ComRoomInfo)
                luaPrint("convertToLua(object,ComStruct.ComRoomInfo) -----*********------")
                luaDump(roomInfo,"roomInfo")
                RoomInfoModule:addRoom(roomInfo);
            end
        else
            luaDump(convertToLua(object,ComStruct.ComRoomInfo),"ComRoomInfo");
        end

        if PlatformMsg.ERR_GP_LIST_FINISH == messageHead.bHandleCode then
            RoomInfoModule:addRoomInfo(GameCreator:getCurrentGameNameID())
            Event:dispatchEvent("platform","I_P_M_RoomList");
            dispatchEvent("I_P_M_RoomList")
        end
    end
end

-- // 房间密码
function PlatformDeal:H_P_M_ListRoomPassword(messageHead, object, objectSize)
    if not checkObjSize(PlatformMsg.MSG_GP_S_C_CheckRoomPasswd,msg:getHead(1)-20) then
        luaPrint("MSG_GP_S_C_CheckRoomPasswd size is error");
        return
    end

    local msg = convertToLua(object,PlatformMsg.MSG_GP_S_C_CheckRoomPasswd);
     Event:dispatchEvent("platform","I_P_M_RoomPassword");
end

function PlatformDeal:H_P_M_GetList(msg)
    local assistantID = msg:getHead(3)
    local handleID = msg:getHead(4)
    if PlatformMsg.ASS_GETLIST == assistantID then
        local msg = convertToLua(msg,PlatformMsg.CMD_ExChangeRat)
        Event:dispatchEvent("platform","ASS_GETLIST", {data = msg, code = handleID});
    elseif PlatformMsg.ASS_EXCHANGE == assistantID then
        local msg = convertToLua(msg,PlatformMsg.CMD_ExChangeResult)
        Event:dispatchEvent("platform","ASS_EXCHANGE", {data = msg, code = handleID});
    elseif PlatformMsg.ASS_GETHUAFEILIST == assistantID then
        local msg = convertToLua(msg,PlatformMsg.CMD_ListHF)
        Event:dispatchEvent("platform","ASS_GETHUAFEILIST", {data = msg, code = handleID});
    elseif PlatformMsg.ASS_GETGOODLIST == assistantID then
        local msg = convertToLua(msg,PlatformMsg.CMD_GiftGoodList)
        Event:dispatchEvent("platform","ASS_GETGOODLIST", {data = msg, code = handleID});
    elseif PlatformMsg.ASS_GETGOODLOG == assistantID then
        local msg = convertToLua(msg,PlatformMsg.CMD_GiftGoodLog)
        Event:dispatchEvent("platform","ASS_GETGOODLOG", {data = msg, code = handleID});
    end
end

function PlatformDeal:MDM_GP_USERINFO(msg)
    local assistantID = msg:getHead(3)
    local handleID = msg:getHead(4)
    if PlatformMsg.ASS_GP_USERINFO_GET == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_USERINFO)
        Event:dispatchEvent("platform","ASS_GP_USERINFO_GET", {data = msg, code = handleID});
        dispatchEvent("ASS_GP_USERINFO_GET",msg)
    elseif PlatformMsg.ASS_GP_USERINFO_ACCEPT == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_R_LogonResult)
        Event:dispatchEvent("platform","ASS_GP_USERINFO_ACCEPT", {data = msg, code = handleID});
        dispatchEvent("ASS_GP_USERINFO_ACCEPT", msg)
    elseif PlatformMsg.ASS_GP_SHARE_WX_REWARD == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_WX_SHARE_GET)
        onWxSharedCallback(msg);
    elseif PlatformMsg.ASS_GP_USERINFO_UPDATE_PWD == assistantID then
        dispatchEvent("updatePwd",handleID)
    elseif PlatformMsg.ASS_GP_USERINFO_NOTACCEPT == assistantID then
        dispatchEvent("ASS_GP_USERINFO_NOTACCEPT")
    end
end

function PlatformDeal:H_P_M_Message(msg)
    local msg = convertToLua(msg,PlatformMsg.MZTW_Mess_World_Horn_struct)
    luaDump(msg,"H_P_M_Message")
    Event:dispatchEvent("platform","ASS_GP_WorldMessage", {data = msg});
end

function PlatformDeal:H_P_M_Prop(msg)
    local assistantID = msg:getHead(3)
    local handleID = msg:getHead(4)
    if PlatformMsg.ASS_PROP_BIG_BOARDCASE_BUYANDUSE == assistantID then
        local msg = convertToLua(msg,PlatformMsg.UseBroadResult)
        luaDump(msg,"UseBroadResult")
        Event:dispatchEvent("platform","ASS_GP_Laba", {data = msg, code = handleID});
    end
end

function PlatformDeal:onFriendInformMessage(msg)

end

function PlatformDeal:reveiveGiftNotify(msg)

end

function PlatformDeal:onUserUploadMessage(msg)
    local assistantID = msg:getHead(3)
    local handleID = msg:getHead(4)
    if UserLogoMsg.ASS_ULS_UPLOADSUCCEED == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_USERINFO)

        -- Event:dispatchEvent("ASS_ULS_UPLOADSUCCEED", {data = msg, code = handleID});
    elseif UserLogoMsg.ASS_ULS_UPLOADFAILED == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_R_LogonResult)

        -- Event:dispatchEvent("ASS_ULS_UPLOADFAILED", {data = msg, code = handleID});
    elseif UserLogoMsg.ASS_ULS_LOGOINFORMATION == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_R_LogonResult)

        -- Event:dispatchEvent("ASS_ULS_LOGOINFORMATION", {data = msg, code = handleID});
    elseif UserLogoMsg.ASS_ULS_DOWN == assistantID then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_R_LogonResult)

        -- Event:dispatchEvent("ASS_ULS_DOWN", {data = msg, code = handleID});
        HeadManager:onDownloadFace(msg);
    end
end

--捕鱼比赛
function PlatformDeal:H_P_M_FishMatch(msg)
    local objectSize = msg:getHead(1)-20
    local mainID = msg:getHead(2)
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4);
    if PlatformMsg.ASS_GP_GET_FISH_MATCH_INFO == assistantID then      --1获取比赛列表
        local count = objectSize/getObjSize(PlatformMsg.MSG_GP_S_GET_FISH_MATCH_INFO)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_FISH_MATCH_INFO);
            table.insert(data, msg);
        end
        self:dispatchEvent(mainID,assistantID,{data=data});
    elseif PlatformMsg.ASS_GP_ENROLL_FISH_MATCH == assistantID then    --2报名比赛
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_ENROLL_FISH_MATCH);
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif PlatformMsg.ASS_GP_GET_USER_MATCH_INFO == assistantID then    --3获取用户比赛信息
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_USER_MATCH_INFO);
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif PlatformMsg.ASS_GP_GET_FISH_MATCH_RANK == assistantID then    --4获取比赛排名
        local count = objectSize/getObjSize(PlatformMsg.MSG_GP_S_GET_FISH_MATCH_RANK)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_FISH_MATCH_RANK);
            table.insert(data, msg);
        end
        self:dispatchEvent(mainID,assistantID,{data=data});
    elseif PlatformMsg.ASS_GP_GET_FISH_MATCH_REWARD == assistantID then    --5获取比赛奖励列表
        local count = objectSize/getObjSize(PlatformMsg.MSG_GP_S_GET_FISH_MATCH_REWARD)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_FISH_MATCH_REWARD);
            -- luaDump(msg,"获取比赛奖励列表")
            table.insert(data, msg);
        end
        self:dispatchEvent(mainID,assistantID,{data=data});
    end
end

function PlatformDeal:H_P_M_MZTW(msg)
    local assistantID = msg:getHead(3)

    if assistantID == PlatformMsg.ASS_ZTW_SCORE then
        local msg = convertToLua(msg,PlatformMsg.MZTW_Mess_UserInfo)
        dispatchEvent("ASS_ZTW_SCORE",msg)
    elseif assistantID == PlatformMsg.ASS_ZTW_DJ_ENDGAME then
        dispatchEvent("MZTW_Mess_UserInfo");
        MailInfo:sendMailListInfoRequest();
    end
end

function PlatformDeal:H_P_M_AGENCY(msg)
    local assistantID = msg:getHead(3)
    local mainID = msg:getHead(2)
    local handlecode = msg:getHead(4)
    local objectSize = msg:getHead(1)-20

    -- if assistantID == PlatformMsg.ASS_GP_GET_TOTAL then
    --     local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_TOTAL)
    --     self:dispatchEvent(mainID,assistantID,{data=msg})
    -- elseif assistantID == PlatformMsg.ASS_GP_GET_DETAIL then
    --     local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_DETAIL)
    --     self:dispatchEvent(mainID,assistantID,{data={msg,handlecode}})
    -- elseif assistantID == PlatformMsg.ASS_GP_GET_NEEDLEVEL then
    --     local count = objectSize/getObjSize(PlatformMsg.MSG_GET_NEED_LEVEL)
    --     local data = {}
    --     for i=1,count do
    --         local msg = convertToLua(msg,PlatformMsg.MSG_GET_NEED_LEVEL)
    --         if i ~= 1 then
    --             table.insert(data, msg)
    --         end
    --     end
    --     self:dispatchEvent(mainID,assistantID,{data=data})
    -- end
    self:dispatchEvent(mainID,assistantID,msg)
end

function PlatformDeal:H_P_M_Cash(msg)
    local assistantID = msg:getHead(3)
    local mainID = msg:getHead(2)
    local objectSize = msg:getHead(1)-20

     if assistantID == PlatformMsg.ASS_GP_UPDATE_ALIPAY then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_SETTLEMENT)
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif assistantID == PlatformMsg.ASS_GP_GET_CASH then
        local msg = convertToLua(msg,PlatformMsg.MSG_GP_SETTLEMENT)
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif assistantID == PlatformMsg.ASS_GP_GET_AGENTWECHAT then
        local count = objectSize/getObjSize(PlatformMsg.MSG_GP_S_GET_AGENTWECHAT)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,PlatformMsg.MSG_GP_S_GET_AGENTWECHAT);
            table.insert(data, msg);
        end
        self:dispatchEvent(mainID,assistantID,{data=data})
    elseif assistantID == PlatformMsg.ASS_GP_GET_CASH_LOG then
        self:dispatchEvent(mainID,assistantID,msg);
    elseif assistantID == PlatformMsg.ASS_GP_GET_CASH_ACQUIRE then
        self:dispatchEvent(mainID,assistantID,msg)
    end
end

function PlatformDeal:H_P_M_Web(msg)
    local assistantID = msg:getHead(3)
    local mainID = msg:getHead(2)
    local objectSize = msg:getHead(1)-20

    if assistantID == PlatformMsg.ASS_GP_WEB_ADD_SCORE then
        dispatchEvent("refreshScoreBank")
        local cf = {{"ret","INT"}}
        local data = convertToLua(msg, cf)
        dispatchEvent("webScore",data)
    elseif assistantID == PlatformMsg.ASS_GP_WEB_MAIL then
        MailInfo:sendMailListInfoRequest()
    elseif assistantID == PlatformMsg.ASS_GP_WEB_JIANYI then
        MailInfo:sendQuestionListRequest()
    elseif assistantID == PlatformMsg.ASS_GP_WEB_DUOBAO then
        SettlementInfo:sendConfigInfoRequest(serverConfig.total)
    elseif assistantID == PlatformMsg.ASS_GP_LOAD_SYSTEM_LIST then
        SettlementInfo:sendConfigInfoRequest(serverConfig.total)
    elseif assistantID == PlatformMsg.ASS_GP_FORCEUSER then
        dispatchEvent("forceUser")
    elseif assistantID == PlatformMsg.ASS_GP_REFRESHGAMELIST then
        local data = convertToLua(msg, PlatformMsg.MSG_GP_WEB_INFO)
        luaDump(data,"MSG_GP_WEB_INFO")
        dispatchEvent("refreshGameList",data.info)
    end
end

function PlatformDeal:H_P_M_Activity(msg)
    local mainID = msg:getHead(2)
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4)

    if PlatformMsg.ASS_GP_LUCKAWARD_OPEN == assistantID then
        local msg = convertToLua(msg,PlatformMsg.LuckAwardOpen);
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_LUCKAWARD_WHEEL == assistantID then
        local msg = convertToLua(msg,PlatformMsg.LuckAwardWheel);
        self:dispatchEvent(mainID,assistantID,{data={msg, handCode}});
    elseif PlatformMsg.ASS_GP_LUCKAWARD_RECORD == assistantID then
        local msg = convertToLua(msg,PlatformMsg.LuckRecordElem);
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif PlatformMsg.ASS_GP_LUCKAWARD_LUCKY == assistantID then
        local msg = convertToLua(msg,PlatformMsg.WheelInfo);
        self:dispatchEvent(mainID,assistantID,{data={msg, handCode}});
    elseif PlatformMsg.ASS_GP_LUCKAWARD_POINT == assistantID then
        local msg = convertToLua(msg,PlatformMsg.LuckAwardOpen);
        self:dispatchEvent(mainID,assistantID,{data=msg});
    else
        self:dispatchEvent(mainID,assistantID,msg);
    end
end

function PlatformDeal:dispatchEvent(mainID, subID, data)
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

function PlatformDeal:H_P_M_Vip(msg)
    local objectSize = msg:getHead(1)-20
    local mainID = msg:getHead(2)
    local assistantID = msg:getHead(3)
    local handCode = msg:getHead(4)

    -- addScrollMessage(assistantID)

    if VipMsg.ASS_GP_CREATE_GUILD_REQ == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_CREATE_GUILD_REQ);
        self:dispatchEvent(mainID,assistantID,{data=msg})
    elseif VipMsg.ASS_GP_GET_GUILD_LIST == assistantID then
        local count = objectSize/getObjSize(VipMsg.MSG_GP_S_GET_GUILD_LIST)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_LIST);
            table.insert(data, msg);
        end
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_LIST);
        self:dispatchEvent(mainID,assistantID,{data={data, handCode}});
    elseif VipMsg.ASS_GP_CREATE_GUILD == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_CREATE_GUILD);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}});
    elseif VipMsg.ASS_GP_APPLY_JOIN == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_APPLY_JOIN);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}}); 
    elseif VipMsg.ASS_GP_APPLY_JOIN_REQ == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_APPLY_JOIN_REQ);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}});  
    elseif VipMsg.ASS_GP_GET_GUILD_USER == assistantID then
        local count = objectSize/getObjSize(VipMsg.MSG_GP_S_GET_GUILD_USER)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
            table.insert(data, msg);
        end
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
        self:dispatchEvent(mainID,assistantID,{data={data,handCode}});  
    elseif VipMsg.ASS_GP_AGREE_JOIN == assistantID then
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_AGREE_JOIN);
        self:dispatchEvent(mainID,assistantID,{data={handCode}}); 
    elseif VipMsg.ASS_GP_REJECT_JOIN == assistantID then
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_REJECT_JOIN);
        self:dispatchEvent(mainID,assistantID,{data={handCode}});  
    elseif VipMsg.ASS_GP_CHANGE_USERNOTE == assistantID then
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
        self:dispatchEvent(mainID,assistantID,{data={handCode}});    
    elseif VipMsg.ASS_GP_QUIT_JOIN == assistantID then
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
        self:dispatchEvent(mainID,assistantID,{data={handCode}})
    elseif VipMsg.ASS_GP_DELETE_GUILD == assistantID then
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
        self:dispatchEvent(mainID,assistantID,{data={handCode}});
    elseif VipMsg.ASS_GP_KICK_GUILD_USER == assistantID then
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
        self:dispatchEvent(mainID,assistantID,{data={handCode}});
    elseif VipMsg.ASS_GP_CHANGE_RULE == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_CHANGE_RULE);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}}); 
    elseif VipMsg.ASS_GP_CREATE_REQ_MEMBER == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_CREATE_GUILD_REQ);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}}); 
    elseif VipMsg.ASS_GP_GUILD_SETTOP == assistantID then
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
        self:dispatchEvent(mainID,assistantID,{data={handCode}});
    elseif VipMsg.ASS_GP_GUILD_TAXDETAIL == assistantID then
        local count = objectSize/getObjSize(VipMsg.MSG_GP_S_TAXDETAIL)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,VipMsg.MSG_GP_S_TAXDETAIL);
            table.insert(data, msg);
        end
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_TAXDETAIL);
        self:dispatchEvent(mainID,assistantID,{data={data,handCode}}); 
    elseif VipMsg.ASS_GP_GUILD_MEMBERDETAIL == assistantID then
        local count = objectSize/getObjSize(VipMsg.MSG_GP_S_MEMBERDETAIL)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,VipMsg.MSG_GP_S_MEMBERDETAIL);
            table.insert(data, msg);
        end
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_MEMBERDETAIL);
        self:dispatchEvent(mainID,assistantID,{data={data,handCode}}); 
    elseif VipMsg.ASS_GP_GUILD_RECORD_REQ == assistantID then
        local count = objectSize/getObjSize(VipMsg.MSG_GP_S_GUILD_RECORDREQ)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_RECORDREQ);
            table.insert(data, msg);
        end
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_RECORDREQ);
        self:dispatchEvent(mainID,assistantID,{data={data,handCode}}); 
    elseif VipMsg.ASS_GP_MEMBER_USERLIST == assistantID then
        local count = objectSize/getObjSize(VipMsg.MSG_GP_S_GET_GUILD_USER)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
            table.insert(data, msg);
        end
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_GUILD_USER);
        self:dispatchEvent(mainID,assistantID,{data={data,handCode}}); 
    elseif VipMsg.ASS_GP_GET_CALLTIME == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GET_CALLTIME);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}});
    elseif VipMsg.ASS_GP_GUILD_ONEKEYCALL == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_ONEKEYCALL);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}}); 
    elseif VipMsg.ASS_GP_GUILD_CHANGERULE_REQ == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_CHANGE_RULE_REQ);
        self:dispatchEvent(mainID,assistantID,{data=msg}); 
    elseif VipMsg.ASS_GP_GUILD_DELETE_NOTIFY == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_DELETE_NOTIFY);
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif VipMsg.ASS_GP_GUILD_CHANGE_NOTIFY == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_CHANGE_NOTIFY);
        self:dispatchEvent(mainID,assistantID,{data=msg});
    elseif VipMsg.ASS_GP_GUILD_KICK_NOTIFY == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_CHANGE_NOTIFY);
        self:dispatchEvent(mainID,assistantID,{data=msg});         
    ----股东
    elseif VipMsg.ASS_GP_GUILD_HOLDER_REQ == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_HOLDER_REQ);
        self:dispatchEvent(mainID,assistantID,{data=msg});    
    elseif VipMsg.ASS_GP_GUILD_HOLDER_SET == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_HOLDER_SET);
        self:dispatchEvent(mainID,assistantID,{data = {msg,handCode}});    
    elseif VipMsg.ASS_GP_GUILD_COMMEND_TIME == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_COMMEND_TIME);
        self:dispatchEvent(mainID,assistantID,{data=msg});    
    elseif VipMsg.ASS_GP_GUILD_COMMEND_REQ == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_COMMEND_REQ);
        self:dispatchEvent(mainID,assistantID,{data= {msg,handCode}});    
    elseif VipMsg.ASS_GP_GUILD_COMMEND == assistantID then
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_CHANGE_NOTIFY);
        self:dispatchEvent(mainID,assistantID,{data=handCode});    
    elseif VipMsg.ASS_GP_GUILD_COMMEND_AGREE == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_COMMEND_AGREE);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}});    
    elseif VipMsg.ASS_GP_GUILD_COMMEND_DETAIL == assistantID or VipMsg.ASS_GP_GUILD_COMMEND_DETAIL_HOLDER == assistantID then
        local count = objectSize/getObjSize(VipMsg.MSG_GP_S_GUILD_COMMEND_DETAIL)
        local data = {};
        for i=1,count do
            local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_COMMEND_DETAIL);
            table.insert(data, msg);
        end
        -- local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_COMMEND_DETAIL);
        self:dispatchEvent(mainID,assistantID,{data={data,handCode}}); 
    elseif VipMsg.ASS_GP_GUILD_SENDMONEY_REQ == assistantID then
        local msg = convertToLua(msg,VipMsg.MSG_GP_S_GUILD_SENDMONEY_REQ);
        self:dispatchEvent(mainID,assistantID,{data={msg,handCode}});    
                 
    end

    luaPrint("H_P_M_Vip")
end

return PlatformDeal;
