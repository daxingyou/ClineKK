
local CunRuLayer = class("CunRuLayer", PopLayer)

function CunRuLayer:create(oType,zijinMoney)
	return CunRuLayer.new(oType,zijinMoney)
end

function CunRuLayer:ctor(oType,zijinMoney)
	self.super.ctor(self,PopType.middle)

	-- self.layer = layer
	-- self.parent = parent
	self.oType = oType--取 0 存 1

	self.zijinMoney = zijinMoney;--资金池金额

	if oType == nil then
		self.oType = 0
	end

	self:bindEvent()

	self:initUI()
end

function CunRuLayer:bindEvent()
	self:pushEventInfo(PartnerInfo,"PartnerScore",handler(self, self.receiveGetBankScore))--取钱
	self:pushEventInfo(PartnerInfo,"AddPartnerScore",handler(self, self.receiveStoreBankScore))--存钱
	--self:pushGlobalEventInfo("isCanSendGetScore",handler(self, self.receiveIsCanSendGetScore))
end

function CunRuLayer:initUI()

	self.sureBtn:removeSelf()

	local size = self.bg:getContentSize();

	--标题
	local titleStr = "newExtend/hehuoren/quchubiaoti.png";
	if self.oType == 1 then
		titleStr = "newExtend/hehuoren/cunrubiaoti.png";
	end
	local title = ccui.ImageView:create(titleStr)
	title:setPosition(self.size.width/2,self.size.height-45)
	self.bg:addChild(title)

	local kuang1 = ccui.ImageView:create("newExtend/hehuoren/jinedi.png")
	kuang1:setPosition(size.width*0.5-250,size.height*0.5+140);
	self.bg:addChild(kuang1)

	local kuang2 = ccui.ImageView:create("newExtend/hehuoren/jinedi.png")
	kuang2:setPosition(size.width*0.5+250,size.height*0.5+140);
	self.bg:addChild(kuang2)

	local jian = ccui.ImageView:create("newExtend/hehuoren/jian.png");
	jian:setPosition(self.size.width/2,self.size.height*0.5+140);
	self.bg:addChild(jian);

	local str1 = "newExtend/hehuoren/yuerbaoyue.png";
	if self.oType == 0 then
		str1 = "newExtend/hehuoren/jiangchijine.png";
	end
	local str2 = "newExtend/hehuoren/jiangchijine.png";
	if self.oType == 0 then
		str2 = "newExtend/hehuoren/yuerbaoyue.png";
	end

	local image1 = ccui.ImageView:create(str1);
	kuang1:addChild(image1)
	image1:setPosition(kuang1:getContentSize().width/2,kuang1:getContentSize().height/2+35);

	local image2 = ccui.ImageView:create(str2);
	kuang2:addChild(image2)
	image2:setPosition(kuang2:getContentSize().width/2,kuang2:getContentSize().height/2+35);

	local scoreText1 = FontConfig.createWithCharMap("1000","newExtend/hehuoren/moneynumber.png",30,41,"+")
	scoreText1:setPosition(kuang1:getContentSize().width/2,kuang1:getContentSize().height/2-20);
	kuang1:addChild(scoreText1);
	scoreText1:setScale(0.6);
	self.scoreText1 = scoreText1;

	local scoreText2 = FontConfig.createWithCharMap("1000","newExtend/hehuoren/moneynumber.png",30,41,"+")
	scoreText2:setPosition(kuang1:getContentSize().width/2,kuang1:getContentSize().height/2-20);
	kuang2:addChild(scoreText2);
	scoreText2:setScale(0.6);
	self.scoreText2 = scoreText2;

	if self.oType == 1 then
		self:setScore(PlatformLogic.loginResult.i64Bank,self.zijinMoney);
	else
		self:setScore(self.zijinMoney,PlatformLogic.loginResult.i64Bank);
	end

	local text = ccui.ImageView:create("newExtend/hehuoren/quchujine.png")
	text:setAnchorPoint(0.5,0.5)
	self.bg:addChild(text)

	text:setPosition(size.width*0.30,size.height*0.55-20)
	
	if self.oType == 0 then
		self.codeTextEdit, editBg = createEditBox(text,"输入取出金额",cc.EDITBOX_INPUT_MODE_DECIMAL,1)
	else
		text:loadTexture("newExtend/hehuoren/cunruText.png")
		self.codeTextEdit, editBg = createEditBox(text,"输入存入金额",cc.EDITBOX_INPUT_MODE_DECIMAL,1)
	end

	self.codeTextEdit:setMaxLength(11)

	-- self.codeTextEdit:onEditHandler(handler(self, self.onMoneyEditBoxHandler))

	--购买
	local btn = ccui.Button:create("bank/add.png","bank/add-on.png")
	btn:setPosition(editBg:getContentSize().width,editBg:getContentSize().height/2)
	btn:setAnchorPoint(0.5,0.5)
	editBg:addChild(btn)
	btn:onClick(function(sender) createShop() end)
	editBg = nil
	btn:setVisible(false);

	--滑动条
	local slider = ccui.Slider:create()
	slider:loadBarTexture("newExtend/hehuoren/linebackground.png")
	slider:loadProgressBarTexture("newExtend/hehuoren/line.png")
	slider:loadSlidBallTextures("newExtend/hehuoren/huadong.png","newExtend/hehuoren/huadong-on.png")	
	slider:setPercent(0)
	self.bg:addChild(slider)
	self.slider = slider
	self.percent = 0
	slider:onEvent(handler(self, self.onClickSlider))

	local percent = ccui.ImageView:create("newExtend/hehuoren/percent.png")
	self.bg:addChild(percent)

	--max
	local btn = ccui.Button:create("newExtend/hehuoren/max.png","newExtend/hehuoren/max-on.png")
	btn:setTag(3)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	
	slider:setPosition(size.width*0.5,size.height*0.4)
	percent:setPosition(size.width*0.5,size.height*0.4-60)
	btn:setPosition(size.width*0.85,size.height*0.4)
	

	--重置
	local btn = ccui.Button:create("newExtend/hehuoren/reset.png","newExtend/hehuoren/reset-on.png")
	btn:setTag(1)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	self.resetBtn = btn
	btn:setAnchorPoint(0.5,0.5);
	
	--确定
	local btn1 = ccui.Button:create("common/ok.png","common/ok-on.png","common/ok-dis.png")
	btn1:setTag(2)
	self.bg:addChild(btn1)
	self.sureBtn = btn1
	btn1:setAnchorPoint(0.5,0.5);
	btn1:onClick(function(sender) self:onClickBtn(sender) end)

	if globalUnit.isEnterGame == true then
		btn:setPosition(size.width*0.35,size.height*0.2)
		btn1:setPosition(size.width*0.65,size.height*0.2)
		-- btn1:setEnabled(false)
		self.isCanSure = true
	else
		btn:setPosition(size.width*0.3,size.height*0.10+10)
		btn1:setPosition(size.width*0.7,size.height*0.10+10)
	end
end

function CunRuLayer:setScore(score1,score2)
	luaPrint("setScore",score1,score2);
	if self.oType == 1 then
		self.scoreText1:setString(":"..goldConvertFour(score1,1));
		self.scoreText2:setString(":"..goldConvert(score2,1));
	else
		self.scoreText1:setString(":"..goldConvert(score1,1));
		self.scoreText2:setString(":"..goldConvertFour(score2,1));
	end
	self.zijinMoney = score1
end

function CunRuLayer:onClickSlider(event)
	if event.eventType == 0 then
		local money = self.zijinMoney;

		if self.oType == 1 then
			money = PlatformLogic.loginResult.i64Bank
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
		local money = self.zijinMoney
		local text = "资金池没有余额，无法取款"

		if self.oType == 1 then
			money = PlatformLogic.loginResult.i64Bank
			text = "钱包没有余额，无法存款"
		end

		if money <= 0 then
			addScrollMessage(text)
			event.target:setPercent(0)
		end
	end
end

function CunRuLayer:updateSlider()
	local money = self.zijinMoney

	if self.oType == 1 then
		money = PlatformLogic.loginResult.i64Bank
	end

	money = money * self.percent / 100

	if math.abs(money) == 0 then
		money = ""
	end

	if money == "" then
		self.codeTextEdit:setText("")
	else
		self.codeTextEdit:setText(tostring(math.floor(money/100)))
		if self.oType == 1 then
			self.codeTextEdit:setText(tostring(math.floor(money/10000)))
		end
	end
end

function CunRuLayer:onClickBtn(sender)
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

		local money1 = self.zijinMoney
		local text = "资金池余额不足，无法取款"

		if self.oType == 1 then
			money1 = PlatformLogic.loginResult.i64Bank
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

			PartnerInfo:sendGetPartnerScoreRequest(money)
		elseif self.oType == 1 then--存
			PartnerInfo:sendGetAddPartnerScoreRequest(money*100)
		end
	elseif tag == 3 then
		local money = self.zijinMoney;
		local text = "资金池没有余额，无法取款"

		if self.oType == 1 then
			money = PlatformLogic.loginResult.i64Bank
			text = "余额宝没有余额，无法存款"
		end

		luaPrint("money333",money,PlatformLogic.loginResult.i64Bank,self.zijinMoney);

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

function CunRuLayer:receiveGetBankScore(data)
	if self.oType ~= 0 then
		return
	end

	local data = data._usedata

	luaDump(data,"取钱返回");

	local text = "";
	if data.ret == 0 then
		self:onClickBtn(self.resetBtn)
		text = "金币提取操作成功，请查验账户信息"
		self:setScore(data.PartnerScore,data.BankScore);
		dispatchEvent("refreshScoreBank")
	elseif data.ret == 1 then
		text = "取出失败，资金池仅在未激活时取出"
	else
		text = "提取错误！"
	end

	addScrollMessage(text)
end

function CunRuLayer:receiveStoreBankScore(data)
	if self.oType ~= 1 then
		return
	end

	local data = data._usedata

	luaDump(data,"存钱返回");

	local text = "";
	if data.ret == 0 then
		self:onClickBtn(self.resetBtn)
		text = "金币存入操作成功，请查验账户信息"
		self:setScore(data.BankScore,data.PartnerScore);
		dispatchEvent("refreshScoreBank")
	elseif data.ret == 1 then
		text = "金额不足！"
	else
		text = "存入错误！"
	end

	addScrollMessage(text)
end

function CunRuLayer:onEditBoxHandler(event)
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

function CunRuLayer:onMoneyEditBoxHandler(event)
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

function CunRuLayer:receiveIsCanSendGetScore(data)
	local data = data._usedata

	self.isCanSure = data

	self.sureBtn:setEnabled(data == true)
end

return CunRuLayer