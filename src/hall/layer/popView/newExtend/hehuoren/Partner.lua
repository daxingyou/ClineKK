--合伙人类

local Partner = class("Partner", PopLayer)

--创建类 isJump = true 关闭页面的时候弹公告
function Partner:create( isJump )

	local layer = Partner.new( isJump );

	return layer;
end

--构造函数
function Partner:ctor(isJump)
	playEffect("hall/sound/partner.mp3")
	self.super.ctor(self,PopType.none)

	local uiTable = {
		Image_bg = "Image_bg",
		Button_close = "Button_close",
		Button_tgjc = "Button_tgjc",
		Button_msxq = "Button_msxq",
		Button_zjc = "Button_zjc",
		bgkuang_tuiguang = "bgkuang_tuiguang",
		bgkuang_moshi = "bgkuang_moshi",
		bgkuang_zijin = "bgkuang_zijin",
		Button_cunru = "Button_cunru",
		Button_quchu = "Button_quchu",
		Button_mingxi = "Button_mingxi",
		Button_timeSet = "Button_timeSet",
		Button_fuzhi = "Button_fuzhi",
		Button_zanting = "Button_zanting",
		Button_jihuo = "Button_jihuo",
		Button_cancle = "Button_cancle",
		Text_cancleTime = "Text_cancleTime",
		Image_zhancheng = "Image_zhancheng",
		AtlasLabel_money = "AtlasLabel_money",--资金
		Image_fenxiang = "Image_fenxiang",
		AtlasLabel_peopleNum = "AtlasLabel_peopleNum",--人数
		AtlasLabel_zhancheng = "AtlasLabel_zhancheng",--占成
		Image_ziBg = "Image_ziBg",
		Panel_shuoming = "Panel_shuoming",--单局上限占成  说明
		Button_help = "Button_help", --单局上限占成  说明
		Image_danjushangxian = "Image_danjushangxian",
		hehuoren = "hehuoren",
		Node_button = "Node_button",
		Image_ping = "Image_ping",
	}
	self:initData();

	self.isJump = isJump; --关闭页面的时候是否弹公告 true弹
	loadNewCsb(self,"newExtend/hehuoren/hehuoren",uiTable)

	iphoneXFit(self.Image_bg,1);

    if checkIphoneX() then
        self.Image_ziBg:setPositionX(0);
        self.Button_close:setPositionX(self.Button_close:getContentSize().width*0.5);
        self.hehuoren:setPositionX(self.Button_close:getPositionX()+self.Button_close:getContentSize().width*0.5
        	+self.hehuoren:getContentSize().width*0.5);
        local framesize = cc.Director:getInstance():getWinSize()
  		local addWidth = (framesize.width - 1280)/2;
        self.Node_button:setPositionX(self.Node_button:getPositionX()-addWidth);
        self.Image_ping:setPositionX(self.Image_ping:getPositionX()-addWidth);
    end

    self.bit = 80
    if SettlementInfo:getConfigInfoByID(31) then
    	self.bit = SettlementInfo:getConfigInfoByID(31);
    	self.bit =  self:getNumPer(self.bit,10) --tonumber(string.format("%.1f",self.bit/10));
    end

	_instance = self;

	self:setLocalZOrder(999);
end

--进入
function Partner:onEnter()
	self:initUI()

	self:bindEvent()

	self.super.onEnter(self);
end

function Partner:bindEvent()
	self:pushEventInfo(PartnerInfo,"PartnerInfor",handler(self, self.receivePartnerInfo))
	self:pushEventInfo(PartnerInfo,"OpenPartner",handler(self, self.receiveOpenPartner))
	self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.updateMoney))
	self:pushGlobalEventInfo("saveExtend",handler(self, self.receiveSaveExtend))
	self:pushEventInfo(SettlementInfo, "configInfo", handler(self, self.receiveConfigInfo))
end

function Partner:receiveConfigInfo(data)
	luaDump(data, "receiveConfigInfo_data", 5)
	local data = data._usedata
	if data.id == 31 then
		local num = data.val;
		self.bit =  self:getNumPer(num,10) --tonumber(string.format("%.1f",num/10));
		if self.codeTextEdit then
			self.codeTextEdit:setPlaceHolder("最高可设置"..self.bit.."%");
		end
	end
end

function Partner:initData()
	self.zijinMoney = 0;
	self.data = {};
	self.schedule_Partner = nil;
end

function Partner:updateMoney()
	PartnerInfo:sendGetPartnerInfoRequest();
end


function Partner:receivePartnerInfo(data)
	local data = data._usedata
	luaDump(data,"合伙人信息");
	self.data = data;
	self.AtlasLabel_peopleNum:setString(data.UserCount);
	self.AtlasLabel_zhancheng:setString(goldConvert(data.PartnerIncome,1));
	self.AtlasLabel_money:setString(goldConvert(data.PartnerScore,1));
	self.zijinMoney = data.PartnerScore;

	local nowTime = os.time();
	local haveTime = 30*60 + data.StopTime-nowTime;
	luaPrint("nowTime",os.time(),haveTime);
	if haveTime <=0 then
		haveTime = 0;
	end
	self.time_h = math.floor(haveTime/60);
	self.time_s = haveTime%60; 
	luaPrint("计算时间",self.time_h,self.time_s);
	self.Text_cancleTime:setString("00:"..self:timeChange(self.time_h)..":"..self:timeChange(self.time_s));
	if data.IsPartner == 2 then --0未启用 1 启用 2暂停
		self.Button_zanting:setVisible(false);
		self.Button_cancle:setVisible(true);
		self.Button_jihuo:setVisible(false);
		if self.time_h>0 or self.time_s>0 then
			self:startSchedule(1);
		end
		self.Button_timeSet:setEnabled(true);
		self.codeTextEdit:setText(tostring(self:getNumPer(data.PartnerRat,10)));
		-- self.codeTextEdit:setText(string.format("%.1f", data.PartnerRat/10));
		if data.PartnerMaxWin <= 0 then --未设置
			self.limitTextEdit:setPlaceHolder("未设置")
		else
			self.limitTextEdit:setText(data.PartnerMaxWin/100);	
		end
		
		self.codeTextEdit:setEnabled(false);
		self.limitTextEdit:setEnabled(false);
	elseif data.IsPartner == 1 then --启用状态 输入框禁止修改
		self.Button_zanting:setVisible(true);
		self.Button_cancle:setVisible(false);
		self.Button_jihuo:setVisible(false);
		self.Button_timeSet:setEnabled(true);

		self.codeTextEdit:setText(tostring(self:getNumPer(data.PartnerRat,10)));
		-- self.codeTextEdit:setText(string.format("%.1f", data.PartnerRat/10));
		if data.PartnerMaxWin <= 0 then --未设置
			self.limitTextEdit:setPlaceHolder("未设置")
		else
			self.limitTextEdit:setText(data.PartnerMaxWin/100);	
		end
		self.codeTextEdit:setEnabled(false);
		self.limitTextEdit:setEnabled(false);
	elseif data.IsPartner == 0 then
		self.Button_zanting:setVisible(false);
		self.Button_cancle:setVisible(false);
		self.Button_jihuo:setVisible(true);
		self.Button_timeSet:setEnabled(false);
		self.codeTextEdit:setText("");
		self.codeTextEdit:setPlaceHolder("最高可设置"..self.bit.."%");
		self.limitTextEdit:setText("");
		self.limitTextEdit:setPlaceHolder("输入上限金额");

		self.codeTextEdit:setEnabled(true);
		self.limitTextEdit:setEnabled(true);
	end

end

--开启合伙人功能
function Partner:receiveOpenPartner(data)
	local data = data._usedata
	luaDump(data,"合伙人开关");
	--luaPrint("配置表",SettlementInfo:getConfigInfoByID(22));
	local text = ""
	if data.ret == 0 then
		text = "关闭成功"
		self.Button_zanting:setVisible(false);
		self.Button_cancle:setVisible(false);
		self.Button_jihuo:setVisible(true);
		self.Button_timeSet:setEnabled(false);

		--开启输入框
		self.codeTextEdit:setEnabled(true);
		self.limitTextEdit:setEnabled(true);
	elseif data.ret == 1 then
		text = "开启成功"
		self.Button_timeSet:setEnabled(true);
		self.Button_jihuo:setVisible(false);
		self.Button_cancle:setVisible(false);
		self.Button_zanting:setVisible(true);
		self:startSchedule(2);

		--关闭输入框
		self.codeTextEdit:setEnabled(false);
		self.limitTextEdit:setEnabled(false);

		local str2 = self.limitTextEdit:getText();
		local num2 = tonumber(str2)
		if type(num2) == "number" and num2 > 0 then
			-- self.limitTextEdit:setText(str2)
		else
			self.limitTextEdit:setText("");
			self.limitTextEdit:setPlaceHolder("未设置");
		end


		
	elseif data.ret == 2 then
		text = "暂停成功"

		--关闭输入框
		self.codeTextEdit:setEnabled(false);
		self.limitTextEdit:setEnabled(false);

		self.Button_timeSet:setEnabled(true);
		self.Button_jihuo:setVisible(false);
		self.Button_zanting:setVisible(false);
		self.Button_cancle:setVisible(true);
		PartnerInfo:sendGetPartnerInfoRequest();


	elseif data.ret == 10 then
		text = "资金池钱不够"
	elseif data.ret == 11 then
		text = "比例不符合"
	elseif data.ret == 12 then
		text = "直属推广玩家不足"..SettlementInfo:getConfigInfoByID(22).."人"
	elseif data.ret == 13 then
		text = "状态不符合"
	else
		text = "合伙人开关出错"
	end

	addScrollMessage(text)

end

function Partner:initUI()

	-- ExtendInfo:sendExtendTotalCountRequest()
	-- ExtendInfo:sendGetNeedLevelRequest()
	-- local ret, data = ExtendInfo:sendExtendDetailRequest(1)
	-- if ret == true then
	-- 	self:receiveExtendDetail(data)
	-- end

	PartnerInfo:sendGetPartnerInfoRequest();

	self.Image_zhancheng:setVisible(false);

	self.AtlasLabel_money:setString(goldConvert(0,1));

	self.bgkuang_zijin:getChildByName("TextField_set"):setVisible(false);
	self.bgkuang_zijin:getChildByName("Image_4"):setVisible(false);

	local Image_zhancheng = ccui.ImageView:create("newExtend/hehuoren/zhancheng.png");
	self.bgkuang_zijin:addChild(Image_zhancheng);
	Image_zhancheng:setPosition(self.Image_zhancheng:getPosition());

	luaPrint("最高可设置",SettlementInfo:getConfigInfoByID(31));

	Image_zhancheng.epath = "newExtend/hehuoren/zhanchengshurukuang.png"
	self.codeTextEdit = createEditBox(Image_zhancheng,"  最高可设置"..self.bit.."%",cc.EDITBOX_INPUT_MODE_DECIMAL,1)--输入框
    self.codeTextEdit :setPlaceholderFontSize(30)
    self.codeTextEdit:setPlaceholderFontColor(cc.c3b(77,77,77))
    self.codeTextEdit:setFontColor(cc.c3b(110,111,158));

     ----------------单局占成上限
    self.Image_danjushangxian:setVisible(false);
    self.bgkuang_zijin:getChildByName("TextField_limitSet"):setVisible(false);
	self.bgkuang_zijin:getChildByName("Image_4_0"):setVisible(false);
	
	local Image_limit = ccui.ImageView:create("newExtend/hehuoren/hehuoren_danju.png");
	self.bgkuang_zijin:addChild(Image_limit);
	Image_limit:setPosition(self.Image_danjushangxian:getPosition());

	Image_limit.epath = "newExtend/hehuoren/zhanchengshurukuang.png"
	self.limitTextEdit = createEditBox(Image_limit,"  输入上限金额",cc.EDITBOX_INPUT_MODE_DECIMAL,1)--输入框
    self.limitTextEdit :setPlaceholderFontSize(30)
    self.limitTextEdit:setPlaceholderFontColor(cc.c3b(77,77,77))
    self.limitTextEdit:setFontColor(cc.c3b(110,111,158));


	self.Button_close:onClick(function ()
		if self.isJump then
			self:delayCloseLayer(0,function()  showNoticeLayer() end)
		else
			dispatchEvent("registerLayerUpCallBack");
			self:delayCloseLayer();
		end
	end);

	self.Button_tgjc:setTag(1);
	self.Button_tgjc:onClick(function (sender)
		self:btnClick(sender);
	end)

	self.Button_msxq:setTag(2);
	self.Button_msxq:onClick(function (sender)
		self:btnClick(sender);
	end)

	self.Button_zjc:setTag(3);
	self.Button_zjc:onClick(function (sender)
		self:btnClick(sender);
	end)

	self.Button_timeSet:setEnabled(false);
	self.Button_timeSet:onClick(function (sender)
		--self:btnClick(sender);
		local layer = require("layer.popView.newExtend.hehuoren.SetTimeLayer"):create(self.data);
		display.getRunningScene():addChild(layer);
	end)

	self.Button_cunru:onClick(function ()
		luaPrint("Button_cunru",self.zijinMoney);
		local layer = require("layer.popView.newExtend.hehuoren.CunRuLayer"):create(1,self.zijinMoney);
		display.getRunningScene():addChild(layer);
	end);
	self.Button_quchu:onClick(function ()
		local layer = require("layer.popView.newExtend.hehuoren.CunRuLayer"):create(0,self.zijinMoney);
		display.getRunningScene():addChild(layer);
	end);
	self.Button_mingxi:onClick(function ()
		PartnerInfo:sendGetPartnerInfoRequest();
		local layer = require("layer.popView.newExtend.hehuoren.ZiJinDetail"):create();
		display.getRunningScene():addChild(layer);
	end);

	self.Button_fuzhi:onClick(function ()
		if copyToClipBoard(getQrUrl()) then
			addScrollMessage("推广地址复制成功")
		end
	end);

	self.Button_zanting:setVisible(true);
	self.Button_zanting:setTag(1);
	self.Button_zanting:onClick(function (sender)
		self:clickSend(sender);
	end);

	--self.Button_jihuo:setVisible(false);
	self.Button_jihuo:setTag(0);
	self.Button_jihuo:onClick(function (sender)
		-- local bit = tonumber(self.codeTextEdit:getText());
		-- PartnerInfo:sendGetOpenPartnerRequest(bit,0);
		self:clickSend(sender);
	end);

	self.Button_cancle:setVisible(false);
	self.Button_cancle:setTag(2);
	self.Button_cancle:onClick(function (sender)
		-- local bit = tonumber(self.codeTextEdit:getText());
		-- PartnerInfo:sendGetOpenPartnerRequest(bit,2);
		self:clickSend(sender);
	end);

	--二维码
	local tag = cc.UserDefault:getInstance():getIntegerForKey("saveExtend",1)
	local btn = ccui.Button:create()--ccui.Button:create("newExtend/hehuoren/extend/big"..tag..".png","newExtend/hehuoren/extend/big"..tag..".png")
	self.Image_fenxiang:setVisible(false);
	btn:setPosition(cc.p(self.Image_fenxiang:getPositionX(),self.Image_fenxiang:getPositionY()-170))
	btn:setScale(0.8)
	btn:setTag(1)
	self.bgkuang_tuiguang:addChild(btn)
	--btn:onClick(function(sender) self:onClickBtn(sender) end)
	self.saveExtendBtn = btn
	createExtendQr()--生成二维码

	local path = cc.FileUtils:getInstance():getWritablePath()..PlatformLogic.loginResult.dwUserID..".png"

	local qr = ccui.ImageView:create(path)
	qr:setPosition(btn:getContentSize().width/2,qr:getContentSize().width/2+80)
	self.saveExtendBtn:addChild(qr)


	--单局上限
	self.Panel_shuoming:setVisible(false);
	self.Panel_shuoming:setLocalZOrder(100);
	self.Button_help:onClick(function (sender)
		self.Panel_shuoming:setVisible(not self.Panel_shuoming:isVisible());
	end);

	self.Panel_shuoming:onClick(function (sender)
		self.Panel_shuoming:setVisible(faslse);
	end);


	--self.Text_cancleTime:setString("00:30:00");

	--self.AtlasLabel_money:setString("98568.25");

	self:updata(1);

end

function Partner:clickSend(sender)
	local tag = sender:getTag();

	local str = self.codeTextEdit:getText()
	local number = tonumber(str);

	if tag == 0 then
		if number == nil then
			addScrollMessage("输入有误！");
			return;
		end

		if number<= 0 then
			addScrollMessage("输入不可小于等于0！");
			return;
		end

		if number>self.bit then
			addScrollMessage("最高可设置"..self.bit.."%");
			return;
		end
	end
	
		local str2 = self.limitTextEdit:getText();
		--判断整数
		if string.find(str2,".",1,true) then
			addScrollMessage("单局上限占成输入非法！");
			return;
		end


		local limitNum = tonumber(str2);

		
		luaPrint("str2,limitNum:",str2,limitNum);
		if str2 == "" then
			limitNum = 0;
		end

		if type(limitNum) ~= "number" then
			addScrollMessage("单局上限占成输入有误！");
			return;
		end


		--判断整数
		if math.floor(limitNum) < limitNum then
			addScrollMessage("单局上限占成输入非法！");
			return;
		end

		if limitNum < 0 then
			addScrollMessage("单局上限占成不能小于0!");
			limitNum = 0;
			return;
		end

		--一百万 上限
		local tempNum = limitNum *100;
		if tempNum > 1000000 then
			addScrollMessage("单局上限占成金额过大!");
			limitNum = 0;
			return;
		end
	
	if tag == 1 then
		local prompt = GamePromptLayer:create();
    	prompt:showPrompt("暂停合伙人模式需要半小时后生效哦！");
    	prompt:setBtnClickCallBack(function (sender)
   			PartnerInfo:sendGetOpenPartnerRequest(number,limitNum,tag);
    	end);
    	return;
	end

	PartnerInfo:sendGetOpenPartnerRequest(number,limitNum,tag);

end

--二维码按钮
function Partner:onClickBtn()
	display.getRunningScene():addChild(require("layer.popView.newExtend.hehuoren.ExtendGameLayer"):create())
end

-- 1 开启 2 关闭
function Partner:startSchedule(_type)

	if _type == nil then
		_type = 1;
	end
	if _type == 2 then
		self:stopAction(self.schedule_Partner)
		self.schedule_Partner = nil;
		return;
	end
	-- self.time_h = 30;
	-- self.time_s = 0;
	if self.schedule_Partner then
		self:stopAction(self.schedule_Partner)
		self.schedule_Partner = nil;
	end
	self.schedule_Partner = schedule(self, function() 
		
		if self.time_s <= 0 then
			self.time_s = 60;
			self.time_h = self.time_h-1;
			if self.time_h<=0 then
				self.time_h = 0;
			end
		end

		self.time_s = self.time_s - 1;
		if self.time_s < 0 then
			self.time_s = 0;
		end

		luaPrint("startSchedule",self.time_h,self.time_s);
		self.Text_cancleTime:setString("00:"..self:timeChange(self.time_h)..":"..self:timeChange(self.time_s));

		if self.time_h == 0 and self.time_s == 0 then
			if self.schedule_Partner then
				self:stopAction(self.schedule_Partner);
				self.schedule_Partner = nil;
				self:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(
					function ()
						luaPrint("时间结束自动请求一下信息");
						PartnerInfo:sendGetPartnerInfoRequest();
					end
					)));
			end
		end

	end, 1.0)
end

--时间转化
function Partner:timeChange(time)
	local str = "";
	if type(time) == "string" then
		time = tonumber(time);
	end
	if time == nil then
		return;
	end
	if time == 0 then
		str = "00"
	elseif time<10 and time>0 then
		str = "0"..tostring(time);
	else
		str = tostring(time);
	end
	return str;
end


--按钮回调
function Partner:btnClick(sender)

	PartnerInfo:sendGetPartnerInfoRequest();
	
	local tag = sender:getTag();
	
	self:updata(tag);
	
end

function Partner:updata(tag)
	self.bgkuang_tuiguang:setVisible(tag == 2);
	self.bgkuang_moshi:setVisible(tag == 1);
	self.bgkuang_zijin:setVisible(tag == 3);

	self.Button_tgjc:setEnabled(tag ~= 1);
	self.Button_msxq:setEnabled(tag ~= 2);
	self.Button_zjc:setEnabled(tag ~= 3);
end

function Partner:receiveSaveExtend(data)
	local data = data._usedata

	self.saveExtendBtn:loadTextures("extend/big"..data..".png","extend/big"..data..".png")
end

function Partner:receiveExtendDetail(data)
	local data = data._usedata
	luaPrint("receiveExtendDetail");
	luaDump(data,"receiveExtendDetail");
	self.AtlasLabel_peopleNum:setString(ExtendInfo.extendTotalCount.UserCountB);
	self.AtlasLabel_zhancheng:setString(ExtendInfo.extendTotalCount.UserCountB);

end


--获取整数
function Partner:getNumStr(str)
	local num = tonumber(str);
	local num2 = math.floor(num);

	return tostring(num2);
end




function Partner:getNumPer(num,per)
	local numPer = num/per;
	if math.floor(numPer) == numPer then
		return numPer;
	else
		return tonumber(string.format("%.1f", numPer));
	end
end

return Partner;