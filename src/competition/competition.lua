local competition = {}

competition.step = 0
competition.pushLayer = {}

function competition:start(params)
	self.name = "competition"
	self.plistName = {

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

	luaPrint("电竞 进入房间步骤",self.step)

	if self.step == 0 then
		--房间选择界面， 具体游戏自己写
		layer = loadScript("CreateGoldRoomLayer"):create("dj")
		table.insert(self.pushLayer,layer)
		self.step = 2
	elseif self.step == 1 then
		layer = loadScript("competition.LoadLayer"):create(function() Hall:selectedGame("competition",params) end)
		zorder = gameZorder
		self.step = 2
	elseif self.step == 2 then
		layer = loadScript("competition.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function competition:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/"..self.name,true)
	cc.FileUtils:getInstance():addSearchPath("src/"..self.name,true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/"..self.name,true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/"..self.name,true)
	end
	GameMsg = loadScript("competition.GameMsg")
	if self.isSetRes then
		return
	end
	self.isSetRes = true

	CompetInfo = loadScript("competition.CompetInfo")
end

--所有游戏此函数不改
function competition:exitGame(dt,callback)
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
			CompetInfo:clear()
			package.loaded[self.name] = nil
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
		end
	end
end

function competition:directExitGame()
	self.step = 0
	self.pushLayer = {}
	CompetInfo:clear()
	package.loaded[self.name] = nil
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
end

return competition
