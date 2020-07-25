require("shisanzhanglq.CommonFunc")
require("shisanzhanglq.CommonUI")
require("shisanzhanglq.TableStructs")
require("shisanzhanglq.TableGlobal")
require("shisanzhanglq.TableConfig")
require("shisanzhanglq.TableUtil")

local shisanzhanglq = {}

shisanzhanglq.step = 0
shisanzhanglq.pushLayer = {}

function shisanzhanglq:start(params, isBack)
	self.name = "shisanzhanglq"
	self.plistName = {
		"shisanzhanglq/cards/cards",
	}
	self:setRes()

	if self.pushLayer == nil then
		self.pushLayer = {}
	end

	luaPrint("self.step----------", self.step)

	if self.step < 0 then
		self.step = 0
	end

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
		-- layer = loadScript("shisanzhanglq.CreateGoldRoomLayer"):create("dz_ssz")
		if globalUnit.VipRoomList then
			layer = loadScript("VipCreateGoldRoomLayer"):create("dz_lq_ssz")
			layer:setName("VipCreateGoldRoomLayer")
			zorder = 998
		else
			layer = loadScript("CreateGoldRoomLayer"):create("dz_lq_ssz")
		end
		table.insert(self.pushLayer,layer)
		self.step = 1
	elseif self.step == 1 then
		dispatchEvent("loginRoom");
		-- layer = loadScript("shisanzhanglq.LoadLayer"):create(function() Hall:selectedGame("shisanzhanglq",params) end)
		-- zorder = gameZorder
		self.step = 2
		if globalUnit.VipRoomList then
			layer = loadScript("GameDeskLayer"):create(globalUnit.iPlayCount)
			layer:setName("deskLayer")
			zorder = 997
			table.insert(self.pushLayer,layer)
		else
			self:start(params)
		end
	elseif self.step == 2 then	
		dispatchEvent("loginRoom");
		self:ClearAllGameLayer();
		luaPrint("111111111")
		if (self.erterRoom or self.noBackRoom == nil) and params~=nil or globalUnit.VipRoomList then
			luaPrint("22222222222")

			self:reset(params and params[1])
			layer = loadScript("shisanzhanglq.TableLayer"):create(params[1], params[2], params[3], params[4])
			layer:setName("gameLayer")
			dispatchEvent("enterGameAndStopCheckNet")--停止大厅心跳检测
			self.erterRoom = nil;
		else

			luaPrint("3333333333")
			layer = loadScript("shisanzhanglq.MatchTableLayer"):create();
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

function shisanzhanglq:reset(uNameId)
	if uNameId==40028010 then
		PLAY_COUNT = 4
	elseif uNameId==40028011 then
		PLAY_COUNT = 8
	elseif uNameId==40028012 then 
		PLAY_COUNT = 6
	end

	GameMsg = loadScript("shisanzhanglq.GameMsg");
	if shisanzhanglqInfo then
		shisanzhanglqInfo:clear()
	end
	shisanzhanglqInfo = loadScript("shisanzhanglq.shisanzhanglqInfo");
end

--清除所有游戏界面
function shisanzhanglq:ClearAllGameLayer()
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
function shisanzhanglq:ReSetTableLayer(userScore,cellScore)
	
	luaPrint("---shisanzhanglq:ReSetTableLayer-----",userScore)
	local runningScene = display.getRunningScene()
	self.step = 2;
	self.erterRoom = true;
	self.noBackRoom = true;
	self.reStart = nil;
	layer = loadScript("shisanzhanglq.MatchTableLayer"):create(userScore,cellScore);
	layer:setName("mGameLayer")
	if layer then
		layer:setLocalZOrder(gameZorder+self.step)
		runningScene:addChild(layer)
	end
	table.insert(self.pushLayer,layer);
	layer:showFangjian();
end

function shisanzhanglq:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/shisanzhanglq",true)
	cc.FileUtils:getInstance():addSearchPath("src/shisanzhanglq",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/shisanzhanglq",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/shisanzhanglq",true)
	end
	luaPrint("self.isSetRes",tostring(self.isSetRes))
	
	if self.isSetRes then
		return
	end
	self.isSetRes = true

end

--所有游戏此函数不改
function shisanzhanglq:exitGame(dt,callback)
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
			if shisanzhanglqInfo then
				shisanzhanglqInfo:clear()
			end
			if nil == Hall.lastBackGame then
				Hall.lastGame = nil
				dispatchEvent("exitCreateRoom")
			end
			package.loaded["shisanzhanglq"] = nil
			self.backRoom = true
		end
	end
end

function shisanzhanglq:directExitGame()
	self.step = 0
	self.pushLayer = {}
	if shisanzhanglqInfo then
		shisanzhanglqInfo:clear()
	end
	package.loaded["shisanzhanglq"] = nil
	if self == Hall.lastBackGame then
		Hall.lastGame = nil
	end
	self.backRoom = true
end

return shisanzhanglq
