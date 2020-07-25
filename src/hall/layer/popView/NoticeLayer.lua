local NoticeLayer = class("NoticeLayer",PopLayer)

function NoticeLayer:create(noticeKind)
	return NoticeLayer.new(noticeKind)
end

function NoticeLayer:ctor(noticeKind)
	self.super.ctor(self,PopType.none)

	self:initData(noticeKind)

	self:initUI()

	self:bindEvent()
end

function NoticeLayer:initData(noticeKind)
	self.noticeList = {}
	self.noticeTitleBtn = {}
	self.noticeBtn = {}
	self.noticeTypeData = {}
	if noticeKind then
		self.m_noticeKind = noticeKind; -- 2：公告 1：活动
	else
		self.m_noticeKind = 1; -- 2：公告 1：活动
	end
end

function NoticeLayer:bindEvent()
	self:pushGlobalEventInfo("noticeList",handler(self, self.receiveNoticeList))
	self:pushEventInfo(SettlementInfo,"configInfo",handler(self, self.receiveConfigInfo))
end

function NoticeLayer:onExit()
	self.super.onExit(self)
	LoadingLayer:removeLoading()
end

function NoticeLayer:initUI()
	self:removeBtn(0)
	self:setName("noticeLayer")

	local bg = ccui.ImageView:create("activity/notice/notice_bg.png")
	bg:setPosition(winSize.width/2,winSize.height/2)
	self:addChild(bg)
	self.bg = bg;

	-- if not checkIphoneX() then
	-- 	bg:setPositionX(bg:getPositionX()+50)
	-- end

	self.size = bg:getContentSize();

	--公告 or 活动 标签
	local imageTb = {
		[1] = "activity/notice/notice_huodong.png",	--活动
		[2] = "activity/notice/notice_gonggao.png",	--公告
	}
	local image_kind = ccui.ImageView:create(imageTb[self.m_noticeKind]);
	self.bg:addChild(image_kind);
	image_kind:setPosition(142,652);

	-- local title = ccui.ImageView:create("activity/notice/notice_biaoti.png")
	-- title:setPosition(275,self.size.height-49)
	-- self.bg:addChild(title)

	local closeBtn = ccui.Button:create("common/close.png","common/close-on.png")
	closeBtn:setPosition(1227,650);
	bg:addChild(closeBtn)
	closeBtn:onTouchClick(handler(self, self.onClickClose),1)

	-- local jinbi = ccui.ImageView:create("activity/notice/notice_zhuangshi1.png")
	-- jinbi:setPosition(self.size.width-35,50)
	-- self.bg:addChild(jinbi)
	-- jinbi:setVisible(false);

	local titleBg = ccui.ImageView:create("activity/notice/notice_anniudi.png")
	titleBg:setPosition(self.size.width/2 + 70,self.size.height-45)
	self.bg:addChild(titleBg)
	titleBg:setVisible(false);

	local titleBgSize = bg:getContentSize();

	local panel = ccui.Layout:create();
	panel:setContentSize(cc.size(418,62));
	panel:setPosition(480,610);
	self.bg:addChild(panel);
	panel:setVisible(false);

	local image_di = ccui.ImageView:create("activity/notice/notice_anniudi.png");
	panel:addChild(image_di);
	image_di:setPosition(209,31);

	local btn1 = ccui.Button:create("activity/notice/notice_remenhuodong1.png","activity/notice/notice_remenhuodong2.png","activity/notice/notice_remenhuodong2.png")
	btn1:setTag(1)
	panel:addChild(btn1)
	btn1:setPosition(110,20)
	table.insert(self.noticeTitleBtn,btn1)
	btn1:onClick(function(sender) self:onClickTitleBtn(sender) end)
	btn1:setEnabled(false)
	btn1:setTouchEnabled(false)

	local btn2 = ccui.Button:create("activity/notice/notice_youxigonggao1.png","activity/notice/notice_youxigonggao2.png","activity/notice/notice_youxigonggao2.png")
	btn2:setTag(2)
	panel:addChild(btn2)
	btn2:setPosition(304,20)
	table.insert(self.noticeTitleBtn,btn2)
	btn2:onClick(function(sender) self:onClickTitleBtn(sender) end)
	btn2:setTouchEnabled(false)

	self:requestNotice()
end

function NoticeLayer:requestNotice()
	if NoticeData == nil then
		LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求公告,请稍后"), LOADING):removeTimer(10)
		display.getRunningScene():getChildByTag(9999):removeTouch()
		local url = ""
		url = GameConfig:getWebNotice().."&userid="..PlatformLogic.loginResult.dwUserID
		url = url.."&agentid="..channelID
		luaPrint("请求公告的网址--"..url)
		HttpUtils:requestHttp(url,function(result, response) onHttpRequestNotice(result, response) end)
	else
		self:receiveNoticeList({_usedata=NoticeData})
	end
end

-- 公告请求结果
function onHttpRequestNotice(result, response)
	if result == false then
		luaPrint("http request cmd =  error")
	else
		if not isEmptyString(response) then
			local tb = json.decode(response)
			luaPrint("公告请求成功------------------------",tb)
			if tb and tb.State == 1 then
				luaDump(tb.Value)
				NoticeData = tb.Value
				dispatchEvent("noticeList",tb.Value)
				updateUserInfo()
				return
			end
		end
	end

	dispatchEvent("noticeList",false)
end

function updateUserInfo()
	if PlatformLogic and PlatformLogic.loginResult and PlatformLogic.loginResult.dwUserID and isUpdateUserInfo == nil then
		isUpdateUserInfo = true
		local url = GameConfig.tuiguanUrl.."/Public/PublicHandler.ashx?action=updateclientinfo&agentid="..channelID.."&userid="..tostring(PlatformLogic.loginResult.dwUserID).."&infostr="
		local param = pkgNum
		if isSDKSuccess == 0 then
			param = param.."_".."youxidun"
		elseif isSDKSuccess == 1 then
			param = param.."_".."chaojidun"
		else
			param = param.."_".."unknowdun"
		end

		local cv = getAppConfig("BundleVersionDate")

		if isEmptyString(cv) then
			cv = "0"
		end

		param = param.."_"..tostring(globalUnit.ip)
		param = param.."_"..tostring(globalUnit.city)
		param = param.."_"..tostring(onUnitedPlatformGetVersion())
		param = param.."_"..tostring(GameConfig:getLuaVersion(gameName))
		param = param.."_"..tostring(cv)
		param = param.."_"..tostring(GameConfig.md5Url)

		if device.platform == "android" then
			param = param.."_"..tostring(globalUnit.deviceMode)
		elseif device.platform == "ios" then
			local deviceVlaue = getDeviceByID(iosDeviceType.version)
			if not isEmptyString(deviceVlaue) then
				param = param.."_"..tostring(deviceVlaue)
			end
		end

		url = url..string.urlencode(param)

		HttpUtils:requestHttp(url,function(result, response)
			if result == true then
				luaPrint("updateclientinfo success")
			else
				luaPrint("updateclientinfo failed")
			end
		end)
	end
end

function NoticeLayer:receiveConfigInfo(data)
	local data = data._usedata
	luaDump(data,"NoticeLayer配置信息")
	if data.id == serverConfig.houtaiUrl then
		self:requestNotice()
	end
end

NoticeData = nil

function NoticeLayer:receiveNoticeList(data)
	local data = data._usedata
	if type(data) == "table" and data.data then
		local noticeData = data.data
		self.pngUrl = data.url
		--self:showNoticList()
		for k,v in pairs(self.noticeTitleBtn) do
			v:setTouchEnabled(true)
		end
		self:showNoticeType(noticeData);
		LoadingLayer:removeLoading()
	else
		if SettlementInfo:getConfigInfoByID(serverConfig.houtaiUrl) == 0 then
			SettlementInfo:sendConfigInfoRequest(serverConfig.houtaiUrl)
		end
	end
end

--创建热门活动和游戏公告界面
function NoticeLayer:showNoticeType(noticeData)
	self.noticeTypeData[1] = {};--热门活动
	self.noticeTypeData[2] = {};--游戏公告

	for _,data in pairs(noticeData) do
		if data.type == 2 then
			table.insert(self.noticeTypeData[1],data)
		else
			table.insert(self.noticeTypeData[2],data)
		end
	end

	-- self:onClickTitleBtn(self.noticeTitleBtn[1])
	self:onClickTitleBtn(self.noticeTitleBtn[self.m_noticeKind])
end

function NoticeLayer:onClickTitleBtn(sender)
	local tag = sender:getTag()
	if tag == 1 then
		self.noticeTitleBtn[1]:setEnabled(false);
		self.noticeTitleBtn[2]:setEnabled(true);
		self.noticeList = self.noticeTypeData[1];
		self:showNoticList(1)
	else
		self.noticeTitleBtn[1]:setEnabled(true);
		self.noticeTitleBtn[2]:setEnabled(false);
		self.noticeList = self.noticeTypeData[2];
		self:showNoticList(2)
	end
end

function NoticeLayer:showNoticList(tag)
	local node = self.bg:getChildByName("listView"..tag)
	if node then
		self.bg:removeChildByName("listView"..tag)
	end

	if self.listView then
		self.listView:removeAllChildren()
	end

	for k,v in pairs(self.noticeBtn) do
		if not tolua.isnull(v) then
			v:removeFromParent();
		end
	end

	self.noticeBtn = {};

	local size = self.size

	local x = self.size.width*0.12
	local h = 130

	-- if #self.noticeList > 1 then
		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0.5,0.5))
		listView:setDirection(ccui.ScrollViewDir.vertical)
		listView:setBounceEnabled(true)
		listView:setScrollBarEnabled(false)
		listView:setName("listView"..tag)
		listView:setContentSize(cc.size(260, 533))
		listView:setPosition(175,316)
		listView:setLocalZOrder(1)
		self.bg:addChild(listView)
		listView:setTouchEnabled(#self.noticeList > 5)

		local size = listView:getContentSize()
		for k,v in pairs(self.noticeList) do
			local layout = ccui.Layout:create()
			local btn = ccui.Button:create("activity/notice/anniu1-on.png","activity/notice/anniu1.png","activity/notice/anniu.png")
			btn:setTag(k)
			btn:setTitleText(v.Title)
			btn:setTitleFontSize(26)
			btn:setTitleFontName(FontConfig.gFontFile)
			btn:onClick(function(sender) self:onClickBtn(sender) end)
			table.insert(self.noticeBtn,btn)
			layout:setContentSize(cc.size(size.width,btn:getContentSize().height+10))
			btn:setPosition(size.width*0.5,btn:getContentSize().height/2-5)
			layout:addChild(btn)
			listView:pushBackCustomItem(layout)
		end
	-- else
	-- 	for k,v in pairs(self.noticeList) do
	-- 		local btn = ccui.Button:create("activity/notice/anniu1-on.png","activity/notice/anniu1.png","activity/notice/anniu.png")
	-- 		btn:setPosition(189,490-h*(k-1))
	-- 		btn:setTag(k)
	-- 		btn:setTitleText(v.Title)
	-- 		btn:setTitleFontSize(26)
	-- 		btn:setTitleFontName(FontConfig.gFontFile)
	-- 		self.bg:addChild(btn)
	-- 		btn:onClick(function(sender) self:onClickBtn(sender) end)

	-- 		table.insert(self.noticeBtn,btn)
	-- 	end
	-- end

	if #self.noticeList > 0 then
		self:onClickBtn(self.noticeBtn[1])
	end
end

function NoticeLayer:onClickBtn(sender)
	local tag = sender:getTag()
	for k,v in pairs(self.noticeBtn) do
		if k == tag then
			v:setEnabled(false)
			v:setTitleColor(cc.c3b(127,67,13))
			self:showNoticeContent(k)
			self.selectTag = tag
		else
			v:setEnabled(true)
			v:setTitleColor(cc.c3b(231,201,158))
		end
	end
end

function NoticeLayer:showNoticeContent(tag)
	if self.listView == nil then
		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0.5,0.5))
		listView:setDirection(ccui.ScrollViewDir.vertical)
		listView:setBounceEnabled(true)
		listView:setScrollBarEnabled(false)
		listView:setContentSize(cc.size(919, 542))
		listView:setPosition(773.5,321)
		self.bg:addChild(listView)
		self.listView = listView
		
	else
		self.listView:removeAllChildren()
		self.listView:scrollToPercentVertical(0,0.01,true)
	end

	local layout = ccui.Layout:create()

	local notice = self.noticeList[tag]

	local node = nil
	local ret = false

	if notice.NoteType == 1 then--image
		node,ret = self:createNoticeImage(tag)
	elseif notice.NoteType == 2 then--text
		node,ret = self:createNoticeText(notice)
	else
		if notice.Contents then
			node,ret = self:createNoticeText(notice)
		elseif notice.ImageSite then
			node,ret = self:createNoticeImage(tag)
		end
	end

	if node then
		if node:getContentSize().height > self.listView:getContentSize().height then
			layout:setContentSize(cc.size(self.listView:getContentSize().width, node:getContentSize().height))
			node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height/2)
		else
			layout:setContentSize(cc.size(self.listView:getContentSize().width, self.listView:getContentSize().height))
			node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height/2)
		end

		layout:addChild(node)

		local btn = ccui.Widget:create()
		btn:setContentSize(layout:getContentSize())
		btn:setAnchorPoint(cc.p(0.5,0.5))
		btn:setPosition(layout:getContentSize().width/2,layout:getContentSize().height/2)
		btn:setTouchEnabled(ret)
		layout:addChild(btn)
		btn:onClick(function(sender) self:onClick(sender) end)

		self.listView:pushBackCustomItem(layout)
	end
end

function NoticeLayer:onClick(sender)
	if not isEmptyString(self.noticeList[self.selectTag].url) then
		if string.len(self.noticeList[self.selectTag].url) > 5 then--打开网页
			openWeb(self.noticeList[self.selectTag].url)
		else--打开本地页面
			if tonumber(self.noticeList[self.selectTag].url) then
				local index = tonumber(self.noticeList[self.selectTag].url);
				if index == 1 then --签到界面
					showSign(1);
				elseif index == 2 then --首充
					createShop()
				elseif index == 3 then --幸运夺宝
					showLucky();
				end
			end
		end
	end
end

function NoticeLayer:createNoticeImage(tag)
	local notice = self.noticeList[tag]
	local path = notice.ImageSite

	if isEmptyString(path) then
		return
	end

	local image = nil
	local fullPath = cc.FileUtils:getInstance():getWritablePath().."notice/"..path
	--local fullPath = "activity/notice/"..path..".png"
	--noticePng[path] = true 
	luaPrint("图片的路径---",fullPath)

	if cc.FileUtils:getInstance():isFileExist(fullPath) and display.loadImage(fullPath) ~= nil then
		noticePng[path] = true
	end

	if noticePng[path] == true then
		image = ccui.ImageView:create(fullPath)
		if image:getContentSize().width > self.listView:getContentSize().width then
			image:setScaleX(self.listView:getContentSize().width/image:getContentSize().width)
		end

		if image:getContentSize().height > self.listView:getContentSize().height then
			-- image:setScaleY(self.listView:getContentSize().height/image:getContentSize().height)
		end
	else
		local url = self.pngUrl..path
		luaPrint("请求图片的路径---",url)
		createDir("notice")
		if not isEmptyString(NoticeData.domain) then
			url = string.gsub(url,NoticeData.domain,GameConfig.tuiguanUrl)
		end

		HttpUtils:downLoadFile(url,
			fullPath,
			function(result, savePath, response) downLoadNoticePng(tag, path, result, savePath, response) end)

		image = ccui.ImageView:create("common/black.png")
		image:setScale9Enabled(true)
		image:setContentSize(self.listView:getContentSize())

		local load = ccui.ImageView:create("common/loading.png")
		load:setPosition(image:getContentSize().width/2,image:getContentSize().height/2)
		image:addChild(load)

		local rep = cc.RepeatForever:create(cc.RotateBy:create(0.4,90))
		load:runAction(rep)
	end

	return image,noticePng[path] == true
end

noticePng = {}
function downLoadNoticePng(tag, path, result, savePath, response)
	if result == true then
		noticePng[path] = true
		local layer = display.getRunningScene():getChildByName("noticeLayer")

		if layer then
			if layer.selectTag == tag then
				layer:showNoticeContent(tag)
			end
		end
	end
end

function NoticeLayer:createNoticeText(notice)
	local text = FontConfig.createWithSystemFont(notice.Contents,26,cc.c3b(147, 155, 231))
	text:setAnchorPoint(0.5,0.5)
	text:setDimensions(820,0)
	if text:getStringNumLines() > 1 then
		text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	else
		text:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	end
	return text,true
end

function NoticeLayer:onClickClose(sender)
	self:delayCloseLayer(0,function() if isShowAccountUpgrade == nil then showBindPhone() end end)
end

return NoticeLayer