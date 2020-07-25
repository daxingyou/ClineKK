local hongheidazhan = {}

hongheidazhan.step = 0
hongheidazhan.pushLayer = {}

function hongheidazhan:start(params)
	self.name = "hongheidazhan"
	self.plistName = 
	{
		"hongheidazhan/hongheidazhan",
		"hongheidazhan/card",
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

	luaPrint("hongheidazhan---self.step",self.step)

	if self.step == 0 then
		--房间选择界面， 具体游戏自己写
		-- layer = loadScript("CreateGoldRoomLayer"):create("hhdz")
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("game_hhdz")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("hhdz")
			layer:setName("CreateGoldRoomLayer");
		end
		self.step = 1
		table.insert(self.pushLayer,layer)
	elseif self.step == 1 then
		-- layer = loadScript("hongheidazhan.LoadLayer"):create(function() Hall:selectedGame("hongheidazhan",params) end)
		-- zorder = gameZorder
		self.step = 2
		self:start(params)
	elseif self.step == 2 then
		layer = loadScript("hongheidazhan.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function hongheidazhan:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/hongheidazhan",true)
	cc.FileUtils:getInstance():addSearchPath("src/hongheidazhan",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/hongheidazhan",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/hongheidazhan",true)
	end
	GameMsg = loadScript("hongheidazhan.GameMsg")
	if self.isSetRes then
		return
	end
	self.isSetRes = true

	HhdzInfo = loadScript("hongheidazhan.HhdzInfo")
end

--所有游戏此函数不改
function hongheidazhan:exitGame(dt,callback)
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
			HhdzInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["hongheidazhan"] = nil
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

function hongheidazhan:directExitGame()
	self.step = 0
	self.pushLayer = {}
	HhdzInfo:clear()
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
	package.loaded["hongheidazhan"] = nil
end

return hongheidazhan
