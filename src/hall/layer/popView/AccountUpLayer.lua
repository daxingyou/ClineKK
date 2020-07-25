local AccountUpLayer = class("AccountUpLayer", PopLayer)

function AccountUpLayer:create(iType)
	return AccountUpLayer.new(iType)
end

function AccountUpLayer:ctor(iType)
	if iType == nil then
		self.super.ctor(self, PopType.none)
	else
		self.super.ctor(self, PopType.small)
	end

	self.iType = iType

	self:initUI()
end

function AccountUpLayer:initUI()
	if self.iType == 1 or self.iType == 2 then
		local title = ccui.ImageView:create("common/wenxintishi.png")
		title:setPosition(self.size.width/2,self.size.height-90)
		self.bg:addChild(title)

		local info = FontConfig.createWithSystemFont("游客账号不允许提现，请先升级正式账号！",30,cc.c3b(255,249,217))
		info:setDimensions(650,0)
		info:setLineBreakWithoutSpace(true)
		info:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		info:setPosition(self.size.width/2,self.size.height/2)
		self.bg:addChild(info)

		if self.iType == 2 then
			info:setString("为了您的资金安全，请先将账号升级为正式账号，若微信无法登入时，可使用账号密码登入。")
			self:updateSureBtnImage("login/accountUp1.png","login/accountUp1-on.png")
		elseif self.iType == 1 then
			self:updateSureBtnImage("login/accountUp.png","login/accountUp-on.png")
		end
	else
		local sprite = ccui.ImageView:create("activity/zc_tu.png")
		sprite:setPosition(winSize.width/2,winSize.height/2)
		self:addChild(sprite)

		local sureBtn = ccui.Button:create("activity/zc_lijishengji.png","activity/zc_lijishengji-on.png")
		sureBtn:setPosition(sprite:getContentSize().width/2+20,30)
		sprite:addChild(sureBtn)
		sureBtn:onClick(function(sender) self:onClickSure(sender) end)

		local score = FontConfig.createWithCharMap(goldConvert(PlatformLogic.loginResult.UserChouShui)..":;","activity/zc_zitiao.png",76,98,"+")
		score:setPosition(450,150)
		sprite:addChild(score)
		score:setAnchorPoint(0,0.5)

		local shou = ccui.ImageView:create("activity/zc_shouzhi.png")
		sprite:addChild(shou)
		shou:setPosition(sprite:getContentSize().width/2+100,sprite:getContentSize().height/2-300)

		local zi = ccui.ImageView:create("activity/zc_shengjijisong.png")
		sprite:addChild(zi)
		zi:setPosition(sprite:getContentSize().width/2-100,sprite:getContentSize().height/2-150)

		local closeBtn = ccui.Button:create("common/cha.png","common/cha-on.png")
		closeBtn:setPosition(850,550)
		sprite:addChild(closeBtn)
		closeBtn:onClick(handler(self, self.onClickClose))
	end
end

function AccountUpLayer:onClickSure(sender)
	if self.iType == 2 then
		isShowShop = true
	end

	local layer = require("layer.popView.RegisterLayer"):create()
	display:getRunningScene():addChild(layer,9999)
	self:delayCloseLayer(0)
end

function AccountUpLayer:onClickClose(sender)
	isShowAccountUpgrade = true
	self:delayCloseLayer()
end

return AccountUpLayer
