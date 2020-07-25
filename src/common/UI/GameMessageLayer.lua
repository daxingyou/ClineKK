local GameMessageLayer = class("GameMessageLayer", PopLayer)

function GameMessageLayer:create(title,text, ok, cancel)
	return GameMessageLayer.new(title,text, ok, cancel);
end

function GameMessageLayer:ctor(title,text, ok, cancel)
	self.showText = text
	self.title = title

	self.super.ctor(self)

	self:initData();

	self.showOk = ok;
	self.showCancel = cancel;

	self:initUI();
end

function GameMessageLayer:initData()
	self.onClickBtnOk = nil;--按钮回调事件
	self.onClickBtnCancel = nil;
end

function GameMessageLayer:initUI()
	LoadingLayer:removeLoading();
	self.sureBtn:removeSelf()
	self.sureBtn = nil
	local bg = self.bg

	local biaoti = ccui.ImageView:create(self.title);
	biaoti:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height-50));
	bg:addChild(biaoti);

	local size = self.size

	local text = FontConfig.createWithSystemFont(self.showText,35,FontConfig.colorGray)
	text:setPosition(size.width/2,size.height*0.55);
	text:setDimensions(630,0)
	text:setLineBreakWithoutSpace(true)
	text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	bg:addChild(text);

	self.btnOk = ccui.Button:create(self.showOk..".png",self.showOk.."-on.png");
	self.btnOk:setPosition(size.width/2 - 150,100);
	self.btnOk:setAnchorPoint(0.5, 0);
	bg:addChild(self.btnOk);
	self.btnOk:onClick(function()
			self:delayCloseLayer(0)
			if self.onClickBtnOk ~= nil then
				self.onClickBtnOk()
			end
			self.onClickBtnOk = nil
		end)

	if self.showCancel then
		self.btnCancel = ccui.Button:create(self.showCancel..".png",self.showCancel.."-on.png");
		self.btnCancel:setPosition(self.size.width/2 + 150,100);
		self.btnCancel:setAnchorPoint(0.5, 0);
		bg:addChild(self.btnCancel);
		self.btnCancel:onClick(function()
				self:delayCloseLayer(0)
				if self.onClickBtnCancel ~= nil then
					self.onClickBtnCancel()
				end
				self.onClickBtnCancel = nil
			end)
	else
		self.btnOk:setPositionX(self.size.width/2)
	end

	self:setLocalZOrder(3000)
end

function GameMessageLayer:setBtnClickCallBack(okCallBack, cancelCallBack)
	self.onClickBtnOk = okCallBack or nil;
	self.onClickBtnCancel = cancelCallBack or nil;
end

return GameMessageLayer

