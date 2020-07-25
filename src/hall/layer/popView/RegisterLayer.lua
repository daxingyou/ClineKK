local RegisterLayer = class("RegisterLayer", PopLayer)

function RegisterLayer:ctor()
	self.super.ctor(self,PopType.middle)

	self:initUI()

	self:bindEvent()
end

function RegisterLayer:bindEvent()
	self:pushGlobalEventInfo("accountUpSuccess",handler(self, self.receiveAccountUp))
	self:pushGlobalEventInfo("getCodeSuccess",handler(self, self.receiveGetCodeSuccess))
	self:pushGlobalEventInfo("accountUpFailed",handler(self, self.receiveAccountUpFailed))
	self:pushGlobalEventInfo("checkFangShuaFailed",handler(self, self.checkFangShuaFailed))
end

function RegisterLayer:initUI()
	self:setName("RegisterLayer")
	self:updateSureBtnPos(-115)
	local title = ccui.ImageView:create("common/registerTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local h = 85
	local y = self.size.height*0.75
	local x = self.size.width*0.35

	if device.platform ~= "windows" and isEmptyString(globalUnit.jsstring1) and not isEmptyString(GameConfig.AliyunUrl) then
		h = 73
		y = self.size.height*0.75+15
	end

	--手机号
	local mobile = ccui.ImageView:create("login/mobile.png")
	mobile:setAnchorPoint(1,0.5)
	mobile:setPosition(x,y)
	self.bg:addChild(mobile)

	self.phoneTextEdit = createEditBox(mobile,"请输入手机号",cc.EDITBOX_INPUT_MODE_PHONENUMBER,1)

	y = y - h
	--验证码
	local mobileCode = ccui.ImageView:create("login/mobileCode.png")
	mobileCode:setAnchorPoint(1,0.5)
	mobileCode:setPosition(x,y)
	self.bg:addChild(mobileCode)

	self.codeTextEdit, editBg = createEditBox(mobileCode,"请输入验证码",cc.EDITBOX_INPUT_MODE_PHONENUMBER,1,cc.size(300,70))

	--获取验证码
	self.codeBtn = createPhoneCodeBtn(editBg,handler(self, self.sendPhoneCode))
	editBg = nil

	y = y - h
	--输入密码
	local name = ccui.ImageView:create("login/xingming.png")
	name:setAnchorPoint(1,0.5)
	name:setPosition(x,y)
	self.bg:addChild(name)

	self.nameTextEdit = createEditBox(name,"请输入真实姓名(必须与银行卡开户名字一致)",cc.EDITBOX_INPUT_MODE_SINGLELINE,1)
	self.nameTextEdit:setMaxLength(20)

	--输入密码
	y = y - h
	local pwd = ccui.ImageView:create("login/pwd.png")
	pwd:setAnchorPoint(1,0.5)
	pwd:setPosition(x,y)
	self.bg:addChild(pwd)

	self.pwdTextEdit = createEditBox(pwd,"请输入6-20位密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

	--确定密码
	y = y - h
	local againPwd = ccui.ImageView:create("login/againPwd.png")
	againPwd:setAnchorPoint(1,0.5)
	againPwd:setPosition(x,y)
	self.bg:addChild(againPwd)

	self.againPwdTextEdit = createEditBox(againPwd,"请再输入一次密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

	--推荐人ID
	-- local referee = ccui.ImageView:create("login/answer.png")
	-- referee:setAnchorPoint(1,0.5)
	-- referee:setPosition(x,y-h*4)
	-- self.bg:addChild(referee)

	-- self.refereeTextEdit = createEditBox(referee,"请输入下面题目答案",cc.EDITBOX_INPUT_MODE_NUMERIC,1)

	--用户协议
	-- local checkBox = ccui.CheckBox:create("common/gouxuankuang.png","common/gouxuankuang.png","common/gouxuan.png","common/gouxuankuang.png","common/gouxuankuang.png")
	-- checkBox:setPosition(x,y-h*5)
	-- checkBox:setSelected(true)
	-- self.bg:addChild(checkBox)
	-- self.checkBox = checkBox

	-- local xieyiBtn = ccui.Button:create("login/agreeXieyi.png","login/agreeXieyi-on.png")
	-- xieyiBtn:setAnchorPoint(cc.p(0,0.5))
	-- xieyiBtn:setPosition(checkBox:getContentSize().width+20, checkBox:getContentSize().height/2)
	-- checkBox:addChild(xieyiBtn)
	-- xieyiBtn:onClick(handler(self, self.onClickXieyi))

	-- local label = FontConfig.createWithSystemFont("",26,cc.c3b(20,112,148))
	-- label:setAnchorPoint(0.5,0.5)
	-- label:setPosition(self.size.width/2, y-h*5+15)
	-- self.bg:addChild(label)
	-- self.text = label

	self:createWebView()
end

function RegisterLayer:checkFangShuaFailed(data)
	self:createWebView()
end

function RegisterLayer:createWebView()
	if device.platform ~= "windows" and isEmptyString(globalUnit.jsstring1) and not isEmptyString(GameConfig.AliyunUrl) then
		if self._webView then
			self:stopActionByTag("123")
			self._webView:reload()
			return
		end

		local rd,code,pcode = createCheckCode(1825)

		local webView = ccexp.WebView:create()
		webView:setContentSize(cc.size(650, 100))
		webView:setScalesPageToFit(true)
		webView:setPosition(cc.p(self.size.width/2-20, 118))
		local url = GameConfig.AliyunUrl.."/fs/index.html?AppKey="..pcode
		webView:loadURL(url,false)
		webView:setBackgroundTransparent()
		webView:setBounces(false)
		self.bg:addChild(webView)
		self._webView = webView
		webView:setOnShouldStartLoading(function(sender, url)
			luaPrint("onWebViewShouldStartLoading,url is ", url)
			return true
		end)

		webView:setOnDidFinishLoading(function(sender, url)
			luaPrint("onWebViewDidFinishLoading,url is ", url)
			if self:isVisible() then
				sender:show()
			end
		end)

		webView:setOnDidFailLoading(function(sender, url)
			luaPrint("onWebViewDidFailLoading,url is ", url)
			webView:reload()
		end)
		--设置Scheme 用于iOS复制微信号到剪贴板
		if webView.setOnJSCallback then
			local scheme = "weixincopy"
			webView:setJavascriptInterfaceScheme(scheme)
			webView:setOnJSCallback(function(sender,url)
				luaPrint("js callback ===",url)
				local i,j = string.find(url,"://")
				if i and j then
					local js = string.split(url,"_")
					if #js > 2 then
						if js[2] == "fangshua" then
							if tonumber(js[3]) == 1 then
								local endIndex = string.len(url)-string.len(js[#js])-1
								local startIndex = string.len(js[1])+string.len(js[2])+string.len(js[3])+3+1
								if endIndex < startIndex then
									endIndex = string.len(url)
								end
								local realStr = string.sub(url,startIndex,endIndex)

								i,j = string.find(realStr,js[#js]) 
								if i and j then
									realStr = string.gsub(realStr,js[#js],"_")
								end
								luaPrint(realStr)

								globalUnit.jsstring1 = realStr

								if self._webView then
									self._webView:setOnJSCallback(function(sender,url) end)
									performWithDelay(self,function() self._webView:removeSelf() self._webView = nil end,0.05):setTag(123)
								end
							else
								addScrollMessage("请稍后重试")
								if self._webView then
									self._webView:reload()
								end
							end
						end
					end
				end
			end)
		end
		-- self:hideAll()
	end
end

function RegisterLayer:hideAll()
	-- self:hide()
	self:setTouchEnabled(false)
	if device.platform ~= "windows" then
		if self._webView then
			-- self._webView:hide()
			self._webView:setTouchEnabled(false)
		end
	end
	self.nameTextEdit:setText("")
	self.pwdTextEdit:setText("")
	self.againPwdTextEdit:setText("")
end

--显示所有
function RegisterLayer:showAll()
	self.isClose = nil
	-- self:show()
	self:setTouchEnabled(true)
	if device.platform ~= "windows" then
		if self._webView then
			-- self._webView:show()
			self._webView:setTouchEnabled(true)
		end
	end
end

function RegisterLayer:setRegisterCallback(callback)
	self.callback = callback
end

--发送手机验证码
function RegisterLayer:sendPhoneCode(sender)
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
	local str = "userid="..(PlatformLogic.loginResult.dwUserID or 0).."&phone="..phone.."&type=4".."&AgentID="..channelID
	local rd,code,pcode = createCheckCode()

	str = str.."&rd="..rd.."&code="..code.."&pcode="..pcode

	HttpUtils:requestHttp(url, function(result, response) getCodeCallback(result, response); end, "POST", str);

	return true
end

function RegisterLayer:onClickSure(sender)
	local phone = self.phone

	if isEmptyString(phone) then
		phone = self.phoneTextEdit:getText()
	end

	if isEmptyString(phone) then
		luaPrint("手机号为空")
		addScrollMessage("手机号为空")
		return
	end

	if #phone > 11 then
		luaPrint("您输入的手机号有误，请重输")
		addScrollMessage("您输入的手机号有误，请重输")
		return
	end

	local name = self.nameTextEdit:getText();

	if isEmptyString(name) then
		addScrollMessage("请输入您的真实姓名")
		return
	end

	if isEmoji(name) or not stringIsHaveChinese(name,1) then
		addScrollMessage("您输入的真实姓名包含非汉字如空格等")
		return
	end

	-- if type(sender) == "table" then
	-- 	name = sender[1]
	-- end

	-- if isEmptyString(name) then
	-- 	luaPrint("用户名为空")
	-- 	addScrollMessage("用户名为空")
	-- 	return
	-- end

	-- local s = string.gsub(name,"[%w]","")

	-- if not isEmptyString(s) then
	-- 	addScrollMessage("用户名只能包含字母和数字")
	-- 	return
	-- end

	-- if #name > 20 then
	-- 	addScrollMessage("您输入的用户名大于20位，请重输")
	-- end

	-- name = self.nameTextEdit:getText();

	local code = self.codeTextEdit:getText()

	if isEmptyString(code) then
		luaPrint("验证码为空")
		addScrollMessage("验证码为空")
		return
	end

	local pwd = self.pwdTextEdit:getText()

	if type(sender) == "table" then
		pwd = sender[2]
	end

	if isEmptyString(pwd) then
		luaPrint("密码为空")
		addScrollMessage("密码为空")
		return
	end

	local ret,msg = verifyNumberAndEnglish(pwd)
	if not ret then
		luaPrint("您输入的密码包含非法字符")
		addScrollMessage(msg)
		return
	end

	if #pwd < 6 then
		luaPrint("您输入的密码小于6位，请重输")
		addScrollMessage("您输入的密码小于6位，请重输")
		return
	end

	if #pwd > 20 then
		luaPrint("您输入的密码大于20位，请重输")
		addScrollMessage("您输入的密码大于20位，请重输")
		return
	end

	local againPwd = self.againPwdTextEdit:getText()

	if type(sender) ~= "table" then
		if isEmptyString(againPwd) then
			luaPrint("确认密码为空")
			addScrollMessage("确认密码为空")
			return
		end

		if pwd ~= againPwd then
			luaPrint("两次密码不一致")
			addScrollMessage("两次密码不一致")
			return
		end
	end

	if isEmptyString(globalUnit.jsstring1)  and not isEmptyString(GameConfig.AliyunUrl) and device.platform ~= "windows" then
		addScrollMessage("请确认滑动验证")
		return
	end

	-- local referee = self.refereeTextEdit:getText()

	-- if self.checkBox and not self.checkBox:isSelected() then
	-- 	luaPrint("请同意用户使用协议！")
	-- 	addScrollMessage("请同意用户使用协议！")
	-- 	return
	-- end

	-- if isEmptyString(referee) then
	-- 	referee = 0
	-- end

	local msg = {}
	msg.phone = phone
	msg.code = code
	msg.pwd = pwd
	msg.answer = name
	msg.name = phone

	globalUnit.registerInfo.phone = msg.phone
	globalUnit.registerInfo.code = msg.code
	globalUnit.registerInfo.pwd = msg.pwd
	globalUnit.registerInfo.answer = msg.answer
	globalUnit.registerInfo.name = msg.name

	if self.callback then
		self.callback(msg)
	else
		dispatchEvent("registerAccount",msg)
	end
end

function RegisterLayer:onClickXieyi(sender)
	addScrollMessage("稍后实现")
end

function RegisterLayer:receiveAccountUp()
	addScrollMessage("账号升级成功")
	self:delayCloseLayer()
end

function RegisterLayer:receiveGetCodeSuccess(data)
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
	text:setPosition(sender:getContentSize().width/2,sender:getContentSize().height/2+5)
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

	if self.text then
		self.text:setString(tostring(data))
	end
end

function RegisterLayer:receiveAccountUpFailed(data)
	-- self.refereeTextEdit:setText("")
end

function RegisterLayer:onExit()
	self.super.onExit(self)
	if self._webView then
		self._webView:setJavascriptInterfaceScheme("")
		self._webView:setOnJSCallback(function() end)
	end
end

function RegisterLayer:onEnterTransitionFinish()
	self:setScale(1)
end

function RegisterLayer:onClickClose(sender)
	dispatchEvent("registerLayerUpCallBack");
	self:delayCloseLayer(0)
end

return RegisterLayer
