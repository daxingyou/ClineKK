--Android iOS 交互函数

local headimgurl ="";
local REFRESH_TOKEN = "refresh_token";
local splits = "_";

function initQsuSDK(str)
    if isCloseQSu == true then
        return
    end

    if schedulerSDK and not tolua.isnull(schedulerSDK) then
        display.getRunningScene():stopAction(schedulerSDK)
        schedulerSDK = nil
    end

    luaPrint("su sdk ",str)

    if initSDKRet ~= 0 then
        initSDKRet = 0
        isSDKSuccess = 0

        if isGetHotUpdate == true then
            isGetHotUpdate = nil

            performWithDelay(display.getRunningScene(),function()
                if isSetTuiguangUrl == nil then
                    local str = getWebBestIP("kktuiguang")
                    local result = string.split(str,":")
                    luaPrint("SettlementInfo 4 sdk result ====",str)
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
                dispatchEvent("reqestHotUpdate") end,0.3)
            return
        end

        luaPrint("su sdk ",str,PlatformLogic.isToConnect,RoomLogic.isToConnect)

        if PlatformLogic.sdkSuccect then
            if PlatformLogic.isToConnect then
                performWithDelay(display.getRunningScene(),function() getBestIP(PlatformLogic.port) end,0.3)
            end

            if RoomLogic.isToConnect then
                performWithDelay(display.getRunningScene(),function() getBestIP(RoomLogic.port) end,0.3)
            end
        else
            if not globalUnit.isSDKInit and not PlatformLogic.cServer then
                performWithDelay(display.getRunningScene(),function() 
                    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求配置中,请稍后"), LOADING):removeTimer(10,function() addScrollMessage("请求配置超时") globalUnit.isSDKInit = true end)
                    PlatformLogic:connect()
                end,0.3)
            end
        end
    end
end

function uploadEmulatorInfo(info)
    luaPrint("设备信息 ",info)
    uploadInfo("设备信息",info)
end

function uploadHardwareInfo(info)
    luaPrint("硬件信息 ",info)
    uploadInfo("硬件信息",info)
    local deviceInfo = string.split(info,"\r\n")
    for k,v in pairs(deviceInfo) do
        if string.find(v,"model") then
            local model = string.split(v," = ")[2]
            globalUnit.deviceMode = model
            break
        end
    end
end

function printSDKLog(log)
    gLog = gLog..log.."\n"
end

function connectToServer(str)
    luaPrint("sdk result ====",str)
    local result = string.split(str,":")
    if #result > 1 then
        luaPrint("获取sdk最优ip去连接服务器")
        if PlatformLogic.isToConnect then
            PlatformLogic.sdkSuccect = true
            if not HallLayer:getInstance() then
                if not PlatformLogic.cServer then
                    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录A服中,请稍后"), LOADING):removeTimer(10,function() globalUnit.isSDKInit = true addScrollMessage("请切换网络试下") end)
                else
                    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在连接登录服中,请稍后"), LOADING):removeTimer(10)
                end
            end

            local ip = result[1]
            local port = tonumber(result[2])
            if port then
                PlatformLogic.socketLogic:openWithIp(ip,port)
            end
        end

        PlatformLogic.isToConnect = nil

        if RoomLogic.isToConnect then
            local ip = result[1]
            local port = tonumber(result[2])
            if port then
                RoomLogic.socketLogic:openWithIp(ip,port)
            end
        end

        RoomLogic.isToConnect = nil
    else
        if RoomLogic.isToConnect then
            local a,b = Hall:getGameName(Hall:getGameNameByNameID(GameCreator:getCurrentGameNameID()))

            if a ~= nil and globalUnit.gameName ~= nil then
                RoomLogic:close()
                dispatchEvent("loginRoom")
                Hall:exitGame()
                dispatchEvent("onRoomLoginError",1);--通知VIP界面
            end
        end

        PlatformLogic.isToConnect = nil
        RoomLogic.isToConnect = nil

        if not PlatformLogic.cServer then
            if not HallLayer:getInstance() then
                globalUnit.isSDKInit = true
            end
        end

        luaPrint("获取sdk最优ip失败不去连接服务器 ：",str)
        LoadingLayer:removeLoading()
        addScrollMessage("连接服务器失败"..tostring(str))
    end
end

function AutoLoginFormWeb(arg)
    if arg == nil then
        return;
    end
    
    local ret = string.split(arg, ',');

    local shardType = ret[1];
    local roomid = tonumber(ret[2]);

    if type(roomid) == "number" and roomid > 0 then
        globalUnit.webRoomid = ret[2];
        globalUnit.isCheckWebLogin = false;
    end
end

--微信登陆或分享回调
function onWXResp(arg)
    local ret = string.split(arg, ',');

    local code = ret[1];
    local wxType = tonumber(ret[2]);
    if wxType == 0 then
        luaPrint("wxapi  wxapi  wxapi  wxapi wxapi !!!!!!!!!!!!!!!!!!!!!!");
        local url = WX_ACCESS_TOKEN_URL..GameConfig.WX_APP_ID.."&secret="..GameConfig.WX_SECRET.."&code="..code.."&grant_type=authorization_code";
        luaPrint("wx url ------ "..url);
        HttpUtils:requestHttpCmd(CMD_ACCESS_TOKEN, url, function(cmd, result, response) onWxRequestCallback(cmd, result, response); end);
    elseif wxType == 1 then
        luaPrint("分享完成");
        
        if globalUnit:getIsShareAward() == true then
            if device.platform ~= "android" then
                display.getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()  Hall.showToast("分享成功"); end)))
            end

            local msg = {};
            msg.dwUserID = PlatformLogic.loginResult.dwUserID;
            PlatformLogic:send(PlatformMsg.MDM_GP_USERINFO, PlatformMsg.ASS_GP_SHARE_WX_REWARD, msg, PlatformMsg.MSG_GP_C_GET_USERINFO);
        else            
            if device.platform ~= "android" then
                display.getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()  Hall.showToast("分享成功"); end)))
            end
        end

        -- globalUnit:setIsShareAward(true);
    end
end

function onWxSharedCallback(msg)
    if msg.iUserRoomKey > 0 then
        -- PlatformLogic.loginResult.iRoomKey = msg.iUserRoomKey;
        local money = PlatformLogic.loginResult.i64Money;
        -- if PlatformLayer:getInstance() then
            -- PlatformLayer:getInstance():setNumFK(money+msg.iUserRoomKey);
        -- end
        -- GamePromptLayer:create():showPrompt(GBKToUtf8("恭喜获得"..msg.iUserRoomKey.."金币,每日1次，剩余"..msg.leftShare.."次,奖励已发放！"));
        GamePromptLayer:create():showPrompt(GBKToUtf8("恭喜获得捕鱼礼包,每日1次，剩余"..msg.leftShare.."次,奖励已发放！"));
    end
end

--微信授权回调
function onWxRequestCallback(cmd, result, response)
    if result == false then
        luaPrint("http request cmd =  "..cmd.." error");
        return;
    end

    if cmd == CMD_ACCESS_TOKEN then  --//获取到access_token
        if LoginLayer:getInstance() then
            -- LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("微信登陆中,请稍后"), LOADING):removeTimer(10);
        end
       
        local access_token = 0;
        local openid = 0;
        local refresh_token = 0;

        access_token =  getValueFromJson(response, "access_token");
        openid = getValueFromJson(response, "openid");
        refresh_token = getValueFromJson(response, "refresh_token");

        cc.UserDefault:getInstance():setStringForKey(REFRESH_TOKEN,tostring(refresh_token));

        --luaPrint("2222222222222222222222222222refresh_token",refresh_token)
        local url = "https://api.weixin.qq.com/sns/userinfo?access_token="..access_token.."&openid="..openid.."&lang=zh_CN";
        luaPrint("hwt c--------------url : "..url);
         --            //继续请求用户信息
        HttpUtils:requestHttpCmd(CMD_USER_INFO, url, function(cmd, result, response) onWxRequestCallback(cmd, result, response); end);
    elseif cmd == CMD_USER_INFO or cmd == CMD_USER_INFO_REFRESH then
        if cmd == CMD_USER_INFO then
            if LoginLayer:getInstance() then
                -- LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("微信登陆中,请稍后"), LOADING):removeTimer(10);
            end            
        end
        luaPrint("wx response -- "..response)

        local headimgurl = "";

        SocialUtils._wx_unionid = getValueFromJson(response, "unionid");
        SocialUtils._wx_nickname = getValueFromJson(response, "nickname");
        SocialUtils._wx_sex = tonumber(getValueFromJson(response, "sex"));
        headimgurl = getValueFromJson(response, "headimgurl")
        headimgurl = string.gsub(headimgurl,"\\","");

        local errcode = getValueFromJson(response,"errcode")

        if  tonumber(errcode) then
            addScrollMessage("微信授权失败 "..tostring(errcode))
            return
        end

        luaPrint("_wx_nickname ------------ "..SocialUtils._wx_nickname);
        luaPrint("headimgurl  "..headimgurl)
        luaPrint("headimgurl len  "..string.len(headimgurl))

        -- if string.len(headimgurl) < 8 then
            if LoginLayer:getInstance() then
                LoginLayer:getInstance():gameWXRegister(SocialUtils._wx_unionid,SocialUtils._wx_nickname);
            end
        -- else
        --     local s = headimgurl;
        --     luaPrint("s -----  "..s);
        --     local i = string.find(s,"/",string.len(s)-10);
        --     -- s = string.sub(s, 1, string.len(s)-1);
        --     if i == nil then
        --         i = string.len(s)-1;
        --     end
        --     s = string.sub(s, 1, i);
        --     s = s.."96";
        --     luaPrint("微信头像 url "..s);
        --     doHttpRequest(s);
        -- end
    elseif cmd == CMD_REFRESH_TOKEN then
        luaPrint("CMD_REFRESH_TOKEN")
        local access_token = 0;
        local openid = 0;
        local refresh_token = 0;

        access_token = getValueFromJson(response, "access_token");
        openid = getValueFromJson(response, "openid");
        refresh_token = getValueFromJson(response, "refresh_token");

        cc.UserDefault:getInstance():setStringForKey(REFRESH_TOKEN,tostring(refresh_token));

        --luaPrint("2222222222222222222222222222refresh_token",refresh_token)
        local url = "https://api.weixin.qq.com/sns/userinfo?access_token="..access_token.."&openid="..openid.."&lang=zh_CN";
        HttpUtils:requestHttpCmd(CMD_USER_INFO_REFRESH, url, function(cmd, result, response) onWxRequestCallback(cmd, result, response); end);
    end
end

function getValueFromJson(response, key)
    luaPrint("key -----------  "..key);
    local sp, ep = string.find(response, key);
    if sp ~= nil and ep ~= nil then
        local es1, es2 = "\":", "\":\"";
        luaPrint("sp ------ "..sp.."  ep ======== "..ep)
        local s = string.sub(response, ep+1, ep+3);

        local s1 = ep+2;--整数
        local c = ",\"";
        luaPrint("s ============  "..s);
        if s == es2 then
            s1 = ep+3;
            c = "\",\"";
        end

        luaPrint("s1 ========== "..s1);

        luaPrint("c =========  "..c)

        s1 = s1 + 1;

        sp, ep = string.find(response,c, s1);

        luaPrint("sp====== ",sp,"ep ------------ ",ep)

        if sp == nil and ep == nil then
            sp = -2;
        end

        luaPrint("string.sub(response, sp, ep); = "..string.sub(response, s1, sp-1))
        return string.sub(response, s1, sp-1);
    end

    return "";
end

-- "headimgurl":"http:\/\/wx.qlogo.cn\/mmopen\/1xGS0thAUMxz7w9ibJBk2UlOxjTtMJGnxqBUicpTAxcE9rreicIib8txub41KDvjmuVe4IaotKIwb9uaGGvFkPib708j7dLU55ty3\/0"
function getValueFromResponse(response, byKey)
    local temp = string.sub(response,3,-2);
    temp = string.gsub(temp,"\\","");
    temp = string.split(temp,",\"");

    for k,v in pairs(temp) do
        if string.sub(v,-1,-1) == "\"" then
            v = string.sub(v,1,-2);
        end

        local str = string.split(v,"\":");

        for i=1,#str do
            if string.sub(str[i],1,1) == "\"" then
                str[i] = string.sub(str[i],2,-1);
            end
        end

        if str[1] == byKey then
            return str[2];
        end
    end

    return "";
end

function getJsonFilter(str)
    local a = "/"
    local b = string.gsub(str,a,"");
    luaPrint("b = "..b)
    local start,endd = string.find(b, splits);
    
    local i = 0;

    while true do
        if start ~= nil and endd ~= nil then
            splits = splits..i.."_";
        else
            break;
        end
        
        start,endd = string.find(b, splits);

        i = i + 1;
    end

    return string.gsub(b,"\\",splits);
end

function onStartOpenUrl(url)
    luaPrint("onStartOpenUrl  -----")
    if device.platform == "ios" then
        -- local args = {serverID="3"}
        -- local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlatformSwtichServer",args)
        -- if ok == false then
        --     luaPrint("luaoc调用出错:PlatformSwtichServer")
        -- end
        
    elseif device.platform == "android" then
        luaPrint("start lua to java");
        local javaMethodName = "openUrl"
        local javaParams = {url}
        local javaMethodSig = "(Ljava/lang/String;)V"

        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName,javaParams,javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 PlatformSwtichServer")
        end
    else
        luaPrint("onUnitedPlatformLogin!")
    end
end

isInitBaiDu = false;
function onUnitedPlatformInitBaiDuSDK()
    if device.platform == "ios" and isInitBaiDu ~= true then
        local ok,ret;
            local args = {key=BAIDU_KEY};
            ok,ret = luaCallFun.callStaticMethod("MethodForLua","initBaiDuSDK",args);
        
        if ok == false then
            luaPrint("luaoc调用出错:initBaiDuSDK")
        else
            if ret == 1 then
                isInitBaiDu = true;
                --开启百度定位
                onStartBaiDuLocation();
            end
        end
    else
        onStartBaiDuLocation();
    end
end

--开启百度定位
function onStartBaiDuLocation()
    luaPrint("onStartBaiDuLocation  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("AppController","StartBaiDuLocation")
        if ok == false then
            luaPrint("luaoc调用出错:StartBaiDuLocation")
        end        
    elseif device.platform == "android" then
        luaPrint("start lua to java");
        local javaMethodName = "StartBaiDuLocation"
        local javaParams = {}        
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams)
        if ok == false then
            luaPrint("luaoc调用出错 onStartBaiDuLocation")
        end
    else
        luaPrint("onStartBaiDuLocation!")
    end
end

--百度定位返回结果
function onBaiDuResp(code)
    luaPrint("onBaiDuResp = "..code);
    -- TableLayer:getInstance():onGameBaiDuLocation(code);
end

--百度定位停止
function onStopBaiDuLocation()
    
end

--微信登陆
function onUnitedPlatformLogin(itype)
    luaPrint("onUnitedPlatformLogin  -----")
    if globalUnit:getLoginType() == wxLogin or itype == 1 then
        if device.platform == "ios" then
            if iswxInstall ~= true then
                GamePromptLayer:create():showPrompt("未安装微信!");
                LoadingLayer:removeLoading();
                return;
            end
            
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","sendAuthRequest")
            if ok == false then
                luaPrint("luaoc调用出错:sendAuthRequest")
            end
        elseif device.platform == "android" then
            -- luaPrint("start lua to java");
            local javaMethodName = "sendMsgtoWX"
            local javaParams = {}
            local javaMethodSig = "()V"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 onUnitedPlatformLogin")
            end
        else
            luaPrint("onUnitedPlatformLogin!")
        end
    end    
end

function onUnitedPlatformIsWXAppInstalled()
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","iswxInstall")
        if ok == false then
            luaPrint("luaoc调用出错:iswxInstall")
        else
            luaPrint("iswxInstall  ret ---- "..tostring(ret))
            if ret == 1 then
                return true;
            end
        end
    end

    return false;
end

function onUnitedPlatformIsAYAppInstalled()
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","GetInstallAY")
        if ok == false then
            luaPrint("luaoc调用出错:GetInstallAY")
        else
            if ret == 1 then
                return true;
            end
        end
    elseif device.platform == "android" then
        local javaClassName = "org.cocos2dx.lua.AYTools"
        local javaMethodName = "GetAYAppInstalled"
        local javaParams = {}
        local javaMethodSig = "()I"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 GetAYAppInstalled")
        else
            if ret == 1 then
                return true;
            end
        end
    end

    return false;
end

--微信分享 start ----------
function onUnitedPlatformShare(info,itype)--朋友
    luaPrint("onUnitedPlatformShare  -----")
    if itype == wxLogin then
        if device.platform == "ios" then
            local temp = string.split(info,"|");
            local sharedType = temp[#temp-1];
            local roomid = temp[#temp];
            local args = {msg=info,type=1,url=GameConfig.app_url};
            
            if #temp <= 2 then
                sharedType = nil;
                roomid = nil;
            end

            if sharedType ~= nil and roomid ~= nil then
                args = {msg=info,type=1,url=GameConfig.app_url,sharedType=sharedType,roomid=roomid};
            end
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","shareToWeixin",args)
            if ok == false then
                luaPrint("luaoc调用出错:shareToWeixin")
            end
        elseif device.platform == "android" then
            -- luaPrint("start lua to java");
            local javaMethodName = "sendMsgToFriend"
            local javaParams = {info,GameConfig.app_url}
            local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 onUnitedPlatformShare")
            end
        else
            luaPrint("onUnitedPlatformShare!")
        end
    end
end

function onUnitedPlatformShareFriendWorld(info,itype)--朋友圈
    luaPrint("onUnitedPlatformShareFriendWorld  -----")
    if itype == wxLogin then
        if device.platform == "ios" then
            local args = {msg=info,type=2,url=GameConfig.app_url};
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","shareToWeixin",args)
            if ok == false then
                luaPrint("luaoc调用出错:shareToWeixin")
            end
        elseif device.platform == "android" then
            -- luaPrint("start lua to java");
            local javaMethodName = "sendMsgToFriendWorld"
            local javaParams = {info,GameConfig.app_url}
            local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
            if ok == false then
                luaPrint("luaoc调用出错 sendMsgToFriendWorld")
            end
        else
            luaPrint("onUnitedPlatformShareFriendWorld!")
        end
    end
end

--分享截图
function onUnitedPlatformShareTimeLine(shareType, path)--朋友圈
    luaPrint("onUnitedPlatformShareTimeLine  -----")
    if globalUnit:getLoginType() == wxLogin then
        if device.platform == "ios" then
             local args = {path=path,type=shareType};
            local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","shareToWeixinForIOS",args)
            if ok == false then
                luaPrint("luaoc调用出错:shareToWeixinForIOS")
            end
        elseif device.platform == "android" then

            -- luaPrint("start lua to java");
            local javaMethodName = "sendMsgToTimeLine"
            local javaParams = {path, shareType}
            local javaMethodSig = "(Ljava/lang/String;I)V"
            local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
          
            if ok == false then
                luaPrint("luaoc调用出错 onUnitedPlatformShareTimeLine")
            end
        else
            local prompt = GamePromptLayer:create();
            prompt:showPrompt(GBKToUtf8(path));
            luaPrint("onUnitedPlatformShareTimeLine!")
        end
    end
end

function getSharedRoomInfo()
    -- luaPrint("getSharedRoomInfo  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getSharedRoomInfo")
        if ok == false then
            luaPrint("luaoc调用出错:getSharedRoomInfo")
        else
            -- AutoLoginFormWeb(ret);
        end
    elseif device.platform == "android" then
        local javaMethodName = "getSharedRoomInfo"
        local javaParams = {path, shareType}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 getSharedRoomInfo")
        else
            AutoLoginFormWeb(ret);
        end
    end
end

--微信分享 end ----------

--语音Java调用本地函数  start-------------
function OnApplyMessageKey(arg)
    luaPrint("lua OnApplyMessageKey --- arg  = "..arg);
    local mnotify = MessageNotify:getInstance();

    if mnotify then
        mnotify:OnApplyMessageKey(tonumber(arg));
    end
end

function OnDownloadFile(arg)
    local mnotify = MessageNotify:getInstance();

    if mnotify then
        local ret = string.split(arg, ',');
        local code = ret[1];
        local filePath = ret[2];
        local fileID = ret[3];
        mnotify:OnDownloadFile(tonumber(code), filePath, fileID);
    end
end

function OnJoinRoom(arg)
    local mnotify = MessageNotify:getInstance();

    if mnotify then
        local ret = string.split(arg, ',');
        local code = ret[1];
        local roomName = ret[2];
        local memberID = ret[3];
        mnotify:OnJoinRoom(tonumber(code), roomName, memberID);
    else
        luaPrint("lua OnJoinRoom error mnotify is nil");
    end
end

function OnMemberVoice(arg)

end

function OnPlayRecordedFile(arg)
    local mnotify = MessageNotify:getInstance();

    if mnotify then
        local ret = string.split(arg, ',');
        local code = ret[1];
        local filePath = ret[2];
        mnotify:OnPlayRecordedFile(tonumber(code), filePath);
    end
end

function OnQuitRoom(arg)
    local mnotify = MessageNotify:getInstance();

    if mnotify then
        local ret = string.split(arg, ',');
        local code = ret[1];
        local roomName = ret[2];
        mnotify:OnQuitRoom(tonumber(code), roomName);
    end
end

function OnRecording(arg)

end

function OnSpeechToText(arg)

end

function OnStatusUpdate(arg)

end

function OnStreamSpeechToText(arg)

end

function OnUploadFile(arg)
    luaPrint("上传回调到lua");
    local mnotify = MessageNotify:getInstance();

    if mnotify then
        local ret = string.split(arg, ',');
        local code = ret[1];
        local filePath = ret[2];
        local fileID = ret[3];
        mnotify:OnUploadFile(tonumber(code), filePath, fileID);
    else
        luaPrint("onuploadFile  mnotify is nil");
    end
end

--语音Java调用本地函数  end-------------


--语音操作-----------------start----------------
--初始化语音sdk
function onUnitedPlatformInitGCloudSDK(appID, appKey, openID)
    luaPrint("onUnitedPlatformInitGCloudSDK  -----")
    if device.platform == "ios" then
        local args = {appid=appID,appkey=appKey,openid=openID}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","GVoiceInit",args)
        if ok == false then
            luaPrint("luaoc调用出错:GVoiceInit")
        else
            return ret;
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "initGCloudVoice"
        local javaParams = {appID, appKey, openID}
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformInitGCloudSDK")
        else
            return ret;
        end
    else
        luaPrint("onUnitedPlatformInitGCloudSDK!")
    end

    return -1;
end

function onUnitedPlatformSetNotify()
    luaPrint("onUnitedPlatformSetNotify  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","SetNotify",args)
        if ok == false then
            luaPrint("luaoc调用出错:SetNotify")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "SetNotify"
        local javaParams = { path}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformSetNotify")
        end
    else
        luaPrint("onUnitedPlatformSetNotify!")
    end
end

function onUnitedPlatformApplyMessageKey()
    luaPrint("onUnitedPlatformApplyMessageKey  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","applyMessageKey")
        if ok == false then
            luaPrint("luaoc调用出错:applyMessageKey")
        else
            return ret;
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "applyMessageKey"
        local javaParams = {}
        local javaMethodSig = "()I"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformApplyMessageKey")
        else
            return ret;
        end
    else
        luaPrint("onUnitedPlatformApplyMessageKey!")
    end

    return -1;
end

function onUnitedPlatformSetMode(mode)
    luaPrint("onUnitedPlatformSetMode  ----- mode "..mode)
    if device.platform == "ios" then
        local args = {mode=mode}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","setGCloudMode",args)
        if ok == false then
            luaPrint("luaoc调用出错:setGCloudMode")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "setGCloudMode"
        local javaParams = {mode}
        local javaMethodSig = "(I)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformSetMode")
        end
    else
        luaPrint("onUnitedPlatformSetMode!")
    end
end

function onUnitedPlatformJoinTeamRoom(roomName)
    luaPrint("onUnitedPlatformJoinTeamRoom  ----- roomName   "..roomName)
    if device.platform == "ios" then
        local args = {roomName=roomName}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","JoinTeamRoom",args)
        if ok == false then
            luaPrint("luaoc调用出错:JoinTeamRoom")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "JoinTeamRoom"
        local javaParams = {roomName}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformJoinTeamRoom")
        end
    else
        luaPrint("onUnitedPlatformJoinTeamRoom!")
    end
end

function onUnitedPlatformJoinNationalRoom(roomName)
    luaPrint("onUnitedPlatformJoinNationalRoom  -----  roomName "..roomName)
    if device.platform == "ios" then
        local args = {roomName=roomName}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","JoinNationalRoom",args)
        if ok == false then
            luaPrint("luaoc调用出错:JoinNationalRoom")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "JoinNationalRoom"
        local javaParams = {roomName}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformJoinNationalRoom")
        end
    else
        luaPrint("onUnitedPlatformJoinNationalRoom!")
    end
end

function onUnitedPlatformOpenMic()
    luaPrint("onUnitedPlatformOpenMic  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","OpenMic")
        if ok == false then
            luaPrint("luaoc调用出错:OpenMic")
        end
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "OpenMic"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformOpenMic")
        end
    else
        luaPrint("onUnitedPlatformOpenMic!")
    end
end

function onUnitedPlatformCloseMic()
    luaPrint("onUnitedPlatformCloseMic  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","CloseMic")
        if ok == false then
            luaPrint("luaoc调用出错:CloseMic")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "CloseMic"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformCloseMic")
        end
    else
        luaPrint("onUnitedPlatformCloseMic!")
    end
end

function onUnitedPlatformOpenSpeaker()
    luaPrint("onUnitedPlatformOpenSpeaker  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","OpenSpeaker")
        if ok == false then
            luaPrint("luaoc调用出错:OpenSpeaker")
        end
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "OpenSpeaker"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformOpenSpeaker")
        end
    else
        luaPrint("onUnitedPlatformOpenSpeaker!")
    end
end

function onUnitedPlatformCloseSpeaker()
    luaPrint("onUnitedPlatformCloseSpeaker  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","CloseSpeaker")
        if ok == false then
            luaPrint("luaoc调用出错:CloseSpeaker")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "CloseSpeaker"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformCloseSpeaker")
        end
    else
        luaPrint("onUnitedPlatformCloseSpeaker!")
    end
end

function onUnitedPlatformQuitRoom(roomName)
    luaPrint("onUnitedPlatformQuitRoom  -----")
    if device.platform == "ios" then
        local args = {roomName=roomName}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","QuitRoom",args)
        if ok == false then
            luaPrint("luaoc调用出错:PlatformSwtichServer")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "QuitRoom"
        local javaParams = {roomName}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformQuitRoom")
        end
    else
        luaPrint("onUnitedPlatformQuitRoom!")
    end
end

function onUnitedPlatformPoll()
    luaPrint("onUnitedPlatformPoll  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","poll")
        if ok == false then
            luaPrint("luaoc调用出错:Poll")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "Poll"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformPoll")
        end
    else
        luaPrint("onUnitedPlatformPoll!")
    end
end

function onUnitedPlatformUnpoll()
    luaPrint("onUnitedPlatformUnpoll  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","stopPoll")
        if ok == false then
            luaPrint("luaoc调用出错:stopPoll")
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "stopPoll"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformUnpoll")
        end
    else
        luaPrint("onUnitedPlatformUnpoll!")
    end
end

function onUnitedPlatformStopRecording()
    luaPrint("onUnitedPlatformStopRecording  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","StopRecording")
        if ok == false then
            luaPrint("luaoc调用出错:StopRecording")
        else
            return ret;
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "StopRecording"
        local javaParams = {}
        local javaMethodSig = "()I"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformStopRecording")
        else
            return ret;
        end
    else
        luaPrint("onUnitedPlatformStopRecording!")
    end

    return -1;
end

function onUnitedPlatformStartRecording(path)
    luaPrint("onUnitedPlatformStartRecording  -----")
    if device.platform == "ios" then
        local args = {filePath=path}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","StartRecording",args)
        if ok == false then
            luaPrint("luaoc调用出错:StartRecording")
        else
            return ret;
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "StartRecording"
        local javaParams = {path}
        local javaMethodSig = "(Ljava/lang/String;)I"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformStartRecording")
        else
            return ret;
        end
    else
        luaPrint("onUnitedPlatformStartRecording!")
    end

    return -1;
end

function onUnitedPlatformUploadRecordedFile(path)
    luaPrint("onUnitedPlatformUploadRecordedFile  -----")
    if device.platform == "ios" then
        local args = {filePath=path}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","UploadRecordedFile",args)
        if ok == false then
            luaPrint("luaoc调用出错:UploadRecordedFile")
        else
            return ret;
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "UploadRecordedFile"
        local javaParams = {path}
        local javaMethodSig = "(Ljava/lang/String;)I"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformUploadRecordedFile")
        else
            return ret;
        end
    else
        luaPrint("onUnitedPlatformUploadRecordedFile!")
    end

    return -1;
end

function onUnitedPlatformGetFileParam(path)
    luaPrint("onUnitedPlatformGetFileParam  -----")
    if device.platform == "ios" then
        local args = {filePath = path};
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","GetFileParam",args)
        if ok == false then
            luaPrint("luaoc调用出错:GetFileParam")
        else
            return ret;
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "GetFileParam"
        local javaParams = {path}
        local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformGetFileParam")
        else
            return ret;
        end
    else
        luaPrint("onUnitedPlatformGetFileParam!")
    end

    return -1;
end

function onUnitedPlatformDownloadRecordedFile(fileID, path)
    luaPrint("onUnitedPlatformDownloadRecordedFile  -----")
    if device.platform == "ios" then
        local args = {fileID=fileID,filePath=path}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","DownloadRecordedFile",args)
        if ok == false then
            luaPrint("luaoc调用出错:DownloadRecordedFile")
        else
            return ret;
        end        
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "DownloadRecordedFile"
        local javaParams = {fileID, path}
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)I"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformDownloadRecordedFile")
        else
            return ret;
        end
    else
        luaPrint("onUnitedPlatformDownloadRecordedFile!")
    end

    return -1;
end

function onUnitedPlatformPlayRecordedFile(path)
    luaPrint("onUnitedPlatformPlayRecordedFile  -----")
    if device.platform == "ios" then
        local args = {filePath=path}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","PlayRecordedFile",args)
        if ok == false then
            luaPrint("luaoc调用出错:PlayRecordedFile")
        else
            return ret;
        end
    elseif device.platform == "android" then
        -- luaPrint("start lua to java");
        local javaMethodName = "PlayRecordedFile"
        local javaParams = {path}
        local javaMethodSig = "(Ljava/lang/String;)I"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformPlayRecordedFile")
        else
            return ret;
        end
    else
        luaPrint("onUnitedPlatformPlayRecordedFile!")
    end

    return -1;
end

--语音操作-----------------end----------------

--模块操作 start
gVersion = "1.0.0";
function onUnitedPlatformGetVersion()
    luaPrint("onUnitedPlatformGetVersion  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getVersion")
        if ok == false then
            luaPrint("luaoc调用出错:onUnitedPlatformGetVersion")
        else
            gVersion = ret;
            return ret;
        end
    elseif device.platform == "android" then
        local javaMethodName = "getVersion"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformGetVersion")
        else
            gVersion = ret;
            return ret;
        end
    else
        luaPrint("onUnitedPlatformGetVersion!")
    end

    return gVersion;
end

gSearial = nil

function onUnitedPlatformGetSerialNumber()
    if device.platform == "ios" then
        if gSearial ~= nil then
            return gSearial
        else
            gSearial = cc.UserDefault:getInstance():getStringForKey("iosimei","")
            if gSearial ~= "" then
                if gSearial == "00000000-0000-0000-0000-000000000000" then
                    cc.UserDefault:getInstance():setStringForKey("iosimei","")
                else
                    return gSearial
                end
            end
        end

        local args = {}
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getSerialNumber",args)
        if ok == false then
            luaPrint("luaoc调用出错:onUnitedPlatformGetSerialNumber")
        else
            if runMode == "debug" then
                -- ret = ret..os.time()
            end

            if gSearial ~= "00000000-0000-0000-0000-000000000000" then
                cc.UserDefault:getInstance():setStringForKey("iosimei",ret)
            end
            gSearial = ret
            return ret
        end
    elseif device.platform == "android" then
        if gSearial ~= nil then
            return gSearial
        else
            local path = "/mnt/sdcard/lconfig.txt";
            local file = io.open(path, "rb")
            if not file then
                file = io.open("/mnt/ext_sdcard/lconfig.txt","rb")
            end

            if file then
                local currrent = file:seek()
                local size = file:seek("end")
                file:seek("set",currrent)
                local testM =file:read(size)
                gSearial = testM
                file:close()
                return gSearial
            end
        end

        local javaMethodName = "getSerialNumber"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if ok == false then
            luaPrint("luaoc调用出错 onUnitedPlatformGetSerialNumber")
        else
            if runMode == "debug" then
                -- ret = ret..os.time()
            end

            local path = "/mnt/sdcard/lconfig.txt";
            local f, err = io.open(path, 'wb')
            if not f then
                f = io.open("/mnt/ext_sdcard/lconfig.txt","wb")
            end

            if f then
                f:write(ret)
                f:close()
                gSearial = ret
            end
            return ret
        end
    else
        luaPrint("onUnitedPlatformGetSerialNumber!")
    end

    local ret = "026666-703017-106FA5-C05854-26B9-357F62";
    -- local ret = "061266-703017-106FA5-C05854-23B9-367F39";

    if runMode == "debug" then
        -- ret = ret..os.time()
    end

    return ret
end

function wxSearialNumber(id)
    if device.platform == "ios" then
        if gwxSearial ~= nil then
            return gwxSearial
        else
            gwxSearial = cc.UserDefault:getInstance():getStringForKey("wxiosimei",id)
            if gwxSearial ~= "" then
                return gwxSearial
            end
        end
    elseif device.platform == "android" then
        if gwxSearial ~= nil then
            return gwxSearial
        else
            local path = "/mnt/sdcard/lwxconfig.txt";
            local file = io.open(path, "rb")
            if not file then
                file = io.open("/mnt/ext_sdcard/lwxconfig.txt","rb")
            end

            if file then
                local currrent = file:seek()
                local size = file:seek("end")
                file:seek("set",currrent)
                local testM =file:read(size)
                gwxSearial = testM
                file:close()
                return gwxSearial
            end
        end

        local path = "/mnt/sdcard/lwxconfig.txt";
        local f, err = io.open(path, 'wb')
        if not f then
            f = io.open("/mnt/ext_sdcard/lwxconfig.txt","wb")
        end

        if f then
            f:write(id)
            f:close()
            gwxSearial = id
        end
    end

    return gwxSearial
end

--模块操作 end

--applepay  start---
function onUnitedPlatformApplePay(goodid)
    if device.platform == "ios" then
        local args = {goodid=goodid,userid = PlatformLogic.loginResult.dwUserID,url="http://"..GameConfig.A_SERVER_IP..GameConfig.WEB_PORT.."/Public/XmlHttpUser.aspx?type=AddOrder2"};
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","doIAPPrepayHttpRequest",args)
        if ok == false then
            luaPrint("luaoc调用出错:doIAPPrepayHttpRequest")
        end
    end
end

function doIAPVerifyHttpRequest(event)
    local receipt = event.receipt;
    local orderid = event.orderid;
    local cny = event.cny;
    luaPrint("苹果支付回调")
    local url = "http://"..GameConfig.A_SERVER_IP..GameConfig.WEB_PORT.."/Public/XmlHttpUser.aspx?type=PaySucceedByIOS2";
    -- local url = "http://120.76.43.8:8009/Public/XmlHttpUser.aspx?type=PaySucceedByIOS2";

    local str = "OrderID="..orderid.."&payMoney="..cny.."&receipt_data="..receipt;
    luaPrint("str -- "..str);

    HttpUtils:requestHttp(url, function(result, response) onIAPVerifyHttpRequestCompleted(result, response); end, "POST", str);
end

function onIAPVerifyHttpRequestCompleted(result, response)
    if result == false then
        luaPrint("Apple pay 二次支付验证 error");
    else
        local str = json.decode(response);

        if str then
            local Statu = tonumber(str.Statu);
            local GoodID = tonumber(str.GoodID);

            if Statu == 1 then
               if HallLayer:getInstance() then
                   HallLayer:getInstance():toCallUpdateRoomkey();
               end
            else
                luaPrint("Verify Faild");
           end 
        end
    end
end
--applepay end----

-- -- 公告请求结果
-- function onHttpRequestNotice(result, response)
--     if result == false then
--         luaPrint("http request cmd =  error");
--         return;
--     end
--     luaPrint("公告请求成功111------------------------")
--     local tb = json.decode(response)  
--     luaPrint("公告请求成功------------------------",tb)
--     if tb then 
--         local table = tb["list"]
--         local str = table[1]["MContent"]
--         globalUnit.m_sNotieceMsg = str;
--         luaPrint("公告请求成功------------------------",globalUnit.m_sNotieceMsg)
--     end
-- end

local bit = require("bit")
function unicode_to_utf8(convertStr)
    if type(convertStr)~="string" then
        return convertStr
    end

    local resultStr=""
    local i=1
    while true do
        local num1=string.byte(convertStr,i)
        local unicode

        if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
            unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
            i=i+6
        elseif num1~=nil then
            unicode=num1
            i=i+1
        else
            break
        end

        if unicode <= 0x007f then
            resultStr=resultStr..string.char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        end
    end
    resultStr=resultStr..'\0'
    --luaPrint(resultStr)
    return resultStr
end

--写入当前包类型
function writePackageType(arg)
    if arg == nil then
        return;
    end
    
    luaPrint("writePackageType arg ="..arg);

    if device.platform == "ios" then
        if tonumber(arg) == 1 then
            globalUnit:setIsFormalPackage(true);
        else
            globalUnit:setIsFormalPackage(false);
        end
    else
        globalUnit:setIsFormalPackage(true);
    end
end

--iOS获取当前包类型
function readPackageType()
    luaPrint("readPackageType  -----")
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","readPackageType")
        if ok == false then
            luaPrint("luaoc调用出错:readPackageType")
        end
    end
end

reyunKey = "38583b1764e9ad6b859f8b647e23440e";
isInitReyun = false;
function onUnitedPlatformInitReyunSDK()
    if device.platform == "ios" and isInitReyun ~= true then
        local ok,ret;
            local args = {key=reyunKey,channel=getGameChannel()};
            ok,ret = luaCallFun.callStaticMethod("MethodForLua","reyunInit",args);
        
        if ok == false then
            luaPrint("luaoc调用出错:reyunInit")
        else
            isInitReyun = true;
        end
    end
end

--热云  监听注册
function reyunSetRegisterWithAccountID(userid)
    luaPrint("reyunSetRegisterWithAccountID  -----")
    if device.platform == "ios" then
        local args = {userid=userid};
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","reyunSetRegisterWithAccountID",args)
        if ok == false then
            luaPrint("luaoc调用出错:reyunSetRegisterWithAccountID")
        else
            -- AutoLoginFormWeb(ret);
        end
    elseif device.platform == "android" then
        local javaMethodName = "reyunSetRegisterWithAccountID"
        local javaParams = {tostring(userid)}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 reyunSetRegisterWithAccountID")
        else
            -- AutoLoginFormWeb(ret);
        end
    end
end

--热云  监听登录
function reyunSetLoginSuccess(userid)
    -- if device.platform == "ios" then
    --     local args = {userid=tostring(userid)};
    --     local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","reyunSetLoginSuccess",args)
    --     if ok == false then
    --         luaPrint("luaoc调用出错:reyunSetLoginSuccess")
    --     else
    --         -- AutoLoginFormWeb(ret);
    --     end
    -- elseif device.platform == "android" then
    --     local javaMethodName = "reyunSetLoginSuccess"
    --     local javaParams = {tostring(userid)}
    --     local javaMethodSig = "(Ljava/lang/String;)V"
    --     local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
    --     if ok == false then
    --         luaPrint("luaoc调用出错 reyunSetLoginSuccess")
    --     else
    --         -- AutoLoginFormWeb(ret);
    --     end
    -- end
end

--获取设备唯一标识
function GetDeviceUUID()
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getUUID")
        if ok == false then
            luaPrint("luaoc调用出错:getUUID")
        else
            return ret
        end
    elseif device.platform == "android" then
        local javaClassName = "org.cocos2dx.lua.HNCommonUtils"
        local javaMethodName = "getUUID"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 GetDeviceUUID")
        else
            return ret;
        end
    end
    return "000266-703028-103FA5-C05024-006BBE-007F50";
end

function getGameChannel()
    if device.platform == "ios" then
        if globalUnit then
            globalUnit.gameChannel = gameName.."000";
        end
        return gameName.."000";
    elseif device.platform == "android" then
        -- local javaMethodName = "getGameChannel"
        -- local javaParams = {}
        -- local javaMethodSig = "()Ljava/lang/String;"
        -- local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)

        -- if ok == false then
        --     luaPrint("luaoc调用出错 getGameChannel")
        -- else
        -- end

        globalUnit.gameChannel = gameName.."000";
        return globalUnit.gameChannel;
    else
        globalUnit.gameChannel = "ls_windows" 
    end
end

function getConfig(arg)
    if device.platform == "android" then
        -- if checkVersion("1.1.1") == 2 then
        --     local javaMethodName = "getConfig"
        --     local javaParams = {arg}
        --     local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
        --     local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)

        --     if ok == false then
        --         luaPrint("luaoc调用出错 getConfig")
        --     else
        --         if arg == "channel" then
        --             globalUnit.gameChannel = ret;
        --         end

        --         return ret
        --     end
        -- else
            if arg == "channel" then
                return globalUnit.gameChannel
            end
        -- end
    elseif device.platform == "ios" then
        if arg == "channel" then
            return globalUnit.gameChannel
        end
    end

    return ""
end

jiGuangKey  = "be705a4fa6039c8a430a3651"
isInitJiGuang = false;
function onUnitedPlatformInitJiGuangSDK()
    if device.platform == "ios" and isInitJiGuang ~= true then
        local ok,ret;
        local args = {key=jiGuangKey};
        ok,ret = luaCallFun.callStaticMethod("MethodForLua","initJiGuangSDK",args);
        
        if ok == false then
            luaPrint("luaoc调用出错:initJiGuangSDK")
        else
            if ret == 1 then
                isInitJiGuang = true;
            end
        end
    end
end

function getJiGuangID()
    local gJiGuangID = ""
    if device.platform == "ios" then
        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","getJiGuangID")
        if ok == false then
            luaPrint("luaoc调用出错:getJiGuangID")
        else
            gJiGuangID = ret;
        end
    elseif device.platform == "android" then
        local javaMethodName = "getJiGuangID"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 getJiGuangID")
        else
            gJiGuangID = ret;
        end
    end

    if gJiGuangID == "" and device.platform ~= "windows" and appleView ~= 1 then
        --启动定时获取
        checkJiGuangID();
    end
    return gJiGuangID;
end

--全局检测
function checkJiGuangID()
    if schedulerJiGuang then
        return;
    end

    local func = function()
        local id = getJiGuangID();
        if id and id ~= nil and id ~= "" then
            local sharedScheduler = cc.Director:getInstance():getScheduler()
            sharedScheduler:unscheduleScriptEntry(schedulerJiGuang)
            schedulerJiGuang = nil;

            if PlatformLogic then
                PlatformLogic:sendJiGuangID(id);
            end
        end
    end

    local sharedScheduler = cc.Director:getInstance():getScheduler()

    schedulerJiGuang = sharedScheduler:scheduleScriptFunc(func, 3, false)
end

function getPhoneVersion()
    if device.platform == "ios" then
        --todo
    elseif device.platform == "android" then
        local javaMethodName = "getPhoneVersion"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 getPhoneVersion")
        else
           return ret;
        end
    end

    return "";
end

function getPhoneModel()
    if device.platform == "ios" then
        --todo
    elseif device.platform == "android" then
        local javaMethodName = "getPhoneModel"
        local javaParams = {}
        local javaMethodSig = "()Ljava/lang/String;"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 getPhoneModel")
        else
           return ret;
        end
    end

    return "";
end

--初始化第三方支付sdk
sdkKey = "";
function initThirdSDK()
    if isIntThirdSDK == true then
        return;
    end

    if device.platform == "ios" then
    elseif device.platform == "android" then
        local javaMethodName = "initThirdSDK"
        local javaParams = {sdkKey}
        local javaMethodSig = "(Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 initThirdSDK")
        else
            isIntThirdSDK = true;
        end
    end
end

--第三方登陆
function thirdLogin()
    if device.platform == "ios" then
    elseif device.platform == "android" then
        local javaMethodName = "thirdLogin"
        local javaParams = {}
        local javaMethodSig = "()V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 thirdLogin")
        end
    end
end

--第三方登陆回调
function thirdLoginSuccess(arg)
    if arg == nil then
        return;
    end
    
    local ret = string.split(arg, ',');

    local nickName = ret[1];
    local uid = ret[2];
    local token = ret[3];
    local session = ret[4];

    luaPrint("sdk 登陆成功 nickName : "..nickName.." uid : "..uid.." token : "..token.." session : "..session)
    SocialUtils._wx_unionid=uid;
    SocialUtils._wx_nickname = nickName;
end

function thirdLogoutSuccess()
    luaPrint("thirdLogoutSuccess ----------")
    if globalUnit.isEnterGame == true then
        -- if TableLayer and TableLayer:getInstance() then
            luaPrint("TableLayer:getInstance()")
            -- TableLayer:getInstance():leaveDesk(1);
        -- end
    else
        cc.UserDefault:getInstance():setStringForKey(USERNAME_TEXT,"");
        cc.UserDefault:getInstance():getStringForKey(PASSWORD_TEXT, "");

        globalUnit:init();

        globalUnit:setLoginType(guestLogin);

        local name = cc.FileUtils:getInstance():getWritablePath().."headupload.png";
        if cc.FileUtils:getInstance():isFileExist(name) then
            cc.Director:getInstance():getTextureCache():removeTextureForKey(name);
        end

        Hall.startGame();
    end
end

--第三方登陆校验
function checkThirdLogin(ret, response)
    local data = json.decode(response);
    luaDump(data,"checkThirdLogin")
    if ret == true and data.Statu == 1 then
        luaDump(data,"checkThirdLogin 登陆成功");
        if LoginLayer and LoginLayer:getInstance() then
            LoginLayer:getInstance():gameWXRegister(SocialUtils._wx_unionid, SocialUtils._wx_nickname);
            LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("加载中,请稍后"), LOADING):removeTimer(20);
        end
    else
        luaPrint("checkThirdLogin 服务器校验登陆失败")
    end
end

--购买配置
PurchaseConfig = {
}

function getPayOrderID(payID)
end

function thirdPay(payID,orderID)
    local price = PurchaseConfig.productPrice[payID];
    local des = PurchaseConfig.productDes[payID];

    if device.platform == "ios" then
    elseif device.platform == "android" then
        local javaMethodName = "thirdPay"
        local javaParams = {des,price,orderID}
        local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret  = luaCallFun.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
      
        if ok == false then
            luaPrint("luaoc调用出错 thirdPay")
        end
    end
end

--支付回调
function thirdPaySuccess()

end

function printMemoryInfo()
    local func = function() 
        if globalUnit and globalUnit.isEnterGame ~= true then
            clearCache(nil,nil,false)
        end

        collectgarbage("collect")

        if runMode == "debug" then
            luaPrint("/////////////////////////////////////////")

            printInfo(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
            -- luaDump(cc.Director:getInstance():getTextureCache():getCachedTextureInfo());
            cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo();
            luaPrint("/////////////////////////////////////////")
        end
    end
    local sharedScheduler = cc.Director:getInstance():getScheduler()
    schedulerMemory = sharedScheduler:scheduleScriptFunc(func, 20, false)
end

--场景spine对象
function createSkeletonAnimation(skName,skJson,skAtlas)
    local skeleton_animation = nil
    --由于cocos2dx_spine.ini中没对SkeletonAnimation::createWithData函数进行绑定，所以这个函数在lua中不能使用
    if sp.SkeletonAnimation.createFromCache then
        if addSkeletonAnimation(skName,skJson,skAtlas) then
            skeleton_animation = sp.SkeletonAnimation:createFromCache(skName)
        end
        luaPrint("cache skName ======  "..skName)
    else
        if cc.FileUtils:getInstance():isFileExist(skJson) and cc.FileUtils:getInstance():isFileExist(skAtlas) then
            local path = subString(skAtlas,".")
            path = path..".png"

            if cc.FileUtils:getInstance():isFileExist(path) and display.loadImage(path) ~= nil then
                skeleton_animation = sp.SkeletonAnimation:create(skJson, skAtlas)
                luaPrint("not cache skName ======  "..skName)
            else
                luaPrint("create spine error  "..skJson)
            end
        end
    end
    -- skeleton_animation=nil
    return skeleton_animation
end

--全局记录换spine缓存名称
spineCacheName = {}

--加入spine缓存
function addSkeletonAnimation(skName,skJson,skAtlas)
    if sp.SkeletonAnimation.isExistSkeletonDataInCache and not sp.SkeletonAnimation:isExistSkeletonDataInCache(skName) and skJson and skAtlas and 
        cc.FileUtils:getInstance():isFileExist(skJson) and cc.FileUtils:getInstance():isFileExist(skAtlas) then
        local path = subString(skAtlas,".")
        path = path..".png"

        luaPrint("skJson = "..tostring(skJson))
        luaPrint("skAtlas = "..tostring(skAtlas))
        luaPrint("skPng = "..tostring(path))

        if cc.FileUtils:getInstance():isFileExist(path) and display.loadImage(path) ~= nil then
            sp.SkeletonAnimation:readSkeletonDataToCache(skName, skJson, skAtlas)

            if spineCacheName == nil then
                spineCacheName = {}
            end

            table.insert(spineCacheName,skName)
            return true
        else
            luaPrint("spine cache failed png "..tostring(cc.FileUtils:getInstance():isFileExist(path)))
        end
    else
        if sp.SkeletonAnimation:isExistSkeletonDataInCache(skName) then
            return true
        else
            luaPrint("spine cache failed skJson = "..tostring(cc.FileUtils:getInstance():isFileExist(skJson)).." skAtlasb = "..tostring(cc.FileUtils:getInstance():isFileExist(skAtlas)))
        end
    end
end

--删除spine
function removeSkeletonAnimation(skName, isRemove)
    if isRemove == nil then
        isRemove = true
    end

    if skName then
        if sp.SkeletonAnimation.removeSkeletonData then
            local ret = sp.SkeletonAnimation:removeSkeletonData(skName)
            if isRemove and ret then
                table.removebyvalue(spineCacheName,skName)
            end

            return ret
        end
    end

    return false
end

--删除无用spine
function removeUnuseSkeletonAnimation()
    if sp.SkeletonAnimation.removeUnuseSkeletonDatas then
        sp.SkeletonAnimation:removeUnuseSkeletonDatas()
        for k,v in pairs(spineCacheName) do
            if not isExistSkeletonDataInCache(v) then
                table.removebyvalue(spineCacheName,v,true)
            end
        end
    end
end

-- 删除所有
function removeAllSkeletonAnimation()
    if sp.SkeletonAnimation.removeAllSkeletonData then
        sp.SkeletonAnimation:removeAllSkeletonData()
        for k,v in pairs(spineCacheName) do
            if not isExistSkeletonDataInCache(v) then
                table.removebyvalue(spineCacheName,v,true)
            end
        end
    end
end

--特殊用途 在退出大厅前 大厅的spine动画不移除
-- skNames 不希望被移除的spine
function removeOtherUnuseSkeletonAnimation(skNames)
    if skNames == nil or skNames == "" then
        return
    end

    if type(skNames) ~= "table" then
        removeSkeletonAnimation(skNames)
    else
        local temp = {}
        for k,v in pairs(spineCacheName) do
            local ret = false

            for kk,vv in pairs(skNames) do
                if v == vv then
                    ret = true
                    break
                end
            end

            if not ret then
                if removeSkeletonAnimation(v,false) then
                    table.insert(temp,v)
                end
            end
        end

        for k,v in pairs(temp) do
            table.removebyvalue(spineCacheName,v,true)
        end
    end
end

--spine动画是否缓存
function isExistSkeletonDataInCache(skName)
    if skName and sp.SkeletonAnimation.isExistSkeletonDataInCache then
        return sp.SkeletonAnimation:isExistSkeletonDataInCache(skName)
    end

    return false
end

--帧动画
function createFrames(frameName,frameCount)
    if frameName and frameCount then
        local animation= cc.Animation:create()

        for i=1,frameCount do
            local strname = string.format(frameName, i)
            animation:addSpriteFrameWithFile(strname)
        end
        animation:setDelayPerUnit(0.05)
        animation:setRestoreOriginalFrame(true)

        local animate= cc.Animate:create(animation)

        local sp = cc.Sprite:create(string.format(frameName,1))
        sp:runAction(cc.RepeatForever:create(animate))
        return sp
    end

    return nil
end
