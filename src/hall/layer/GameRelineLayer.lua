-- 断线重连界面
local GameRelineLayer = class("GameRelineLayer", BaseWindow)

function GameRelineLayer:create(callback)
	return GameRelineLayer.new(callback);
end

function GameRelineLayer:ctor(callback)
	self.super.ctor(self, true,true,nil,nil)
	self.callback = callback;
	globalUnit.m_connectCount = 0;--重连次数

	LoadingLayer:removeLoading()

	self:updateLayerOpacity(0)

	local width = cc.Director:getInstance():getWinSize().width;
	local height = cc.Director:getInstance():getWinSize().height;

	-- local animation= cc.Animation:create()
	-- for i=1,14 do
	-- 	animation:addSpriteFrameWithFile("hall/loading"..i..".png")
	-- end
	-- animation:setDelayPerUnit(2/14)
	-- animation:setRestoreOriginalFrame(true)
	-- local action = cc.Animate:create(animation)

	local image = cc.Sprite:create("common/loading1.png")
	image:setPosition(getScreenCenter())
	self:addChild(image)
	self.image = image
	image:hide()
	-- image:runAction(cc.RepeatForever:create(action))

	local label = FontConfig.createLabel(FontConfig.gFontConfig_22, "", FontConfig.colorWhite);
	label:setPosition(image:getContentSize().width/2,image:getContentSize().height/2);
	image:addChild(label);
	self.label = label

	self:bindEvent()
end

function GameRelineLayer:bindEvent()
    self:pushGlobalEventInfo("onPlatformLoginCallback", handler(self, self.onPlatformLoginCallback))
end

function GameRelineLayer:onExit()
	self.super.onExit(self);

	self:stopAllActions();

	GameDate:loginend();

	if self.callback then
		self.callback();
	end
end

function GameRelineLayer:onPlatformLoginCallback(data)
	local data = data._usedata

	if data[1] == true then
		self:updateForloginPlatform()
		dispatchEvent("requestGameList")
	end
end

function GameRelineLayer:sureReline()
	globalUnit.m_connectCount = 0;
	globalUnit.m_gameConnectState = STATE.STATE_CONNECTING;
	self:updateForlogin();
	if isUseNetSDK then
		schedule(self, function() self:updateForlogin(); end, 3)
	else
		schedule(self, function() self:updateForlogin(); end, 3)
	end
end

-- //重连大厅
function GameRelineLayer:sureRelinePlatform()
	globalUnit.m_connectCount = 0;
	globalUnit.m_gameConnectState = STATE.PLATFORM_STATE_CONNECTING;
	luaPrint("sureRelinePlatform  globalUnit.m_gameConnectState  "..globalUnit.m_gameConnectState)
	self:updateForloginPlatform();
	if isUseNetSDK then
		schedule(self, function() self:updateForloginPlatform(); end, 3)
	else
		schedule(self, function() self:updateForloginPlatform(); end, 3)
	end
end

function GameRelineLayer:updateForlogin()
	if globalUnit.m_gameConnectState == STATE.STATE_OVER then
		-- //已经成功重连,销毁该节点
		globalUnit.m_connectCount = 0;
		self:delayCloseLayer(0);
		return;
	end

	if globalUnit.m_connectCount > globalUnit.m_reConnectMaxCount then
		luaPrint("游戏网络连接不上")
		RoomLogic:close()
		self:delayCloseLayer(0);
		globalUnit.m_connectCount = 0;
		Hall:exitGame(nil,function() globalUnit.isEnterGame = false end)
		return;
	end

	GameDate:login();

	globalUnit.m_connectCount = globalUnit.m_connectCount + 1;
	local str = "正在重新加载网络……"--"第"..globalUnit.m_connectCount.."次重新连接,请稍后";
	luaPrint("globalUnit.m_connectCount   --------  "..globalUnit.m_connectCount)
	if self.label then
		self.label:setString(str)
	end

	if globalUnit.m_connectCount > 2 then
		self.image:show()
	end
end

-- //大厅重连
function GameRelineLayer:updateForloginPlatform()
	luaPrint("globalUnit.m_gameConnectState   ***********   "..globalUnit.m_gameConnectState)
	if globalUnit.m_gameConnectState == STATE.STATE_OVER then
		-- //已经成功重连,销毁该节点
		globalUnit.m_connectCount = 0;
		dispatchEvent("loginRoom")
		luaPrint("1111111------------")
		self:delayCloseLayer(0);
		return;
	end

	if globalUnit.m_connectCount > globalUnit.m_reConnectMaxCount then
		luaPrint("222222222222------------")
		Hall.exitHall()
		return;
	end

	GameDate:platformLogin();

	globalUnit.m_connectCount = globalUnit.m_connectCount + 1;

	local str = "正在重新加载网络……"--"第"..globalUnit.m_connectCount.."次重新连接,请稍后";
	luaPrint("globalUnit.m_connectCount   ---*********-----  "..globalUnit.m_connectCount)
	if self.label then
		self.label:setString(str)
	end

	if globalUnit.m_connectCount > 2 then
		self.image:show()
	end
end

return GameRelineLayer
