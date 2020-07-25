local LoginLayer = class("LoginLayer", BaseWindow)
local PlatformLogin = require("logic.platformLogic.PlatformLogin");
local RegisterLayer = require("layer.popView.RegisterLayer")
local AccountLoginLayer = require("layer.popView.AccountLoginLayer")
local PlatformGameList = require("logic.platformLogic.PlatformGameList")

local Word_Loading      =       GBKToUtf8("正在登录...")
local Word_Register     =       GBKToUtf8("正在注册...")
local Word_Empty_Name   =       GBKToUtf8("账号不能为空!")
local Word_Empty_Pass   =       GBKToUtf8("密码不能为空!")
local Word_Wrong_Name   =       GBKToUtf8("登录名字错误!")
local Word_Wrong_Pass   =       GBKToUtf8("用户密码错误!")
local Word_Logined      =       GBKToUtf8("帐号已经登录!")

local _instance = nil;

function LoginLayer:getInstance()
    return _instance;
end

function LoginLayer:scene()
    if LoginLayer:getInstance() then
        -- return
        luaPrint("LoginLayer:getInstance()   异常")
    end

    local loginLayer = LoginLayer:create()

    local scene = display.newScene()
    scene:addChild(loginLayer)
    return scene
end

function LoginLayer:create()
    Event:clearEventListener()

    globalUnit.isFirstTimeInGame = true

    return LoginLayer.new()
end

function LoginLayer:ctor()
    self.super.ctor(self, false,false,nil,nil,false)

    self:initData()

    self:init()

    _instance = self
end

function LoginLayer:init()
    self:initUI();

    self:bindEvent();
end

function LoginLayer:initData()
    -- globalUnit.isStopService = nil

    self.platformLogin = PlatformLogin.new(self)
    self._gameListLogic = PlatformGameList.new(self);

    self.isSaveAccount = true;
end

function LoginLayer:bindEvent()
    self:unBindEvent()

    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_ROOM",function (event) self:searchRoomCallback(event) end)
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_DisConnect",function () self:I_P_M_DisConnect() end)

    self:pushGlobalEventInfo("onPlatformLoginCallback",handler(self, self.onReceivePlatformLoinCallback))
    self:pushGlobalEventInfo("onPlatformRegistCallback",handler(self, self.onReceivePlatformRegistCallback))
    -- self:pushGlobalEventInfo("checkFangShuaFailed",handler(self, self.checkFangShuaFailed))
    self:pushGlobalEventInfo("registerCallback",handler(self, self.registerEventCallback))
end

function LoginLayer:unBindEvent()
    if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return;
    end

    for _, bindid in pairs(self.bindIds) do
        Event:unRegisterListener(bindid)
    end

    self.bindIds = nil
end

function LoginLayer:onExit()
    self.super.onExit(self)
    self:unBindEvent()
    if self.platformLogin then
        self.platformLogin:stop()
        self.platformLogin = nil
    end

    PlatformRegister:getInstance():stop()
    _instance = nil
end

function LoginLayer:onEnterTransitionFinish()
    clearCache(nil,true,true)

    if isShowUpdate == true then
        self:addChild(require("layer.popView.UpdateLayer"):create(function() performWithDelay(self, function() self:autoLogin(); end, 0.1) end))
        isShowUpdate = nil
    else
        performWithDelay(self, function() self:autoLogin(); end, 0.05)
    end

    -- if runMode == "debug" then
    --     local func = function(sender)
    --         if sender.isClick == true then
    --             return
    --         end

    --         sender.isClick = true
    --         clearCacheResources()
    --         local layer = GamePromptLayer:create()
    --         layer:showPrompt("修复后请退出重登")
    --         layer.closeBtn:removeSelf()
    --         layer:setBtnClickCallBack(function() cc.Director:getInstance():endToLua() exitGame() end)
    --     end

    --     local btn = ccui.Button:create("gameUpdate/yijianxiufu.png","gameUpdate/yijianxiufu-on.png")
    --     btn:setPosition(winSize.width*0.85,winSize.height*0.85)
    --     self:addChild(btn)
    --     btn:onClick(func)
    -- end

    cc.UserDefault:getInstance():setBoolForKey("checkCount",true)

    isLoginLayer = true

    performWithDelay(self,function() self:loadSpine() end,0.1)

    iphoneXFit(self.Image_loginMask,4)

    self:setBtnListener()
end

function LoginLayer:initUI()
    playMusic("sound/audio-login.mp3",true)

    local uiTable = {
        Image_bg = "Image_bg",
        Button_guestLogin = "Button_guestLogin",
        Button_accountLogin = "Button_accountLogin",
        Button_register = "Button_register",
        Button_kefu = "Button_kefu",
        Node_effect = "Node_effect",
        Image_loginMask = "Image_loginMask"
    }
    loadNewCsb(self,"loginLayer",uiTable)
    self.Image_bg:loadTexture("login/bg.png")
    self.Image_loginMask:setCascadeOpacityEnabled(false)
    self.Image_loginMask:setOpacity(0)
    self.Image_loginMask:setPositionY(0)
    local image = ccui.ImageView:create("gameUpdate/info.png")
    image:setPosition(self.Image_bg:getContentSize().width/2,0)
    image:setAnchorPoint(0.5,0)
    self.Image_bg:addChild(image)

    self.Button_kefu:loadTextures("login/kefu.png","login/kefu-on.png");

    self:addEffect()

    self:appleViewOff()

    self:registerEvent()

    -- self:resetViewPos()
end

function LoginLayer:loadSpine()
    local name = {"buyuheji","bairenpinshi","kuaile30miao","longhudou","hongheidazhan","yaoyiyao","feiqinzoushou","dezhoupuke","sanzhangpai","21dian","10dianban","qiangzhuangpinshi","errenpinshi","benchibaoma","saoleihongbao","shuihuzhuan","chaojishuiguoji","sweetparty","lianhuanduobao"}
    local name1 = {
        {"xinshouyucun","fishing/createRoom/effect/xinshouyucun"},
        {"yongzhehaiwan","fishing/createRoom/effect/yongzhehaiwan"},
        {"shenhailieshou","fishing/createRoom/effect/shenhailieshou"},
        {"haiyangshenhua","fishing/createRoom/effect/haiyangshenhua"},
        {"tiyanchang","fishing/createRoom/effect/tiyanchang"},

        {"xinshouyucun","likuipiyu/createRoom/effect/xinshouyucun"},
        {"yongzhehaiwan","likuipiyu/createRoom/effect/yongzhehaiwan"},
        {"shenhailieshou","likuipiyu/createRoom/effect/shenhailieshou"},
        {"haiyangshenhua","likuipiyu/createRoom/effect/haiyangshenhua"},

        {"xinshouyucun","jinchanbuyu/createRoom/effect/xinshouyucun"},
        {"yongzhehaiwan","jinchanbuyu/createRoom/effect/yongzhehaiwan"},
        {"shenhailieshou","jinchanbuyu/createRoom/effect/shenhailieshou"},
        {"haiyangshenhua","jinchanbuyu/createRoom/effect/haiyangshenhua"},
    }

    for i=1,#name do
        local info = name[i]
        local path = "hall/effect/"..info
        addSkeletonAnimation(info,path..".json",path..".atlas")
    end

    for i=1,#name1 do
        local info = name1[i]
        local path = info[2]
        addSkeletonAnimation(info[1],path..".json",path..".atlas")
    end
end

function LoginLayer:playEffect()
    if self.isPlay == true then
        return
    end

    -- self:resetViewPos()
    -- self:playEnterEffect()
end

function LoginLayer:resetViewPos()
    if self.isSetPos == true then
        return
    end

    self.isSetPos = true
    self.Image_loginMask:setPositionY(self.Image_loginMask:getPositionY()-250)
end

function LoginLayer:playEnterEffect()
    if self.isPlay == true then
        return
    end

    self.isPlay = true
    local speed = 700
    local dis = 250
    local fu = 25
    local dt = (dis+fu)/speed

    local seq = cc.Sequence:create(cc.MoveBy:create(dt,cc.p(0,dis+fu)),cc.MoveBy:create(fu/speed,cc.p(0,-fu)),cc.CallFunc:create(function() self.isSetPos = false end))
    self.Image_loginMask:runAction(seq)
end

function LoginLayer:registerEvent()
    if isRegisterBackground == nil then
        isRegisterBackground = true
        local backgroundListener = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT", function() onEnterBackground() end)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(backgroundListener, 1)

        local foregroundListener = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT", function() onEnterForeground() end)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(foregroundListener, 1)
    end
end

function LoginLayer:appleViewOff()
    if device.platform == "ios" then
        if runMode == "release" and appleView == 1 then
        else
            requestNotice();--//加载公告信息
            -- onUnitedPlatformInitJiGuangSDK();
            -- onUnitedPlatformInitReyunSDK();
        end
    else
        requestNotice();--//加载公告信息
    end
end

function LoginLayer:setBtnListener()
    self.Button_register:hide()
    local btn = ccui.Button:create("login/weixindenglu.png","login/weixindenglu-on.png")
    btn:setPositionY(self.Button_guestLogin:getPositionY())
    self.Button_guestLogin:getParent():addChild(btn)
    local d = (winSize.width - btn:getContentSize().width * 4)/5
    local w = btn:getContentSize().width

    -- self.Button_guestLogin:setPositionX(winSize.width/2 - d/2 - w/2)
    -- self.Button_accountLogin:setPositionX(winSize.width/2 + d/2 + w/2)
    -- self.Button_register:setPositionX(self.Button_accountLogin:getPositionX() + d + w)
    -- btn:setPositionX(self.Button_guestLogin:getPositionX() - d - w)
    btn:setPositionX(self.Button_register:getPositionX())

    self.Button_guestLogin:onClick(function(sender) self:guestLoginEventCallback(sender) end)

    self.Button_accountLogin:onClick(function(sender) self:accountLoginEventCallback(sender) end)

    -- self.Button_register:onClick(function(sender) self:registerEventCallback(sender) end)

    self.Button_kefu:onClick(function(sender) self:onClickBtnKefu(sender) end)

    btn:onClick(function(sender) self:wxLoginEventCallback(sender) end)

    local cv = getAppConfig("BundleVersionDate")

    if isEmptyString(cv) then
        cv = "0"
    end

    local text = "Appv "..tostring(onUnitedPlatformGetVersion()).."    Resv "..tostring(GameConfig:getLuaVersion(gameName).."    Appcv "..tostring(cv))
    local winSize = cc.Director:getInstance():getWinSize()
    local tip = FontConfig.createWithSystemFont(text,18,FontConfig.colorWhite)
    tip:setAnchorPoint(0,0.5)
    tip:setPosition(cc.p(15,winSize.height-15))
    self:addChild(tip)

    -- self:createWebView()
end

function LoginLayer:addEffect()
    -- local skeleton_animation = createSkeletonAnimation("baoliqipai", "login/effect/baoliqipai.json", "login/effect/baoliqipai.atlas")
    -- if skeleton_animation then
    --     skeleton_animation:setAnimation(1,"baoliqipai", true)
    --     skeleton_animation:setPosition(self.Image_bg:getContentSize().width/2,self.Image_bg:getContentSize().height*0.5)    
    --     self.Node_effect:addChild(skeleton_animation)

    --     if checkIphoneX() then
    --         skeleton_animation:setPositionX(skeleton_animation:getPositionX()-fitX)
    --     end
    -- end
    local image = ccui.ImageView:create("hall/gameUpdate/logo.png");
    image:setPosition(self.Image_bg:getContentSize().width/2,self.Image_bg:getContentSize().height*0.5);
    self.Node_effect:addChild(image)

    if checkIphoneX() then
        image:setPositionX(image:getPositionX()-fitX)
    end
end

function LoginLayer:onClickBtnKefu(sender)
    openWeb(GameConfig:getServerUrl())
end

-- function LoginLayer:checkFangShuaFailed(data)
--     local data = data._usedata
--     if data == 1 then
--         self:createWebView()
--     else
--         if not self:getChildByName("RegisterLayer") then
--             self:createWebView()
--         end
--     end
-- end

function LoginLayer:createWebView()
    if device.platform ~= "windows" and isEmptyString(globalUnit.jsstring2) then
        local username = cc.UserDefault:getInstance():getStringForKey(USERNAME_TEXT, "")
        local password = cc.UserDefault:getInstance():getStringForKey(PASSWORD_TEXT, "")

        if username ~= "" and password ~= "" then
            self.Button_guestLogin:setTouchEnabled(true)
            return
        end

        local rd,code,pcode = createCheckCode(1356)

        local webView = ccexp.WebView:create()
        webView:setContentSize(cc.size(269, 100))
        webView:setScalesPageToFit(true)
        webView:setPosition(self.Button_guestLogin:getPositionX()-7,self.Button_guestLogin:getPositionY()+7)
        local url = GameConfig.AliyunUrl.."/fs/index2.html?AppKey="..pcode
        webView:loadURL(url,false)
        webView:setBackgroundTransparent()
        webView:setBounces(false)
        self.Button_guestLogin:getParent():addChild(webView)
        self._webView = webView
        webView:setOnShouldStartLoading(function(sender, url)
            luaPrint("onWebViewShouldStartLoading,url is ", url)
            return true
        end)

        webView:setOnDidFinishLoading(function(sender, url)
            luaPrint("onWebViewDidFinishLoading,url is ", url)
            if self:isVisible() then
                sender:show()
            end
        end)

        webView:setOnDidFailLoading(function(sender, url)
            luaPrint("onWebViewDidFailLoading,url is ", url)
            webView:reload()
        end)
        --设置Scheme 用于iOS复制微信号到剪贴板
        if webView.setOnJSCallback then
            local scheme = "weixincopy"
            webView:setJavascriptInterfaceScheme(scheme)
            webView:setOnJSCallback(function(sender,url)
                luaPrint("js callback =--==",url)
                local i,j = string.find(url,"://")
                if i and j then
                    local js = string.split(url,"_")
                    if #js > 2 then
                        if js[2] == "fangshua" then
                            if tonumber(js[3]) == 1 then
                                local endIndex = string.len(url)-string.len(js[#js])-1
                                local startIndex = string.len(js[1])+string.len(js[2])+string.len(js[3])+3+1
                                if endIndex < startIndex then
                                    endIndex = string.len(url)
                                end
                                local realStr = string.sub(url,startIndex,endIndex)

                                i,j = string.find(realStr,js[#js]) 
                                if i and j then
                                    realStr = string.gsub(realStr,js[#js],"_")
                                end
                                luaPrint(realStr)

                                globalUnit.jsstring2 = realStr

                                self:guestLoginEventCallback(self.Button_guestLogin)
                                self.Button_guestLogin:setTouchEnabled(true)
                                if self._webView then
                                    self._webView:setJavascriptInterfaceScheme("")
                                    self._webView:setOnJSCallback(function(sender,url) end)
                                    self._webView:removeSelf()
                                    self._webView = nil
                                end
                            else
                                addScrollMessage("请稍后重试")
                                self._webView:reload()
                            end
                        end
                    end
                end
            end)
        end
    end
end

--微信登录
function LoginLayer:wxLoginEventCallback(sender)
--     local username = cc.UserDefault:getInstance():getStringForKey(USERNAME_TEXT, "")
--     local password = cc.UserDefault:getInstance():getStringForKey(PASSWORD_TEXT, "")

--     if username ~= "" and password ~= "" and globalUnit:getLoginType() == wxLogin then
--         self:enterGame(userName, passWord)
--     else
        self:doSendSSO()
    -- end
end

function LoginLayer:guestLoginEventCallback(sender)
    if isStopService == true then
        GamePromptLayer:create():showPrompt("游戏正在维护,请维护完毕再进入")
        return
    end

    if globalUnit.checkIpIsCanLogin == false then
        GamePromptLayer:create():showPrompt("游戏已关闭，无法登陆")
        return
    end

    if self.isEmulator == true or luaCrash() then
        self.isEmulator = true
        GamePromptLayer:create():showPrompt("检测到非正常设备")
        return
    end

    uploadLog()
    luaPrint("guestLogin............... "..tostring(globalUnit.gameChannel))

    local func = function ()
        globalUnit.jsstring = globalUnit.jsstring2
        self.isSaveAccount = false;
        self:gameGuestRegister()
    end

    if device.platform == "windows" then
        func()
    else
        local username = cc.UserDefault:getInstance():getStringForKey(USERNAME_TEXT, "")
        local password = cc.UserDefault:getInstance():getStringForKey(PASSWORD_TEXT, "")

        if username ~= "" and password ~= "" then
            func()
        else
            if isEmptyString(globalUnit.jsstring2) and not isEmptyString(GameConfig.AliyunUrl) then
                local layer = require("layer.popView.AliyunLayer"):create(func)
                self:addChild(layer)
            else
                func()
            end
        end
    end
end

-- // 账号登陆回调
function LoginLayer:accountLoginEventCallback(sender)
    if isStopService == true then
        GamePromptLayer:create():showPrompt("游戏正在维护,请维护完毕再进入")
        return
    end

    if globalUnit.checkIpIsCanLogin == false then
        GamePromptLayer:create():showPrompt("游戏已关闭，无法登陆")
        return
    end

    if self.isEmulator == true or luaCrash() then
        self.isEmulator = true
        GamePromptLayer:create():showPrompt("检测到非正常设备")
        return
    end

    uploadLog()
    -- local userName = cc.UserDefault:getInstance():getStringForKey(USERNAME_TEXT, "")
    -- local savePassWord = cc.UserDefault:getInstance():getStringForKey(PASSWORD_TEXT,"")

    -- if savePassWord ~= "" then
    --     -- RoomLogic:close()
    --     -- PlatformLogic:close()
    --     self:enterGame(userName, savePassWord)
    --     LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("登录中,请稍后"), LOADING):removeTimer(10)
    -- else
        -- if self._webView then
        --     self._webView:removeSelf()
        --     self._webView = nil
        -- end

        local layer = AccountLoginLayer:create()
        layer:setLoginCallback(function(userName,passWord)
            passWord = MD5_CTX:MD5String(passWord)
            -- RoomLogic:close()
            -- PlatformLogic:close()
            cc.UserDefault:getInstance():setIntegerForKey("wxlogin", 0)
            self:enterGame(userName, passWord)
            -- LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("登录中,请稍后"), LOADING):removeTimer(10)
        end)
        self:addChild(layer)
    -- end
end

function LoginLayer:registerEventCallback(sender)
    if isStopService == true then
        GamePromptLayer:create():showPrompt("游戏正在维护,请维护完毕再进入")
        return
    end

    uploadLog()
    local func = function(msg)
        local onlyString = onUnitedPlatformGetSerialNumber()
        if onlyString ~= nil then
            cc.UserDefault:getInstance():setIntegerForKey("wxlogin", 0)
            luaPrint("onlyString   -------------------    "..onlyString)
            globalUnit.jsstring = globalUnit.jsstring1
            self.platformLogin:stop()
            PlatformRegister:getInstance():start()
            PlatformRegister:getInstance().type = 1
            PlatformRegister:getInstance():requestRegist(msg.name, MD5_CTX:MD5String(msg.pwd), onlyString, false)
            -- LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("注册中,请稍后"), LOADING):removeTimer(10)
        end
    end

    -- if self._webView then
    --     self._webView:removeSelf()
    --     self._webView = nil
    -- end

    local layer = RegisterLayer:create()
    layer:setRegisterCallback(func)
    self:addChild(layer)
end

function LoginLayer:gameGuestRegister()
    self.isResponseDisConnect = true
    SocialUtils._wx_nickname = ""
    local onlyString = onUnitedPlatformGetSerialNumber()
    local username = cc.UserDefault:getInstance():getStringForKey(USERNAME_TEXT, "")
    local password = cc.UserDefault:getInstance():getStringForKey(PASSWORD_TEXT, "")

    -- LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("登录中,请稍后"), LOADING):removeTimer(10);

    if username ~= "" and password ~= "" then
        self:enterGame(username, password)
    else
        cc.UserDefault:getInstance():setIntegerForKey("wxlogin", 0)
        globalUnit:setLoginType(guestLogin)
        luaPrint("onlyString   -------------------    "..onlyString)
        self.platformLogin:stop()
        PlatformRegister:getInstance():start()
        PlatformRegister:getInstance().type = 0
        PlatformRegister:getInstance():requestRegist("", "", onlyString, true)
    end
end

function LoginLayer:gameWXRegister(id, nickName)
    if self.isRefreshHead == true then
        return;
    end

    cc.UserDefault:getInstance():setIntegerForKey("wxlogin", 1)
    -- id = wxSearialNumber(id)
    globalUnit.registerInfo.wxID = id
    local onlyString = onUnitedPlatformGetSerialNumber()
    luaPrint("onlyString   -------------------    "..onlyString)

    -- //游客登陆
    self.tempId = id;
    self.tempNickName = nickName;
    self.isResponseDisConnect = true;

    self.platformLogin:stop()
    PlatformRegister:getInstance():start();
    PlatformRegister:getInstance().type = 0
    PlatformRegister:getInstance():requestRegist("", "", onlyString, true);
end

function LoginLayer:doSendSSO()
    if isStopService == true then
        GamePromptLayer:create():showPrompt("游戏正在维护,请维护完毕再进入")
        return
    end

    if globalUnit.checkIpIsCanLogin == false then
        GamePromptLayer:create():showPrompt("游戏已关闭，无法登陆")
        return
    end

    if self.isEmulator == true or luaCrash() then
        self.isEmulator = true
        GamePromptLayer:create():showPrompt("检测到非正常设备")
        return
    end

    if isCheckWx == nil then
        isCheckWx = true;
        if device.platform == "ios" then
            iswxInstall = onUnitedPlatformIsWXAppInstalled();
        elseif device.platform == "android" then
            iswxInstall = true;
        end
    end

    --请求微信登陆
    onUnitedPlatformLogin(1);
end

function LoginLayer:enterGame(userName, userPwd)
    self.isResponseDisConnect = true;
    self.tempName = userName;
    self.tempPwd = userPwd;
    luaPrint("进入游戏")
    PlatformRegister:getInstance():stop()
    self.platformLogin:start();
    self.platformLogin:requestLogin(userName, userPwd);
end

function LoginLayer:onReceivePlatformLoinCallback(data)
    local data = data._usedata

    if data then
        if data[1] then
            PlatformRegister:getInstance():stop();
            self:enterGame(data[3], data[4]);
            globalUnit.isRegisterEnterGame = true;
        else
            GamePromptLayer:create():showPrompt(data[2]);
        end
    end
end

function LoginLayer:onReceivePlatformRegistCallback(data)
    local data = data._usedata

    if PlatformRegister:getInstance().type ~= 5 then
        self:onPlatformRegistCallback(data[1],data[2],data[3],data[4],data[5],data[6])
    end
end

function LoginLayer:onPlatformRegistCallback(success, fastRegist, message, name, pwd, loginTimes)
    -- LoadingLayer:removeLoading();
    PlatformRegister:getInstance():stop();
    self:stopActionByTag(234)
    schedule(self,function() PlatformLogic:sendHeart() end,4):setTag(234)
    luaPrint("注册完毕，开始登陆")
    if success then
        openInstallReportRegister()
        self:enterGame(name, pwd);
        -- globalUnit.isRegisterEnterGame = true;
    else
        -- PlatformLogic:close()
        dispatchEvent("accountUpFailed")
        if message == "机器码获取错误" then
            local layer = GamePromptLayer:createWithParam({2,"hall/imeiTip.png"})
            layer:showPrompt()
            layer:setBtnClickCallBack(function() cc.Director:getInstance():endToLua() exitGame() end)
        else
            GamePromptLayer:create():showPrompt(message);
        end
    end
end

function LoginLayer:onPlatformLoginCallback(success, message, name, pwd)
    self:bindEvent();
    self.platformLogin:stop();
    -- LoadingLayer:removeLoading();
    local userDefault = cc.UserDefault:getInstance();

    if success then
        if globalUnit.isRegisterEnterGame ~= true then
            local msg = {}
            msg.AgentID = channelID
            PlatformLogic:send(PlatformMsg.MDM_GP_LIST, PlatformMsg.ASS_GP_LIST_KIND,msg,PlatformMsg.MSG_GP_SR_GetAgentGameList);
            SettlementInfo:sendConfigInfoRequest(serverConfig.total)
            PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_OPEN);
        end

        globalUnit.isRegisterEnterGame = true;
        createQrImage()
        self:saveUserInfo(name, pwd);

        globalUnit.m_userID = PlatformLogic.loginResult.dwUserID;
        globalUnit.m_account = name;
        globalUnit.m_password = pwd;

        if HallLayer and HallLayer:getInstance() then
            HallLayer:getInstance():delayCloseLayer()
        end
        -- Hall.enterPlatform();
        -- //查询本人的房间是否存在,若在房间中，则直接进入房间
        local msg = {};
        msg.iUserID = PlatformLogic.loginResult.dwUserID;
        PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GP_GET_ROOM, msg, PlatformMsg.MSG_GP_C_USE_ROOM_KEYINFO);
    else
        local userDefault = cc.UserDefault:getInstance();
        -- userDefault:setStringForKey(USERNAME_TEXT, "");
        userDefault:setStringForKey(PASSWORD_TEXT, "");
        if message == PlatformMsg.ERR_GP_VER_ERROR then
            LoadingLayer:removeLoading();
            self:addChild(require("layer.popView.UpdateLayer"):create(function() performWithDelay(self, function() self:autoLogin(); end, 0.1) end))
        else
            local func = function()
                if message == "由于您连续输入密码错误，账号被暂时锁定，请稍后再做尝试。" then
                    globalUnit.jsstring1 = ""
                    dispatchEvent("checkFangShuaFailed")
                end
            end
            local layer = GamePromptLayer:create()
            layer:showPrompt(message)
            layer:setBtnClickCallBack(func)
            self:playEffect()
        end
    end
end

function LoginLayer:saveUserInfo(name, pwd)
    if device.platform == "windows" then--木蚂蚁
        return;
    end

    -- if globalUnit:getLoginType() ~= accountLogin then
        -- return
    -- end

    -- if not checkPhoneNum(name) then
    --     return
    -- end

    -- if not self.isSaveAccount then
    --     return
    -- end

    local userDefault = cc.UserDefault:getInstance();

    if not isEmptyString(name) then
        userDefault:setStringForKey(USERNAME_TEXT, name);
    end

    if not isEmptyString(pwd) then
        userDefault:setStringForKey(PASSWORD_TEXT, pwd);
    end

    userDefault:flush();
end

--查询是否在房间
function LoginLayer:searchRoomCallback(event)
    local data = event.data;
    local handCode = event.code;
    luaDump(event,"查询是否在房间")
    
    -- self:initDataBase();

    if HallLayer and HallLayer:getInstance() then
        HallLayer:getInstance():delayCloseLayer()
    end

    if handCode == 0 then
        -- local roomid = {};

        -- table.insert(roomid, math.floor(data.iRoomID / 10));
        -- table.insert(roomid, data.iRoomID % 10);
        -- table.insert(roomid, math.floor(data.iDeskID / 100));
        -- table.insert(roomid, math.floor((data.iDeskID % 100) / 10));
        -- table.insert(roomid, data.iDeskID % 10);
        -- table.insert(roomid, tonumber(data.szLockPass));
        -- 如果是换服登录，直接返回
        local userDefault = cc.UserDefault:getInstance()
        local key = userDefault:getStringForKey("sdkkey", sdkKey)

        luaPrint("sdkKey ",sdkKey," ,key ",key)
        self:stopActionByTag(234)
        schedule(self,function() PlatformLogic:sendHeart() end,4):setTag(234)

        if (not isEmptyString(key) and sdkKey ~= key and globalUnit.isCheckSDK ~= true) or not GamesInfoModule:findGameName(data.iNameID) then
            addScrollMessage("请等待上局游戏结束")
            LoadingLayer:removeLoading()
            return
        end

        Hall:restartDownload()

        if data.iRoomID ~= -1 then
            self:unBindEvent()
            if self.platformLogin then
                self.platformLogin:stop()
                -- self.platformLogin = nil
            end

            isOnlineRemind = true
            PlatformRegister:getInstance():stop()
            local layer = HallLayer:create(1,data);
            layer:setName("hallLayer")
            layer:setVisible(false);
            -- layer:enterGameRoomByPwd(roomid);
            self:addChild(layer);
            globalUnit.isFirstTimeInGame = false;
        end
    else--不在房间
        cc.UserDefault:getInstance():setStringForKey("sdkkey", sdkKey)
        globalUnit.isCheckSDK = true
        -- self:requestGameRoomTimerCallBack()
        globalUnit.isRestartDown = true
        isOnlineRemind = true
        Hall.enterPlatform();
    end
end

function LoginLayer:requestGameRoomTimerCallBack()
    local ret = self._gameListLogic:requestGameList()
    if ret == false then
    elseif ret == 1 then
        globalUnit.isRestartDown = true
        Hall.enterPlatform();
    elseif ret == true then
        self._gameListLogic:start()
    end
end

function LoginLayer:onPlatformGameListCallback(success, message)
    self._gameListLogic:stop()
    globalUnit.isRestartDown = true
    Hall.enterPlatform();
end

function LoginLayer:initDataBase()
    local fullDBPath = cc.FileUtils:getInstance():getWritablePath()..dbSourceName..PlatformLogic.loginResult.dwUserID..".db";

    luaPrint("fullDBPath -------------- "..fullDBPath);
    local db = DBUtil:create();
    local ret = db:InitDB(fullDBPath);

    if ret then
        -- //创建表T_GameInfo
        local createTableSql = "create table T_GameInfo (id integer primary key autoincrement,userid integer,game_id integer,innings integer,room_id text,players integer,end_time text,name1 text,name2 text,name3 text,name4 text,name5 text,name6 text,userid1 integer,userid2 integer,userid3 integer,userid4 integer,userid5 integer,userid6 integer)";
        db:CreateTable(createTableSql, "T_GameInfo");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN MaxRound integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN GameRule integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN ip1 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN ip2 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN ip3 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN ip4 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN ip5 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN ip6 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN sex1 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN sex2 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN sex3 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN sex4 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN sex5 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN sex6 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN total1 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN total2 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN total3 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN total4 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN total5 integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameInfo ADD COLUMN total6 integer DEFAULT(0)");
        -- //////////////////////////////////////////////////////////////////////////
        -- //创建表T_GameSource
        local createTableSql1 = "create table T_GameSource (id integer primary key autoincrement,userid integer, room_id text,innings integer,source1 integer,source2 integer,source3 integer,source4 integer,source5 integer,source6 integer,win integer,total1 integer,total2 integer,total3 integer,total4 integer,total5 integer,total6 integer)";
        db:CreateTable(createTableSql1, "T_GameSource");
        db:ExecSql("ALTER TABLE T_GameSource ADD COLUMN time text DEFAULT('')");
        db:ExecSql("ALTER TABLE T_GameSource ADD COLUMN bindid integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameSource ADD COLUMN masterID integer DEFAULT(0)");
        -- //////////////////////////////////////////////////////////////////////////
        -- //创建表T_GameData
        local createTableSql2 = "create table T_GameData (id integer primary key autoincrement,userid integer,innings integer,data1 blob,data2 blob)";
        db:CreateTable(createTableSql2, "T_GameData");
        db:ExecSql("ALTER TABLE T_GameData ADD COLUMN nameid integer DEFAULT(0)");
        db:ExecSql("ALTER TABLE T_GameData ADD COLUMN bindid integer DEFAULT(0)");
        -- //关闭db
        db:CloseDB();
    end
end

isGetKeFuUrl = true

function requestNotice()
    -- if isEmptyString(globalUnit.m_sNotieceMsg) then
    --     local url = GameConfig:getNoticeUrl().."Type=GetSystemMsg".."&pageSize=1".."&pageindex=1";
    --     HttpUtils:requestHttp(url,function(result, response) onHttpRequestNotice(result, response); end)
    -- end
    -- if isEmptyString(GameConfig.serverUrl) then
    if isGetKeFuUrl then
        -- local url = GameConfig:getWebKefu()
        -- HttpUtils:requestHttp(url,function(result, response) onHttpRequestKefu(result, response) end)
    end
end

function onHttpRequestKefu(result, response)
    if result == false then
        -- GameConfig:getSwitchWebUrl()
    else
        local tb = json.decode(response)
        if tb and tb.State == 1 then
            GameConfig.serverUrl = tb.Value
            isGetKeFuUrl = false
        end
    end
end

function LoginLayer:I_P_M_DisConnect()
    -- self:playEnterEffect()
    -- if self.isResponseDisConnect == true then
    --     if self.netCount == nil then
    --         self.netCount = 0;
    --     end

    --     if self.netCount > 5 then
    --         self.isResponseDisConnect = nil;
    --         self.netCount = 0;

    if not globalUnit.isSDKInit and not PlatformLogic.cServer then
        LoadingLayer:removeLoading()
        globalUnit.isSDKInit = true
    end
            
    --     end

    --     self.netCount = self.netCount + 1;

    --     if HallLayer and HallLayer:getInstance() then
    --         HallLayer:getInstance():delayCloseLayer()
    --     end

    --     -- luaPrint("断线 ，主动重新登陆")
    --     if self.tempName ~= nil and self.tempPwd ~= nil then
    --         self:enterGame(self.tempName, self.tempPwd);--账号登陆
    --     elseif self.tempId ~= nil and self.tempNickName ~= nil then
    --         self:gameWXRegister(self.tempId, self.tempNickName);--微信登陆
    --     else
    --         self:gameGuestRegister();--游客登陆
    --     end
    -- else
    --     -- luaPrint("断线 无登陆");
    -- end
end

function LoginLayer:autoLogin()
    local username = cc.UserDefault:getInstance():getStringForKey(USERNAME_TEXT, "")
    local password = cc.UserDefault:getInstance():getStringForKey(PASSWORD_TEXT, "")

    if isStopService then
        return
    end

    initNet()

    if self.isEmulator == true or luaCrash() then
        self.isEmulator = true
        GamePromptLayer:create():showPrompt("检测到非正常设备")
        return
    end

    if username == "" or password == "" or (globalUnit:getLoginType() ~= accountLogin and device.platform ~= "windows") then
        self:playEffect()
        if not globalUnit.isSDKInit and not PlatformLogic.cServer then
            LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求配置中,请稍后"), LOADING):removeTimer(10,function() addScrollMessage("请求配置超时") globalUnit.isSDKInit = true end)
            PlatformLogic:connect()
        end
    else
        -- readPackageType();
        if isRunAutoLogin == nil then
            isRunAutoLogin = true
            local func = function ()
                addScrollMessage("请求配置超时")
                if PlatformLogic.isLogined ~= true and LoginLayer:getInstance() then
                    LoginLayer:getInstance():playEffect()
                end
            end
            LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求配置中,请稍后"), LOADING):removeTimer(10,func)
            self:enterGame(username, password)
        end
    end
end

return LoginLayer
