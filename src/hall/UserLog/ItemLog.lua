--奔驰宝马
local ItemLog = class("ItemLog", PopLayer)


function ItemLog:ctor(gameData)
	self.super.ctor(self, PopType.moreBig)
	self:setName("ItemLog");

	self:initData(gameData);
	self:initUI();
	

end

function ItemLog:create(gameData)
	local layer = ItemLog.new(gameData);

	return layer;
end

function ItemLog:initUI()
	self.sureBtn:removeSelf()
	self:updateBg("hall/UserLog/UserLog_commonBg1.png");
	self:updateCloseBtnPos(10,-30);
	local size = self.bg:getContentSize();

	local title = ccui.ImageView:create("hall/UserLog/UserLog_zhanji.png");
	title:setPosition(size.width/2,size.height-50);
	self.bg:addChild(title);

	local detailStr = FontConfig.createWithSystemFont(self.m_gameData.Detail.title,26,cc.c3b(255,249,217));
	detailStr:setAnchorPoint(0,1);
    detailStr:setPosition(65,size.height-120);
    self.bg:addChild(detailStr);

    local ding = ccui.ImageView:create("hall/UserLog/UserLog_dinglan.png");
	ding:setAnchorPoint(0.5,1);
	ding:setPosition(size.width/2,size.height-160);
	self.bg:addChild(ding,10);

	local dingSize = ding:getContentSize();

	--创建下注 开奖结果
	local xiazhu = ccui.ImageView:create("hall/UserLog/UserLog_xiazhu.png");
	xiazhu:setPosition(250,dingSize.height/2);
	ding:addChild(xiazhu);

	local kaijiang = ccui.ImageView:create("hall/UserLog/UserLog_kaijiangjieguo.png");
	kaijiang:setPosition(820,dingSize.height/2);
	ding:addChild(kaijiang);

	--添加分割条
	local fenge = ccui.ImageView:create("hall/UserLog/UserLog_fengexian.png");
	fenge:setAnchorPoint(0.5,1);
	fenge:setPosition(550,size.height-190);
	self.bg:addChild(fenge);

	--创建下注信息
	local scrollSize = cc.size(460,400);
	local xiazhuStr = FontConfig.createWithSystemFont(self.m_gameData.Detail.xiazhu,26,cc.c3b(255,249,217),cc.size(scrollSize.width,0),"",cc.TEXT_ALIGNMENT_LEFT);
	xiazhuStr:setAnchorPoint(0,1);

	local ScrollView_xiazhu = ccui.ScrollView:create();
	ScrollView_xiazhu:setContentSize(scrollSize);
	self.bg:addChild(ScrollView_xiazhu);
	ScrollView_xiazhu:setPosition(cc.p(68,ding:getPositionY()-dingSize.height-10));
	ScrollView_xiazhu:setInnerContainerSize(cc.size(scrollSize.width,xiazhuStr:getContentSize().height));
	ScrollView_xiazhu:setAnchorPoint(cc.p(0,1));
	ScrollView_xiazhu:setBounceEnabled(true);
	ScrollView_xiazhu:setInertiaScrollEnabled(true);
	ScrollView_xiazhu:setBounceEnabled(false);
	ScrollView_xiazhu:setScrollBarEnabled(false);

	if xiazhuStr:getContentSize().height<scrollSize.height then
		xiazhuStr:setPosition(0,scrollSize.height)
	else
		xiazhuStr:setPosition(0,xiazhuStr:getContentSize().height)
	end

	ScrollView_xiazhu:addChild(xiazhuStr);


	--创建结果
	local scrollSize1 = cc.size(500,400);
	local jieguoStr = FontConfig.createWithSystemFont(self.m_gameData.Detail.result,26,cc.c3b(255,249,217),cc.size(scrollSize1.width,0),"",cc.TEXT_ALIGNMENT_LEFT);
	jieguoStr:setAnchorPoint(0,1);

	local ScrollView_jieguo = ccui.ScrollView:create();
	ScrollView_jieguo:setContentSize(scrollSize1);
	self.bg:addChild(ScrollView_jieguo);
	ScrollView_jieguo:setPosition(cc.p(588,ding:getPositionY()-dingSize.height-10));
	ScrollView_jieguo:setInnerContainerSize(cc.size(scrollSize1.width,jieguoStr:getContentSize().height));
	ScrollView_jieguo:setAnchorPoint(cc.p(0,1));
	ScrollView_jieguo:setBounceEnabled(true);
	ScrollView_jieguo:setInertiaScrollEnabled(true);
	ScrollView_jieguo:setBounceEnabled(false);
	ScrollView_jieguo:setScrollBarEnabled(false);

	if jieguoStr:getContentSize().height<scrollSize1.height then
		jieguoStr:setPosition(0,scrollSize1.height)
	else
		jieguoStr:setPosition(0,jieguoStr:getContentSize().height)
	end

	ScrollView_jieguo:addChild(jieguoStr);

end

function ItemLog:initData(gameData)
	self.m_gameData = gameData;
	self.target = target;
end



return ItemLog