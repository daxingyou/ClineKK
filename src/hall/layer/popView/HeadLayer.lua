local HeadLayer = class("HeadLayer",PopLayer)

function HeadLayer:ctor()
	self.super.ctor(self,PopType.middle)

	self:initData()

	self:initUI()
end

function HeadLayer:initData()
	self.headBtns = {}
end

function HeadLayer:initUI()
	self:updateSureBtnPos(-110)
	local uiTable = {
		Button_head1 = "Button_head1",
		Button_head2 = "Button_head2",
		Button_head3 = "Button_head3",
		Button_head4 = "Button_head4",
		Button_head5 = "Button_head5",
		Button_head6 = "Button_head6",
		Button_head7 = "Button_head7",
		Button_head8 = "Button_head8",
		Button_head9 = "Button_head9",
		Button_head10 = "Button_head10",
	}
	loadNewCsb(self,"headLayer",uiTable)
	self.xBg = self.csbNode

	local title = ccui.ImageView:create("common/headTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	table.insert(self.headBtns,self.Button_head1)
	table.insert(self.headBtns,self.Button_head2)
	table.insert(self.headBtns,self.Button_head3)
	table.insert(self.headBtns,self.Button_head4)
	table.insert(self.headBtns,self.Button_head5)
	table.insert(self.headBtns,self.Button_head6)
	table.insert(self.headBtns,self.Button_head7)
	table.insert(self.headBtns,self.Button_head8)
	table.insert(self.headBtns,self.Button_head9)
	table.insert(self.headBtns,self.Button_head10)

	for k,v in pairs(self.headBtns) do
		v:setTag(k)
		v:onClick(handler(self, self.onClickBtn))
	end

	local path,id = getHeadPath(PlatformLogic.loginResult.bLogoID,PlatformLogic.loginResult.bBoy,true)

	self.headBtns[id]:setEnabled(false)
	self.sureBtn:removeSelf()
end

function HeadLayer:onClickBtn(sender)
	local tag = sender:getTag()

	for k,v in pairs(self.headBtns) do
		v:setEnabled(tag ~= k)
	end

	if self.callback then
		self.callback(tag)
	end
end

function HeadLayer:setHeadCallback(callback)
	self.callback = callback
end

return HeadLayer
