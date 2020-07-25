local BankInfoNode = class("BankInfoNode", BaseNode)

function BankInfoNode:create(layer,parent,oType)
	return BankInfoNode.new(layer,parent,oType)
end

function BankInfoNode:ctor(layer,parent,oType)
	self.super.ctor(self)

	self.layer = layer
	self.parent = parent
	self.oType = oType--取 0 存 1

	if oType == nil then
		self.oType = 0
	end

	self:bindEvent()

	self:initUI()
end

function BankInfoNode:bindEvent()
	self:pushEventInfo(BankInfo,"getBankScore",handler(self, self.receiveGetBankScore))
	self:pushEventInfo(BankInfo,"storeBankScore",handler(self, self.receiveStoreBankScore))
	self:pushGlobalEventInfo("isCanSendGetScore",handler(self, self.receiveIsCanSendGetScore))
end

function BankInfoNode:initUI()
	local size = self.parent:getContentSize()

	local text = ccui.ImageView:create("bank/quchuText.png")
	text:setAnchorPoint(1,0.5)
	self:addChild(text)

	if globalUnit.isEnterGame == true then
		text:setPosition(size.width*0.25,size.height*0.72+20)

		local pwd = ccui.ImageView:create("login/pwdInfo.png")
		pwd:setAnchorPoint(1,0.5)
		pwd:setPosition(size.width*0.25,size.height*0.72+20-80)
		self:addChild(pwd)

		self.pwdTextEdit = createEditBox(pwd,"请输入保险箱密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)
		self.pwdTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))
	else
		text:setPosition(size.width*0.35,size.height*0.72)
	end

	if self.oType == 0 then
		self.codeTextEdit, editBg = createEditBox(text,"输入取出金额",cc.EDITBOX_INPUT_MODE_DECIMAL,1)
	else
		text:loadTexture("bank/cunruText.png")
		self.codeTextEdit, editBg = createEditBox(text,"输入存入金额",cc.EDITBOX_INPUT_MODE_DECIMAL,1)
	end

	self.codeTextEdit:setMaxLength(11)

	-- self.codeTextEdit:onEditHandler(handler(self, self.onMoneyEditBoxHandler))

	--购买
	local btn = ccui.Button:create("bank/add.png","bank/add-on.png")
	btn:setPosition(editBg:getContentSize().width,editBg:getContentSize().height/2)
	btn:setAnchorPoint(1,0.5)
	editBg:addChild(btn)
	btn:onClick(function(sender) createShop() end)
	editBg = nil

	--滑动条
	local slider = ccui.Slider:create()
	slider:loadBarTexture("bank/linebackground.png")
	slider:loadProgressBarTexture("bank/line.png")
	slider:loadSlidBallTextures("bank/huadong.png","bank/huadong-on.png")	
	slider:setPercent(0)
	self:addChild(slider)
	self.slider = slider
	self.percent = 0
	slider:onEvent(handler(self, self.onClickSlider))

	local percent = ccui.ImageView:create("bank/percent.png")
	self:addChild(percent)

	--max
	local btn = ccui.Button:create("bank/max.png","bank/max-on.png")
	btn:setTag(3)
	self:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	if globalUnit.isEnterGame == true then
		slider:setPosition(size.width*0.4,size.height/2)
		percent:setPosition(size.width*0.4+27,size.height/2-55)
		btn:setPosition(size.width*0.85,size.height/2)
	else
		slider:setPosition(size.width/2+20,size.height/2)
		percent:setPosition(size.width/2+47,size.height/2-55)
		btn:setPosition(size.width*0.88,size.height/2)
	end

	--重置
	local btn = ccui.Button:create("bank/reset.png","bank/reset-on.png")
	btn:setTag(1)
	self:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	self.resetBtn = btn
	
	--确定
	local btn1 = ccui.Button:create("common/ok.png","common/ok-on.png","common/ok-dis.png")
	btn1:setTag(2)
	self:addChild(btn1)
	self.sureBtn = btn1
	btn1:onClick(function(sender) self:onClickBtn(sender) end)

	if globalUnit.isEnterGame == true then
		btn:setPosition(size.width*0.35,size.height*0.2)
		btn1:setPosition(size.width*0.65,size.height*0.2)
		-- btn1:setEnabled(false)
		self.isCanSure = true
	else
		btn:setPosition(size.width*0.45,size.height*0.15-10)
		btn1:setPosition(size.width*0.75,size.height*0.15-10)
	end
end

function BankInfoNode:onClickSlider(event)
	if event.eventType == 0 then
		local money = PlatformLogic.loginResult.i64Bank

		if self.oType == 1 then
			money = PlatformLogic.loginResult.i64Money
		end

		if money <= 0 then
			event.target:setPercent(0)
			return
		end

		local percent = event.target:getPercent()

		if percent%10 == 0 then
			self.percent = percent
		end

		event.target:setPercent(self.percent)
		self:stopActionByTag(5555)
		self.isChangeSlider = true
		self:updateSlider()
		performWithDelay(self,function() self.isChangeSlider = nil end,0.5):setTag(5555)
	elseif event.eventType == 1 then
		local money = PlatformLogic.loginResult.i64Bank
		local text = "保险柜没有余额，无法取款"

		if self.oType == 1 then
			money = PlatformLogic.loginResult.i64Money
			text = "钱包没有余额，无法存款"
		end

		if money <= 0 then
			addScrollMessage(text)
			event.target:setPercent(0)
		end
	end
end

function BankInfoNode:updateSlider()
	local money = PlatformLogic.loginResult.i64Bank

	if self.oType == 1 then
		money = PlatformLogic.loginResult.i64Money
	end

	money = money * self.percent / 100

	if math.abs(money) == 0 then
		money = ""
	end

	if money == "" then
		self.codeTextEdit:setText("")
	else
		self.codeTextEdit:setText(string.format("%.2f",goldConvert(money)))
	end
end

function BankInfoNode:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then
		self.percent = 0
		self.slider:setPercent(0)
		self:updateSlider()
		if self.pwdTextEdit then
			self.pwdTextEdit:setText("")
		end
	elseif tag == 2 then
		local money = self.codeTextEdit:getText()
		if isEmptyString(money) then
			money = 0
		end

		if tonumber(money) == nil then
			addScrollMessage("请输入正确金额")
			return
		end

		money = tonumber(money)
		-- luaPrint("money 00 =="..money)
		if money <= 0 then
			addScrollMessage("您输入的金币小于等于零")
			return
		end

		local s = tostring(money)

		local i,j = string.find(s,"%.")
		-- luaPrint("s = "..s.."i ="..tostring(i).." j ="..tostring(j))
		if i and j then
			local s1 = string.sub(s,i+1,#s)

			if #s1 > 2 then
				addScrollMessage("请输入正确金额，仅支持小数点后两位")
				return
			end
			-- luaPrint("s1 = "..s1)
			if #s1 == 1 then
				local rt,a = checkNumber(s)

				if rt == false then
					s = a.."0"
				end
			elseif #s1 == 2 then
				local rt,a = checkNumber(s)
				-- luaPrint("a = "..a)
				if rt == false then
					s = a
				end
			end
		else
			s = s.."00"
		end

		money = math.ceil(tonumber(s))

		local money1 = PlatformLogic.loginResult.i64Bank
		local text = "保险柜余额不足，无法取款"

		if self.oType == 1 then
			money1 = PlatformLogic.loginResult.i64Money
			text = "钱包余额不足，无法存款"
		end

		-- luaPrint("money = "..money)
		-- luaPrint("money1 = "..money1)
		if money < money1 then
			
		else
			if tostring(money) == tostring(money1) then
				--todo
			else
				addScrollMessage(text)
				return
			end
		end

		if self.oType == 0 then--取
			local pwd = ""
			if self.pwdTextEdit then
				pwd = self.pwdTextEdit:getText()
				if isEmptyString(pwd) then
					luaPrint("密码为空")
					addScrollMessage("密码为空")
					return
				end
			end

			BankInfo:sendGetBankScoreRequest(money,MD5_CTX:MD5String(pwd))
		elseif self.oType == 1 then--存
			BankInfo:sendStoreBankScoreRequest(money)
		end
	elseif tag == 3 then
		local money = PlatformLogic.loginResult.i64Bank
		local text = "保险柜没有余额，无法取款"

		if self.oType == 1 then
			money = PlatformLogic.loginResult.i64Money
			text = "钱包没有余额，无法存款"
		end

		if money <= 0 then
			addScrollMessage(text)
			return
		end

		self:stopActionByTag(5555)
		self.isChangeSlider = true
		self.percent = 100
		self.slider:setPercent(self.percent)
		self:updateSlider()
		performWithDelay(self,function() self.isChangeSlider = nil end,0.5):setTag(5555)
	end
end

function BankInfoNode:receiveGetBankScore(data)
	if self.oType ~= 0 then
		return
	end

	local data = data._usedata

	local text = "";
	if data.ret == 0 then
		if globalUnit.isEnterGame == true then
			PlatformLogic.loginResult.i64Bank = PlatformLogic.loginResult.i64Bank - data.Score
		end
		self:onClickBtn(self.resetBtn)
		text = "保险箱金币提取操作成功，请查验账户信息"
		dispatchEvent("refreshScoreBank")
	elseif data.ret == 1 then
		text = "用户ID不存在！"
	elseif data.ret == 2 then
		text = "密码不正确！"
	elseif data.ret == 3 then
		text = "金币不足！"
	elseif data.ret == 4 then
		text = "您正在游戏中！"
	else
		text = "保险箱提取错误！"
	end

	addScrollMessage(text)
end

function BankInfoNode:receiveStoreBankScore(data)
	if self.oType ~= 1 then
		return
	end

	local data = data._usedata

	local text = "";
	if data.ret == 0 then
		self:onClickBtn(self.resetBtn)
		text = "保险箱金币存入操作成功，请查验账户信息"
		dispatchEvent("refreshScoreBank")
	elseif data.ret == 1 then
		text = "用户ID不存在！"
	elseif data.ret == 2 then
		text = "密码不正确！"
	elseif data.ret == 3 then
		text = "金币不足！"
	elseif data.ret == 4 then
		text = "您正在游戏中！"
	else
		text = "保险箱提取错误！"
	end

	addScrollMessage(text)
end

function BankInfoNode:onEditBoxHandler(event)
	local name = event.name

	if name == "began" then
		--todo
	elseif name == "ended" then
		if self.isCanSure == true then
			self.sureBtn:setEnabled(event.target:getText() ~= "")
		end
	elseif name == "return" then
	elseif name == "changed" then
		--todo
	end
end

function BankInfoNode:onMoneyEditBoxHandler(event)
	local name = event.name

	if name == "began" then
		self.isChangeSlider = nil
	elseif name == "ended" then
		if self.isChangeSlider ~= true then
			local rt, s = checkNumber(event.target:getText(),event.target)
			if rt == false then
				if #s > 8 then
					event.target:setText(string.sub(s,1,8))
				end
			elseif rt == true then
				if #s > 8 then
					event.target:setText(string.sub(s,1,8))
				end
			end
		end
	elseif name == "return" then
		if self.isChangeSlider ~= true then
			local rt, s = checkNumber(event.target:getText(),event.target)
			if rt == false then
				if #s > 8 then
					event.target:setText(string.sub(s,1,8))
				end
			elseif rt == true then
				if #s > 8 then
					event.target:setText(string.sub(s,1,8))
				end
			end
		end
	elseif name == "changed" then
		if self.isChangeSlider ~= true then
			local rt, s = checkNumber(event.target:getText(),event.target)
			if rt == false then
				if #s > 8 then
					event.target:setText(string.sub(s,1,8))
				end
			elseif rt == true then
				if #s > 8 then
					event.target:setText(string.sub(s,1,8))
				end
			end
		end
	end
end

function BankInfoNode:receiveIsCanSendGetScore(data)
	local data = data._usedata

	self.isCanSure = data

	self.sureBtn:setEnabled(data == true)
end

return BankInfoNode