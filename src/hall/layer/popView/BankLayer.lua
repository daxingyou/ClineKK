local BankLayer = class("BankLayer", PopLayer)

function BankLayer:create(callback)
	return BankLayer.new(callback)
end

function BankLayer:ctor(callback)
	if globalUnit.isEnterGame == true then
		self.super.ctor(self,PopType.small)
	else
		self.super.ctor(self,PopType.middle)
	end

	self.callback = callback

	self:initData()

	self:initUI()

	self:bindEvent()
end

function BankLayer:initData()
	self.bankBtns = {}
	self.bankNodes = {}
end

function BankLayer:bindEvent()
	self:pushEventInfo(BankInfo,"getBankScore",handler(self, self.receiveGetBankScore))
	self:pushEventInfo(BankInfo,"bankLog",handler(self, self.receiveBankLog))
end

function BankLayer:initUI()
	self.sureBtn:removeSelf()
	MailInfo:sendMailListInfoRequest()
	MailInfo:sendQuestionListRequest()
	dispatchEvent("refreshScoreBank")

	local title = ccui.ImageView:create("common/bankTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	if globalUnit.isEnterGame == true then
		local node = require("layer.popView.UserInfoNode"):create()
		node:setPosition(self.size.width*0.85,self.size.height*1.05)
		self.bg:addChild(node)

		local node = require("layer.popView.BankInfoNode"):create(self,self.bg)
		self.bg:addChild(node)
	else
		BankInfo:sendBankLogRequest()
		local bg = ccui.ImageView:create("common/smallBg.png")
		bg:setAnchorPoint(cc.p(0.5,0.5))
		bg:setPosition(cc.p(self.size.width/2,self.size.height/2))
		self.bg:addChild(bg)

		local size = bg:getContentSize()

		local x = self.size.width*0.1
		local h = 100

		--取出
		local btn = ccui.Button:create("bank/quchu.png","bank/quchu-on.png","bank/quchu-dis.png")
		btn:setPosition(x,size.height*0.8)
		btn:setTag(1)
		bg:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)
		btn:setEnabled(false)
		table.insert(self.bankBtns,btn)

		--存入
		local btn = ccui.Button:create("bank/cunru.png","bank/cunru-on.png","bank/cunru-dis.png")
		btn:setPosition(x,size.height*0.8-h)
		btn:setTag(2)
		bg:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)
		table.insert(self.bankBtns,btn)

		--明细
		local btn = ccui.Button:create("bank/mingxi.png","bank/mingxi-on.png","bank/mingxi-dis.png")
		btn:setPosition(x,size.height*0.8-h*2)
		btn:setTag(3)
		bg:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)
		table.insert(self.bankBtns,btn)

		local info = ccui.ImageView:create("bank/bankInfo.png")
		info:setAnchorPoint(0,0.5)
		info:setPosition(30,50)
		self.bg:addChild(info)

		local node = require("layer.popView.BankInfoNode"):create(self,bg)
		bg:addChild(node)
		table.insert(self.bankNodes,node)

		local node = require("layer.popView.BankInfoNode"):create(self,bg,1)
		node:hide()
		bg:addChild(node)
		table.insert(self.bankNodes,node)

		local node = cc.Node:create()
		node:hide()
		bg:addChild(node)

		local bg = ccui.ImageView:create("bank/lanmu.png")
		bg:setPosition(size.width*0.6+3,size.height*0.9)
		node:addChild(bg)

		local time = ccui.ImageView:create("bank/shijian.png")
		time:setPosition(60,bg:getContentSize().height/2)
		bg:addChild(time)

		local leixing = ccui.ImageView:create("bank/leixing.png")
		leixing:setPosition(250,bg:getContentSize().height/2)
		bg:addChild(leixing)

		local jine = ccui.ImageView:create("bank/jine.png")
		jine:setPosition(440,bg:getContentSize().height/2)
		bg:addChild(jine)

		local yue = ccui.ImageView:create("bank/yue.png")
		yue:setPosition(630,bg:getContentSize().height/2)
		bg:addChild(yue)

		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0.5,0.5))
		listView:setDirection(ccui.ScrollViewDir.vertical)
		listView:setBounceEnabled(true)
		listView:setContentSize(cc.size(size.width*0.75, size.height*0.8))
		listView:setPosition(size.width*0.6+3,size.height*0.45)
		node:addChild(listView)
		self.listView = listView

		table.insert(self.bankNodes,node)
	end
end

function BankLayer:onClickBtn(sender)
	local tag = sender:getTag()

	self:selectBankOperation(tag)
end

function BankLayer:selectBankOperation(tag)
	for k,v in pairs(self.bankBtns) do
		v:setEnabled(k~=tag)
	end

	for k,v in pairs(self.bankNodes) do
		if k == tag then
			v:show()
		else
			v:hide()
		end
	end
end

function BankLayer:receiveGetBankScore(data)
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

function BankLayer:receiveBankLog(data)
	local data = data._usedata

	if self.listView then
		self.listView:removeAllChildren()
		for k,v in pairs(data) do
			local layout = self:createItem(v)
			self.listView:pushBackCustomItem(layout)
		end
	end
end

function BankLayer:createItem(data)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(self.listView:getContentSize().width, 55))

	local size = layout:getContentSize()

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw");
	-- layout:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))

	local text = FontConfig.createWithSystemFont(timeConvert(data.ColletTime,1),26,cc.c3b(20,112,148))
	text:setPosition(75,size.height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	layout:addChild(text)

	local text = FontConfig.createWithSystemFont(data.bType,26,cc.c3b(20,112,148))
	text:setPosition(265,size.height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	layout:addChild(text)

	local text = FontConfig.createWithSystemFont(goldConvert(data.OperatScore),26,cc.c3b(255,0,0))
	text:setPosition(450,size.height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	layout:addChild(text)

	if data.OperatScore > 0 then
		text:setString("+"..text:getString())
	end

	local text = FontConfig.createWithSystemFont("保险箱:"..goldConvert(data.NowScore),26,cc.c3b(20,112,148))
	text:setPosition(640,size.height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	layout:addChild(text)

	local line = ccui.ImageView:create("bank/fengexian.png")
	line:setPosition(size.width/2,2)
	layout:addChild(line)

	return layout
end

return BankLayer
