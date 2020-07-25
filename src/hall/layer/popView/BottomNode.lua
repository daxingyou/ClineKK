local BottomNode = class("BottomNode", BaseNode)

function BottomNode:ctor()
	self.super.ctor(self)

	self:bindEvent()

	SettlementInfo:sendConfigInfoRequest(5)

	self:initUI()
end

function BottomNode:bindEvent()
	self:pushEventInfo(MailInfo, "newMailNotify", handler(self, self.receiveNewMailNotify))
	self:pushEventInfo(MailInfo, "newQuestionNotify", handler(self, self.receiveNewQuestionNotify))
	self:pushEventInfo(SettlementInfo, "configInfo", handler(self, self.receiveConfigInfo))
end

function BottomNode:initUI(iType)
	local bg = ccui.ImageView:create("hall/bottomBg.png")
	bg:setAnchorPoint(cc.p(0.5,0))
	bg:setPosition(cc.p(0,0))
	self:addChild(bg)

	-- local image = ccui.ImageView:create("hall/bottomBg1.png")
	-- image:setPosition(1559-(139.5-(winSize.width-1280)/2),0)
	-- image:setAnchorPoint(1,0)
	-- bg:addChild(image)

	local size = bg:getContentSize()

	local x = 240
	local d = 135
	local h = 18

	if checkIphoneX() then
		x = 140
		d = 150
		if device.platform == "ios" then
			d = 160
		end
	end

	if iType == nil or SettlementInfo:getConfigInfoByID(5) == 1 then--显示
		-- --结算
		-- local btn = ccui.Button:create("hall/jiesuan.png","hall/jiesuan-on.png")
		-- btn:setPosition(x,size.height/2+h)
		-- btn:setTag(1)
		-- bg:addChild(btn)
		-- btn:onClick(function(sender) self:onClickBtn(sender) end)

		-- x = x + d
	else
		x = 240
		d = 145

		if checkIphoneX() then
			x = 150
			d = 190
		end
	end

	--推广员
	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(150,60))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(x,size.height/2+h)
	btn:setTouchEnabled(true)
	btn:setTag(5)
	bg:addChild(btn)
	btn:onTouchClick(function(sender) self:onClickBtn(sender) end)

	local skeleton_animation = createSkeletonAnimation("yuerubaiwan", "hall/effect/yuerubaiwan.json", "hall/effect/yuerubaiwan.atlas")
	if skeleton_animation then
		skeleton_animation:setAnimation(1,"yuerubaiwan", true)
		skeleton_animation:setPosition(btn:getContentSize().width/2,btn:getContentSize().height*0.5)    
		btn:addChild(skeleton_animation)
	end

	x = x + d + 45
	--保险箱
	local btn = ccui.Button:create("hall/yueebao.png","hall/yueebao-on.png")
	btn:setPosition(x,size.height/2+h)
	btn:setTag(3)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	if globalUnit.isYuEbao == true then
		btn:loadTextures("hall/yueebao.png","hall/yueebao-on.png")
	else
		if iType == 1 and globalUnit.isYuEbao == false then
			btn:loadTextures("hall/baoxianxiang.png","hall/baoxianxiang-on.png")
		end
	end

	x = x + d + 5
	--客服
	local btn = ccui.Button:create("hall/kefu.png","hall/kefu-on.png")
	btn:setPosition(x,size.height/2+h)
	btn:setTag(4)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	--消息
	x = x + d
	local btn = ccui.Button:create("hall/xiaoxi.png","hall/xiaoxi-on.png")
	btn:setPosition(x,size.height/2+h-5)
	btn:setTag(2)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	self.mailBtn = btn

	--x = x + d
	-- --建议
	-- local btn = ccui.Button:create("hall/jianyi.png","hall/jianyi-on.png")
	-- btn:setPosition(x,size.height/2+h)
	-- btn:setTag(6)
	-- bg:addChild(btn)
	-- btn:onClick(function(sender) self:onClickBtn(sender) end)
	-- self.questionBtn = btn

	-- x = x + d
	-- --设置
	-- local btn = ccui.Button:create("hall/shezhi.png","hall/shezhi-on.png")
	-- btn:setPosition(x,size.height/2+h)
	-- btn:setTag(7)
	-- bg:addChild(btn)
	-- btn:onClick(function(sender) self:onClickBtn(sender) end)

	x = x + d
	--公告
	local btn = ccui.Button:create("hall/notice.png","hall/notice-on.png")
	btn:setPosition(x,size.height/2+h)
	btn:setTag(9)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	x = x + d
	--公告
	local btn = ccui.Button:create("hall/active.png","hall/active-on.png")
	btn:setPosition(x,size.height/2+h)
	btn:setTag(10)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	if iType == nil or SettlementInfo:getConfigInfoByID(5) == 1 then--显示
		x = x + d
		--提现
		local btn = ccui.Widget:create()
		btn:setContentSize(cc.size(90,90))
		btn:setAnchorPoint(cc.p(0.5,0.5))
		btn:setPosition(x,size.height/2+h+8)
		btn:setTouchEnabled(true)
		btn:setTag(1)
		bg:addChild(btn)
		btn:onTouchClick(function(sender) self:onClickBtn(sender) end)

		local skeleton_animation = createSkeletonAnimation("tixian", "hall/effect/tixian.json", "hall/effect/tixian.atlas")
		if skeleton_animation then
			skeleton_animation:setAnimation(1,"tixian", true)
			skeleton_animation:setPosition(btn:getContentSize().width/2,btn:getContentSize().height*0.5)
			btn:addChild(skeleton_animation)
		end
	end

	x = x + d + 160

	if checkIphoneX() then
		if iType == nil or SettlementInfo:getConfigInfoByID(5) == 1 then--显示
			x = x + 50
		else
			x = x + 50
		end
	end

	--商城
	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(200,90))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(x-100,size.height/2+h)
	btn:setTouchEnabled(true)
	btn:setTag(8)
	bg:addChild(btn)
	btn:onTouchClick(function(sender) self:onClickBtn(sender) end)

	local skeleton_animation = createSkeletonAnimation("chongzhi", "hall/effect/chongzhi.json", "hall/effect/chongzhi.atlas")
	if skeleton_animation then
		skeleton_animation:setAnimation(1,"chongzhi", true)
		skeleton_animation:setPosition(btn:getContentSize().width/2,btn:getContentSize().height*0.5)
		btn:addChild(skeleton_animation)
	end
end

function BottomNode:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then--结算
		if not showBindPhone() then
			display.getRunningScene():addChild(require("layer.popView.SettlementLayer"):create())
		-- else
		-- 	isShowSettlementLayer = true
		end
	elseif tag == 2 then--消息
		display.getRunningScene():addChild(require("layer.popView.MailLayer"):create())
	elseif tag == 3 then--保险箱
		if globalUnit.isYuEbao == true then
			self:showYuEBao()
		else
			self:showBankBox()
		end
	elseif tag == 4 then--客服
		openWeb(GameConfig:getServerUrl())
	elseif tag == 5 then--推广员
		createGeneralizeLayer()
	elseif tag == 6 then--建议
		display.getRunningScene():addChild(require("layer.popView.SuggestLayer"):create())
	elseif tag == 7 then--设置
		display.getRunningScene():addChild(require("layer.popView.SetLayer"):create())
	elseif tag == 8 then--商城
		createShop()
	elseif tag == 9 then--公告
		display.getRunningScene():addChild(require("layer.popView.NoticeLayer"):create(2))
		playEffect("hall/sound/announcement.mp3")
	elseif tag == 10 then--公告
		display.getRunningScene():addChild(require("layer.popView.NoticeLayer"):create(1))
		playEffect("hall/sound/announcement.mp3")
	end
end

--余额宝
function BottomNode:showYuEBao()
	local layer;
	luaPrint("showYuEBao",PlatformLogic.loginResult.bSetBankPass);
	--if not isEmptyString(PlatformLogic.loginResult.szMobileNo) then -- 先判断有木有绑定手机
		if PlatformLogic.loginResult.bSetBankPass == 0 then
			layer = require("layer.popView.activity.yuebao.ShengFenYanZheng"):create();
		else
			luaPrint("getBankPwd()",globalUnit:getBankPwd());
			-- if globalUnit:getBankPwd() == nil then
			-- 	layer = require("layer.popView.activity.yuebao.ShengFenYanZhengTip"):create()
			-- else
			-- 	layer = require("layer.popView.activity.yuebao.YuEBaoLayer"):create()
			-- end
			layer = require("layer.popView.activity.yuebao.YuEBaoLayer"):create()
		end
	-- else
	-- 	layer = require("layer.popView.activity.yuebao.BindPhoneTiShi"):create()
	-- end

	if layer then
		display.getRunningScene():addChild(layer)
	end
end

-- 保险箱
function BottomNode:showBankBox()
	local layer

	if PlatformLogic.loginResult.bSetBankPass == 0 then
		layer = require("layer.popView.BankPasswordLayer"):create()
	else
		if globalUnit:getBankPwd() == nil then
			layer = require("layer.popView.BankPasswordTip"):create()
		else
			layer = require("layer.popView.BankLayer"):create()
		end
	end

	if layer then
		display.getRunningScene():addChild(layer)
	end
end

function BottomNode:receiveNewMailNotify(data)
	local data = data._usedata

	local node = ccui.Helper:seekNodeByName(self.mailBtn,"hongdian")

	if data == 0 then
		if node then
			node:removeSelf()
		end
		return
	end

	if node == nil then
		node = ccui.ImageView:create("common/hongdian.png")
		node:setPosition(self.mailBtn:getContentSize().width*0.9,self.mailBtn:getContentSize().height*0.9)
		node:setName("hongdian")
		self.mailBtn:addChild(node)

		local text = FontConfig.createWithSystemFont(data,20,cc.c3b(255,255,0))
		text:setName("text")
		text:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
		node:addChild(text)
	else
		local text = ccui.Helper:seekNodeByName(node,"text")

		if text then
			text:setString(data)
		else
			local text = FontConfig.createWithSystemFont(data,20,cc.c3b(255,255,0))
			text:setName("text")
			text:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
			node:addChild(text)
		end
	end
end

function BottomNode:receiveNewQuestionNotify(data)
	local data = data._usedata

	local node = ccui.Helper:seekNodeByName(self.questionBtn,"hongdian")

	if data == 0 then
		if node then
			node:removeSelf()
		end
		return
	end

	if node == nil then
		node = ccui.ImageView:create("common/hongdian.png")
		node:setPosition(self.questionBtn:getContentSize().width*0.8,self.questionBtn:getContentSize().height*0.8)
		node:setName("hongdian")
		self.questionBtn:addChild(node)

		local text = FontConfig.createWithSystemFont(data,20,cc.c3b(255,255,0))
		text:setName("text")
		text:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
		node:addChild(text)
	else
		local text = ccui.Helper:seekNodeByName(node,"text")

		if text then
			text:setString(data)
		else
			local text = FontConfig.createWithSystemFont(data,20,cc.c3b(255,255,0))
			text:setName("text")
			text:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
			node:addChild(text)
		end
	end
end

--提现按钮配置
function BottomNode:receiveConfigInfo(data)
	local data = data._usedata

	if data.id == 5 or data.id == 11 then
		self:removeAllChildren()
		self:initUI(1)
		self:receiveNewMailNotify({_usedata=MailInfo.newMailNotify})
		self:receiveNewQuestionNotify({_usedata=MailInfo.newQuestionNotify})
	end
end

return BottomNode
