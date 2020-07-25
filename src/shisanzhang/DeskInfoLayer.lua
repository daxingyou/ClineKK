
-- 桌子信息

local DeskInfoLayer = class("DeskInfoLayer",PopLayer)



function DeskInfoLayer:create(deskNo,deskInfo,MaxCount,uRoomID)
	return DeskInfoLayer.new(deskNo,deskInfo,MaxCount,uRoomID)
end

function DeskInfoLayer:ctor(deskNo,deskInfo,MaxCount,uRoomID)
	self.super.ctor(self, PopType.middle)
	self.deskNo = deskNo
	self.deskInfo = deskInfo
	self.MaxCount = MaxCount
	self.uRoomID = uRoomID
	-- luaDump(self.deskInfo,"self.deskInfo = DeskInfoLayer")
	self:initData()

	self:initUI()
end

function DeskInfoLayer:initData()
	
end

function DeskInfoLayer:initUI()
	self:setLocalZOrder(999+10)
	local size = self.bg:getContentSize()

	local title = ccui.ImageView:create("desk/xuanzejiaru.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title)

	--桌子号
	local deskNoBg = ccui.ImageView:create("desk/di.png")
	deskNoBg:setAnchorPoint(0.5,1)
	deskNoBg:setPosition(size.width*0.2,size.height*0.95-35)
	self.bg:addChild(deskNoBg)

	local deskNo = FontConfig.createWithCharMap(self.deskInfo.iDeskNo,"desk/di-zitiao.png",20,30,"0")
	deskNo:setPosition(deskNoBg:getContentSize().width/2,deskNoBg:getContentSize().height/2)
	deskNoBg:addChild(deskNo)

	self:updateSureBtnImage("desk/b-jiaru.png","desk/b-jiaru-on.png")
    self.sureBtn:setPosition(cc.p(size.width*0.5,size.height*0.1+5))

	-- local node = cc.Node:create();
	local node = ccui.ScrollView:create()
	node:setScrollBarEnabled(false)
	node:setPosition(0, 145)
	node:setContentSize(cc.size(1090,380));


    self.bg:addChild(node)
    self.Node_User = node

    local userlist = {}
	for k,v in pairs(self.deskInfo.iDeskUser) do
		if v.iUserId >0 then 
			table.insert(userlist,v)
		end
	end

	local sHeight = math.max(math.floor((#userlist+1)/2)*135, 380)
	node:setInnerContainerSize(cc.size(950,sHeight))

	for k,v in pairs(userlist) do

		local infoBg = ccui.ImageView:create("desk/bg.png")
		infoBg:setPosition(self.bg:getContentSize().width*0.5+((k+1)%2*2-1)*235,sHeight-135/2-math.floor((k-1)/2)*140)
		self.Node_User:addChild(infoBg)
		infoBg:setScale(0.8)

		local head = ccui.ImageView:create("head/1.png")
		head:setPosition(infoBg:getContentSize().width*0.15,infoBg:getContentSize().height*0.5+5)
		infoBg:addChild(head)
		head:setScale(0.5);
		head:loadTexture(getHeadPath(v.iLogoId));

		local nickimg = ccui.ImageView:create("desk/nicheng.png")
		nickimg:setPosition(infoBg:getContentSize().width*0.4,infoBg:getContentSize().height*0.7)
		infoBg:addChild(nickimg)

		local nickName = FontConfig.createWithSystemFont(v.nickName, 24,cc.c3b(0, 0, 0));
		nickName:setPosition(infoBg:getContentSize().width*0.5,infoBg:getContentSize().height*0.7)
		infoBg:addChild(nickName)
		nickName:setAnchorPoint(0,0.5)

		local idimg = ccui.ImageView:create("desk/id.png")
		idimg:setPosition(infoBg:getContentSize().width*0.42,infoBg:getContentSize().height*0.3)
		infoBg:addChild(idimg)

		local idstr = FontConfig.createWithSystemFont(v.iUserId, 24,cc.c3b(0, 0, 0));
		idstr:setPosition(infoBg:getContentSize().width*0.5,infoBg:getContentSize().height*0.3)
		infoBg:addChild(idstr)
		idstr:setAnchorPoint(0,0.5)

	end

	if #userlist >= self.MaxCount then
		self.sureBtn:setEnabled(false)
	end
end

function DeskInfoLayer:refreshLayer(deskInfo)
	self.deskInfo = deskInfo;
	self.Node_User:removeAllChildren();

	local userlist = {}
	for k,v in pairs(self.deskInfo.iDeskUser) do
		if v.iUserId >0 then 
			table.insert(userlist,v)
		end
	end

	local sHeight = math.max(math.floor((#userlist+1)/2)*135, 380)
	self.Node_User:setInnerContainerSize(cc.size(950,sHeight))

	for k,v in pairs(userlist) do
		local infoBg = ccui.ImageView:create("desk/bg.png")
		infoBg:setPosition(self.bg:getContentSize().width*0.5+((k+1)%2*2-1)*235,sHeight-135/2-math.floor((k-1)/2)*140)
		self.Node_User:addChild(infoBg)
		infoBg:setScale(0.8)
		local head = ccui.ImageView:create("head/1.png")
		head:setPosition(infoBg:getContentSize().width*0.2,infoBg:getContentSize().height*0.5+5)
		infoBg:addChild(head)
		head:setScale(0.5);
		head:loadTexture(getHeadPath(v.iLogoId));

		local nickimg = ccui.ImageView:create("desk/nicheng.png")
		nickimg:setPosition(infoBg:getContentSize().width*0.4,infoBg:getContentSize().height*0.7)
		infoBg:addChild(nickimg)

		local nickName = FontConfig.createWithSystemFont(v.nickName, 24,cc.c3b(0, 0, 0));
		nickName:setPosition(infoBg:getContentSize().width*0.5,infoBg:getContentSize().height*0.7)
		infoBg:addChild(nickName)
		nickName:setAnchorPoint(0,0.5)

		local idimg = ccui.ImageView:create("desk/id.png")
		idimg:setPosition(infoBg:getContentSize().width*0.42,infoBg:getContentSize().height*0.3)
		infoBg:addChild(idimg)

		local idstr = FontConfig.createWithSystemFont(v.iUserId, 24,cc.c3b(0, 0, 0));
		idstr:setPosition(infoBg:getContentSize().width*0.5,infoBg:getContentSize().height*0.3)
		infoBg:addChild(idstr)
		idstr:setAnchorPoint(0,0.5)
	end

	if #userlist >= self.MaxCount then
		self.sureBtn:setEnabled(false)
	else
		self.sureBtn:setEnabled(true)
	end
end

function DeskInfoLayer:onClickSure(sender)
	local layer = display.getRunningScene():getChildByName("deskLayer")
	if not layer then
		return;
	end
	layer.isClickQuick = true

	layer.selectDeskNo = self.deskInfo.iDeskIndex

	performWithDelay(layer,function() layer.isClickQuick = nil end,5)

	dispatchEvent("matchRoom",self.uRoomID)
	
	-- addScrollMessage(self.deskInfo.iDeskIndex)
	-- luaPrint("self.deskInfo.iDeskIndex = "..self.deskInfo.iDeskIndex)
	-- dispatchEvent("selectDesk",self.deskInfo.iDeskIndex)
	self:delayCloseLayer(0);
end




return DeskInfoLayer
