-- 欢乐30秒

local benchibaoma = {}

benchibaoma.step = 0
benchibaoma.pushLayer = {}

function benchibaoma:start(params)
	self.name = "benchibaoma"
	self.plistName = "benchibaoma/game/benchibaoma"
	self:setRes()

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
		-- layer = loadScript("CreateGoldRoomLayer"):create("ppc")
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("game_ppc")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("ppc")
		end
		self.step = 1
		table.insert(self.pushLayer,layer)
	elseif self.step == 1 then
		-- layer = loadScript("benchibaoma.LoadLayer"):create(function() Hall:selectedGame("benchibaoma",params) end)
		-- zorder = gameZorder
		self.step = 2
		self:start(params)
	elseif self.step == 2 then
		layer = loadScript("benchibaoma.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function benchibaoma:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/"..self.name,true)
	cc.FileUtils:getInstance():addSearchPath("src/"..self.name,true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/"..self.name,true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/"..self.name,true)
	end

	GameMsg = loadScript("benchibaoma.GameMsg")

	if self.isSetRes then
		return
	end
	self.isSetRes = true
	
	BCBMInfo = loadScript("benchibaoma.BCBMInfo")
end

--所有游戏此函数不改
function benchibaoma:exitGame(dt,callback)
	self.step = self.step - 1

	if not isEmptyTable(self.pushLayer) then
		local layer = self.pushLayer[#self.pushLayer]

		if layer and not tolua.isnull(layer) then
			table.removebyvalue(self.pushLayer,layer)
			if layer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				-- RoomLogic:stopCheckNet()
				-- dispatchEvent("startCheckNet")
			end

			layer:delayCloseLayer(dt,callback)
		end

		if #self.pushLayer == 0 then
			BCBMInfo:clear()
			package.loaded[self.name] = nil
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
		end
	end
end

function benchibaoma:directExitGame()
	self.step = 0
	self.pushLayer = {}
	BCBMInfo:clear()
	package.loaded[self.name] = nil
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
end

return benchibaoma
