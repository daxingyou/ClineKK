
-- 余额宝

local YuEBaoLayer = class("YuEBaoLayer", PopLayer)

function YuEBaoLayer:create(callback)
	return YuEBaoLayer.new(callback);
end

function YuEBaoLayer:ctor(callback)

	playEffect("hall/sound/yuebao.mp3")

	self.super.ctor(self, PopType.none)

	self.callback = callback

	self:initData();

	self:initUI();

	self:bindEvent();

end

function YuEBaoLayer:bindEvent()
	self:pushEventInfo(YuEBaoInfo,"getBankScore",handler(self, self.receiveGetBankScore))
	self:pushEventInfo(YuEBaoInfo,"bankLog",handler(self, self.receiveBankLog))
	self:pushEventInfo(YuEBaoInfo,"YuEBao",handler(self, self.receiveYuEBao))
	self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.updateAllMoney))
end

--刷新总金额
function YuEBaoLayer:updateAllMoney()
	if(self.allScore) then
		self.allScore:setString(goldConvertFour(PlatformLogic.loginResult.i64Bank,1));--总金额
		self:setBtnEnable();
	end
	YuEBaoInfo:sendYuEBaoRequest();
end

function YuEBaoLayer:initData()
	self.bg = nil;
	self.logData = {};
	self.allScore = nil;--总金额
	self.lastScore = nil;--上轮收益
	self.addUpScore = nil;--累计收益
	self.rateScore = nil; --每轮利率
	self.benefitScore = nil;--每轮收益

end

function YuEBaoLayer:initUI()
	luaPrint("YuEBaoLayer",globalUnit.isEnterGame);

	local winSize = cc.Director:getInstance():getWinSize();

	MailInfo:sendMailListInfoRequest()
	--MailInfo:sendQuestionListRequest()
	dispatchEvent("refreshScoreBank")

	if globalUnit.isEnterGame == true then

		local layer = require("layer.popView.activity.yuebao.ZhuanRuChuLayer"):create(0)
		self:addChild(layer)
		layer:setLocalZOrder(10);
		layer:hideCloseBtn()

		local node = require("layer.popView.UserInfoNode"):create()
		node:setPosition(layer.bg:getContentSize().width*0.68,layer.bg:getContentSize().height*0.10-35)
		layer.bg:addChild(node)
		node:setScale(0.9);
		node:setLocalZOrder(100);

		--关闭按钮
		local closeBtn = ccui.Button:create("common/close.png","common/close-on.png")
		closeBtn:setPosition(layer.bg:getContentSize().width-40,layer.bg:getContentSize().height-50)
		layer.bg:addChild(closeBtn)
		self.closeBtn = closeBtn
		closeBtn:setLocalZOrder(100);
		closeBtn:onTouchClick(function(sender) self:onClickClose(sender) end,1)

	else
		luaPrint("YuEBaoLayer不在游戏内");

		local bgImage = ccui.ImageView:create("activity/yuebao/commonBg1.png");
		bgImage:setPosition(winSize.width/2,winSize.height/2);
		self:addChild(bgImage)

		self.bg = ccui.ImageView:create("activity/yuebao/yeb_bg.png");
		self.bg:setPosition(self:getContentSize().width/2,self:getContentSize().height/2-50);
		self:addChild(self.bg)

		self.size = self.bg:getContentSize();

		--关闭按钮
		local closeBtn = ccui.Button:create("common/close.png","common/close-on.png")
		closeBtn:setPosition(bgImage:getContentSize().width-40,bgImage:getContentSize().height-60)
		bgImage:addChild(closeBtn)
		self.closeBtn = closeBtn
		closeBtn:onTouchClick(function(sender) self:onClickClose(sender) end,1)
		
		--标题
		local title = ccui.ImageView:create("activity/yuebao/yeb_yuebao.png")
		title:setPosition(bgImage:getContentSize().width/2,bgImage:getContentSize().height-30)
		bgImage:addChild(title)

		--明细
		local detailBtn = ccui.Button:create("activity/yuebao/yeb_mingxi.png","activity/yuebao/yeb_mingxi-on.png");
		detailBtn:setPosition(detailBtn:getContentSize().width*0.5+30+15,self.size.height-detailBtn:getContentSize().height*0.5-15);
		self.bg:addChild(detailBtn);
		detailBtn:setTag(3);
		detailBtn:onClick(function(sender) self:onClick(sender) end)

		--帮助
		local helpBtn = ccui.Button:create("activity/yuebao/yeb_banghzu.png","activity/yuebao/yeb_banghzu-on.png");
		helpBtn:setPosition(self.bg:getContentSize().width-helpBtn:getContentSize().width*0.5-30-15,self.size.height-helpBtn:getContentSize().height*0.5-15);
		self.bg:addChild(helpBtn);
		helpBtn:setTag(4);
		helpBtn:onClick(function(sender) self:onClick(sender) end)

		--上轮收益
		-- local lastMoney = ccui.ImageView:create("activity/yuebao/yeb_shanglunshouyi.png");
		-- lastMoney:setPosition(self.size.width/2,self.size.height-210);
		-- self.bg:addChild(lastMoney);

		--总金额
		-- local allMoney = ccui.ImageView:create("activity/yuebao/yeb_zongjine.png");
		-- allMoney:setPosition(self.size.width/2-50,self.size.height-310);
		-- self.bg:addChild(allMoney);

		--有收益金额图片
		-- local haveMakeMoney = ccui.ImageView:create("activity/yuebao/havemake.png");
		-- haveMakeMoney:setPosition(self.size.width/2-50,self.size.height-350);
		-- self.bg:addChild(haveMakeMoney);

		--无收益金额图片
		-- local noMakeMoney = ccui.ImageView:create("activity/yuebao/nomake.png");
		-- noMakeMoney:setPosition(self.size.width/2-50,self.size.height-390);
		-- self.bg:addChild(noMakeMoney);

		local haveMakeScore = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao2.png",16,27,"+")--"activity/yuebao/yeb_zitiao.png");
		haveMakeScore:setPosition(self.size.width/2-320,self.size.height-270);
		self.bg:addChild(haveMakeScore);
		haveMakeScore:setAnchorPoint(0.5,0.5);
		self.haveMakeScore = haveMakeScore

		local noMakeScore = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao2.png",16,27,"+")--"activity/yuebao/yeb_zitiao.png");
		noMakeScore:setPosition(self.size.width/2+320,self.size.height-270);
		self.bg:addChild(noMakeScore);
		noMakeScore:setAnchorPoint(0.5,0.5);
		self.noMakeScore = noMakeScore

		-- --累计收益
		-- local addUpMoney = ccui.ImageView:create("activity/yuebao/yeb_leijishouyi.png");
		-- addUpMoney:setPosition(self.size.width/2-250,260);
		-- self.bg:addChild(addUpMoney);
		
		-- --每轮利率
		-- local rate = ccui.ImageView:create("activity/yuebao/yeb_meilunlilv.png");
		-- rate:setPosition(self.size.width/2,260);
		-- self.bg:addChild(rate);
		
		-- --每轮收益
		-- local benefit = ccui.ImageView:create("activity/yuebao/yeb_meilunshouyi.png");
		-- benefit:setPosition(self.size.width/2+250,260);
		-- self.bg:addChild(benefit);
		

		local lastScore = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao.png",21,33,"+")--"activity/yuebao/yeb_zitiao.png");
		lastScore:setPosition(self.size.width/2-10,self.size.height-160);
		self.bg:addChild(lastScore);
		self.lastScore = lastScore

		local allScore = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao2.png",16,27,"+")--"activity/yuebao/yeb_zitiao.png");
		allScore:setPosition(self.size.width/2,self.size.height-270);
		self.bg:addChild(allScore);
		allScore:setAnchorPoint(0.5,0.5);
		self.allScore = allScore

		local addUpScore = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao3.png",16,27,"+")--"activity/yuebao/yeb_zitiao.png");
		addUpScore:setPosition(self.size.width/2-330,125);
		self.bg:addChild(addUpScore);
		self.addUpScore = addUpScore

		local rateScore = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao3.png",16,27,"+")--"activity/yuebao/yeb_zitiao.png");
		rateScore:setPosition(self.size.width/2,125);
		self.bg:addChild(rateScore);
		self.rateScore = rateScore

		local benefitScore = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao3.png",16,27,"+")--"activity/yuebao/yeb_zitiao.png");
		benefitScore:setPosition(self.size.width/2+310,125);
		self.bg:addChild(benefitScore);
		self.benefitScore = benefitScore

		--转出
		local zhuanchuBtn = ccui.Button:create("activity/yuebao/yeb_zhuanchu.png","activity/yuebao/yeb_zhuanchu-on.png","activity/yuebao/yeb_zhuanchu-cancle.png");
		zhuanchuBtn:setPosition(self.size.width/2-280,30);
		self.bg:addChild(zhuanchuBtn);
		zhuanchuBtn:setTag(1);
		self.zhuanchuBtn = zhuanchuBtn;
		zhuanchuBtn:onClick(function(sender) self:onClick(sender) end)

		--转入
		local zhuanruBtn = ccui.Button:create("activity/yuebao/yeb_zhuanru.png","activity/yuebao/yeb_zhuanru-on.png","activity/yuebao/yeb_zhuanru-cancle.png");
		zhuanruBtn:setPosition(self.size.width/2+280,30);
		self.bg:addChild(zhuanruBtn);
		zhuanruBtn:setTag(2);
		self.zhuanruBtn = zhuanruBtn;
		zhuanruBtn:onClick(function(sender) self:onClick(sender) end)

		--转账
		local zhuanzhuangBtn = ccui.Button:create("activity/yuebao/b-zhuanzhang.png","activity/yuebao/b-zhuanzhang-on.png","activity/yuebao/zhuanzhang-c.png");
		zhuanzhuangBtn:setPosition(self.size.width/2+280,30);
		zhuanzhuangBtn:setTag(5);
		zhuanzhuangBtn:setScale(1.0);
		if not YuEBaoInfo:isOpenTransfer() then
			zhuanzhuangBtn:hide()
		end
		self.bg:addChild(zhuanzhuangBtn);
		self.zhuanzhuangBtn = zhuanzhuangBtn;
		zhuanzhuangBtn:onClick(function(sender) self:onClick(sender) end)
		if YuEBaoInfo:isOpenTransfer() then
			zhuanchuBtn:setPositionX(self.size.width/2-280);
			zhuanruBtn:setPositionX(self.size.width/2);
			zhuanzhuangBtn:setPositionX(self.size.width/2+280);
		end

		self:setBtnEnable();

		YuEBaoInfo:sendYuEBaoRequest();

	end

end

function YuEBaoLayer:setBtnEnable()
	
	self.zhuanchuBtn:setEnabled(PlatformLogic.loginResult.i64Bank>=10000);

	self.zhuanzhuangBtn:setEnabled(PlatformLogic.loginResult.i64Bank>=10000);

	self.zhuanruBtn:setEnabled(PlatformLogic.loginResult.i64Money>=100);
	
end

--按钮回调函数
function YuEBaoLayer:onClick(sender)
	local tag = sender:getTag();
	luaPrint("onClick_tag",tag);
	local layer;
	if(tag == 1) then --转出
		luaPrint("转出");
	 	--local layer = require("layer.popView.activity.yuebao.ShengFenYanZhengTip"):create();
	 	if globalUnit:getBankPwd() == nil then
			layer = require("layer.popView.activity.yuebao.ShengFenYanZhengTip"):create(1)
		else
			layer = require("layer.popView.activity.yuebao.ZhuanRuChuLayer"):create()
		end
	elseif (tag == 2) then -- 转入
		luaPrint("转入");
		layer = require("layer.popView.activity.yuebao.ZhuanRuChuLayer"):create(1);
	elseif (tag == 3) then -- 明细
		luaPrint("明细");
		layer = require("layer.popView.activity.yuebao.DetailLayer"):create(self.logData);
	elseif (tag == 4) then -- 帮助
		luaPrint("帮助");
		layer = require("layer.popView.activity.yuebao.YuEBaoHelp"):create();
	elseif tag == 5 then -- 转账
		luaPrint("转账");
		if globalUnit:getBankPwd() == nil then
			layer = require("layer.popView.activity.yuebao.ShengFenYanZhengTip"):create(2)
		else
			layer = require("layer.popView.activity.yuebao.TransferLayer"):create()
		end
	end

	if layer then
 		display.getRunningScene():addChild(layer);
 	end

end

function YuEBaoLayer:onClickClose(sender)
	dispatchEvent("registerLayerUpCallBack");
	self:removeSelf()
end

function YuEBaoLayer:setRegisterCallback(callback)
	self.callback = callback
end

function YuEBaoLayer:receiveGetBankScore(data)
	luaPrint("YuEBaoLayer:receiveGetBankScore------");
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

function YuEBaoLayer:receiveBankLog(data)
	local data = data._usedata

	--luaDump(data,"receiveBankLog 余额宝记录---------");
	self.logData = data;

	-- if self.listView then
	-- 	self.listView:removeAllChildren()
	-- 	for k,v in pairs(data) do
	-- 		local layout = self:createItem(v)
	-- 		self.listView:pushBackCustomItem(layout)
	-- 	end
	-- end
end

--余额宝信息
function YuEBaoLayer:receiveYuEBao(data)
	local data = data._usedata
	luaDump(data,"余额宝信息");
	if self.allScore then
		self.allScore:setString(goldConvertFour(PlatformLogic.loginResult.i64Bank,1));--总金额
	end
	if self.lastScore then
		self.lastScore:setString(goldConvertFour(data.LastGain,1));--上轮收益
	end

	if self.addUpScore then
		self.addUpScore:setString(goldConvertFour(data.TotalGain,1));--累计收益
	end

	if self.rateScore then
		self.rateScore:setString(goldConvertFour(data.Rate,1)); --每轮利率
	end
	
	if self.benefitScore then
		self.benefitScore:setString(goldConvertFour(data.PerGain,1));--每轮收益
	end

	if self.noMakeScore then
		self.noMakeScore:setString(goldConvertFour(data.UnSecondReach,1));
	end

	if self.haveMakeScore then
		self.haveMakeScore:setString(goldConvertFour(PlatformLogic.loginResult.i64Bank-data.UnSecondReach,1));
	end

end



return YuEBaoLayer
