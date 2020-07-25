local BindPhoneLayer = class("BindPhoneLayer", PopLayer)

function BindPhoneLayer:ctor()
	playEffect("hall/sound/bindPhone.mp3")
	self.super.ctor(self,PopType.middle)

	self:initUI()

	self:bindEvent()
end

function BindPhoneLayer:bindEvent()
	self:pushGlobalEventInfo("accountUpSuccess",handler(self, self.receiveAccountUp))
	self:pushGlobalEventInfo("getCodeSuccess",handler(self, self.receiveGetCodeSuccess))
	self:pushGlobalEventInfo("accountUpFailed",handler(self, self.receiveAccountUpFailed))
end

function BindPhoneLayer:initUI()
	local title = ccui.ImageView:create("common/phoneTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local h = 90
	local y = self.size.height*0.65
	local x = self.size.width*0.35

	--手机号
	local mobile = ccui.ImageView:create("login/mobile.png")
	mobile:setAnchorPoint(1,0.5)
	mobile:setPosition(x,y)
	self.bg:addChild(mobile)

	self.phoneTextEdit = createEditBox(mobile,"请输入手机号",cc.EDITBOX_INPUT_MODE_PHONENUMBER,1)

	--验证码
	local mobileCode = ccui.ImageView:create("login/mobileCode.png")
	mobileCode:setAnchorPoint(1,0.5)
	mobileCode:setPosition(x,y-h)
	self.bg:addChild(mobileCode)

	self.codeTextEdit, editBg = createEditBox(mobileCode,"请输入验证码",cc.EDITBOX_INPUT_MODE_PHONENUMBER,1,cc.size(268,64))

	--获取验证码
	self.codeBtn = createPhoneCodeBtn(editBg,handler(self, self.sendPhoneCode))
	editBg = nil
end

function BindPhoneLayer:setRegisterCallback(callback)
	self.callback = callback
end

--发送手机验证码
function BindPhoneLayer:sendPhoneCode(sender)
	luaPrint("发送手机验证码")

	local phone = self.phoneTextEdit:getText()

	if isEmptyString(phone) then
		luaPrint("手机号为空")
		addScrollMessage("手机号为空")
		return false
	end

	if not checkPhoneNum(phone) then
		addScrollMessage("请输入正确的手机号")
		return false
	end

	sender:setTouchEnabled(false)

	self.phone = phone

	local url = GameConfig:getVerificationCodeUrl()
	local str = "userid="..PlatformLogic.loginResult.dwUserID.."&phone="..phone.."&type=1".."&AgentID="..channelID
	local rd,code,pcode = createCheckCode()

	str = str.."&rd="..rd.."&code="..code.."&pcode="..pcode

	HttpUtils:requestHttp(url, function(result, response) getCodeCallback(result, response); end, "POST", str);

	return true
end

function BindPhoneLayer:onClickSure(sender)
	local phone = self.phone

	if isEmptyString(phone) then
		phone = self.phoneTextEdit:getText()
	end

	if isEmptyString(phone) then
		luaPrint("手机号为空")
		addScrollMessage("手机号为空")
		return
	end

	if #phone ~= 11 then
		luaPrint("您输入的手机号有误，请重输")
		addScrollMessage("您输入的手机号有误，请重输")
		return
	end

	local code = self.codeTextEdit:getText()

	if isEmptyString(code) then
		luaPrint("验证码为空")
		addScrollMessage("验证码为空")
		return
	end

	local msg = {}
	msg.phone = phone
	msg.code = code
	msg.pwd = ""
	msg.answer = ""

	globalUnit.registerInfo.phone = msg.phone
	globalUnit.registerInfo.code = msg.code
	globalUnit.registerInfo.pwd = msg.pwd
	globalUnit.registerInfo.answer = msg.answer

	if self.callback then
		self.callback(msg)
	else
		dispatchEvent("bindPhone",msg)
	end
end

function BindPhoneLayer:onClickXieyi(sender)
	addScrollMessage("稍后实现")
end

function BindPhoneLayer:receiveAccountUp()
	local str = "绑定手机号成功"

	-- if SettlementInfo:getConfigInfoByID(6) > 0 then
	-- 	str = str..",并获得"..goldConvert(SettlementInfo:getConfigInfoByID(6),1).."金币！"
	-- end

	addScrollMessage(str)
	self:delayCloseLayer()

	if isShowSettlementLayer == true then
		isShowSettlementLayer = nil
		local layer = GameMessageLayer:create("common/wenxintishi.png","手机号绑定成功","hall/quduihuan")
		layer:setBtnClickCallBack(function()
			display.getRunningScene():addChild(require("layer.popView.SettlementLayer"):create())
		end)
		display.getRunningScene():addChild(layer)
	end
end

function BindPhoneLayer:receiveGetCodeSuccess(data)
	local data = data._usedata

	if data == false then
		self.codeBtn:setTouchEnabled(true)
		return
	end

	local sender = self.codeBtn
	sender:removeAllChildren()

	sender:setEnabled(false)
	sender:loadTextures("input/getNo.png","input/getNo-on.png")
	local tm = 60;
	local text = FontConfig.createWithCharMap(tm.."s","input/inputNum.png",20,29,"0",{{"s",":"}})
	text:setPosition(sender:getContentSize().width/2,sender:getContentSize().height/2)
	sender:addChild(text)
	text:setTag(tm)

	local fun = function() 
		local tag = text:getTag()

		tag = tag - 1

		if tag < 0 then
			text:removeSelf()
			sender:setEnabled(true)
			sender:loadTextures("input/get.png","input/get-on.png")
			sender:setTouchEnabled(true)
		else
			text:setText(tag.."s",{{"s",":"}})
			text:setTag(tag)
		end
	end

	schedule(text, fun, 1)
end

function BindPhoneLayer:receiveAccountUpFailed(data)
	-- self.refereeTextEdit:setText("")
end

function BindPhoneLayer:onClickClose(sender)
	dispatchEvent("registerLayerUpCallBack");
	self:delayCloseLayer(0)
end

return BindPhoneLayer
