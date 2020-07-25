
-- 抢庄牛牛

local ershiyidian = {}

ershiyidian.step = 0
ershiyidian.pushLayer = {}

function ershiyidian:start(params)
	luaPrint("ershiyidian",self.step);
	self.name = "ershiyidian"
	self.plistName = {
						"ershiyidian/ershiyidian",
						"ershiyidian/card",
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
		-- layer = loadScript("ershiyidian.CreateGoldRoomLayer"):create("esyd")
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("dz_esyd")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("esyd")
		end
		table.insert(self.pushLayer,layer)
		self.step = 1
	elseif self.step == 1 then
		dispatchEvent("loginRoom")
		-- layer = loadScript("ershiyidian.LoadLayer"):create(function() Hall:selectedGame("ershiyidian",params) end)
		-- zorder = gameZorder
		self.step = 2
		if globalUnit.VipRoomList then
			layer = loadScript("GameDeskLayer"):create()
			layer:setName("deskLayer")
			zorder = 997
			table.insert(self.pushLayer,layer)
		else
			self:start(params)
		end
	elseif self.step == 2 then	
		--self.step = 3	
		layer = loadScript("ershiyidian.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function ershiyidian:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/ershiyidian",true)
	cc.FileUtils:getInstance():addSearchPath("src/ershiyidian",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/ershiyidian",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/ershiyidian",true)
	end
		
	GameMsg = loadScript("ershiyidian.GameMsg");

	if self.isSetRes then
		return
	end
	self.isSetRes = true

	ESYDInfo = loadScript("ershiyidian.ESYDInfo");
end

--所有游戏此函数不改
function ershiyidian:exitGame(dt,callback)
	self.step = self.step - 1
	
	if not isEmptyTable(self.pushLayer) then
		
		local layer = self.pushLayer[#self.pushLayer]
		
		if layer and not tolua.isnull(layer) then
			table.removebyvalue(self.pushLayer,layer)
			if layer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				-- RoomLogic:stopCheckNet()
				-- dispatchEvent("startCheckNet")
				if globalUnit.VipRoomList and globalUnit.nowTingId > 0 then
					self.step = self.step + 1
				end
			end

			layer:delayCloseLayer(dt,callback)
		end

		if #self.pushLayer == 0 then
			ESYDInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["ershiyidian"] = nil
		end
	end
end

function ershiyidian:directExitGame()
	self.step = 0
	self.pushLayer = {}
	ESYDInfo:clear()
	package.loaded["ershiyidian"] = nil
	if self == Hall.lastBackGame then
		Hall.lastGame = nil
	end
end

return ershiyidian
