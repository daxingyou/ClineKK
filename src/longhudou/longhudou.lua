local longhudou = {}

longhudou.step = 0
longhudou.pushLayer = {}

function longhudou:start(params)
	self.name = "longhudou"
	self.plistName = 
	{
		"longhudou/longhudou",
		"longhudou/card",
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
		-- layer = loadScript("CreateGoldRoomLayer"):create("lhd")
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("game_lhd")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("lhd")
			layer:setName("CreateGoldRoomLayer");
		end
		self.step = 1
		table.insert(self.pushLayer,layer)
	elseif self.step == 1 then
		-- layer = loadScript("longhudou.LoadLayer"):create(function() Hall:selectedGame("longhudou",params) end)
		-- zorder = gameZorder
		self.step = 2
		self:start(params)
	elseif self.step == 2 then
		layer = loadScript("longhudou.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function longhudou:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/longhudou",true)
	cc.FileUtils:getInstance():addSearchPath("src/longhudou",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/longhudou",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/longhudou",true)
	end
	GameMsg = loadScript("longhudou.GameMsg")
	if self.isSetRes then
		return
	end
	self.isSetRes = true

	LhdInfo = loadScript("longhudou.LhdInfo")
end

--所有游戏此函数不改
function longhudou:exitGame(dt,callback)
	self.step = self.step - 1

	if not isEmptyTable(self.pushLayer) then
		local layer = self.pushLayer[#self.pushLayer]

		local flag = false;
		if layer and not tolua.isnull(layer) then
			table.removebyvalue(self.pushLayer,layer)
			if layer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				-- RoomLogic:stopCheckNet()
				-- dispatchEvent("startCheckNet")
				flag = true;
			end

			layer:delayCloseLayer(dt,callback)

		end

		if #self.pushLayer == 0 then
			flag = false;
			LhdInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["longhudou"] = nil
		end

		if not isEmptyTable(self.pushLayer) and globalUnit.bIsSelectDesk == false then
			local layer = self.pushLayer[#self.pushLayer]
			if layer and not tolua.isnull(layer) then
				if flag and layer:getName() == "CreateGoldRoomLayer" then
					Hall:exitGame();
				end
			end
		end
	end
end

function longhudou:directExitGame()
	self.step = 0
	self.pushLayer = {}
	LhdInfo:clear()
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
	package.loaded["longhudou"] = nil
end

return longhudou
