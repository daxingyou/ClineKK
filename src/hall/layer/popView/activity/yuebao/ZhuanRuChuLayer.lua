local ZhuanRuChuLayer = class("ZhuanRuChuLayer",PopLayer)

function ZhuanRuChuLayer:create(oType)
	return ZhuanRuChuLayer.new(oType)
end

function ZhuanRuChuLayer:ctor(oType)
	self.super.ctor(self, PopType.moreBig)

	self.oType = oType--取 0 存 1

	if oType == nil then
		self.oType = 0
	end

	self:bindEvent()

	self:initUI()
end

function ZhuanRuChuLayer:hideCloseBtn()
	self.closeBtn:setVisible(false);
end

function ZhuanRuChuLayer:bindEvent()
	self:pushEventInfo(YuEBaoInfo,"getBankScore",handler(self, self.receiveGetBankScore))
	self:pushEventInfo(YuEBaoInfo,"storeBankScore",handler(self, self.receiveStoreBankScore))
	self:pushGlobalEventInfo("isCanSendGetScore",handler(self, self.receiveIsCanSendGetScore))
	self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.resetInfo))
end

function ZhuanRuChuLayer:initUI()
	self.sureBtn:removeSelf()
	self:updateBg("activity/yuebao/commonBg1.png");
	local size = self.bg:getContentSize();

	self:updateCloseBtnPos(0,-40)

	--背景
	local scoreBg = ccui.ImageView:create("activity/yuebao/yeb_di1.png");
	scoreBg:setPosition(size.width/2,size.height*0.65+10);
	self.bg:addChild(scoreBg);

	--标题
	local titleStr = "activity/yuebao/yeb_zhuanchu_t.png"
	if self.oType == 1 then
		titleStr = "activity/yuebao/yeb_zhuanru_t2.png"
	end
	local title = ccui.ImageView:create(titleStr)
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	if globalUnit.isEnterGame == true then
		
		local pwd = ccui.ImageView:create("login/pwdInfo.png")
		pwd:setAnchorPoint(1,0.5)
		pwd:setPosition(self.size.width/2-165,self.size.height/2-140)
		self.bg:addChild(pwd)

		self.pwdTextEdit = createEditBox(pwd,"请输入余额宝密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)
		self.pwdTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))

	end

	local scorePath = "activity/yuebao/yeb_zhuanchujine.png"
	if self.oType == 1 then
		scorePath = "activity/yuebao/yeb_zhuanrujine.png"
	end
	local Score = ccui.ImageView:create(scorePath)
	Score:setAnchorPoint(1,0.5)
	Score:setPosition(self.size.width/2-170,self.size.height/2-50)
	self.bg:addChild(Score)
	if self.oType == 0 then  --取 0 存 1
		self.codeTextEdit = createEditBox(Score,"输入取出金额",cc.EDITBOX_INPUT_MODE_DECIMAL,1)
	else
		self.codeTextEdit = createEditBox(Score,"输入存入金额",cc.EDITBOX_INPUT_MODE_DECIMAL,1)
	end

	self.codeTextEdit:setMaxLength(11)

	local sureBtnStr = {"activity/yuebao/yeb_zhuanchu.png","activity/yuebao/yeb_zhuanchu-on.png","activity/yuebao/yeb_zhuanchu-cancle.png"};
	if self.oType == 1 then
		sureBtnStr = {"activity/yuebao/yeb_zhuanru_z.png","activity/yuebao/yeb_zhuanru_z-on.png","activity/yuebao/yeb_zhuanru-cancle.png"};
	end

	--确定按钮
	local sureBtn = ccui.Button:create(sureBtnStr[1],sureBtnStr[2],sureBtnStr[3]);
	sureBtn:setPosition(size.width/2,80);
	if globalUnit.isEnterGame == true then
		sureBtn:setPosition(size.width/2,60);
	end
	self.bg:addChild(sureBtn);
	sureBtn:setTag(1);
	self.sureBtn = sureBtn
	sureBtn:onClick(function(sender) self:onClickBtn(sender) end)

	-- --分数
	local scoreText = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao4.png",37,51,"+")
	scoreText:setPosition(scoreBg:getContentSize().width/2,scoreBg:getContentSize().height*0.4);
	scoreBg:addChild(scoreText);
	self.scoreText = scoreText;
	
	--绘制初始金钱
	local money = PlatformLogic.loginResult.i64Bank
	scoreText:setString(":"..goldConvertFour(money,1));
	if self.oType == 1 then
		money = PlatformLogic.loginResult.i64Money
		scoreText:setString(":"..goldConvert(money,1));
	end

	--全部按钮
	local allButton = ccui.Button:create("activity/yuebao/yeb_quanbu1.png","activity/yuebao/yeb_quanbu1-on.png");
	allButton:setPosition(self.size.width/2+370,self.size.height/2-50);
	self.bg:addChild(allButton); 
	allButton:setTag(3);
	allButton:onClick(function(sender) self:onClickBtn(sender) end)

	-- --线
	-- local image = ccui.ImageView:create("activity/yuebao/yeb_fengexian1.png");
	-- self.bg:addChild(image);
	-- image:setPosition(self.size.width/2,self.size.height/2-90);
	-- if globalUnit.isEnterGame == true then
	-- 	image:setPosition(self.size.width/2,self.size.height/2-90-60);
	-- end

	if self.oType == 1 then
		--字
		local image = ccui.ImageView:create("activity/yuebao/wenzi.png");
		self.bg:addChild(image);
		image:setPosition(self.size.width*0.4,self.size.height/2-141);

		-- local image = ccui.ImageView:create("activity/yuebao/yeb_z_zi-2.png");
		-- self.bg:addChild(image);
		-- image:setPosition(self.size.width*0.1-10,self.size.height/2-127);

		-- local image = ccui.ImageView:create("activity/yuebao/yeb_z_zi-3.png");
		-- self.bg:addChild(image);
		-- image:setPosition(self.size.width*0.1+315,self.size.height/2-153);

		local image = ccui.ImageView:create("activity/yuebao/yeb_zhanghuyue.png");
		scoreBg:addChild(image);
		image:setPosition(scoreBg:getContentSize().width/2,scoreBg:getContentSize().height*0.8);

	else
		local image = ccui.ImageView:create("activity/yuebao/yeb_zi-zhuanru.png");
		self.bg:addChild(image);
		image:setPosition(self.size.width*0.4-50,self.size.height/2-127);
		if globalUnit.isEnterGame == true then
			image:setPosition(self.size.width*0.4-50,self.size.height/2-127-80);
		end

		local image = ccui.ImageView:create("activity/yuebao/yeb_yuebaoyue.png");
		scoreBg:addChild(image);
		image:setPosition(scoreBg:getContentSize().width/2,scoreBg:getContentSize().height*0.8);
	end

	if globalUnit.isEnterGame == true then
		-- btn:setPosition(size.width*0.35,size.height*0.2)
		-- btn1:setPosition(size.width*0.65,size.height*0.2)
		-- btn1:setEnabled(false)
		self.isCanSure = true
	else
		-- btn:setPosition(size.width*0.45,size.height*0.15-10)
		-- btn1:setPosition(size.width*0.75,size.height*0.15-10)
	end
end

function ZhuanRuChuLayer:updateSlider()
	local money = PlatformLogic.loginResult.i64Bank

	if self.oType == 1 then
		money = PlatformLogic.loginResult.i64Money
	end

	money = money 

	if math.abs(money) == 0 then
		money = ""
	end

	if money == "" then
		self.codeTextEdit:setText("")
	else
		--self.codeTextEdit:setText(string.format("%.4f",goldConvertFour(money)))
		if self.oType == 1 then
			self.codeTextEdit:setText(string.format("%.2f",goldConvert(money)))
		else
			self.codeTextEdit:setText(string.format("%.4f",goldConvertFour(self:changesNumber(money))))
		end
	end
end

function ZhuanRuChuLayer:onClickBtn(sender)
	local tag = sender:getTag()

	
	if tag == 1 then
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
		if money < 1 and self.oType == 1 then
			addScrollMessage("您输入的金币小于1")
			return
		end

		if self.oType == 0 then -- 转出的时候只能是整数
			if money%1 ~=0 then
				addScrollMessage("您输入的金币不是整数")
				return
			end
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
		local text = "余额宝余额不足，无法取款"

		if self.oType == 1 then
			money1 = PlatformLogic.loginResult.i64Money
			text = "钱包余额不足，无法存款"
		end

		luaPrint("money = "..money)
		luaPrint("money1 = "..money1)
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

			YuEBaoInfo:sendGetBankScoreRequest(money*100,MD5_CTX:MD5String(pwd))
		elseif self.oType == 1 then--存
			YuEBaoInfo:sendStoreBankScoreRequest(money)
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

		-- self:stopActionByTag(5555)
		-- self.isChangeSlider = true
		-- self.percent = 100
		-- self.slider:setPercent(self.percent)
		self:updateSlider()
		performWithDelay(self,function() self.isChangeSlider = nil end,0.5):setTag(5555)
	end
end

function ZhuanRuChuLayer:receiveGetBankScore(data)
	if self.oType ~= 0 then
		return
	end

	local data = data._usedata

	local text = "";
	if data.ret == 0 then
		if globalUnit.isEnterGame == true then
			PlatformLogic.loginResult.i64Bank = PlatformLogic.loginResult.i64Bank - data.OperatScore*100;
		end
		
		self:resetInfo()
		text = "余额宝金币提取操作成功，请查验账户信息"
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
		text = "余额宝提取错误！"
	end

	addScrollMessage(text)
end

--重置信息
function ZhuanRuChuLayer:resetInfo()
	-- self.percent = 0
	-- self.slider:setPercent(0)
	luaPrint("resetInfo**********",PlatformLogic.loginResult.i64Money,PlatformLogic.loginResult.i64Bank);
	self:updateSlider()
	if self.codeTextEdit then
		self.codeTextEdit:setText("")
	end

	if self.pwdTextEdit then
		self.pwdTextEdit:setText("")
	end

	local money = PlatformLogic.loginResult.i64Bank
	luaPrint("resetInfo111",goldConvertFour(money,1));
	self.scoreText:setString(":"..goldConvertFour(money,1));
	if self.oType == 1 then
		money = PlatformLogic.loginResult.i64Money
		self.scoreText:setString(":"..goldConvert(money,1));
	end
end

--转化数字，如果小数点后面3、4位不为0舍弃
function ZhuanRuChuLayer:changesNumber(score)
	local money = math.floor(score/10000);
	money = money*10000;
	return money;
end

function ZhuanRuChuLayer:receiveStoreBankScore(data)
	if self.oType ~= 1 then
		return
	end

	local data = data._usedata

	local text = "";
	if data.ret == 0 then

		self:resetInfo()
		text = "余额宝金币存入操作成功，请查验账户信息"
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
		text = "余额宝提取错误！"
	end

	addScrollMessage(text)
end

function ZhuanRuChuLayer:onEditBoxHandler(event)
	local name = event.name

	if name == "began" then
		--todo
	elseif name == "ended" then
		if self.isCanSure == true then
			luaPrint("onEditBoxHandler",event.target:getText());
			self.sureBtn:setEnabled(event.target:getText() ~= "")
		end
	elseif name == "return" then
	elseif name == "changed" then
		--todo
	end
end

function ZhuanRuChuLayer:receiveIsCanSendGetScore(data)
	local data = data._usedata
	self.isCanSure = data

	self.sureBtn:setEnabled(data == true)
end

return ZhuanRuChuLayer