local UserInfoNode = class("UserInfoNode",BaseNode)

function UserInfoNode:ctor(bankEnabled)
	self.super.ctor(self)

	self.bankEnabled = bankEnabled

	self:bindEvent()

	self:initUI()
end

function UserInfoNode:bindEvent()
	self:pushGlobalEventInfo("ASS_ZTW_SCORE",handler(self, self.receiveZtwScore))
	self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.receiveRefreshScoreBank))
	self:pushEventInfo(SettlementInfo, "configInfo", handler(self, self.receiveConfigInfo))
end

function UserInfoNode:initUI()
	local gold = ccui.ImageView:create("hall/gold.png")
	self:addChild(gold)
	gold:setPosition(-20,-10)

	local size = gold:getContentSize()

	local goldText = FontConfig.createWithCharMap(goldConvert(PlatformLogic.loginResult.i64Money),"hall/goldNum.png",16,29,"+")
	goldText:setPosition(size.width/4,size.height/2-5 + 7)
	goldText:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	goldText:setAnchorPoint(0,0.5)
	gold:addChild(goldText)
	self.goldText = goldText

	-- goldText:setPositionX(goldText:getPositionX()-goldText:getContentSize().width/2)

	local bank = ccui.Button:create("hall/bank.png","hall/bank-on.png")
	bank:setAnchorPoint(0,0.5)
	bank:setPosition(size.width/2,-8)
	self:addChild(bank)
	bank:onClick(handler(self, self.onClickBtn))
	bank:setTouchEnabled(self.bankEnabled ~= false)

	if globalUnit.isEnterGame == true then
		bank:setTouchEnabled(false)
	end

	local bankText = FontConfig.createWithCharMap(goldConvert(PlatformLogic.loginResult.i64Bank),"hall/goldNum.png",16,29,"+")
	bankText:setPosition(size.width/4-5,size.height/2+5)
	bankText:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	bankText:setAnchorPoint(0,0.5)
	bank:addChild(bankText)
	self.bankText = bankText

	if globalUnit.isYuEbao == true then
		self.bankText:setText(goldConvertFour(PlatformLogic.loginResult.i64Bank,2))
	else
		self.bankText:setText(goldConvert(PlatformLogic.loginResult.i64Bank))
	end

	-- bankText:setPositionX(bankText:getPositionX()-bankText:getContentSize().width/2)

	self.oldPosX = size.width/2+10
end

function UserInfoNode:onClickBtn(sender)
	-- createShop()
	if globalUnit.isYuEbao == true then
		self:showYuEBao()
	else
		self:showBankBox()
	end
end

function UserInfoNode:receiveRefreshScoreBank(data)
	local data = data._usedata

	if data then
		self.goldText:setText(goldConvert(data.i64WalletMoney))
		if globalUnit.isYuEbao == true then
			self.bankText:setText(goldConvertFour(data.i64BankMoney,2))
		else
			self.bankText:setText(goldConvert(data.i64BankMoney))
		end

		-- self.goldText:setPositionX(self.oldPosX-self.goldText:getContentSize().width/2)
		-- self.bankText:setPositionX(self.oldPosX-self.bankText:getContentSize().width/2)
	end
end

function UserInfoNode:receiveZtwScore(data)
	local data = data._usedata

	if data and PlatformLogic.loginResult.dwUserID == data.UserID then
		self.goldText:setText(goldConvert(data.i64WalletMoney))
		PlatformLogic.loginResult.i64Money = data.i64WalletMoney
		-- self.goldText:setPositionX(self.oldPosX-self.goldText:getContentSize().width/2)
	end
end

--余额宝
function UserInfoNode:showYuEBao()
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
function UserInfoNode:showBankBox()
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

function UserInfoNode:receiveConfigInfo(data)
	local data = data._usedata

	if data.id == 11 then
		if globalUnit.isYuEbao == true then
			self.bankText:setText(goldConvertFour(PlatformLogic.loginResult.i64Bank,2))
		else
			self.bankText:setText(goldConvert(PlatformLogic.loginResult.i64Bank))
		end
	end
end

return UserInfoNode
