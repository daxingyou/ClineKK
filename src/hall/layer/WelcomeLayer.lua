local WelcomeLayer = class("WelcomeLayer", function() return display.newLayer() end)

require("platform.PlatformFunction")

isCloseQSu = false

function WelcomeLayer:scene()
	local welcomeLayer = WelcomeLayer:create()

	local scene = display.newScene()
	scene:addChild(welcomeLayer)

	display.runScene(scene)
end

function WelcomeLayer:create()
	return WelcomeLayer.new()
end

function WelcomeLayer:ctor()
	self:setLayerNodeEvent()
	self.globalBindCustomIds = {}
	self.globalBindCustomIds[#self.globalBindCustomIds + 1] = bindGlobalEvent("reqestHotUpdate",handler(self, self.reqestWebHotUpdateUrl))

	self:initUI()
end

function WelcomeLayer:setLayerNodeEvent()
	local function onNodeEvent(eventName)
		if "enter" == eventName then
			self:onEnter()
		elseif "exit" == eventName then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

function WelcomeLayer:initUI()
	local node = cc.CSLoader:createNode("updateLayer.csb")
	node:setCascadeOpacityEnabled(true)
	self:addChild(node)

	local bg = node:getChildByName("Image_bg")
	bg:removeChildByName("Text_info")
	bg:removeChildByName("Text_error")
	bg:removeChildByName("Image_lineBg")
	bg:removeChildByName("Text_percent")
	bg:loadTexture("common/bg.png")
	iphoneXFit(bg)

	local btnXiufu = bg:getChildByName("Button_yijianxiufu")
	if btnXiufu then
		btnXiufu:hide()
		btnXiufu:addClickEventListener(function(sender)	self:clearOldResources(); end)
	end

	local image = ccui.ImageView:create("gameUpdate/logo.png")
	image:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
	bg:addChild(image)

	local image = ccui.ImageView:create("gameUpdate/info.png")
	image:setPosition(bg:getContentSize().width/2,0)
	image:setAnchorPoint(0.5,0)
	bg:addChild(image)
end

function WelcomeLayer:onExit()
	for _, bindid in ipairs(self.globalBindCustomIds) do
		unbindEvent(bindid)
	end

	self.globalBindCustomIds = {}
end

function WelcomeLayer:onEnter()
	self.requestCount = 0
	self.isEndStart = false
	self.requestCountHot = 0
	localAppVersion = self:getAppVersion()

	local cv = getAppConfig("BundleVersionDate")

	if isEmptyString(cv) then
		cv = "0"
	end

	local text = "Appv "..tostring(localAppVersion).."	Resv "..tostring(GameConfig:getLuaVersion(gameName).."	Appcv "..tostring(cv))
	local winSize = cc.Director:getInstance():getWinSize()
	local tip = FontConfig.createWithSystemFont(text,18,FontConfig.colorWhite)
	tip:setAnchorPoint(0,0.5)
	tip:setPosition(cc.p(15,winSize.height-15))
	self:addChild(tip)

	-- 判断是否重置本地
	local url = cc.UserDefault:getInstance():getStringForKey("hotUpdate","")
	if url ~= "" then
		local output = self:getProtocolData(url)

		print("结果 ",url)
		try({
			function() 
				local temp = clone(GameConfig.domain)
				GameConfig.domain =  StrToTable(output)
				dump(GameConfig.domain,"localFile")
				GameConfig:switchUrl()
				GameConfig.domain =  mergeTables(StrToTable(output),temp)
				dump(GameConfig.domain,"newlocalfile")
			end,
			catch=function(error)
				print("local hotUpdate error ",error)
			end
		})
	end

	--根据本地保持版本，设置ios控制状态
	if device.platform == "ios" then
		if localAppVersion == GameConfig.appleVersion then
			appleView = 1
		else
			appleView = 0
		end
	else
		appleView = 0
	end

	local func = function()
		if self.isEndStart ~= true then
			if isChangeSDK ~= true then
				print("超时进入游戏")
				self.isEndStart = true
				NO_UPDATE = true
				isRepairUpate = true
				gameStart()
			else
				self:timeoutEnterGame()
			end
		end
	end

	if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
		performWithDelay(self,func,9):setTag(123)

		performWithDelay(self,function() GameConfig:switchUrl() self:requestGameVersionInfo() end,3):setTag(111)--第一次
	end

	self:requestGameVersionInfo()
end

function WelcomeLayer:timeoutEnterGame()
	local func = function()
		if self.isEndStart ~= true then
			if isChangeSDK ~= true then
				print("超时进入游戏1122")
				self.isEndStart = true
				NO_UPDATE = true
				isRepairUpate = true
				gameStart()
			end
		end
	end

	if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
		performWithDelay(self,func,5):setTag(123)
	end
end

function WelcomeLayer:createCheckCode(url)	
	return encodeBase64(url)
end

function WelcomeLayer:getProtocolData(url)
	return decodeBase64(url)
end

function WelcomeLayer:reqestWebHotUpdateUrl()
	-- if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
		self.requestCountHot = self.requestCountHot + 1

		-- if self.requestCountHot == 2 then--第一次失败切换域名
			self:stopActionByTag(111)
		-- end
		print("self.requestCountHot ",self.requestCountHot)
		if self.requestCountHot > 2 then
			if self.isEndStart ~= true then
				if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
					self.isEndStart = true
					self:stopAllActions()
					NO_UPDATE = true
					isRepairUpate = true
					gameStart()
				else
					self.requestCountHot = 0
					self.requestCount = 0
					-- local func = function()
					-- 	if self.isEndStart ~= true then
					-- 		self:gameStart()
					-- 	end
					-- end

					-- if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
					-- 	performWithDelay(self,func,9):setTag(123)

					-- 	performWithDelay(self,function() GameConfig:switchUrl() self:requestGameVersionInfo() end,3):setTag(111)--第一次
					-- end
					self:requestGameVersionInfo()
				end
			end
			return
		end
	-- end

	local url = GameConfig.tuiguanUrl.."/Public/PublicHandler.ashx?action=getupdateurl&agentid="..channelID.."&num="..pkgNum
	HttpUtils:requestHttp(url,handler(self,self.reqestWebHotUpdateUrlCallback))
end

function WelcomeLayer:reqestWebHotUpdateUrlCallback(result, response)
	if result == false then
		self:reqestWebHotUpdateUrl()
	else
		try({
			function() 
				local domain = json.decode(response)
				if tonumber(domain.State) == 1 then
					local domain = clone(domain.Value)

					cc.UserDefault:getInstance():setStringForKey("hotUpdate",self:createCheckCode(TableToStr(domain)))
					GameConfig.domain = domain
					-- self:stopAllActions()
					GameConfig:switchUrl()
					-- self.requestCount = 0

					-- local func = function()
					-- 	if self.isEndStart ~= true then
					-- 		self.isEndStart = true
					-- 		NO_UPDATE = true
					-- 		isRepairUpate = true
					-- 		gameStart()
					-- 	end
					-- end

					-- if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
					-- 	performWithDelay(self,func,9):setTag(123)

					-- 	performWithDelay(self,function() GameConfig:switchUrl() self:requestGameVersionInfo() end,3):setTag(111)--第一次
					-- end
				end
			end,
			catch=function(error)
				print("local hotUpdate callback error ",error)
			end,
			finally=function()
				self:requestGameVersionInfo()
			end
		})
	end
end

--获取游戏版本信息
function WelcomeLayer:requestGameVersionInfo()
	-- if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
		self.requestCount = self.requestCount + 1
		print("self.requestCount ",self.requestCount,GameConfig:getGameConfigUrl())
		if self.requestCount == 2 then--第一次失败切换域名
			self:stopActionByTag(111)
		end

		if self.requestCount > 3 then
			print("isEndStart",isEndStart)
			if self.isEndStart ~= true then
				self.requestCount = 0
				print("启动超级盾")
				self:gameStart()
			end
			return
		end
	-- end

	HttpUtils:requestHttp(GameConfig:getGameConfigUrl(),handler(self, self.responseGameVersionCallback))
end

function WelcomeLayer:gameStart()
	-- if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
		self.requestCount = self.requestCount + 1
		print("超级盾 ",self.requestCount)
		if self.requestCount == 2 then--第一次失败切换域名
			self:stopActionByTag(111)
		end

		if self.requestCount > 1 then
			if self.isEndStart ~= true then
				if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
					self.isEndStart = true
					self:stopAllActions()
					NO_UPDATE = true
					isRepairUpate = true
					gameStart()
				else
					self.requestCount = 0
					self:requestGameVersionInfo()
				end
			end
			return
		end
	-- end

	isGetHotUpdate = true
	if initNet() == true then
		isGetHotUpdate = nil
		self:reqestWebHotUpdateUrl()
		return
	end

	performWithDelay(self,function() self:gameStart() end,9):setTag(111)--第一次
end

function WelcomeLayer:responseGameVersionCallback(result, response)
	if tolua.isnull(self) then
		return
	end

	if result == false then
		HttpUtils:showError()
		GameConfig:switchUrl()

		self:requestGameVersionInfo()
		return
	else
		if self.isEndStart == true then
			return
		end
		self.isEndStart = true
		self:stopAllActions()
		GameConfig.serverVersionInfo = json.decode(response)
		dump(GameConfig.serverVersionInfo,"服务器版本配置信息")

		GameConfig.serverZipVersionInfo = {}

		GameConfig.serverZipVersionInfo.gameListInfo = GameConfig.serverVersionInfo.zipVersions
		dump(GameConfig.serverZipVersionInfo,"服务器zip版本配置信息")

		GameConfig.configInfo = {}
		GameConfig.configInfo.kefuUrl = GameConfig.serverVersionInfo["kefuUrl"..channelID]
		GameConfig.configInfo.yuming = GameConfig.serverVersionInfo["houtaiyuming"..channelID]
		GameConfig.configInfo.serverState = GameConfig.serverVersionInfo.serverState
	end

	GameConfig.appVerUrl = GameConfig.serverVersionInfo.androidUrl
	--根据服务器配置，设置ios审核控制状态
	if device.platform == "ios" then
		if localAppVersion == GameConfig.serverVersionInfo.iosReviewVer then
			appleView = 1
		else
			appleView = 0
		end
		GameConfig.appVerUrl = GameConfig.serverVersionInfo.iosUrl
	else
		appleView = 0
	end

	-- local func = function() 
	-- 	if self.isEndStart ~= true then
	-- 		self.isEndStart = true
	-- 		NO_UPDATE = true
	-- 		gameStart()
	-- 	end
	-- end

	-- self.requestCount = 0
	-- self.isEndStart = false
	-- if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
	-- 	self:stopActionByTag(123)
	-- 	performWithDelay(self,func,9):setTag(123)

	-- 	performWithDelay(self,function() self:requestConfig() end,3):setTag(111)--第一次
	-- end
	-- self:requestConfig()

	gameUpdate()
end

function WelcomeLayer:requestZipVersion()
	if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
		self.requestCount = self.requestCount + 1

		if self.requestCount == 2 then--第一次失败切换域名
			self:stopActionByTag(111)
		end

		if self.requestCount > 4 then
			self:stopAllActions()
			NO_UPDATE = true
			gameStart()
			return
		end
	end

	local url = "http://"..GameConfig.md5Url.."/download/"..gameName.."/"..channelID.."/zipVersions.txt"

	if runMode == "release" then
		url = GameConfig.md5Url.."/"..gameName.."/"..channelID.."/zipVersions.txt"
	end

	HttpUtils:requestHttp(url,handler(self, self.responseZipVersionCallback))
end

function WelcomeLayer:responseZipVersionCallback(result, response)
	if tolua.isnull(self) then
		return
	end

	if result == false then
		HttpUtils:showError()
		GameConfig:switchUrl()

		self:requestZipVersion()
		return
	else
		self:stopAllActions()

		GameConfig.serverZipVersionInfo = json.decode(response)
		dump(GameConfig.serverZipVersionInfo,"服务器zip版本配置信息")
	end

	self:requestConfig()
end

function WelcomeLayer:requestConfig()
	-- if cc.UserDefault:getInstance():getBoolForKey("checkCount",false) then
		self.requestCount = self.requestCount + 1

		if self.requestCount == 2 then--第一次失败切换域名
			self:stopActionByTag(111)
		end

		if self.requestCount > 3 then
			if self.isEndStart ~= true then
				self.isEndStart = true
				self:stopAllActions()
				gameUpdate()
			end
			return
		end
	-- end

	local url = "http://"..GameConfig.md5Url.."/download/"..gameName.."/config.json"

	if runMode == "release" then
		-- url = GameConfig.md5Url.."/"..gameName.."/config.json"
		url = "http://"..GameConfig.configInfo.yuming.."/config.json"
	end

	HttpUtils:requestHttp(url,handler(self, self.responseConfigCallback))
end

function WelcomeLayer:responseConfigCallback(result, response)
	if tolua.isnull(self) then
		return
	end

	self:stopActionByTag(111)

	if result == false then
		HttpUtils:showError()
		-- GameConfig:switchUrl()

		self:requestConfig()
		return
	else
		self:stopAllActions()
		self.isEndStart = true

		GameConfig.configInfo = json.decode(response)
		GameConfig.configInfo.serverState = tonumber(GameConfig.configInfo.serverState)
		dump(GameConfig.configInfo,"服务器web配置信息")
	end

	gameUpdate()
end

--获得APP版本号
function WelcomeLayer:getAppVersion()
	if device.platform == "ios" then
		local ok,ret  = require("cocos.cocos2d.luaoc").callStaticMethod("MethodForLua","getVersion")
		if ok == false then
			print("luaoc调用出错:getVersion")
		else
			return ret
		end
	elseif device.platform == "android" then
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "getVersion"
		local javaParams = { }
		local javaMethodSig = "()Ljava/lang/String;"
		local ok,ret  = require("cocos.cocos2d.luaj").callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
		if ok == false then
			print("luaj调用出错 getVersion")
		else
			return ret
		end
	else
		print("getVersion!")
	end

	return "1.0.0"
end

function WelcomeLayer:clearOldResources()
	-- local rootPath = {"cachePath/","res/","src/"};
	-- local writePath = cc.FileUtils:getInstance():getWritablePath();

	-- for k,v in pairs(rootPath) do
	-- 	local path1 = writePath..v;
	-- 	if cc.FileUtils:getInstance():isDirectoryExist(path1) then
	-- 		cc.FileUtils:getInstance():removeDirectory(path1);
	-- 		if cc.FileUtils:getInstance():isDirectoryExist(path1) then
	-- 			print("WelcomeLayer path1 ="..path1.."删除失败");
	-- 		else
	-- 			print("WelcomeLayer path1 ="..path1.."删除成功");
	-- 		end
	-- 	else
	-- 		print("WelcomeLayer path1 ="..path1.."不存在，无需删除");
	-- 	end
	-- end

	--重新启动
	-- unloadAllRequire()
	loadScript("src/script/main")
end

return WelcomeLayer
