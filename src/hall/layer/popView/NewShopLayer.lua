local ShopLayer = class("ShopLayer",PopLayer)

local PayType = {vip=1,alipay=2,wechat=3,unionTransferAccounts=4,union=5,jd=6,alipaySweepCode=7,wechatSweepCode=8,dingtalk=9,qq=10,superAlipay=11,superWechat=12,quickPass=13,superAlipayCode=14,superWechatCode=15,superJd=16,superUnion=17,zunxiang=18,superSuning=19,superQQ=20,unionSweepCode=21,huaBei=22,creditCard=23,jdSweepCode=24,qqSweepCode=25,suningSweetCode=26,superCloudPay=27,cloudSweetCode=28,aliNative=29,kefu=30}

function ShopLayer:ctor()
	self.super.ctor(self,PopType.big)

	self:bindEvent()

	self:initData()

	self:initUI()
	SettlementInfo:sendPayConfigInfoRequest()
end

function ShopLayer:initData()
	self.payBtn = {}
	self.payNode = {}
	-- self.payConfig = {
	-- 	url = "",
	-- 	{payType=PayType.vip,title="VIP充值",discount=1,payCopy=8869987,reward=3000,id=3444,agency={{agencyIDType=PayType.wechat,cont="42355",url=""},{agencyIDType=PayType.wechat,cont="42355",url=""},{agencyIDType=PayType.wechat,cont="42355",url=""},{agencyIDType=PayType.wechat,cont="42355",url=""},{agencyIDType=PayType.wechat,cont="42355",url=""},{agencyIDType=PayType.wechat,cont="42355",url=""},{agencyIDType=PayType.wechat,cont="42355",url=""},{agencyIDType=PayType.dingtalk,cont="qq12323",url=""},{agencyIDType=PayType.qq,cont="dd42355",url=""},{agencyIDType=PayType.wechat,cont="42355fff",url=""}}},--代理充值
	-- 	{payType=PayType.alipay,title="支付宝",payInfo="",id=3444,payMoney="500_600_700_1000_140000_1500_2000_600_700_1000_1400_1500_2000_600_700_1000_1400_1500_2000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
	-- 	{payType=PayType.wechat,title="微信z",payInfo="",id=3444,payMoney="500_600_700_1400_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
	-- 	{payType=PayType.union,title="银联扫码",payInfo="",id=3444,payMoney="500_600_700_1000_1400_1500_2000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
	-- 	{payType=PayType.union,title="银联快捷",payInfo="玩家最常用充值金额",id=3444,payMoney="500_600_700_1000_1400_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
	-- 	{payType=PayType.jd,title="京东2",payInfo="玩家最常用充值金额",id=3444,payMoney="500_6000_700_1000_14000_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
	-- 	{payType=PayType.unionTransferAccounts,title="银行转账(最低10)",payInfo="支持同行转账，跨行转账，微信转账到银行卡，支付宝转账到银行卡，需要帮助联系客服",id=3444,payMoney="500_6000_700_1000_14000_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000,cardNumber="62305200460131302170",cardName="大幅度",bankType="农业银行",bankAddr="支行"},
	-- 	{payType=PayType.alipaySweepCode,title="支付宝扫码",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- {payType=PayType.wechatSweepCode,title="微信扫码",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- {payType=PayType.superAlipay,title="支付宝",discount=1,payCont=
			-- {
				-- {payType=PayType.alipaySweepCode,title="扫码1",discount=4,payInfo="温馨提示:单笔额度10-5000元,(!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png",bankAccountName="多发点",bankNo="43535465453",bankName="人民银行"},
				-- {payType=PayType.wechatSweepCode,title="扫码1",discount=4,payInfo="温馨提示:单笔额度10-5000元,(!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png",bankAccountName="多发点",bankNo="43535465453",bankName="人民银行"},
				-- {payType=PayType.unionSweepCode,title="扫码1",discount=4,payInfo="温馨提示:单笔额度10-5000元,(!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png",bankAccountName="多发点",bankNo="43535465453",bankName="人民银行"},
				-- {payType=PayType.wechat,checkMoney="100_300|500_600|2000_4000",realMoney="500_600__1000_1400_2000",title="微信1",payInfo="温馨提示:单笔额度10-5000元",id=3444,payMoney="500_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=1,minMoney=200,maxMoney=100000},
				-- {payType=PayType.wechat,checkMoney="100_300|500_600|2000_4000",title="微信2",payInfo="温馨提示:单笔额度10-5000元,(!",id=3444,payMoney="500_600_1500_2000_1500_3000_1500_5000_1500",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
				-- {payType=PayType.wechat,realMoney="500_600__1000_1400_2000",title="微信3",payInfo="温馨提示:单笔额度10-5000元",id=3444,payMoney="500_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="e支付1",payInfo="",id=3444,payMoney="10_20_50_100_200_500_1000_2000_200_500_1000_2000200_500_1000_2000200_500_1000_2000",url="",isInputMoney=1,minMoney=1,maxMoney=1000,discount=1},
				-- {payType=PayType.alipay,title="e支付2",payInfo="",id=3444,payMoney="10_20_50_100_200_500_1000_2000",url="",isInputMoney=1,minMoney=1,maxMoney=1000},
				-- {payType=PayType.alipay,title="e支付",payInfo="",id=3444,payMoney="300_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="赢赢云",payInfo="",id=3444,payMoney="400_600_700_1000_1000_1000_1000_1000_1000",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="赢赢云",payInfo="",id=3444,payMoney="800_600_700_1000_600_700_1000_1400_1500",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="赢赢云",payInfo="",id=3444,payMoney="800_600_700_600_700_1000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="迪迦",payInfo="",id=3444,payMoney="800_600_700_1000_1400_1500",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="支付宝7",payInfo="",id=3444,payMoney="800_600_700_600_700_1000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="支付宝8",payInfo="",id=3444,payMoney="800_600_700_1000_1400_1500",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="支付宝7",payInfo="",id=3444,payMoney="800_600_700_600_700_1000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="支付宝8",payInfo="",id=3444,payMoney="800_600_700_1000_1400_1500",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="支付宝7",payInfo="",id=3444,payMoney="800_600_700",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
				-- {payType=PayType.alipay,title="支付宝8",payInfo="",id=3444,payMoney="800_600_700_1000_1400_1500",url="",isInputMoney=0,minMoney=0,maxMoney=100000}
		-- 	}
		-- },
		-- {payType=PayType.superWechat,title="微信",payCont=
		-- 	{
		-- 		{payType=PayType.alipaySweepCode,title="扫码1",discount=4,payInfo="温馨提示:单笔额度10-5000元,(!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png",bankAccountName="多发点",bankNo="43535465453",bankName="人民银行"},
		-- 		{payType=PayType.wechat,title="微信1",discount=4,payInfo="",id=3444,payMoney="500_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
		-- 		{payType=PayType.wechat,title="微信2",payInfo="",id=3444,payMoney="500_600_1500_2000_1500_3000_1500_5000_1500",url="",isInputMoney=0,minMoney=0,maxMoney=100000},
		-- 		{payType=PayType.wechat,title="微信3",payInfo="",id=3444,payMoney="500_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000}
		-- 	}
		-- },
		-- {payType=PayType.superAlipayCode,title="支付宝扫码",discount=2,payCont=
		-- 	{
		-- 		{payType=PayType.alipaySweepCode,title="扫码1",discount=4,payInfo="温馨提示:单笔额度10-5000元,(!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png",bankAccountName="多发点",bankNo="43535465453",bankName="人民银行"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码2",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码3",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr1.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码3",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr2.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr3.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码3",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qyr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码3",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码3",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码3",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.alipaySweepCode,title="扫码4",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 	}
		-- },
		-- {payType=PayType.superWechatCode,title="微信扫码",payCont=
		-- 	{
		-- 		{payType=PayType.wechatSweepCode,title="扫码1",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.wechatSweepCode,title="扫码2",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 		{payType=PayType.wechatSweepCode,title="扫码3",payInfo="温馨提示:单笔额度10-5000元,(截屏保存二维码,打开支付宝扫一扫二维码即可支付)支付成功后,输入充值金额，扫码成功流水号，点充值完成，实时到账!",id=3444,minMoney=0,maxMoney=100000,codeUrl="",imageName="qr.png"},
		-- 	}
		-- },
	-- 	{payType=PayType.superJd,title="京东",payCont=
	-- 		{
	-- 			{payType=PayType.jd,title="jd1",payInfo="",id=3444,payMoney="500_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
	-- 			{payType=PayType.jd,title="jd2",payInfo="",id=3444,payMoney="500_600_1500_2000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
	-- 			{payType=PayType.jd,title="jd3",payInfo="",id=3444,payMoney="500_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000}
	-- 		}
	-- 	},
		-- {payType=PayType.superUnion,title="银联",payCont=
		-- 	{
		-- 		{payType=PayType.union,title="union1",payInfo="",id=3444,payMoney="500_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
		-- 		{payType=PayType.union,title="union2",payInfo="",id=3444,payMoney="500_600_1500_2000",url="",isInputMoney=1,minMoney=0,maxMoney=100000},
		-- 		{payType=PayType.union,title="union3",payInfo="",id=3444,payMoney="500_600_700_1000_600_700_1000_1400_1500_2000",url="",isInputMoney=0,minMoney=0,maxMoney=100000}
		-- 	}
		-- },
	-- 	{payType=PayType.quickPass,title="官网闪付",payInfo="",id=3444,alipayUrl="",wechatUrl="",unionUrl=""},
		-- {payType=PayType.zunxiang,title="官网",payInfo="专属vip充值通道，三秒到账充值不等候，一对一为你服务，可通过银联转账，微信，支付宝充值，尊享每笔充值2%的优惠金。365棋牌官网www.38655.com祝：您旗开得胜，盈利多多！点击充值进入专员为您服务"},
	-- }
	self.payConfig = SettlementInfo.payConfigInfo
	self.sPayConfig = TableToStr(self.payConfig)
end

function ShopLayer:bindEvent()
	self:pushEventInfo(SettlementInfo, "payConfigInfo", handler(self, self.receivePayConfigInfo))
end

function ShopLayer:receivePayConfigInfo(data)
	local data = data._usedata

	if self.sPayConfig == TableToStr(data) then
		return
	end

	if isEmptyString(data) then
		return
	end

	self:initData()

	self.payConfig = data
	self.sPayConfig = TableToStr(self.payConfig)

	self.closeBtn:retain()

	self.bg:removeAllChildren()
	self.closeBtn:addTo(self.bg)

	self:initUI()
end

function ShopLayer:initUI()
	if self.sureBtn and not tolua.isnull(self.sureBtn) then
		self.sureBtn:removeSelf()
	end

	self:setName("shopLayer")

	local title = ccui.ImageView:create("common/shopTitle.png")
	title:setPosition(self.size.width/2,self.size.height-30)
	self.bg:addChild(title)

	--充值记录
	local btn = ccui.Button:create("common/investrecordbtn.png","common/investrecordbtn.png","common/investrecordbtn.png")
	btn:setPosition(self.size.width/2+350,self.size.height-80)
	btn:onClick(function(sender) self:onClickDepositRecordBtn(sender) end)
	btn:setScale(1.2)
	-- btn:setVisible(false);
	self.bg:addChild(btn)
	self:createPayBtn()
end

function ShopLayer:onClickDepositRecordBtn(sender)
	local GetCashRecordLayer = require("layer.popView.GetCashRecordLayer");
	local Layer = GetCashRecordLayer:create(0);
	Layer:ignoreAnchorPointForPosition(false);
	Layer:setAnchorPoint(cc.p(0.5,0.5));
	
	local size = display.getRunningScene():getContentSize();
	Layer:setPosition(size.width/2,size.height/2);
	display.getRunningScene():addChild(Layer,9999);
end
function ShopLayer:createPayBtn()
	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,0.5))
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setScrollBarEnabled(false)
	listView:setContentSize(cc.size(self.size.width*0.22, self.size.height*0.75))
	listView:setPosition(self.size.width*0.14-5,self.size.height*0.45-10)
	self.bg:addChild(listView)

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw");
	-- listView:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(listView:getContentSize().width,listView:getContentSize().height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,1,1))

	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(self.size.width*0.7-10,self.size.height*0.75+30))
	layout:setPosition(self.size.width*0.25, self.size.height*0.1-41)
	self.bg:addChild(layout)
	-- local layout = ccui.ImageView:create("shop/moneyBg.png")
	-- layout:setPosition(self.size.width*0.26, self.size.height*0.1-5)
	-- layout:setAnchorPoint(0,0)
	-- self.bg:addChild(layout)
	self.layout = layout

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw");
	-- layout:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(layout:getContentSize().width,layout:getContentSize().height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,1,1))

	if not isEmptyTable(self.payConfig) then
		for k,v in pairs(self.payConfig) do
			if type(v) == "table" then
				local lay = ccui.Layout:create()
				local btn = ccui.Button:create("shop/button.png","shop/button-on.png","shop/button-dis.png")
				lay:setContentSize(cc.size(btn:getContentSize().width-5,btn:getContentSize().height+10))
				btn:setTag(k)
				btn:onClick(function(sender) self:onClickBtn(sender) end)
				btn.payData = v
				btn:setEnabled(k~=1)
				btn:setPosition(lay:getContentSize().width*0.55-10,lay:getContentSize().height/2)
				lay:addChild(btn)
				-- btn:setTitleText(v.title)
				-- btn:setTitleFontSize(22)
				-- btn:setTitleFontName(FontConfig.gFontFile)
				table.insert(self.payBtn,btn)

				local text = FontConfig.createWithTTF(v.title, FontConfig.gFontFile, 26)
				text:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2)
				text:setDimensions(150,0)
				btn:addChild(text)
				btn._title = text

				local icon = ccui.Button:create("shop/"..v.payType.."/icon.png","shop/"..v.payType.."/icon-on.png","shop/"..v.payType.."/icon-dis.png")
				icon:setTouchEnabled(false)
				icon:setPosition(btn:getContentSize().width*0.15,btn:getContentSize().height/2)
				btn:addChild(icon)
				btn.icon = icon

				local value = v.discount

				if type(value) == "number" then
					value = "优惠"..v.discount.."%"
				end

				if v.discount and not isEmptyString(value) then
					local discount = ccui.ImageView:create("shop/tiao.png")
					discount:setPosition(btn:getContentSize().width*0.8,btn:getContentSize().height*0.8)
					btn:addChild(discount)
					-- discount:setScale(0.8)
					btn.discount = discount

					local text = FontConfig.createWithSystemFont(value, 18)
					text:setPosition(discount:getContentSize().width/2,discount:getContentSize().height/2+5)
					-- text:setRotation(-45)
					text:setColor(FontConfig.colorYellow)
					discount:addChild(text)
				end

				listView:pushBackCustomItem(lay)
			end
		end

		self:onClickBtn(self.payBtn[1])
	end
end

function ShopLayer:onClickBtn(sender)
	local tag = sender:getTag()

	for k,v in pairs(self.payBtn) do
		if k == tag then
			v:setEnabled(false)
			v.icon:setEnabled(false)
			v._title:setColor(cc.c3b(255,248,201))
			self:createPayItem(v.payData,tag)
		else
			v:setEnabled(true)
			v.icon:setEnabled(true)
			v._title:setColor(cc.c3b(255,255,255))
		end
	end
end

function ShopLayer:createPayItem(info,tag)
	for k,v in pairs(self.payNode) do
		v:hide()
	end

	if self.payNode[tag] then
		self.payNode[tag]:show()
		return
	end

	local node = nil

	if info.payType == PayType.vip then
		node = self:createVip(info)
	elseif info.payType == PayType.alipay then
		node = self:createAlipay(info)
	elseif info.payType == PayType.wechat then
		node = self:createWechat(info)
	elseif info.payType == PayType.union then
		node = self:createUnion(info)
	elseif info.payType == PayType.jd then
		node = self:createJd(info)
	elseif info.payType == PayType.unionTransferAccounts then
		node = self:createUnionTransferAccounts(info)
	elseif info.payType == PayType.alipaySweepCode then
		node = self:createAlipaySweepCode(info)
	elseif info.payType == PayType.wechatSweepCode then
		node = self:createWechatSweepCode(info)
	elseif info.payType == PayType.superAlipay then
		node = self:createSuperAlipay(info)
	elseif info.payType == PayType.superWechat then
		node = self:createSuperWechat(info)
	elseif info.payType == PayType.quickPass then
		node = self:createQuickPass(info)
	elseif info.payType == PayType.superAlipayCode then
		node = self:createSuperAlipayCode(info)
	elseif info.payType == PayType.superWechatCode then
		node = self:createSuperWechatCode(info)
	elseif info.payType == PayType.superJd then
		node = self:createSuperJd(info)
	elseif info.payType == PayType.superUnion then
		node = self:createSuperUnion(info)
	elseif info.payType == PayType.zunxiang then
		node = self:createZunxiang(info)
	elseif info.payType == PayType.superSuning then
		node = self:createSuperAlipay(info)
	elseif info.payType == PayType.superQQ then
		node = self:createSuperAlipay(info)
	elseif info.payType == PayType.superCloudPay then
		node = self:createSuperAlipay(info)
	end

	if node then
		self.payNode[tag] = node
	end
end

function ShopLayer:createVip(info)
	local size = self.layout:getContentSize()
	local base = "shop/"..info.payType.."/"

	local node = cc.Node:create()
	self.layout:addChild(node)

	-- local image = ccui.ImageView:create("shop/moneyBg.png")
	-- image:setPosition(size.width/2,size.height*0.5-3)
	-- image:setScale9Enabled(true)
	-- image:setContentSize(cc.size(size.width+20,size.height+20))
	-- node:addChild(image)

	local image = ccui.ImageView:create(base.."info.png")
	image:setPosition(size.width/2,size.height-10)
	image:setAnchorPoint(0.5,1)
	node:addChild(image)

	local id = ccui.ImageView:create(base.."fuzhiidkuang.png")
	id:setPosition(image:getContentSize().width/3+20,-15)
	id:setAnchorPoint(0.5,1)
	image:addChild(id)

	local text = FontConfig.createWithSystemFont("ID:      "..info.payCopy,28)
	text:setAnchorPoint(0.5,0.5)
	text:setPosition(id:getContentSize().width/4,id:getContentSize().height/2)
	id:addChild(text)

	local func = function(sender)
		if copyToClipBoard(info.payCopy) then
			addScrollMessage("复制ID成功")
		end
	end

	local btn = ccui.Button:create(base.."fuzhiid.png",base.."fuzhiid-on.png")
	btn:onClick(func)
	btn:setPosition(id:getContentSize().width*0.85-5,id:getContentSize().height/2+2)
	id:addChild(btn)

	local btn = ccui.Button:create(base.."jubaoyoujiang.png",base.."jubaoyoujiang-on.png")
	btn:setPosition(image:getContentSize().width*0.9,id:getPositionY()+8)
	btn:setAnchorPoint(0.5,1)
	image:addChild(btn)

	local str = "当您发现VIP专用充值人员向您推荐其他平台游戏,请您截图并举报给我们,查找后立刻奖励"
	local len = #(string.gsub(str, "[\128-\191]", ""))-1

	str = str..tostring(info.reward).."元"

	local text = FontConfig.createWithTTF(str, nil, 22)
	text:setPosition(btn:getContentSize().width+40,btn:getContentSize().height)
	text:setDimensions(500,0)
	text:setAnchorPoint(1,0.5)
	if text.getLetter then
		for i=1,string.len(tostring(info.reward)) do
			text:getLetter(len+i):setColor(FontConfig.colorWhite)
		end
	end

	local warn = ccui.ImageView:create(base.."warn.png")
	warn:setPosition(btn:getContentSize().width+40,btn:getContentSize().height)
	warn:setAnchorPoint(1,0)
	warn:setScale9Enabled(true)
	warn:setContentSize(text:getContentSize())
	btn:addChild(warn)
	warn:addChild(text)
	text:setPosition(warn:getContentSize().width,warn:getContentSize().height/2)
	warn:hide()
	btn:onClick(function(sender) warn:setVisible(not warn:isVisible()) end)

	-- 创建代理信息
	local x = -1
	local y = 0
	local d = 0
	local count = 2
	local x0 = 0

	if isEmptyTable(info.agency) then
		return node
	end

	local parent = node
	-- if #info.agency > 6 then
		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0.5,1))
		listView:setDirection(ccui.ScrollViewDir.vertical)
		listView:setBounceEnabled(true)
		listView:setScrollBarEnabled(false)
		node:addChild(listView)
		-- listView:setTouchEnabled(#info.agency > 4)

		for i=1,math.ceil(#info.agency/count) do
			local layout = ccui.Layout:create()
			for j=1,count do
				local v = info.agency[(i-1)*count+j]

				if v == nil then
					break
				end

				local daili = ccui.Button:create(base.."lianxichongzhi.png",base.."lianxichongzhi-on.png")
				layout:setContentSize(size.width-10,daili:getContentSize().height)
				daili.data = v

				if x == -1 then
					d = (layout:getContentSize().width - daili:getContentSize().width * count)/(count+1)
					x0 = d + daili:getContentSize().width/2
					y = image:getPositionY() - image:getContentSize().height - btn:getContentSize().height
					x = x0

					listView:setContentSize(cc.size(size.width-10, daili:getContentSize().height*2))
					listView:setPosition(size.width*0.5,y)
				end

				daili:setPosition(x,daili:getContentSize().height/2)
				layout:addChild(daili)

				local text = FontConfig.createLabel(FontConfig.gFontConfig_26, FormotGameNickName(tostring(v.name),13), cc.c3b(150,91,25))
				text:setPosition(daili:getContentSize().width/2,daili:getContentSize().height*0.82)
				daili:addChild(text)

				local text = FontConfig.createLabel(FontConfig.gFontConfig_26, FormotGameNickName("支持:",8), cc.c3b(150,91,25))
				text:setPosition(daili:getContentSize().width/2-text:getContentSize().width-50,daili:getContentSize().height*0.52)
				daili:addChild(text)
				text:setCascadeColorEnabled(false)

				local support
				if not isEmptyString(v.supportType) then
					support = string.split(v.supportType,"_")
				end

				if not isEmptyTable(support) then
					local x1 = text:getContentSize().width
					local y1 = text:getContentSize().height/2

					for kk,vv in pairs(support) do
						local wx = ccui.ImageView:create(base..vv..".png")
						wx:setPosition(x1,y1)
						wx:setAnchorPoint(0,0.5)
						text:addChild(wx)
						x1 = x1 + wx:getContentSize().width
					end
				end

				if (i == 1) and j < 3 then
					local huobao = ccui.ImageView:create(base.."huobao.png")
					huobao:setAnchorPoint(0,1)
					huobao:setPosition(3,daili:getContentSize().height-4)
					daili:addChild(huobao)
				end

				daili:onClick(function(sender) self:addChild(require("layer.popView.AgencyBuyLayer"):create(sender.data)) end)

				x = x + d + daili:getContentSize().width
			end

			x = x0
			listView:pushBackCustomItem(layout)
		end
	-- else
	-- 	for k,v in pairs(info.agency) do
	-- 		local daili = ccui.Button:create(base.."lianxichongzhi.png",base.."lianxichongzhi-on.png")
	-- 		daili.data = v

	-- 		if x == -1 then
	-- 			d = (size.width - daili:getContentSize().width * count)/(count+1)-20
	-- 			x0 = d + daili:getContentSize().width/2
	-- 			y = image:getPositionY() - image:getContentSize().height - id:getContentSize().height - 15 - 10
	-- 			x = x0
	-- 		end

	-- 		daili:setAnchorPoint(0.5,1)
	-- 		daili:setPosition(x,y)
	-- 		node:addChild(daili)

	-- 		local text = FontConfig.createLabel(FontConfig.gFontConfig_26, FormotGameNickName("代理"..v.cont,8), cc.c3b(150,91,25))
	-- 		text:setPosition(daili:getContentSize().width/2,daili:getContentSize().height*0.7)
	-- 		daili:addChild(text)

	-- 		if k < 3 then
	-- 			local huobao = ccui.ImageView:create(base.."huobao.png")
	-- 			huobao:setAnchorPoint(0,1)
	-- 			huobao:setPosition(3,daili:getContentSize().height-4)
	-- 			daili:addChild(huobao)
	-- 		end

	-- 		daili:onClick(function(sender) self:addChild(require("layer.popView.AgencyBuyLayer"):create(sender.data)) end)

	-- 		x = x + d + daili:getContentSize().width
	-- 		if k % 3 == 0 then
	-- 			y = y - daili:getContentSize().height - 10
	-- 			x = x0
	-- 		end
	-- 	end
	-- end

	return node
end

function ShopLayer:createUnion(info)
	return self:createAlipay(info)
end

function ShopLayer:createJd(info)
	return self:createAlipay(info)
end

function ShopLayer:createWechat(info)
	return self:createAlipay(info)
end

function ShopLayer:createUnionTransferAccounts(info)
	local size = self.layout:getContentSize()
	local base = "shop/"..info.payType.."/"

	local node = cc.Node:create()
	self.layout:addChild(node)

	-- local image = ccui.ImageView:create(base.."info.png")
	-- image:setPosition(size.width/2,size.height+2)
	-- image:setAnchorPoint(0.5,1)
	-- node:addChild(image)

	-- local image = ccui.ImageView:create("shop/moneyBg.png")
	-- image:setPosition(size.width/2,size.height/2)
	-- image:setOpacity(0)
	-- node:addChild(image)

	-- local gang = ccui.ImageView:create("shop/liantiao.png")
	-- gang:setPosition(40,image:getContentSize().height)
	-- image:addChild(gang)

	-- local gang = ccui.ImageView:create("shop/liantiao.png")
	-- gang:setPosition(image:getContentSize().width-40,image:getContentSize().height)
	-- image:addChild(gang)

	-- size = image:getContentSize()

	local icon = ccui.ImageView:create(base.."logo.png")
	icon:setPosition(5,size.height*0.9)
	icon:setAnchorPoint(0,0.5)
	node:addChild(icon)

	local input = ccui.ImageView:create("shop/input.png")
	input:setPosition(size.width*0.5+5,size.height*0.9)
	input:setOpacity(0)
	node:addChild(input)

	local chongzhi = ccui.ImageView:create("shop/chongzhijine.png")
	chongzhi:setPosition(-20,input:getContentSize().height*0.5)
	chongzhi:setAnchorPoint(1,0.5)
	input:addChild(chongzhi)

	local moneyEditText = createEditBox(chongzhi,"请输入充值金额",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(200,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
	moneyEditText:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
	moneyEditText:setMaxLength(11)

	local chongzhi = ccui.ImageView:create("shop/chongzhikahao.png")
	chongzhi:setPosition(input:getContentSize().width/2+25,input:getContentSize().height*0.5)
	chongzhi:setAnchorPoint(0,0.5)
	input:addChild(chongzhi)

	local moneyEditText1 = createEditBox(chongzhi,"请输入卡号后6位",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(200,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
	moneyEditText1:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
	moneyEditText1:setMaxLength(6)

	local y = size.height*0.75+10
	--卡号
	local x = input:getPositionX() - input:getContentSize().width/2 - 16
	local card = ccui.ImageView:create(base.."shoukuaikahao.png")
	card:setAnchorPoint(1,0.5)
	card:setPosition(x,y)
	node:addChild(card)

	local text = FontConfig.createWithSystemFont(info.cardNumber, 25, cc.c3b(255,248,201))
	text:setPosition(card:getContentSize().width+20,card:getContentSize().height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	text:setAnchorPoint(0,0.5)
	text:setColor(FontConfig.colorWhite)
	card:addChild(text)

	local btn = ccui.Button:create("shop/fuzhi.png","shop/fuzhi-on.png")
	btn:setPosition(size.width*0.75,y-5)
	node:addChild(btn)
	btn:onClick(function(sender) if copyToClipBoard(info.cardNumber) then addScrollMessage("复制成功") end end)

	local d = input:getPositionY() - card:getPositionY()

	-- 姓名
	local card = ccui.ImageView:create(base.."shoukuanxingming.png")
	card:setAnchorPoint(1,0.5)
	card:setPosition(x,y-d)
	node:addChild(card)

	local text = FontConfig.createWithSystemFont(info.cardName, 25, cc.c3b(255,248,201))
	text:setPosition(card:getContentSize().width+20,card:getContentSize().height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	text:setAnchorPoint(0,0.5)
	text:setColor(FontConfig.colorWhite)
	card:addChild(text)

	local btn = ccui.Button:create("shop/fuzhi.png","shop/fuzhi-on.png")
	btn:setPosition(size.width*0.75,y-d-10)
	node:addChild(btn)
	btn:onClick(function(sender) if copyToClipBoard(info.cardName) then addScrollMessage("复制成功") end end)

	-- 收款银行
	local card = ccui.ImageView:create(base.."shoukuanyinghang.png")
	card:setAnchorPoint(1,0.5)
	card:setPosition(x,y-d*2)
	node:addChild(card)

	local text = FontConfig.createWithSystemFont(info.bankType, 25, cc.c3b(255,248,201))
	text:setPosition(card:getContentSize().width+20,card:getContentSize().height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	text:setAnchorPoint(0,0.5)
	text:setColor(FontConfig.colorWhite)
	card:addChild(text)

	local btn = ccui.Button:create("shop/fuzhi.png","shop/fuzhi-on.png")
	btn:setPosition(size.width*0.75,y-d*2-10)
	node:addChild(btn)
	btn:onClick(function(sender) if copyToClipBoard(info.bankType) then addScrollMessage("复制成功") end end)

	--开户银行
	local card = ccui.ImageView:create(base.."kaihuyinghang.png")
	card:setAnchorPoint(1,0.5)
	card:setPosition(x,y-d*3)
	node:addChild(card)

	local text = FontConfig.createWithSystemFont(info.bankAddr, 25, cc.c3b(255,248,201))
	text:setPosition(card:getContentSize().width+20,card:getContentSize().height/2)
	text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	text:setAnchorPoint(0,0.5)
	text:setColor(FontConfig.colorWhite)
	card:addChild(text)

	local btn = ccui.Button:create("shop/fuzhi.png","shop/fuzhi-on.png")
	btn:setPosition(size.width*0.75,y-d*3-10)
	node:addChild(btn)
	btn:onClick(function(sender) if copyToClipBoard(info.bankAddr) then addScrollMessage("复制成功") end end)

	local str = info.payInfo
	if isEmptyString(str) then
		str = "支持同行转账，跨行转账，微信转账到银行卡，支付宝转账到银行卡，需要帮助联系客服"
	end

	local text = FontConfig.createWithSystemFont(info.payInfo, 25, cc.c3b(255,248,201))
	text:setPosition(size.width/2,y-d*4)
	text:setDimensions(600,0)
	node:addChild(text)

	local btn = ccui.Button:create("shop/likechongzhi.png","shop/likechongzhi-on.png")
	btn:setPosition(size.width/2,10)
	btn:setAnchorPoint(0.5,0)
	node:addChild(btn)
	btn:onClick(function(sender)
		local money = moneyEditText:getText()

		if isEmptyString(money) then
			addScrollMessage("请输入充值金额")
			return
		end

		local ret = checkNumber(money)

		if not ret then
			addScrollMessage("充值金额必须是数字")
			return
		end

		local card = moneyEditText1:getText()

		if isEmptyString(card) then
			addScrollMessage("请输入银行卡号后6位")
			return
		end

		local ret = checkNumber(card)

		if not ret then
			addScrollMessage("银行卡号后6位必须是数字")
			return
		end

		local url = info.url.."?action=addorder2&userid="..PlatformLogic.loginResult.dwUserID.."&transferCardNO="..card.."&type=1&paytypeid="..info.id.."&money="..money.."&timestamp="..os.time().."000"

		local func = function(result, response)
			if result == true then
				local re = json.decode(response)
				addScrollMessage(re.Msg)
			else
				addScrollMessage("充值失败")
			end
		end

		if not isEmptyString(info.domain) then
			url = string.gsub(url,info.domain,GameConfig.tuiguanUrl)
		end

		HttpUtils:requestHttp(url, func, "POST")
	end)

	return node
end

qrPng = {}
qrWidth = 180
function ShopLayer:createAlipaySweepCode(info)
	local size = self.layout:getContentSize()
	local base = "shop/"..info.payType.."/"

	local node = cc.Node:create()
	self.layout:addChild(node)

	local image = ccui.ImageView:create(base.."info.png")
	image:setPosition(size.width/2,size.height)
	image:setAnchorPoint(0.5,1)
	node:addChild(image)

	-- local image = ccui.ImageView:create("shop/moneyBg.png")
	-- image:setPosition(size.width/2,size.height/2)
	-- image:setOpacity(0)
	-- node:addChild(image)

	-- local gang = ccui.ImageView:create("shop/liantiao.png")
	-- gang:setPosition(40,image:getContentSize().height)
	-- image:addChild(gang)

	-- local gang = ccui.ImageView:create("shop/liantiao.png")
	-- gang:setPosition(image:getContentSize().width-40,image:getContentSize().height)
	-- image:addChild(gang)

	-- size = image:getContentSize()

	local input = ccui.ImageView:create("shop/input.png")
	input:setPosition(size.width*0.5-10,size.height*0.6)
	input:setOpacity(0)
	node:addChild(input)

	local chongzhi = ccui.ImageView:create("shop/chongzhijine.png")
	chongzhi:setPosition(input:getContentSize().width*0.6,input:getContentSize().height*0.5)
	chongzhi:setAnchorPoint(1,0.5)
	input:addChild(chongzhi)

	local moneyEditText = createEditBox(chongzhi,"请输入充值金额",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(320,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
	moneyEditText:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
	moneyEditText:setMaxLength(11)

	local chongzhi = ccui.ImageView:create("shop/liushuihao.png")
	chongzhi:setPosition(input:getContentSize().width*0.6,-input:getContentSize().height)
	chongzhi:setAnchorPoint(1,0.5)
	input:addChild(chongzhi)

	local moneyEditText1 = createEditBox(chongzhi,"请输入流水号",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(320,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
	moneyEditText1:onEditHandler(handler(self, self.onMoneyEditBoxHandler))

	local path = info.imageName

	if isEmptyString(path) and not isEmptyString(info.codeUrl) then
		local ts = string.reverse(info.codeUrl)
		local i,j = string.find(ts,"/",1,true)
		local m = string.len(ts)-i-1
		path = string.sub(info.codeUrl,m+1)
	end

	local qr
	local y = size.height*0.65

	if not isEmptyString(path) then
		local fullPath = cc.FileUtils:getInstance():getWritablePath().."qr/"..path

		luaPrint("pay 二维码路径 ",fullPath)

		if cc.FileUtils:getInstance():isFileExist(fullPath) and display.loadImage(fullPath) ~= nil then
			qrPng[fullPath] = true
		end

		qr = ccui.ImageView:create(fullPath)
		qr:setPosition(5,y)--- math.abs(y/2-qrWidth/2))
		qr:setAnchorPoint(0,1)
		node:addChild(qr)

		if qrPng[fullPath] ~= true then
			createDir("qr")
			if not isEmptyString(info1.codeUrl) then
				local url = info1.codeUrl..path
				if isEmptyString(info1.imageName) then
					url = info1.codeUrl
				end
				luaPrint("请求二维码路径 ",url)

				HttpUtils:downLoadFile(url,
				fullPath,
				function(result, savePath, response) downQrCallback(qr,fullPath, result, savePath, response) end)
			end
		else
			local s = qr:getContentSize()
			qr:setScaleX(qrWidth/s.width)
			qr:setScaleY(qrWidth/s.height)
		end
	else
		qr = ccui.ImageView:create()
		qr:setPosition(5,y)
		qr:setAnchorPoint(0,1)
		node:addChild(qr)
	end

	local btn = ccui.Button:create("shop/chongzhiwancheng.png","shop/chongzhiwancheng-on.png")
	btn:setPosition(size.width*0.7,30)
	btn:setAnchorPoint(0.5,0)
	node:addChild(btn)
	btn:onClick(function(sender)
		local money = moneyEditText:getText()

		if isEmptyString(money) then
			addScrollMessage("请输入充值金额")
			return
		end

		local ret = checkNumber(money)

		if not ret then
			addScrollMessage("充值金额必须是数字")
			return
		end

		local card = moneyEditText1:getText()

		if isEmptyString(card) then
			addScrollMessage("请输入流水号")
			return
		end

		local ret = checkNumber(card)

		if not ret then
			addScrollMessage("流水号必须是数字")
			return
		end

		local url = info.url.."?action=addorder2&userid="..PlatformLogic.loginResult.dwUserID.."&transactionid="..card.."&type=0&paytypeid="..info.id.."&money="..money.."&timestamp="..os.time().."000"

		if not isEmptyString(info.domain) then
			url = string.gsub(url,info.domain,GameConfig.tuiguanUrl)
		end

		openWeb(url)
	end)

	return node
end

function ShopLayer:createWechatSweepCode(info)
	return self:createAlipaySweepCode(info)
end

function ShopLayer:createSuperWechat(info)
	return self:createSuperAlipay(info)
end

function ShopLayer:createSuperAlipayCode(info)
	local size = self.layout:getContentSize()
	local base = "shop/"..info.payType.."/"

	local node = cc.Node:create()
	self.layout:addChild(node)

	-- local image = ccui.ImageView:create("shop/moneyBg.png")
	-- image:setPosition(size.width/2,size.height*0.5)
	-- image:setScale9Enabled(true)
	-- image:setContentSize(cc.size(size.width+20,size.height+20))
	-- image:setOpacity(0)
	-- node:addChild(image)

	-- size = image:getContentSize()

	local listView1 = ccui.ListView:create()
	listView1:setAnchorPoint(cc.p(0.5,1))
	listView1:setDirection(ccui.ScrollViewDir.vertical)
	listView1:setBounceEnabled(true)
	listView1:setScrollBarEnabled(false)
	listView1:setContentSize(cc.size(size.width,size.height-5))
	listView1:setPosition(size.width/2,size.height)
	node:addChild(listView1)

	local layout1 = ccui.Layout:create()
	layout1:setContentSize(cc.size(size.width,size.height-5))
	listView1:pushBackCustomItem(layout1)

	size = layout1:getContentSize()

	local bg = ccui.ImageView:create("shop/btnBg.png")
	bg:setPosition(size.width/2,size.height)
	bg:setAnchorPoint(0.5,1)
	bg:setScale9Enabled(true)
	layout1:addChild(bg)

	local btns = {}

	local width = 0

	local func = function(sender,y,row)
		listView1:setTouchEnabled(false)
		for k,v in pairs(btns) do
			v:setEnabled(v~=sender)
			if v~=sender then
				v:setTitleColor(cc.c3b(255,255,255))
				v:setTouchEnabled(false)
			else
				v:setTitleColor(cc.c3b(255,248,201))
			end
		end

		local info1 = sender.data

		layout1:removeChildByName("mnode",true)

		local mnode = cc.Node:create()
		mnode:setName("mnode")
		layout1:addChild(mnode)
		mnode.oldY = mnode:getPositionY()

		local width1 = 0

		local str = "说明:充值时请直接转入此账号,为了您的财产安全,绑定后不可私自更改,如需修改,请联系客服。请输入正确的支付宝实名制名字,不然无法转入该账号。"

		if not isEmptyString(info1.payInfo) then
			str = info1.payInfo
		end

		local text = FontConfig.createWithSystemFont(str, 26)
		text:setPosition(size.width/2,y)
		text:setAnchorPoint(0.5,1)
		text:setColor(cc.c3b(255,248,201))
		text:setScale(0.8)
		text:setDimensions(800,0)
		mnode:addChild(text)
		y = y - text:getContentSize().height - 10

		width1 = width1 + text:getContentSize().height + 10

		local line = ccui.ImageView:create("shop/line.png")
		line:setScaleY(1.2)
		line:setPosition(size.width/2, y-line:getContentSize().height/2*line:getScaleY())
		mnode:addChild(line)

		local input = ccui.ImageView:create("shop/input.png")
		input:setPosition(size.width*0.5-10,y - input:getContentSize().height*0.7)
		input:setOpacity(0)
		mnode:addChild(input)

		local chongzhi = ccui.ImageView:create("shop/dingdan.png")
		chongzhi:setPosition(input:getContentSize().width*0.63,input:getContentSize().height)
		chongzhi:setAnchorPoint(0,0.5)
		input:addChild(chongzhi)

		local chongzhi = ccui.ImageView:create("shop/cunkuanxingming.png")
		chongzhi:setPosition(input:getContentSize().width*0.92,input:getContentSize().height*0)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		local moneyEditText = createEditBox(chongzhi,"输入存款姓名",cc.EDITBOX_INPUT_MODE_SINGLELINE,1,cc.size(240,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
		-- moneyEditText:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
		moneyEditText:setMaxLength(20)

		local chongzhi = ccui.ImageView:create("shop/cunkuanjine.png")
		chongzhi:setPosition(input:getContentSize().width*0.92,-input:getContentSize().height*1.25)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		-- width1 = width1 + input:getContentSize().height*0.7

		local moneyEditText1 = createEditBox(chongzhi,"输入存款金额",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(240,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
		moneyEditText1:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
		moneyEditText1:setSwallowTouches(false)

		local chongzhi = ccui.ImageView:create("shop/cunkuanshijian.png")
		chongzhi:setPosition(input:getContentSize().width*0.92,-input:getContentSize().height*2.5)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		-- width1 = width1 + input:getContentSize().height*0.7

		local moneyEditText2 = createEditBox(chongzhi,"输入存款时间(如20190103)",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(240,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
		moneyEditText2:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
		moneyEditText2:setSwallowTouches(false)

		local path = info1.imageName

		if isEmptyString(path) and not isEmptyString(info1.codeUrl) then
			local ts = string.reverse(info1.codeUrl)
			local i,j = string.find(ts,"/",1,true)
			local m = string.len(ts)-i+1
			path = string.sub(info1.codeUrl,m+1)
		end

		local qr
		local fullPath = cc.FileUtils:getInstance():getWritablePath().."qr/"..tostring(path)
		luaPrint("pay 二维码路径 ",fullPath)

		if not isEmptyString(path) then
			if cc.FileUtils:getInstance():isFileExist(fullPath) and display.loadImage(fullPath) ~= nil then
				qrPng[fullPath] = true
			end

			qr = ccui.ImageView:create(fullPath)
			qr:setPosition(120,y-20)--- math.abs(y/2-qrWidth/2))
			qr:setAnchorPoint(0,1)
			mnode:addChild(qr)

			if qrPng[fullPath] ~= true then
				createDir("qr")
				if not isEmptyString(info1.codeUrl) then
					local url = info1.codeUrl..path
					if isEmptyString(info1.imageName) then
						url = info1.codeUrl
					end
					luaPrint("请求二维码路径 ",url)

					HttpUtils:downLoadFile(url,
					fullPath,
					function(result, savePath, response) downQrCallback(qr,fullPath, result, savePath, response) end)
				end
			else
				local s = qr:getContentSize()
				qr:setScaleX(qrWidth/s.width)
				qr:setScaleY(qrWidth/s.height)
			end
		else
			qr = ccui.ImageView:create()
			qr:setPosition(120,y-20)
			qr:setAnchorPoint(0,1)
			mnode:addChild(qr)
		end

		qr:setLocalZOrder(1)
		local btn = ccui.Button:create("shop/qrBg.png","shop/qrBg.png")
		btn:setScale(qrWidth/btn:getContentSize().width+0.1)
		btn:setPosition(qr:getPositionX()+qrWidth/2,qr:getPositionY()-qrWidth/2)
		mnode:addChild(btn)
		btn:onClick(function(sender)
			if qrPng[fullPath] then
				saveSystemPhoto(fullPath)
			else
				addScrollMessage("正在下载二维码")
			end
		end)

		local text = FontConfig.createWithSystemFont("点击二维码保存到手机", 26)
		text:setPosition(qr:getPositionX()+qrWidth/2,qr:getPositionY()-qrWidth-10)
		text:setAnchorPoint(0.5,1)
		text:setColor(cc.c3b(254,246,196))
		text:setScale(0.7)
		mnode:addChild(text)

		local chongzhi = ccui.ImageView:create("shop/xingming.png")
		chongzhi:setPosition(-input:getContentSize().width*0.3,-input:getContentSize().height*2.5)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		local text = FontConfig.createWithSystemFont(info1.bankAccountName, 26)
		text:setPosition(chongzhi:getContentSize().width+10,chongzhi:getContentSize().height/2+3)
		text:setAnchorPoint(0,0.5)
		text:setColor(cc.c3b(254,246,196))
		chongzhi:addChild(text)

		local btn = ccui.Button:create("shop/fuzhi1.png","shop/fuzhi1-on.png")
		btn:onClick(function(sender) if copyToClipBoard(info1.bankAccountName) then addScrollMessage("复制成功") end end)
		btn:setPosition(input:getContentSize().width*0.3,chongzhi:getPositionY())
		input:addChild(btn)

		local chongzhi = ccui.ImageView:create("shop/zhanghao.png")
		chongzhi:setPosition(-input:getContentSize().width*0.3,-input:getContentSize().height*3.3)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		local text = FontConfig.createWithSystemFont(FormotGameNickName(info1.bankNo,10), 26)
		text:setPosition(chongzhi:getContentSize().width+10,chongzhi:getContentSize().height/2+3)
		text:setAnchorPoint(0,0.5)
		text:setColor(cc.c3b(254,246,196))
		chongzhi:addChild(text)

		local btn = ccui.Button:create("shop/fuzhi1.png","shop/fuzhi1-on.png")
		btn:onClick(function(sender) if copyToClipBoard(info1.bankNo) then addScrollMessage("复制成功") end end)
		btn:setPosition(input:getContentSize().width*0.3,chongzhi:getPositionY())
		input:addChild(btn)

		local chongzhi = ccui.ImageView:create("shop/yinhangmingcheng.png")
		chongzhi:setPosition(-input:getContentSize().width*0.3,-input:getContentSize().height*4.1)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		local text = FontConfig.createWithSystemFont(info1.bankName, 26)
		text:setPosition(chongzhi:getContentSize().width+10,chongzhi:getContentSize().height/2+3)
		text:setAnchorPoint(0,0.5)
		text:setColor(cc.c3b(254,246,196))
		chongzhi:addChild(text)

		local btn = ccui.Button:create("shop/fuzhi1.png","shop/fuzhi1-on.png")
		btn:onClick(function(sender) if copyToClipBoard(info1.bankName) then addScrollMessage("复制成功") end end)
		btn:setPosition(input:getContentSize().width*0.3,chongzhi:getPositionY())
		input:addChild(btn)

		local btn = ccui.Button:create("shop/tijiaodingdan.png","shop/tijiaodingdan-on.png")
		btn:setPosition(size.width*0.75,y- math.abs(y/2-qrWidth/2) - qrWidth)
		btn:setAnchorPoint(0.5,0)
		mnode:addChild(btn)
		btn:setSwallowTouches(false)
		btn:onClick(function(sender)
			local name = moneyEditText:getText();

			if isEmptyString(name) then
				addScrollMessage("请输入您的存款姓名")
				return
			end

			if isEmoji(name) or not stringIsHaveChinese(name,1) then
				addScrollMessage("您输入的存款姓名包含非汉字如空格等")
				return
			end

			local card = moneyEditText1:getText()

			if isEmptyString(card) then
				addScrollMessage("请输入您的存款金额")
				return
			end

			local ret = checkNumber(card)

			if not ret then
				addScrollMessage("存款金额必须是数字")
				return
			end

			local tm = moneyEditText2:getText()

			if isEmptyString(tm) then
				addScrollMessage("请输入您的存款时间")
				return
			end

			local ret = checkNumber(tm)

			if not ret then
				addScrollMessage("存款时间必须是数字")
				return
			end

			local url = info1.url.."?action=addorder2&userid="..PlatformLogic.loginResult.dwUserID.."&transactionid="..card.."&type=0&paytypeid="..info1.id.."&money="..money.."&timestamp="..os.time().."000"
			local func = function(result, response)
				if result == true then
					local re = json.decode(response)
					addScrollMessage(re.Msg)
				else
					addScrollMessage("充值失败")
				end
			end

			if not isEmptyString(info1.domain) then
				url = string.gsub(url,info1.domain,GameConfig.tuiguanUrl)
			end

			HttpUtils:requestHttp(url, func, "POST")
		end)

		width1 = width1 + line:getContentSize().height*line:getScaleY() + 20

		local ch = layout1:getChildren()
		local chazhi = width+width1 - size.height

		local items = listView1:getItems()
		local h = 0
		if #items > 1 then
			h = items[#items]:getContentSize().height
			listView1:removeLastItem()
		end

		if chazhi < h then
			local lay = ccui.Layout:create()
			lay:setContentSize(cc.size(size.width,h))
			listView1:pushBackCustomItem(lay)
		else
			local lay = ccui.Layout:create()
			lay:setContentSize(cc.size(size.width,chazhi))
			listView1:pushBackCustomItem(lay)
			h = chazhi
		end

		btn:setPositionY(qr:getPositionY() - qrWidth*2)
		listView1:setTouchEnabled(true)

		for k,v in pairs(btns) do
			v:stopAllActions()
			v.isclick = nil
			v:setScale(1)

			if v~=sender then
				v:setTouchEnabled(true)
			end
		end
	end

	-- 创建列表
	local x = 30
	local y = size.height * 0.94

	-- local icon = ccui.ImageView:create(base.."logo.png")
	-- icon:setPosition(x,y)
	-- icon:setAnchorPoint(0,0.5)
	-- layout1:addChild(icon)
	-- icon.oldY = icon:getPositionY()

	-- local btnBg = ccui.ImageView:create("shop/xuanzexianlu.png")
	-- btnBg:setPosition(x*2+10,icon:getContentSize().height/2)
	-- btnBg:setAnchorPoint(0,0.5)
	-- icon:addChild(btnBg)

	-- x = x  * 2  * 1.5 + 10 + 10 + btnBg:getContentSize().width
	x = 0
	y = size.height

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0,1))
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setScrollBarEnabled(false)
	listView:setPosition(x,y)
	layout1:addChild(listView)
	listView:setTouchEnabled(false)
	listView.oldY = listView:getPositionY()

	local column = 4
	local row = math.ceil(#info.payCont/column)
	local height = -1
	local k = 1
	local y0 = 0

	for i=1,row do
		local layout = ccui.Layout:create()
		layout:setLocalZOrder(row-i+1)

		for j=1,column do
			local v = info.payCont[k]
			if v == nil then
				break
			end

			local btn = ccui.Button:create("shop/1.png","shop/1-on.png","shop/1-dis.png")

			if height == -1 then
				height =  btn:getContentSize().height
				listView:setContentSize(cc.size(btn:getContentSize().width * column - x,height * row))

				d = (listView:getContentSize().width - btn:getContentSize().width * column)/(column+1)
				x = d
				y0 = height/2
			end

			btn:setPosition(x,y0)
			btn:setAnchorPoint(0,0.5)
			layout:addChild(btn)
			x = x + btn:getContentSize().width + d

			if i > 1 then
				btn:setPositionY(btn:getPositionY()+9*(i-1))
			end

			btn:setTitleText(v.title)
			btn:setTitleFontSize(30)
			btn:setTitleFontName(FontConfig.gFontFile)
			btn:onClick(function(sender) func(sender,y,row) end)
			btn:setTitleColor(cc.c3b(255,248,201))
			btn.data = v
			btn:setSwallowTouches(false)

			if v.discount and v.discount > 0 then
				local discount = ccui.ImageView:create("shop/tiao.png")
				discount:setPosition(30,btn:getContentSize().height/2+15)
				discount:setScale(0.75)
				btn:addChild(discount)
				btn.discount = discount

				local text = FontConfig.createWithSystemFont("优惠"..v.discount.."%", 20)
				text:setPosition(discount:getContentSize().width/2-10,discount:getContentSize().height/2+10)
				text:setRotation(-45)
				text:setColor(FontConfig.colorYellow)
				discount:addChild(text)
			end

			table.insert(btns,btn)
			k = k + 1
		end

		x = d

		layout:setContentSize(cc.size(listView:getContentSize().width,height))
		layout:setPosition(size.width/2,size.height - layout:getContentSize().height*(i-1))
		layout:setAnchorPoint(0.5,1)
		layout1:addChild(layout)
	end

	y = y - listView:getContentSize().height
	width = listView:getContentSize().height
	listView:setTouchEnabled(false)
	bg:setContentSize(cc.size(listView:getContentSize().width,listView:getContentSize().height-9*row))

	if row > 1 then
		y = y + 15 * row + 15 - 25
	end

	func(btns[1],y,row)

	return node
end

function ShopLayer:createSuperWechatCode(info)
	return self:createSuperAlipayCode(info)
end

function ShopLayer:createSuperJd(info)
	return self:createSuperAlipay(info)
end

function ShopLayer:createSuperUnion(info)
	return self:createSuperAlipay(info)
end

function ShopLayer:createSuperAlipay(info)
	local size = self.layout:getContentSize()
	local base = "shop/"..info.payType.."/"

	local node = cc.Node:create()
	self.layout:addChild(node)

	-- local image = ccui.ImageView:create("shop/moneyBg.png")
	-- image:setPosition(size.width/2,size.height*0.5)
	-- image:setScale9Enabled(true)
	-- image:setContentSize(cc.size(size.width+20,size.height+20))
	-- image:setOpacity(0)
	-- node:addChild(image)

	-- size = image:getContentSize()
	local listView1 = ccui.ListView:create()
	local layout1 = ccui.Layout:create()

	local bg = ccui.ImageView:create("shop/btnBg.png")
	bg:setPosition(size.width/2,size.height-15)
	bg:setAnchorPoint(0.5,1)
	bg:setScale9Enabled(true)
	node:addChild(bg)

	local btns = {}

	local width = 0

	local func = function(sender,y,row)
		listView1:setTouchEnabled(false)
		for k,v in pairs(btns) do
			v:setEnabled(v~=sender)
			if v~=sender then
				v:setTitleColor(cc.c3b(255,255,255))
				v:setTouchEnabled(false)
			else
				v:setTitleColor(cc.c3b(255,248,201))
			end
		end

		local info1 = sender.data

		layout1:removeChildByName("mnode",true)

		local width1 = 0
		if info1.payType == PayType.alipaySweepCode or info1.payType == PayType.wechatSweepCode or info1.payType == PayType.unionSweepCode or info1.payType == PayType.jdSweepCode or info1.payType == PayType.qqSweepCode or info1.payType == PayType.suningSweetCode or info1.payType == PayType.cloudSweetCode then
			width1 = self:createQr(layout1,info1,listView1,size,y)
		else
			local ret = true
			if info1.payType == PayType.aliNative and checkVersion("1.0.1") ~= 2 then
				ret = false
			end

			if ret == true then
				width1 = self:createZhifubao(layout1,info1,listView1,size,y)
			end
		end

		if width1 == nil then
			listView1:setTouchEnabled(true)

			for k,v in pairs(btns) do
				v:stopAllActions()
				v.isclick = nil
				v:setScale(1)

				if v~=sender then
					v:setTouchEnabled(true)
				end
			end

			return
		end

		local chazhi = width+width1 - size.height

		local items = listView1:getItems()
		local h = 0
		if #items > 1 then
			h = items[#items]:getContentSize().height
			listView1:removeLastItem()
		end

		if chazhi < h then
			local lay = ccui.Layout:create()
			lay:setContentSize(cc.size(size.width,h))
			listView1:pushBackCustomItem(lay)
		else
			local lay = ccui.Layout:create()
			lay:setContentSize(cc.size(size.width,chazhi))
			listView1:pushBackCustomItem(lay)
		end

		listView1:setTouchEnabled(true)

		for k,v in pairs(btns) do
			v:stopAllActions()
			v.isclick = nil
			v:setScale(1)

			if v~=sender then
				v:setTouchEnabled(true)
			end
		end
	end

	-- 创建列表
	local x = 30
	local y = size.height * 0.94

	x = 0
	y = size.height - 15

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,1))
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setScrollBarEnabled(false)
	listView:setPosition(size.width/2,y)
	node:addChild(listView)
	listView:setTouchEnabled(false)
	listView.oldY = listView:getPositionY()

	local column = 4
	local row = math.ceil(#info.payCont/column)
	local height = -1
	local k = 1
	local y0 = 0

	for i=1,row do
		local layout = ccui.Layout:create()
		layout:setLocalZOrder(row-i+1)

		for j=1,column do
			local v = info.payCont[k]
			if v == nil then
				break
			end

			local ret = true
			if v.payType == PayType.aliNative and checkVersion("1.0.1") ~= 2 then
				ret = false
			end

			if ret == true then
				local btn = ccui.Button:create("shop/1.png","shop/1-on.png","shop/1-dis.png")

				if height == -1 then
					height = btn:getContentSize().height
					listView:setContentSize(cc.size(btn:getContentSize().width * column - x,height * row))

					d = (listView:getContentSize().width - btn:getContentSize().width * column)/(column+1)
					x = d
					y0 = height/2
				end

				btn:setPosition(x,y0)
				btn:setAnchorPoint(0,0.5)
				layout:addChild(btn)
				x = x + btn:getContentSize().width + d

				if i > 1 then
					btn:setPositionY(btn:getPositionY()+9*(i-1))
				end

				v.pType = info.payType
				btn:setTitleText(v.title)
				btn:setTitleFontSize(30)
				btn:setTitleFontName(FontConfig.gFontFile)
				btn:onClick(function(sender) func(sender,y,row) end)
				btn:setTitleColor(cc.c3b(253,242,197))
				btn.data = v
				btn:setSwallowTouches(false)

				local value = v.discount

				if type(value) == "number" then
					value = "优惠"..v.discount.."%"
				end

				if v.discount and not isEmptyString(value) then
					local discount = ccui.ImageView:create("shop/tiao1.png")
					discount:setPosition(btn:getContentSize().width*0.87,btn:getContentSize().height*0.8)
					btn:addChild(discount)
					btn:setScale(0.8)
					btn.discount = discount

					local text = FontConfig.createWithSystemFont(value, 18)
					text:setPosition(discount:getContentSize().width/2,discount:getContentSize().height/2)
					text:setColor(FontConfig.colorYellow)
					text:setDimensions(50,0)
					discount:addChild(text)
				end

				table.insert(btns,btn)
			end
			k = k + 1
		end

		x = d

		layout:setContentSize(cc.size(listView:getContentSize().width,height))
		layout:setPosition(size.width/2,y - layout:getContentSize().height*(i-1))
		layout:setAnchorPoint(0.5,1)
		node:addChild(layout)
	end

	y = y - listView:getContentSize().height
	local height = size.height-listView:getContentSize().height-15

	if row > 1 then
		y = y +  9 * row + 9 - 10
		height = height +  9 * row + 9 - 10
	end

	listView1:setAnchorPoint(cc.p(0.5,1))
	listView1:setDirection(ccui.ScrollViewDir.vertical)
	listView1:setBounceEnabled(true)
	listView1:setScrollBarEnabled(false)
	listView1:setContentSize(cc.size(size.width,height))
	listView1:setPosition(size.width/2,y)
	node:addChild(listView1)

	layout1:setContentSize(listView1:getContentSize())
	listView1:pushBackCustomItem(layout1)

	size = layout1:getContentSize()
	y = size.height - 9
	listView:setTouchEnabled(false)
	bg:setContentSize(cc.size(bg:getContentSize().width,listView:getContentSize().height-9*row))

	width = math.abs(y - size.height)

	func(btns[1],y,row)

	return node
end

function ShopLayer:createQr(layout1,info1,listView1,size,y)
	local mnode = cc.Node:create()
	mnode:setName("mnode")
	layout1:addChild(mnode)
	mnode.oldY = mnode:getPositionY()

	local width1 = 0
	local str = "说明:充值时请直接转入此账号,为了您的财产安全,绑定后不可私自更改,如需修改,请联系客服。请输入正确的支付宝实名制名字,不然无法转入该账号。"

	if not isEmptyString(info1.payInfo) then
		str = info1.payInfo

		local text = FontConfig.createWithSystemFont(str, 26)
		text:setPosition(size.width/2,y)
		text:setAnchorPoint(0.5,1)
		text:setColor(cc.c3b(255,252,216))
		text:setScale(0.8)
		text:setDimensions(800,0)
		mnode:addChild(text)
		y = y - text:getContentSize().height - 15

		width1 = width1 + text:getContentSize().height + 15
	else
		y = y - 15

		width1 = width1 + 15
	end

	local line = ccui.ImageView:create("shop/line.png")
	line:setScaleY(1.2)
	line:setPosition(size.width/2, y-line:getContentSize().height/2*line:getScaleY())
	mnode:addChild(line)

	local input = ccui.ImageView:create("shop/input.png")
	input:setPosition(size.width*0.5-10,y - input:getContentSize().height*0.7)
	input:setOpacity(0)
	mnode:addChild(input)

	local chongzhi = ccui.ImageView:create("shop/dingdan.png")
	chongzhi:setPosition(input:getContentSize().width*0.63,input:getContentSize().height)
	chongzhi:setAnchorPoint(0,0.5)
	input:addChild(chongzhi)

	local text = "输入存款姓名"
	if info1.payType == PayType.unionSweepCode then
		path = "shop/cunkuanxingming.png"
	elseif info1.payType == PayType.alipaySweepCode then
		path = "shop/cunkuanxingming.png"
		-- text = "输入支付宝姓名"
	elseif info1.payType == PayType.wechatSweepCode then
		path = "shop/cunkuanxingming.png"
		-- text = "输入微信姓名"
	end

	local chongzhi = ccui.ImageView:create(path)
	chongzhi:setPosition(input:getContentSize().width*0.92,input:getContentSize().height*0)
	chongzhi:setAnchorPoint(1,0.5)
	input:addChild(chongzhi)

	local moneyEditText = createEditBox(chongzhi,text,cc.EDITBOX_INPUT_MODE_SINGLELINE,1,cc.size(252,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
	-- moneyEditText:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
	moneyEditText:setMaxLength(20)

	local chongzhi = ccui.ImageView:create("shop/cunkuanjine.png")
	chongzhi:setPosition(input:getContentSize().width*0.92,-input:getContentSize().height*1.25)
	chongzhi:setAnchorPoint(1,0.5)
	input:addChild(chongzhi)

	local moneyEditText1 = createEditBox(chongzhi,"输入存款金额",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(252,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
	moneyEditText1:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
	moneyEditText1:setSwallowTouches(false)

	local chongzhi = ccui.ImageView:create("shop/yinhangkahou.png")
	chongzhi:setPosition(input:getContentSize().width*0.92,-input:getContentSize().height*2.5)
	chongzhi:setAnchorPoint(1,0.5)
	input:addChild(chongzhi)

	local moneyEditText2 = nil

	if info1.payType == PayType.unionSweepCode then
		moneyEditText2 = createEditBox(chongzhi,"请输入卡号后6位",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(252,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
		moneyEditText2:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
		moneyEditText2:setMaxLength(6)
	elseif info1.payType == PayType.alipaySweepCode or info1.payType == PayType.wechatSweepCode then
		-- chongzhi:loadTexture("shop/cunkuanshijian.png")
		-- moneyEditText2 = createEditBox(chongzhi,os.date("%Y-%m-%d-%H:%M:%S"),cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(252,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
		-- moneyEditText2:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
		-- moneyEditText2:setTouchEnabled(false)
		-- moneyEditText2:setText(os.date("%Y-%m-%d-%H:%M:%S"))
		chongzhi:loadTexture("shop/dingdanhao.png")
		moneyEditText2 = createEditBox(chongzhi,"输入订单号后6位",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(252,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
		moneyEditText2:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
		moneyEditText2:setSwallowTouches(false)
		moneyEditText2:setMaxLength(6)
	else
		chongzhi:loadTexture("shop/dingdanhao.png")
		moneyEditText2 = createEditBox(chongzhi,"输入订单号",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(252,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
		moneyEditText2:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
		moneyEditText2:setSwallowTouches(false)
		moneyEditText2:setMaxLength(6)
	end
	moneyEditText2:setSwallowTouches(false)

	local path = info1.imageName

	if isEmptyString(path) and not isEmptyString(info1.codeUrl) then
		local ts = string.reverse(info1.codeUrl)
		local i,j = string.find(ts,"/",1,true)
		local m = string.len(ts)-i+1
		path = string.sub(info1.codeUrl,m+1)
	end

	local qr
	if not isEmptyString(path) then
		local fullPath = cc.FileUtils:getInstance():getWritablePath().."qr/"..tostring(path)
		luaPrint("pay 二维码路径 ",fullPath)

		if not isEmptyString(path) then
			if cc.FileUtils:getInstance():isFileExist(fullPath) and display.loadImage(fullPath) ~= nil then
				qrPng[fullPath] = true
			end

			qr = ccui.ImageView:create(fullPath)
			qr:setPosition(120,y-20)--- math.abs(y/2-qrWidth/2))
			qr:setAnchorPoint(0,1)
			mnode:addChild(qr)

			if qrPng[fullPath] ~= true then
				createDir("qr")
				if not isEmptyString(info1.codeUrl) then
					local url = info1.codeUrl..path
					if isEmptyString(info1.imageName) then
						url = info1.codeUrl
					end
					luaPrint("请求二维码路径 ",url)

					HttpUtils:downLoadFile(url,
					fullPath,
					function(result, savePath, response) downQrCallback(qr,fullPath, result, savePath, response) end)
				end
			else
				local s = qr:getContentSize()
				qr:setScaleX(qrWidth/s.width)
				qr:setScaleY(qrWidth/s.height)
			end
		else
			qr = ccui.ImageView:create()
			qr:setPosition(120,y-20)
			qr:setAnchorPoint(0,1)
			mnode:addChild(qr)
		end

		qr:setLocalZOrder(1)
		local btn = ccui.Button:create("shop/qrBg.png","shop/qrBg.png")
		btn:setScale(qrWidth/btn:getContentSize().width+0.1)
		btn:setPosition(qr:getPositionX()+qrWidth/2,qr:getPositionY()-qrWidth/2)
		mnode:addChild(btn)
		btn:onClick(function(sender)
			if qrPng[fullPath] then
				saveSystemPhoto(fullPath)
			else
				addScrollMessage("正在下载二维码")
			end
		end)

		local text = FontConfig.createWithSystemFont("点击二维码保存到手机", 26)
		text:setPosition(qr:getPositionX()+qrWidth/2,qr:getPositionY()-qrWidth-10)
		text:setAnchorPoint(0.5,1)
		text:setColor(cc.c3b(254,246,196))
		text:setScale(0.7)
		mnode:addChild(text)
	end

	local path = ""

	if info1.payType == PayType.unionSweepCode then
		path = "shop/yhkxingming.png"
	elseif info1.payType == PayType.alipaySweepCode then
		path = "shop/zfbxingming.png"
	elseif info1.payType == PayType.wechatSweepCode then
		path = "shop/weixinshoujihao.png"
	end

	local y1 = -input:getContentSize().height*2.5

	if not qr then
		y1 = input:getContentSize().height*0.5
	end

	path = "shop/yhkxingming.png"

	if not isEmptyString(path) then
		local chongzhi = ccui.ImageView:create(path)
		chongzhi:setPosition(-input:getContentSize().width*0.25,y1)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		local text = FontConfig.createWithSystemFont(info1.cardName, 22)
		text:setPosition(chongzhi:getContentSize().width+10,chongzhi:getContentSize().height/2)
		text:setAnchorPoint(0,0.5)
		text:setColor(cc.c3b(254,246,196))
		chongzhi:addChild(text)

		local btn = ccui.Button:create("shop/fuzhi1.png","shop/fuzhi1-on.png")
		btn:onClick(function(sender) if copyToClipBoard(info1.cardName) then addScrollMessage("复制成功") end end)
		btn:setPosition(input:getContentSize().width*0.3,chongzhi:getPositionY()-chongzhi:getContentSize().height/2-10)
		btn:setAnchorPoint(0.5,1)
		btn:setScale(1.2)
		input:addChild(btn)

		y1 = y1 - chongzhi:getContentSize().height/2 - btn:getContentSize().height - 50
	end

	path = ""
	if info1.payType == PayType.alipaySweepCode then
		path = "shop/zfbzhanghao.png"
	elseif info1.payType == PayType.unionSweepCode then
		path = "shop/yhkkahao.png"
	end

	path = "shop/yhkkahao.png"

	if not isEmptyString(path) then
		local chongzhi = ccui.ImageView:create(path)
		chongzhi:setPosition(-input:getContentSize().width*0.25,y1)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		local text = FontConfig.createWithSystemFont(info1.cardNumber, 22)
		text:setPosition(chongzhi:getContentSize().width+10,chongzhi:getContentSize().height/2)
		text:setAnchorPoint(0,0.5)
		text:setColor(cc.c3b(254,246,196))
		chongzhi:addChild(text)

		local btn = ccui.Button:create("shop/fuzhi1.png","shop/fuzhi1-on.png")
		btn:onClick(function(sender) if copyToClipBoard(info1.cardNumber) then addScrollMessage("复制成功") end end)
		btn:setPosition(input:getContentSize().width*0.3,chongzhi:getPositionY()-chongzhi:getContentSize().height/2-10)
		btn:setAnchorPoint(0.5,1)
		btn:setScale(1.2)
		input:addChild(btn)

		y1 = y1 - chongzhi:getContentSize().height/2 - btn:getContentSize().height - 50
	end

	path = ""
	if info1.payType == PayType.unionSweepCode then
		path = "shop/yinhangmingcheng.png"
	end

	path = "shop/yinhangmingcheng.png"

	if not isEmptyString(path) then
		local chongzhi = ccui.ImageView:create(path)
		chongzhi:setPosition(-input:getContentSize().width*0.25,y1)
		chongzhi:setAnchorPoint(1,0.5)
		input:addChild(chongzhi)

		local text = FontConfig.createWithSystemFont(info1.bankName, 22)
		text:setPosition(chongzhi:getContentSize().width+10,chongzhi:getContentSize().height/2)
		text:setAnchorPoint(0,0.5)
		text:setColor(cc.c3b(254,246,196))
		chongzhi:addChild(text)

		local btn = ccui.Button:create("shop/fuzhi1.png","shop/fuzhi1-on.png")
		btn:onClick(function(sender) if copyToClipBoard(info1.bankName) then addScrollMessage("复制成功") end end)
		btn:setPosition(input:getContentSize().width*0.3,chongzhi:getPositionY()-chongzhi:getContentSize().height/2-10)
		btn:setAnchorPoint(0.5,1)
		btn:setScale(1.2)
		input:addChild(btn)
	end

	local btn = ccui.Button:create("shop/tijiaodingdan.png","shop/tijiaodingdan-on.png")
	btn:setPosition(size.width*0.75,y - line:getContentSize().height*line:getScaleY()*0.92)
	btn:setAnchorPoint(0.5,0)
	mnode:addChild(btn)
	btn:setSwallowTouches(false)
	btn:onClick(function(sender)
		local name = moneyEditText:getText();

		if isEmptyString(name) then
			local text = "请输入您的存款姓名"
			if info1.payType == PayType.unionSweepCode then
			elseif info1.payType == PayType.alipaySweepCode then
				text = "请输入您的支付宝姓名"
			elseif info1.payType == PayType.wechatSweepCode then
				text = "请输入您的微信姓名"
			end
			addScrollMessage(text)
			return
		end

		-- if isEmoji(name) or not stringIsHaveChinese(name,1) then
		-- 	addScrollMessage("您输入的存款姓名包含非汉字如空格等")
		-- 	return
		-- end

		local money = moneyEditText1:getText()

		if isEmptyString(money) then
			addScrollMessage("请输入您的存款金额")
			return
		end

		local ret = checkNumber(money)

		if not ret then
			addScrollMessage("存款金额必须是数字")
			return
		end

		local card = 0
		local tm = 0

		if info1.payType == PayType.unionSweepCode then
			card = moneyEditText2:getText()

			if isEmptyString(card) then
				addScrollMessage("请输入银行卡号后6位")
				return
			end

			local ret = checkNumber(card)

			if not ret then
				addScrollMessage("银行卡号后6位必须是数字")
				return
			end

			tm = card
		elseif info1.payType == alipaySweepCode or info1.payType == wechatSweepCode then
			tm = moneyEditText2:getText()

			local ret = checkNumber(tm)

			if not ret then
				addScrollMessage("存款时间必须是数字")
				return
			end
		else
			tm = moneyEditText2:getText()

			if isEmptyString(tm) then
				addScrollMessage("请输入您的订单号")
				return
			end

			local ret = checkNumber(tm)

			if not ret then
				addScrollMessage("订单号必须是数字")
				return
			end
		end

		local url = info1.url.."?action=addorder4&userid="..PlatformLogic.loginResult.dwUserID.."&AccountName="..string.urlencode(name).."&RechargeTime="..tm.."&type="..info1.type.."&paywayid="..info1.paywayid.."&money="..money.."&timestamp="..os.time().."000".."&paytypeid="..info1.id
		local func = function(result, response)
			if result == true then
				local re = json.decode(response)
				addScrollMessage(re.Msg)
			else
				addScrollMessage("网络不好，请稍后重试")
			end
		end

		if not isEmptyString(info1.domain) then
			url = string.gsub(url,info1.domain,GameConfig.tuiguanUrl)
		end

		HttpUtils:requestHttp(url, func, "POST")
	end)

	width1 = width1 + line:getContentSize().height*line:getScaleY() + 20

	return width1
end

function ShopLayer:createZhifubao(layout1,info1,listView1,size,y)
	local mnode = cc.Node:create()
	mnode:setName("mnode")
	layout1:addChild(mnode)
	mnode.oldY = mnode:getPositionY()

	local width1 = 0

	local str = "说明:充值时请直接转入此账号,为了您的财产安全,绑定后不可私自更改,如需修改,请联系客服。请输入正确的支付宝实名制名字,不然无法转入该账号。"

	if not isEmptyString(info1.payInfo) then
		str = info1.payInfo

		local text = FontConfig.createWithSystemFont(str, 26)
		text:setPosition(size.width/2,y)
		text:setAnchorPoint(0.5,1)
		text:setColor(cc.c3b(255,252,216))
		text:setScale(0.8)
		text:setDimensions(800,0)
		mnode:addChild(text)
		y = y - text:getContentSize().height - 15

		width1 = width1 + text:getContentSize().height + 15
	else
		y = y - 15

		width1 = width1 + 15
	end

	local input = ccui.ImageView:create("shop/input.png")
	input:setPosition(size.width*0.55-4,y)
	input:setAnchorPoint(0.5,1)
	input:setOpacity(0)
	mnode:addChild(input)

	local chongzhi = ccui.ImageView:create("shop/chongzhijine.png")
	chongzhi:setPosition(-80,input:getContentSize().height*0.5)
	chongzhi:setAnchorPoint(1,0.5)
	input:addChild(chongzhi)

	local moneyEditText = createEditBox(chongzhi,"请输入充值金额(最低"..tostring(info1.minMoney).."元,最高"..tostring(info1.maxMoney).."元)",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(400,input:getContentSize().height),"shop/input.png",FontConfig.colorWhite)
	moneyEditText:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
	moneyEditText:setMaxLength(string.len(tostring(info1.maxMoney)))
	-- moneyEditText:setFontSize(20)

	local btn = ccui.Button:create("shop/likechongzhi.png","shop/likechongzhi-on.png")
	btn:setAnchorPoint(0,0.5)
	btn:setPosition(input:getContentSize().width+15,input:getContentSize().height/2)
	input:addChild(btn)
	btn:onClick(function(sender)
		local money = moneyEditText:getText()
		if isEmptyString(money) then
			if info1.isInputMoney == 0 then
				addScrollMessage("请选择充值金额")
			else
				addScrollMessage("请输入充值金额")
			end
			return
		end

		money = tonumber(money)

		if info1.isInputMoney == 0 then
			if info1.realMoney and type(info1.realMoney) == "string" then
				info1.realMoney = string.split(info1.realMoney,"_")
				for ka,va in pairs(info1.realMoney) do
					va = tonumber(va)
				end
			end

			local flag1 = false

			if info1.realMoney then
				for k,v in pairs(info1.realMoney) do
					if tonumber(v) == money then
						flag1 = true
						break
					end
				end
			else
				flag1 = true
			end

			if not flag1 then
				addScrollMessage("当前充值金额无有效通道")
				return
			end
		else
			if money < info1.minMoney or money > info1.maxMoney then
				addScrollMessage("请输入正确金额，最低"..info1.minMoney.."元,最高"..info1.maxMoney.."元")
				return
			end

			if info1.checkMoney and type(info1.checkMoney) == "string" then
				local m = string.split(info1.checkMoney,"|")
				local t = {}
				local flag = false
				if not isEmptyTable(m) then
					for kkk,vvv in pairs(m) do
						local te = string.split(vvv,"_")
						te[1] = tonumber(te[1])
						te[2] = tonumber(te[2])
						table.insert(t,te)
						if te[1] and te[2] then
							flag = true
						end
					end
				end
				info1.checkMoney = clone(t)

				if not flag then
					info1.checkMoney = nil
				end
			end

			if info1.realMoney and type(info1.realMoney) == "string" then
				info1.realMoney = string.split(info1.realMoney,"_")
				local flag = false
				for ka,va in pairs(info1.realMoney) do
					info1.realMoney[ka] = tonumber(va)
					if info1.realMoney[ka] then
						flag = true
					end
				end

				if not flag then
					info1.realMoney = nil
				end
			end

			local flag1 = false

			if info1.realMoney then
				for k,v in pairs(info1.realMoney) do
					if tonumber(v) == money then
						flag1 = true
						break
					end
				end
			else
				flag1 = true
			end

			local flag2 = false
			if info1.checkMoney then
				local count = 0
				for k,v in pairs(info1.checkMoney) do
					if tonumber(v[1]) and tonumber(v[2]) and (money < tonumber(v[1]) or money > tonumber(v[2])) then
						count = count + 1
					end

					if not tonumber(v[1]) and not tonumber(v[2]) then
						count = count + 1
					end
				end

				flag2 = count ~= #info1.checkMoney
			else
				flag2 = true
			end

			if info1.realMoney and info1.checkMoney then
				if not flag1 and not flag2 then
					addScrollMessage("当前充值金额无有效通道")
					return
				end
			else
				if info1.realMoney or info1.checkMoney then
					if not flag1 or not flag2 then
						addScrollMessage("当前充值金额无有效通道")
						return
					end
				end
			end
		end

		local url = self.payConfig.url

		if not isEmptyString(info1.url) then
			url = info1.url
		end

		if not isEmptyString(info1.domain) then
			url = string.gsub(url,info1.domain,GameConfig.tuiguanUrl)
		end

		local param = "userid="..PlatformLogic.loginResult.dwUserID.."&total_fee="..money.."&paywayid="..tostring(info1.paywayid).."&paytypeid="..tostring(info1.id).."&timestamp="..os.time().."000"
		luaPrint(param)
		LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在拉起订单中..."), LOADING)
		local func = function(result, response)
			LoadingLayer:removeLoading()
			if result == true then
				try({
					function()
						local response1 = string.gsub(response,"\\","|")
						luaPrint(response1)
						response1 = unicode_to_utf8(response1)
						luaPrint(response1)
						local re = json.decode(response1)
						luaDump(re)
						if tonumber(re.code) == 200 then
							local newurl = ""
							if info1.payType == PayType.aliNative then
								newurl = string.gsub(string.urldecode(re.url),"|","\\")
								luaPrint("newurl ---",newurl)
								local subject = ""
								local body = ""
								local www = ""
								luaPrint("aliNative 参数",newurl,subject)
								alipayNative(newurl,subject)
							else
								newurl = string.gsub(re.url,"|","")
								openWeb(newurl)
							end
						else
							-- local msg = string.gsub(re.msg,"|","\\")
							-- addScrollMessage(unicode_to_utf8(msg))
							addScrollMessage("支付异常，请重试")
						end
					end,
					catch = function(error)
						addScrollMessage("支付返回异常")
						luaPrint(error)
						uploadInfo("支付异常数据",error)
					end
				})
			else
				addScrollMessage("网络不好，请稍后重试")
			end
		end

		HttpUtils:requestHttp(url, func, "POST",param)
	end)

	moneyEditText:setTouchEnabled(info1.isInputMoney ~= 0)
	moneyEditText:setSwallowTouches(false)

	if info1.isInputMoney == 0 then
		moneyEditText:setPlaceHolder("")
	end

	y = y - input:getContentSize().height - 20

	local str = ""

	if info1.isInputMoney == 0 then
		str = "当前充值方式不支持自定义金额"
	end

	-- str = str.."玩家最常用充值金额"

	local text = FontConfig.createWithSystemFont(str, 26, cc.c3b(255,248,201))
	text:setPosition(size.width/2,y)
	text:setAnchorPoint(0.5,1)
	text:setDimensions(800,0)
	mnode:addChild(text)

	y = y - text:getContentSize().height

	-- 创建代理信息
	local x = -1
	local y1 = 0
	local d = 0
	local count = 4
	local x0 = 0

	if isEmptyString(info1.payMoney) then
		return
	end

	local payMoney = string.split(info1.payMoney,"_")

	if isEmptyTable(payMoney) then
		return
	end

	y = y - 30

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,1))
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setScrollBarEnabled(false)
	listView:setPosition(size.width/2,y)
	mnode:addChild(listView)

	local r = math.ceil(#payMoney/count)

	for i=1,r do
		local layout = ccui.Layout:create()
		for j=1,count do
			local v = payMoney[(i-1)*count+j]

			if v == nil then
				break
			end

			local daili = ccui.Button:create("shop/jine.png","shop/jine-on.png")
			daili:setTag(tonumber(v))
			daili:setSwallowTouches(false)
			layout:setContentSize(size.width-10,daili:getContentSize().height)

			if x == -1 then
				d = (layout:getContentSize().width - daili:getContentSize().width * count)/(count+1)
				x0 = d + daili:getContentSize().width/2
				x = x0

				listView:setContentSize(cc.size(size.width-10, daili:getContentSize().height*r))

				width1 = width1 + input:getPositionY() - listView:getPositionY() + listView:getContentSize().height
			end

			daili:setPosition(x,daili:getContentSize().height/2)
			layout:addChild(daili)

			local text = FontConfig.createWithCharMap(v.."元","shop/jinerzitiao.png",23,39,"0",{{"元",":;"}})
			text:setPosition(daili:getContentSize().width/2,daili:getContentSize().height*0.5)
			daili:addChild(text)

			daili:onClick(function(sender) moneyEditText:setText(sender:getTag().."") end)

			x = x + d + daili:getContentSize().width
		end

		x = x0
		listView:pushBackCustomItem(layout)
	end

	listView:setTouchEnabled(false)

	return width1
end

function downQrCallback(qr, path, result, savePath, response)
	if result == true then
		if qr and not tolua.isnull(qr) then
			qrPng[path] = true
			qr:loadTexture(path)
			local s = qr:getContentSize()
			qr:setScaleX(qrWidth/s.width)
			qr:setScaleY(qrWidth/s.height)
		end
	end
end

function ShopLayer:createAlipay(info)
	local size = self.layout:getContentSize()
	local base = "shop/"..info.payType.."/"

	local node = cc.Node:create()
	self.layout:addChild(node)

	local image = ccui.ImageView:create(base.."info.png")
	image:setPosition(size.width/2,size.height+2)
	image:setAnchorPoint(0.5,1)
	node:addChild(image)

	-- local image = ccui.ImageView:create("shop/moneyBg.png")
	-- image:setPosition(size.width/2,size.height/2)
	-- image:setOpacity(0)
	-- node:addChild(image)

	-- local gang = ccui.ImageView:create("shop/liantiao.png")
	-- gang:setPosition(40,image:getContentSize().height)
	-- image:addChild(gang)

	-- local gang = ccui.ImageView:create("shop/liantiao.png")
	-- gang:setPosition(image:getContentSize().width-40,image:getContentSize().height)
	-- image:addChild(gang)

	-- size = image:getContentSize()

	local input = ccui.ImageView:create("shop/input.png")
	input:setPosition(size.width*0.5-30,size.height*0.65)
	node:addChild(input)
	input:setOpacity(0)

	local chongzhi = ccui.ImageView:create("shop/chongzhijine.png")
	chongzhi:setPosition(-20,input:getContentSize().height*0.5)
	chongzhi:setAnchorPoint(1,0.5)
	input:addChild(chongzhi)

	local moneyEditText = createEditBox(chongzhi,"请输入充值金额(最低"..info.minMoney.."元,最高"..info.maxMoney.."元)",cc.EDITBOX_INPUT_MODE_NUMERIC,1,cc.size(400,70),"shop/input.png",FontConfig.colorWhite)
	moneyEditText:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
	moneyEditText:setMaxLength(string.len(tostring(info.maxMoney)))

	local btn = ccui.Button:create("shop/likechongzhi.png","shop/likechongzhi-on.png")
	btn:setAnchorPoint(0,0.5)
	btn:setPosition(input:getContentSize().width+75,input:getContentSize().height/2)
	input:addChild(btn)
	btn:onClick(function(sender)
		local money = moneyEditText:getText()
		if isEmptyString(money) then
			addScrollMessage("请输入充值金额")
			return
		end

		money = tonumber(money)

		if money < info.minMoney or money > info.maxMoney then
			addScrollMessage("请输入正确金额，最低"..info.minMoney.."元,最高"..info.maxMoney.."元=")
			return
		end

		local url = self.payConfig.url

		if not isEmptyString(info.url) then
			url = info.url
		end

		url = url.."?userid="..PlatformLogic.loginResult.dwUserID.."&total_fee="..money.."&ID="..info.id

		if not isEmptyString(info.domain) then
			url = string.gsub(url,info.domain,GameConfig.tuiguanUrl)
		end

		openWeb(url)
	end)

	local str = ""

	if info.isInputMoney == 0 then
		str = "当前充值是固定金额，禁止输入\n"
	end

	str = str.."玩家最常用充值金额"

	if not isEmptyString(info.payInfo) then
		str = info.payInfo
	end

	moneyEditText:setTouchEnabled(info.isInputMoney ~= 0)
	moneyEditText:setSwallowTouches(false)

	local text = FontConfig.createWithSystemFont(str, 26, cc.c3b(255,248,201))
	text:setPosition(size.width/2,size.height*0.55)
	text:setAnchorPoint(0.5,1)
	text:setDimensions(800,0)
	node:addChild(text)

	-- 创建代理信息
	local x = -1
	local y = 0
	local d = 0
	local count = 4
	local x0 = 0

	local payMoney = string.split(info.payMoney,"_")

	if isEmptyTable(payMoney) then
		return node
	end

	-- if #payMoney > 6 then
		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0.5,1))
		listView:setDirection(ccui.ScrollViewDir.vertical)
		listView:setBounceEnabled(true)
		listView:setScrollBarEnabled(false)
		node:addChild(listView)

		for i=1,math.ceil(#payMoney/count) do
			local layout = ccui.Layout:create()
			for j=1,count do
				local v = payMoney[(i-1)*count+j]

				if v == nil then
					break
				end

				local daili = ccui.Button:create("shop/jine.png","shop/jine-on.png")
				daili:setTag(tonumber(v))
				layout:setContentSize(size.width-10,daili:getContentSize().height)

				if x == -1 then
					d = (layout:getContentSize().width - daili:getContentSize().width * count)/(count+1)
					x0 = d + daili:getContentSize().width/2
					y = text:getPositionY() - text:getContentSize().height - 10 - 5
					x = x0

					if info.isInputMoney == 0 then
						listView:setContentSize(cc.size(size.width-10, daili:getContentSize().height*3-15))
					else
						listView:setContentSize(cc.size(size.width-10, daili:getContentSize().height*3))
						if #payMoney <= 9 then
							listView:setTouchEnabled(false)
						end
					end
					listView:setPosition(size.width/2,y)
				end

				daili:setPosition(x,daili:getContentSize().height/2)
				layout:addChild(daili)

				local text = FontConfig.createWithCharMap(v.."元","shop/jinerzitiao.png",23,39,"0",{{"元",":;"}})
				text:setPosition(daili:getContentSize().width/2,daili:getContentSize().height*0.5)
				daili:addChild(text)

				daili:onClick(function(sender) moneyEditText:setText(sender:getTag().."") end)

				x = x + d + daili:getContentSize().width
			end

			x = x0
			listView:pushBackCustomItem(layout)
		end
	-- else
	-- 	for k,v in pairs(payMoney) do
	-- 		local daili = ccui.Button:create("shop/jine.png","shop/jine-on.png")
	-- 		daili:setTag(tonumber(v))

	-- 		if x == -1 then
	-- 			d = (size.width - daili:getContentSize().width * count)/(count+1)
	-- 			x0 = d + daili:getContentSize().width/2
	-- 			y = text:getPositionY() - text:getContentSize().height - 10
	-- 			x = x0
	-- 		end

	-- 		daili:setAnchorPoint(0.5,1)
	-- 		daili:setPosition(x,y)
	-- 		image:addChild(daili)

	-- 		local text = FontConfig.createWithCharMap(v.."元","shop/jinerzitiao.png",23,39,"0",{{"元",":;"}})
	-- 		text:setPosition(daili:getContentSize().width/2,daili:getContentSize().height*0.5)
	-- 		daili:addChild(text)

	-- 		daili:onClick(function(sender) moneyEditText:setText(sender:getTag().."") end)

	-- 		x = x + d + daili:getContentSize().width
	-- 		if k % 3 == 0 then
	-- 			y = y - daili:getContentSize().height - 10
	-- 			x = x0
	-- 		end
	-- 	end
	-- end

	return node
end

function ShopLayer:createQuickPass(info)
	local size = self.layout:getContentSize()
	local base = "shop/"..info.payType.."/"

	local node = cc.Node:create()
	self.layout:addChild(node)

	-- local image = ccui.ImageView:create("shop/moneyBg.png")
	-- image:setPosition(size.width/2,size.height*0.5)
	-- image:setScale9Enabled(true)
	-- image:setContentSize(cc.size(size.width+20,size.height+20))
	-- image:setOpacity(0)
	-- node:addChild(image)

	-- size = image:getContentSize()

	local pass = ccui.ImageView:create(base.."shanfu.png")
	pass:setPosition(size.width/2,size.height*0.85)
	node:addChild(pass)

	local text = FontConfig.createWithSystemFont("专属服务秒到账，充值不等候", 26, cc.c3b(255,248,201))
	text:setPosition(size.width/2,size.height*0.7)
	node:addChild(text)

	local btn = ccui.Button:create(base.."zhifubao.png",base.."zhifubao.png",base.."zhifubao.png")
	btn:setPosition(size.width*0.25,size.height/2)
	node:addChild(btn)
	btn:onClick(function(sender) openWeb(info.alipayUrl) end)

	local btn = ccui.Button:create(base.."weixin.png",base.."weixin.png",base.."weixin.png")
	btn:setPosition(size.width*0.5,size.height/2)
	node:addChild(btn)
	btn:onClick(function(sender) openWeb(info.wechatUrl) end)

	local btn = ccui.Button:create(base.."yinlian.png",base.."yinlian.png",base.."yinlian.png")
	btn:setPosition(size.width*0.75,size.height/2)
	node:addChild(btn)
	btn:onClick(function(sender) openWeb(info.unionUrl) end)

	local text = FontConfig.createWithSystemFont("官网闪付信息\n请选择常用的支付方式，为您匹配秒充专员", 26, cc.c3b(255,248,201))
	text:setPosition(size.width/2,size.height*0.25)
	node:addChild(text)

	return node
end

function ShopLayer:createZunxiang(info)
	local size = self.layout:getContentSize()
	local base = "shop/"..info.payType.."/"

	local node = cc.Node:create()
	self.layout:addChild(node)

	local image = ccui.ImageView:create("shop/moneyBg.png")
	image:setPosition(size.width/2,size.height*0.5)
	-- image:setScale9Enabled(true)
	-- image:setContentSize(cc.size(size.width+20,size.height+20))
	image:setOpacity(0)
	node:addChild(image)

	size = image:getContentSize()

	local text = FontConfig.createWithSystemFont(info.payInfo, 26, cc.c3b(255,248,201))
	text:setPosition(size.width/2,size.height*0.7)
	text:setDimensions(800,0)
	image:addChild(text)

	local btn = ccui.Button:create("shop/likechongzhi.png","shop/likechongzhi-on.png")
	btn:setPosition(size.width*0.5,size.height*0.2)
	image:addChild(btn)
	btn:onClick(function(sender) openService() end)

	return node
end

function ShopLayer:onMoneyEditBoxHandler(event)
	local name = event.name

	if name == "began" then
		--todo
	elseif name == "ended" then
		checkNumber(event.target:getText(),event.target)
	elseif name == "return" then
		checkNumber(event.target:getText(),event.target)
	elseif name == "changed" then
		checkNumber(event.target:getText(),event.target)
	end
end

function ShopLayer:onClickClose(sender)
	dispatchEvent("registerLayerUpCallBack");
	self:delayCloseLayer()
end

return ShopLayer
