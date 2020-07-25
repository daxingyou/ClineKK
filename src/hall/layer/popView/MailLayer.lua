local MailLayer = class("MailLayer",PopLayer)

function MailLayer:ctor()
	playEffect("hall/sound/mail.mp3")
	self.super.ctor(self,PopType.middle)

	self:bindEvent()

	self:initUI()
	
end

function MailLayer:bindEvent()
	self:pushEventInfo(MailInfo,"mailListInfo",handler(self, self.onReceiveMailList))--邮件列表
	self:pushEventInfo(MailInfo,"mailDelete",handler(self, self.onReceiveMailDelete))--邮件列表
end

function MailLayer:initUI()
	self.sureBtn:hide()
	-- MailInfo:sendMailListInfoRequest()
	self:updateSureBtnImage("mail/deleteAll.png","mail/deleteAll-on.png")
	self:updateSureBtnPos(-5)
	self.sureBtn:setTouchEnabled(false)

	local title = ccui.ImageView:create("common/xiaoxi.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local logo = ccui.ImageView:create("mail/zanwuxiaoxi.png")
	logo:setPosition(self.size.width/2,self.size.height/2)
	self.bg:addChild(logo)
	self.logo = logo;
	-- local data2 = MailInfo:sendMailListInfoRequest()
 --    if data2 then
 --    	local data = {}
 --    	data._usedata = data2;
 --    	self:onReceiveMailList(data);
 --    end
	
	local function onRefreshDone(sender,event)
    	MailInfo:sendMailListInfoRequest()
    end
	
    self.logo:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(onRefreshDone)));
end

function MailLayer:onReceiveMailList(data)
	local data =  data._usedata
	
	if #data == 0 then
		if self.sureBtn then
			-- self.sureBtn:removeSelf()
			-- self.sureBtn = nil
			self.sureBtn:hide()
		end

		if self.listView then
			self.listView:removeSelf()
			self.listView = nil
		end

		-- local image = ccui.ImageView:create("mail/zanwuxiaoxi.png")
		-- image:setPosition(self.size.width/2,self.size.height/2)
		-- self.bg:addChild(image)
		
	else
		if self.listView == nil then
			local listView = ccui.ListView:create()
			listView:setAnchorPoint(cc.p(0.5,0.5))
			listView:setDirection(ccui.ScrollViewDir.vertical)
			listView:setBounceEnabled(true)
			listView:setContentSize(cc.size(self.size.width-50, self.size.height*0.5))
			listView:setPosition(self.size.width/2,self.size.height*0.6-15)
			self.bg:addChild(listView)
			self.listView = listView
		else
			self.listView:removeAllChildren()
		end
		
		for k,v in pairs(data) do
			local layout = self:createMailItem(v)
			self.listView:pushBackCustomItem(layout)
		end
		
		self.logo:setVisible(false);
		self.sureBtn:setTouchEnabled(true)
		self.sureBtn:show()
	end
end

function MailLayer:createMailItem(data)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(self.listView:getContentSize().width, 100))

	local size = layout:getContentSize()

	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(size.width-10,size.height))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(size.width/2,size.height/2)
	btn:setCascadeOpacityEnabled(true)
	btn:setTouchEnabled(true)
	layout:addChild(btn)
	btn:onTouchClick(function(sender) self:onClickMailBtn(sender,data) end)

	local uiTable = {
		Image_mask = "Image_mask",
		Text_time = "Text_time",
		Text_title = "Text_title",
		Button_delete = "Button_delete"
	}
	loadNewCsb(layout, "mailNode", uiTable)
	layout.csbNode:setPosition(size.width/2,size.height/2-5)
	layout.Button_delete:loadTextures("mail/delete.png","mail/delete-on.png","mail/delete-on.png")
	layout.Button_delete:setPositionY(layout.Button_delete:getPositionY() - 5)
	if data.IsUse == true then
		-- layout.Image_mask:setColor(cc.c3b(128,128,128));
		layout.Image_mask:loadTexture("mail/read.png");
	else
		layout.Image_mask:loadTexture("mail/weidu.png");
	end
	layout.Text_time:setTextColor(cc.c3b(255, 255, 255))
	layout.Text_title:setTextColor(cc.c3b(255, 255, 255))
	layout.Text_time:setString(timeConvert(data.CreateDate))
	layout.Text_title:setString(data.Title)

	layout.Button_delete:onClick(function() MailInfo:sendMailDeleteRequest(data.MailID) end)

	return layout
end

function MailLayer:onClickSure(sender)
	MailInfo:sendMailDeleteRequest(0)
end

--邮件详情
function MailLayer:onClickMailBtn(sender,data)
	if data.IsUse == false then
		MailInfo:sendMailReadRequest(data.MailID)
	end
	display.getRunningScene():addChild(require("layer.popView.MailContentLayer"):create(data))
end

function MailLayer:onReceiveMailDelete(data)
	local data = data._usedata

	if data.ret == 0 then
		addScrollMessage("邮件删除成功")
	else
		addScrollMessage("邮件删除失败")
	end
end

return MailLayer
