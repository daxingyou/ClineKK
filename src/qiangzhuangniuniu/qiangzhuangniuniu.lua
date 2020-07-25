
-- 抢庄牛牛

local qiangzhuangniuniu = {}

qiangzhuangniuniu.step = 0
qiangzhuangniuniu.pushLayer = {}

function qiangzhuangniuniu:start(params,isBack)
	self.name = "qiangzhuangniuniu"
	self.plistName = {
						"qiangzhuangniuniu/qiangzhuangniuniu",
						"qiangzhuangniuniu/gold",
						"qiangzhuangniuniu/card",
					}
	self:setRes()

	if self.pushLayer == nil then
		self.pushLayer = {}
	end

	-- if self.step < 0 or not params then
	-- 	self.step = 0
	-- end
	luaPrint("doudizhu_self.step"..self.step,self.noBackRoom,self.erterRoom,isBack)

	local runningScene = display.getRunningScene()

	local layer = nil
	local zorder = layerZorder

	if isBack~=nil then
		self.step = 2;
		self.erterRoom = true;
		self.reStart = nil;
	end

	if self.step == 0 then
		--房间选择界面， 具体游戏自己写
		self.noBackRoom = true;
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("dz_qzps")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("qzps")
		end
		table.insert(self.pushLayer,layer)
		self.step = 1
	elseif self.step == 1 then
		dispatchEvent("loginRoom")
		-- layer = loadScript("qiangzhuangniuniu.LoadLayer"):create(function() Hall:selectedGame("qiangzhuangniuniu",params) end)
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
		dispatchEvent("loginRoom");
		self:ClearAllGameLayer();
		if (self.erterRoom or self.noBackRoom == nil) and params~=nil or globalUnit.VipRoomList then
			layer = loadScript("qiangzhuangniuniu.TableLayer"):create(params[1], params[2], params[3], params[4])
			zorder = gameZorder
			layer:setName("gameLayer")
			dispatchEvent("enterGameAndStopCheckNet")--停止大厅心跳检测
			self.erterRoom = nil;
		else
			layer = loadScript("qiangzhuangniuniu.MatchTableLayer"):create();
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
function qiangzhuangniuniu:ClearAllGameLayer()
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
function qiangzhuangniuniu:ReSetTableLayer(userScore,cellScore)
	
	luaPrint("---qiangzhuangniuniu:ReSetTableLayer-----",userScore)
	local runningScene = display.getRunningScene()
	self.step = 2;
	self.erterRoom = true;
	self.noBackRoom = true;
	self.reStart = nil;
	layer = loadScript("qiangzhuangniuniu.MatchTableLayer"):create(userScore,cellScore);
	layer:setName("mGameLayer")
	if layer then
		layer:setLocalZOrder(gameZorder+self.step)
		runningScene:addChild(layer)
	end
	table.insert(self.pushLayer,layer);
	layer:showFangjian();
end

function qiangzhuangniuniu:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/qiangzhuangniuniu",true)
	cc.FileUtils:getInstance():addSearchPath("src/qiangzhuangniuniu",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/qiangzhuangniuniu",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/qiangzhuangniuniu",true)
	end
		
	GameMsg = loadScript("qiangzhuangniuniu.GameMsg");

	if self.isSetRes then
		return
	end
	self.isSetRes = true

	QznnInfo = loadScript("qiangzhuangniuniu.QznnInfo");
end

--所有游戏此函数不改
function qiangzhuangniuniu:exitGame(dt,callback)
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
			QznnInfo:clear()
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["qiangzhuangniuniu"] = nil
			self.backRoom = true
		end
	end
end

function qiangzhuangniuniu:directExitGame()
	self.step = 0
	self.pushLayer = {}
	QznnInfo:clear()
	package.loaded["qiangzhuangniuniu"] = nil
	if self == Hall.lastBackGame then
		Hall.lastGame = nil
	end
	self.backRoom = true
end

return qiangzhuangniuniu
