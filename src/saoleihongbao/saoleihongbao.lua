local saoleihongbao = {}

saoleihongbao.step = 0
saoleihongbao.pushLayer = {}

function saoleihongbao:start(params)
	self.name = "saoleihongbao"
	self.plistName = {
						"saoleihongbao/image/slhb_image1",
						"saoleihongbao/image/slhb_image2",
						"saoleihongbao/image/slhb_finger",
						
					}

	self:setRes()

	if self.pushLayer == nil then
		self.pushLayer = {}
	end

	-- if self.step < 0 or not params then
	-- 	self.step = 0
	-- end

	local runningScene = display.getRunningScene()

	local layer = nil
	local zorder = layerZorder

	if self.step == 0 then
		--房间选择界面， 具体游戏自己写
		-- layer = loadScript("CreateGoldRoomLayer"):create("slhb")
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("game_slhb")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("slhb")
			layer:setName("CreateGoldRoomLayer");
		end
		table.insert(self.pushLayer,layer)
		self.step = 1
	elseif self.step == 1 then
		dispatchEvent("loginRoom")
		-- layer = loadScript("saoleihongbao.LoadLayer"):create(function() Hall:selectedGame("saoleihongbao",params) end);
		-- zorder = gameZorder
		self.step = 2
		self:start(params)
	elseif self.step == 2 then
		layer = loadScript("saoleihongbao.TableLayer"):create(params[1], params[2], params[3], params[4]);
		zorder = gameZorder
		layer:setName("gameLayer")
		dispatchEvent("enterGameAndStopCheckNet")--停止大厅心跳检测
		table.insert(self.pushLayer,layer)
	end

	if layer then
		layer:setLocalZOrder(zorder+self.step)
		runningScene:addChild(layer)

		-- if layer:getName() ~= "loadLayer" then
		-- 	table.insert(self.pushLayer,layer)
		-- end
	end
end

function saoleihongbao:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/"..self.name,true)
	cc.FileUtils:getInstance():addSearchPath("src/"..self.name,true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/"..self.name,true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/"..self.name,true)
	end

	GameMsg = loadScript("saoleihongbao.GameMsg")
	
	if self.isSetRes then
		return
	end
	self.isSetRes = true
	
	
	SLHBInfo = loadScript("saoleihongbao.SLHBInfo")

	-- SLHBInfo:init()
end

--所有游戏此函数不改
function saoleihongbao:exitGame(dt,callback)
	self.step = self.step - 1
	
	if not isEmptyTable(self.pushLayer) then
		local layer = self.pushLayer[#self.pushLayer]

		local flag = false;
		if layer and not tolua.isnull(layer) then
			table.removebyvalue(self.pushLayer,layer)
			if layer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				RoomLogic:stopCheckNet()
				dispatchEvent("startCheckNet")
				flag = true;
			end

			layer:delayCloseLayer(dt,callback)
		end

		if #self.pushLayer == 0 then
			flag = false;
			SLHBInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["saoleihongbao"] = nil
		end

		if not isEmptyTable(self.pushLayer) then
			local layer = self.pushLayer[#self.pushLayer]
			if layer and not tolua.isnull(layer) then
				if flag and layer:getName() == "CreateGoldRoomLayer" then
					Hall:exitGame();
				end
			end
		end
	end
end

function saoleihongbao:directExitGame()
	self.step = 0
	self.pushLayer = {}
	SLHBInfo:clear()
	package.loaded["saoleihongbao"] = nil
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
	
end

return saoleihongbao
