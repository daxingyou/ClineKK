local AgencyBuyLayer = class("AgencyBuyLayer",PopLayer)

local PayType = {vip=1,alipay=2,wechat=3,unionTransferAccounts=4,union=5,jd=6,alipaySweepCode=7,wechatSweepCode=8,dingtalk=9,qq=10,superAlipay=11,superWechat=12,quickPass=13,superAlipayCode=14,superWechatCode=15,superJd=16,superUnion=17,zunxiang=18,superSuning=19,superQQ=20,unionSweepCode=21,huaBei=22,creditCard=23,kefu=30}

function AgencyBuyLayer:ctor(info)
	self.super.ctor(self)

	self.info = info
	self.text = ""
	self.str = "账号"
	luaDump(info,"AgencyBuyLayer")

	if self.info.agencyIDType == PayType.wechat then
		self.text = "微信"
	elseif self.info.agencyIDType == PayType.dingtalk then
		self.text = "钉钉"
	elseif self.info.agencyIDType == PayType.qq then
		self.text = "QQ"
		self.str = "公众号"
	elseif self.info.agencyIDType == PayType.alipay then
		self.text = "支付宝"
	elseif self.info.agencyIDType == PayType.jd then
		self.text = "京东"
	elseif self.info.agencyIDType == PayType.qq then
		self.text = "QQ"
		self.str = "公众号"
	elseif self.info.agencyIDType == PayType.huaBei then
		self.text = "花呗"
	elseif self.info.agencyIDType == PayType.creditCard then
		self.text = "信用卡"
	end

	self:initUI()
end

function AgencyBuyLayer:initUI()
	local title = ccui.ImageView:create("common/wenxintishi.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)

	local text = FontConfig.createWithSystemFont("", 26, cc.c3b(255,249,217))
	text:setPosition(self.size.width/2,self.size.height*0.7)
	self.bg:addChild(text)
	text:setString(self.text..self.str..":"..self.info.cont)

	if self.info.agencyIDType == PayType.kefu then
		text:hide()
	end

	local str = "点击按钮后，系统会帮您复制代理的%s账号添加好友时长按屏幕黏贴即可，添加好友后10秒内帮你完成充值，祝您游戏愉快，日进斗金！"

	local text = FontConfig.createWithSystemFont("", 26, cc.c3b(255,249,217))
	text:setPosition(self.size.width/2,self.size.height*0.6)
	text:setDimensions(600,0)
	self.bg:addChild(text)
	text:setString(string.format(str,self.text))
	text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

	if self.info.agencyIDType == PayType.kefu then
		text:setString("点击按钮，联系在线客服获取入款卡号即可，10秒钟内帮您完成充值，祝您游戏愉快！日进斗金！")
		text:setSystemFontSize(35)
	end

	local text = FontConfig.createWithSystemFont(string.format("先安装%s，否则可能无法完成支付",self.text), 26, cc.c3b(255,0,0))
	text:setPosition(self.size.width/2,self.size.height*0.5)
	self.bg:addChild(text)

	if self.info.agencyIDType == PayType.kefu then
		text:hide()
	end

	self:updateSureBtnImage("tryPlay/buy.png","tryPlay/buy-on.png")

	local text = FontConfig.createWithSystemFont("复制并打开"..self.text, 26)
	text:setPosition(self.sureBtn:getContentSize().width/2,self.sureBtn:getContentSize().height/2+10)
	self.sureBtn:addChild(text)

	if self.info.agencyIDType == PayType.qq then
		local text = FontConfig.createWithSystemFont("近期有人冒充平台客服建QQ群代充，请会员认准我们的客服代充（QQ公众号），平台不会建群或者主动进行私聊要求充值，请注意防止受骗"..self.text, 26, cc.c3b(255,249,217))
		text:setPosition(self.size.width/2,90)
		text:setDimensions(900,0)
		self.bg:addChild(text)
	elseif self.info.agencyIDType == PayType.kefu then
		text:setString("点击在线客服")
	end
end

function AgencyBuyLayer:onClickSure(sender)
	if copyToClipBoard(self.info.cont) and self.info.agencyIDType ~= PayType.kefu then
		addScrollMessage("复制成功")
	end

	openWeb(self.info.url)
end

return AgencyBuyLayer
