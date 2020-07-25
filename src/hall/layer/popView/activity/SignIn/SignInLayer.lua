local SignInLayer = class("SignInLayer", PopLayer)

local maxLen = 4;
local moveSpeed = 100;
local textHeight = 30;

local statusPos = {
	cc.p(81,106),
	cc.p(34,136)
};

function SignInLayer:ctor()
	playEffect("hall/sound/sign.mp3")
	self.super.ctor(self,PopType.none);

	cc.FileUtils:getInstance():addSearchPath("res/hall/activity/SignIn",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/hall/activity/SignIn",true)
	end

	local uiTable = {
		Button_close = "Button_close",
		Node_1 = "Node_1",
		Node_2 = "Node_2",
		Node_3 = "Node_3",
		Node_4 = "Node_4",
		Node_5 = "Node_5",
		Node_6 = "Node_6",
		Node_7 = "Node_7",
		Node_qiandao = "Node_qiandao",
		Panel_list = "Panel_list",
		Node_animate = "Node_animate";
	}

	self:bindEvent();

	self:initData();

	loadNewCsb(self,"hall/activity/SignIn/qiandao",uiTable);

	self.xBg = self.csbNode;

	self:initUI()
end

function SignInLayer:bindEvent()
	self:pushEventInfo(SignInInfo,"SignWeekOpen",handler(self, self.DealSignWeekOpen))
	self:pushEventInfo(SignInInfo,"SignWeekSignIn",handler(self, self.DealSignWeekSignIn))
	self:pushEventInfo(SignInInfo,"SignWeekRecord",handler(self, self.DealSignRecordElem))
	self:pushEventInfo(SignInInfo,"SignWeekRecordTol",handler(self, self.DealSignWeekRecordTol))
end

--进入
function SignInLayer:onEnter()

	self.super.onEnter(self);

	PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_OPEN);
end

--退出
function SignInLayer:onExit()
	self.super.onExit(self);

	PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_CLOSE);
end



function SignInLayer:initData()
	self.qiandao = 0;
	self.textTable = {};
	self.textMsg = {};
	self.m_recvCount = 0;
end

function SignInLayer:initUI()
	--设置关闭按钮回调
	if self.Button_close then
		self.Button_close:onTouchClick(handler(self, self.onClickClose),1)
	end

	local qiandaoBtn = self.Node_qiandao:getChildByName("Button_dayBg");
	if qiandaoBtn then
		qiandaoBtn:onClick(handler(self,self.SignInClick))
	end
end

function SignInLayer:SignInClick(sender)
	--收到2条消息才可以点击
	if self.m_recvCount >= 2 then
		PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_SIGNIN);
	else
		addScrollMessage("请稍后再试");
	end
end

--打开签到界面  -1 不可签到 1 已签到
function SignInLayer:DealSignWeekOpen(data)
	local msg = data._usedata;

	cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/activity/SignIn/qiandao.plist");

	--记录签到的日期	
	self.qiandao = msg.DayCount;

	--更改签到状态标志
	for k,v in pairs(msg.SignState) do
		local node = self["Node_"..k];
		local signBg = node:getChildByName("Image_dayBg");
		local statusSp = node:getChildByName("Image_status");

		if k < self.qiandao or (k == self.qiandao and v == 1) then--时间过了的签到和 今天已签到
			signBg:loadTexture("qiandaodi"..k.."-on.png",UI_TEX_TYPE_PLIST);
			--设置签到状态
			if v == -1 then
				statusSp:setVisible(true);
				statusSp:loadTexture("qiandao_weiqiandao.png",UI_TEX_TYPE_PLIST);
				statusSp:ignoreContentAdaptWithSize(true);
				statusSp:setPosition(statusPos[2]);
			elseif v == 1 then
				statusSp:setVisible(true);
				statusSp:loadTexture("qiandao_yiqiandao.png",UI_TEX_TYPE_PLIST);
				statusSp:ignoreContentAdaptWithSize(true);
				statusSp:setPosition(statusPos[1]);
			end

		elseif k == self.qiandao and v ~= 1 then
			statusSp:setVisible(true);
			statusSp:loadTexture("qiandao_daiqiandao.png",UI_TEX_TYPE_PLIST);
			statusSp:ignoreContentAdaptWithSize(true);
			statusSp:setPosition(statusPos[2]);

			signBg:loadTexture("qiandaodi"..k..".png",UI_TEX_TYPE_PLIST);
		else--还原
			statusSp:setVisible(false);
			signBg:loadTexture("qiandaodi"..k..".png",UI_TEX_TYPE_PLIST);
		end
	end

	--更改签到信息 已签到的话将签到按钮无法点击
	local qiandaoBtn = self.Node_qiandao:getChildByName("Button_dayBg");
	if msg.SignState[self.qiandao] == 1 then--已经签到了设置灰色
		qiandaoBtn:loadTextures("dianjiqiandao.png","dianjiqiandao-on.png","dianjiqiandaojinyong.png",UI_TEX_TYPE_PLIST);
		qiandaoBtn:setEnabled(false);
	-- elseif msg.SignState[self.qiandao] == -1 then
	-- 	qiandaoBtn:setEnabled(false);
	else
		qiandaoBtn:loadTextures("dianjiqiandao.png","dianjiqiandao-on.png","dianjiqiandaojinyong.png",UI_TEX_TYPE_PLIST);
		qiandaoBtn:setEnabled(true);
	end

	self.m_recvCount = self.m_recvCount+1;
end

--总签到
function SignInLayer:DealSignWeekRecordTol(data)
	local msg = data._usedata;

	for i = #msg.SignRecord,1,-1 do
		self:SetPlayerInfo(msg.SignRecord[i]);
	end

	self.m_recvCount = self.m_recvCount+1;
end

--签到
function SignInLayer:DealSignWeekSignIn(data)
	local msg = data._usedata;

	cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/activity/SignIn/qiandao.plist");

	if self.qiandao>0 then
		local node = self["Node_"..self.qiandao];
		local signBg = node:getChildByName("Image_dayBg");
		local statusSp = node:getChildByName("Image_status");

		signBg:loadTexture("qiandaodi"..self.qiandao.."-on.png",UI_TEX_TYPE_PLIST);

		statusSp:setVisible(true);--设置成已签到
		statusSp:loadTexture("qiandao_yiqiandao.png",UI_TEX_TYPE_PLIST);
		statusSp:ignoreContentAdaptWithSize(true);
		statusSp:setPosition(statusPos[1]);

		--将签到按钮无法点击
		local qiandaoBtn = self.Node_qiandao:getChildByName("Button_dayBg");
		qiandaoBtn:setEnabled(false);


		--如果有奖励界面则将奖励界面移除
		local layer = self.Node_animate:getChildByName("gongxihuode");
		if layer then
			layer:removeFromParent();
		end

		--创建签到奖励动画显示
		local animatePath = "hall/activity/SignIn/gongxihuode.";

		local skeleton_animation = createSkeletonAnimation("gongxihuode",animatePath.."json",animatePath.."atlas");
    	if skeleton_animation then
        	self.Node_animate:addChild(skeleton_animation);
        	skeleton_animation:setAnimation(0,"gongxihuode", false);
        	skeleton_animation:setPosition(640,360);
        	skeleton_animation:setName("gongxihuode");
        	self.Node_animate:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        		--创建
        		cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/activity/SignIn/qiandao.plist");
		        local qianSp;
		        if self.qiandao < 7 then
		        	qianSp = cc.Sprite:createWithSpriteFrameName("qiandao_tubiao1.png");
		    	else
		    		qianSp = cc.Sprite:createWithSpriteFrameName("qiandao_tubiao2.png");
		    	end
		    	qianSp:setPosition(640,360);
		    	self.Node_animate:addChild(qianSp);

		    	local money = FontConfig.createWithCharMap(goldConvert(msg.moneyGet)..":;<=","hall/activity/SignIn/hdnum.png", 42, 68, '+');
			    money:setPosition(640,230);
			    self.Node_animate:addChild(money);
        	end),cc.DelayTime:create(3),cc.CallFunc:create(function()
        		self.Node_animate:removeAllChildren();
        	end)));
        end
        dispatchEvent("refreshScoreBank")

	end

end

--广播的签到信息
function SignInLayer:DealSignRecordElem(data)
	local msg = data._usedata;

	self:SetPlayerInfo(msg);
end

function SignInLayer:SetPlayerInfo(info)
	if info.moneyGet == 0 or info.nickName == "" then
		return;
	end

	table.insert(self.textMsg,info);

	--如果保存的数据大于5条则会自动调用
	if #self.textMsg>maxLen+1 then
		return;
	end

	self:PlayPlayerInfo(info);
end


--创建滚动字条
function SignInLayer:PlayPlayerInfo(info)
	--先布满4条数据 第五条备用
	if #self.textTable<maxLen+1 then
		local pNode = cc.Node:create();
		pNode:setPosition(5,((maxLen-1)-#self.textTable)*textHeight);
		self.Panel_list:addChild(pNode);

		table.insert(self.textTable,pNode);

		local fontSize = 20;

		local str1 = ccui.Text:create();
		str1:setFontSize(fontSize);
		str1:setAnchorPoint(cc.p(0,0));
		str1:setString("恭喜【");
		str1:setPosition(0,0);
		pNode:addChild(str1);

		local str2 = ccui.Text:create();
		str2:setFontSize(fontSize);
		str2:setAnchorPoint(cc.p(0,0));
		str2:setString(FormotGameNickName(info.nickName,nickNameLen).."】在连续签到中心开出");
		str2:setPosition(str1:getPositionX()+str1:getContentSize().width,0);

		str2:setName("nickName");
		pNode:addChild(str2);


		local str4 = ccui.Text:create();
		str4:setFontSize(fontSize);
		str4:setAnchorPoint(cc.p(0,0));
		str4:setString(goldConvert(info.moneyGet).."金币");
		str4:setPosition(str2:getPositionX()+str2:getContentSize().width,0);
		str4:setColor(cc.c3b(226,228,50));

		str4:setName("moneyGet");
		pNode:addChild(str4);


		local str6 = ccui.Text:create();
		str6:setFontSize(fontSize);
		str6:setAnchorPoint(cc.p(0,0));
		str6:setString("大奖");
		str6:setPosition(str4:getPositionX()+str4:getContentSize().width,0);

		str6:setName("lastStr")
		pNode:addChild(str6);
	end

	--数组大于4创建移动的动画
	if #self.textTable>maxLen then
		local textNode = self.textTable[maxLen+1];
		local msg = self.textMsg[maxLen+1];
		local nickName = textNode:getChildByName("nickName");
		local moneyGet = textNode:getChildByName("moneyGet");
		local lastStr = textNode:getChildByName("lastStr");

		--设置数据
		nickName:setString(FormotGameNickName(msg.nickName,nickNameLen).."】在连续签到中心开出");
		moneyGet:setString(goldConvert(msg.moneyGet).."金币");

		--重置位置
		moneyGet:setPositionX(nickName:getPositionX()+nickName:getContentSize().width);
		lastStr:setPositionX(moneyGet:getPositionX()+moneyGet:getContentSize().width);

		for k,v in pairs(self.textTable) do
			--目标位置比原来多一个height
			local movePos = cc.p(v:getPositionX(),textHeight*(maxLen+1-k));

			local moveAction = cc.MoveTo:create((movePos.y-v:getPositionY())/moveSpeed,movePos);
			--先放置一段时间再移动到目标位置
			v:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),moveAction,cc.CallFunc:create(function()
				if k == 1 then
					--移除数据
					table.remove(self.textMsg,1);

					--将node放到最后循环使用
					table.removebyvalue(self.textTable,v);
					table.insert(self.textTable,v);
					v:setPositionY((maxLen-#self.textTable)*textHeight);

					--如果大于4 继续播放
					if #self.textMsg > maxLen then
						self:PlayPlayerInfo(self.textMsg[maxLen+1]);
					end
				end
			end)))
		end
	end
end

function SignInLayer:onClickClose(sender)
	dispatchEvent("registerLayerUpCallBack");
	self:delayCloseLayer();
	--self:delayCloseLayer(0,function() if isShowAccountUpgrade == nil then display.getRunningScene():addChild(require("layer.popView.NoticeLayer"):create()) end end)
end

return SignInLayer


