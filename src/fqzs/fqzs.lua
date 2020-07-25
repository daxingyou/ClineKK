local fqzs = {}

fqzs.step = 0
fqzs.pushLayer = {}

function fqzs:start(params)
	self.name = "fqzs"
	self.plistName = "fqzs/fqzs"
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
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("game_fqzs")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("fqzs")
		end
		
		table.insert(self.pushLayer,layer)
		self.step = 1
	elseif self.step == 1 then
		-- layer = loadScript("fqzs.LoadLayer"):create(function() Hall:selectedGame("fqzs",params) end)
		-- zorder = gameZorder
		self.step = 2
		self:start(params)
	elseif self.step == 2 then		
		layer = loadScript("fqzs.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function fqzs:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/fqzs",true)
	cc.FileUtils:getInstance():addSearchPath("src/fqzs",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/fqzs",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/fqzs",true)
	end
	luaPrint("self.isSetRes",tostring(self.isSetRes))
	
	GameMsg = loadScript("fqzs.GameMsg");
	if self.isSetRes then
		return
	end
	self.isSetRes = true

	FqzsInfo = loadScript("fqzs.FqzsInfo");
end

--所有游戏此函数不改
function fqzs:exitGame(dt,callback)
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
			FqzsInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["fqzs"] = nil
			self.backRoom = true
		end
	end
end

function fqzs:directExitGame()
	self.step = 0
	self.pushLayer = {}
	FqzsInfo:clear()
	package.loaded["fqzs"] = nil
	if self == Hall.lastBackGame then
		Hall.lastGame = nil
	end
	self.backRoom = true
end

return fqzs
