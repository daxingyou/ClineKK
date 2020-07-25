local superfruitgame = {}

superfruitgame.step = 0
superfruitgame.pushLayer = {}

function superfruitgame:start(params)
	self.name = "superfruitgame"
	self.plistName = 
	{
		"superfruitgame/superfruittable",
	}
	self:setRes();
	if self.pushLayer == nil then
		self.pushLayer = {}
	end

	if self.step < 0 or not params then
		self.step = 0
	end

	local runningScene = display.getRunningScene()

	local layer = nil
	local zorder = layerZorder

	if self.step == 0 then
		--房间选择界面， 具体游戏自己写
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("dz_shuiguoji")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("shuiguoji")
		end
		self.step = 1
		table.insert(self.pushLayer,layer)
	elseif self.step == 1 then
		self.step = 2
		self:start(params)
	elseif self.step == 2 then
		layer = loadScript("superfruitgame.TableLayer"):create(params[1], params[2], params[3], params[4])
		zorder = gameZorder
		layer:setName("gameLayer")
		dispatchEvent("enterGameAndStopCheckNet")--停止大厅心跳检测
		table.insert(self.pushLayer,layer)
	end

	if layer then
		layer:setLocalZOrder(zorder+self.step)
		runningScene:addChild(layer)
	end
end

function superfruitgame:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/superfruitgame",true)
	cc.FileUtils:getInstance():addSearchPath("src/superfruitgame",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/superfruitgame",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/superfruitgame",true)
	end
	GameMsg = loadScript("superfruitgame.GameMsg")
	if self.isSetRes then
		return
	end
	self.isSetRes = true

	SuperFriutInfo = loadScript("superfruitgame.SuperFriutInfo")
end

--所有游戏此函数不改
function superfruitgame:exitGame(dt,callback)
	self.step = self.step - 1

	if not isEmptyTable(self.pushLayer) then
		local layer = self.pushLayer[#self.pushLayer]

		if layer and not tolua.isnull(layer) then
			table.removebyvalue(self.pushLayer,layer)
			if layer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				RoomLogic:stopCheckNet()
				dispatchEvent("startCheckNet")
			end

			layer:delayCloseLayer(dt,callback)
		end

		if #self.pushLayer == 0 then
			SuperFriutInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["superfruitgame"] = nil
		end
	end
end

function superfruitgame:directExitGame()
	self.step = 0
	self.pushLayer = {}
	SuperFriutInfo:clear()
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
	package.loaded["superfruitgame"] = nil
end

return superfruitgame
