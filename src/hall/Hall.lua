package.path = package.path .. ";common/?.lua"

--逻辑控制模块
package.loaded["platform.RegisterFunction"] = nil
package.loaded["platform.UnitedPlatform"] = nil
package.loaded["tools.tools"] = nil
package.loaded["tools.improve"] = nil

require("common.BaseCommand")
loadScript("logic.Const")
loadScript("common.CommonFunc")

globalUnit = require("tools.globalUnit")
FontConfig = loadScript("common.UI.FontConfig")

HttpUtils = loadScript("common.http.HttpUtils")
SocialUtils = require("common.http.SocialUtils")
ComStruct = require("net.netMessage.ComStruct")

QukuailianMsg = require("qukuailian.QukuailianMsg")
VipMsg = require("hall.layer.popView.newExtend.vip.VipMsg")
ImMsg = require("net.netMessage.ImMsg")
UserLogoMsg = require("net.netMessage.UserLogoMsg")
PlatformMsg = require("net.netMessage.PlatformMsg")
RoomMsg = require("net.netMessage.RoomMsg")
VoiceChatMsg = require("net.netMessage.VoiceChatMsg")
bit = require("logic.roomLogic.bit")
ui = require("common.ui")
require("common.View")

require("common.platformDefine")
require("tools.improve")
require("common.tools.BindTool")
require("net.ProtocolUtil")
require("platform.PlatformFunction")
require("common.base64")

-- sdk控制添加
if checkVersion() ~= 2 then
	isUseNetSDK = false
else
	if device.platform == "ios" then
		if GameConfig.serverVersionInfo.isIosSDK == 1 then
			isUseNetSDK = true
		elseif GameConfig.serverVersionInfo.isIosSDK == 0 then
			isUseNetSDK = false
			isYouxidun = false
		else
			isUseNetSDK = true
		end

		if GameConfig.serverVersionInfo.yuming ~= "" and GameConfig.serverVersionInfo.yuming ~= nil then
			GameConfig.A_SERVER_IP = GameConfig.serverVersionInfo.yuming
		end
	elseif device.platform == "android" then
		if GameConfig.serverVersionInfo.isAndroidSDK == 1 then
			isUseNetSDK = true
		elseif GameConfig.serverVersionInfo.isAndroidSDK == 0 then
			isUseNetSDK = false
			isYouxidun = false
		else
			isUseNetSDK = true
		end

		if GameConfig.serverVersionInfo.yuming ~= "" and GameConfig.serverVersionInfo.yuming ~= nil then
			GameConfig.A_SERVER_IP = GameConfig.serverVersionInfo.yuming
		end
	end

	isGetHotUpdate = nil
end

--单例
PlatformLogic = require("net.platform.PlatformLogic"):getInstance()
RoomLogic = require("net.room.RoomLogic"):getInstance()
Event = require("common.Event").new()
UserInfoModule = require("net.netData.UserInfoModule"):getInstance()
GamesInfoModule = require("net.netData.GamesInfoModule"):getInstance()
GameCreator = require("net.platform.GameCreator"):getInstance()
RoomInfoModule = require("net.netData.RoomInfoModule"):getInstance()
GameDate = require("layer.GameDate"):getInstance()
HeadManager = require("common.http.HeadManager"):getInstance()
UpdateManager =require("launcher.UpdateManager"):getInstance()
PlatformRegister = require("logic.platformLogic.PlatformRegister")

--UI
BaseNode = require("layer.BaseNode")
BaseWindow = require("layer.BaseLayer")
PopLayer = require("layer.PopLayer")
LoadingLayer = require("UI.LoadingLayer")
GamePromptLayer = require("UI.GamePromptLayer")
LoginLayer = require("layer.LoginLayer")
HallLayer = require("layer.HallLayer")
MessageNotify = require("platform.MessageNotify")
LibRoomVoice = require("platform.LibRoomVoice")
GameMessageLayer = require("UI.GameMessageLayer")

BankInfo = require("dataModel.platform.BankInfo")
YuEBaoInfo = require("dataModel.platform.YuEBaoInfo")
MailInfo = require("dataModel.platform.MailInfo")
MoneyInfo = require("dataModel.platform.MoneyInfo")
ExtendInfo = require("dataModel.platform.ExtendInfo")
SettlementInfo = require("dataModel.platform.SettlementInfo")
LuckyInfo = require("dataModel.platform.LuckyInfo")
SignInInfo = require("hall.layer.popView.activity.SignIn.SignInInfo")
PartnerInfo = require("dataModel.platform.PartnerInfo")
VipInfo = require("hall.layer.popView.newExtend.vip.VipInfo")
GeneralizeInfo = require("hall.layer.popView.newExtend.newGeneralize.GeneralizeInfo");

iswxInstall = false
--消息类型
REAL_DATA = 100
FALSE_DATA = -1
laba_DATA = 0
MESSAGE_ROLL = 1 --全局滚动消息
MESSAGE_GLOBAL = 2 --全局提示消息
--模式  true 游戏列表模式 false 房间模式
isGameMode = false

--捕到大鱼鱼消息
fishMessage = {}

--网络端口注册
NetPortRegister = {}

--控制模块
Hall = class("Hall")

function Hall:ctor()
	self:loadUpdateManager()

	self:init()
end

function Hall:init()
	globalUnit:init()

	--获取userid channel
	getInternetIP()
	getOpenInstall()

	SocialUtils:init()
	BankInfo:init()
	YuEBaoInfo:init()
	MailInfo:init()
	MoneyInfo:init()
	ExtendInfo:init()
	SettlementInfo:init()
	LuckyInfo:init()
	SignInInfo:init()
	PartnerInfo:init()
	VipInfo:init()
	GeneralizeInfo:init()

	if checkVersion("1.0.0") == 2 then
		onUnitedPlatformInitJiGuangSDK()
	end

	registerWx()

	self.savePackagePath = package.path 
	self.saveSearchPath = cc.FileUtils:getInstance():getSearchPaths()

	printMemoryInfo()
	self:clearNewScrollMessage()
	isCloseQSu = false
end

function Hall.exitHall()
	if schedulerQr then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerQr)
		schedulerQr = nil
	end

	isShowAccountUpgrade = nil
	-- cc.UserDefault:getInstance():setStringForKey(PASSWORD_TEXT, "")
	PlatformLogic.loginResult = {}
	local temp = globalUnit.gameChannel
	local temp1 = globalUnit.registerInfo.referee
	globalUnit:init()
	globalUnit.gameChannel = temp
	globalUnit.registerInfo.referee = temp1
	-- globalUnit:setLoginType(guestLogin)
	isRunAutoLogin = true
	pasteFromClipBoard()
	Hall.startGame()
end

function Hall.startGame()
	SocialUtils:init()
	PlatformLogic:close()
	RoomLogic:close()
	audio.stopMusic()
	RoomLogic:stopCheckNet()
	Hall:directExitGame()
	GamesInfoModule:clear()
	LoadingLayer:removeLoading()
	display.runScene(LoginLayer:scene());
end

function Hall.enterPlatform()
	display.runScene(HallLayer:scene());
end

function Hall.returnPlatform()
	display.runScene(HallLayer:returnPlatform());
end

function Hall.returnPlatformDirectMatch()
	display.runScene(HallLayer:returnPlatformDirectMatch());
end

function Hall.startLoading(callback)
	display.runScene(LoadLayer:scene(callback));
end

--设置大厅中回房间
function Hall:setHallBackRoom(uNameId)
	self.backNameId = uNameId

	if uNameId == nil then
		self.lastBackGame = nil
		globalUnit:setIsBackRoom(false)
	end
end

function Hall:getHallBackRoom(uNameId)
	if uNameId ~= nil and uNameId ~= self.backNameId then
		return false
	end

	return self.backNameId
end

function Hall:resetSearchPath()
	cc.FileUtils:getInstance():setSearchPaths(self.saveSearchPath)
	package.path = self.savePackagePath
end

--isBack true 登陆返回房间 false 大厅返回房间 nil 正常进房间
function Hall:selectedGame(gameName,params,isBack)
	if gameName == nil then
		luaPrint("进入游戏异常")
		globalUnit.isEnterGame = false
		RoomLogic:close()
		RoomLogic:stopCheckNet()
		if HallLayer and HallLayer:getInstance() and not HallLayer:getInstance():isVisible() then
			HallLayer:getInstance():delayCloseLayer(0)
		end
		return
	end

	if not cc.FileUtils:getInstance():isFileExist("src/" .. gameName .. "/"..gameName..".luac") and not cc.FileUtils:getInstance():isFileExist("src/" .. gameName .. "/"..gameName..".lua") then
		globalUnit.isEnterGame = false
		RoomLogic:close()
		RoomLogic:stopCheckNet()
		if HallLayer and HallLayer:getInstance() and not HallLayer:getInstance():isVisible() then
			HallLayer:getInstance():delayCloseLayer(0)
			cc.UserDefault:getInstance():setStringForKey("sdkkey", sdkKey)
			globalUnit.isCheckSDK = true
			globalUnit.isRestartDown = true
			Hall.enterPlatform();
		else
			if runMode == "release" and NO_UPDATE == true and isCheckRestartDownload ~= true then
				addScrollMessage("正在检查更新")
			else
				addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."下载失败")
			end
		end
		return
	end

	self:resetSearchPath()
	package.path = package.path .. ";src/" .. gameName .. "/?.lua";

	local gamePath = gameName

	local game = require(gamePath)

	if not game then
		addScrollMessage("此游戏暂未开放!")
		return
	end

	if isBack ~= nil then
		game.step = 2
	end

	self:clearNewScrollMessage()

	game:start(params,isBack)

	local layer = game.pushLayer[#game.pushLayer]
	if layer and not tolua.isnull(layer) then
		dispatchEvent("loginRoom")
		if layer:getName() == "gameLayer" then-- and not GamesInfoModule:isMatchMode() then
			if globalUnit.isTryPlay == true and isBack == nil and globalUnit.isShowTryPlay == nil then
				globalUnit.isShowTryPlay = true
				GamePromptLayer:create(1):showPrompt("体验场每次进入都会提供10W金币供您体验，退出房间后清零",true)
			end
		elseif layer:getName() == "deskLayer" and game.step == 2 then
			if RoomLogic:getSelectedRoom().isTryPlay == true then
				globalUnit.isTryPlay = true
			else
				globalUnit.isTryPlay = false
			end

			if globalUnit.isTryPlay == true and isBack ~= false then
				GamePromptLayer:create(1):showPrompt("体验场每次进入都会提供10W金币供您体验，退出房间后清零",true)
			end
		elseif globalUnit.isTryPlay == true and globalUnit.isEnterGame ~= true and layer:getName() == "mGameLayer" and GamesInfoModule:isMatchMode() then
			-- GamePromptLayer:create(1):showPrompt("体验场每次进入都会提供10W金币供您体验，退出房间后清零",true)
		end
	end

	if isBack ~= false then
		self.lastGame = game
	else
		self.lastBackGame = game
	end
end

function Hall:exitGame(isShowTips,callback,dt)
	if isShowTips == nil then
		isShowTips = false
	end

	local root = cc.Director:getInstance():getRunningScene()

	local node = root:getChildByTag(1421)
	if node then
		RoomLogic:close()
		RoomLogic:stopCheckNet()
		node:delayCloseLayer(0)
	end

	local game = nil
	local uNameId = 0
	local plistName = nil
	if self.lastBackGame then
		game = self.lastBackGame
		uNameId = self:getHallBackRoom()
	else
		game = self.lastGame
		uNameId = GameCreator:getCurrentGameNameID()
	end

	if game then
		plistName = game.plistName
		local layer = game.pushLayer[#game.pushLayer]
		if layer and not tolua.isnull(layer) then
			local gameInfo = GamesInfoModule:findGameName(uNameId)

			local name = layer:getName()

			if name == "gameLayer" and globalUnit.nowTingId > 0 then--VIP厅游戏出来
				VipInfo:sendGuildSendMoneyReq();
			end

			local func = function()
				if layer.tableLogic then
					layer.tableLogic:clear()
				end
				closeGameOpenHallLayer()
				if not RoomLogic:isConnect() then
					RoomLogic:stopCheckNet()
				end
				dispatchEvent("pushMessage",1)
				GamePromptLayer:remove()
				game:exitGame(0,callback)
				-- dispatchEvent("exitGameBackPlatform")
				self:clearGameData(uNameId,name,isShowTips,plistName)
			end

			-- if game.name == "errenniuniu" then--专为二人牛牛
			-- 	if globalUnit.isTryPlay == true then
			-- 		if isShowTips == 3 then--选桌退出
			-- 			local prompt = GamePromptLayer:create(1)
			-- 			prompt:showPrompt("您现在正在免费体验房间，退出房间后体验金币清零",true)
			-- 			prompt:setBtnClickCallBack(func)
			-- 			return
			-- 		elseif isShowTips == 2 then--超时
			-- 			func()
			-- 			if name == "gameLayer" then
			-- 				self:exitGame(isShowTips,callback,dt)
			-- 			end
			-- 			return
			-- 		end
			-- 	end
			-- end

			local gameName = game.name

			if isShowTips ~= true and name == "gameLayer" and globalUnit.isTryPlay == true then
				if not RoomLogic:isConnect() then
					RoomLogic:stopCheckNet()
					GamePromptLayer:remove()
					dispatchEvent("closeOutTime")
				end

				if isShowTips == 2 or not RoomLogic:isConnect() then--超时直接出去
					func()
					if isShowTips == 5 then--金币不足直接退出 二人牛牛
						RoomLogic:close()
						self:exitGame(isShowTips,nil,dt)
					else
						dispatchEvent("exitGameBackPlatform")
					end
				elseif isShowTips == false then
					local prompt = GamePromptLayer:create(1)
					prompt:showPrompt("您现在正在免费体验房间，退出房间后体验金币清零",true)
					prompt:setBtnClickCallBack(func,function() if isShowTips == 5 or not RoomLogic:isConnect()  then func() end end)--对战玩家站起点击关闭，也退出游戏
				else
					func()
				end
			else
				if isShowTips == true and RoomLogic:isConnect() and name == "gameLayer" then
					if string.find(gameInfo.szGameName,"dz") then
						local prompt = GamePromptLayer:create()
						if globalUnit.nowTingId>0 then
							prompt:showPrompt("本局游戏已开始，您不能退出房间哦！(VIP厅内游戏中途不可退出房间)",true,false)
						else
							prompt:showPrompt("正在游戏中，请稍后再试",true)
							-- prompt:setBtnClickCallBack(func)
						end
					elseif globalUnit.isTryPlay == true then
						local prompt = GamePromptLayer:create(1)
						prompt:showPrompt("您现在正在免费体验房间，退出房间后体验金币清零",true)
						prompt:setBtnClickCallBack(func)
					else
						layer.tableLogic:clear()
						closeGameOpenHallLayer()
						dispatchEvent("pushMessage",1)
						local node = display.getRunningScene():getChildByName("prompt")
						if node then
							node:delayCloseLayer(0)
						end
						game:exitGame(0,callback)
						-- dispatchEvent("exitGameBackPlatform")
						self:clearGameData(uNameId,name,isShowTips,plistName)
					end
				else
					if name == "gameLayer" then
						layer.tableLogic:clear()
						closeGameOpenHallLayer()
						dispatchEvent("pushMessage",1)
						local node = display.getRunningScene():getChildByName("prompt")
						if node then
							node:delayCloseLayer(0)
						end
					elseif isShowTips == false and layer:getName() == "mGameLayer" and globalUnit.isTryPlay == true then
						-- local prompt = GamePromptLayer:create(1)
						-- prompt:showPrompt("您现在正在免费体验房间，退出房间后体验金币清零",true)
						-- prompt:setBtnClickCallBack(func)
						func()
						return
					end

					game:exitGame(0,callback)
					self:clearGameData(uNameId,name,isShowTips,plistName)

					if name == "gameLayer" then
						-- if isShowTips == 5 and gameName == "errenniuniu" then--金币不足直接退出 二人牛牛
						-- 	RoomLogic:close()
						-- 	self:exitGame(isShowTips,nil,dt)
						-- else
							-- dispatchEvent("exitGameBackPlatform")
						-- end
					end
				end
			end
		else
			luaPrint("退出游戏异常22222")
		end
	else
		luaPrint("退出游戏异常")
	end
end

function Hall:clearGameData(uNameId,layerName,isShowTips,plistName)
	local isReturnRoom = true
	if self.lastBackGame == nil then
		if not self.lastGame then
			clearCache(plistName,true,true)
			self:resetSearchPath()
			globalUnit.gameName = nil
			RoomLogic:close()
		end
		isReturnRoom = false
	end

	local isPlay = false
	if GamesInfoModule:isMatchMode(uNameId) then
		if isShowTips ~= 1 then
			if layerName == "mGameLayer" or layerName == "gameLayer" then
				if globalUnit:getIsBackRoom() == true then
					self:setHallBackRoom(nil)
				end
				isPlay = true
			end
		else
			globalUnit.isDoudizhuBackRoom = false
		end
	else
		self:setHallBackRoom(nil)
		if layerName == "gameLayer" then
			isPlay = true
		end
	end

	if isShowTips ~= 1 and LoginLayer:getInstance() then
		globalUnit.gameName = nil
		Hall.enterPlatform()
		globalUnit.bIsSelectDesk = nil
	else
		if isPlay then
			-- local name = Hall:getCurGameName();
			-- local isDuizhan = false
			-- if name == "qiangzhuangniuniu" or name == "doudizhu" or name == "sanzhangpai" or name == "errenniuniu"
			-- or name == "ershiyidian" or name == "shidianban" or name == "dezhoupuke" or name == "shisanzhang" then
			-- 	isDuizhan = true
			-- end
			local layer = display.getRunningScene():getChildByName("deskLayer")
			if globalUnit.gameName == nil and not layer then
				RoomLogic:close()
			else
				if isReturnRoom then
					RoomLogic:close()
				else
					dispatchEvent("exitGameBackPlatform")
				end
			end

			SettlementInfo:sendConfigInfoRequest(5)
			MailInfo:sendMailListInfoRequest()
			stopMusic()
			playMusic("sound/audio-login.mp3",true)
			clearCache(plistName,true,true)
			-- if uNameId ~= 40021000 then
				globalUnit.isTryPlay = false
			-- else
			-- 	if layerName == "deskLayer" then--二人牛牛退出选桌才置
			-- 		globalUnit.isTryPlay = false
			-- 	end
			-- end
			globalUnit.isShowTryPlay = nil
			self:clearShowScrollMessage()
		else
			globalUnit.bIsSelectDesk = nil
		end
		print("退出游戏 === globalUnit.bIsSelectDesk ",globalUnit.bIsSelectDesk,isPlay)
		dispatchEvent("refreshScoreBank")
	end

	self:clearNewScrollMessage()
end

--断线时调用
function Hall:directExitGame()
	if not PlatformLogic:isConnect() or not RoomLogic:isConnect() then
		local ret = false

		if self.lastGame then
			local plistName = self.lastGame.plistName
			self.lastGame:directExitGame()
			ret = true
			self.lastGame = nil
		end

		if self.lastBackGame then
			local plistName = self.lastBackGame.plistName
			self.lastBackGame:directExitGame()
			ret = true
			self:setHallBackRoom(nil)
		end

		if ret then
			self:resetSearchPath()
			self:clearNewScrollMessage()
			closeGameOpenHallLayer()
			clearCache(plistName,false,true)
			local root = cc.Director:getInstance():getRunningScene()
			if root ~= nil then
				local node = root:getChildByName("prompt")
				if node then
					node:delayCloseLayer(0)
				end
			end
		end
	end
end

function Hall:getGameNameByNameID(uNameId)
	local gameName = ""

	if uNameId == 40011000 then
		gameName = "baijiale"
	elseif uNameId == 40012000 then
		gameName = "benchibaoma"
	elseif uNameId == 40013000 then
		gameName = "yaoyiyao"
	elseif uNameId == 40014000 then
		gameName = "fqzs"
	elseif uNameId == 40015000 then
		gameName = "bairenniuniu"
	elseif uNameId == 40022000 then
		gameName = "qiangzhuangniuniu"
	elseif uNameId == 40023000 then
		gameName = "doudizhu"
	elseif uNameId == 40024000 then
		gameName = "sanzhangpai"
	elseif uNameId == 40021000 then
		gameName = "errenniuniu"
	elseif uNameId == 40010000 or uNameId == 40010004 then
		gameName = "fishing"
	elseif uNameId == 40010001 or uNameId == 40010005 then
		gameName = "likuipiyu"
	elseif uNameId == 40010002 or uNameId == 40010006 then
		gameName = "jinchanbuyu"
	elseif uNameId == 40026000 then
		gameName = "ershiyidian"
	elseif uNameId == 40027000 then
		gameName = "shidianban"
	elseif uNameId == 40025000 then
		gameName = "dezhoupuke"
	elseif uNameId == 40016000 then
		gameName = "hongheidazhan"
	elseif uNameId == 40017000 then
		gameName = "longhudou"
	elseif uNameId == 40028000 or uNameId == 40028001 or uNameId == 40028002 then
		gameName = "shisanzhang"
	elseif uNameId == 40028010 or uNameId == 40028011 or uNameId == 40028012 then
		gameName = "shisanzhanglq"
	elseif uNameId == 40031000 then
		gameName = "competition"
	elseif uNameId == 40018000 then
		gameName = "saoleihongbao"
	elseif uNameId == 40050000 then
		gameName = "superfruitgame"
	elseif uNameId == 40060000 then
		gameName = "shuihuzhuan"
	elseif uNameId == 40061000 then
		gameName = "sweetparty"
	elseif uNameId == 40062000 then
		gameName = "lianhuanduobao"
	end

	return gameName
end

function Hall:getChineseGameNameByGameName(name)
	local gameName = ""

	if name == "baijiale" then
		gameName = "百家乐"
	elseif name == "benchibaoma" then
		gameName = "奔驰宝马"
	elseif name == "yaoyiyao" then
		gameName = "骰宝"
	elseif name == "fqzs" then
		gameName = "飞禽走兽"
	elseif name == "bairenniuniu" then
		gameName = "百人牛牛"
	elseif name == "qiangzhuangniuniu" then
		gameName = "抢庄牛牛"
	elseif name == "doudizhu" then
		gameName = "斗地主"
	elseif name == "sanzhangpai" then
		gameName = "扎金花"
	elseif name == "errenniuniu" then
		gameName = "二人牛牛"
	elseif name == "fishing" then
		gameName = "捕鱼达人"
	elseif name == "ershiyidian" then
		gameName = "二十一点"
	elseif name == "shidianban" then
		gameName = "十点半"
	elseif name == "dezhoupuke" then
		gameName = "德州扑克"
	elseif name == "hongheidazhan" then
		gameName = "红黑大战"
	elseif name == "longhudou" then
		gameName = "龙虎斗"
	elseif name == "shisanzhang" then
		gameName = "十三张"
	elseif name == "competition" then
		gameName = "电竞竞猜"
	elseif name == "saoleihongbao" then
		gameName = "扫雷红包"
	elseif name == "superfruitgame" then
		gameName = "超级水果机"
	elseif name == "shuihuzhuan" then
		gameName = "水浒传"
	elseif name == "shisanzhanglq" then
		gameName = "乐清十三张"
	elseif name == "sweetparty" then
		gameName = "糖果派对"
	elseif name == "lianhuanduobao" then
		gameName = "连环夺宝"
	elseif name == "likuipiyu" then
		gameName = "李逵劈鱼"
	elseif name == "jinchanbuyu" then
		gameName = "金蟾捕鱼"
	end

	return gameName
end

function Hall:getNameIDByGameName(gameName)
	local uNameId = 0

	if gameName == "baijiale" then
		uNameId = 40011000
	elseif gameName == "benchibaoma" then
		uNameId = 40012000
	elseif gameName == "yaoyiyao" then
		uNameId = 40013000
	elseif gameName == "fqzs" then
		uNameId = 40014000
	elseif gameName == "bairenniuniu" then
		uNameId = 40015000
	elseif gameName == "qiangzhuangniuniu" then
		uNameId = 40022000
	elseif gameName == "doudizhu" then
		uNameId = 40023000
	elseif gameName == "sanzhangpai" then
		uNameId = 40024000
	elseif gameName == "errenniuniu" then
		uNameId = 40021000
	elseif gameName == "fishing" then
		uNameId = {40010000,40010004}
	elseif gameName == "ershiyidian" then
		uNameId = 40026000
	elseif gameName == "shidianban" then
		uNameId = 40027000
	elseif gameName == "dezhoupuke" then
		uNameId = 40025000
	elseif gameName == "hongheidazhan" then
		uNameId = 40016000
	elseif gameName == "longhudou" then
		uNameId = 40017000
	elseif gameName == "shisanzhang" then
		uNameId = {40028000,40028001,40028002}
	elseif gameName == "shisanzhanglq" then
		uNameId = {40028010,40028011,40028012}
	elseif gameName == "competition" then
		uNameId = 40031000
	elseif gameName == "saoleihongbao" then
		uNameId = 40018000
	elseif gameName == "superfruitgame" then
		uNameId = 40050000
	elseif gameName == "shuihuzhuan" then
		uNameId = 40060000
	elseif gameName == "sweetparty" then
		uNameId = 40061000
	elseif gameName == "lianhuanduobao" then
		uNameId = 40062000
	elseif gameName == "likuipiyu" then
		uNameId = {40010001,40010005}
	elseif gameName == "jinchanbuyu" then
		uNameId = {40010002,40010006}
	end

	return uNameId
end

function Hall:isHaveGame(uNameId)
	if type(uNameId) == "number" then
		return GamesInfoModule:findGameName(uNameId)
	elseif type(uNameId) == "table" then
		for k,v in pairs(uNameId) do
			if GamesInfoModule:findGameName(uNameId) then
				return true
			end
		end
	end

	return false
end

function Hall:getGameName(name)
	-- if name == "baijiale" or name == "benchibaoma" or name == "yaoyiyao"or name == "fqzs"
	--  or name == "bairenniuniu" or name == "hongheidazhan" or name == "longhudou" then
	-- 	return "game"
	-- elseif name == "qiangzhuangniuniu" or name == "doudizhu" or name == "sanzhangpai" or name == "errenniuniu"
	--  or name == "ershiyidian" or name == "shidianban"  name == "dezhoupuke" or name == "shisanzhang" or name == "competition" then
	-- 	return "dz"
	-- else
	-- 	return "lkpy"
	-- end

	local gameName = ""

	if name == "baijiale" then
		return "game","30miao"
	elseif name == "benchibaoma" then
		return "game","ppc"
	elseif name == "yaoyiyao" then
		return "game","yyy"
	elseif name == "fqzs" then
		return "game","fqzs"
	elseif name == "bairenniuniu" then
		return "game","brps"
	elseif name == "hongheidazhan" then
		return "game","hhdz"
	elseif name == "longhudou" then
		return "game","lhd"
	elseif name == "sanzhangpai" then
		return "dz","szp"
	elseif name == "saoleihongbao" then
		return "game","slhb"
	end

	return nil
end

--回房间
function Hall:selectedBackGame(params)
	local uNameId = params[1]
	local gameName = ""

	gameName = self:getGameNameByNameID(uNameId)

	self:selectedGame(gameName,params,true)
end

function Hall:selectedHallBackGame(params)
	local uNameId = params[1]
	local gameName = ""

	if uNameId ~= self.backNameId then
		luaDump(params,"大厅回房间错误")
		luaPrint("大厅回房间错误，本地和服务器不一致 self.backNameId = "..tostring(self.backNameId))
		dispatchEvent("loginRoom")
		Hall:setHallBackRoom(nil)
		return
	end

	gameName = self:getGameNameByNameID(uNameId)

	self:selectedGame(gameName,params,false)
end

function Hall:getCurGameName()
	if self.lastGame then
		return self.lastGame.name
	end

	return nil
end

function Hall:getCurrentGameName()
	local name = ""
	local game = nil
	if self.lastBackGame then
		game = self.lastBackGame
	else
		game = self.lastGame
	end

	if game then
		name = game.name
	end

	return name,game
end

function Hall:isHaveGameLayer()
	if display.getRunningScene():getChildByName("gameLayer") then
		return true
	end

	return false
end

function Hall:loadUpdateManager()
	if NO_UPDATE ~= true then
		--配置文件
		local temp = clone(GameConfig)

		if temp.A_SERVER_IP == nil then
			audio = loadScript("cocos.framework.audio")
			temp.A_SERVER_IP = A_SERVER_IP
			temp.A_SERVER_PORT = A_SERVER_PORT
			temp.SECRECT_KEY = SECRECT_KEY
			temp.WEB_PORT = WEB_PORT
			temp.API_SERVER_URL = API_SERVER_URL
			temp.VIEW_SERVER_URL = VIEW_SERVER_URL
			temp.WEB_SERVER_URL = WEB_SERVER_URL
			temp.GCLOUD_GAME_ID = GCLOUD_GAME_ID
			temp.GCLOUD_GAME_KEY = GCLOUD_GAME_KEY
			temp.WX_APP_ID = WX_APP_ID
			temp.WX_SECRET = WX_SECRET
			temp.shareToRoom = shareToRoom
			temp.app_url = app_url
			temp.appVerUrl = appVerUrl
			temp.BAIDU_KEY = BAIDU_KEY
			temp.BAIDU_TKEY = BAIDU_TKEY
			temp.BAIDU_FKEY = BAIDU_FKEY
		end

		GameConfig = loadScript("common.GameConfig")

		if checkVersion() == 2 then
			if device.platform == "ios" then
				if temp.serverVersionInfo.isIosSDK ~= 1 then
					if temp.serverVersionInfo.yuming ~= "" and temp.serverVersionInfo.yuming ~= nil then
						GameConfig.A_SERVER_IP = temp.serverVersionInfo.yuming
					end
				end
			elseif device.platform == "android" then
				if temp.serverVersionInfo.isAndroidSDK ~= 1 then
					if temp.serverVersionInfo.yuming ~= "" and temp.serverVersionInfo.yuming ~= nil then
						GameConfig.A_SERVER_IP = temp.serverVersionInfo.yuming
					end
				end
			end
		end

		PlatformLogic.ip = GameConfig.A_SERVER_IP
		PlatformLogic.port = GameConfig.A_SERVER_PORT

		if runMode == "release" then
			for k,v in pairs(GameConfig) do
				if temp[k] ~= nil then
					if k == "appVerUrl" or k == "serverVersionInfo" or k == "serverZipVersionInfo" or k == "configInfo" or k == "AliyunUrl" or k == "domain" then
						GameConfig[k] = clone(temp[k])
					end
				end
			end

			GameConfig.AliyunUrl = GameConfig.serverVersionInfo.aliyunFangshuaUrl

			if device.platform == "ios" then
				if not isEmptyString(GameConfig.serverVersionInfo.iosWxAppid) and not isEmptyString(GameConfig.serverVersionInfo.iosWxSecret) then
					GameConfig.WX_APP_ID = GameConfig.serverVersionInfo.iosWxAppid
					GameConfig.WX_SECRET = GameConfig.serverVersionInfo.iosWxSecret

					cc.UserDefault:getInstance():setStringForKey("wxappid", GameConfig.WX_APP_ID)
					cc.UserDefault:getInstance():setStringForKey("wxsecret", GameConfig.WX_SECRET)
				end
			elseif device.platform == "android" then
				if not isEmptyString(GameConfig.serverVersionInfo.androidWxAppid) and not isEmptyString(GameConfig.serverVersionInfo.androidWxSecret) then
					GameConfig.WX_APP_ID = GameConfig.serverVersionInfo.androidWxAppid
					GameConfig.WX_SECRET = GameConfig.serverVersionInfo.androidWxSecret

					cc.UserDefault:getInstance():setStringForKey("wxappid", GameConfig.WX_APP_ID)
					cc.UserDefault:getInstance():setStringForKey("wxsecret", GameConfig.WX_SECRET)
				end
			end

			if temp.configInfo then
				if isSetTuiguangUrl == nil and not isEmptyString(temp.configInfo.yuming) then
					GameConfig.tuiguanUrl = temp.configInfo.yuming
				end
				GameConfig.serverUrl = temp.configInfo.kefuUrl
			end

			if isSetTuiguangUrl == true then
				GameConfig.tuiguanUrl = temp.tuiguanUrl
			end

			if not cc.UserDefault:getInstance():getBoolForKey("isDeleteDoudizhu",false) then
				cc.UserDefault:getInstance():setBoolForKey("isDeleteDoudizhu",true)
				cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath().."cache/olddoudizhu.txt")
			end
		end

		globalUnit.isNewVersion = true--热更方式更改后，兼容老版本
		if temp:getLuaVersion("hall") <= 210 then
			globalUnit.isNewVersion = false
			UpdateManager =require("launcher.UpdateManager"):getInstance()

			--热更文件
			local isUseCacheDir = UpdateManager.isUseCacheDir--下载文件时是否开启缓存目录功能
			local cacheDir = UpdateManager.cacheDir--缓存目录

			local tbServerMD5List = clone(UpdateManager.tbServerMD5List)

			--下载MD5文件后保存目录 默认值为合集
			local md5Path = cc.FileUtils:getInstance():getWritablePath().."cache"

			--下载文件列表
			local tbDownloadFileList = clone(UpdateManager.tbDownloadFileList)
			local tbDownFileUrl = clone(UpdateManager.tbDownFileUrl)
			local tbDownDirName = clone(UpdateManager.tbDownDirName)

			--记录待下载MD5url
			local readyDownMD5list = clone(UpdateManager.readyDownMD5list)
			local md5Url = GameConfig:getMd5Url()

			local downLoadList = clone(UpdateManager.downLoadList)--下载列表
			local downLoadListCallback = clone(UpdateManager.downLoadListCallback)--下载回调列表

			local advanceDownMd5 = UpdateManager.advanceDownMd5
			local advanceStatue = UpdateManager.advanceStatue

			if UpdateManager.globalBindCustomIds then
				for k,v in pairs(UpdateManager.globalBindCustomIds) do
					unbindEvent(v)
				end
			end

			UpdateManager = loadScript("launcher.UpdateManager"):getInstance()
			UpdateManager:initData()
			UpdateManager:bindEvent()

			UpdateManager.tbServerMD5List = clone(tbServerMD5List)
			UpdateManager.tbDownloadFileList = clone(tbDownloadFileList)
			UpdateManager.tbDownFileUrl = clone(tbDownFileUrl)
			UpdateManager.tbDownDirName = clone(tbDownDirName)

			UpdateManager.readyDownMD5list = clone(readyDownMD5list)
			UpdateManager.downLoadList = clone(downLoadList)
			UpdateManager.downLoadListCallback = clone(downLoadListCallback)
			UpdateManager.tbDownDirName = clone(tbDownDirName)
			UpdateManager.advanceDownMd5 = advanceDownMd5
			UpdateManager.advanceStatue = advanceStatue

			local tempName = {}
			if GameConfig.serverVersionInfo.gameListInfo then
				for k,v in pairs(GameConfig.serverVersionInfo.gameListInfo) do
					if GameConfig:getLuaVersion(v.gameName) == nil then
						table.insert(tempName,v.gameName)
					end
				end
			end

			if #tempName > 0 then
				for k,v in pairs(tempName) do
					UpdateManager:startDownload(v,true)
				end
			end
		else
			UpdateManager =require("launcher.ClientUpdate"):getInstance()
		end

		loadScript("cocos.cocos2d.functions")

		if ccui then
			loadScript("cocos.framework.extends.UISlider")
		end

		loadScript("cocos.cocos2d.json")
	end

	if isRepairUpate == true then
		local appid = cc.UserDefault:getInstance():getStringForKey("wxappid", "")
		local secret = cc.UserDefault:getInstance():getStringForKey("wxsecret", "")

		if not isEmptyString(appid) and not isEmptyString(secret) then
			GameConfig.WX_APP_ID = appid
			GameConfig.WX_SECRET = secret
		end

		local key = cc.UserDefault:getInstance():getStringForKey("sdkkey", "")
		-- if not isEmptyString(key) then
		-- 	if tonumber(key) then
		-- 		isUseNetSDK = true
		-- 	else
		-- 		isUseNetSDK = false
		-- 	end
		-- end
	end
end

--重启下载进入游戏网络异常处理
function Hall:restartDownload()
	luaPrint("判断是否需要重启下载",isRepairUpate)
	if runMode == "release" then
		local ret = true

		if GameConfig:getLuaVersion(gameName) >= 240 then
			if isRepairUpate ~= true then
				ret = false
			end
		end

		luaPrint("ret ",ret,NO_UPDATE,isCheckRestartDownload)

		if ret and NO_UPDATE == true and isCheckRestartDownload ~= true then
			UpdateManager =require("launcher.ClientUpdate"):getInstance()
			globalUnit.isNewVersion = true
			luaPrint("重启下载进入游戏网络异常处理")
			local layer = require("layer.update.RestartDownLayer"):create()
			display.getRunningScene():addChild(layer)
		end
	end
end

--开始重新下载
function Hall:startDownload()
	if globalUnit.isNewVersion then
		if isDownHall == true then
			UpdateManager:initData()
		end

		UpdateManager:setDownloadListInfo({"child",display.getRunningScene(),function(finishNum,totalNum) end,function() dispatchEvent("restartDownloadSuccess") end})
		UpdateManager:startDownload("child",true)

		if isDownHall == true then
			UpdateManager:setDownloadListInfo({GameConfig.serverZipVersionInfo.gameListInfo[1].gameName,display.getRunningScene()})
			UpdateManager:startDownload(GameConfig.serverZipVersionInfo.gameListInfo[1].gameName)
		end

		isDownHall = nil
	else
		for k,v in pairs(GameConfig.serverVersionInfo.gameListInfo) do
			UpdateManager:startDownload(v.gameName,true)
			break
		end
	end
end

--是否为匹配场
function Hall.isValidPiPeiGameID(gameId)
	return true;
end

function Hall:clearNewScrollMessage()
	self.newScrollMessageArr = {}
	self.newScrollMessageLayout = {}
	luaPrint("初始化 newScrollMessageLayout  len = "..#self.newScrollMessageLayout)
end

function Hall:pushNewScrollMessage(message)
	if not self.newScrollMessageArr then
		self.newScrollMessageArr = {}
	end

	local m = message

	if type(message) == "string" then
		m = {data=message,type=0}
	elseif type(message) == "table" then
		
	end

	table.insert(self.newScrollMessageArr,m)
end

function Hall:getNewMessage()
	local text = ""
	local ttype = 0

	if table.maxn(self.newScrollMessageArr) > 0 then
		text = self.newScrollMessageArr[1].data
		ttype = self.newScrollMessageArr[1].type
		table.remove(self.newScrollMessageArr,1)
	end

	return text,ttype
end

--新的滚动消息
function Hall:showNewScrollMessage(message)
	self:pushNewScrollMessage(message)

	self:startNewScrollMessage()
end

function Hall:startNewScrollMessage()
	if self.newScrollMessageLayout == nil then
		luaPrint("悲剧 初始化有问题 ")
		-- self:clearNewScrollMessage()
		self.newScrollMessageLayout = {}
	end

	local winSize = cc.Director:getInstance():getWinSize()

	local scrollTextContainer = cc.Node:create()
	scrollTextContainer:setCascadeOpacityEnabled(true)
	scrollTextContainer:setAnchorPoint(cc.p(0.5,1))
	display.getRunningScene():addChild(scrollTextContainer,9999999)
	scrollTextContainer.runCount = 0
	scrollTextContainer:setTag(#self.newScrollMessageLayout+1)

	local scrollBg = ccui.ImageView:create("common/tuisongbg.png")
	scrollBg:setAnchorPoint(cc.p(0.5,0.5))
	scrollBg:setPosition(cc.p(winSize.width/2,winSize.height/2))
	scrollTextContainer:addChild(scrollBg,999999)
	scrollBg:setCascadeOpacityEnabled(true)
	
	local messageContent = self:getNewMessage() --获取消息内容
	local scrollText = ccui.Text:create()
	scrollText:setFontSize(24)
	scrollText:setAnchorPoint(cc.p(0.5,0.5))
	scrollText:setString(messageContent)
	scrollText:setPosition(cc.p(scrollBg:getContentSize().width/2,scrollBg:getContentSize().height/2))
	scrollBg:addChild(scrollText)

	scrollTextContainer:retain()
	scrollTextContainer:hide()
	table.insert(self.newScrollMessageLayout,scrollTextContainer)

	-- performWithDelay(display.getRunningScene(),function() self:removeNewUnuseScrollMessage() end, 0.3)
	luaPrint("播放 -------  333")
	self:removeNewUnuseScrollMessage()
end

local fudu = 10
-- local pos = {
-- 			cc.p(0,winSize.height*0.15+30+30+30+fudu),
-- 			cc.p(0,winSize.height*0.15+30+30+fudu),
-- 			cc.p(0,winSize.height*0.15+30+fudu)
-- 		}

local pos = {
			cc.p(0,winSize.height*0.15+40+fudu),
			cc.p(0,winSize.height*0.15+40+40+fudu),
			cc.p(0,winSize.height*0.15+40+40+40+fudu)
		}

function Hall:removeNewUnuseScrollMessage()
	if self.isNewAction or self.isComplete then
		luaPrint("isNewAction -----------------   return")
		return
	end

	self.isNewAction = true
	self.isComplete = true

	local node = {}
	local count = 0

	-- if #self.newScrollMessageLayout > 3 then
		for k,v in pairs(self.newScrollMessageLayout) do
			v:stopAllActions()
			if k <= 3 and v.runCount >= 3 then
				table.insert(node,v)
			else
				if v:isVisible() then
					count = count + 1
				end
			end
		end
	-- end

	if not isEmptyTable(node) then
		for k,v in pairs(node) do
			luaPrint("移除  ---    tag =============  "..v:getChildren()[1]:getChildren()[1]:getString().."   count = "..v.runCount)
			table.removebyvalue(self.newScrollMessageLayout,v)
			v:removeSelf()
			v:release()
		end
	else
		luaPrint("没有可移除")
	end

-- for k,v in pairs(self.newScrollMessageLayout) do
-- 		luaPrint("遍历  ---    tag =============  "..v:getChildren()[1]:getChildren()[1]:getString().."   count = "..v.runCount)
-- 	end

	local speed = 600
	local fudu = 10
	local dt = (winSize.height*0.15+40+fudu)/speed
	local dt1 = (40+fudu)/speed

	local len = #self.newScrollMessageLayout

	local endIndex = len

	if len > 3 then
		endIndex = 3
	end

	if len == 1 then
		endIndex = 1
	elseif len == 2 then
		endIndex = 2
	else
		if self.newScrollMessageLayout[1] == self.newScrollMessageLayout[2] or 
			self.newScrollMessageLayout[2] == self.newScrollMessageLayout[3] or 
			self.newScrollMessageLayout[1] == self.newScrollMessageLayout[3] then
			endIndex = 2
		end
	end

	if len > 1 then
		if count == 0 then
			endIndex = 1
		elseif count == 1 then
			endIndex = 2
		end
	end

	luaPrint("len = "..len.."   endIndex  = "..endIndex)
	-- luaDump(self.newScrollMessageLayout,"self.newScrollMessageLayout")

	local ret = false
	local flag = {false,false,false}
	for k,v in pairs(self.newScrollMessageLayout) do
		luaPrint("k = "..k.."遍历  ---    tag =============  "..v:getChildren()[1]:getChildren()[1]:getString().."   count = "..v.runCount.."     posY ====   "..v:getPositionY())
		if flag[v.runCount + 1] == false then
			local target = pos[v.runCount+1]
			if k == endIndex then
				v.runCount = v.runCount + 1
				v:stopAllActions()
				v:show()
				v:setOpacity(0)
				local dt = (target.y - v:getPositionY())/speed
				local spawn = cc.Spawn:create(cc.FadeIn:create(dt),cc.MoveTo:create(dt, target))
				local seq = cc.Sequence:create(
					spawn,
					cc.MoveBy:create(fudu/speed, cc.p(0,-fudu)),
					cc.CallFunc:create(function()  
						luaPrint("重置   isNewAction  "..#self.newScrollMessageLayout..v:getChildren()[1]:getChildren()[1]:getString().."   count = "..v.runCount.."     posY ====   "..v:getPositionY()) 
						self.isNewAction = false 
						local rt = false
						for k,v in pairs(self.newScrollMessageLayout) do
							if not v:isVisible() then
								rt = true
								break
							end
						end
						if rt then
							luaPrint("播放 -------  111")
							self:removeNewUnuseScrollMessage()
						end
					end),
					cc.DelayTime:create(3),
					cc.FadeOut:create(0.3),
					cc.CallFunc:create(function() luaPrint("动作  移除  ---    tag ====--------------=========  "..v:getChildren()[1]:getChildren()[1]:getString().."   count = "..v.runCount.."     posY ====   "..v:getPositionY()) table.removebyvalue(self.newScrollMessageLayout,v) v:removeSelf() v:release() luaPrint("播放 -------  222") self:removeNewUnuseScrollMessage() end))
				v:runAction(seq)
				flag[v.runCount] = true
				ret = true
			else
				if v.runCount < 3 then
					v.runCount = v.runCount + 1
					v:show()
					v:stopAllActions()
					v:setOpacity(0)
					local dt2 = (target.y - v:getPositionY())/speed
					local spawn = cc.Spawn:create(cc.FadeIn:create(dt2),cc.MoveTo:create(dt2, target))
					local seq = cc.Sequence:create(
						cc.DelayTime:create(dt-dt1*(k+1)),
						spawn,
						cc.MoveBy:create(fudu/speed, cc.p(0,-fudu)),
						cc.DelayTime:create(3),
						cc.FadeOut:create(0.3),
						cc.CallFunc:create(function() luaPrint("动作   移除  ---    tag =============  "..v:getChildren()[1]:getChildren()[1]:getString().."   count = "..v.runCount.."     posY ====   "..v:getPositionY()) table.removebyvalue(self.newScrollMessageLayout,v) v:removeSelf() v:release() end))
					v:runAction(seq)
					flag[v.runCount] = true
				else
					table.removebyvalue(self.newScrollMessageLayout,v) 
					v:removeSelf()
					v:release()
				end
			end
		end

		if k >= endIndex or k == len then
			if ret == false then
				local l = 0
				for k,vv in pairs(flag) do
					if vv == true then
						l = l + 1
					end
				end

				if l ~= endIndex then
					v:runAction(
						cc.Sequence:create(
							cc.DelayTime:create(dt-dt1*(k+1)+dt1+fudu/speed+0.1), 
							cc.CallFunc:create(function() 
								self.isNewAction = false 
								local rt = false
								for k,v in pairs(self.newScrollMessageLayout) do
									if not v:isVisible() then
										rt = true
										break
									end
								end
								if rt then  
									luaPrint("播放 -------  444") 
									self:removeNewUnuseScrollMessage() 
									end 
								end)
							)
						)
				end
			end
			break
		end
	end

	if #self.newScrollMessageLayout == 0 then
		self.isNewAction = false
	end

	self.isComplete = false
end

function Hall.showTips(tip,dt)
	dt = dt or 2;
	local tipBg = "common/tip2.png"

	local winSize = cc.Director:getInstance():getWinSize()
	local layer = display.newLayer();
	layer:setTag(22222)
	local runningScene = display.getRunningScene();
	
	if runningScene:getChildByTag(22222) then
		runningScene:removeChildByTag(22222)
	end

	runningScene:addChild(layer,10000);

	local label = FontConfig.createLabel(FontConfig.gFontConfig_22, tip, cc.c3b(40,70,112));

	local background = cc.Scale9Sprite:create(tipBg)
	background:setContentSize(cc.size(label:getContentSize().width+100,60))
	background:setPosition(winSize.width/2, winSize.height/2);
	background:setAnchorPoint(cc.p(0.5,0.5))
	layer:addChild(background);

	label:setPosition(background:getContentSize().width/2,background:getContentSize().height/2);
	background:addChild(label);

	layer:runAction(cc.Sequence:create(cc.DelayTime:create(dt), cc.CallFunc:create(function() layer:removeFromParent(); end)))
end

function Hall.showToast(tip,dt)
	dt = dt or 1;
	local tipBg = "common/tip.png"

	local winSize = cc.Director:getInstance():getWinSize()
	local layer = display.newLayer();
	layer:setTag(111111)
	local runningScene = display.getRunningScene();
	
	if runningScene:getChildByTag(111111) then
		runningScene:removeChildByTag(111111)
	end

	runningScene:addChild(layer,10000);

	local label = FontConfig.createLabel(FontConfig.gFontConfig_22, tip, FontConfig.colorGold);

	local background = cc.Scale9Sprite:create(tipBg)
	background:setContentSize(cc.size(label:getContentSize().width+100,60))
	background:setPosition(winSize.width/2, 90)
	background:setAnchorPoint(cc.p(0.5,0.5))
	layer:addChild(background);

	
	label:setPosition(winSize.width/2,90);
	layer:addChild(label);

	layer:runAction(cc.Sequence:create(cc.DelayTime:create(dt), cc.CallFunc:create(function() layer:removeFromParent(); end)))
end

function Hall.showTextState(tip,dt,callback)
	dt = dt or 1;
	local tipBg = "common/tip2.png"

	local winSize = cc.Director:getInstance():getWinSize()
	local layer = display.newLayer();
	layer:setTag(1111111)
	local runningScene = display.getRunningScene();
	
	if runningScene:getChildByTag(1111111) then
		runningScene:removeChildByTag(1111111)
	end

	runningScene:addChild(layer,10000);

	local label = FontConfig.createLabel(FontConfig.gFontConfig_22, tip..".", cc.c3b(40,70,112));
	
	local background = cc.Scale9Sprite:create(tipBg)
	background:setContentSize(cc.size(label:getContentSize().width+100,60))
	background:setPosition(winSize.width/2, winSize.height/2)
	background:setAnchorPoint(cc.p(0.5,0.5))
	layer:addChild(background);

	label:setPosition(winSize.width/2, winSize.height/2);
	layer:addChild(label);

	local speed = cc.Speed:create(cc.Sequence:create(
		cc.DelayTime:create(dt),
		cc.CallFunc:create(function() 
			if callback then
				callback();
			end
			layer:removeFromParent(); 
			end)),1);
	speed:setTag(11);
	layer:runAction(speed);

	local startNum = 1

	local callFunc = function()
		
		startNum = startNum + 1
		if startNum % 4 == 1 then
			label:setString(""..tip.." .")
		elseif startNum % 4 == 2 then
			label:setString(""..tip.." ..")
		elseif startNum % 4 == 3 then
			label:setString(""..tip.." ...")
		end
	end

	local sequence = transition.sequence(
		{
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(callFunc)
		}
	)
	layer:runAction(cc.RepeatForever:create(sequence))
end

function Hall.closeTips()
	local runningScene = display.getRunningScene();
	
	local node = runningScene:getChildByTag(1111111);
	if node then
		node:getActionByTag(11):setSpeed(10);
	end

	node = runningScene:getChildByTag(111111)
	if node then
		node:removeSelf();
	end

	node = runningScene:getChildByTag(22222)
	if node then
		node:removeSelf();
	end
end

--全局滚动消息
--剔除假数据
function Hall:eliminateShowScrollMessage( messageContent )
	--数据转换
	if type(messageContent) == "string" then
		local showInfo = {}
		showInfo.type = FALSE_DATA
		showInfo.data = messageContent

		messageContent = showInfo
	elseif type(messageContent) == "table" then
		local showInfo = {}
		if messageContent.messageType == 2 or messageContent.messageType == 3 then
			showInfo.type = messageContent.messageType
			showInfo.data = messageContent
		elseif messageContent.data and messageContent.messageType then
			showInfo.type = messageContent.messageType
			showInfo.data = messageContent.data
		else
			showInfo.type = REAL_DATA
			showInfo.data = messageContent[1]
		end

		messageContent = showInfo
	end

	local realMessage = {}

	for k,v in pairs(self.scrollMessageArr) do
		if v.type ~= FALSE_DATA then
			table.insert(realMessage,v)
		end
	end

	if messageContent.type == FALSE_DATA and #realMessage == 0 then
		table.insert(self.scrollMessageArr, messageContent)
	else--if messageContent.type == REAL_DATA then

		--有真实数据 清除假数据
		
		self.scrollMessageArr = realMessage
		
		if messageContent.type == REAL_DATA then
			table.insert(self.scrollMessageArr, messageContent)
		else
			table.insert(self.scrollMessageArr, messageContent)
		end
	end
end

function Hall:getMessage(messType)
	local messageContent = ""
	local mType = nil;
	if messType == MESSAGE_ROLL then
		if #self.scrollMessageArr > 0 then			
			if type(self.scrollMessageArr[1].data) == "table" then
				messageContent = clone(self.scrollMessageArr[1].data)
			else
				messageContent = self.scrollMessageArr[1].data
			end
			mType =  self.scrollMessageArr[1].type
			table.removebyvalue(self.scrollMessageArr,self.scrollMessageArr[1])
		end
	elseif messType == MESSAGE_GLOBAL then
		if #self.globalMessageArr > 0 then
			messageContent = self.globalMessageArr[1]
			table.removebyvalue(self.scrollMessageArr,self.scrollMessageArr[1])
		end
	else
		if #self.scrollMessageArr > 0 then
			if type(self.scrollMessageArr[1].data) == "table" then
				messageContent = clone(self.scrollMessageArr[1].data)
			else
				messageContent = self.scrollMessageArr[1].data
			end
			mType =  self.scrollMessageArr[1].type
			table.removebyvalue(self.scrollMessageArr,self.scrollMessageArr[1])
		end
	end

	return messageContent, mType
end

function Hall:clearShowScrollMessage()
	--全局滚动消息数组
	self.scrollMessageArr = {}
	self.scrollMessageFishArr = {}
	self.fishMessageLayout = {}

	if self.fishMessageLayout == nil then
		self.fishMessageLayout = {}
	end

	if self.fishMessageLayout[globalUnit:getEnterGameName()] == nil then
		self.fishMessageLayout[globalUnit:getEnterGameName()] = {}
	end

	if self.scrollMessageFishArr == nil then
		self.scrollMessageFishArr = {}
	end

	if self.scrollMessageFishArr[globalUnit:getEnterGameName()] == nil then
		self.scrollMessageFishArr[globalUnit:getEnterGameName()] = {}
	end
end

--全局滚动消息
function Hall:showScrollMessage(messageContent,messType)
	if self.scrollMessageArr == nil then
		return;
	end

	messType = messType or MESSAGE_ROLL

	if messType == MESSAGE_ROLL then
		self:eliminateShowScrollMessage(messageContent)
	elseif messType == MESSAGE_GLOBAL then
		table.insert(self.globalMessageArr, messageContent)
	end

	local temp = display.getRunningScene():getChildByTag(10000 + 100)
	if temp then
		local scrollTextPanel = temp:getChildByName("scrollTextPanel");
		if scrollTextPanel then
			local scrollText = scrollTextPanel:getChildByName("scrollText");
			if scrollText then
				local tag = scrollText:getTag();
				if tag == FALSE_DATA and type(messageContent) ~= "string" then-- and messageContent.messageType == laba_DATA then
					scrollText:removeFromParent()
					self:startScrollMessage(messType)
				end
			end
		end
		return
	end

	local winSize = cc.Director:getInstance():getWinSize();

	--滚动消息
	local scrollTextContainer = ccui.Layout:create()
	scrollTextContainer:setAnchorPoint(cc.p(0.5,1))
	display.getRunningScene():addChild(scrollTextContainer,100,10000 + 100);
	scrollTextContainer:setName("scrollLayer")
	if messType == MESSAGE_ROLL then
		scrollTextContainer:setContentSize(cc.size(600,30))
		scrollTextContainer:setPosition(cc.p(winSize.width/2+30, winSize.height-110))
	elseif messType == MESSAGE_GLOBAL then
		scrollTextContainer:setContentSize(cc.size(600,30))
		scrollTextContainer:setPosition(cc.p(winSize.width/2+30, winSize.height-110))
	end

	local scrollBg = ccui.ImageView:create("common/ty_pao_ma_bg.png")
	scrollBg:setScale9Enabled(true)
	scrollBg:setContentSize(cc.size(scrollTextContainer:getContentSize().width, 40))
	scrollBg:ignoreAnchorPointForPosition(false)
	scrollBg:setAnchorPoint(cc.p(0.5,0.5))
	scrollBg:setPosition(cc.p(scrollTextContainer:getContentSize().width/2,scrollTextContainer:getContentSize().height/2))
	scrollTextContainer:addChild(scrollBg)

	-- if messType == MESSAGE_GLOBAL then
	-- else
		--不显示喇叭图标
		-- local markIcon = ccui.ImageView:create("common/laba.png")
		-- markIcon:setPosition(35,scrollBg:getContentSize().height/2+5)
		-- scrollTextContainer:addChild(markIcon)
	-- end

	local scrollTextPanel = ccui.Layout:create()
	scrollTextPanel:setAnchorPoint(cc.p(0.5,0.5))
	-- if globalUnit.isEnterGame == true then
	-- 	markIcon:hide()
		scrollTextPanel:setContentSize(cc.size(scrollBg:getContentSize().width,30))
		scrollTextPanel:setPosition(cc.p(scrollTextContainer:getContentSize().width/2,scrollTextContainer:getContentSize().height/2))
	-- else
	-- 	scrollTextPanel:setContentSize(cc.size(scrollBg:getContentSize().width-markIcon:getContentSize().width,30))
	-- 	scrollTextPanel:setPosition(cc.p(scrollTextContainer:getContentSize().width/2+markIcon:getContentSize().width/3,scrollTextContainer:getContentSize().height/2))
	-- end
	scrollTextPanel:setClippingEnabled(true)
	scrollTextPanel:setName("scrollTextPanel")
	scrollTextContainer:addChild(scrollTextPanel)

	self:startScrollMessage(messType)

	return scrollTextContainer;
end

function Hall:startScrollMessage(messType)
	local scrollTextContainer = display.getRunningScene():getChildByTag(10000 + 100)

	local messageCount = 0

	if messType == MESSAGE_ROLL then
		messageCount = #self.scrollMessageArr
	elseif messType == MESSAGE_GLOBAL then
		messageCount = #self.globalMessageArr
	end

	if messageCount > 0 then
		if scrollTextContainer then
			scrollTextContainer:getParent():reorderChild(scrollTextContainer, layerZorder-100);

			local scrollTextPanel = scrollTextContainer:getChildByName("scrollTextPanel")
			
			local messageContent,mType = self:getMessage(messType) --获取消息内容
			--是否富文本
			if mType == 2 or mType == 3 then
				if globalUnit.isEnterGame then --是否在游戏中  层级重置
					scrollTextContainer:getParent():reorderChild(scrollTextContainer, gameZorder+100);
				end

				local scrollText = ccui.RichText:create();
				scrollText:ignoreContentAdaptWithSize(true);
				scrollText:setAnchorPoint(cc.p(0,0.5));
				scrollText:setName("scrollText");

				local name = messageContent.UserName
				local len = #(string.gsub(name, "[\128-\191]", ""))
				local target = ""
				if len > 8 then
					target = FormotGameNickName(name,nickNameLen)
				else
					target = name
				end

				local rich1 = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, "恭喜 ", "Helvetica", 24); --恭喜
				local richName = ccui.RichElementText:create(1, cc.c3b(0, 255, 0), 255, target.." ", "Helvetica", 24); --玩家名称
				local richGame = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, messageContent.data, "Helvetica", 24); --游戏名称
				local richScore = ccui.RichElementText:create(1, cc.c3b(255, 0, 0), 255, goldConvert(messageContent.lScore,true).." ", "Helvetica", 24); --获得金币
				local richPraise = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, messageContent.enddata.." ", "Helvetica", 24); --祝贺语
				scrollText:pushBackElement(rich1);
				scrollText:pushBackElement(richName);
				scrollText:pushBackElement(richGame);
				scrollText:pushBackElement(richScore);
				scrollText:pushBackElement(richPraise);

				if mType then
					scrollText:setTag(mType)
				end
				scrollTextPanel:addChild(scrollText);
				scrollText:formatText();
				scrollText:setPosition(cc.p(scrollTextPanel:getContentSize().width,scrollTextPanel:getContentSize().height/2))

				local moveDistance = scrollText:getContentSize().width + scrollTextPanel:getContentSize().width
				local moveDuration = moveDistance / 100

				--当单局赢得金币超过5000时，消息播放栏周围一圈需有特效显示。messageData.messageType 2 赢取  3 提取
				if messageContent.messageType == 2 and messageContent.lScore >= 100000 then
					--特效
					local skeleton_animation = createSkeletonAnimation("ganggaotexiaoA", "hall/effect/ganggaotexiao.json", "hall/effect/ganggaotexiao.atlas")
					if skeleton_animation then
						skeleton_animation:setAnimation(1,"ganggaotexiao", true)
						skeleton_animation:setPosition(scrollTextContainer:getContentSize().width/2-2,scrollTextContainer:getContentSize().height/2-2)
						scrollTextContainer:addChild(skeleton_animation)
						skeleton_animation:setScaleX(0.69)
						skeleton_animation:setScaleY(0.90)
						skeleton_animation:runAction(cc.Sequence:create(
								cc.DelayTime:create(moveDuration),
								cc.CallFunc:create(function() 
									skeleton_animation:removeSelf();
								end)))
					end
				end

				local scrollAction = cc.Sequence:create(
								cc.MoveBy:create(moveDuration, cc.p(-moveDistance,0)),
								cc.CallFunc:create(function() 
									scrollText:removeFromParent()
									self:startScrollMessage(messType)
								end)
							)
				scrollText:runAction(scrollAction)
				performWithDelay(scrollText,function() if messageCount-1<= 0 then dispatchEvent("pushMessage") end end, moveDuration-50/1000);

				return;
			end

			local scrollText = ccui.Text:create()
			scrollText:setFontSize(24)
			scrollText:setAnchorPoint(cc.p(0,0.5))
			scrollText:setColor(cc.c3b(255,255,255))
			scrollText:setString(messageContent)
			scrollText:setName("scrollText")
			if mType then
				scrollText:setTag(mType)
			end
			scrollText:setPosition(cc.p(scrollTextPanel:getContentSize().width,scrollTextPanel:getContentSize().height/2))
			scrollTextPanel:addChild(scrollText)

			local moveDistance = scrollText:getContentSize().width + scrollTextPanel:getContentSize().width
			local moveDuration = moveDistance / 100

			local scrollAction = cc.Sequence:create(
							cc.MoveBy:create(moveDuration, cc.p(-moveDistance,0)),
							cc.CallFunc:create(function() 
								scrollText:removeFromParent()
								self:startScrollMessage(messType)
							end)
						)
			scrollText:runAction(scrollAction)
			performWithDelay(scrollText,function() if messageCount-1<= 0 then dispatchEvent("pushMessage") end end, moveDuration-50/1000)
		else
			--清空消息队列
			if messType == MESSAGE_ROLL then
				self.scrollMessageArr = {}
			elseif messType == MESSAGE_GLOBAL then
				self.globalMessageArr = {} 
			end

			performWithDelay(display.getRunningScene(),function() dispatchEvent("pushMessage") end, 50/1000)
		end
	else
		if scrollTextContainer then
			scrollTextContainer:removeFromParent()
		end
	end
end

function Hall:eliminateShowScrollFishMessage( messageContent )
	--数据转换
	if type(messageContent) == "string" then
		local showInfo = {}
		showInfo.type = FALSE_DATA
		showInfo.data = messageContent

		messageContent = showInfo
	elseif type(messageContent) == "table" then
		local showInfo = {}
		if messageContent.data and messageContent.messageType then
			showInfo.type = messageContent.messageType
			showInfo.data = messageContent.data
		else
			showInfo.type = REAL_DATA
			showInfo.data = messageContent.data
		end
		showInfo.UserName = messageContent.UserName
		showInfo.VipLevel = messageContent.VipLevel
		showInfo.IsYueKa = messageContent.IsYueKa

		messageContent = showInfo
	end

	if self.scrollMessageFishArr == nil then
		self.scrollMessageFishArr = {}
	end

	if self.scrollMessageFishArr[globalUnit:getEnterGameName()] == nil then
		self.scrollMessageFishArr[globalUnit:getEnterGameName()] = {};
	end

	local realMessage = {}

	for k,v in pairs(self.scrollMessageFishArr[globalUnit:getEnterGameName()]) do
		if v.type ~= FALSE_DATA then
			table.insert(realMessage,v)
		end
	end

	if messageContent.type == FALSE_DATA and #realMessage == 0 then
		table.insert(self.scrollMessageFishArr[globalUnit:getEnterGameName()], messageContent)
	else
		--有真实数据 清除假数据
		
		self.scrollMessageFishArr[globalUnit:getEnterGameName()] = realMessage
		
		if messageContent.type == REAL_DATA then
			table.insert(self.scrollMessageFishArr[globalUnit:getEnterGameName()], messageContent)
		else
			table.insert(self.scrollMessageFishArr[globalUnit:getEnterGameName()], messageContent)	
		end
	end
end

function Hall:getFishMessage()
	local messageContent = ""
	if table.maxn(self.scrollMessageFishArr[globalUnit:getEnterGameName()]) > 0 then
		messageContent = self.scrollMessageFishArr[globalUnit:getEnterGameName()][1]
		table.remove(self.scrollMessageFishArr[globalUnit:getEnterGameName()],1)
	end
	return messageContent
end

--仅针对游戏内捕鱼消息
function Hall:showFishMessage(messageContent)
	if globalUnit.isEnterGame ~= true and messageContent.messageType ~= 3 then
		return;
	end

	self:eliminateShowScrollFishMessage(messageContent)

	self:startScrollFishMessage();

	-- if self:removeUnuseFishMessage() ~= true then
	--	 self:startScrollFishMessage();
	-- end

	if #self.fishMessageLayout[globalUnit:getEnterGameName()] <= 3 then
		self:removeUnuseFishMessage();
	end
end

function Hall:startScrollFishMessage()
	local messageCount = 0

	messageCount = table.maxn(self.scrollMessageFishArr[globalUnit:getEnterGameName()])

	if messageCount > 0 then
		local winSize = cc.Director:getInstance():getWinSize();

		local scrollTextContainer = ccui.Layout:create()
		scrollTextContainer:setAnchorPoint(cc.p(0.5,0.5)) 
		display.getRunningScene():getChildByName("gameLayer"):addChild(scrollTextContainer,999999);
		scrollTextContainer:setName("fish"..globalUnit:getEnterGameName())

		scrollTextContainer:setContentSize(cc.size(800,30))
		scrollTextContainer:setPosition(cc.p(winSize.width/2, winSize.height-200))

		local scrollBg = ccui.ImageView:create("common/tuisongbg.png")
		scrollBg:setScale9Enabled(true)
		scrollBg:setContentSize(cc.size(scrollTextContainer:getContentSize().width, 30))
		scrollBg:ignoreAnchorPointForPosition(false)
		scrollBg:setAnchorPoint(cc.p(0.5,0.5))
		scrollBg:setPosition(cc.p(scrollTextContainer:getContentSize().width/2,scrollTextContainer:getContentSize().height/2))
		scrollTextContainer:addChild(scrollBg)

		local messageContent = self:getFishMessage() --获取消息内容
		local text = {"大侠[",messageContent.UserName,"]"..messageContent.data};
		local color = {cc.c3b(255,255,255),cc.c3b(255,255,255),cc.c3b(255,255,255)}
		if messageContent.VipLevel > 0 then
			color = {cc.c3b(255,255,255),cc.c3b(255,0,0),cc.c3b(255,255,255),cc.c3b(255,0,0),cc.c3b(255,255,255)}
			text = {"强势围观[","VIP"..messageContent.VipLevel,"]大侠[",messageContent.UserName,"]"..messageContent.data};
		elseif messageContent.IsYueKa ~= 0 then
			color[2] = cc.c3b(255,0,0)
			text = {"大侠[",messageContent.UserName,"]"..messageContent.data};
		end
		local node = cc.Node:create();
		node:setPosition(cc.p(scrollTextContainer:getContentSize().width/2,scrollTextContainer:getContentSize().height/2))
		scrollTextContainer:addChild(node);
		
		local x = 0;
		for i=1,#text do
			local scrollText = ccui.Text:create()
			scrollText:setFontSize(24)
			scrollText:setAnchorPoint(cc.p(0,0.5))
			scrollText:setColor(color[i])
			scrollText:setString(text[i])
			scrollText:setPosition(cc.p(x,0))
			node:addChild(scrollText)
			x = x + scrollText:getContentSize().width;
		end

		node:setPositionX(node:getPositionX()-x/2);

		scrollTextContainer:retain();
		scrollTextContainer:setVisible(false);
		table.insert(self.fishMessageLayout[globalUnit:getEnterGameName()],scrollTextContainer);
	else
		self.scrollMessageFishArr[globalUnit:getEnterGameName()] = {}
	end
end

function Hall:removeUnuseFishMessage()
	if isAction == true then
		return;
	end

	isAction = true;
	local winSize = cc.Director:getInstance():getWinSize();
	local len = 0--#self.fishMessageLayout[globalUnit:getEnterGameName()];
	local y = winSize.height-200;
	local dis = 30;
	local speed = 60;
	local dt = 5;

	for k,v in pairs(self.fishMessageLayout[globalUnit:getEnterGameName()]) do
		if v and not tolua.isnull(v) then
			if v:isVisible() == true then
				len = len + 1;
			end
		end
	end

	if #self.fishMessageLayout[globalUnit:getEnterGameName()] <= 0 then
		isAction = false;
		return;
	end

	if len == 0 then
		local layout1 = self.fishMessageLayout[globalUnit:getEnterGameName()][1];
		if layout1 and not tolua.isnull(layout1) then
			layout1:setVisible(true);
			local y1 = layout1:getPositionY();

			local scrollAction = cc.Sequence:create(
				cc.DelayTime:create(dt),
				cc.CallFunc:create(function() 
					layout1:removeFromParent()
					layout1:removeSelf()
					table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);
					self:removeUnuseFishMessage();
				end)
			)
			layout1:runAction(scrollAction)
		else
			table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);
		end
	elseif len == 1 then
		local layout1 = self.fishMessageLayout[globalUnit:getEnterGameName()][1];
		local layout2 = self.fishMessageLayout[globalUnit:getEnterGameName()][2];

		local isFlag = false;
		if layout1 and not tolua.isnull(layout1) then
			layout1:setVisible(true);
			layout1:stopAllActions();
			local yy = y+dis-layout1:getPositionY();
			local dt1 = yy/speed;

			local seq = cc.Sequence:create(
							cc.Spawn:create(cc.ScaleTo:create(dt1, 0.8),cc.MoveBy:create(dt1,cc.p(0,yy))),
							cc.DelayTime:create(dt-dt1),
							cc.CallFunc:create(function() 
								layout1:removeFromParent(); 
								layout1:removeSelf();
								table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1)
								end)
						)
			layout1:runAction(seq);
			isFlag = true;
		else
			table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);
		end

		if layout2 and not tolua.isnull(layout2) then
			layout2:setVisible(true);
			layout2:stopAllActions();
			local scrollAction = cc.Sequence:create(
				cc.DelayTime:create(dt),
				cc.CallFunc:create(function()
					layout2:removeFromParent()
					layout2:removeSelf()
					table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);
					self:removeUnuseFishMessage();
				end)
			)
			layout2:runAction(scrollAction)
		else
			table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);
			if not isFlag then
				self:removeUnuseFishMessage();
			end
		end
	elseif len == 2 then
		local layout1 = self.fishMessageLayout[globalUnit:getEnterGameName()][1];
		local layout2 = self.fishMessageLayout[globalUnit:getEnterGameName()][2];
		local layout3 = self.fishMessageLayout[globalUnit:getEnterGameName()][3];
		local dt2 = 0;
		if layout1 and not tolua.isnull(layout1) then
			layout1:stopAllActions();
			local yy = y+dis-layout1:getPositionY();
			if yy <= 0 then
				layout1:removeFromParent()
				layout1:removeSelf()
			else
				local s = layout1:getScaleX();
				s = 0.8 / s;
				dt2 = yy / speed;
				local seq = cc.Sequence:create(
								cc.Spawn:create(cc.ScaleTo:create(dt2, s),cc.MoveBy:create(dt2,cc.p(0,yy))),
								cc.CallFunc:create(function() 
								layout1:removeFromParent(); 
								layout1:removeSelf();
								end)
					)
				layout1:runAction(seq);
			end
		end
		table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);

		if #self.fishMessageLayout[globalUnit:getEnterGameName()] > 2 then
			dt = 1;
		end

		if layout2 and not tolua.isnull(layout2) then
			layout2:stopAllActions();
			local yy = y+dis-layout2:getPositionY();
			if yy < 0 then
				yy = 0;
			end
			local dt1 = yy/speed;

			local seq = cc.Sequence:create(
							cc.DelayTime:create(dt2),
							cc.Spawn:create(cc.ScaleTo:create(dt1, 0.8),cc.MoveBy:create(dt1,cc.p(0,yy))),
							cc.DelayTime:create(dt-dt1),
							cc.CallFunc:create(function() 
								layout2:removeFromParent(); 
								layout2:removeSelf();
								table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1)
								end)
						)
			layout2:runAction(seq);
		else
			table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);
			self:removeUnuseFishMessage();
		end

		if layout3 and not tolua.isnull(layout3) then
			layout3:setVisible(true);
			layout3:stopAllActions();
			local scrollAction = cc.Sequence:create(
				cc.DelayTime:create(dt+dt2),
				cc.CallFunc:create(function() 
					layout3:removeFromParent()
					layout3:removeSelf()
					table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);
					self:removeUnuseFishMessage();
				end)
			)

			local yy = y+dis-layout3:getPositionY();
			if yy < 0 then
				yy = 0;
			end
			local dt1 = yy/speed;

			if dt ~= 5 then
				scrollAction = cc.Sequence:create(
					cc.DelayTime:create(dt+dt2),
					cc.Spawn:create(cc.ScaleTo:create(dt1, 0.8),cc.MoveBy:create(dt1,cc.p(0,yy),cc.CallFunc:create(function() self:removeUnuseFishMessage(); end))),
					cc.CallFunc:create(function() 
						layout3:removeFromParent()
						layout3:removeSelf()
						table.remove(self.fishMessageLayout[globalUnit:getEnterGameName()], 1);							
					end)
				)
			end
			layout3:runAction(scrollAction)
		end
	end

	isAction = false;
end

return Hall
