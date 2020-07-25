local GamePromptLayer = class("GamePromptLayer", PopLayer)

function GamePromptLayer:create(iType)
	return GamePromptLayer.new(iType);
end

function GamePromptLayer:createWithParam(params)
	return GamePromptLayer.new(params[1], params[2], params[3],params[4]);
end

function GamePromptLayer:ctor(text, image, isOk, isCancel)
	self.iType = text

	if self.iType == nil then
		self.super.ctor(self);
	elseif self.iType == 1 then
		self.super.ctor(self,PopType.outType);
	elseif self.iType == 2 then
		self.super.ctor(self,PopType.middle);
	end

	self:initData();

	self.showText = "";
	self.imagePath = image

	if isOk == nil then
		isOk = true;
	end

	if isCancel == nil then
		isCancel = false;
	end

	self.isShowOk = isOk;
	self.isShowCancel = isCancel;

	self:initUI();
end

function GamePromptLayer:initData()
	self.showText = ""; --显示文字
	self.textPrompt = nil; --显示文本
	self.btnOk = nil; --确定按钮
	self.btnCancel = nil; --取消按钮
	self.textTimer = nil;	--计时文本 默认不显示

	self.showTime = 0; --默认显示时间

	--按钮是否显示 默认不显示
	self.isShowOk = false;
	self.isShowCancel = false;

	self.onClickBtnOk = nil;--按钮回调事件
	self.onClickBtnCancel = nil;
end

function GamePromptLayer:initUI()
	LoadingLayer:removeLoading();
	self.sureBtn:removeSelf()
	self.sureBtn = nil
	local bg = self.bg

	local biaoti = ccui.ImageView:create("common/wenxintishi.png");
	biaoti:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height-90));
	bg:addChild(biaoti);

	if self.iType == 1 then
		biaoti:setPositionY(bg:getContentSize().height-90)
	end

	local size = self.size

	if self.imagePath == nil then
		self.textPrompt = FontConfig.createLabel(FontConfig.gFontConfig_26, self.showText, cc.c3b(255,249,217));
		self.textPrompt:setPosition(size.width/2,size.height*0.55);

		if self.iType == 1 then
			self.textPrompt:setDimensions(cc.size(420,0))
			-- self.textPrompt:setColor(FontConfig.colorWhite)
		else
			self.textPrompt:setDimensions(cc.size(600, 0))
		end
		self.textPrompt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		self.textPrompt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		bg:addChild(self.textPrompt);
	else
		local biaoti = ccui.ImageView:create(self.imagePath)
		biaoti:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2))
		bg:addChild(biaoti)
	end

	self.btnOk = ccui.Button:create("common/ok.png","common/ok-on.png");
	self.btnOk:setPosition(size.width/2 - 100, 70);
	self.btnOk:setAnchorPoint(0.5, 0);
	bg:addChild(self.btnOk);
	self.btnOk:onClick(function()
			self:delayCloseLayer(0);
			if HallLayer and HallLayer:getInstance() and not HallLayer:getInstance():isVisible() then
				HallLayer:getInstance():delayCloseLayer()
			end

			if self.onClickBtnOk ~= nil then
				self.onClickBtnOk();
			end
			self.onClickBtnOk = nil
		end)

	if self.iType == 2 then
		self.btnOk:loadTextures("common/zanshilikaiyouxi.png","common/zanshilikaiyouxi-on.png")
		self.btnOk:setPositionY(10)
	end

	self.btnCancel = ccui.Button:create("common/cancel.png","common/cancel-on.png");
	self.btnCancel:setPosition(size.width/2 + 100, 70);
	self.btnCancel:setAnchorPoint(0.5, 0);
	bg:addChild(self.btnCancel);
	self.btnCancel:onClick(function()
			LoadingLayer:removeLoading();
			self:delayCloseLayer(0);
			if self.onClickBtnCancel ~= nil then
				self.onClickBtnCancel();
			end
			self.onClickBtnCancel = nil
		end)

	self:setBtnOkCancelStatus();

	self:setLocalZOrder(3000);
end

function GamePromptLayer:onClickClose(sender)
	LoadingLayer:removeLoading()
	self:delayCloseLayer(0)
	if self.onClickBtnCancel ~= nil then
		self.onClickBtnCancel()
	end
	self.onClickBtnCancel = nil
end

function GamePromptLayer:setBtnVisible(isOk, isCancel)
	if isOk == nil then
		isOk = true;
	end

	if isCancel == nil then
		isCancel = false;
	end

	self.isShowOk = isOk;
	self.isShowCancel = isCancel;

	self:setBtnOkCancelStatus();
end

function GamePromptLayer:setBtnOkCancelStatus()
	if self.btnOk then
		self.btnOk:setVisible(self.isShowOk);
	end

	if self.btnCancel then
		self.btnCancel:setVisible(self.isShowCancel);
	end

	--位置调整
	if self.isShowOk == true then
		if not self.isShowCancel then
			self.btnOk:setPositionX(self.size.width/2);
		else
			self.btnOk:setPositionX(self.size.width/2 - 150);
			self.btnCancel:setPositionX(self.size.width/2 + 150);
		end
	else
		if self.isShowCancal then
			self.btnCancel:setPositionX(self.size.width/2);
		end
	end
end

function GamePromptLayer:setBtnClickCallBack(okCallBack, cancelCallBack)
	self.onClickBtnOk = okCallBack or nil;
	self.onClickBtnCancel = cancelCallBack or nil;
end

function GamePromptLayer:showPrompt(prompt, isOk, isCancel)
	local root = cc.Director:getInstance():getRunningScene();

	if root == nil then
		return;
	end

	local node = root:getChildByName("prompt");

	if node then
		if self.showText == prompt then
			return;
		end

		node:removeFromParent();
	end

	LoadingLayer:removeLoading()

	self:setLocalZOrder(99999);
	root:addChild(self);
	self:setName("prompt");

	self.showText = prompt;

	if self.textPrompt ~= nil then
		self.textPrompt:setString(self.showText);
	end

	self:setBtnVisible(isOk, isCancel);
end

function GamePromptLayer:setAutoClose(dt)
	if dt ~= nil then
		if self.tmText == nil then
			local text = FontConfig.createLabel(FontConfig.gFontConfig_22, "", FontConfig.colorRed);
			text:setPosition(self.size.width/2,self.size.height*0.45)
			self.bg:addChild(text)
			self.tmText = text
		end

		if self.tmText then
			self.showTime = dt
			self.tmText:setString("("..dt.."秒后关闭页面)")
			schedule(self.tmText, function(dt) self:updateTimer(dt) end, 1);
		end
	end
end

function GamePromptLayer:updateTimer(dt)
	self.showTime = self.showTime - 1;

	if self.tmText ~= nil then
		self.tmText:setString("("..self.showTime.."秒后关闭页面)");
	end

	if self.showTime <= 0 then
		self:onClickClose();
	end
end

function GamePromptLayer:remove()
	local node = display.getRunningScene():getChildByName("prompt")
	if node then
		node:delayCloseLayer(0)
	end
end

return GamePromptLayer
