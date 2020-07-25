local SuggestLayer = class("SuggestLayer",PopLayer)

function SuggestLayer:ctor()
	self.super.ctor(self,PopType.middle)

	self:initData()

	self:bindEvent()

	self:initUI()
end

function SuggestLayer:bindEvent()
	self:pushEventInfo(MailInfo, "questionListInfo", handler(self, self.receiveQuestionList))
	self:pushEventInfo(MailInfo, "addQuestion", handler(self, self.receiveAddQuestion))
end

function SuggestLayer:initData()
	self.suggestBtns = {}
	self.suggestNodes = {}
	self.textCont = "发现BUG?成功建议？活动创意统统提过来吧！写下您的建议，一经采纳可赢取丰厚奖励！"
end

function SuggestLayer:initUI()
	MailInfo:sendQuestionListRequest()

	local title = ccui.ImageView:create("common/suggestTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	
	local bg = ccui.ImageView:create("common/smallBg.png")
	bg:setAnchorPoint(cc.p(0.5,0.5))
	bg:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self.bg:addChild(bg)

	local size = bg:getContentSize()
	--cebian
	bg:setCascadeOpacityEnabled(false);
	bg:setOpacity(0);
	local cebianBg = ccui.ImageView:create("mail/cebian.png")
	
	cebianBg:setPosition(cc.p(cebianBg:getContentSize().width*0.5,cebianBg:getContentSize().height/2+8.5))
	bg:addChild(cebianBg);
	

	local x = self.size.width*0.1
	local h = 100

	--取出
	local btn = ccui.Button:create("mail/lianxikefu.png","mail/lianxikefu-on.png","mail/lianxikefu-dis.png")
	btn:setPosition(x,size.height*0.85)
	btn:setTag(1)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	btn:setEnabled(false)
	table.insert(self.suggestBtns,btn)

	--存入
	local btn = ccui.Button:create("mail/kefuhuifu.png","mail/kefuhuifu-on.png","mail/kefuhuifu-dis.png")
	btn:setPosition(x,size.height*0.85-h)
	btn:setTag(2)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	table.insert(self.suggestBtns,btn)

	--提建议
	local node = cc.Node:create()
	bg:addChild(node)
	table.insert(self.suggestNodes,node)

	local input = ccui.ImageView:create("mail/kefuinput.png")
	input:setPosition(size.width*0.6+5,size.height*0.6)
	node:addChild(input)

	self.sureBtn:retain()
	self.sureBtn:removeSelf()
	node:addChild(self.sureBtn)
	self.sureBtn:release()
	self:updateSureBtnPos(-95,90)

	local editBg = nil
	self.refereeTextEdit,editBg = createEditBox(input,"",cc.EDITBOX_INPUT_MODE_ANY,1,nil,"mail/kefuinput.png")
	self.refereeTextEdit:setAnchorPoint(0,1)
	self.refereeTextEdit:setPosition(cc.p(0, editBg:getContentSize().height))
	-- editBg:loadTexture("suggest/kefuinput.png")
	editBg:setPosition(0,input:getContentSize().height/2)
	-- self.refereeTextEdit:hide()
	-- self.refereeTextEdit:setContentSize(editBg:getContentSize())
 --	self.refereeTextEdit:setPosition(cc.p(editBg:getContentSize().width/2, editBg:getContentSize().height/2))
	-- self.refereeTextEdit:setAnchorPoint(0,1)
	self.refereeTextEdit:setMaxLength(200)
	self.refereeTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))

	local text = FontConfig.createWithSystemFont(self.textCont,20,cc.c3b(79,95,107))
	text:setPosition(10,input:getContentSize().height-10)
	text:setAnchorPoint(0,1)
	text:setDimensions(600,0)
	text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	input:addChild(text)
	self.text = text

	--客服回复列表
	local node = cc.Node:create()
	node:hide()
	bg:addChild(node)
	table.insert(self.suggestNodes,node)

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,0.5))
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setContentSize(cc.size(size.width*0.75, size.height*0.9))
	listView:setPosition(size.width*0.6+5,size.height/2)
	node:addChild(listView)
	self.listView = listView

	local info = ccui.ImageView:create("mail/suggestInfo.png")
	info:setAnchorPoint(0,0.5)
	info:setPosition(30,50)
	self.bg:addChild(info)
end

function SuggestLayer:onClickBtn(sender)
	local tag = sender:getTag()

	self:selectBtnOperation(tag)
end

function SuggestLayer:selectBtnOperation(tag)
	for k,v in pairs(self.suggestBtns) do
		v:setEnabled(k~=tag)
	end

	for k,v in pairs(self.suggestNodes) do
		if k == tag then
			v:show()
			if tag == 1 then
				MailInfo:sendQuestionListRequest()
			end
		else
			v:hide()
		end
	end
end

function SuggestLayer:onEditBoxHandler(event)
	local name = event.name

	if name == "began" then
		--todo
	elseif name == "ended" then
		self:setInputText()
	elseif name == "return" then
		-- local text = event.target:getText()
		-- event.target:setText("")
		-- if text == "" then
		-- 	text = self.textCont
		-- end
		-- self.text:setString(text)
	elseif name == "changed" then
		--todo
	end
end

function SuggestLayer:resetInputText()
	self.text:setString(self.textCont)
	performWithDelay(self.refereeTextEdit,function() self.refereeTextEdit:setText("") end,0.05)
end


function SuggestLayer:setInputText()
	local text = self.refereeTextEdit:getText()
	if text == "" then
		text = self.textCont
	end
	self.text:setString(text)

	performWithDelay(self.refereeTextEdit,function() self.refereeTextEdit:setText("") end,0.05)
end

function SuggestLayer:onClickSure(sender)
	local text = self.text:getString()

	if text == self.textCont then
		addScrollMessage("请输入建议")
		return
	end

	if isEmptyString(text) then
		addScrollMessage("请输入建议")
		return
	end

	if string.len(text) > 240 then --utf8 3个字节
		addScrollMessage("建议字数过长！")
		self:resetInputText();
		return;
	end

	MailInfo:sendQuestionRequest(text)
end

function SuggestLayer:receiveAddQuestion(data)
	local data = data._usedata

	if data.ret == 0 then
		MailInfo:sendQuestionListRequest()
		addScrollMessage("您的建议已提交成功，客服会在24小时内回复")
	else
		addScrollMessage("建议提交失败")
	end
end

function SuggestLayer:receiveQuestionList(data)
	local data = data._usedata

	if #data > 0 then
		self.listView:removeAllChildren()

		for k,v in pairs(data) do
			local layout = self:createSuggestItem(v)
			self.listView:pushBackCustomItem(layout)
		end
	end
end

function SuggestLayer:createSuggestItem(data)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(self.listView:getContentSize().width, 110))

	local size = layout:getContentSize()

	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(size.width-10,size.height))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(size.width/2,size.height/2)
	btn:setCascadeOpacityEnabled(true)
	btn:setTouchEnabled(true)
	layout:addChild(btn)
	btn:onTouchClick(function(sender) self:onClickSuggestBtn(sender,data) end)

	local uiTable = {
		Text_time = "Text_time",
		Image_read = "Image_read"
	}
	loadNewCsb(layout, "suggestNode", uiTable)
	layout.csbNode:setPosition(size.width/2,size.height/2-5)
	layout.Image_read:setVisible(data.IsUse == 2)
	layout.Text_time:setString(timeConvert(data.CreateDate))
	return layout
end

--邮件详情
function SuggestLayer:onClickSuggestBtn(sender,data)
	if data.IsUse == 1 then
		MailInfo:sendMailReadRequest(data.QuestionID,1)
		MailInfo:sendQuestionListRequest()
	end
	display.getRunningScene():addChild(require("layer.popView.SuggestContentLayer"):create(data))
end

return SuggestLayer
