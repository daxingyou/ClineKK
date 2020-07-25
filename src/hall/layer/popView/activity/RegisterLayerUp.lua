

local RegisterLayerUp = class("RegisterLayerUp",PopLayer)

function RegisterLayerUp:create()
	return RegisterLayerUp.new()
end

function RegisterLayerUp:ctor()
	self.super.ctor(self,PopType.none)

	self.colorLayer:setOpacity(0);

	self:initData()

	self:initUI()

	self:bindEvent()
end

function RegisterLayerUp:initData()
	self.noticeList = {}
	self.noticeTitleBtn = {}
	self.noticeBtn = {}
	self.noticeTypeData = {}
	self.selectTag = 1;
end

function RegisterLayerUp:bindEvent()
	self:pushGlobalEventInfo("noticeLists",handler(self, self.receiveNoticeList))
	self:pushEventInfo(SettlementInfo,"configInfo",handler(self, self.receiveConfigInfo))
	self:pushGlobalEventInfo("registerLayerUpCallBack",handler(self, self.receiveCallBack))
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.onEnterForeground))
end

function RegisterLayerUp:receiveCallBack()
	
	--self.selectTag  = self.selectTag+1;

	luaPrint("receiveCallBack",self.selectTag,#self.noticeTypeData);

	if self.selectTag > #self.noticeTypeData then
		self:delayCloseLayer(0,function()  showNoticeLayer() end)
		return;
	else
		self:setVisible(true);
		-- if self.selectTag <= #self.noticeTypeData then
		-- 	self:createNoticeImage(self.selectTag);
		-- end
		self:setScale(0);
		local scaleTo = cc.ScaleTo:create(0.3, 1.0)
		self:runAction(scaleTo);
	end
	--self:onClickClose();
end

function RegisterLayerUp:onExit()
	self.super.onExit(self)
	LoadingLayer:removeLoading()
end

function RegisterLayerUp:initUI()
	self:removeBtn(0)
	self:setName("RegisterLayerUp")

	local size = cc.Director:getInstance():getWinSize();
	self.size = size;

	self.image = ccui.ImageView:create("");
	self:addChild(self.image);
	self.image:setPosition(size.width*0.5,size.height*0.5);

	local btn = ccui.Widget:create()
	btn:setContentSize(cc.Director:getInstance():getWinSize());
	self:addChild(btn);
	btn:setPosition(size.width*0.5,size.height*0.5);
	btn:onClick(function (sender)
		self:imageCallBack(sender);
	end);
	self.btn = btn;
	btn:setTouchEnabled(true)

	local closeBtn = ccui.Button:create("common/cha.png","common/cha-on.png")
	closeBtn:setPosition(self.size.width-36,self.size.height-57);
	self:addChild(closeBtn)
	closeBtn:onTouchClick(handler(self, self.onClickClose),1)
	closeBtn:setVisible(false);
	self.closeBtn = closeBtn;

	
	self:requestNotice()
end

function RegisterLayerUp:imageCallBack(sender)
	luaPrint("imageCallBack");
	if #self.noticeTypeData == 0 then
		self:delayCloseLayer(0,function()  showNoticeLayer() end)
		return;
	end

	local ret = false

	local number = self.noticeTypeData[self.selectTag].url
	number = tonumber(number);
	if number == 4 then--合伙人
		display.getRunningScene():addChild(require("layer.popView.newExtend.hehuoren.Partner"):create())
	elseif number == 5 then--手机绑定
		display.getRunningScene():addChild(require("layer.popView.RegisterLayer"):create())
	elseif number == 6 then--vip厅
		VipInfo:sendGetVipInfo()
	elseif number == 7 then--推广
		createGeneralizeLayer();
	elseif number == 8 then--签到
		showSign(1);
	elseif number == 9 then--幸运转盘
		showLucky();
	elseif number == 10 then--充值
		createShop()
	elseif number == 11 then--兑换
		display.getRunningScene():addChild(require("layer.popView.SettlementLayer"):create())
	elseif number == 12 then--余额宝
		showYuEBaoLayer();
	elseif number == nil and not isEmptyString(self.noticeTypeData[self.selectTag].url) then
		ret = true
	else
		--跳转url如果没有填写或者填写错误，直接跳下一张图片，最后一张直接关闭后弹公告
		if self.selectTag == #self.noticeTypeData then
			self:delayCloseLayer(0,function()  showNoticeLayer() end)
		else
			self:setVisible(false);
			self.selectTag = self.selectTag + 1;
			if self.selectTag <= #self.noticeTypeData then
				self:createNoticeImage(self.selectTag);
			end
			self:receiveCallBack();
		end
		return;
	end

	self:setVisible(false);
	self.selectTag  = self.selectTag+1;
	if self.selectTag <= #self.noticeTypeData then
		self:createNoticeImage(self.selectTag);
	end

	if ret then
		self.isUrlOpen = true
		openWeb(self.noticeTypeData[self.selectTag-1].url)
	end
end

function RegisterLayerUp:onClickClose()
	luaPrint("onClickClose",#self.noticeTypeData,self.selectTag);
	if self.selectTag>#self.noticeTypeData then
		self:delayCloseLayer(0,function()  showNoticeLayer() end)
		return;
	end
	if #self.noticeTypeData == self.selectTag then
		self:delayCloseLayer(0,function()  showNoticeLayer() end)
	else
		self.selectTag  = self.selectTag+1;
		self:createNoticeImage(self.selectTag);
		self:setScale(0);
		local scaleTo = cc.ScaleTo:create(0.3, 1.0)
		self:runAction(scaleTo);
	end
end

function RegisterLayerUp:onEnterForeground()
	if self.isUrlOpen then
		self.isUrlOpen = nil
		self:receiveCallBack();
	end
end

function RegisterLayerUp:requestNotice()
	luaPrint("requestNotice");
	if NoticeDatas == nil then
		--LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求图片,请稍后"), LOADING):removeTimer(10)
		--display.getRunningScene():getChildByTag(9999):removeTouch()
		local url = ""
		url = GameConfig.tuiguanUrl.."/public/PublicHandler.ashx?action=getPopupImageNote&".."userid="..PlatformLogic.loginResult.dwUserID
		--url = url.."&agentid="..channelID
		luaPrint("请求网址--"..url)
		HttpUtils:requestHttp(url,function(result, response) onHttpRequestNotices(result, response) end)
	else
		self:receiveNoticeList({_usedata=NoticeDatas})
	end
end

-- 请求结果
function onHttpRequestNotices(result, response)
	if result == false then
		luaPrint("http request cmd =  error")
		local layer = display.getRunningScene():getChildByName("RegisterLayerUp")
		if layer then
			layer.selectTag = #layer.noticeTypeData;
		end
		if SettlementInfo:getConfigInfoByID(serverConfig.houtaiUrl) ~= 0 then
			--addScrollMessage("图片获取失败");
		end
	else
		if not isEmptyString(response) then
			local tb = json.decode(response)
			luaDump(tb,"公告成功------------------------")
			if tb and tb.State == 1 then
				luaDump(tb.Value)
				NoticeDatas = tb.Value
				dispatchEvent("noticeLists",tb.Value)
				return
			end
		end
	end

	dispatchEvent("noticeLists",false)
end

function RegisterLayerUp:receiveConfigInfo(data)
	local data = data._usedata
	luaDump(data,"RegisterLayerUp配置信息")
	if data.id == serverConfig.houtaiUrl then
		self:requestNotice()
	end
end

NoticeDatas = nil

function RegisterLayerUp:receiveNoticeList(data)
	local data = data._usedata
	if type(data) == "table" and data.data then
		local noticeData = data.data
		self.pngUrl = data.url
		self:showNoticeType(noticeData);
		LoadingLayer:removeLoading()
		if #noticeData>0 then
			self.colorLayer:setOpacity(100);
		 	self.closeBtn:setVisible(true);
		else
		 	self:onClickClose();
		end
	else
		if SettlementInfo:getConfigInfoByID(serverConfig.houtaiUrl) == 0 then
			SettlementInfo:sendConfigInfoRequest(serverConfig.houtaiUrl)
		else
			self:onClickClose();
		end
	end
end

--创建热门活动和游戏公告界面
function RegisterLayerUp:showNoticeType(noticeData)
	self.noticeTypeData = {};

	for _,data in pairs(noticeData) do
		table.insert(self.noticeTypeData,data)
	end

	self:onClickTitleBtn(1)
end

function RegisterLayerUp:onClickTitleBtn(num)
	self:showNoticList(num)
end

function RegisterLayerUp:showNoticList(tag)
	self:onClickBtn(tag);
end

function RegisterLayerUp:onClickBtn(tag)
	self:showNoticeContent(tag)
end

function RegisterLayerUp:showNoticeContent(tag)
	self:createNoticeImage(tag)
end

function RegisterLayerUp:onClick(sender)
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

function RegisterLayerUp:createNoticeImage(tag)
	luaDump(self.noticeTypeData);

	if #self.noticeTypeData == 0 then
		-- self.image:loadTexture("activity/boss.png");
		-- self.image:ignoreContentAdaptWithSize(true);
		-- self.btn:setContentSize(self.image:getContentSize());
		return;
	end

	local notice = self.noticeTypeData[tag]
	luaDump(notice,"notice");
	local path = notice.ImageSite

	if isEmptyString(path) then
		return
	end

	local image = nil
	local fullPath = cc.FileUtils:getInstance():getWritablePath().."notice/"..path
	--local fullPath = "activity/notice/"..path..".png"
	--noticePngs[path] = true 
	luaPrint("图片的路径---",fullPath)

	if cc.FileUtils:getInstance():isFileExist(fullPath) and display.loadImage(fullPath) ~= nil then
		noticePngs[path] = true
	end

	if noticePngs[path] == true then
		self.image:loadTexture(fullPath);
		self.image:ignoreContentAdaptWithSize(true);
		self.btn:setContentSize(self.image:getContentSize());
	else
		local url = self.pngUrl..path
		luaPrint("请求图片的路径---",url)
		createDir("notice")

		HttpUtils:downLoadFile(url,
			fullPath,
			function(result, savePath, response) downLoadNoticePngs(tag, path, result, savePath, response) end)

		image = ccui.ImageView:create("common/black.png")
		image:setScale9Enabled(true)
		image:setContentSize(self.size)

		local load = ccui.ImageView:create("common/loading.png")
		load:setPosition(image:getContentSize().width/2,image:getContentSize().height/2)
		image:addChild(load)

		local rep = cc.RepeatForever:create(cc.RotateBy:create(0.4,90))
		load:runAction(rep)
	end

	-- return image,noticePngs[path] == true
end

noticePngs = {}
function downLoadNoticePngs(tag, path, result, savePath, response)
	if result == true then
		noticePngs[path] = true
		local layer = display.getRunningScene():getChildByName("RegisterLayerUp")

		if layer then
			if layer.selectTag == tag then
				layer:showNoticeContent(tag)
			end
		end
	end
end

return RegisterLayerUp