local SuggestContentLayer = class("SuggestContentLayer", PopLayer)

function SuggestContentLayer:create(data)
	return SuggestContentLayer.new(data)
end

function SuggestContentLayer:ctor(data)
	self.super.ctor(self,PopType.small)

	self.data = data

	self:initUI()
end

function SuggestContentLayer:initUI()
	local title = ccui.ImageView:create("common/xiangqing.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local bg = ccui.ImageView:create("mail/xiangxiBg.png")
	bg:setPosition(self.size.width/2,self.size.height/2)
	self.bg:addChild(bg)

	local d = 30

	local gap = 30;

	--new scroll
	local bgSize = bg:getContentSize();
	local ScrollView_content = ccui.ScrollView:create();
	ScrollView_content:setContentSize(cc.size(bgSize.width,bgSize.height-5));
	ScrollView_content:setAnchorPoint(cc.p(0.5,0.5));
	ScrollView_content:setPosition(bg:getPosition());
	ScrollView_content:setInnerContainerSize(cc.size(996,935));
	-- ScrollView_content:setAnchorPoint(cc.p(0,1));
	ScrollView_content:setBounceEnabled(true);
	ScrollView_content:setInertiaScrollEnabled(true);
	self.bg:addChild(ScrollView_content)
	local sizeAll = cc.size(bg:getContentSize().width,0);

	local did = 10;
	local textTime = FontConfig.createWithSystemFont("回复时间："..timeConvert(self.data.CreateDate),26,cc.c3b(109,92,90))
	
	textTime:setAnchorPoint(0,1)
	textTime:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	ScrollView_content:addChild(textTime)
	sizeAll = cc.size(sizeAll.width,sizeAll.height + textTime:getContentSize().height);

	local textSug = FontConfig.createWithSystemFont("建议："..self.data.Question,26,cc.c3b(109,92,90))
	
	textSug:setAnchorPoint(0,1)
	textSug:setDimensions(bgSize.width-20,0)
	textSug:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	ScrollView_content:addChild(textSug)
	sizeAll = cc.size(sizeAll.width,sizeAll.height + textSug:getContentSize().height);

	local textResp = FontConfig.createWithSystemFont("回复："..self.data.Answer,26,cc.c3b(109,92,90))
	
	textResp:setAnchorPoint(0,1)
	textResp:setDimensions(bgSize.width-20,0)
	textResp:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	ScrollView_content:addChild(textResp)

	sizeAll = cc.size(sizeAll.width,sizeAll.height + textResp:getContentSize().height+120);
	if sizeAll.height < bgSize.height then
		sizeAll.height = bgSize.height;
	end

	ScrollView_content:setInnerContainerSize(sizeAll);
	textTime:setPosition(cc.p(did,sizeAll.height-d));
	textSug:setPosition(cc.p(did,sizeAll.height-d-textTime:getContentSize().height-d))
	textResp:setPosition(cc.p(did,textSug:getPositionY() - textSug:getContentSize().height-d))


	-- local text = FontConfig.createWithSystemFont("回复时间："..timeConvert(self.data.CreateDate),26,cc.c3b(109,92,90))
	-- text:setPosition(self.size.width*0.1-15 + gap,self.size.height*0.75 + d)
	-- text:setAnchorPoint(0,1)
	-- text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	-- self.bg:addChild(text)

	-- local text = FontConfig.createWithSystemFont("建议："..self.data.Question,26,cc.c3b(109,92,90))
	-- text:setPosition(self.size.width*0.1-15 + gap,self.size.height*0.65 + d)
	-- text:setAnchorPoint(0,1)
	-- text:setDimensions(630,0)
	-- text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	-- self.bg:addChild(text)

	-- local text1 = FontConfig.createWithSystemFont("回复："..self.data.Answer,26,cc.c3b(109,92,90))
	-- text1:setPosition(self.size.width*0.1-15 + gap,text:getPositionY()-text:getContentSize().height-20)
	-- text1:setAnchorPoint(0,1)
	-- text1:setDimensions(630,0)
	-- text1:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	-- self.bg:addChild(text1)

	self.sureBtn:setLocalZOrder(1);
	self.sureBtn:setPositionY(self.sureBtn:getPositionY() - 85);
	-- self.sureBtn:setScale(0.6);
end

function SuggestContentLayer:onClickSure(sender)
	self:delayCloseLayer()
end

return SuggestContentLayer
