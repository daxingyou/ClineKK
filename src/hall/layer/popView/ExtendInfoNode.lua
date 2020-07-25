local ExtendInfoNode = class("ExtendInfoNode",BaseNode)

function ExtendInfoNode:create(parent)
	return ExtendInfoNode.new(parent)
end

function ExtendInfoNode:ctor(parent)
	self.super.ctor(self)

	self.parent = parent

	self:bindEvent()

	self:initUI()
end

function ExtendInfoNode:bindEvent()
	self:pushEventInfo(ExtendInfo,"extendTotalCount",handler(self, self.receiveExtendTotalCount))
	self:pushEventInfo(ExtendInfo,"extendYesterdayDetail",handler(self, self.receiveExtendYesterdayDetail))
	-- self:pushEventInfo(ExtendInfo,"needLevelExp",handler(self, self.receiveNeedLevelExp))
	self:pushGlobalEventInfo("saveExtend",handler(self, self.receiveSaveExtend))
	self:pushGlobalEventInfo("accountUpSuccess",handler(self, self.receiveAccountUp))
	self:pushEventInfo(SettlementInfo, "configInfo", handler(self, self.receiveConfigInfo))
end

function ExtendInfoNode:initUI()
	local size = self.parent.size

	-- if showAccountUpgrade(false) then
	if false then
		SettlementInfo:sendConfigInfoRequest(6)
		local info = FontConfig.createWithSystemFont("亲爱的玩家，您现在是游客账号，无法成为推广员，赶快升级为",26,cc.c3b(255,0,0))
		info:setPosition(size.width*0.6-13,size.height*0.6)
		info:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		self:addChild(info)

		local info = FontConfig.createWithSystemFont("正式账号即可成为推广员！",26,cc.c3b(255,0,0))
		-- local info = FontConfig.createWithSystemFont("正式账号即可成为推广员，还能再获得6.00金币！",26,cc.c3b(255,0,0))
		info:setPosition(size.width*0.6-13,size.height*0.6-35)
		info:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		self:addChild(info)

		self.info = info
		if SettlementInfo:getConfigInfoByID(6) > 0 then
			info:setString("正式账号即可成为推广员，还能获得"..goldConvert(SettlementInfo:getConfigInfoByID(6),1).."金币！")
		end

		local btn = ccui.Button:create("login/accountUp.png","login/accountUp-on.png")
		btn:setPosition(size.width*0.6-13,size.height*0.3)
		btn:setTag(3)
		self:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)
	else
		self.info = nil
		-- --头像
		-- local headBg = cc.Sprite:create("userCenter/headBg.png")
		-- headBg:setPosition(size.width*0.5,size.height*0.7)
		-- self:addChild(headBg)

		-- local head = cc.Sprite:create("userCenter/head.png")
		-- head:setPosition(headBg:getContentSize().width/2,headBg:getContentSize().height/2)
		-- headBg:addChild(head)

		-- local node = createClipNode(head)
		-- local head = cc.Sprite:create(getHeadPath(PlatformLogic.loginResult.bLogoID))
		-- node:addChild(head)

		-- --昵称
		-- local nickNameText = FontConfig.createWithSystemFont("昵称: "..PlatformLogic.loginResult.nickName,28,cc.c3b(20,112,148))
		-- nickNameText:setPosition(size.width*0.5,size.height*0.55+10)
		-- self:addChild(nickNameText)

		-- --代理等级
		-- local lv = ccui.ImageView:create("extend/curLv.png")
		-- lv:setPosition(size.width*0.3,size.height*0.52)
		-- self:addChild(lv)

		-- if PlatformLogic.loginResult.AgencyLevel == 5 then
		-- 	lv:setPositionX(size.width*0.38)
		-- 	lv:setPositionY(lv:getPositionY()-20)
		-- end

		-- local lvMask = ccui.ImageView:create("extend/lvMask"..PlatformLogic.loginResult.AgencyLevel..".png")
		-- lvMask:setAnchorPoint(0,0.5)
		-- lvMask:setPosition(lv:getPositionX()+lv:getContentSize().width*0.5+10,lv:getPositionY()+2)
		-- self:addChild(lvMask)

		-- local lvNum = ccui.ImageView:create("extend/lv"..PlatformLogic.loginResult.AgencyLevel..".png")
		-- lvNum:setAnchorPoint(0,0.5)
		-- lvNum:setPosition(lvMask:getPositionX()+lvMask:getContentSize().width*0.5+20,lv:getPositionY())
		-- self:addChild(lvNum)

		-- local nextLv = PlatformLogic.loginResult.AgencyLevel+1

		-- if PlatformLogic.loginResult.AgencyLevel < 5 then
		-- 	local lv = ccui.ImageView:create("extend/nextLv.png")
		-- 	lv:setPosition(size.width*0.55,size.height*0.52)
		-- 	self:addChild(lv)

		-- 	local lvMask = ccui.ImageView:create("extend/lvMask"..nextLv..".png")
		-- 	lvMask:setAnchorPoint(0,0.5)
		-- 	lvMask:setPosition(lv:getPositionX()+lv:getContentSize().width*0.5+10,lv:getPositionY()+2)
		-- 	self:addChild(lvMask)

		-- 	local lvNum = ccui.ImageView:create("extend/lv"..nextLv..".png")
		-- 	lvNum:setAnchorPoint(0,0.5)
		-- 	lvNum:setPosition(lvMask:getPositionX()+lvMask:getContentSize().width*0.5+20,lv:getPositionY())
		-- 	self:addChild(lvNum)

		-- 	local expValue = {1000,21000,121000,1121000,11121000}
		-- 	local expValuer = {1000,20000,100000,1000000,10000000}

		-- 	--lv进度条
		-- 	local barBg = ccui.ImageView:create("extend/linebackground.png")
		-- 	barBg:setPosition(size.width/2,size.height*0.47)
		-- 	self:addChild(barBg)

		-- 	local cur = PlatformLogic.loginResult.Exper

		-- 	if PlatformLogic.loginResult.AgencyLevel > 0 then
		-- 		if ExtendInfo.needLevelExp[nextLv] then
		-- 			cur = PlatformLogic.loginResult.Exper - ExtendInfo.needLevelExp[nextLv-1].tempExp
		-- 			expValuer[nextLv] = ExtendInfo.needLevelExp[nextLv].needExp
		-- 		else
		-- 			cur = PlatformLogic.loginResult.Exper - expValue[nextLv-1]
		-- 		end
		-- 	end

		-- 	local loadingBar = ccui.LoadingBar:create("extend/line.png")
		-- 	loadingBar:setPosition(size.width/2,size.height*0.47)
		-- 	loadingBar:setPercent((cur/expValuer[nextLv])*100)
		-- 	self:addChild(loadingBar)
		-- 	self.loadingBar = loadingBar

		-- 	local lvText = FontConfig.createWithSystemFont(cur.."/"..expValuer[nextLv],28,cc.c3b(255,0,0))
		-- 	lvText:setPosition(size.width/2,size.height*0.47)
		-- 	self:addChild(lvText)
		-- 	self.lvText = lvText
		-- else--满级
		-- 	local manji = ccui.ImageView:create("extend/yimanji.png")
		-- 	manji:setAnchorPoint(0,0.5)
		-- 	manji:setPosition(lvNum:getPositionX()+lvNum:getContentSize().width+10,lvNum:getPositionY()+2)
		-- 	self:addChild(manji)
		-- end

		--推广介绍
		local image = ccui.ImageView:create("extend/extendContent.png")
		image:setAnchorPoint(0,0.5)
		image:setPosition(size.width*0.25-10,size.height*0.66)
		self:addChild(image)

		local image = ccui.ImageView:create("extend/line1.png")
		image:setAnchorPoint(0,0.5)
		image:setPosition(size.width*0.21,size.height*0.47)
		self:addChild(image)

		--已推广人数
		local image = ccui.ImageView:create("extend/yituiguang.png")
		image:setAnchorPoint(0,0.5)
		image:setPosition(size.width*0.25-10,size.height*0.42)
		self:addChild(image)

		local label = FontConfig.createWithSystemFont(0,28,cc.c3b(255,0,0))
		label:setAnchorPoint(0,0.5)
		label:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		label:setPosition(image:getContentSize().width+20,image:getContentSize().height/2)
		image:addChild(label)
		self.totalLabel = label

		if ExtendInfo.extendTotalCount.UserCountTotal ~= nil then
			label:setString(ExtendInfo.extendTotalCount.UserCountTotal)
		end

		--已推广好友昨日总税收
		local image = ccui.ImageView:create("extend/zongshuishou.png")
		image:setAnchorPoint(0,0.5)
		image:setPosition(size.width*0.25-10,size.height*0.37)
		self:addChild(image)

		local label = FontConfig.createWithSystemFont(0,28,cc.c3b(255,0,0))
		label:setAnchorPoint(0,0.5)
		label:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		label:setPosition(image:getContentSize().width+20,image:getContentSize().height/2)
		image:addChild(label)
		self.shuishouLabel = label

		if ExtendInfo.extendYesterdayDetail.shuishou ~= nil then
			label:setString(goldConvert(ExtendInfo.extendYesterdayDetail.shuishou))
		end

		--昨日税收总奖励
		local image = ccui.ImageView:create("extend/jianglizonger.png")
		image:setAnchorPoint(0,0.5)
		image:setPosition(size.width*0.25-10,size.height*0.32)
		self:addChild(image)

		local label = FontConfig.createWithSystemFont(0,28,cc.c3b(255,0,0))
		label:setAnchorPoint(0,0.5)
		label:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		label:setPosition(image:getContentSize().width+20,image:getContentSize().height/2)
		image:addChild(label)
		self.awardLabel = label

		if ExtendInfo.extendYesterdayDetail.award ~= nil then
			label:setString(goldConvert(ExtendInfo.extendYesterdayDetail.award))
		end

		local image = ccui.ImageView:create("extend/gengxin.png")
		image:setAnchorPoint(0,0.5)
		image:setPosition(size.width*0.25-10,size.height*0.27)
		self:addChild(image)

		local image = ccui.ImageView:create("extend/fengexian.png")
		image:setAnchorPoint(0,0.5)
		image:setPosition(size.width*0.25-40,size.height*0.24-2)
		self:addChild(image)

		local image = ccui.ImageView:create("extend/info.png")
		image:setAnchorPoint(0,0.5)
		image:setPosition(size.width*0.25-40,size.height*0.17)
		self:addChild(image)

		local btn = ccui.Button:create("extend/fuzhiwangzhi.png","extend/fuzhiwangzhi-on.png")
		btn:setPosition(size.width*0.85+30,size.height*0.15)
		btn:setTag(4)
		self:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)

		--游戏推广
		local tag = cc.UserDefault:getInstance():getIntegerForKey("saveExtend",1)
		local btn = ccui.Button:create("extend/big"..tag..".png","extend/big"..tag..".png")
		btn:setPosition(size.width*0.85+30,size.height*0.6+10)
		btn:setScale(0.3)
		btn:setTag(1)
		self:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)
		self.saveExtendBtn = btn

		createExtendQr()

		local path = cc.FileUtils:getInstance():getWritablePath()..PlatformLogic.loginResult.dwUserID..".png"

		local qr = ccui.ImageView:create(path)
		qr:setPosition(btn:getContentSize().width/2,qr:getContentSize().width/2+80)
		btn:addChild(qr)

		local btn = ccui.Button:create("extend/save.png","extend/save-on.png")
		btn:setPosition(size.width*0.85+30,size.height*0.3+5)
		btn:setTag(2)
		self:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)
	end
end

function ExtendInfoNode:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then
		display.getRunningScene():addChild(require("layer.popView.ExtendGameLayer"):create())
	elseif tag == 2 then
		local tag = cc.UserDefault:getInstance():getIntegerForKey("saveExtend",1)
		saveSystemPhoto(tag)
	elseif tag == 3 then--升级账号
		display.getRunningScene():addChild( require("layer.popView.RegisterLayer"):create())
	elseif tag == 4 then--复制官网
		if copyToClipBoard(globalUnit.tuiguanUrlQr) then
			addScrollMessage("推广地址复制成功")
		end
	end
end

function ExtendInfoNode:receiveExtendTotalCount(data)
	local data = data._usedata

	if self.totalLabel then
		self.totalLabel:setString(data.UserCountTotal)
	end
end

function ExtendInfoNode:receiveNeedLevelExp(data)
	local data = data._usedata

	if PlatformLogic.loginResult.AgencyLevel < 5 then
		local cur = PlatformLogic.loginResult.Exper
		local nextLv = PlatformLogic.loginResult.AgencyLevel + 1
		if PlatformLogic.loginResult.AgencyLevel > 0 then
			cur = PlatformLogic.loginResult.Exper - data[nextLv-1].tempExp
		end

		if self.loadingBar then
			self.loadingBar:setPercent((cur/data[nextLv].needExp)*100)
		end

		if self.lvText then
			self.lvText:setString(cur.."/"..data[nextLv].needExp)
		end
	end
end

function ExtendInfoNode:receiveExtendYesterdayDetail(data)
	local data = data._usedata

	if self.shuishouLabel then
		self.shuishouLabel:setString(goldConvert(data.shuishou))
	end

	if self.awardLabel then
		self.awardLabel:setString(goldConvert(data.award))
	end
end

function ExtendInfoNode:receiveSaveExtend(data)
	local data = data._usedata

	self.saveExtendBtn:loadTextures("extend/big"..data..".png","extend/big"..data..".png")
end

function ExtendInfoNode:receiveAccountUp(data)
	self:removeAllChildren()

	self:initUI()
end

function ExtendInfoNode:receiveConfigInfo(data)
	local data = data._usedata

	if data.id == 6 and self.info then
		if SettlementInfo:getConfigInfoByID(6) > 0 then
			self.info:setString("正式账号即可成为推广员，还能获得"..goldConvert(SettlementInfo:getConfigInfoByID(6),1).."金币！")
		else
			self.info:setString("正式账号即可成为推广员！")
		end
	end
end

return ExtendInfoNode
