local RestartDownLayer = class("RestartDownLayer", BaseWindow)

function RestartDownLayer:create()
	return RestartDownLayer.new()
end

function RestartDownLayer:ctor()
	self.super.ctor(self)
	self:bindEvent()
end

function RestartDownLayer:bindEvent()
	self:pushGlobalEventInfo("restartDownloadSuccess",handler(self, self.onReceiveRestartDownloadSuccess))
	self:pushGlobalEventInfo("reqestHotUpdate",handler(self, self.reqestWebHotUpdateUrl))
end

function RestartDownLayer:onEnter()
	self.super.onEnter(self)
	localAppVersion = self:getAppVersion()
	self.requestCount = 0
	self.requestCountHot = 0

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

	self:requestGameVersionInfo()
end

--获取游戏版本信息
function RestartDownLayer:requestGameVersionInfo()
	self.requestCount = self.requestCount + 1
	luaPrint("重启下载请求",self.requestCount)
	HttpUtils:requestHttp(GameConfig:getGameConfigUrl(),handler(self, self.responseGameVersionCallback))
end

function RestartDownLayer:responseGameVersionCallback(result, response)
	if result == false then
		HttpUtils:showError()
		if self.requestCount >= 3 then
			if SettlementInfo:getConfigInfoByID(serverConfig.hotUpdateUrl) ~= 0 then
				GameConfig.md5Url = SettlementInfo:getConfigInfoByID(serverConfig.hotUpdateUrl)
				isDownHall = true
				luaPrint("后台配置热更拯救域名为 ",GameConfig.md5Url)
			else
				luaPrint("后台没有配置热更拯救域名")
				local url = cc.UserDefault:getInstance():getStringForKey("hotUpdate","")
				if isEmptyString(url) then
					self.requestCountHot = 0
					self:requestQsu()
					return
				end
				GameConfig:switchUrl()
			end
		else
			GameConfig:switchUrl()
		end

		self:requestGameVersionInfo()
		return
	else
		GameConfig.serverVersionInfo = json.decode(response)
		luaDump(GameConfig.serverVersionInfo,"服务器版本配置信息")

		GameConfig.serverZipVersionInfo = {}

		GameConfig.serverZipVersionInfo.gameListInfo = GameConfig.serverVersionInfo.zipVersions
		luaDump(GameConfig.serverZipVersionInfo,"服务器zip版本配置信息")

		GameConfig.configInfo = {}
		GameConfig.configInfo.kefuUrl = GameConfig.serverVersionInfo.kefuUrl
		GameConfig.configInfo.yuming = GameConfig.serverVersionInfo.houtaiyuming
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

	local ret = self:checkUpdateVersion()
	luaPrint("版本比较结果 ret = "..ret.." GameConfig.serverVersionInfo.serverState = "..GameConfig.serverVersionInfo.serverState)

	if ret == 2 then--强更
		luaPrint("强更")
		layer = require("layer.popView.UpdateLayer"):create()
		layer:setLocalZOrder(gameZorder+9999)
		display.getRunningScene():addChild(layer)
	else
		--重启下载
		Hall:startDownload()
	end
end

--获得APP版本号
function RestartDownLayer:getAppVersion()
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
		local javaParams = { }
		local javaMethodSig = "()Ljava/lang/String;"
		local ok,ret  = require("cocos.cocos2d.luaj").callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
		if ok == false then
			luaPrint("luaj调用出错 getVersion")
		else
			return ret
		end
	else
		luaPrint("getVersion!")
	end

	return "1.0.0"
end

function RestartDownLayer:onReceiveRestartDownloadSuccess()
	luaPrint("重启下载完成")
	NO_UPDATE = false
	globalUnit.isRestartDown = false
	isCheckRestartDownload = true
	isRepairUpate = nil
	dispatchEvent("restartDownload")
	isUpdateUserInfo = nil
	updateUserInfo()
	self:removeSelf()
end

--检测app是否升级
function RestartDownLayer:checkUpdateVersion()
	if device.platform == "windows" then
		return 1
	end

	local curVer = GameConfig.serverVersionInfo.androidVer
	local localVer = string.gsub(localAppVersion,"%D","")

	if device.platform == "ios" then
		curVer = GameConfig.serverVersionInfo.iosVer
	end

	curVer = string.gsub(curVer,"%D","")

	--版本一样
	if curVer == localVer then
		return 0
	end

	local count = math.abs(#curVer-#localVer)

	if #curVer < #localVer then
		for i=1,count do
			curVer = curVer.."0"
		end
	else
		for i=1,count do
			localVer = localVer.."0"
		end
	end

	if tonumber(curVer) > tonumber(localVer) then
		return 2
	else
		return 1
	end
end

function RestartDownLayer:requestQsu()
	print("超级盾 获取")

	isGetHotUpdate = true
	if initNet() == true then
		isGetHotUpdate = nil
		self:reqestWebHotUpdateUrl()
		return
	end

	performWithDelay(self,function() self:requestGameVersionInfo() end,9):setTag(1111)--第一次
end

function RestartDownLayer:reqestWebHotUpdateUrl()
	self.requestCountHot = self.requestCountHot + 1

	self:stopActionByTag(1111)
	print("self.requestCountHot ",self.requestCountHot)
	if self.requestCountHot > 2 then
		self.requestCountHot = 0
		self.requestCount = 0
		self:requestGameVersionInfo()
		return
	end

	local url = GameConfig.tuiguanUrl.."/Public/PublicHandler.ashx?action=getupdateurl&agentid="..channelID.."&num="..pkgNum
	HttpUtils:requestHttp(url,handler(self,self.reqestWebHotUpdateUrlCallback))
end

function RestartDownLayer:reqestWebHotUpdateUrlCallback(result, response)
	if result == false then
		self:reqestWebHotUpdateUrl()
	else
		try({
			function() 
				local domain = json.decode(response)
				if tonumber(domain.State) == 1 then
					local domain = clone(domain.Value)
					luaDump(domain,"domain")

					cc.UserDefault:getInstance():setStringForKey("hotUpdate",encodeBase64(TableToStr(domain)))
					GameConfig.domain = domain
					GameConfig:switchUrl()
				end
			end,
			catch=function(error)
				print("restart local hotUpdate callback error ",error)
			end,
			finally=function()
				self.requestCount = 0
				self:requestGameVersionInfo()
			end
		})
	end
end

return RestartDownLayer
