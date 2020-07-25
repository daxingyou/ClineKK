local ExtendLayer = class("ExtendLayer", PopLayer)

function ExtendLayer:create()
	return ExtendLayer.new()
end

function ExtendLayer:ctor()
	self.super.ctor(self,PopType.big)

	self:initData()

	self:bindEvent()

	self:initUI()
end

function ExtendLayer:initData()
	self.extandBtns = {}
	self.extandNodes = {}
end

function ExtendLayer:bindEvent()
	self:pushEventInfo(ExtendInfo,"extendDetail",handler(self, self.receiveExtendDetail))
end

function ExtendLayer:initUI()
	self.sureBtn:removeSelf()

	local title = ccui.ImageView:create("common/extandTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local size = self.size
	local bg = self.bg

	local x = self.size.width*0.1
	local h = 100

	--推广教程
	local btn = ccui.Button:create("extend/tuiguangjiaocheng.png","extend/tuiguangjiaocheng-on.png","extend/tuiguangjiaocheng-dis.png")
	btn:setPosition(x,size.height*0.8)
	btn:setTag(1)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	btn:setEnabled(false)
	table.insert(self.extandBtns,btn)

	--推广员信息
	local btn = ccui.Button:create("extend/tuiguangyuanxinxi.png","extend/tuiguangyuanxinxi-on.png","extend/tuiguangyuanxinxi-dis.png")
	btn:setPosition(x,size.height*0.8-h)
	btn:setTag(2)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	table.insert(self.extandBtns,btn)

	--推广明细
	local btn = ccui.Button:create("extend/tuiguangmingxi.png","extend/tuiguangmingxi-on.png","extend/tuiguangmingxi-dis.png")
	btn:setPosition(x,size.height*0.8-h*2)
	btn:setTag(3)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	table.insert(self.extandBtns,btn)

	local node = ccui.ImageView:create("extend/extandInfo.png")
	node:setPosition(size.width*0.6-13,size.height*0.5-8)
	bg:addChild(node)
	table.insert(self.extandNodes,node)

	local node = require("layer.popView.ExtendInfoNode"):create(self)
	node:hide()
	bg:addChild(node)
	table.insert(self.extandNodes,node)

	local node = cc.Node:create()
	node:hide()
	bg:addChild(node)

	--时间选择
	local time = ccui.ImageView:create("extend/jinchakan.png")
	time:setPosition(size.width*0.65,size.height*0.8)
	node:addChild(time)

	local time = ccui.ImageView:create("extend/xialaxianshi.png")
	time:setPosition(size.width*0.87,size.height*0.8)
	node:addChild(time)

	local btn = ccui.Button:create("extend/xialaanniu.png","extend/xialaanniu-on.png")
	btn:setAnchorPoint(1,0.5)
	btn:setPosition(time:getContentSize().width,time:getContentSize().height/2)
	btn:setTag(5)
	time:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	local text = FontConfig.createWithSystemFont(timeConvert(os.time()-24*60*60,1),26)
	text:setPosition(time:getContentSize().width/2-20,time:getContentSize().height/2)
	time:addChild(text)
	self.dateText = text

	--标题栏
	local bg = ccui.ImageView:create("extend/lanmutiao.png")
	bg:setPosition(size.width*0.6-10,size.height*0.7+5)
	node:addChild(bg)

	local time = ccui.ImageView:create("extend/nicheng.png")
	time:setPosition(120,bg:getContentSize().height/2)
	bg:addChild(time)

	local leixing = ccui.ImageView:create("extend/id.png")
	leixing:setPosition(290,bg:getContentSize().height/2)
	bg:addChild(leixing)

	local jine = ccui.ImageView:create("extend/shuishou.png")
	jine:setPosition(480,bg:getContentSize().height/2)
	bg:addChild(jine)

	local yue = ccui.ImageView:create("extend/shuishoujiangli.png")
	yue:setPosition(700,bg:getContentSize().height/2)
	bg:addChild(yue)

	local image = ccui.ImageView:create("mail/tubiao.png")
	image:setPosition(size.width*0.6,size.height/2)
	node:addChild(image)

	table.insert(self.extandNodes,node)
	
	ExtendInfo:sendExtendTotalCountRequest()
	ExtendInfo:sendGetNeedLevelRequest()
	local ret, data = ExtendInfo:sendExtendDetailRequest(1)
	if ret == true then
		self:receiveExtendDetail(data)
	end

	local info = ccui.ImageView:create("extend/shuoming.png")
	info:setAnchorPoint(0,0.5)
	info:setPosition(30,40)
	self.bg:addChild(info)
end

function ExtendLayer:onEnter()
	self.super.onEnter(self)
end

function ExtendLayer:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 5 then
		self:showDate()
	else
		self:selectBankOperation(tag)
	end
end

function ExtendLayer:selectBankOperation(tag)
	for k,v in pairs(self.extandBtns) do
		v:setEnabled(k~=tag)
	end

	for k,v in pairs(self.extandNodes) do
		if k == tag then
			v:show()
		else
			v:hide()
		end
	end
end

function ExtendLayer:showDate()
	if self.dateBtn == nil then
		local btn = ccui.Widget:create()
		btn:setAnchorPoint(cc.p(0.5,1))
		btn:setPosition(self.size.width*0.87,self.size.height*0.8)
		btn:setCascadeOpacityEnabled(true)
		btn:setTouchEnabled(true)
		btn:setSwallowTouches(true)
		self.extandNodes[#self.extandNodes]:addChild(btn,100)
		self.dateBtn = btn

		local width = 0
		local height = 0
		local x = 0
		local y = 0

		for i=1,7 do
			local btn = ccui.Button:create("extend/xiala.png","extend/xiala.png")
			local date = timeConvert(os.time()-24*60*60*(i),1)
			if x == 0 then
				height = btn:getContentSize().height
				width = btn:getContentSize().width

				self.dateBtn:setContentSize(cc.size(width,height*7))
				self.dateBtn:setPositionY(self.dateBtn:getPositionY()-height/2-8)

				x = width/2
				y = height*7
			end

			btn:setPosition(x,y);
			btn:setAnchorPoint(0.5,1);
			btn:setTag(i)
			btn:setName(date)
			self.dateBtn:addChild(btn);
			btn:addClickEventListener(function(sender) self:onClickDateBtn(sender) end)

			local text = FontConfig.createWithSystemFont(date,26,cc.c3b(255,255,255))
			text:setPosition(width/2,height/2)
			btn:addChild(text)

			y = y - height
		end
		self.dateBtn:setScaleY(0)
	else
		if not self.dateBtn:isVisible() then
			self.dateBtn:setScaleY(0)
		end
		self.dateBtn:setVisible(not self.dateBtn:isVisible())
	end

	if self.dateBtn:isVisible() then
		self.dateBtn:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1, 1, 1)))
	end
end

function ExtendLayer:onClickDateBtn(sender)
	if self.dateBtn then
		self.dateBtn:setVisible(not self.dateBtn:isVisible())
	end

	local tag = sender:getTag()
	local name = sender:getName()

	self.dateText:setString(name)

	ExtendInfo:sendExtendDetailRequest(tag)
end

function ExtendLayer:receiveGetBankScore(data)
	if globalUnit.isEnterGame == true then
		local data = data._usedata

		if data.ret == 0 then
			if self.callback then
				self.callback(data)
			else
				dispatchEvent("refreshScoreBank")
			end
		end
	end
end

function ExtendLayer:receiveExtendDetail(data)
	local data = data._usedata

	if #data == 0 then
		if self.listView then
			self.listView:removeSelf()
			self.listView = nil
		end

		if self.infoNode then
			self.infoNode:removeSelf()
			self.infoNode = nil
		end

		if self.noMingXiText == nil then
			local text = FontConfig.createWithSystemFont("暂无明细",26,cc.c3b(20,112,148))
			text:setPosition(self.size.width*0.6,self.size.height*0.35)
			self.extandNodes[#self.extandNodes]:addChild(text)
			self.noMingXiText = text
		end

		if self.infoNode then
			self.infoNode:removeSelf()
			self.infoNode = nil
		end

		local node = cc.Node:create()
		self.extandNodes[#self.extandNodes]:addChild(node)
		self.infoNode = node

		local dis = -10
		--B
		local text = FontConfig.createWithSystemFont("B总人数：0",26,cc.c3b(51,140,85))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.25,self.size.height*0.25+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总额：0",26,cc.c3b(51,140,85))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.4,self.size.height*0.25+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总奖励总额：0",26,cc.c3b(51,140,85))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.65,self.size.height*0.25+dis)
		node:addChild(text)

		--C
		local text = FontConfig.createWithSystemFont("C总人数：0",26,cc.c3b(20,112,148))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.25,self.size.height*0.2+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总额：0",26,cc.c3b(20,112,148))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.4,self.size.height*0.2+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总奖励总额：0",26,cc.c3b(20,112,148))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.65,self.size.height*0.2+dis)
		node:addChild(text)

		--D
		local text = FontConfig.createWithSystemFont("D总人数：0",26,cc.c3b(189,107,41))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.25,self.size.height*0.15+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总额：0",26,cc.c3b(189,107,41))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.4,self.size.height*0.15+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总奖励总额：0",26,cc.c3b(189,107,41))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.65,self.size.height*0.15+dis)
		node:addChild(text)
	else
		if self.noMingXiText then
			self.noMingXiText:removeSelf()
			self.noMingXiText = nil
		end

		if self.listView == nil then
			local listView = ccui.ListView:create()
			listView:setAnchorPoint(cc.p(0.5,0.5))
			listView:setDirection(ccui.ScrollViewDir.vertical)
			listView:setBounceEnabled(true)
			listView:setContentSize(cc.size(self.size.width*0.75, self.size.height*0.35))
			listView:setPosition(self.size.width*0.6,self.size.height*0.45+10)
			self.extandNodes[#self.extandNodes]:addChild(listView)
			self.listView = listView
		else
			self.listView:removeAllChildren()
		end

		local b = 0
		local c = 0
		local d = 0
		local b1 = 0
		local c1= 0
		local d1 = 0

		for k,v in pairs(data) do
			local layout = self:createItem(v)
			self.listView:pushBackCustomItem(layout)

			if v.AgencyType == 1 then
				b = b + v.Revenue
				b1 = b1 + v.RewardRevenue
			elseif v.AgencyType == 2 then
				c = c + v.Revenue
				c1 = c1 + v.RewardRevenue
			elseif v.AgencyType == 3 then
				d = d + v.Revenue
				d1 = d1 + v.RewardRevenue
			end
		end

		if self.infoNode then
			self.infoNode:removeSelf()
			self.infoNode = nil
		end

		local node = cc.Node:create()
		self.extandNodes[#self.extandNodes]:addChild(node)
		self.infoNode = node

		local dis = -10
		--B
		local text = FontConfig.createWithSystemFont("B总人数："..ExtendInfo.extendTotalCount.UserCountB,26,cc.c3b(51,140,85))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.25,self.size.height*0.25+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总额："..goldConvert(b),26,cc.c3b(51,140,85))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.4,self.size.height*0.25+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总奖励总额："..goldConvert(b1),26,cc.c3b(51,140,85))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.65,self.size.height*0.25+dis)
		node:addChild(text)

		--C
		local text = FontConfig.createWithSystemFont("C总人数："..ExtendInfo.extendTotalCount.UserCountC,26,cc.c3b(20,112,148))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.25,self.size.height*0.2+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总额："..goldConvert(c),26,cc.c3b(20,112,148))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.4,self.size.height*0.2+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总奖励总额："..goldConvert(c1),26,cc.c3b(20,112,148))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.65,self.size.height*0.2+dis)
		node:addChild(text)

		--D
		local text = FontConfig.createWithSystemFont("D总人数："..ExtendInfo.extendTotalCount.UserCountD,26,cc.c3b(189,107,41))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.25,self.size.height*0.15+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总额："..goldConvert(d),26,cc.c3b(189,107,41))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.4,self.size.height*0.15+dis)
		node:addChild(text)

		local text = FontConfig.createWithSystemFont("税收总奖励总额："..goldConvert(d1),26,cc.c3b(189,107,41))
		text:setAnchorPoint(0,0.5)
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		text:setPosition(self.size.width*0.65,self.size.height*0.15+dis)
		node:addChild(text)
	end
end

function ExtendLayer:createItem(data)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(self.listView:getContentSize().width, 55))

	local size = layout:getContentSize()

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw");
	-- layout:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))

	local text = FontConfig.createWithSystemFont(data.NickName,26,cc.c3b(20,112,148))
	text:setPosition(120,size.height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	layout:addChild(text)

	local text = FontConfig.createWithSystemFont(data.UserID,26,cc.c3b(20,112,148))
	text:setPosition(290,size.height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	layout:addChild(text)

	local text = FontConfig.createWithSystemFont(goldConvert(data.Revenue),26,cc.c3b(255,0,0))
	text:setPosition(480,size.height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	layout:addChild(text)

	local text = FontConfig.createWithSystemFont(goldConvert(data.RewardRevenue),26,cc.c3b(20,112,148))
	text:setPosition(700,size.height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	layout:addChild(text)

	local line = ccui.ImageView:create("bank/fengexian.png")
	line:setPosition(size.width/2-15,2)
	layout:addChild(line)
	line:setScaleX(1.2)

	return layout
end

return ExtendLayer

