
--三张牌

local sanzhangpai = {}

sanzhangpai.step = 0
sanzhangpai.pushLayer = {}

function sanzhangpai:start(params,isBack)
	self.name = "sanzhangpai"
	self.plistName = {
						"sanzhangpai/image/img_szp",
						"sanzhangpai/image/szp_card",
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

	if isBack~=nil then
		self.step = 2;
		self.erterRoom = true;
		self.reStart = nil;
	end

	dump(params,"333333")
	luaPrint("self.step",self.step)
	if self.step == 0 then
		--房间选择界面， 具体游戏自己写		
		-- layer = loadScript("CreateGoldRoomLayer"):create("szp")
		self.noBackRoom = true;
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("dz_szp")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("szp")
			layer:setName("CreateGoldRoomLayer");
		end
		table.insert(self.pushLayer,layer)
		self.step = 1
	elseif self.step == 1 then
		dispatchEvent("loginRoom")
		-- layer = loadScript("sanzhangpai.LoadLayer"):create(function() Hall:selectedGame("sanzhangpai",params) end)
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
		if (self.erterRoom or self.noBackRoom == nil) and params~=nil then
			dump(params,"1111111")
			layer = loadScript("sanzhangpai.TableLayer"):create(params[1], params[2], params[3], params[4])
			layer:setName("gameLayer")
			dispatchEvent("enterGameAndStopCheckNet")--停止大厅心跳检测
			self.erterRoom = nil;
		else
			dump(params,"2222222")
			layer = loadScript("sanzhangpai.MatchTableLayer"):create();
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
function sanzhangpai:ClearAllGameLayer()
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

function sanzhangpai:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/sanzhangpai",true)
	cc.FileUtils:getInstance():addSearchPath("src/sanzhangpai",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/sanzhangpai",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/sanzhangpai",true)
	end

	GameMsg = loadScript("sanzhangpai.GameMsg")

	if self.isSetRes then
		return
	end
	self.isSetRes = true

	SZPInfo = loadScript("sanzhangpai.SZPInfo")
end

--所有游戏此函数不改
function sanzhangpai:exitGame(dt,callback)
	self.step = self.step - 1
	self.erterRoom = nil
	if not isEmptyTable(self.pushLayer) then
		
		local layer = self.pushLayer[#self.pushLayer]

		local flag = false;
		if layer and not tolua.isnull(layer) then
			table.removebyvalue(self.pushLayer,layer)
			if layer:getName() == "gameLayer" then--退出游戏的时候，开启大厅心跳
				-- RoomLogic:stopCheckNet()
				-- dispatchEvent("startCheckNet")
				if globalUnit.VipRoomList and globalUnit.nowTingId > 0 then
					self.step = self.step + 1
				end
				flag = true;
			end
			if callback then
				luaPrint("gamelayer 设置回调函数")
			else
				luaPrint("gamelayer 没有设置回调函数")
			end
			layer:delayCloseLayer(dt,callback)
		end

		if #self.pushLayer == 0 and self.reStart == nil then
			flag = false;
			SZPInfo:clear()
			if nil == Hall.lastBackGame  then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["sanzhangpai"] = nil
			self.backRoom = true
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

function sanzhangpai:directExitGame()
	self.step = 0
	self.pushLayer = {}
	SZPInfo:clear()
	package.loaded["sanzhangpai"] = nil
	if self == Hall.lastBackGame then
		Hall.lastGame = nil
	end
	
end

--开始游戏重新创建tablelayer
function sanzhangpai:ReSetTableLayer()
	luaPrint("---sanzhangpai:ReSetTableLayer-----",userScore)
	local runningScene = display.getRunningScene()
	self.step = 2;
	self.erterRoom = true;
	self.noBackRoom = true;
	self.reStart = nil;
	layer = loadScript("sanzhangpai.MatchTableLayer"):create(userScore,cellScore);
	layer:setName("mGameLayer")
	if layer then
		layer:setLocalZOrder(gameZorder+self.step)
		runningScene:addChild(layer)
	end
	table.insert(self.pushLayer,layer);
	layer:showFangjian();
end

return sanzhangpai
