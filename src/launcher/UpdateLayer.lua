local UpdateLayer = class("UpdateLayer",function() return display.newLayer() end)

function UpdateLayer:scene(updateType)
	local updateLayer = UpdateLayer:create(updateType)

	local scene = display.newScene()
	scene:addChild(updateLayer)

	display.runScene(scene)
end

function UpdateLayer:create(updateType)
	return UpdateLayer.new(updateType)
end

function UpdateLayer:ctor(updateType)
	self:setLayerNodeEvent()

	self.updateType = updateType --默认单文件更新

	self:initUI()
end

function UpdateLayer:setLayerNodeEvent()
	local function onNodeEvent(eventName)
		if "enter" == eventName then
			self:onEnter()
		elseif "exit" == eventName then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

function UpdateLayer:initUI()
	local node = cc.CSLoader:createNode("updateLayer.csb")
	node:setCascadeOpacityEnabled(true)
	self:addChild(node)

	local bg = node:getChildByName("Image_bg")
	bg:loadTexture("common/bg.png")

	iphoneXFit(bg)

	self.curTextInfo = "正在下载资源"
	--更新百分比
	self.updateTextInfo = bg:getChildByName("Text_info")
	self.updateTextInfo:setString("正在检查游戏中.")
	self.updateTextInfo:setTag(1)
	-- schedule(self.updateTextInfo, function() self:updateUpdateTextInfo() end, 1)
	self.updateTextInfo:removeSelf()

	self.loadingBarBg = bg:getChildByName("Image_lineBg")
	self.loadingBar = self.loadingBarBg:getChildByName("LoadingBar_line")
	self.loadingBarBg:hide()

	self.percentLabel = bg:getChildByName("Text_percent")
	self.percentLabel:hide()

	local btnXiufu = bg:getChildByName("Button_yijianxiufu")
	if btnXiufu then
		btnXiufu:hide()
		btnXiufu:addClickEventListener(function(sender) self:clearOldResources() end)
	end

	local image = ccui.ImageView:create("gameUpdate/logo.png")
	image:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
	bg:addChild(image)

	local image = ccui.ImageView:create("gameUpdate/info.png")
	image:setPosition(bg:getContentSize().width/2,0)
	image:setAnchorPoint(0.5,0)
	bg:addChild(image)

	-- if self.updateType then
		local label = cc.Label:createWithSystemFont(self.curTextInfo, "Arial", 26)
		self.loadingBar:addChild(label)
		label:setPosition(self.loadingBar:getContentSize().width/2,self.loadingBar:getContentSize().height/2+30)
		self.downInfoLabel = label
		-- schedule(self.downInfoLabel, function() self:updateUpdateTextInfo() end, 1)
		label:hide()
	-- end

	local cv = getAppConfig("BundleVersionDate")

	if isEmptyString(cv) then
		cv = "0"
	end

	local text = "Appv "..tostring(localAppVersion).."   Resv "..tostring(GameConfig:getLuaVersion(gameName).."   Appcv "..tostring(cv))
	local winSize = cc.Director:getInstance():getWinSize()
	local tip = FontConfig.createWithSystemFont(text,18,FontConfig.colorWhite)
	tip:setAnchorPoint(0,0.5)
	tip:setPosition(cc.p(15,winSize.height-15))
	self:addChild(tip)
end

function UpdateLayer:onEnter()
	self.globalBindCustomIds = {}
	self.globalBindCustomIds[#self.globalBindCustomIds + 1] = bindGlobalEvent("downFileFail",handler(self, self.downFileFail))

	--版本检测
	local ret = self:checkUpdateVersion();
	luaPrint("版本比较结果 ret = "..ret.." GameConfig.serverVersionInfo.serverState = "..GameConfig.serverVersionInfo.serverState)

	local server = GameConfig.serverVersionInfo.serverIosState

	if device.platform == "android" then
		server = GameConfig.serverVersionInfo.serverAndroidState
	end

	if server == nil then
		server = GameConfig.serverVersionInfo.serverState
	end

	if GameConfig.configInfo and server == 1 then--停服提示
		if self.downInfoLabel then
			self.downInfoLabel:stopAllActions()
			self.downInfoLabel:setString("游戏正在维护,请等待维护完毕再进入")
		end
		isStopService = true
		self:downloadFinish()
		return
	end

	if ret == 2 then--强更
		luaPrint("强更")
		isShowUpdate = true
		-- self:showWindow("发现新版本，请前往官网更新",function() cc.Application:getInstance():openURL(GameConfig.appVerUrl) end)
		self:downloadFinish()
		return
	else
		ret = self:checkVersionComplieUpdate()
		luaPrint("编译时间版本比较 ret = ",ret)

		if ret == 2 then
			luaPrint("编译时间 强更")
			isShowUpdate = true
			self:downloadFinish()
			return
		end
	end

	--正常更新
	self.downInfoLabel:stopAllActions()
	self.downInfoLabel:setTag(1)
	self.downInfoLabel:setString(self.curTextInfo)
	-- schedule(self.downInfoLabel, function() self:updateUpdateTextInfo() end, 1)

	self:startDownload()
end

function UpdateLayer:checkVersionComplieUpdate()
	if device.platform == "windows" then
		return 1
	end

	local localAppVersion = getAppConfig("BundleVersionDate")
	luaPrint("localAppVersion ",localAppVersion)

	if not isEmptyString(localAppVersion) then
		localAppVersion = string.split(localAppVersion,".")
	else
		localAppVersion = {"0"}
	end

	local curVer = GameConfig.serverVersionInfo.androidVersionDate
	local localVer = localAppVersion

	if device.platform == "ios" then
		curVer = GameConfig.serverVersionInfo.iosVersionDate
	end

	luaPrint("curVer ",curVer)

	if not isEmptyString(curVer) then
		curVer = string.split(curVer,".")
	else
		curVer = {"0"}
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
					return 1
				elseif vl < vc then
					return 2
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
				return 1
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
				return 2
			end
		end
	end

	return 0
end

function UpdateLayer:onExit()
	for _, bindid in ipairs(self.globalBindCustomIds) do
		unbindEvent(bindid)
	end

	self.globalBindCustomIds = {}
end

function UpdateLayer:updateUpdateTextInfo()
	local tag = self.downInfoLabel:getTag()

	tag = tag + 1

	if tag > 3 then
		tag = 1
	end

	local text = self.curTextInfo

	for i=1,tag do
		text = text.."."
	end

	self.downInfoLabel:setTag(tag)
	self.downInfoLabel:setString(text)
end

--检测app是否升级
function UpdateLayer:checkUpdateVersion()
	if device.platform == "windows" then
		return 1
	end

	local localVer = {"0"}

	if not isEmptyString(localAppVersion) then
		localVer = string.split(localAppVersion,".")
	end

	local curVer = GameConfig.serverVersionInfo.androidVer

	if device.platform == "ios" then
		curVer = GameConfig.serverVersionInfo.iosVer
	end

	if not isEmptyString(curVer) then
		curVer = string.split(curVer,".")
	else
		curVer = {"0"}
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
					return 1
				elseif vl < vc then
					return 2
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
				return 1
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
				return 2
			end
		end
	end

	return 0
end

--开始下载
function UpdateLayer:startDownload()
	if self.updateType then
		luaPrint("开始zip更新下载")
		self.updateManager = require("launcher.ClientUpdate"):getInstance()

		-- self.updateManager:setDelegate(self,self.updateDownloadProgress)
		self.updateManager:setDownloadListInfo({"child",self,
					function(finishNum,totalNum)  end,
					function() 
					self.updateManager:setDownloadListInfo({GameConfig.serverZipVersionInfo.gameListInfo[1].gameName,self,
					function(finishNum,totalNum) self:updateDownloadProgress(finishNum,totalNum,1) end,
					function() self:downloadFinish() end,function() self:downloadFinish() end,function(value) local temp = string.split(value,"_") self:updateUnZipProgress(tonumber(temp[1]),tonumber(temp[2])) end})
					
					self.updateManager:startDownload(GameConfig.serverZipVersionInfo.gameListInfo[1].gameName) end})
		self.updateManager:startDownload("child",true,function() self.updateManager:startDownload(GameConfig.serverZipVersionInfo.gameListInfo[1].gameName) end)
	else
		luaPrint("开始更新下载")
		self.updateManager = require("launcher.UpdateManager"):getInstance()
		self.updateManager:setDownloadListInfo({"hall",self,
			function(finishNum,totalNum) self:updateDownloadProgress(finishNum,totalNum) end,
			function() self:downloadFinish() end,function() self:downloadFinish() end})

		--提前下载子游戏MD5文件进行比较
		self:downAllChildGameMD5()
	end
end

function UpdateLayer:downAllChildGameMD5()
	for k,v in pairs(GameConfig.serverVersionInfo.gameListInfo) do
		self.updateManager:startDownload(v.gameName,true)
		break
	end
end

--下载完成，进入登录页
function UpdateLayer:downloadFinish()
	if self.updateType and not isShowUpdate and not isStopService then
		local gameName = self.updateManager.gameName

		for k,v in pairs(GameConfig.serverZipVersionInfo.gameListInfo) do
			if v.gameName == gameName then
				v.isDown = true
			end
		end

		local flag = false

		for k,v in pairs(GameConfig.serverZipVersionInfo.gameListInfo) do
			if v.isDown ~= true then
				flag = true
				gameName = v.gameName
				break
			end
		end

		flag = false--子游戏zip不在初始阶段下载

		if not flag then--下载完所有zip包
			local f = io.open(cc.FileUtils:getInstance():getWritablePath().."/cache/zipVersions.txt", 'wb')

			if f then
				f:write(json.encode(GameConfig.serverZipVersionInfo))
				f:close()
			end

			luaPrint("单文件更新检查")
			-- if GameConfig:getLuaVersion("hall") > 210 then
				luaPrint("下载完成，进入登录页...........")
				dispatchEvent("removeUpdateNotify",{GameConfig.dbSourceName,self})
				gameStart()
			-- else
				-- self.updateManager:setDelegate(nil)
				-- luaPrint("下载完成，进入登录页...........")
				-- dispatchEvent("removeUpdateNotify",{GameConfig.dbSourceName,self})
				-- gameStart()
				-- self.updateManager.destroyInstance()
				-- loadScript("launcher.UpdateLayer"):scene()
			-- end
		else
			luaPrint("下载 zip	",gameName)
			self.updateManager:startDownload(gameName)
		end
	else
		luaPrint("下载完成，进入登录页")
		dispatchEvent("removeUpdateNotify",{GameConfig.dbSourceName,self})
		gameStart()
	end
end

function getSize(size)
	local unit = "";
	local tsize = "";
	if (size > 1024 * 1024 * 1024) then
		unit = "G";
		size = size / (1024 * 1024 * 1024);
	elseif (size > 1024 * 1024) then
		unit = "M";
		size = size / (1024 * 1024);
	elseif (size > 1024) then
		unit = "KB";
		size = size / 1024;
	end
	tsize = string.format("%.1f",size)
	return tsize..unit;
end

function UpdateLayer:updateZipProgress(downInfo)
	if self.updateType then
		-- self.updateTextInfo:hide()
		luaDump(downInfo,"downInfo")
		-- self:updateDownloadProgress(downInfo[1]/100)

		if self.downInfoLabel then
			self.downInfoLabel:show()
			self.curTextInfo = "正在下载资源"
			-- self.downInfoLabel:setString("正在下载资源(下载速度: "..downInfo[4].." 剩余: "..getSize(downInfo[3]-downInfo[2])..")")
			self.downInfoLabel:setString(self.curTextInfo..":"..string.format("%d",downInfo[1]/100).."%")
		end
	end
end

function UpdateLayer:updateUnZipProgress(mainID,result)
	if mainID == 6 then
		if self.downInfoLabel then
			if result == 1 then
				self.downInfoLabel:setString("解压完成")
				performWithDelay(self, function() self:downloadFinish(); end, 0.05)
				-- self:downloadFinish()
			elseif result == 0 then
				-- self.downInfoLabel:setString("解压失败,重新下载")
				-- cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath()..gameName..".zip")
				-- for i=1,threadCount do
				-- 	local path = cc.FileUtils:getInstance():getWritablePath().."temp/"..i..gameName..".zip"
				-- 	cc.FileUtils:getInstance():removeFile(path)
				-- end
				-- self.updateManager:updateDownLoadList(gameName,"downloadState",STATUE_HAVEUPDATE)
				self.updateManager:startDownload(GameConfig.serverZipVersionInfo.gameListInfo[1].gameName)
			end
		end
	elseif mainID == 5 then
		if self.downInfoLabel then
			self.downInfoLabel:show()
		end
		self.downInfoLabel:setString("正在解压中,请勿关闭应用,耐心等候..(解压过程无需流量) "..result.."%")
		self.loadingBar:setPercent(result)
	end
end

--更新下载进度条
function UpdateLayer:updateDownloadProgress(finishNum,totalNum,iType)
	local percent = 0
	local text = ""

	-- if self.updateType ~= nil then
	-- 	percent = tonumber(finishNum)
	-- 	text = string.format("%.1f%%", percent)
	-- else
		percent = finishNum/totalNum

		if percent > 1 then
			percent = 1
		end

		local text = string.format("%.1f%%", percent * 100)

		if iType ~= nil then
			text = string.format("%d%%", percent * 100)
		end

		if percent == 1 then
			text = "100%"
		end

		percent =  math.floor(100 * percent)

		if not self.percentLabel:isVisible() then
			-- self.percentLabel:show()
			self.downInfoLabel:show()
			self.loadingBarBg:show()
		end
		self.curTextInfo = "正在下载资源"
		self.downInfoLabel:setString(self.curTextInfo..":"..text)
	-- end

	-- if percent > self.loadingBar:getPercent() then
		self.percentLabel:setString(text)
		self.loadingBar:setPercent(percent)
	-- end
end

--强更提示
function UpdateLayer:showWindow(msg,callback)
	local layer = display.newLayer()
	layer:setName("prompt")
	self:addChild(layer)

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

	local btnOk = ccui.Button:create("common/ok.png","common/ok_on.png")
	btnOk:setPosition(size.width/2, 70)
	btnOk:setAnchorPoint(0.5, 0)
	bg:addChild(btnOk)
	btnOk:addClickEventListener(function()
		local node = self:getChildByName("prompt")

		if node then
			node:removeFromParent()
		end

		self:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.2), 
			cc.CallFunc:create(
				function() 
					if callback then
						callback()
					end
			end)))
	end)
end

function UpdateLayer:downFileFail(data)
	local data = data._usedata

	-- if data == "hall" then
	luaPrint("大厅 更新 失败 "..data)
	if PlatformLogic and PlatformLogic.loginResult and PlatformLogic.loginResult.dwUserID then
	else
		local writePath = cc.FileUtils:getInstance():getWritablePath()
		local func = function()
			local rootPath = {"res/"..data,"src/"..data,"src/common","src/launcher","src/script"}

			if cc.FileUtils:getInstance():isFileExist(writePath.."cache/old"..data..".txt") then
				cc.FileUtils:getInstance():removeFile(writePath.."cache/old"..data..".txt")
			end

			-- for k,v in pairs(rootPath) do
			-- 	local path1 = writePath..v;
			-- 	if cc.FileUtils:getInstance():isDirectoryExist(path1) then
			-- 		cc.FileUtils:getInstance():removeDirectory(path1);
			-- 		if cc.FileUtils:getInstance():isDirectoryExist(path1) then
			-- 			luaPrint("main updateLayer path1 ="..path1.."删除失败");
			-- 		else
			-- 			luaPrint("main updateLayer path1 ="..path1.."删除成功");
			-- 		end
			-- 	else
			-- 		luaPrint("main updateLayer path1 ="..path1.."不存在，无需删除");
			-- 	end
			-- end

			-- for _, bindid in ipairs(self.globalBindCustomIds) do
			-- 	unbindEvent(bindid)
			-- end

			-- self.globalBindCustomIds = {}

			self.updateManager:resetDwon(data)
			-- unloadAllRequire()
			-- loadScript("src/script/main")
			self.updateManager:setDownloadListInfo({"hall",self,
				function(finishNum,totalNum) self:updateDownloadProgress(finishNum,totalNum) end,
				function() self:downloadFinish() end,function() self:downloadFinish() end})
			self.updateManager:updateDownLoadList("hall","isCanDown",true)
			self.updateManager:startDownload("hall")
		end

		if self.updateType == 1 then
			self.updateManager:startDownload(data)
		else
			func()
		end
	end
end

return UpdateLayer
