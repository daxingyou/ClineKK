
-- 德州扑克

local dezhoupuke = {}

dezhoupuke.step = 0
dezhoupuke.pushLayer = {}

function dezhoupuke:start(params)
	self.name = "dezhoupuke"
	self.plistName = {
					"dezhoupuke/image/img_dzpk",
					"dezhoupuke/image/gold",
					"dezhoupuke/image/card",
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
		-- layer = loadScript("CreateGoldRoomLayer"):create("dzpk")
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("dz_dzpk")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("dzpk")
		end
		table.insert(self.pushLayer,layer)
		self.step = 1
	elseif self.step == 1 then
		dispatchEvent("loginRoom")
		-- layer = loadScript("dezhoupuke.LoadLayer"):create(function() Hall:selectedGame("dezhoupuke",params) end)
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
		
		layer = loadScript("dezhoupuke.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function dezhoupuke:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/dezhoupuke",true)
	cc.FileUtils:getInstance():addSearchPath("src/dezhoupuke",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/dezhoupuke",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/dezhoupuke",true)
	end
		
	GameMsg = loadScript("dezhoupuke.GameMsg");

	if self.isSetRes then
		return
	end
	self.isSetRes = true

	DzpkInfo = loadScript("dezhoupuke.DzpkInfo");
end

--所有游戏此函数不改
function dezhoupuke:exitGame(dt,callback)
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
			DzpkInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["dezhoupuke"] = nil
		end
	end
end

function dezhoupuke:directExitGame()
	self.step = 0
	self.pushLayer = {}
	DzpkInfo:clear()
	package.loaded["dezhoupuke"] = nil
	if self == Hall.lastBackGame then
		Hall.lastGame = nil
	end
end

return dezhoupuke
