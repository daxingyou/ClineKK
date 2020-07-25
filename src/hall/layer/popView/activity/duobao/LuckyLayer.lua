local LuckyLayer = class("LuckyLayer", PopLayer)

function LuckyLayer:create(iType,iTag)
	return LuckyLayer.new(iType,iTag)
end

-- type 0为记录 1为抽奖
function LuckyLayer:ctor(iType,iTag)

	playEffect("hall/sound/luckyGuy.mp3")

	self.super.ctor(self,PopType.small)

	self.layerType = iType or 0
	self.iTag = iTag or 1

	self:initData()

	self:initUI()

	self:bindEvent()

	if self.layerType == 0 then
		LuckyInfo:sendLuckyOpenRequest()
	end
end

function LuckyLayer:initData()
	self.clickBtns = {}
	self.logBtn = {}
	self.logListView = nil
	self.centerX = 0
	self.selectLuckyTag = 1
	self.selectLog = 1

	self.textTable = {};
	self.textMsg = {};
end

function LuckyLayer:bindEvent()
	self:pushEventInfo(LuckyInfo,"luckyOpenInfo",handler(self, self.receiveLuckyOpenInfo))
	self:pushEventInfo(LuckyInfo,"luckyListInfo",handler(self, self.receiveLuckyListInfo))
	self:pushEventInfo(LuckyInfo,"luckyOtherResult",handler(self, self.receiveLuckyOtherResult))
	self:pushEventInfo(LuckyInfo,"luckyPointInfo",handler(self, self.receiveLuckyPointInfo))
end

function LuckyLayer:onExit()
	self.super.onExit(self)
	if self.layerType == 0 then
		LuckyInfo:sendLeaveLuckyRequest()
	end
end

function LuckyLayer:initUI()
	self:removeBtn(0)
	self:updateBg("activity/duobao/bg.png")
	self:updateCloseBtnImage("hall/fanhui.png","hall/fanhui-on.png")
	self.closeBtn:onTouchClick(function(sender) 
		dispatchEvent("registerLayerUpCallBack"); 
		self:onClickClose(sender) 
	end)
	self.closeBtn:setPosition((winSize.width-1280)/4+1230,self.closeBtn:getPositionY()+5)

	iphoneXFit(self.bg,1)

	self.size = self.bg:getContentSize()

	local pNode = cc.Node:create();
	pNode:setPosition((self.size.width-1280)/2,0);
	self.bg:addChild(pNode);
	self.pNode = pNode;

	local title = ccui.ImageView:create("activity/duobao/title.png")
	title:setAnchorPoint(0,0);
	title:setPosition(- (self.size.width-1280)/2,600)
	pNode:addChild(title,10)

	local tiao = ccui.ImageView:create("activity/duobao/tiao.png")
	tiao:setAnchorPoint(cc.p(0,0))
	tiao:setPosition(cc.p(- (self.size.width-1280)/2,0))
	pNode:addChild(tiao)

	if checkIphoneX() then
		self.closeBtn:setPositionX(winSize.width-safeX-self.closeBtn:getContentSize().width/2)
	end

	if self.layerType == 0 then
		self.logBg = ccui.ImageView:create("activity/duobao/logBg.png")
		self.logBg:setAnchorPoint(0,0.5)
		self.logBg:setPosition(290,self.size.height/2-20)
		pNode:addChild(self.logBg)

		--按钮底
		local logBgSize = self.logBg:getContentSize();
		local titleBg = ccui.ImageView:create("activity/duobao/logTitleBg.png")
		titleBg:setOpacity(0);
		titleBg:setPosition(logBgSize.width/2,logBgSize.height+20)
		self.logBg:addChild(titleBg)

		local titleBgSize = titleBg:getContentSize();
		local btn = ccui.Button:create("activity/duobao/dajiangjilu.png","activity/duobao/dajiangjilu-on.png","activity/duobao/dajiangjilu-dis.png")
		btn:setAnchorPoint(1,0.5);
		btn:setPosition(titleBgSize.width/2,titleBgSize.height/2-10);
		titleBg:addChild(btn)
		btn:setTag(1)
		btn:onClick(function(sender) self:onClickLog(sender) end)
		table.insert(self.logBtn,btn)
		btn:setEnabled(false)
		self.selectLog = btn:getTag()

		local btn2 = ccui.Button:create("activity/duobao/gerenjilu.png","activity/duobao/gerenjilu-on.png","activity/duobao/gerenjilu-dis.png")
		btn2:setAnchorPoint(0,0.5);
		btn2:setPosition(titleBgSize.width/2,titleBgSize.height/2-10);
		titleBg:addChild(btn2)
		btn2:setTag(2)
		btn2:onClick(function(sender) self:onClickLog(sender) end)
		table.insert(self.logBtn,btn2)

		local infoBg = ccui.ImageView:create("activity/duobao/infoBg.png")
		infoBg:setPosition(self.logBg:getPositionX()+self.logBg:getContentSize().width/2-10,0)
		infoBg:setAnchorPoint(0.5,0)
		pNode:addChild(infoBg)

		local size = self.logBg:getContentSize()

		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0,0))
		listView:setDirection(ccui.ScrollViewDir.vertical)
		listView:setBounceEnabled(true)
		listView:setContentSize(cc.size(817, 201))
		listView:setPosition(70,265)
		self.logBg:addChild(listView)
		self.logListView = listView

		local iconLabel = FontConfig.createWithSystemFont("当前积分:")
		iconLabel:setPosition(infoBg:getContentSize().width*0.1,15);
		iconLabel:setAnchorPoint(cc.p(0,0));
		infoBg:addChild(iconLabel);

		local iconLabel = FontConfig.createWithCharMap(0,"activity/duobao/zhuanpan/jifenNum.png",13,19,"+")
		iconLabel:setPosition(infoBg:getContentSize().width*0.25,15);
		iconLabel:setAnchorPoint(cc.p(0,0));
		iconLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		infoBg:addChild(iconLabel);
		self.pointLabel = iconLabel

		local iconLabel = FontConfig.createWithSystemFont("今日有效下注(明日积分):")
		iconLabel:setPosition(infoBg:getContentSize().width*0.5,15);
		iconLabel:setAnchorPoint(cc.p(0,0));
		infoBg:addChild(iconLabel);

		local iconLabel = FontConfig.createWithCharMap(0,"activity/duobao/zhuanpan/jifenNum.png",13,19,"+")
		iconLabel:setPosition(infoBg:getContentSize().width*0.8,15);
		iconLabel:setAnchorPoint(cc.p(0,0));
		iconLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		infoBg:addChild(iconLabel);
		self.pointtLabel = iconLabel

		local compass = ccui.Button:create("activity/duobao/zhuanpan/help.png");
		compass:setPosition(infoBg:getContentSize().width-10,0);
		compass:setAnchorPoint(0,0)
		infoBg:addChild(compass);
		compass:onTouchClick(function(sender) self:addChild(require("layer.popView.activity.duobao.HelpLayer"):create()) end)

		--添加标题到界面上
		local pos = {0,190,210,165};
		local posX = 230;

		for i = 1,4 do
			posX = posX+pos[i];
			local title = ccui.ImageView:create("activity/duobao/title"..i..".png")
			title:setPosition(posX,495)
			self.logBg:addChild(title)	
		end

	else
		self:refreshLuckyInfo()
	end
end

-- 创建左边轮盘和右边抽奖区
function LuckyLayer:refreshLuckyInfo()
	local size = self.bg:getContentSize()

	local x = self.size.width*0.1
	local h = 150

	if #self.clickBtns == 0 then
		local len = #LuckyInfo.luckyListInfo
		for i=1,len do
			local btn = ccui.Button:create("activity/duobao/lunpan"..LuckyInfo.luckyListInfo[i].kind.."-dis.png","activity/duobao/lunpan"..LuckyInfo.luckyListInfo[i].kind.."-on.png","activity/duobao/lunpan"..LuckyInfo.luckyListInfo[i].kind..".png")
			btn:setPosition(150 - (size.width-1280)/2,size.height*0.9-h-(btn:getContentSize().height*1.1)*(i-1))
			btn:setTag(i)
			self.pNode:addChild(btn)
			btn:onClick(function(sender) self:onClickBtn(sender) end)
			table.insert(self.clickBtns,btn)

			local iconLabel = FontConfig.createWithCharMap(goldConvert(LuckyInfo.luckyListInfo[i].needPoint).."积分","activity/duobao/lnum.png",18,30,"0",{{"积分",":;<"}})
			iconLabel:setPosition(btn:getContentSize().width/2,0);
			iconLabel:setAnchorPoint(cc.p(0.5,0));
			iconLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			btn:addChild(iconLabel);

			if self.layerType == 1 then
				btn:setEnabled(i ~= self.iTag)
			end
		end
	end

	if self.layerType == 1 then
		if not self:getChildByName("prize") then
			local node = require("layer.popView.activity.duobao.PrizeLayer"):create(self)
			node:setTag(self.iTag)
			node:setName("prize")
			self:addChild(node)
		else
			dispatchEvent("changePrize",self.iTag)
		end
	end
end

function LuckyLayer:receiveLuckyPointInfo(data)
	local data = data._usedata

	if self.pointLabel then
		self.pointLabel:setString(goldConvert(data.curPoint))
	end

	if self.pointtLabel then
		self.pointtLabel:setString(goldConvert(data.curNote))
	end
end

function LuckyLayer:refreshLuckyLog()
	if self.layerType ~= 0 then
		return
	end

	if self.logListView then
		self.logListView:removeSelf()
	end

	local size = self.logBg:getContentSize()

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0,0))
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setContentSize(cc.size(787, 206))
	listView:setPosition(130,270)
	listView:setScrollBarEnabled(false);
	self.logBg:addChild(listView)
	self.logListView = listView

	local data = LuckyInfo.luckyOpenInfo.bigAward
	if self.selectLog == 1 then
		
	elseif self.selectLog == 2 then
		data = LuckyInfo.luckyOpenInfo.selfAward
	end

	if data then
		local name = {"白银轮盘","黄金轮盘","钻石轮盘"}
		local size = self.logListView:getContentSize()
		for k,v in pairs(data) do
			if name[v.wheelKind] and v.awardMoney > 0 then
				local layout = ccui.Layout:create()
				layout:setContentSize(size.width,50)
				local size1 = layout:getContentSize()

				-- local draw = cc.DrawNode:create()
				-- draw:setAnchorPoint(0.5,0.5)
				-- draw:setName("draw");
				-- layout:addChild(draw, 1000)
				-- draw:drawRect(cc.p(0,0), cc.p(layout:getContentSize().width,layout:getContentSize().height), cc.c4f(1,1,0,1))
				-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))

				local info1 = FontConfig.createWithSystemFont(timeConvert(v.awardTime))
				info1:setPosition(100,size1.height/2)
				info1:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				info1:setAnchorPoint(0.5,0.5)
				layout:addChild(info1)

				local info2 = FontConfig.createWithSystemFont(FormotGameNickName(v.nickName,nickNameLen))
				info2:setPosition(info1:getPositionX()+190,size1.height/2)
				info2:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				info2:setAnchorPoint(0.5,0.5)
				layout:addChild(info2)

				local info3 = FontConfig.createWithSystemFont(name[v.wheelKind])
				info3:setPosition(info2:getPositionX()+210,size1.height/2)
				info3:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				info3:setAnchorPoint(0.5,0.5)
				layout:addChild(info3)

				local info4 = FontConfig.createWithSystemFont(goldConvert(v.awardMoney))
				info4:setPosition(info3:getPositionX()+165,size1.height/2)
				info4:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				info4:setAnchorPoint(0.5,0.5)
				layout:addChild(info4)

				self.logListView:pushBackCustomItem(layout)
			end
		end
	end

	local layout = self.logBg:getChildByName("layout");

	if not layout and LuckyInfo.luckyOpenInfo.smallAward then
		for i = 1,#LuckyInfo.luckyOpenInfo.smallAward do
			self:SetPlayerInfo(LuckyInfo.luckyOpenInfo.smallAward[i]);
		end
	end
end

function LuckyLayer:onClickBtn(sender)
	local tag = sender:getTag()

	if self.layerType == 0 then
		local layer = require("layer.popView.activity.duobao.LuckyLayer"):create(1,tag)
		self:addChild(layer)
	else
		for k,v in pairs(self.clickBtns) do
			v:setEnabled(tag~=v:getTag())
		end

		self.selectLuckyTag = tag
		self.iTag = tag

		if #LuckyInfo.luckyListInfo > 0 then
			self:refreshLuckyInfo()
		else
			LuckyInfo:sendLuckyWheelRequest()
		end
	end
end

function LuckyLayer:onClickLog(sender)
	local tag = sender:getTag()

	for k,v in pairs(self.logBtn) do
		v:setEnabled(v:getTag()~=tag)
	end

	self.selectLog = tag

	self:refreshLuckyLog()
end

function LuckyLayer:receiveLuckyOpenInfo(data)
	self:refreshLuckyLog()
end

function LuckyLayer:receiveLuckyListInfo(data)
	self:refreshLuckyInfo()
end

local maxLen = 4;
local moveSpeed = 100;
local textHeight = 38;

function LuckyLayer:receiveLuckyOtherResult(data)
	if self.layerType ~= 0 then
		return
	end

	local data = data._usedata
	self:SetPlayerInfo(data);
	-- LuckyInfo:sendLuckyOpenRequest()
end

function LuckyLayer:SetPlayerInfo(info)
	if info.awardMoney == 0 or info.nickName == "" then
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
function LuckyLayer:PlayPlayerInfo(info)
	--先布满4条数据 第五条备用
	local size = self.logBg:getContentSize()
	local layout = self.logBg:getChildByName("layout");

	if layout == nil then
		layout = ccui.Layout:create()
		layout:setContentSize(787,152);
		layout:setAnchorPoint(0,0);
		layout:setPosition(130,95);
		layout:setName("layout");
		self.logBg:addChild(layout)
		layout:setClippingEnabled(true)
	end

	local name = {"白银轮盘","黄金轮盘","钻石轮盘"}

	if #self.textTable<maxLen+1 then
		if name[info.wheelKind] then
			local pNode = cc.Node:create();
			pNode:setPosition(5,((maxLen-1)-#self.textTable)*textHeight+10);
			layout:addChild(pNode);

			table.insert(self.textTable,pNode);

			local fontSize = 21;
			local textColor = cc.c3b(255,255,0);

			local str1 = ccui.Text:create();
			str1:setFontSize(fontSize);
			str1:setAnchorPoint(cc.p(0,0));
			str1:setString("恭喜【");
			str1:setPosition(20,0);
			pNode:addChild(str1);
			str1:setColor(textColor);

			local str2 = ccui.Text:create();
			str2:setFontSize(fontSize);
			str2:setAnchorPoint(cc.p(0,0));
			str2:setString(FormotGameNickName(info.nickName,nickNameLen).."】在"..name[info.wheelKind].."中得");
			str2:setPosition(str1:getPositionX()+str1:getContentSize().width,0);
			str2:setColor(textColor);
			str2:setName("nickName");
			pNode:addChild(str2);

			local str4 = ccui.Text:create();
			str4:setFontSize(fontSize);
			str4:setAnchorPoint(cc.p(0.5,0));
			str4:setString(goldConvert(info.awardMoney));
			str4:setPosition(layout:getContentSize().width*0.85,0);
			str4:setColor(cc.c3b(255,206,87));

			str4:setName("moneyGet");
			pNode:addChild(str4);
		end
	end

	--数组大于4创建移动的动画
	if #self.textTable>maxLen then
		if name[info.wheelKind] then
			local textNode = self.textTable[maxLen+1];
			local msg = self.textMsg[maxLen+1];
			local nickName = textNode:getChildByName("nickName");
			local moneyGet = textNode:getChildByName("moneyGet");

			--设置数据
			nickName:setString(FormotGameNickName(info.nickName,nickNameLen).."】在"..name[info.wheelKind].."中得");
			moneyGet:setString(goldConvert(msg.awardMoney));

			--重置位置
			-- moneyGet:setPositionX(layout:getContentSize().width-80);

			for k,v in pairs(self.textTable) do
				--目标位置比原来多一个height
				local movePos = cc.p(v:getPositionX(),textHeight*(maxLen+1-k)+10);

				local moveAction = cc.MoveTo:create((movePos.y-v:getPositionY())/moveSpeed,movePos);
				--先放置一段时间再移动到目标位置
				v:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),moveAction,cc.CallFunc:create(function()
					if k == 1 then
						--移除数据
						table.remove(self.textMsg,1);

						--将node放到最后循环使用
						table.removebyvalue(self.textTable,v);
						table.insert(self.textTable,v);
						v:setPositionY((maxLen-#self.textTable)*textHeight+10);

						--如果大于4 继续播放
						if #self.textMsg > maxLen then
							self:PlayPlayerInfo(self.textMsg[maxLen+1]);
						end
					end
				end)))
			end
		end
	end
end

return LuckyLayer
