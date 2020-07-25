local shuihuzhuan = {}

shuihuzhuan.step = 0
shuihuzhuan.pushLayer = {}

function shuihuzhuan:start(params)
	self.name = "shuihuzhuan"
	self.plistName = 
	{
		"shuihuzhuan/image/tableLayer",
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
			layer = loadScript("VipCreateGoldRoomLayer"):create("game_shz")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("game_shz")
			layer:setName("CreateGoldRoomLayer");
		end
		self.step = 1
		table.insert(self.pushLayer,layer)
	elseif self.step == 1 then
		self.step = 2
		self:start(params)
	elseif self.step == 2 then
		layer = loadScript("shuihuzhuan.TableLayer"):create(params[1], params[2], params[3], params[4])
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

function shuihuzhuan:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/shuihuzhuan",true)
	cc.FileUtils:getInstance():addSearchPath("src/shuihuzhuan",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/shuihuzhuan",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/shuihuzhuan",true)
	end
	GameMsg = loadScript("shuihuzhuan.GameMsg")
	if self.isSetRes then
		return
	end
	self.isSetRes = true

	SuperFriutInfo = loadScript("shuihuzhuan.shuihuzhuanInfo")
end

--所有游戏此函数不改
function shuihuzhuan:exitGame(dt,callback)
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
			SuperFriutInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["shuihuzhuan"] = nil
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

function shuihuzhuan:directExitGame()
	self.step = 0
	self.pushLayer = {}
	SuperFriutInfo:clear()
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
	package.loaded["shuihuzhuan"] = nil
end

return shuihuzhuan
