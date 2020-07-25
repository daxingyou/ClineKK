local lianhuanduobao = {}

lianhuanduobao.step = 0
lianhuanduobao.pushLayer = {}

function lianhuanduobao:start(params)
	self.name = "lianhuanduobao"
	self.plistName = 
	{
		"lianhuanduobao/GameScene",
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
			layer = loadScript("VipCreateGoldRoomLayer"):create("game_lhdb")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("game_lhdb")
			layer:setName("CreateGoldRoomLayer");
		end
		self.step = 1
		table.insert(self.pushLayer,layer)
	elseif self.step == 1 then
		self.step = 2
		self:start(params)
	elseif self.step == 2 then
		layer = loadScript("lianhuanduobao.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function lianhuanduobao:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/lianhuanduobao",true)
	cc.FileUtils:getInstance():addSearchPath("src/lianhuanduobao",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/lianhuanduobao",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/lianhuanduobao",true)
	end
	GameMsg = loadScript("lianhuanduobao.GameMsg")
	if self.isSetRes then
		return
	end
	self.isSetRes = true

	lianhuanduobaoInfo = loadScript("lianhuanduobao.lianhuanduobaoInfo")
end

--所有游戏此函数不改
function lianhuanduobao:exitGame(dt,callback)
	self.step = self.step - 1

	if not isEmptyTable(self.pushLayer) then
		local layer = self.pushLayer[#self.pushLayer]

		local flag = false;
		if layer and not tolua.isnull(layer) then
			table.removebyvalue(self.pushLayer,layer)
			if layer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				--RoomLogic:stopCheckNet()
				--dispatchEvent("startCheckNet")
				flag = true;
			end

			layer:delayCloseLayer(dt,callback)
		end

		if #self.pushLayer == 0 then
			flag = false;
			lianhuanduobaoInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["lianhuanduobao"] = nil
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

function lianhuanduobao:directExitGame()
	self.step = 0
	self.pushLayer = {}
	lianhuanduobaoInfo:clear()
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
	package.loaded["lianhuanduobao"] = nil
end

return lianhuanduobao
