
-- 桌子节点

local DeskNode = class("DeskNode",function() return ccui.Layout:create() end)
local DeskInfoLayer = require("sanzhangpai.DeskInfoLayer");
-- //桌子信息
local DeskInfo = class("DeskInfo")

function DeskInfo:ctor()
	self.deskID 		= 0;			   	--// 桌号
	self.multiple 		= 0;			 	--// 倍率
	self.goldMin 		= 0;			  	--// 最小携带金钱
	self.goldMax 		= 0;			  	--// 最大携带金钱
	self.peopleValue 	= 0;		  		--// 桌子当前人数
	self.peopleMax 		= 0;				--// 桌子最大人数
	self.isLocked 		= 0;			 	--// 是否锁桌
end

function DeskNode:create(index,deskInfo,uRoomID,MaxCount)
	return DeskNode.new(index,deskInfo,uRoomID,MaxCount)
end

function DeskNode:ctor(index,deskInfo,uRoomID,MaxCount)
	self.index = index
	self.deskInfo = deskInfo
	self.uRoomID = uRoomID
	self.MaxCount = MaxCount;
	-- luaDump(self.deskInfo,"self.deskInfo = DeskNode")
	self:initData()

	self:initUI()
end

function DeskNode:initData()
	self.pos = {{0,0.7},{0.5,0.4},{1,0.7},{0.7,1},{0.3,1}}
end

function DeskNode:initUI()
	self:setAnchorPoint(0.5,0.5)
	local bg = ccui.ImageView:create("desk/zhuozi.png")
	self:setContentSize(bg:getContentSize())
	bg:setPosition(bg:getContentSize().width/2-20,bg:getContentSize().height/2)
	self:addChild(bg)
	self.bg = bg

	local size = bg:getContentSize()
	self.head = {}
	for i=1,self.MaxCount do
		local headKuang = ccui.ImageView:create("desk/touxiangkuang.png")
		headKuang:setPosition(bg:getContentSize().width*self.pos[i][1],bg:getContentSize().height*self.pos[i][2])
		self.bg:addChild(headKuang)
		local head = ccui.ImageView:create("head/1.png")
		head:setPosition(headKuang:getContentSize().width*0.5,headKuang:getContentSize().height*0.5)
		headKuang:addChild(head)
		head:setScale(0.3);
		head:setVisible(false);
		-- self.head[i] = head;
		table.insert(self.head,head)
	end

	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(size.width,size.height))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(size.width/2,size.height/2)
	btn:setCascadeOpacityEnabled(true)
	btn:setTouchEnabled(true)
	btn:setTag(self.index)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	--桌子号
	local deskNoBg = ccui.ImageView:create("desk/zhuohao-2.png")
	deskNoBg:setAnchorPoint(0.5,1)
	deskNoBg:setPosition(size.width,70)
	bg:addChild(deskNoBg)
	
	local deskNo = FontConfig.createWithCharMap(self.deskInfo[self.index].iDeskNo,"desk/zhuohao-zitiao.png",14,18,"0")
	deskNo:setPosition(deskNoBg:getContentSize().width/2,deskNoBg:getContentSize().height/2)
	deskNoBg:addChild(deskNo)

	local name = "";
	if self.deskInfo[self.index].eState == 1 then	
		name = "desk/duizhanzhong.png"
	else
		name = "desk/kongxianzhong.png"
	end
	local state = ccui.ImageView:create(name)
	state:setPosition(bg:getContentSize().width/2,bg:getContentSize().height*0.7+10)
	bg:addChild(state)
	self.state = state;

	self:refreshDesk()
end

function DeskNode:refreshDesk(deskInfo)
	if deskInfo then
		self.deskInfo = deskInfo;
		local layer = display.getRunningScene():getChildByName("DeskInfoLayer")
		if layer and layer.deskInfo.iDeskNo == self.deskInfo[self.index].iDeskNo then
			layer:refreshLayer(self.deskInfo[self.index])
		end
	end
	for k,v in pairs(self.head) do
		v:setVisible(false)
	end
	local userlist = {}
	for k,v in pairs(self.deskInfo[self.index].iDeskUser) do
		if v.iUserId >0 then 
			table.insert(userlist,v)
		end
	end
	local len = #userlist;
	for i=1,len do
		self.head[i]:setVisible(true);
		self.head[i]:loadTexture(getHeadPath(userlist[i].iLogoId));
	end

	local name = "";
	if self.deskInfo[self.index].eState == 1 then	
		name = "desk/duizhanzhong.png"
	else
		name = "desk/kongxianzhong.png"
	end
	self.state:loadTexture(name)
end

function DeskNode:onClickBtn(sender)
	local layer = display.getRunningScene():getChildByName("deskLayer")
	if not layer then
		return;
	else
		if layer.isClickQuick then
			return
		end
	end
	-- if not PlatformLogic:isConnect() then
	-- 	return
	-- end

	-- if globalUnit.isEnterGame == true then
	-- 	return
	-- end

	
	local isIndesk = false;
	for k,v in pairs(self.deskInfo) do
		for kk,vv in pairs(v.iDeskUser) do
			if vv.iUserId == PlatformLogic.loginResult.dwUserID then 
				isIndesk = true;
				break;
			end
		end
	end

	if isIndesk then
		if layer then
			layer.isClickQuick = true
			layer.selectDeskNo = self.deskInfo[self.index].iDeskIndex

			performWithDelay(layer,function() layer.isClickQuick = nil end,2)
		end
		-- LoadingLayer:createLoading(FontConfig.gFontConfig_22, "正在进入房间,请稍后", LOADING):removeTimer(10)
		dispatchEvent("matchRoom",self.uRoomID)
	else
		local tag = sender:getTag()
		local layer = DeskInfoLayer:create(tag,self.deskInfo[self.index],self.MaxCount,self.uRoomID);
		layer:setName("DeskInfoLayer")
		display.getRunningScene():addChild(layer);
	end
end




return DeskNode
