
-- 桌子列表

local GameDeskLayer = class("GameDeskLayer",BaseWindow)

function GameDeskLayer:ctor()
	self.super.ctor(self,0,false)

	self:initData()

	self:bindEvent()

	self:initUI()
	
	LoadingLayer:removeLoading()
end

function GameDeskLayer:initData()
	local uNameId = GameCreator:getCurrentGameNameID()
	self.roomInfo = RoomInfoModule:getRoomInfoByNameID(uNameId)[globalUnit.iRoomIndex]
	-- luaDump(self.roomInfo,"self.roomInfo")
	self.deskCount = 0;
	self.deskInfo = {};
	self.MaxCount = 5;  --游戏最大人数
	self.recodeReqDeskList = {}
end

function GameDeskLayer:bindEvent()
	self:pushGlobalEventInfo("roomLoginSuccess", handler(self, self.onReceiveRoomLoginSuccess))
	-- self:pushGlobalEventInfo("I_R_M_UserSit", handler(self, self.onReceiveUserCome))
	-- self:pushGlobalEventInfo("I_R_M_UserUp", handler(self, self.onReceiveUserLeft))
	self:pushGlobalEventInfo("exitGameBackPlatform",handler(self, self.onReceiveBackDesk))--回大厅刷新
	self:pushGlobalEventInfo("I_P_M_Login",handler(self, self.onReceiveLogin))--断线重连刷新
	-- self:pushGlobalEventInfo("I_R_M_GameBegin",handler(self, self.onReceiveGameBegin))--断线重连刷新
	-- self:pushGlobalEventInfo("I_R_M_GameEnd",handler(self, self.onReceiveGameEnd))--断线重连刷新
	-- self:pushGlobalEventInfo("H_R_M_UserPoint",handler(self, self.onReceiveUserPoint))
	self:pushGlobalEventInfo("I_R_M_DisConnect",handler(self, self.onReceiveDisConnect))
	self:pushGlobalEventInfo("I_R_M_SitError",handler(self, self.onReceiveSitError))

	self:pushEventInfo(VipInfo,"guildDeskInfo",handler(self, self.recguildDeskInfo))
	self:pushEventInfo(VipInfo,"guildDeskInfoUpdate",handler(self, self.recguildDeskInfoUpdate))

	
end

function GameDeskLayer:initUI()
	local size = cc.Director:getInstance():getWinSize();

	local layer = display.getRunningScene():getChildByName("VipCreateGoldRoomLayer")
    if layer then
    	layer:setVisible(false)
    end

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,0.5))
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setContentSize(cc.size(920, 410))
	listView:setPosition(size.width/2+120,size.height*0.4+80)
	self:addChild(listView)
	self.listView = listView

	local guatiao = ccui.ImageView:create("newExtend/vip/common/di1.png")
    guatiao:setPosition(size.width*0.5+585,size.height*0.6)
    guatiao:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(guatiao)

    local gameName = "德州扑克"
    local msg = ""
	if globalUnit.iRoomIndex == 1 then
		msg = "平民场"
	elseif globalUnit.iRoomIndex == 2 then
		msg = "小资场"
	elseif globalUnit.iRoomIndex == 3 then
		msg = "老板场"
	elseif globalUnit.iRoomIndex == 4 then
		msg = "富豪场"
	end
    local Label_name = FontConfig.createWithSystemFont(self:changeNameErect(gameName..msg),30 ,cc.c3b(90, 44, 14));
    Label_name:setPosition(guatiao:getContentSize().width/2+10,guatiao:getContentSize().height/2-10)
    Label_name:setAnchorPoint(0.5,0.5)
    Label_name:setContentSize(cc.size(50,260))
    guatiao:addChild(Label_name)

    local btn = ccui.Button:create("newExtend/vip/viphall/kuaisukaishi.png","newExtend/vip/viphall/kuaisukaishi-on.png")
	btn:setPosition(105+size.width/2, 75)
	btn:setAnchorPoint(0.5,0)
	btn:setTag(1)
	self:addChild(btn)
	btn:onClick(handler(self, self.onClick))
	self.bottomNode = btn

	VipInfo:sendGuildDeskReq(globalUnit.nowTingId)
end

function GameDeskLayer:createDeskList(row)
	local index = (row - 1) * 3 + 1

	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(self.listView:getContentSize().width,240))

	local size = layout:getContentSize()

	local dis = 80
	local x = size.width/2 - 80
	local w = 0
	local y = size.height/2-20

	for i=1,3 do
		if index <= self.deskCount then
			
			local node = require("dezhoupuke.DeskNode"):create(index,self.deskInfo,self.roomInfo.uRoomID,self.MaxCount)
			luaPrint("index = "..index)
			layout:addChild(node)
			table.insert(self.deskNodes, node)

			if w == 0 then
				w = node:getContentSize().width
				x = x - w
			end

			node:setPosition(x,y)
			node:setTag(index-1)

			x = x + w + dis
			
			index = index + 1

			
		end
	end

	return layout
end

function GameDeskLayer:onReceiveRoomLoginSuccess(data)
	-- addScrollMessage("onReceiveRoomLoginSuccess")
	luaPrint("onReceiveRoomLoginSuccess   self.selectDeskNo ===  "..tostring(self.selectDeskNo))
	if self.selectDeskNo then
		dispatchEvent("selectDesk",self.selectDeskNo)
		self.selectDeskNo = nil
	else
		self:initData()
		-- self:onReceiveUserCome()
		VipInfo:sendGuildDeskReq(globalUnit.nowTingId)
	end
end

function GameDeskLayer:recguildDeskInfo(data)
	local data = data._usedata;
    local code = data[2];

     if code== 0 or code== 1 then--
        for k,v in pairs(data[1]) do
            table.insert(self.recodeReqDeskList,v)
        end
    end

    if code == 1 then
    	-- self.deskInfo = data[1]
    	-- self.deskCount = #data[1];
    	self:refreshDeskData(self.recodeReqDeskList)
    	self.recodeReqDeskList = {}
    	self:onReceiveUserCome();
    	local layer = display.getRunningScene():getChildByName("DeskInfoLayer")
		if layer then
			local isRemove = true;
			for k,v in pairs(self.deskInfo) do
				if v.iDeskNo == layer.deskNo then
					layer:refreshLayer(v)
					isRemove = false;
				end 
			end
			if isRemove then
				layer:delayCloseLayer(0);
			end
		end
    end
end

function GameDeskLayer:recguildDeskInfoUpdate(data)
	local data = data._usedata;
	if data.updateType == 1 or data.updateType == 2 then
		local index = 0;
		for k,v in pairs(self.deskInfo) do
			if v.iDeskIndex == data.iDeskIndex then
				index = k;
				v.iDeskUser[data.bDeskStation+1] = data.deskUser;
				v.eState = data.eState;
			end
		end
		if index >0 and self.deskNodes[index] then
			self.deskNodes[index]:refreshDesk(self.deskInfo)
		end
	end
end


function GameDeskLayer:refreshDeskData(data)
	local len = #data;
	for i =len,1,-1 do
		if data.iDeskIndex == -1 then
			table.remove(data,i)
		end
	end
	self.deskInfo = data
    self.deskCount = #data;
end

function GameDeskLayer:onReceiveUserCome(data)
	if data == nil then
		self.deskNodes = {}
		self.listView:removeAllChildren()
		local line = math.ceil(self.deskCount / 3)

		for i=1,line do
			local layout = self:createDeskList(i)
			self.listView:pushBackCustomItem(layout)
		end
	else
		local data = data._usedata
		if self.deskNodes[data.bDeskNO+1] then
			self.deskNodes[data.bDeskNO+1]:refreshDesk()
		end
	end
end


--游戏返回刷新桌子
function GameDeskLayer:onReceiveBackDesk(data)
	if not RoomLogic:isConnect() then
		luaPrint("onReceiveBackDesk ===========  ")
		dispatchEvent("matchRoom",{self.roomInfo.uRoomID,2})
		self.selectDeskNo = nil
	else
		VipInfo:sendGuildDeskReq(globalUnit.nowTingId);
	end

	self.isClickQuick = nil
end

function GameDeskLayer:onReceiveDisConnect()
	-- addScrollMessage("onReceiveDisConnect")
	self:stopActionByTag(666)

	local func = function()
		local node = display.getRunningScene():getChildByTag(1421);

		if not node and not Hall:isHaveGameLayer() then
			luaPrint("onReceiveDisConnect ====== ")
			self:onReceiveBackDesk()
		end
	end
	performWithDelay(self,func,3):setTag(666)
end

function GameDeskLayer:onReceiveLogin(data)
	-- addScrollMessage("onReceiveLogin")
	local data = data._usedata

	if data.logined then
		self:stopActionByTag(555)

		local func = function()
			local node = display.getRunningScene():getChildByTag(1421);
			if not node then
				luaPrint("onReceiveLogin =============")
				self:onReceiveBackDesk()
				self:stopActionByTag(555)
			end
		end

		local action = schedule(self,func,0.5)
		action:setTag(555)		
	end
end

function GameDeskLayer:onClick(sender)
	local tag = sender:getTag()
	luaPrint("快速开始 "..tag)
	if tag == 1 then--快速开始
		if self.isClickQuick or #self.deskInfo == 0 then
			return
		end

		self.selectDeskNo = nil

		for k,v in pairs(self.deskInfo) do
			local count = 0;
			for k,v in pairs(v.iDeskUser) do
				if v.iUserId >0 then
					count = count + 1;
				end
			end
			v.count = count;
		end

		table.sort(self.deskInfo, function(a,b) return a.count > b.count; end)

		for k,v in pairs(self.deskInfo) do
			if v.count <self.MaxCount and v.iDeskIndex ~= -1 then
				-- dispatchEvent("selectDesk",v.iDeskIndex)
				self.selectDeskNo = v.iDeskIndex;
				break;
			end
		end

		local isIndesk = false;
		for k,v in pairs(self.deskInfo) do
			for kk,vv in pairs(v.iDeskUser) do
				if vv.iUserId == PlatformLogic.loginResult.dwUserID then 
					isIndesk = true;
					break;
				end
			end
		end
		
		self.isClickQuick = true
		self.isQuick = true
		-- LoadingLayer:createLoading(FontConfig.gFontConfig_22, "正在进入房间,请稍后", LOADING):removeTimer(10)
		
		performWithDelay(self,function() self.isClickQuick = nil self.isQuick = nil end,5)
			
		if isIndesk then
			dispatchEvent("matchRoom",self.roomInfo.uRoomID)
		else
			dispatchEvent("selectDesk",self.selectDeskNo)
		end
		-- dispatchEvent("matchRoom",self.roomInfo.uRoomID)
	end
end


function GameDeskLayer:onReceiveSitError(data)
	self.isClickQuick = nil
	self.isQuick = nil
	self.selectDeskNo = nil
end

--改变名字的竖直(必须全是汉字)
function GameDeskLayer:changeNameErect(gameName)
  local name = string.sub(gameName,1,3)
  local len = (#gameName)/3;
  for i=1,len do
  	name = name.."\n"..string.sub(gameName,3*i+1,3*(i+1))
  end
  return name;
end

return GameDeskLayer
