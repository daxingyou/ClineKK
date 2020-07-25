local TransferLayer = class("TransferLayer",PopLayer)

function TransferLayer:create()
	return TransferLayer.new()
end

function TransferLayer:ctor()
	self.super.ctor(self, PopType.moreBig)

	self.zhuanzhangMoney = 0;

	self.phoneNumber = nil;

	self:bindEvent()

	self:initUI()
end

function TransferLayer:hideCloseBtn()
	self.closeBtn:setVisible(false);
end

function TransferLayer:bindEvent()
	self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.resetInfo))
	self:pushEventInfo(YuEBaoInfo,"UserInfo",handler(self, self.receiveUserInfo))
	self:pushEventInfo(YuEBaoInfo,"TransferScore",handler(self, self.receiveTransferScore))
end

--获得玩家信息
function TransferLayer:receiveUserInfo(data)
	local data = data._usedata
	luaDump(data,"对方信息");
	if data.ret == 0 then --成功
		if self.phoneNumber ~= nil then
			local layer = require("layer.popView.activity.yuebao.TransferUserInfo"):create(self.phoneNumber,self.zhuanzhangMoney,data)
			if layer then
	            display.getRunningScene():addChild(layer)
	        end
	    else
	    	addScrollMessage("转账发生错误！");
	    	self:removeSelf();
	    end
	else
		addScrollMessage("玩家不存在,转入失败！");
	end
end

--转账返回
function TransferLayer:receiveTransferScore(data)
	local data = data._usedata
	luaDump(data,"转账返回");
	if data.ret == 0 then
		dispatchEvent("refreshScoreBank")
		addScrollMessage("转账成功！");
		self.phoneTextEdit:setText("");
		self.codeTextEdit:setText("");
	elseif data.ret == 2 then
		addScrollMessage("密码错误");
	elseif data.ret == 3 then
		addScrollMessage("金币不足");
	elseif data.ret == 4 then
		addScrollMessage("正在游戏中");
	elseif data.ret == 5 then
		addScrollMessage("金币需大于100");
	elseif data.ret == 6 then
		addScrollMessage("对方id不存在");
	end

end

function TransferLayer:initUI()
	self.sureBtn:removeSelf()
	self:updateBg("activity/yuebao/commonBg1.png");
	local size = self.bg:getContentSize();

	--背景
	local scoreBg = ccui.ImageView:create("activity/yuebao/yeb_di1.png");
	scoreBg:setPosition(size.width/2,size.height*0.65+10);
	self.bg:addChild(scoreBg);
	
	self:updateCloseBtnPos(0,-40)

	--标题
	local titleStr = "activity/yuebao/zhuanzhang.png"
	local title = ccui.ImageView:create(titleStr)
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local scorePath = "activity/yuebao/yeb_zhuanchujine.png"

	local userId = ccui.ImageView:create("activity/yuebao/id.png")
    userId:setAnchorPoint(1,0.5)
    userId:setPosition(self.size.width/2-180,self.size.height/2-30)
    self.bg:addChild(userId)
    self.phoneTextEdit = createEditBox(userId,"输入对方ID",cc.EDITBOX_INPUT_MODE_PHONENUMBER,1)
    self.phoneTextEdit:setMaxLength(16)

	local Score = ccui.ImageView:create(scorePath)
    Score:setAnchorPoint(1,0.5)
    Score:setPosition(self.size.width/2-180,self.size.height/2-130)
    self.bg:addChild(Score)
	
	self.codeTextEdit = createEditBox(Score,"输入转账金额",cc.EDITBOX_INPUT_MODE_DECIMAL,1)
	
	self.codeTextEdit:setMaxLength(11)

	local sureBtnStr = {"activity/yuebao/ok.png","activity/yuebao/ok-on.png"};
	
	--确定按钮
	local sureBtn = ccui.Button:create(sureBtnStr[1],sureBtnStr[2]);
	sureBtn:setPosition(size.width/2,80);
	if globalUnit.isEnterGame == true then
		sureBtn:setPosition(size.width/2,80);
	end
	self.bg:addChild(sureBtn);
	sureBtn:setTag(1);
	self.sureBtn = sureBtn
	sureBtn:onClick(function(sender) self:onClickBtn(sender) end)

	--分数
	local scoreText = FontConfig.createWithCharMap("","activity/yuebao/yeb_zitiao4.png",37,51,"+")
	scoreText:setPosition(scoreBg:getContentSize().width/2,scoreBg:getContentSize().height*0.4);
	scoreBg:addChild(scoreText);
	self.scoreText = scoreText;
	
	--绘制初始金钱
	local money = PlatformLogic.loginResult.i64Bank
	scoreText:setString(":"..goldConvertFour(money,1));

	--全部按钮
	local allButton = ccui.Button:create("activity/yuebao/yeb_quanbu1.png","activity/yuebao/yeb_quanbu1-on.png");
	allButton:setPosition(self.size.width/2+370,self.size.height/2-130);
	self.bg:addChild(allButton); 
	allButton:setTag(3);
	allButton:onClick(function(sender) self:onClickBtn(sender) end)

	local image = ccui.ImageView:create("activity/yuebao/yeb_zhanghuyue.png");
	scoreBg:addChild(image);
	image:setPosition(scoreBg:getContentSize().width/2,scoreBg:getContentSize().height*0.8);

	local image = ccui.ImageView:create("activity/yuebao/tishi.png");
	self.bg:addChild(image);
	image:setPosition(self.bg:getContentSize().width/2,self.bg:getContentSize().height*0.05-5);


end

function TransferLayer:updateSlider()
	local money = PlatformLogic.loginResult.i64Bank

	money = money 

	if math.abs(money) == 0 then
		money = ""
	end

	if money == "" then
		self.codeTextEdit:setText("")
	else
		self.codeTextEdit:setText(string.format("%d",goldConvertFour(self:changesNumber(money))))
	end
end

function TransferLayer:onClickBtn(sender)
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

		if tostring(tonumber(money)) ~= money then
			addScrollMessage("输入转账金额有误！");
			return 
		end

		money = tonumber(money)
		-- luaPrint("money 00 =="..money)
		if money < 1  then
			addScrollMessage("您输入的金币小于1")
			return
		end

		if money<100 then
			addScrollMessage("您输入的金币小于100");
			return
		end

		if money%1 ~=0 then
			addScrollMessage("您输入的金币不是整数")
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
		local text = "余额宝余额不足，无法转出"

		luaPrint("money = "..money)
		luaPrint("money1 = "..money1)
		if money*100 < money1 then
			
		else
			if tostring(money*100) == tostring(money1) then
				--todo
			else
				addScrollMessage(text)
				return
			end
		end

		local phoneNumber = self.phoneTextEdit:getText();
		if tostring(tonumber(phoneNumber)) ~= phoneNumber then
			addScrollMessage("输入ID有误！");
			return 
		end

		luaPrint("szMobileNo",PlatformLogic.loginResult.dwUserID,phoneNumber);
		if tonumber(phoneNumber) == PlatformLogic.loginResult.dwUserID then
			addScrollMessage("不可以给自己转账！");
			return
		end

		--local pwd = ""
		-- if self.pwdTextEdit then
		-- 	pwd = self.pwdTextEdit:getText()
		-- 	if isEmptyString(pwd) then
		-- 		luaPrint("密码为空")
		-- 		addScrollMessage("密码为空")
		-- 		return
		-- 	end
		-- end
		phoneNumber = tonumber(phoneNumber);
		self.zhuanzhangMoney = money*100;
		self.phoneNumber = phoneNumber;
		--YuEBaoInfo:onTransferMoney(phoneNumber,money*100,MD5_CTX:MD5String(pwd))
		YuEBaoInfo:onRequestUserInfo(phoneNumber)
	elseif tag == 3 then
		local money = PlatformLogic.loginResult.i64Bank
		local text = "保险柜没有余额，无法取款"

		if money <= 0 then
			addScrollMessage(text)
			return
		end

		self:updateSlider()
	end
end

--重置信息
function TransferLayer:resetInfo()
	-- self.percent = 0
	-- self.slider:setPercent(0)
	luaPrint("resetInfo**********",PlatformLogic.loginResult.i64Money,PlatformLogic.loginResult.i64Bank);
	self:updateSlider()
	if self.codeTextEdit then
		self.codeTextEdit:setText("")
	end

	local money = PlatformLogic.loginResult.i64Bank
	self.scoreText:setString(":"..goldConvertFour(money,1));
end

--转化数字，如果小数点后面3、4位不为0舍弃
function TransferLayer:changesNumber(score)
	local money = math.floor(score/10000);
	money = money*10000;
	return money;
end

function TransferLayer:onEditBoxHandler(event)
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

return TransferLayer