local errenniuniu = {}

errenniuniu.step = 0
errenniuniu.pushLayer = {}

function errenniuniu:start(params,isBack)
	self.name = "errenniuniu"
		self.plistName = 
			{
				"errenniuniu/errenniuniu",
				"errenniuniu/card",
			}
	self:setRes()

	if self.pushLayer == nil then
		self.pushLayer = {}
	end

	if self.step < 0 then
		self.step = 0
	end

	local runningScene = display.getRunningScene()

	local layer = nil
	local zorder = layerZorder

	luaPrint("errenniuniu.step"..self.step,self.noBackRoom,self.erterRoom,isBack)
	-- luaDump(params,"params")

	if isBack~=nil then
		self.step = 2;
		self.erterRoom = true;
		self.reStart = nil;
	end

	if self.step == 0 then
		--房间选择界面， 具体游戏自己写
		self.noBackRoom = true;
		self.step = 1;
		-- layer = loadScript("errenniuniu.CreateGoldRoomLayer"):create("ernn");
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("dz_ernn")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("ernn")
		end
		table.insert(self.pushLayer,layer);
	elseif self.step == 1 then
		dispatchEvent("loginRoom");
		-- layer = loadScript("errenniuniu.LoadLayer"):create(function() Hall:selectedGame("errenniuniu",params) end)
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
		-- self.step = 3
		dispatchEvent("loginRoom");
		self:ClearAllGameLayer();
		if (self.erterRoom or self.noBackRoom == nil) and params~=nil or globalUnit.VipRoomList then
			layer = loadScript("errenniuniu.TableLayer"):create(params[1], params[2], params[3], params[4])
			layer:setName("gameLayer")
			dispatchEvent("enterGameAndStopCheckNet")--停止大厅心跳检测
			self.erterRoom = nil;
		else
			layer = loadScript("errenniuniu.MatchTableLayer"):create();
			layer:setName("mGameLayer")
			layer:showFangjian();
		end
		zorder = gameZorder
		table.insert(self.pushLayer,layer);
	end

	if layer then
		layer:setLocalZOrder(zorder+self.step)
		runningScene:addChild(layer)
	end
end
--清除所有游戏界面
function errenniuniu:ClearAllGameLayer()
	for k,oldlayer in pairs(self.pushLayer) do
		if oldlayer and not tolua.isnull(oldlayer) and (oldlayer:getName() == "gameLayer" or oldlayer:getName() == "mGameLayer") then
			table.removebyvalue(self.pushLayer,oldlayer);
			if oldlayer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				RoomLogic:stopCheckNet()
				dispatchEvent("startCheckNet")
			end
			oldlayer:delayCloseLayer(0)
		end
	end
end

--开始游戏重新创建tablelayer
function errenniuniu:ReSetTableLayer()
	
	luaPrint("---errenniuniu:ReSetTableLayer-----")
	luaDump(self.pushLayer)
	local runningScene = display.getRunningScene()
	self.step = 2;
	self.erterRoom = true;
	self.noBackRoom = true;
	self.reStart = nil;
	layer = loadScript("errenniuniu.MatchTableLayer"):create();
	layer:setName("mGameLayer")
	if layer then
		layer:setLocalZOrder(gameZorder+self.step)
		runningScene:addChild(layer)
	end
	table.insert(self.pushLayer,layer);
	layer:showFangjian();
end

function errenniuniu:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/errenniuniu",true)
	cc.FileUtils:getInstance():addSearchPath("src/errenniuniu",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/errenniuniu",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/errenniuniu",true)
	end

	GameMsg = loadScript("errenniuniu.GameMsg")
	if self.isSetRes then
		return
	end
	self.isSetRes = true

	ERNNInfo = loadScript("errenniuniu.ERNNInfo")
	
end

--所有游戏此函数不改
function errenniuniu:exitGame(dt,callback)
	self.step = self.step - 1
	self.erterRoom = nil
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
			if callback then
				luaPrint("gamelayer 设置回调函数")
			else
				luaPrint("gamelayer 没有设置回调函数")
			end
			layer:delayCloseLayer(dt,callback)
		end

		if #self.pushLayer == 0 and self.reStart == nil then
			ERNNInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["errenniuniu"] = nil
			self.backRoom = true
		end
	end
end

function errenniuniu:directExitGame()
	self.step = 0
	self.pushLayer = {}
	ERNNInfo:clear()
	if self == Hall.lastGame then
		Hall.lastGame = nil
	end
	package.loaded["errenniuniu"] = nil
	self.backRoom = true
end

return errenniuniu
