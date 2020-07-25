local Fishing = {}

Fishing.step = 0
Fishing.pushLayer = {}

function Fishing:start(params)
	self.name = "fishing"
	self.plistName = {
					"fishing/fishing/fish/boss2",
					"fishing/fishing/fish/boss",
					"fishing/fishing/fish/boss1",
					"fishing/fishing/fort",
					"fishing/fishing/fish/fish_test4",
					"fishing/fishing/fish/fish_test3",
					"fishing/fishing/fish/fish_test2",
					"fishing/fishing/fish/fish_test1",
					"fishing/fishing/game/gamefish",
					"fishing/fishing/scene/gold",
					"fishing/fishing/scene/other_gold"
					}
	self:setRes()

	if self.pushLayer == nil then
		self.pushLayer = {}
	end

	if self.step < 0 then
		self.step = 0
	end

	local runningScene = display.getRunningScene()

	local layer = nil
	local zorder = layerZorder

	if self.step == 0 then
		--房间选择界面， 具体游戏自己写
		-- layer = loadScript("CreateGoldRoomLayer"):create("LKPY")
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("LKPY")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("LKPY")
		end
		self.step = 1
	elseif self.step == 1 then
		dispatchEvent("loginRoom")
		layer = loadScript("fishing.LoadLayer"):create(function() Hall:selectedGame(self.name,params) end)
		zorder = gameZorder
		layer:setName("loadLayer")
		self.step = 2
	elseif self.step == 2 then
		layer = loadScript("game.TableLayer"):create(params[1], params[2], params[3], params[4])
		zorder = gameZorder
		layer:setName("gameLayer")
		dispatchEvent("enterGameAndStopCheckNet")--停止大厅心跳检测
	end

	if layer then
		layer:setLocalZOrder(zorder+self.step)
		runningScene:addChild(layer)

		if layer:getName() ~= "loadLayer" then
			table.insert(self.pushLayer,layer)
		end
	end
end

function Fishing:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/"..self.name,true)
	cc.FileUtils:getInstance():addSearchPath("src/"..self.name,true)
	cc.FileUtils:getInstance():addSearchPath("res/"..self.name.."/fishing/",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/"..self.name,true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/"..self.name,true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/"..self.name.."/fishing/",true)
	end

	GameMsg = loadScript("game.GameMsg")

	if self.isSetRes then
		return
	end
	self.isSetRes = true

	loadScript("game.core.GlobalConstant")
	FishModule = loadScript("game.FishModule"):getInstance()
	GameGoodsInfo = loadScript("dataModel.fish.GameGoodsInfo")
	GiftEggsInfo = loadScript("dataModel.fish.GiftEggsInfo")
	RockingMoneyTreeInfo = loadScript("dataModel.fish.RockingMoneyTreeInfo")
	UserExpandInfo = loadScript("dataModel.fish.UserExpandInfo")
	RedEnvelopesInfo = loadScript("dataModel.fish.RedEnvelopesInfo")
	LockFishInfo = loadScript("dataModel.fish.LockFishInfo")
end

--所有游戏此函数不改
function Fishing:exitGame(dt,callback)
	self.step = self.step - 1

	if not isEmptyTable(self.pushLayer) then
		local layer = self.pushLayer[#self.pushLayer]

		if layer and not tolua.isnull(layer) then
			table.removebyvalue(self.pushLayer,layer)
			if layer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				RoomLogic:stopCheckNet()
				dispatchEvent("startCheckNet")
				FishModule:clearData()
			end

			layer:delayCloseLayer(dt,callback)
		end

		if #self.pushLayer == 0 then
			FishModule:destroyInstance()
			GameGoodsInfo:clear()
			GiftEggsInfo:clear()
			UserExpandInfo:clear()
			RedEnvelopesInfo:clear()
			RockingMoneyTreeInfo:clear()
			LockFishInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded[self.name] = nil
		end
	end
end

function Fishing:directExitGame()
	self.step = 0
	self.pushLayer = {}
	FishModule:destroyInstance()
	GameGoodsInfo:clear()
	GiftEggsInfo:clear()
	UserExpandInfo:clear()
	RedEnvelopesInfo:clear()
	RockingMoneyTreeInfo:clear()
	LockFishInfo:clear()
	package.loaded[self.name] = nil
	Hall.lastGame = nil
end

return Fishing
