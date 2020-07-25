local TableLayer =  class("TableLayer", BaseWindow)

local TableLogic = require("likuipiyu.game.TableLogic");
local ResultLayer = require("likuipiyu.game.ResultLayer");
local HelpLayer = require("likuipiyu.popView.HelpLayer");

--捕鱼
FishManager = require("likuipiyu.game.core.FishManager"):getInstance();
local FishGroup = require("likuipiyu.game.core.FishGroup"):getInstance();
local FishMatrix = require("likuipiyu.game.core.FishMatrix"):getInstance();
local DataCacheManager = require("likuipiyu.game.core.DataCacheManager"):getInstance();
local FishPath = require("likuipiyu.game.core.FishPath"):getInstance();

local button_zorder = 200;
local _instance = nil;

local btnEnable = 10;
local btnDisenable = 11;

--离线语音按钮图片  安装说话的
local voiceMessageNormalDisenableImage = "game/table/lixianyuyin.png";--关
local voiceMessagePressDisenableImage = "game/table/lixianyuyin-on.png";

local voiceMessageNormalImage = "game/table/yuyin.png";--开
local voiceMessagePressImage = "game/table/yuyin-on.png";

--实时语音
local voiceRealTimeNormalImage = "game/table/yuyin/yuyinkaiqi.png";--开
local voiceRealTimePressImage = "game/table/yuyin/yuyinkaiqi-on.png";

local voiceRealTimeNormalDisenableImage = "game/table/yuyin/yuyinguanbi.png";--关
local voiceRealTimePressDisenableImage = "game/table/yuyin/yuyinguanbi-on.png";

--麦克风
local microphoneTimeNormalImage = "game/table/yuyin/maikefengkaiqi.png";--开
local microphoneRealTimePressImage = "game/table/yuyin/maikefengkaiqi-on.png";

local microphoneRealTimeNormalDisenableImage = "game/table/yuyin/maikefengguanbi.png";--关
local microphoneRealTimePressDisenableImage = "game/table/yuyin/maikefengguanbi-on.png";

local isAutoPhysicWorld = true
LOCK_SKILL_CD_TIME = -1;---1表示无限
BINGDONG_SKILL_CD_TIME = 15;--冰冻 技能冷却时间
FAST_SKILL_CD_TIME = 15--狂暴
CALLFISH_SKILL_CD_TIME = 15;--召唤
BINGDONG_FISH_CD_TIME = 15;--冰冻鱼
isUserServerFishPath = false;
ionPaoLv = 8;-- 能量炮等级
isShowFishRect = false;--是否显示鱼的矩形区域
isPhysics = false;--是否使用物理引擎

--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)
	bulletCurCount = {};

	-- GameMsg.init();

	local layer = TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);

	local scene = display.newScene("FishScene", {physics=isPhysics});
	
	if isPhysics then
		scene:getPhysicsWorld():setGravity(cc.p(0, 0))
		-- scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
		scene:getPhysicsWorld():setAutoStep(isAutoPhysicWorld);
	end

	scene:addChild(layer);

	layer.runScene = scene;
	--碰撞边界
	layer:initWorldBox();
	--触摸层
	layer:initTouchLayer();

	return scene;
end

function TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster)
	Event:clearEventListener()

	GameMsg.init()
	-- GameGoodsInfo:init()
	-- GiftEggsInfo:init()
	-- UserExpandInfo:init()
	-- RedEnvelopesInfo:init()
	-- RockingMoneyTreeInfo:init()
	LockFishInfo:init()

	local layer = TableLayer.new(uNameId, bDeskIndex, bAutoCreate, bMaster)

	layer:initTouchLayer()
	globalUnit.isFirstTimeInGame = false

	return layer
end

function TableLayer:getInstance()
	return _instance;
end

function TableLayer:ctor(uNameId, bDeskIndex, bAutoCreate, bMaster)
	self.super.ctor(self, 0, true);
	
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;

	display.loadSpriteFrames("likuipiyu/fishing/game/gamefish_lkpy.plist", "likuipiyu/fishing/game/gamefish_lkpy.png")

	local uiTable = {
		Sprite_bg = "Image_bg",

		-- --基本按钮 设置 玩法 退出 解散 聊天 语音
		Button_help = {"Button_help",0,1},
		Button_exit = {"Button_exit",0},
		Button_multCannon = {"Button_multCannon",0},
		Button_addCannon = {"Button_addCannon",1},
		Button_show = {"Button_show",1},
		Button_lock = {"Button_lock",1},
		Button_unlock = {"Button_unlock",1},
		Button_task = {"Button_task",0},
		Button_fort = "Button_fort",
		Button_fast = {"Button_fast",1},
	}

	self:initData();

	loadNewCsb(self,"csbs/tableLayer",uiTable)

	_instance = self;
end

function TableLayer:onEnter()
	-- package.loaded["game.core.matchPlayer"] = nil;
	package.loaded["game.core.player"] = nil;

	-- if globalUnit:getGameMode() == true then
	-- 	player = require("likuipiyu.game.core.matchPlayer");
	-- else
		player = require("likuipiyu.game.core.player");
	-- end

	self:initUI()

	self:bindEvent()

	self.super.onEnter(self)
end

function TableLayer:onEnterTransitionFinish()

	-- self.updateForCheckOnlineSchedule = schedule(self, function() self:updateForCheckOnline() end, 1);
	-- self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1);

	-- //注册任务调度，不断检测子弹与鱼儿的碰撞
	self.updateCheckFish = schedule(self, function() self:updateGame(1/60); end, 1/60);
	self.catchFishUpdateScheduler = schedule(self, function() self:catchFishUpdate(); end, 0.2);
	
	-- self:reqOnlineTime();--请求在线奖励同步时间
	-- self:sendTaskReq();--请求未领取奖励数量
	-- UserExpandInfo:sendUserExpandInfoRequest();
	-- if not globalUnit:getGameMode() then
	-- 	GameGoodsInfo:sendGoodsInfoRequest()
	-- end

	-- self:preventAddictionGameTips();
end

function TableLayer:bindEvent()
	self:pushEventInfo(GameGoodsInfo, "requestGoodsInfo", handler(self, self.refreshGoodsButton))
	self:pushEventInfo(GameGoodsInfo, "useGoodsInfo", handler(self, self.refreshGoodsOperation))
	self:pushEventInfo(GameGoodsInfo, "getGoodsInfo", handler(self, self.refreshDropGoods))
	self:pushEventInfo(GameGoodsInfo, "synUseGoodsInfo", handler(self, self.synGoodsOperation))
	self:pushEventInfo(GameGoodsInfo, "synGetGoodsInfo", handler(self, self.synDropGoods))
	self:pushEventInfo(MatchInfo, "userMatchInfo", handler(self, self.receiveUserMatchInfo))--用户比赛信息
	self:pushEventInfo(GiftEggsInfo, "hitGiftEggsInfo", handler(self, self.showSpecialRewardLayer))--砸金蛋结果
	self:pushEventInfo(UserExpandInfo, "userExpandInfo", handler(self, self.receiveUserExpandInfo))--用户扩展属性
	self:pushEventInfo(PaotaiInfo, "buyPaotaiResultInfo", handler(self, self.receiveBuyFortInfo))--用户扩展属性
	self:pushEventInfo(LockFishInfo, "lockFishInfo", handler(self, self.receiveLockFishInfo))--锁定消息

	self:pushGlobalEventInfo("gameWorldMessage",handler(self, self.gameWorldMessage))
	self:pushGlobalEventInfo("robotData",handler(self,self.gameRobotDeal))
	self:pushGlobalEventInfo("playOutTime", handler(self, self.playOutTime))--试玩场超时
end

function TableLayer:initUI()
	self:initMusic();


	self:onNodeLoading();

	--基本按钮
	self:initGameNormalBtn();

	-- 初始化玩家信息
	self:initPlayerInfo();

	--初始化语音
	-- self:initVoiceChat();

	--网络信号
	-- self:initNetWorkState();

	--适配游戏
	-- self:adjustmentGame();

	-- 游戏内消息处理
	luaPrint("游戏内消息处理")
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	self:appleViewOff();

	self:initMaskLayer()
end

function TableLayer:initMaskLayer()
	local layer = BaseWindow:create(true,true);
	layer:setName("tableMaskLayer");
	layer:updateLayerOpacity(200)
	self:addChild(layer,9999)
	if layer then
		layer.colorLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1),cc.CallFunc:create(function() layer:removeSelf() end)))
	end
end

function TableLayer:initMusic()
	local userDefault = cc.UserDefault:getInstance();
	local volume = userDefault:getIntegerForKey(MUSIC_VALUE_TEXT, 100);

	if volume > 0 then
		local tag = globalUnit.iRoomIndex
		if globalUnit.iRoomIndex == 5 then
			tag = 4
		end
		audio.playMusic("sound/bg"..tag..".mp3", true);
	end
end

function TableLayer:appleViewOff()
	if device.platform == "ios" then
		if appleView == 1 then
			-- self.Button_share:setVisible(false);
			-- self.Button_distance:setVisible(false);
			-- self.Button_fast:setVisible(false);
			-- self.Button_fort:setVisible(false);
		else
			-- onUnitedPlatformInitBaiDuSDK();
		end
	else
		--开启百度定位
		-- onStartBaiDuLocation();
	end
end

function TableLayer:initData()	
	--玩家对象存储
	self.playerNodeInfo = {};

	--玩家昵称
	self.playerInfo = {};--包括昵称 ID 登陆IP 性别

	self._i64UseDeskLockPassTime = 0
	self.m_iGameMaxCount = 0;--//最大局数
	self._iGameRemaeCount = 0;--//剩余局数
	self._iGameRule = 0;--房间规则
	self.m_bAutomaticCard = false;--//托管

	--聊天图片
	self.chatImage = {};

	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子

	--游戏是否开始
	self.m_bGameStart = false;

	--游戏是否结算
	self._isGameEnd = false;

	self._PlayersSounds = {};--玩家播放
	self._PlayersSoundsTime = {};--玩家播放

	self.recodMaxTime = MAX_RECORD_TIME;--语音倒计时

	self._bReconding = false;
	self.oldEffectVoice = 1;
	--聊天记录
	self.ChatRecord={};
	--是否显示玩家真实信息
	self.isShowPlayInfo = true;--默认显示
	--记录是否是代开房
	self.isDaiKaiFang = nil;
	--有事解散
	self._isHaveThing = false;
	
	--距离页面
	self.DistanceLayer = nil;
	--存储每个玩家的经纬度，根据视图座位号存放	
	self.DistanceTable = {};
	--定位次数，达到三次还未定位到则关闭
	self.DistanceCount = 0;
	--玩家位置信息，获取出来保存
	self.DistanceMsg = nil;

	--房间类型
	self.roomType = RoomType.NormalRoom;--默认正常房间

	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3;

	--捕鱼数据
	FLIP_FISH = false;--屏幕翻转
	self.bulletList = {};--所有子弹断线
	self.fishData = {};--所有fish对象

	self.my = nil;--当前玩家
	self.isAutoShoot = false;--自动射击
	self.isLockFish = false;--是否锁定
	self._isFrozen = false;--是否冰冻
	self.playerPos = {};--玩家坐标

	self.lastClick = nil;--点击的坐标
	self.isFiring = false;--是否普通点击
	self.isFastShoot = false;--是否狂暴
	self.isMoreFastShoot = false;--是否散弹 同时发射三颗子弹
	self.isCallFish = false;--是否召唤
	self.isBingdongFish = false;--是否冰冻
	self.isCreateMatrix = false;--是否创建鱼阵
	self.m_changeGameTable = false;--是否换桌
	self.GLOBAL_BULLET_ID = 1;--子弹ID
	self.catchFishDataCacheList = {};--抓到鱼缓存

	self.isResponeClick = true;--是否响应触摸，以打子弹
	self.playerFastTimeList = {};
	self.playerCallFishTimeList = {};
	self.checkFishList = {};
	-- self.checkBulletList = {};
	self.checkCount = 0;
end

--游戏基本按钮设置
function TableLayer:initGameNormalBtn()
	--玩法
	if self.Button_help then
		self.Button_help:onClick(function(sender) self:onClickHelpCallBack(sender); end)
		self.Button_help:setPositionY(self.Button_fast:getPositionY())
	end

	--任务
	if self.Button_task then
		-- self.Button_task:setVisible(false)
		-- if globalUnit:getGameMode() then
		-- 	self.Button_task:setVisible(false);
		-- 	self.Button_exit:setPosition(cc.p(self.Button_exit:getPositionX(),self.Button_task:getPositionY()));
		-- else
		-- 	--有未领取（已完成任务）奖励 显示标识 数量
		-- 	self.newbg = ccui.ImageView:create("common/mailtip.png")
		-- 	self.newbg:setPosition(cc.p(100,100));
		-- 	self.Button_task:addChild(self.newbg);
		-- 	self.newbg:setVisible(false);
		-- 	local bsize = self.newbg:getContentSize();
		-- 	self.Atlnum = FontConfig.createWithCharMap("","common/tishizitiao.png", 12, 20, '+');
		-- 	self.Atlnum:setPosition(cc.p(bsize.width/2,bsize.height/2));
		-- 	self.Atlnum:setAnchorPoint(cc.p(0.5, 0.5));
		-- 	self.newbg:addChild(self.Atlnum);
		-- 	self.Button_task:setListener(function() self:onClickTaskCallBack(); end)
		-- end
		--任务换成自动
		display.loadSpriteFrames("likuipiyu/fishing/game/gamefish_lkpy.plist", "likuipiyu/fishing/game/gamefish_lkpy.png")
		-- self.Button_task:loadTextures("lkpy_zidong.png","lkpy_zidong-on.png","lkpy_zidong.png",UI_TEX_TYPE_PLIST);
		try({
			function() self.Button_task:loadTextures("lkpy_zidong.png","lkpy_zidong-on.png","lkpy_zidong.png",UI_TEX_TYPE_PLIST) end,
			catch = function(error)
				display.removeSpriteFrames("likuipiyu/fishing/game/gamefish_lkpy.plist", "likuipiyu/fishing/game/gamefish_lkpy.png")
				display.loadSpriteFrames("likuipiyu/fishing/game/gamefish_lkpy.plist", "likuipiyu/fishing/game/gamefish_lkpy.png")
				self.Button_task:loadTextures("lkpy_zidong.png","lkpy_zidong-on.png","lkpy_zidong.png",UI_TEX_TYPE_PLIST)
			end
		})
		self.Button_task:setTag(0);
		self.Button_task:onClick(function(sender) self:onClickAutoCallBack(sender); end);
		self.Button_task:setPositionY(self.Button_lock:getPositionY())
	end
	
	--退出游戏
	if self.Button_exit then
		self.Button_exit:onClick(function()  self:onClickExitGameCallBack(); end)
		self.Button_exit:setPositionY(self.Button_show:getPositionY())
	end

	-- --解散房间
	-- if self.Button_havething then
	-- 	self.Button_havething:setListener(function(sender) self:onClickHaveThingCallBack(sender); end)
	-- end

	-- --聊天
	-- if self.Button_chat then
	-- 	self.Button_chat:setListener(function() self:onClickChatCallBack(); end)
	-- end

	-- --距离
	-- if self.Button_distance then
	-- 	self.Button_distance:setListener(function() self:onClickDistanceCallBack(); end)
	-- end

	-- if self.Button_showResult then
	-- 	self.Button_showResult:setListener(function() self:hideResultLayer(); end)
	-- end

	if self.Button_multCannon then
		self.Button_multCannon:onClick(function() self:onClickFortMult(false) end);
	end

	if self.Button_addCannon then
		self.Button_addCannon:onClick(function() self:onClickFortMult(true) end);
	end

	-- if self.Button_addFishScore then
	-- 	self.Button_addFishScore:setListener(function() self:onClickFishScoreExchange(true); end);
	-- end

	-- if self.Button_multFishScore then
	-- 	self.Button_multFishScore:setListener(function() self:onClickFishScoreExchange(false); end);
	-- end

	--显示隐藏
	if self.Button_show then
		display.loadSpriteFrames("likuipiyu/fishing/game/gamefish_lkpy.plist", "likuipiyu/fishing/game/gamefish_lkpy.png")
		-- self.Button_show:loadTextures("lkpy_yincang.png","lkpy_yincang-on.png","lkpy_yincang.png",UI_TEX_TYPE_PLIST);
		try({
			function() self.Button_show:loadTextures("lkpy_yincang.png","lkpy_yincang-on.png","lkpy_yincang.png",UI_TEX_TYPE_PLIST) end,
			catch = function(error)
				display.removeSpriteFrames("likuipiyu/fishing/game/gamefish_lkpy.plist", "likuipiyu/fishing/game/gamefish_lkpy.png")
				display.loadSpriteFrames("likuipiyu/fishing/game/gamefish_lkpy.plist", "likuipiyu/fishing/game/gamefish_lkpy.png")
				self.Button_show:loadTextures("lkpy_yincang.png","lkpy_yincang-on.png","lkpy_yincang.png",UI_TEX_TYPE_PLIST)
			end
		})
		self.Button_show:setTag(0);
		self.Button_show:onClick(function(sender) self:onClickShowBtn(sender); end);
		-- self.Button_show:setPosition(self.Button_fast:getPosition())
	end

	--锁定
	if self.Button_lock then
		self.Button_lock:onClick(function() self:onClickLock(); end);
	end

	--解锁
	if self.Button_unlock then
		self.Button_unlock:onClick(function() self:onClickUnLock() end);
	end

	if self.Button_fort then
		self.Button_fort:setVisible(false)
		-- if globalUnit:getGameMode() then
		-- 	self.Button_fort:setVisible(false);
		-- 	self.Button_show:setPosition(cc.p(self.Button_fast:getPositionX(),self.Button_fast:getPositionY()));
		-- 	self.Button_fast:setPosition(cc.p(self.Button_fort:getPositionX(),self.Button_fort:getPositionY()));
		-- else
		-- 	self.Button_fort:setListener(function() self:onClickFortUnlock(); end);
		-- end
	end

	if self.Button_fast then
		self.Button_fast:setTag(0);--散弹
		self.Button_fast:onClick(function(sender) self:onClickFastShoot(sender); end);
		-- self.Button_fast:setVisible(false)
	end
	
	local dis = 50
	self.Button_fast:setPositionY(self.Button_fast:getPositionY()+dis)
	self.Button_exit:setPositionY(self.Button_exit:getPositionY()+dis)
	self.Button_multCannon:setPositionY(self.Button_multCannon:getPositionY()+dis)
	self.Button_help:setPositionY(self.Button_help:getPositionY()+dis)
	self.Button_task:setPositionY(self.Button_task:getPositionY()+dis)
	self.Button_addCannon:setPositionY(self.Button_addCannon:getPositionY()+dis)
	self.Button_lock:setPositionY(self.Button_lock:getPositionY()+dis)
	self.Button_unlock:setPositionY(self.Button_unlock:getPositionY()+dis)
	self.Button_fort:setPositionY(self.Button_fort:getPositionY()+dis)
	self.Button_show:setPositionY(self.Button_show:getPositionY()+dis)

	self.Button_fast:loadTextures("lkpy_fast.png","lkpy_fast-on.png","lkpy_fast.png",UI_TEX_TYPE_PLIST);
	self.Button_exit:loadTextures("lkpy_tuichu.png","lkpy_tuichu-on.png","lkpy_tuichu.png",UI_TEX_TYPE_PLIST);
	self.Button_multCannon:loadTextures("lkpy_jianpao.png","lkpy_jianpao-on.png","lkpy_jianpao.png",UI_TEX_TYPE_PLIST);
	self.Button_help:loadTextures("lkpy_shuoming.png","lkpy_shuoming-on.png","lkpy_shuoming.png",UI_TEX_TYPE_PLIST);
	self.Button_addCannon:loadTextures("lkpy_jiapao.png","lkpy_jiapao-on.png","lkpy_jiapao.png",UI_TEX_TYPE_PLIST);
	self.Button_lock:loadTextures("lkpy_suoding.png","lkpy_suoding-on.png","lkpy_suoding.png",UI_TEX_TYPE_PLIST);
	self.Button_unlock:loadTextures("lkpy_jiesuo.png","lkpy_jiesuo-on.png","lkpy_jiesuo.png",UI_TEX_TYPE_PLIST);
	
	self:updateButtonZorder(true);
end

function TableLayer:hideAllBtn(visible)
	if self.dis == nil then
		self.dis = winSize.width - self.Button_lock:getPositionX() + 70
	end

	local dis = self.dis

	if visible then
		self.Button_exit:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
		-- self.Button_multFishScore:runAction(cc.MoveBy:create(0.5,cc.p(150,0)));
		self.Button_multCannon:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
		self.Button_help:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
		self.Button_task:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
		-- self.Button_addFishScore:runAction(cc.MoveBy:create(0.5,cc.p(-150,0)));
		self.Button_addCannon:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
		self.Button_lock:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
		self.Button_unlock:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
		self.Button_fort:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
		self.Button_fast:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
	else
		self.Button_exit:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
		-- self.Button_multFishScore:runAction(cc.MoveBy:create(0.5,cc.p(-150,0)));
		self.Button_multCannon:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
		self.Button_help:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
		self.Button_task:runAction(cc.MoveBy:create(0.5,cc.p(-dis,0)));
		-- self.Button_addFishScore:runAction(cc.MoveBy:create(0.5,cc.p(150,0)));
		self.Button_addCannon:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
		self.Button_lock:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
		self.Button_unlock:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
		self.Button_fort:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
		self.Button_fast:runAction(cc.MoveBy:create(0.5,cc.p(dis,0)));
	end
end

function TableLayer:loadCacheResource()
	local frames = {
					-- "likuipiyu/fishing/fish/boss2",
					-- "likuipiyu/fishing/fish/boss",
					-- "likuipiyu/fishing/fish/boss1",
					"likuipiyu/fishing/lkpy_fort",
					-- "likuipiyu/fishing/fish/lkpy_fish_test4",
					"likuipiyu/fishing/fish/lkpy_fish_test3",
					"likuipiyu/fishing/fish/lkpy_fish_test2",
					"likuipiyu/fishing/fish/lkpy_fish_test1",
					"likuipiyu/fishing/game/gamefish_lkpy",
					"likuipiyu/fishing/scene/gold_lkpy",
					"likuipiyu/fishing/scene/lkpy_other_gold"
					};

	for k,v in pairs(frames) do
		display.loadImage(v..".png")
		display.loadSpriteFrames(v..".plist", v..".png")
	end
end

function TableLayer:loadAnimate()
	local ArmatureList = {
						 "effect/dabaoza/eff_kill_dayu",
						 "effect/zhuanfanle/eff_get_money",
						 "fishEffect/eff_bingdong",
						 "effect/click_effect/eff_bowen",
						 "fishEffect/eff_baozha",
						 "fishEffect/eff_shuaidaile",
						 "effect/xiaobaoza/eff_kill_dabaozha",
						 "effect/zhuanpan/eff_zhuanpan",
						}

	for k,v in pairs(ArmatureList) do
		addArmature(v.."0.png",  v.."0.plist", v..".ExportJson");
	end
end

--隐藏回放按钮
function TableLayer:hideReplayBtn()
	if self.Node_ReplayBtn then
		self.Node_ReplayBtn:setVisible(false);
	end
end

--以下为按钮事件处理
function TableLayer:onClickFortMult(isAdd)
	if self.m_bGameStart ~= true then
		return;
	end

	if self.my and self.my.isEnergyCannon ~= true then
		self.my:changePaoMultiple(isAdd);
	end
end

--鱼分兑换
function TableLayer:onClickFishScoreExchange(isAdd)
	if isAdd == nil then
		isAdd = true;
	end

	self.tableLogic:sendFishScoreExchange(isAdd);
end

--显示按钮
function TableLayer:onClickShowBtn(sender)
	if self.m_bGameStart ~= true then
		return;
	end
	display.loadSpriteFrames("likuipiyu/fishing/game/gamefish_lkpy.plist", "likuipiyu/fishing/game/gamefish_lkpy.png")
	if sender:getTag() == 1 then--显示
		self:hideAllBtn(true);
		sender:setTag(0)
		-- sender:setRotation(45);
		self.Button_show:loadTextures("lkpy_yincang.png","lkpy_yincang-on.png","lkpy_yincang.png",UI_TEX_TYPE_PLIST);
	else
		self:hideAllBtn(false);
		sender:setTag(1);
		-- sender:setRotation(45);
		self.Button_show:loadTextures("lkpy_show.png","lkpy_show-on.png","lkpy_show.png",UI_TEX_TYPE_PLIST);
	end
end

function TableLayer:onClickLock()
	if self.m_bGameStart ~= true then
		return;
	end

	if self.isMoreFastShoot == true then
		if self.my.score < self.my.cur_zi_dan_cost*3 then
			Hall.showTips("当前金币不够发射此倍数炮,不能锁定!")
			return;
		end
	else
		if self.my.score < self.my.cur_zi_dan_cost then
			Hall.showTips("当前金币不够发射此倍数炮,不能锁定!")
			return;
		end
	end

	if self.isLockFish == false then
		self:lockFish(true)
		self:autoShoot(true)

		self.Button_lock:setVisible(false);
		self.Button_unlock:setVisible(true);
	else
		local tipsLayer = Hall.showToast("锁定技能正在使用中")
		tipsLayer:setTouchEnabled(false)
	end
end

function TableLayer:onClickUnLock()
	if self.m_bGameStart ~= true then
		return;
	end

	LockFishInfo:sendLockFishRequest(false);
	self:autoShoot(false)
	self:lockFish(false)
	self.Button_lock:setVisible(true);
	self.Button_unlock:setVisible(false);

	for i, bulletNode in pairs(FishManager:getGameLayer().bulletList) do
		if bulletNode then
			bulletNode.follow = false;
		end
	end
end

--准备按钮，发送准备
function TableLayer:onClickReadyCallBack()
	if Hall.isValidPiPeiGameID(self.uNameId) and PlatformLogic.loginResult.i64Money < globalUnit.nMinRoomKey then
		local prompt = GamePromptLayer:create();
		prompt:showPrompt(GBKToUtf8("金币不足"));
		prompt:setBtnClickCallBack(function() 
			self.tableLogic:sendUserUp();
			self.tableLogic:sendForceQuit();
		end); 
		return;
	end
	self.tableLogic:sendMsgReady();
end

--分享
function TableLayer:onClickShareCallBack(sender)
	globalUnit:setIsShareAward(false);
	local msg = "【娱家斗八张】| 一起来玩吧！房间号:"..gRoomID;
	--luaPrint("gRoomID------------------------------",msg)
	if Hall.isValidPiPeiGameID(self.uNameId) then
		msg = msg.." 模式: 6人 平庄 不带双王"
	else
		if self._iGameRule > 0 then
			local zhuang1 = bit:_and(self._iGameRule, 64);
			local zhuang2 = bit:_and(self._iGameRule, 128);
			local zhuang3 = bit:_and(self._iGameRule, 256);
			local wang = bit:_and(self._iGameRule, 512);
			if zhuang1 ~= 0 then
				msg = msg.." 模式:"..PLAY_COUNT.."人 平庄"
			end	
			if zhuang2 ~= 0 then
				msg = msg.." 模式:"..PLAY_COUNT.."人 A庄"
			end	
			if zhuang3 ~= 0 then
				msg = msg.." 模式:"..PLAY_COUNT.."人 房主坐庄"
			end
			if wang ~= 0 then
				msg = msg.." 带双王";
			else
				msg = msg.." 不带双王";	
			end
		end
		if self.tableLogic:getAAFanKa() then
			msg = msg.." AA制"
		else
			msg = msg.." 非AA制"
		end

		msg = msg.." "..self.m_iGameMaxCount.."局"

		if shareToRoom == true then
			msg = msg.."|3|"..gRoomID;
		end
	end

	if device.platform == "android" then --//判断当前是否为Android平台
		luaPrint("Android 分享朋友")
		onUnitedPlatformShare(msg);
	elseif device.platform == "ios" then
		luaPrint("ios 分享朋友")
		onUnitedPlatformShare(msg);
	else
		luaPrint("登录手机方可分享!")
	end
end

--设置 
function TableLayer:onClickSetCallBack()
	local layer = SetLayer:create(self)
	layer:setLocalZOrder(101);
	self.Sprite_bg:addChild(layer);
end

--玩法
function TableLayer:onClickHelpCallBack()
	if self.m_bGameStart ~= true then
		return;
	end

	self:addChild(HelpLayer:create());
end

--自动，手动
function TableLayer:onClickAutoCallBack(sender,isPochan)

	local tag = sender:getTag();
	if isPochan then
		tag = 1;
	end
	display.loadSpriteFrames("fishing/fishing/game/gamefish_lkpy.plist", "fishing/fishing/game/gamefish_lkpy.png")
	local path = "lkpy_zidong"	
	if tag == 0 then  --自动
		tag = 1;
		self:stopAutoFire();
		self:startAutoFire();
		path = "lkpy_shoudong"
	else
		tag = 0;
		self:stopAutoFire();
	end
	
	sender:setTag(tag);
	sender:loadTextures(path..".png",path.."-on.png",path..".png",UI_TEX_TYPE_PLIST);

	
end

function TableLayer:startAutoFire()
	self.updateAutoSchedule = schedule(self, function() self:autoFire(); end, 1/5);
end

function TableLayer:stopAutoFire()
	if self.updateAutoSchedule then
		self:stopAction(self.updateAutoSchedule);
		self.updateAutoSchedule = nil;
	end
end

function TableLayer:autoFire()
	local winSize = cc.Director:getInstance():getWinSize();
	if self.lastClick == nil then
		self.lastClick = cc.p(winSize.width/2,winSize.height/2)
	end

	if self.my and self.my.lockFish and not tolua.isnull(self.my.lockFish) then
		self.lastClick = self.my.lockFish:getFishPos()
	end

	if self.my then
		self.my:fireToPonit(self.lastClick)
	end
end

--任务
function TableLayer:onClickTaskCallBack()
	if self.m_bGameStart ~= true then
		return;
	end

	local layer = TaskLayer:create();
	self:sendTaskReq()
	layer:setRecAllCallBack(function() self:onClickReceiveAll(); end)
	layer:setRecCallBack(function(taskid) self:onClickReceive(taskid); end)
	layer:setName("TaskLayer")
	self:addChild(layer);
end

--退出
function TableLayer:onClickExitGameCallBack()
	if self.m_bGameStart ~= true then
		return;
	end

	luaPrint("onClickExitGameCallBack-----------------")
	-- if self.isDaiKaiFang or Hall.isValidPiPeiGameID(self.uNameId) or self.m_iGameMaxCount - self._iGameRemaeCount == 0 then
	-- 	self:exitClickCallback();
	-- else
	-- 	self:onClickHaveThingCallBack(self.Button_havething.view, ccui.TouchEventType.ended);
	-- end
	if self.tableLogic then
		self.tableLogic:sendUserResult();
	end
end

function TableLayer:onClickFortUnlock()
	if self.m_bGameStart ~= true then
		return;
	end

	local layer = PaotaiLayer:create(self.my.score);

	self:addChild(layer);
end

function TableLayer:onClickFastShoot(sender,isPochan)
	if self.my == nil then
		return;
	end
	if self.my.isEnergyCannon == true and isPochan == nil then
		return;
	end

	local tag = sender:getTag();
	local path = "lkpy_fast"

	if tag == 0 then
		self.isMoreFastShoot = true;
		tag = 1;
		path = "lkpy_danpao";
	else
		self.isMoreFastShoot = false;
		tag = 0;
	end
	
	if self.my then
		self.my.isMoreFastShoot = self.isMoreFastShoot
		self.my.cannon:setMoreFastFire(self.isMoreFastShoot);
		self.my:updateBullet(self.my.cur_zi_dan_cost);
	end

	sender:setTag(tag);
	sender:loadTextures(path..".png",path.."-on.png",path..".png",UI_TEX_TYPE_PLIST);
end

--解散房间
function TableLayer:onClickHaveThingCallBack(sender,eventType)
	luaPrint("解散房间 ----------- ")
	local name = sender:getName();

	if name == "Button_havething" then
		if self.isBoxMaster then
			local prompt = GamePromptLayer:create();
			prompt:showPrompt(GBKToUtf8("是否解散房间?"));
			prompt:setBtnVisible(true,true)
			prompt:setBtnClickCallBack(function() 
				local str = tostring(gRoomID);
				local msg = {};
				msg.iUserID = PlatformLogic.loginResult.dwUserID;
				msg.iNameID = self.uNameId;
				msg.iRoomID = string.sub(str,1,2);
				msg.iDeskID = string.sub(str,3,5);
				msg.szLockPass = string.sub(str,-1,-1);
				PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_DISMISS, msg, PlatformMsg.MSG_GP_C_DISMISS);
			end);
			return;
		end

		if (not self.m_bGameStart and self.m_iGameMaxCount - self._iGameRemaeCount == 0) or not RoomLogic:isConnect() then--//玩家在第一局开始之前,点击解散房间,非房主执行退出操作
			self:exitClickCallback();
		elseif self._haveThing == nil then
			self._haveThing = HaveThingLayer:create(self);
			self:addChild(self._haveThing);
		end
	end
end

function TableLayer:showHaveThing(data)
	luaPrint("收到解散消息")
	luaDump(data)
	if self._pHaveThing == nil then
		self._pHaveThing = HaveThingLayer.new(self, 1);
		self:addChild(self._pHaveThing);
		self._pHaveThing:showHaveThing(data);
	else
		self._pHaveThing:updateShowHaveThing(data);
	end
end

-- //断线回来，解散房间结果处理
function TableLayer:gameRecurLeftResult(seatNo, bArgeeLeave)
	if bArgeeLeave == 0 then
		return;
	end

	if self._pHaveThing then
		self._pHaveThing:delayCloseLayer();
		self._pHaveThing = nil;
	end

	local prompt = GamePromptLayer:create();

	if bArgeeLeave == 1 then
		self._isHaveThing = true;
		prompt:showPrompt(GBKToUtf8("超过半数玩家同意退出，游戏结束！"));
	elseif bArgeeLeave == 2 then
		RoomLogic:close();
		self._isGameEnd = true;
		self._isHaveThing = true;
		prompt:showPrompt(GBKToUtf8("房主解散房间！"));
		prompt:setBtnClickCallBack(function()
			self.tableLogic:sendUserUp(); 
			self.tableLogic:sendForceQuit();
		end);
	end
end

function TableLayer:gameLeftResult(seatNo, bArgeeLeave)
	local prompt = GamePromptLayer:create();

	if self._pHaveThing then
		self._pHaveThing:delayCloseLayer();
		self._pHaveThing = nil;
	end

	-- //请求提前结束的结果
	if bArgeeLeave == 0 then
		prompt:showPrompt(GBKToUtf8("未超过半数玩家同意退出，游戏继续！"));
		return;
	elseif bArgeeLeave == 1 then
		self._isHaveThing = true;
		prompt:showPrompt(GBKToUtf8("超过半数玩家同意退出，游戏结束！"));		
	elseif bArgeeLeave == 2 then
		prompt:showPrompt(GBKToUtf8("房主解散房间！"));		
		self._isGameEnd = true;
		self._isHaveThing = true;
		RoomLogic:close();
	end

	prompt:setBtnClickCallBack(function()
			self.tableLogic:sendUserUp();
			self.tableLogic:sendForceQuit();
		end);
end

function TableLayer:exitClickCallback()
	if not RoomLogic:isConnect() then--//如果客户端没有断线提示，但实际上断线了，直接离开房间
		luaPrint("断线离开")
		self._bLeaveDesk = false;
		self:leaveDesk();
		return;
	end

	if not self.isDaiKaiFang and not Hall.isValidPiPeiGameID(self.uNameId) and not self.tableLogic:playing() and self.m_iGameMaxCount - self._iGameRemaeCount == 0 and self.tableLogic:getTableOwnerId() == PlatformLogic.loginResult.dwUserID then
		if self._haveThing == nil then
			self._haveThing = HaveThingLayer:create(self);
			self:addChild(self._haveThing)
		end
	else
		local prompt = GamePromptLayer:create();
		prompt:showPrompt(GBKToUtf8("是否退出房间?"));
		prompt:setBtnVisible(true,true)
		prompt:setBtnClickCallBack(function() 
			self.tableLogic:sendUserUp();
			-- self.tableLogic:sendForceQuit();
		end);
	end
end

function TableLayer:leaveDesk(source)
	if not self._bLeaveDesk then
		globalUnit.isEnterGame = false;

		if self.contactListener then
			local eventDispathcher = cc.Director:getInstance():getEventDispatcher()
			eventDispathcher:removeEventListener(self.contactListener);
			self.contactListener = nil;
		end

		self.tableLogic:stop();
		self.tableLogic = nil

		DataCacheManager:clearDataCache();

		self:stopAllActions();

		if fishMatrixEffect then
			audio.stopSound(fishMatrixEffect)
			fishMatrixEffect = nil;
		end

		RoomLogic:close();
		
		self._bLeaveDesk = true;
		_instance = nil;		
	end
end

--聊天
function TableLayer:onClickChatCallBack()
	local chat = GameChatLayer:create(self)
	chat:addChatRecord(self.ChatRecord)
	self:addChild(chat)--加载聊天记录
end

--麦克风
function TableLayer:onClickMicrophoneCallBack(sender, eventType)
	if ccui.TouchEventType.ended == eventType then
		local tag = sender:getTag();

		self:updateMicrophoneBtnEnable(tag ~= btnEnable);
	end
end

--实时语音
function TableLayer:onClickVoiceCallBack(sender, eventType)
	if ccui.TouchEventType.ended == eventType then
		local tag = sender:getTag();

		self:updateRealTimeBtnEnable(tag ~= btnEnable);
	end
end

--语音
function TableLayer:onClickYuyinCallBack(sender, eventType)
	-- //按下开始
	if ccui.TouchEventType.began == eventType then
		luaPrint("begin record");
		self:onPlayVoiceRecord();
	elseif ccui.TouchEventType.moved == eventType then
		local btn_posY = sender:getPositionY() - sender:getContentSize().height/2;
		local touch_posY = sender:getTouchMovePosition().y;
		if math.abs(touch_posY - btn_posY) > 90 then
			if self.Image_chatTip then
				self.Image_chatTip:setVisible(false);
				local sp = self.Image_chatTip:getChildByName("record_ani_sp");
				if sp then
					sp:stopAllActions();
					self.Image_chatTip:removeChildByName("record_ani_sp");
				end
			end
			-- //resume the voice
			audio.resumeMusic();
			audio.setSoundsVolume(self.oldEffectVoice);
			if self.recordSchedule then
				self:stopAction(self.recordSchedule);
				self.recordSchedule = nil;
			end

			if device.platform ~= "windows" then
				if self.libRoomVoice then
					self.libRoomVoice:stopRecord();
				end
			end
		end
	elseif ccui.TouchEventType.ended == eventType then		  --//按下结束
		luaPrint("end record")
		self:onEndVoiceRecord();
	elseif ccui.TouchEventType.canceled == eventType then
		luaPrint(" touch  cancel cancel the  point can not get !!! ");

		if self.Image_chatTip then
			self.Image_chatTip:setVisible(false);
			local sp = self.Image_chatTip:getChildByName("record_ani_sp");
			if sp then
				sp:stopAllActions();
				self.Image_chatTip:removeChildByName("record_ani_sp");
			end
		end
		-- //resume the voice
		audio.resumeMusic();
		audio.setSoundsVolume(self.oldEffectVoice);
		if self.recordSchedule then
			self:stopAction(self.recordSchedule);
			self.recordSchedule = nil;
		end

		if device.platform ~= "windows" then
				if self.libRoomVoice then
					self.libRoomVoice:stopRecord();
				end
			end
		return;
	end
end

--扫描
function TableLayer:onClickDistanceCallBack()
	luaPrint("距离按钮回调函数")
	local ScanLayer =  require("likuipiyu.game.ScanLayer");
	local Layer = ScanLayer:create(self)
	self:addChild(Layer)
end

--查看距离
function TableLayer:onClickDistance(sender)
	if self.isShowPlayInfo then
		local vSeatNO = sender:getTag();
		local lSeatNo = self.tableLogic:viewToLogicSeatNo(vSeatNO);
		local userInfo = self.tableLogic:getUserBySeatNo(lSeatNo);
			
		if userInfo ~= nil then
			local DistanceLayer =  require("likuipiyu.game.DistanceLayer");
			self.DistanceLayer = DistanceLayer:create(self,lSeatNo)
			self:addChild(self.DistanceLayer)
		end
	end
end

-- //录音倒计时
function TableLayer:voiceRecordCallEverySecond()
	self.recodMaxTime = self.recodMaxTime  - 1;
	if self.Text_chat then
		self.Text_chat:setText(self.recodMaxTime.."s");
	end

	if self.recodMaxTime <= 0 then
		self:onEndVoiceRecord();
	end
end

	-- //开始
function TableLayer:onPlayVoiceRecord()
	self.recodMaxTime = MAX_RECORD_TIME;
	self._bReconding = true;

	if self.Image_chatTip then
		self.Image_chatTip:setOpacity(255);
		self.Image_chatTip:setVisible(true);
	end

	if self.Text_chat then
		self.Text_chat:setVisible(true);
		self.Text_chat:setText(self.recodMaxTime.."s");
	end

	local sp_record = cc.Sprite:create("record/v_record_1.png");
	sp_record:setAnchorPoint(cc.p(0.5, 0));
	sp_record:setPosition(self.Image_chatTip:getContentSize().width / 2, 10);
	sp_record:setName("record_ani_sp");
	self.Image_chatTip:addChild(sp_record);
	local ani_cache = cc.AnimationCache:getInstance();
	local animation = ani_cache:getAnimation("record");
	if animation then
		luaPrint("播放录音动画");
		local itemAni = cc.Animate:create(animation);
		sp_record:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function() luaPrint("播放帧动画") end), itemAni)));
	end	

	audio.pauseMusic();
	audio.pauseAllSounds();

	self.oldEffectVoice = audio.getMusicVolume();
	audio.setMusicVolume(0);

	self.recordSchedule = schedule(self, function() self:voiceRecordCallEverySecond(); end, 1)

	if device.platform ~= "windows" then
		if self.libRoomVoice then
			self.libRoomVoice:record();
		end
	end
end
	
-- //结束录音
function TableLayer:onEndVoiceRecord()
	if self.Image_chatTip then
		self.Image_chatTip:setVisible(false);
		local sp = self.Image_chatTip:getChildByName("record_ani_sp");

		if sp then
			sp:stopAllActions();
			self.Image_chatTip:removeChildByName("record_ani_sp");
		end
	end

	if self._bReconding == true then
		-- //结束录音
		self._bReconding = false;
		if self.recordSchedule then
			self:stopAction(self.recordSchedule);
			self.recordSchedule = nil;
		end
		
		if device.platform ~= "windows" then
			if self.libRoomVoice then
				self.libRoomVoice:recordOver();
			end
		end
	else
		audio.resumeMusic();
		audio.setSoundsVolume(self.oldEffectVoice);
		if device.platform ~= "windows" then
			if self.libRoomVoice then
				self.libRoomVoice:stopRecord();
			end
		end
	end
end

--初始化玩家信息
function TableLayer:initPlayerInfo()
	self.playerNodeInfo = {};

	for i=1,PLAY_COUNT do
		local playerNode = player.new(nil, i-1, self.bulletLayer, self.bulletList)
		playerNode:setTag(i-1);
		self.playerLayer:addChild(playerNode);
	end
end

--根据人数适配游戏
function TableLayer:adjustmentGame()
	--适配人数
	if PLAY_COUNT ~= nil and type(PLAY_COUNT) == "number" and PLAY_COUNT > 0 then
		local size = cc.Director:getInstance():getWinSize();

		if PLAY_COUNT == 5 then
			local node5 = self["Node_player5"];
			local pos5 = node5:getPosition();

			--调整1 2 3 4位置
			local node4 = self["Node_player4"];
			local pos4 =node4:getPosition();
			node4:getChildByName("Image_ready4"):setPositionX(node4:getChildByName("Image_ready4"):getPositionX() + 240);
			node4:getChildByName("Image_wchat4"):setPositionY(node4:getChildByName("Image_wchat4"):getPositionY() + 170);
			node4:getChildByName("Image_chat4"):setPositionX(node4:getChildByName("Image_chat4"):getPositionX() + 260);
			node4:setPosition(pos5);
			
			local node3 = self["Node_player3"];
			local pos3 =node3:getPosition();
			node3:getChildByName("Image_wchat3"):setPositionY(node3:getChildByName("Image_wchat3"):getPositionY() + 170);
			node3:setPosition(pos4);
			
			local node2 = self["Node_player2"];
			local y = node2:getPositionY();
			node2:setPosition(pos3)

			local node1 = self["Node_player1"];
			node1:setPositionY(y);

		elseif PLAY_COUNT == 4 then
			local node5 = self["Node_player5"];
			local pos5 = node5:getPosition();

			--调整1 2 3 位置
			local node3 = self["Node_player3"];
			local pos3Y =node3:getPositionY();
			node3:setPosition(pos5);
			node3:getChildByName("Image_ready3"):setPositionX(node3:getChildByName("Image_ready3"):getPositionX() - 260);
			node3:getChildByName("Image_wchat3"):setPosition(node3:getChildByName("Image_wchat3"):getPositionX() - 480,node3:getChildByName("Image_wchat3"):getPositionY() + 170);
			--node3:getChildByName("Image_chat3"):setPosition(node3:getChildByName("Image_chat3"):getPositionX() + 240);

			local node0 = self["Node_player0"];
			local pos0X = node0:getPositionX();
			local node2 = self["Node_player2"];
			local y = node2:getPositionY();
			node2:setPosition(cc.p(pos0X,pos3Y));
			local readyNode = node2:getChildByName("Image_ready2");
			readyNode:setPosition(readyNode:getPositionX() - 130,readyNode:getPositionY() - 120);
			-- local wChatNode = node2:getChildByName("Image_wchat2");
			-- wChatNode:setPosition(wChatNode:getPositionX() - 420,wChatNode:getPositionY() - 200);
			-- local chatNode = node2:getChildByName("Image_chat2");
			-- chatNode:setPosition(chatNode:getPositionX() - 200,chatNode:getPositionY() - 200);

			local node1 = self["Node_player1"];
			node1:setPositionY(y);
		elseif PLAY_COUNT == 3 then
			local node5 = self["Node_player5"];
			local pos5 = node5:getPosition();
			
			local node2 = self["Node_player2"];
			local pos2 = node2:getPosition();
			node2:setPosition(pos5);
			node2:getChildByName("Image_ready2"):setPositionX(node2:getChildByName("Image_ready2"):getPositionX() - 260);
			node2:getChildByName("Image_wchat2"):setPositionX(node2:getChildByName("Image_wchat2"):getPositionX() - 480);
			--node2:getChildByName("Image_chat2"):setPositionX(node2:getChildByName("Image_chat2"):getPositionX() - 240);
			
			local node1 = self["Node_player1"];
			node1:setPosition(pos2);

		elseif PLAY_COUNT == 2 then
			local node3 = self["Node_player3"];
			local Y =node3:getPositionY();

			local node0 = self["Node_player0"];
			local X = node0:getPositionX();
			
			local node1 = self["Node_player1"];
			local readyNode = node1:getChildByName("Image_ready1");
			readyNode:setPosition(readyNode:getPositionX() - 130,readyNode:getPositionY() - 120);

			node1:setPosition(cc.p(X,Y));
		end

		-- PokerCommonDefine.adjustmentGame();
	end
end

--初始化语音
function TableLayer:initVoiceChat()
	local voiceMode = cc.UserDefault:getInstance():getIntegerForKey(gcloudVoice_key, GCloudVoiceMode.RealTime);
	--语音
	if self.Button_yuyin then
		self.Button_yuyin:setVisible(false);
		self:updateYuyinBtnEnable(voiceMode == GCloudVoiceMode.Messages, 2);
		self.Button_yuyin:setTouchListener(function(sender, eventType) self:onClickYuyinCallBack(sender, eventType); end, false)
	end

	local ani_cache = cc.AnimationCache:getInstance();
	-- // 录音动画
	local animation_record = cc.Animation:create();
	for i=1,4 do
		animation_record:addSpriteFrameWithFile("record/v_record_"..i..".png");
	end

	animation_record:setDelayPerUnit(1.0 / 4.0);
	animation_record:setRestoreOriginalFrame(true);
	-- animation_record:setLoops(-1);
	ani_cache:addAnimation(animation_record, "record");

	if self.Button_voice then
		self.Button_voice:setVisible(false);
		self:updateRealTimeBtnEnable(voiceMode == GCloudVoiceMode.RealTime, 2);
		self.Button_voice:setTouchListener(function(sender, eventType) self:onClickVoiceCallBack(sender, eventType); end)
		self.Button_voice:setLocalZOrder(2000);
	end

	if self.Button_microphone then
		self.Button_microphone:setVisible(false);
		self.Button_microphone:setLocalZOrder(2000);
		if voiceMode == GCloudVoiceMode.RealTime then
			self:updateMicrophoneBtnEnable(cc.UserDefault:getInstance():getBoolForKey(gcloudVoice_maikefeng_key, true),2);
		else
			self:updateMicrophoneBtnEnable(false,2);
		end
		
		self.Button_microphone:setTouchListener(function(sender, eventType) self:onClickMicrophoneCallBack(sender, eventType); end)
	end
end

--离线语音
function TableLayer:updateYuyinBtnEnable(enable, clickType)
	if enable == true then
		self.Button_yuyin:loadTextures(voiceMessageNormalImage, voiceMessagePressImage);
		self.Button_yuyin:setTag(btnEnable);
		self.Button_yuyin:setTouchEnabled(true);
		luaPrint("离线语音打开");
		if self.libRoomVoice then
			self.libRoomVoice:setGCloudMode(GCloudVoiceMode.Messages);
		end
	else
		self.Button_yuyin:loadTextures(voiceMessageNormalDisenableImage, voiceMessagePressDisenableImage);
		self.Button_yuyin:setTag(btnDisenable);
		self.Button_yuyin:setTouchEnabled(false);
		luaPrint("离线语音关闭");
	end
end

--实时语音
function TableLayer:updateRealTimeBtnEnable(enable, clickType)
	local path = "";
	if enable == true then
		self.Button_voice:loadTextures(voiceRealTimeNormalImage, voiceRealTimePressImage);
		self.Button_voice:setTag(btnEnable);
		-- self.Button_voice:setTouchEnabled(true);

		self:updateYuyinBtnEnable(false);
		self:updateMicrophoneBtnEnable(true, 1);
		luaPrint("实时语音打开");

		if self.libRoomVoice then
			self.libRoomVoice:setGCloudMode(GCloudVoiceMode.RealTime);
		end

		if clickType ~= 2 then
			path = "game/table/yuyin/yuyinkaiqitishi.png";
		end		
		cc.UserDefault:getInstance():setIntegerForKey(gcloudVoice_key, GCloudVoiceMode.RealTime);
	else
		self.Button_voice:loadTextures(voiceRealTimeNormalDisenableImage, voiceRealTimePressDisenableImage);
		self.Button_voice:setTag(btnDisenable);
		-- self.Button_voice:setTouchEnabled(false);

		self:updateMicrophoneBtnEnable(false, 1);
		self:updateYuyinBtnEnable(true);
		luaPrint("实时语音关闭");

		if clickType ~= 2 then
			path = "game/table/yuyin/yuyinguanbitishi.png"
		end		
		cc.UserDefault:getInstance():setIntegerForKey(gcloudVoice_key, GCloudVoiceMode.Messages);
	end

	if path ~= "" then
		local imageTip = getChildByName(self.Button_voice,"Image_text");
		imageTip:loadTexture(path);

		local tip = self.Button_voice:getChildByName("Image_tip");
		tip:setVisible(true);
		performWithDelay(tip, function() tip:setVisible(false); end, 1);
	end
end

--麦克风
function TableLayer:updateMicrophoneBtnEnable(enable, clickType)
	local path = "";
	if enable == true then
		self.Button_microphone:loadTextures(microphoneTimeNormalImage, microphoneRealTimePressImage);
		self.Button_microphone:setTag(btnEnable);
		if clickType == 1 then
			self.Button_microphone:setTouchEnabled(true);
		elseif clickType == 2 then
			
		else
			path = "game/table/yuyin/maikefengkaiqitishi.png"
		end		
		cc.UserDefault:getInstance():setBoolForKey(gcloudVoice_maikefeng_key, true);
		luaPrint("麦克风打开");

		if self.libRoomVoice then
			self.libRoomVoice:OpenSpeaker();
		end
	else
		self.Button_microphone:loadTextures(microphoneRealTimeNormalDisenableImage, microphoneRealTimePressDisenableImage);
		self.Button_microphone:setTag(btnDisenable);
		if clickType == 1 then
			self.Button_microphone:setTouchEnabled(false);
		elseif clickType == 2 then
			
		else
			path = "game/table/yuyin/maikefengguanbitishi.png"
		end
		cc.UserDefault:getInstance():setBoolForKey(gcloudVoice_maikefeng_key, false);
		luaPrint("麦克风关闭 ");

		if self.libRoomVoice then
			self.libRoomVoice:closeSpeaker();
		end
	end

	if path ~= "" then
		local imageTip = getChildByName(self.Button_microphone,"Image_text");
		imageTip:loadTexture(path);

		local tip = self.Button_microphone:getChildByName("Image_tip");
		tip:setVisible(true);
		performWithDelay(tip, function() tip:setVisible(false); end, 1);
	end
end

--网络信号
function TableLayer:initNetWorkState()
	
end

--显示游戏信息
function TableLayer:showDeskInfo(gameInfo)
	self.gameInfo = gameInfo;
	self._i64UseDeskLockPassTime = RoomLogic.loginResult.itime - gameInfo.i64UseDeskLockPassTime; --//获得当前有效时间
	self.m_iGameMaxCount = gameInfo.iGameRoundMax;
	self._iGameRemaeCount = self.m_iGameMaxCount - gameInfo.iGameRoundCount; --//获得当前有效场数
	gRoomID = gameInfo.szPwd;

	for i=1,PLAY_COUNT do
		local k = i - 1;
		local bDeskStation = self.tableLogic:logicToViewSeatNo(k);
		self:setUserMoney(bDeskStation, gameInfo.iGameStatisticsPoint[i]);
	end

	self:callSYTime();

	self._iGameRule = gameInfo.iGameRule;
	--//显示游戏剩余次数的信息
	local info = "房间号: ";
	
	info =info..gRoomID;
	luaPrint("gRoomID   showdeskinfo	----   "..gRoomID)
	self.Text_roomid:setText(info);

	if self._iGameRule > 0 then
		local zhuang1 = bit:_and(self._iGameRule, 64);
		local zhuang2 = bit:_and(self._iGameRule, 128);
		local zhuang3 = bit:_and(self._iGameRule, 256);
		local wang = bit:_and(self._iGameRule, 512);
		local textStr = "";
		if zhuang1 ~= 0 then
			textStr="模式:"..PLAY_COUNT.."人 平庄"
		end	

		if zhuang2 ~= 0 then
			textStr="模式:"..PLAY_COUNT.."人 A庄"
		end	

		if zhuang3 ~= 0 then
			textStr="模式:"..PLAY_COUNT.."人 房主坐庄"
		end

		if wang ~= 0 then
			textStr = textStr.."\n带双王";
		else
			textStr = textStr.."\n不带双王";
		end

		if gameInfo.bAAFanKa then
			textStr = textStr.." AA制";
		else
			textStr = textStr.." 非AA制";
		end

		self.Text_rule:setText(textStr)
	end

	if Hall.isValidPiPeiGameID(self.uNameId) then
		self.Text_roomid:setVisible(false);
		self.Text_rule:setText("模式: 6人 平庄 \n不带双王 AA制");
		self.Text_rule:setPositionY(self.Text_rule:getPositionY() + 10)
		self.m_iGameMaxCount = 1;
		self._iGameRemaeCount = 1;
		local pipeiStr = "";
		if self.uNameId == GAME_CHUJI_ID then
			pipeiStr = "初级"
		elseif self.uNameId == GAME_ZHONGJI_ID then
			pipeiStr = "中级"
		elseif self.uNameId == GAME_GAOJI_ID then
			pipeiStr = "高级"
		end

		self.Text_jushu:setText("金币"..pipeiStr.."场")
	end

	--语音
   --  if device.platform ~= "windows" then
   --  	local flag = true;

   --  	if device.platform == "ios" then
   --	  	if appleView == 1 then
   --	  		flag = false;
   --	  	end
   --	  end

   --	  if flag == true then
   --	  	self.libRoomVoice = LibRoomVoice:create();
			-- self.view:addChild(self.libRoomVoice);

			-- self.libRoomVoice:setUploadSuccessCallBack(function(fileID) self:onGCloudUploadSuccess(fileID); end)
			-- self.libRoomVoice:setDownloadSuccessCallBack(function(bDestion, bTime) luaPrint("bDestion ~~~~~~~~~~~~	"..bDestion) self:onGCloudDownloadSuccess(bDestion, bTime); end)

			-- if Hall.isValidPiPeiGameID(self.uNameId) then
			-- 	self.libRoomVoice:setGCloudMode(GCloudVoiceMode.Messages);
			-- end
   --	  end
   --  end
end

function TableLayer:callSYTime()
	if Hall.isValidPiPeiGameID(self.uNameId) then
		return;
	end
	if self.Text_jushu and self._iGameRemaeCount >= 0 then
		self.Text_jushu:setText("局数: "..(self.m_iGameMaxCount - self._iGameRemaeCount).."/"..self.m_iGameMaxCount);
	end
end

--设置玩家分数
function TableLayer:setUserMoney(seatNo, money)
	if not self:isValidSeat(seatNo) then
		return;
	end

	seatNo = seatNo + 1;--lua索引从1开始

	-- self.playerNodeInfo[seatNo]:setUserMoney(money);
end

function TableLayer:setUserName(seatNo, name)
	if not self:isValidSeat(seatNo) then 
		return;
	end

	seatNo = seatNo + 1;

	-- self.playerNodeInfo[seatNo]:setUserName(name);
end

--设置玩家分数显示隐藏
function TableLayer:showUserMoney(seatNo, visible)
	luaPrint("设置玩家分数显示隐藏 ------------ seatNo "..seatNo)
	if not self:isValidSeat(seatNo) then
		return;
	end
 	
 	luaPrint("设置玩家分数显示隐藏")
 	seatNo = seatNo + 1;

 	-- self.playerNodeInfo[seatNo]:showUserMoney(visible);
end

function TableLayer:setUserMaster(seatNo, bMaster)
	-- if self:isValidSeat(seatNo) then
	-- 	seatNo = seatNo + 1;
	-- 	luaPrint("房主设置 seatNo = "..seatNo.." bMaster = "..tostring(bMaster));
	--	 if self.playerNodeInfo[seatNo] then
	--		 -- self.playerNodeInfo[seatNo]:setMaster(bMaster);
	--		 if seatNo - 1 == PokerCommonDefine.Poker_Seat_Mark.Poker_South then
	--		 	luaPrint("设置房主 准备 "..tostring(bMaster));
	--		 	-- self.Button_ready:setVisible(not bMaster);
	--		 end
	--	 end
	-- else
	-- 	luaPrint("房主设置失败 seatNo = "..seatNo.." bMaster = "..tostring(bMaster));
	-- end
end

function TableLayer:isValidSeat(seatNo)
	return seatNo < PLAY_COUNT and seatNo >= 0;
end

function TableLayer:getPreviousSeatNo(curSeatNo)
	local seatNo = curSeatNo + 1;

	if seatNo >= PLAY_COUNT then
		seatNo = 0;
	end
end

--添加用户
 function TableLayer:addUser(deskStation, bMe)
	if not self:isValidSeat(deskStation) then 
		return;
	end

	local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);

	if userInfo then
		--//逻辑位置
		if bSeatNo < PLAY_COUNT then
			if userInfo then
				local tempInfo = {};
				--//名字中有 \' 这个符号，对本地数据库保存有影响，所以需要替换
				for k,v in pairs(userInfo) do
					tempInfo[k] = v;
					if k == "nickName" then
						tempInfo.nickName = string.gsub(v,'\'',' ');
					elseif k == "dwUserID" then
						tempInfo.bDestion = v;
					elseif k == "bBoy" then
						if v == true then
							tempInfo._sex = 1;
						else
							tempInfo._sex = 0;	
						end
					elseif k == "dwUserIP" then
						tempInfo._dwIP = v;
					end
				end
				self.playerInfo[bSeatNo] = tempInfo;
			end
			

			deskStation = deskStation + 1;

			if userInfo.dwUserID == PlatformLogic.loginResult.dwUserID then
				self:updateGameSceneRotation(userInfo.bDeskStation);
			end

			self:addPlayer(userInfo);
		end
	end
end

--添加玩家
function TableLayer:addPlayer(userInfo)
	luaPrint("addPlayer(userInfo) -------------------")
	luaDump(userInfo)
	local temp = self.playerLayer:getChildByTag(userInfo.bDeskStation);
	if temp then
		if temp.isAlive == true then
			if FishModule.m_gameFishConfig then
				if globalUnit:getGameMode() == true then
					self.my:updateScore(FishModule.m_gameFishConfig.MatchScore);
					self.my:updateGetSocre(FishModule.m_gameFishConfig.UserNowMatch);
				end
			end
			return;
		else
			temp:removeFromParent();
		end
	end

	local playerNode = player.new(userInfo, userInfo.bDeskStation, self.bulletLayer, self.bulletList)
	playerNode:setTag(userInfo.bDeskStation);
	self.playerLayer:addChild(playerNode);
	playerNode.chushiMoney = userInfo.i64Money;

	self.playerNodeInfo[userInfo.bDeskStation] = playerNode;

	if userInfo.dwUserID == PlatformLogic.loginResult.dwUserID then
		self.my = playerNode;

		if FishModule.m_gameFishConfig then
			self.my:setFortMultSection(FishModule.m_gameFishConfig.min_bullet_multiple, FishModule.m_gameFishConfig.max_bullet_multiple, FishModule.m_gameFishConfig.exchange_count)
			if globalUnit:getGameMode() == true then
				self.my:updateScore(FishModule.m_gameFishConfig.MatchScore);
				self.my:updateGetSocre(FishModule.m_gameFishConfig.UserNowMatch);
			end
		end

		self:addSeatEffect();
		if not self:getChildByName("robot") then
			local layer = require("likuipiyu.game.RobotManager").new()
			layer:setGameLayer(self)
			layer:setName("robot")
			self:addChild(layer)
			self.robotLayer = layer;	
		end
		if globalUnit.fishRobotData then
			self:gameRobotDeal(globalUnit.fishRobotData)
			globalUnit.fishRobotData = nil
		end
	end
	dispatchEvent("refreshUserInfo",{lSeatNo=userInfo.bDeskStation,userInfo=userInfo})
end

function TableLayer:updateGameSceneRotation(lSeatNo)
	if self.isRotation == true or lSeatNo == INVALID_DESKSTATION then
		return;
	end

	luaPrint("自己的逻辑位置 lSeatNo ="..lSeatNo);

	if lSeatNo > 1 then	
		self.isRotation = true;	
		FLIP_FISH = true
		self.rotateLayer:setRotation(180)
		FishManager:setGameRotateEvent(true);
	else
		FLIP_FISH = false
		self.rotateLayer:setRotation(0)
	end
end

function TableLayer:gameChangeMaster(msg)
	if self._isGameEnd == true then
		return;
	end
	if Hall.isValidPiPeiGameID(self.uNameId) then
		luaPrint("TableLayer:gameChangeMaster")
		for k,v in pairs(self.playerNodeInfo) do
			-- v:setMaster(v:getUserId() == msg.dwUserID)
		end

		self.playerInfo[0] = nil;
	end
end

function TableLayer:gameUserCut(seatNo, bCut)
	if globalUnit.m_gameConnectState ~= STATE.STATE_OVER then--//重连中状态
		-- //请求游戏状态信息 ,刷新桌子数据
		local msg = {};
		msg.bEnableWatch = 0;

		RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_GM_GAME_INFO,msg, RoomMsg.MSG_GM_S_ClientInfo);
	end

	local root = cc.Director:getInstance():getRunningScene()

	local node = root:getChildByTag(1421);
	if node then
		node:delayCloseLayer(0);
	end
end

-- //处理玩家掉线协议
function TableLayer:onUserCutMessageResp(userId, seatNo)
	-- if self.playerNodeInfo[seatNo+1] and self.playerNodeInfo[seatNo+1]:getUserId() == userId then
	-- 	-- self.playerNodeInfo[seatNo+1]:setCutHead();
	-- end
end

--当玩家离开的时候房间头像会变成空的
function TableLayer:removeUser(seatNo, bIsMe,bLock)
	if bIsMe then
		RoomLogic:close();
		if bLock == 1 then
			addScrollMessage("您的金币不足,自动退出游戏。")
		elseif bLock == 2 then
			addScrollMessage("您被厅主踢出VIP厅,自动退出游戏。")
		elseif bLock == 5 then 
			addScrollMessage("VIP房间已关闭,自动退出游戏。")
		end
		-- if self._isHaveThing==false then
			-- self:leaveDesk();
		-- end
		return;
	end

	local l = self.tableLogic:viewToLogicSeatNo(seatNo);
	
	if self.playerNodeInfo[l] then
		dispatchEvent("removeRobot",{lSeatNo=l})
		self.playerNodeInfo[l]:removeFromParent();
		self.playerNodeInfo[l] = nil;

		local playerNode = player.new(nil, l, self.bulletLayer, self.bulletList)
		playerNode:setTag(l);
		self.playerLayer:addChild(playerNode);
	end
end

 -- //服务器收到玩家已经准备好了
function TableLayer:playerGetReady(byStation, bAgree, isRecur)
	-- //准备好图片
	-- self.readyImage["Image_ready"..(byStation+1)]:setVisible(bAgree);  
end

-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
	self:clearDesk();

	-- FishModule:clearData();
end

 -- //清理桌面
function TableLayer:clearDesk()
	for i=1,PLAY_COUNT do
		-- //准备好图片
		-- self.readyImage["Image_ready"..i]:setVisible(false);
	end
	-- self.m_bGameStart = false;

	-- //默认不留在桌子上
	self._bLeaveDesk = false;
end

function TableLayer:showResult(data)
	if self.resultLayer == nil then
		--模拟数据
		local layer = ResultLayer:create(self);
		layer:setLocalZOrder(101)
		self.Sprite_bg:addChild(layer);

		self.resultLayer = layer;

		layer:showResult(data);
	end
end

--小结算按钮回调
function TableLayer:resultCallback()
	if self.resultLayer then
		self.resultLayer:delayCloseLayer();
		self.resultLayer = nil;
	end
end

function TableLayer:backPlatform()
	Hall:exitGame(false,function() 
		self.tableLogic:sendUserUp();
		if self.tableLogic then
			self.tableLogic:sendForceQuit();  
		end
	end)
end

--分享 文字
function TableLayer:sendMsgToShare(msgType)
	shareCaptureScreen(msgType);
end

--截屏分享
function TableLayer:sendCapToShare(msgType)
	shareCaptureScreen(msgType);
end

function TableLayer:gameAllEnde(msg, objectSize, game_state)
	table.insert(PokerModule.m_Game_StatisticsMessage,msg);

	if game_state == RoomMsg.CODE_GM_STATISTICS_PART then

	end

	if game_state == RoomMsg.CODE_GM_STATISTICS_FINISH then
		self._isGameEnd = true;
	end
end

function TableLayer:saveSouce(data)
	-- if Hall.isValidPiPeiGameID(self.uNameId) then
	-- 	self._isGameEnd = true;
	-- 	return;
	-- end
	local Myscore = 0;
	for i=1,40 do
		Myscore = Myscore +self.fishingEndData.m_lFishScore[i]
	end
	if Myscore == 0 then
		return;
	end

	if not self._isHaveThing and self._pHaveThing == nil then
		if not PlatformLogic then
			luaPrint("error PlatformLogic is nil");
			return;
		end

		if not self.tableLogic then
			luaPrint("error insert to gameInfo self.tableLogic == nil")
			return;
		end

		-- if self:isReadyByLogicNo(self.tableLogic:getMySeatNo()) ~= true then
		-- 	return;
		-- end

		local fullDBPath = cc.FileUtils:getInstance():getWritablePath()..dbSourceName..PlatformLogic.loginResult.dwUserID..".db";
		-- //打开数据库
		luaPrint("fullDBPath -------------- "..fullDBPath);
		local db = DBUtil:create();
		local ret = db:InitDB(fullDBPath);

		if ret then
			--查询房间
			local date = os.date("%Y-%m-%d %H:%M:%S");
			
			-- 获取当前秒
			local sql = "";
			local tgameinfoid = 0;
			sql = "select id from T_GameInfo where userid = "..PlatformLogic.loginResult.dwUserID;
			sql = sql.."  and game_id = "..GameCreator:getCurrentGameNameID().." and room_id = "..gRoomID.." and GameRule = "..self._iGameRule;

			-- sql = sql.." and userid1 = "..self.tableLogic:getUserId(0).." and userid2 = "..self.tableLogic:getUserId(1).." and userid3 = "..self.tableLogic:getUserId(2).." and userid4 = "..self.tableLogic:getUserId(3)
			
			for i=1, PLAY_COUNT do
				local id = self.tableLogic:getUserId(i-1);

				if id == INVALID_USER_ID then
					id = 0;
				end

				sql = sql.." and userid"..i.." = "..id;
			end
			sql = sql.." order by end_time desc";

			db:GetDataInfoDB(sql);

			-- local iGameStatisticsPoint = data.lCountGameScore;--缺失需添加
			local iGameStatisticsPoint =0;
			luaPrint("--------------222222222222222222")
			local iTotalPoint = {};
			local bWin = 0;

			-- for k,v in pairs(data.lGameScore) do
			-- 	iTotalPoint[k-1] = v;
			-- end
			for i=1,PLAY_COUNT do
				iTotalPoint[i-1] = Myscore;
			end

			luaPrint("--------------1111111111111111")
			luaPrint("self.m_iGameMaxCount  --- "..self.m_iGameMaxCount);
			luaPrint("self._iGameRemaeCount -- "..self._iGameRemaeCount)
			local ret  = false;
			if Hall.isValidPiPeiGameID(self.uNameId) then
				ret = true
			else
				if self.m_iGameMaxCount - self._iGameRemaeCount == 1 or db:getResultSize() <= 0 then
					ret = true
				end
			end

			if ret == true then
				local sql = "insert into T_GameInfo (userid,game_id,innings,room_id,players,end_time,name1,name2,name3,name4,name5,name6,userid1,userid2,userid3,userid4,userid5,userid6,MaxRound,GameRule,ip1,ip2,ip3,ip4,ip5,ip6,sex1,sex2,sex3,sex4,sex5,sex6,total1,total2,total3,total4,total5,total6) values (";
				sql = sql..tonumber(PlatformLogic.loginResult.dwUserID)..","..tonumber(GameCreator:getCurrentGameNameID())..","..tonumber((self.m_iGameMaxCount - self._iGameRemaeCount))..",'"..tostring(gRoomID).."',"..tonumber(PLAY_COUNT)..",'"..tostring(date);
				
				for i=1, MAX_COUNT do
					local name = self.playerInfo[self.tableLogic:getMySeatNo()].nickName;

				-- if i <= PLAY_COUNT then
				-- 	if self.playerInfo[i-1] ~= nil then
				-- 			name = self.playerInfo[i-1].nickName;
				-- 		end
				-- end

					sql = sql.."','"..tostring(name);
				end

				sql = sql.."'";

				for i=1, MAX_COUNT do
					local id = 0;

					if i <= PLAY_COUNT then
						id = self.tableLogic:getUserId(i-1);
					end

					if id == INVALID_USER_ID then
						id = 0;
					end

					sql = sql..","..tonumber(id);
				end

				sql = sql..","..tonumber(self.m_iGameMaxCount)..","..tonumber(self._iGameRule);

				for i=1, MAX_COUNT do
					local ip = 0;

					if i <= PLAY_COUNT then
						if self.playerInfo[i-1] ~= nil then
							ip = self.playerInfo[i-1]._dwIP;
						end
					end

					sql = sql..","..tonumber(ip);
				end
				-- sql = sql..(tonumber(self.playerInfo[0]._dwIP))..","..(tonumber(self.playerInfo[1]._dwIP))..","..(tonumber(self.playerInfo[2]._dwIP))..","..(tonumber(self.playerInfo[3]._dwIP))..",";
				for i=1, MAX_COUNT do
					local sex = 0;

					if i <= PLAY_COUNT then
						if self.playerInfo[i-1] ~= nil then
							sex = self.playerInfo[i-1]._sex;
						end
					end

					sql = sql..","..tonumber(sex);
				end

				for i=1, MAX_COUNT do
					local score = Myscore;

	 --				if i <= PLAY_COUNT then
					-- 	if data.lCountGameScore[i] ~= nil then
					-- 		score = data.lCountGameScore[i];
					-- 	else
					-- 		score = 0;
					-- 	end
					-- end

					sql = sql..","..tonumber(score);
				end

				sql = sql..")";
				-- sql = sql..tonumber(iGameStatisticsPoint[0])..","..tonumber(iGameStatisticsPoint[1])..","..tonumber(iGameStatisticsPoint[2])..","..tonumber(iGameStatisticsPoint[3])..")";
				luaPrint("--------------sql 11	  :  "..sql)
				db:ExecSql(sql);

				db:GetDataInfoDB("select last_insert_rowid() from T_GameInfo");

				if row ~= 0 then
					luaPrint("-----------------333333333333333333")
					tgameinfoid = tonumber(db:GetResultValue(0, "last_insert_rowid()"));
					luaPrint("tgameinfoid -------------- "..tgameinfoid)
				end
			else
				luaPrint("-------------------44444444444444444444");
				tgameinfoid = tonumber(db:GetResultValue(0, "id"));
				luaPrint("tgameinfoid ---------------- "..tgameinfoid)
				local sql = "update T_GameInfo set innings="..tonumber((self.m_iGameMaxCount - self._iGameRemaeCount));
				
				for i=1, MAX_COUNT do
					local score = Myscore;

		--		 	if i <= PLAY_COUNT then
					-- 	if data.lCountGameScore[i] ~= nil then
					-- 		score = data.lCountGameScore[i];
					-- 	else
					-- 		score = 0;
					-- 	end
					-- end

					sql = sql..",total"..i.."="..tonumber(score);
				end

				sql = sql.." where id = "..tonumber(tgameinfoid);
				luaPrint("sql ----  : "..sql);
				db:ExecSql(sql);
			end

			if tgameinfoid == 0 then
				luaPrint("-----------------555555555555555")
				return;
			end
			luaPrint("-------------------------6666666666666666666")
			-- //TSource
			sql = "";
			sql = "insert into T_GameSource (userid, room_id,innings,source1,source2,source3,source4,source5,source6,win,total1,total2,total3,total4,total5,total6,bindid,time,masterID) values ("
			sql = sql..tonumber(PlatformLogic.loginResult.dwUserID)..",'"..tostring(gRoomID).."',"..tonumber((self.m_iGameMaxCount - self._iGameRemaeCount));
			
			-- luaDump(data.lGameScore,"data.lGameScore");
			for i=1, MAX_COUNT do
				local score = Myscore;
	--		 	if i <= PLAY_COUNT then
				-- 	if data.lGameScore[i] ~= nil then
				-- 		-- score = data.lGameScore[i][1] + data.lGameScore[i][2] + data.lGameScore[i][3];
				-- 		score = data.lWinScore[i];
				-- 	else
				-- 		score = 0;
				-- 	end
				-- end

				sql = sql..","..tonumber(score);
			end

			sql = sql..","..tonumber(bWin);

			for i=1, MAX_COUNT do
				local score = Myscore;

	--		 	if i <= PLAY_COUNT then
				-- 	if data.lCountGameScore[i] ~= nil then
				-- 		score = data.lCountGameScore[i];
				-- 	else
				-- 		score = 0;
				-- 	end
				-- end

				sql = sql..","..tonumber(score);
			end

			sql = sql..","..tonumber(tgameinfoid)..",'"..tostring(date).."',"..tonumber(self.tableLogic:getTableOwnerId())..")";
			luaPrint("sql --------------------- : "..sql);
			db:ExecSql(sql);
			luaPrint("----------------77777777777777777")
			-- //操作T_GameData
			-- if saveResult ~= nil and byteLen > 0 then
				luaPrint("-------------888888888888888888")
				-- //没有
				sql = "";
				sql = "insert into T_GameData(userid,innings,nameid,bindid,data1,data2) values(";
				sql = sql..tonumber(PlatformLogic.loginResult.dwUserID)..","..tonumber((self.m_iGameMaxCount - self._iGameRemaeCount))..","..tonumber(GameCreator:getCurrentGameNameID())..","..tonumber(tgameinfoid)..",?,'')";
				luaPrint("sql ------- : "..sql)
				db:ExecSqlBlob(sql);
			-- end
			db:CloseDB();
		end
	end
end

function TableLayer:getViewSeatNO(lSeatNo)
	return self.tableLogic:logicToViewSeatNo(lSeatNo);
end

--修改语音 聊天按钮层级
function TableLayer:updateButtonZorder(flag)
	self.Button_help:setLocalZOrder(100);
	self.Button_exit:setLocalZOrder(100);
	self.Button_multCannon:setLocalZOrder(100);
	self.Button_addCannon:setLocalZOrder(100);
	self.Button_show:setLocalZOrder(100);
	self.Button_unlock:setLocalZOrder(100);
	self.Button_lock:setLocalZOrder(100);
	self.Button_task:setLocalZOrder(100);
	self.Button_fort:setLocalZOrder(100);
	self.Button_fast:setLocalZOrder(100);
end

function TableLayer:updateCheckNet()
	-- PlatformLogic:sendHeart();--防止大厅网络离开大厅后被服务端断开

	-- if not RoomLogic:isConnect() then
	-- 	if self:getChildByTag(1421) == nil then
	-- 		self:onGameDisconnect(function() self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1); end);
	-- 	end
	-- else
	-- 	luaPrint("roomlogic send self.m_iHeartCount = "..self.m_iHeartCount)
	-- 	if self.m_iHeartCount > self.m_maxHeartCount then
	-- 		self.m_iHeartCount = 0;
	-- 		self:onGameDisconnect(function() self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1); end);
	-- 	else
	-- 		RoomLogic:sendHeart();
	-- 		self.m_iHeartCount = self.m_iHeartCount + 1;
	-- 	end
	-- end
end

function TableLayer:gameNetHeart()
	luaPrint("roomlogic rece self.m_iHeartCount = "..self.m_iHeartCount)
	if self.m_iHeartCount > 0 then
		self.m_iHeartCount = self.m_iHeartCount - 1;
	else
		self.m_iHeartCount = 0;
	end
end

function TableLayer:onGameDisconnect(callback)
	-- if self.updateCheckNetSchedule  then
	-- 	self:stopAction(self.updateCheckNetSchedule);
	-- 	self.updateCheckNetSchedule = nil;
	-- end

	-- if globalUnit:getGameMode() ~= true then
	-- 	local root = cc.Director:getInstance():getRunningScene();
	-- 	local node = root:getChildByName("prompt");
		
	-- 	if node or self._isGameEnd == true then
	-- 		return;
	-- 	end

	-- 	RoomLogic:close();

	-- 	local prompt = GamePromptLayer:create();
	-- 	prompt:showPrompt(GBKToUtf8("网络断开连接，请重新登陆!"));
	-- 	prompt:setBtnClickCallBack(function()
	-- 		self.tableLogic:sendUserUp();
	-- 		self.tableLogic:sendForceQuit();
	-- 	end);
	-- else
		-- if self._isGameEnd == true then
		-- 	local node = self:getChildByTag(1421);
		-- 	if node then
		-- 		node.callback = nil;
		-- 		node:delayCloseLayer(0);
		-- 	end

		-- 	local root = cc.Director:getInstance():getRunningScene();
		-- 	local node = root:getChildByName("prompt");
			
		-- 	if node then
		-- 		return;
		-- 	end

		-- 	RoomLogic:close();

		-- 	local prompt = GamePromptLayer:create();
		-- 	prompt:showPrompt(GBKToUtf8("网络断开连接，请重新登陆!"));
		-- 	prompt:setBtnClickCallBack(function()
		-- 		self.tableLogic:sendUserUp();
		-- 		self.tableLogic:sendForceQuit();
		-- 	end);

		-- 	return;
		-- end
		
		-- //--断线重连提示
	-- 	local node = self:getChildByTag(1421);
	-- 	if node then
	-- 		return;-- node:delayCloseLayer(0);
	-- 	end

	-- 	RoomLogic:close();

	-- 	if callback == nil then
	-- 		callback = function() self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1); end
	-- 	end

	-- 	local prompt = GameRelineLayer:create(callback);
	-- 	prompt:setTag(1421);
	-- 	self:addChild(prompt, 1000);
	-- 	prompt:sureReline();
	-- end
		
		
	-- end
	-- if not self._isGameEnd and not self._isHaveThing and not self._bLeaveDesk then
	-- local ret = false;
	-- if self.isDaiKaiFang or Hall.isValidPiPeiGameID(self.uNameId) then
	-- 	if not self._isGameEnd and not self._isHaveThing and not self._bLeaveDesk then
	-- 		ret = true;
	-- 	end
	-- else
	-- 	if not self._isHaveThing and not self._bLeaveDesk then
	-- 		ret = true;
	-- 	end
	-- end

	-- if ret == true then
	-- 	if self.updateCheckNetSchedule  then
	-- 		self:stopAction(self.updateCheckNetSchedule);
	-- 		self.updateCheckNetSchedule = nil;
	-- 	end

	-- 	if callback == nil then
	-- 		callback = function() self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1); end
	-- 	end

	-- 	-- //--断线重连提示
	-- 	local node = self:getChildByTag(1421);
	-- 	if node then
	-- 		node:delayCloseLayer(0);
	-- 	end

	-- 	local prompt = GameRelineLayer:create(callback);
	-- 	prompt:setTag(1421);
	-- 	self:addChild(prompt, 1000);
	-- 	prompt:sureReline();
	-- end
end

-- //语音上传成功回调
function TableLayer:onGCloudUploadSuccess(fileID)
	luaPrint("语音上传成功回调")
	if device.platform ~= "windows" then
		if not isEmptyString(fileID) then
			-- //通知其他玩家
			self:onGCloudVoiceChat(fileID, self.libRoomVoice:getVoiceTime());
		end
	end
end

-- //语音下载完成回调
function TableLayer:onGCloudDownloadSuccess(bDestion, bTime)
	if self._PlayersSounds[bDestion] == nil then
		self._PlayersSounds[bDestion] = {};
	end

	if self._PlayersSoundsTime[bDestion] == nil then
		self._PlayersSoundsTime[bDestion] = {};
	end
	luaDump(bDestion,"bDestion");

	luaPrint("bDestion ******		 "..bDestion)
	table.insert(self._PlayersSounds[bDestion], bDestion);
	table.insert(self._PlayersSoundsTime[bDestion], bTime+2);
	local bView = self.tableLogic:logicToViewSeatNo(bDestion);

	if self:isValidSeat(bView) then
		self.chatImage[bView+1]:setVisible(true);
	end

	if device.platform ~= "windows" then
		if self.libRoomVoice then
			self.libRoomVoice:playVoice();
		end
	end
end

-- //腾讯语音
function TableLayer:onGCloudVoiceChat(fileID, nTime)
	if isEmptyString(fileID) then
		return;
	end

	luaPrint("语音通知其他玩家")
	local msg = {};
	msg.bDestion = self.tableLogic:getMySeatNo();
	msg.bTimeLength = nTime;
	msg.szFileID = fileID;

	self.tableLogic:sendVoiceData(RoomMsg.ASS_VOICE_CHAT_MSG_FINISH, msg);
	for i=1,5 do
		-- luaPrint("sendVoiceData:"..fileID.." , "..nTime);
	end
end

-- //接收腾讯语音消息
function TableLayer:receiveVoiceByFildID(pMsg, nSize, bFinish)
	luaDump(pMsg,"接收腾讯语音消息");
	if nil == pMsg or nSize < 0 then
		return;
	end

	if device.platform ~= "windows" then
		if self.libRoomVoice then
			self.libRoomVoice:download(pMsg.szFileID, pMsg.bDestion, pMsg.bTimeLength);
		end
	end
end

-- //接收语音消息
function TableLayer:receiveVoiceChagMsg(pMsg, nSize, bFinish)
	self:receiveVoiceByFildID(pMsg, nSize, bFinish);
end

function TableLayer:updateForCheckOnline()
	for i=1, PLAY_COUNT do
		local k = i-1;
		if self._PlayersSounds[k] then
			for j=1, #self._PlayersSounds[k] do
				if self._PlayersSoundsTime[k][j] > 0 then
					self._PlayersSoundsTime[k][j] = self._PlayersSoundsTime[k][j] - 1;
				end

				if self._PlayersSoundsTime[k][j] == 0 then
					table.removebyvalue(self._PlayersSounds[k], self._PlayersSounds[k][j]);
					table.removebyvalue(self._PlayersSoundsTime[k], self._PlayersSoundsTime[k][j]);
					local bView = self.tableLogic:logicToViewSeatNo(k);

					if self:isValidSeat(bView) then
						if self.chatImage[bView+1] then
							self.chatImage[bView+1]:setVisible(false);
						end
						audio.resumeMusic();
						audio.setSoundsVolume(self.oldEffectVoice);
					end
					break;
				end
			end
		end
	end
end

--百度定位
function TableLayer:gameBaiduLocation(msg)
	luaPrint("TableLayer:gameBaiduLocation",msg.Latitude,msg.Longitude)
	local deskStation = self.tableLogic:logicToViewSeatNo(msg.wChairID);
	deskStation = deskStation + 1;
	self.DistanceTable[deskStation] = msg;
	if self.DistanceLayer ~= nil then
		self.DistanceLayer:addDistance(msg.wChairID);
	end
end

function TableLayer:onGameBaiDuLocation(baidulocation)
	luaPrint("TableLayer:onGameBaiDuLocation")
	local temp = string.split(baidulocation,",");
	local latitude = temp[1]; --纬度
	local longitude = temp[2];  --经度
	local msg = {};
	msg.wChairID = self.tableLogic:getMySeatNo();
	msg.Latitude = tonumber(latitude);
	msg.Longitude = tonumber(longitude);
	
	luaPrint("msg.wChairID",msg.wChairID,msg.Latitude,msg.Latitude)

	if msg.Latitude == 0 and msg.Longitude == 0 and self.DistanceCount < 5 then
		self.DistanceCount = self.DistanceCount + 1;
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
			onStartBaiDuLocation();
		end)));
		
	else
		self.DistanceCount = 0;
		self.DistanceMsg = msg;

		RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_S_GPS, msg,GameMsg.CMD_S_GPS);
	end
end

function TableLayer:sendChatMsg( nIndex,msg )
	-- body
	--luaPrint("UI 层发送消息")
	local bSeatNo = self.tableLogic:getMySeatNo();
	--luaPrint("发消息人的位置")
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
	--luaDump(userInfo)
	self.tableLogic:sendChatMsg(nIndex,msg,userInfo)
end

--展示聊天消息  msg表示消息 message 是整个消息结构
function TableLayer:showUserChatMsg(nIndex,msg,message)
	--luaPrint("***********************************************************************************************************seatNo",msg)
	
	--获取发消息人的userid
	--local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
	--local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
	local viewSeatNo = nil;
	local seatNo1 = 1;--图片名字
	local chatName = nil--发送聊天人的名字
	local bBoy = true ;

	for i=1,PLAY_COUNT do
		local bSeatNo = self.tableLogic:viewToLogicSeatNo(i-1)
		local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo)
		--luaPrint("bSeatNo",bSeatNo)
		if userInfo then
			--luaPrint("message.dwUserID",message.dwSendID,"userInfo.dwUserID",userInfo.dwUserID)
			if message.dwSendID == userInfo.dwUserID then
				luaDump(userInfo,"玩家信息")
				viewSeatNo = self.tableLogic:logicToViewSeatNo(bSeatNo)+1
				chatName = userInfo.nickName
				bBoy = userInfo.bBoy
				break;
				--luaPrint("找到发消息的人，发消息人的userid为：",userInfo.dwUserID,"视图位置：",viewSeatNo)
			end
		end
	end
	if Hall.isValidPiPeiGameID(self.uNameId) then
		chatName = "玩家"..viewSeatNo;
	end
	local chatStr = "["..chatName.."]"..":"..msg --发送聊天人名字以及内容组合体
	table.insert(self.ChatRecord,chatStr)--保存聊天记录
	local isText= false;
	--seatNo1 = viewSeatNo -1
	-- if PLAY_COUNT == 5 then
	-- 	viewSeatNo
	-- end
	local addWidth = 0;
	if viewSeatNo  == PLAY_COUNT and PLAY_COUNT ~= 2 then 
		addWidth = 120;
		seatNo1 = 2
	else
		seatNo1 = 1
	end

	local chatBgStr = "game/chat/chatRes/chat_bg_text"..seatNo1..".png"--图片背景名字
	local width_Bg = self:getWidth(msg) --长度
	--luaPrint("width_Bg",width_Bg,"viewSeatNo=",viewSeatNo)
	local tmp = cc.Sprite:create(chatBgStr)
	local fullRect = cc.rect(5,5,tmp:getContentSize().width-5,tmp:getContentSize().height-5)
	local insetRect = cc.rect(0,0,0,0)
	local chatBg = cc.Scale9Sprite:create(chatBgStr,fullRect,insetRect) 
	chatBg:setAnchorPoint(0.5,0.5)
	local hight_bg = 55

	if width_Bg >16 then
		width_Bg = 16
		hight_bg = 55
		addWidth = 20
	end
							--高度
	chatBg:setContentSize(width_Bg*20,hight_bg)									--图片背景
	--local chatBgPos = self.playerNodeInfo[seatNo+1]:getPosition()							--位置
	--self.playerNodeInfo[vSeatNo]:getPosition()
	--self.readyImage["Image_ready"..i]
	luaPrint("！！！！！！！！！！！！！！！！！！！！！！说话人的视图位置为："..(viewSeatNo-1),addWidth)
	--self.playerNodeInfo[viewSeatNo]:getParent():getPosition()
	local wChat = self.playerNodeInfo[viewSeatNo]:getParent():getChildByName("Image_wchat"..(viewSeatNo-1))
	chatBg:setPosition(wChat:getPositionX()+addWidth,wChat:getPositionY())

	local tag = viewSeatNo*(-100)
	local sp = self.playerNodeInfo[viewSeatNo]:getParent():getChildByTag(tag)
	if sp then 
		sp:stopAllActions() 
		sp:removeFromParent()
	end

	chatBg:setScale(1)
	self.playerNodeInfo[viewSeatNo]:getParent():addChild(chatBg);
	chatBg:setTag(viewSeatNo*(-100))
	local action1 = cc.DelayTime:create(5);
	local action2 = cc.CallFunc:create(function() chatBg:removeFromParent();
	 end);
	chatBg:runAction(cc.Sequence:create(action1, action2));--要注意这里一个坑
	local word = nil
	if #msg ~= 4 then
		--luaPrint("文本")
		word = ccui.Text:create("","",15)
		word:setString(msg)
		word:setColor(cc.c3b(0,0,0))
		word:ignoreContentAdaptWithSize(false)
		word:setSize(280,40)
		--chatBg:setContentSize(word:getContentSize().x,65)
		isText = true;
	else
		if string.sub(msg,1,1) == "/" and string.sub(msg,2,2) == ":" then  
			if string.byte(string.sub(msg,3,3))>47  and string.byte(string.sub(msg,3,3))<55 and string.byte(string.sub(msg,4,4))>47  then
				local number = nil
				--如果数字小于10就只取最后一位
				if string.sub(msg,3,3) ~= "0" then
					number = string.sub(msg,3,3)..string.sub(msg,4,4)
				else
					number = string.sub(msg,4,4)
				end
				--luaPrint("一定是表情")--确定一定是表情
				word = ccui.ImageView:create("game/chat/chatRes/im"..number..".png")
				--chatBg:setContentSize(word:getContentSize().x+20,65+20)
				word:setAnchorPoint(0.5,0.5)
				isText = false;
			end
		end
	end

	chatBg:setAnchorPoint(0,0.5)

	if word then
		--luaPrint("添加文字")
		chatBg:addChild(word)
		if isText then
			--luaPrint("是文字：文字的宽和高是多少：",word:getContentSize().word,word:getContentSize().height)
			word:setAnchorPoint(0,0.5)
			--chatBg:setContentSize(word:getContentSize().width,word:getContentSize().height)
			word:setPosition(cc.p(20,20))
		else
			--luaPrint("是表情，设置位置")
			chatBg:setContentSize(100,75)
			word:setAnchorPoint(0.5,0.5)
			word:setPosition(cc.p(50,35))
		end
		--word:setAnchorPoint(0,0.5)
		--word:setPosition(20,38)
	end


	--聊天的时候的语音
	if nIndex > 0 then
		local szSound = "";
		--local isNormal = 1--GameSetLayer::m_nSelectLanuage == 1;
		if bBoy then
			szSound = "game/effects/man/CHAT"..nIndex..".mp3";
		else
			szSound =  "game/effects/woman/CHAT"..nIndex..".mp3";
		end
		audio.playSound(szSound, false);
	end

end

--计算九宫格的宽度的
function TableLayer:getWidth(msg)
	-- body
	local num = 0;--表示占用多少位长度
	--笑脸
	if #msg == 4 then
		if string.sub(msg,1,1) == "/" and string.sub(msg,2,2) == ":" then 
			if string.byte(string.sub(msg,3,3))>47  and string.byte(string.sub(msg,3,3))<54 and string.byte(string.sub(msg,4,4))>47  then
				num = 4
				return num
			end
		end
	end

	--字符串
	local i = 1
	--luaPrint("获得长度：",#msg,msg)
	while (i<=#msg) do
		--todo
		if string.byte(string.sub(msg,i,i))>127 then
			--说明找到一个汉字
			num = num +1
			i = i +2
		else 
			num = num + 0.5
		end

		i = i+1
	end

	if num<4 then num = 4 end

	return num;
end

function TableLayer:dealGameRecycleDesk()
	local prompt = GamePromptLayer:create();
	prompt:showPrompt(GBKToUtf8("桌子被解散或者已超时！"));
	RoomLogic:close();
	prompt:setBtnClickCallBack(function() 
		self:leaveDesk();
	end);
end

function TableLayer:getInforData()
	if not (self.isDaiKaiFang and self.m_iGameMaxCount - self._iGameRemaeCount <= 0) then
		local  msg = {};
		msg.dwUserID = PlatformLogic.loginResult.dwUserID;

		RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GR_USERINFO_GET, msg, RoomMsg.MSG_GR_C_GET_USERINFO);
	end
end

function TableLayer:refreshUserInfo(event)
	if event == nil then
		return;
	end
	luaDump(event,"钻石刷新")
	if event.UserID == PlatformLogic.loginResult.dwUserID then
		PlatformLogic.loginResult.i64Money = event.WalletMoney;
		PlatformLogic.loginResult.iRoomKey = event.RoomKey;
	end

	local userInfo = self.tableLogic._deskUserList:getUserByUserID(event.UserID);
	if userInfo and Hall.isValidPiPeiGameID(self.uNameId) then
		userInfo.i64Money = event.WalletMoney;
		userInfo.roomKey = event.RoomKey;
		for k,v in pairs(self.playerNodeInfo) do
			if v:getUserId() == event.UserID then
				v:setUserMoney(userInfo.i64Money);
				break;
			end
		end

		if self.resultLayer then
			self.resultLayer:updateUserInfo(event.UserID,userInfo.i64Money);
		end
	end
end

function TableLayer:directlyMatchGame()
	if PlatformLogic.loginResult.i64Money >= globalUnit.nMinRoomKey then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() 
			-- self:leaveDesk(2);
			self.tableLogic:sendUserUp(2);
			self.tableLogic:sendForceQuit(2);
			end)))
	else
		local prompt = GamePromptLayer:create();
		prompt:showPrompt(GBKToUtf8("金币不足"));
		prompt:setBtnClickCallBack(function() 
			self.tableLogic:sendUserUp();
			self.tableLogic:sendForceQuit();
		end);
	end
end

function TableLayer:hideResultLayer(flag)
	if flag == nil then
		flag = true;
	end

	if self.resultLayer then
		self.Button_showResult:setVisible(not flag);
		self.resultLayer:setVisible(flag)
		self.resultLayer:setTouchEnabled(flag);
	end
end

function TableLayer:addBgEffect(bgNode,pos)
	local particle = cc.ParticleSystemQuad:create("background/lizi_cj_dian.plist")
	particle:setPosition(pos)
	bgNode:addChild(particle);

	local particle = cc.ParticleSystemQuad:create("background/lizi_cj_qipao.plist")
	particle:setPosition(pos)
	bgNode:addChild(particle);
end

function TableLayer:addBgWaterEffect()
	--水波
	-- local animation= cc.Animation:create();
	-- local strname = "";
 --	for i=1,16 do
 --		strname = "fishing/scene/water"..i..".png"
 --		animation:addSpriteFrameWithFile(strname)
 --	end
 --	animation:setDelayPerUnit(0.1);
 --	animation:setRestoreOriginalFrame(true);
 --	-- animation:setLoops(-1) --设置 -1，表示无限循环
 --	local action = cc.Animate:create(animation)
  
 --	local water = cc.Sprite:create("fishing/scene/water1.png");
 --	water:setPosition(cc.p(640,360));
 --	water:setScale(1.2)
 --	water:setLocalZOrder(3);
 --	self.Sprite_bg:addChild(water);
 --	water:runAction(cc.RepeatForever:create(action));
 	local winSize = cc.Director:getInstance():getWinSize();
	local skeleton_animation = createSkeletonAnimation("shuibobeijing_0","scene/water/shuibobeijing_0.25.json", "scene/water/shuibobeijing_0.25.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition(winSize.width/2,winSize.height/2)
		skeleton_animation:setAnimation(1,"shuibobeijing_0.25", true);
		skeleton_animation:setLocalZOrder(3)
		skeleton_animation:setScale(winSize.width/1280)
		self.Sprite_bg:addChild(skeleton_animation);
	end
end

--捕鱼
function TableLayer:onNodeLoading()
	local bgSize = cc.Director:getInstance():getWinSize();
	self:addBgWaterEffect();
	
	self.Sprite_bg:loadTexture("background/bg"..globalUnit.iRoomIndex..".png");

	-- self:addBgEffect(self.Sprite_bg,cc.p(bgSize.width*0.1,bgSize.height*0.1));
	-- self:addBgEffect(self.Sprite_bg,cc.p(bgSize.width*0.15,bgSize.height*0.8));
	-- self:addBgEffect(self.Sprite_bg,cc.p(bgSize.width*0.9,bgSize.height*0.1));

	FishManager:setGameLayer(self);

	self.rotateLayer = self:createLayer()
	self.rotateLayer:setLocalZOrder(3);
	self.Sprite_bg:addChild(self.rotateLayer,3)

	self.coinLayer = self:createLayer()
	self.coinLayer:setLocalZOrder(40)
	self.Sprite_bg:addChild(self.coinLayer,40)

	self.fishLayer = self:createLayer()
	self.rotateLayer:addChild(self.fishLayer);

	self.bulletLayer = self:createLayer()
	self.rotateLayer:addChild(self.bulletLayer,2);

	self.playerLayer = self:createLayer()
	self.rotateLayer:addChild(self.playerLayer,3);
end

function TableLayer:initWorldBox()
	if not isPhysics then
		return;
	end

	local winSize = cc.Director:getInstance():getWinSize();

	local worldBody = cc.PhysicsBody:createEdgeBox(winSize,cc.PhysicsMaterial(0, 1, 0),6);
	worldBody:setCategoryBitmask(8);
	worldBody:setGravityEnable(false)
	worldBody:setRotationEnable(false)
	worldBody:setDynamic(false)

	local worldNde = display.newNode()
	worldNde:setAnchorPoint(cc.p(0.5, 0.5))
	worldNde:setPhysicsBody(worldBody)
	worldNde:setPosition(winSize.width/2, winSize.height/2)
	self.runScene:addChild(worldNde)

	--监听物理碰撞
	self.contactListener = cc.EventListenerPhysicsContact:create()
	self.contactListener:registerScriptHandler(function(contact) onContactBegin(contact) end , cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

	local eventDispathcher = cc.Director:getInstance():getEventDispatcher()
	eventDispathcher:addEventListenerWithFixedPriority(self.contactListener, 1)
end

function TableLayer:initTouchLayer()
	--触摸层
	local touchLayer = display.newLayer();
	self.Sprite_bg:addChild(touchLayer,2);
	touchLayer:setContentSize(cc.Director:getInstance():getWinSize())
	touchLayer:setTouchEnabled(true);
	local function touchCallback(event)
			if self.m_bGameStart ~= true then
				return;
			end

			self:click(event.x,event.y);
			local eventType = event.name;
			if eventType == "began" then
				self.isFiring=true;
				self:addClickEffect(self.lastClick);
				--自动射击时不发射子弹	
				if(self.isAutoShoot == false)then
					self:fireToPonit(self.lastClick,false);
					-- self:test();
					return true
				end

				if(self.my and self.isAutoShoot)then
					if( self:checkFishValid(self.my.lockFish) == false)then
						self:fireToPonit(self.lastClick,false);
					else
						if(self:checkFishValid(self.my.lockFish))then
							luaPrint("发射子弹错误........ self.my.lockFish fishType"..self.my.lockFish._fishType)
						end
					end
				end

				return true;--self:onTouchBegan({x = event.x, y = event.y}, event.name)
			elseif eventType == "moved" then 
				-- self:onTouchMoved({x = event.x, y = event.y}, event.name)
			elseif eventType == "ended" then
				self.isFiring=false;
				-- self:onTouchEnded({x = event.x, y = event.y}, event.name)
			elseif eventType == "cancel" then
				self.isFiring = false;
				-- luaPrint("触摸取消-----------------------")
			end
		end

	touchLayer:onTouch(touchCallback,0, false);
end

function TableLayer:createLayer()
	local layer = cc.Layer:create()
	layer:setAnchorPoint(cc.p(0.5,0.5))

	return layer
end

function TableLayer:click(x,y)
	self.lastClick = cc.p(x,y);
end

function TableLayer:move(x,y)
	self.lastClick = cc.p(x,y);
end

function TableLayer:addFish(fishType, pathType, fishID, fishElapsedTime,isSpec)
	if fishType > 39 then
		return
	end
	if self.isExistFish == nil then
		self.isExistFish = {}
	end

	if self.isExistFish[fishID] then
		return
	end

	self.isExistFish[fishID] = fishID

	local _fishobj = FishManager:createSpecificFish(self, fishType, pathType,isSpec);
	if _fishobj then
		_fishobj:setFishID(fishID);
		self.fishLayer:addChild(_fishobj);
		_fishobj:goFish(fishElapsedTime);

		self.fishData[fishID] = _fishobj;
	end
	return _fishobj;
end

function TableLayer:addServerFish(msg, dt)
	local _fishobj = FishManager:createServerFish(self, msg, dt);
	if _fishobj then
		_fishobj:setFishID(msg.fish_id);
		self.fishLayer:addChild(_fishobj,msg.fish_kind);
		_fishobj:goFish();

		self.fishData[msg.fish_id] = _fishobj;
	end
	return _fishobj;
end

function TableLayer:addFishGroup(fishType, pathType, IdArray)
	local _fishGroup=FishGroup:createFishGroup(self,#IdArray,fishType, pathType);

	for k, _fish in ipairs(_fishGroup) do
		_fish:setFishID(IdArray[k]);
		self.fishLayer:addChild(_fish);
		_fish:goFish();

		self.fishData[IdArray[k]] = _fish;
	end
end

function TableLayer:test()
	local visibleSize = cc.Director:getInstance():getVisibleSize();

	-- local fish = self:addFish(15,1,1);
	-- fish:setPosition(cc.p(visibleSize.width * 0.5,visibleSize.height*0.5));
	-- fish:goFish();
	-- fish:frozen(1000);

	-- local fish = self:addFish(29,1,1);
	-- -- fish:setPosition(cc.p(visibleSize.width * 0.3,visibleSize.height*0.3));

	-- -- local fish = self:addFish(33,1,1);
	-- -- -- fish:setPosition(cc.p(visibleSize.width * 0.3,visibleSize.height*0.3));
	-- -- -- fish:frozen(1000);

	-- -- local fish = self:addFish(30,1,1);
	-- -- -- fish:setPosition(cc.p(visibleSize.width * 0.3,visibleSize.height*0.3));
	-- -- -- fish:frozen(1000);

	-- local fish = self:addFish(16,1,2);
	-- -- -- fish:setPosition(cc.p(visibleSize.width*0.8,visibleSize.height*0.2));
	-- -- -- fish:frozen(1000);

	-- local fish = self:addFish(17,1,3);
	-- -- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.85));
	-- -- fish:frozen(1000);
if self.ii == nil then
	self.ii=0
	self.ids =0
-- 	-- self.ids = {1,12,17}
end
-- if self.ii > 23 then
-- 	return;
-- 	end
if self.ii == 20 then
	self.ii=21
end
-- if self.ii>0 then
-- 	-- return;
-- end
	-- local fish = self:addFish(self.ids[self.ii%3+1],math.random(1,6000),math.random(1,6000));
	-- local fish = self:addFish(self.ii,1,self.ids);
	self.ii = self.ii + 1;
	self.ids=self.ids+1;
	if self.ii > 30 then
		-- self.ii = 25
	end
	-- local fish = cc.Sprite:createWithSpriteFrameName("fish_6_1.png");
	-- fish:setPosition(100,360)
	-- self:addChild(fish)
	-- fish:runAction(cc.MoveBy:create(5,cc.p(2000,0)))
	-- local mby1 = cc.MoveBy:create(1,cc.p(0,200))
	-- local mby2 = cc.MoveBy:create(1,cc.p(0,-200))
	-- fish:runAction(cc.RepeatForever:create(cc.Sequence:create(mby1,mby2,mby2,mby1)))
	-- fish:setPosition(cc.p(math.random(300,900),math.random(50,650)));
	-- fish:frozen(1000);
	-- luaPrint("创建鱼")
	-- local fileName = ("fish_1_%d.png")
	-- local frames = display.newFrames(fileName, 1, 16);
	-- local activeFrameAnimation = display.newAnimation(frames, 0.1);

	-- local sprite = display.newSprite()
	-- sprite:setSpriteFrame(frames[1]);

	-- sprite:setPosition(cc.p(math.random(10,1270),math.random(10,700)));
	-- -- 自身动画
	-- self:addChild(sprite);

	--  local animate= cc.Animate:create(activeFrameAnimation);
	-- local aimateAction=cc.Repeat:create(animate,999999);
	-- -- local aimateSpeed = cc.Speed:create(aimateAction, 1);
	-- sprite:runAction(aimateAction);

	-- local fish = self:addFish(19,1,5);
	-- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.35));
	-- -- fish:frozen(1000);

	-- local fish = self:addFish(20,1,6);
	-- -- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.8));
	-- -- fish:frozen(1000);

	-- local fish = self:addFish(1,1,7);
	-- -- fish:setPosition(cc.p(visibleSize.width*0.2,visibleSize.height*0.5));
	-- -- fish:frozen(1000);

	-- local fish = self:addFish(2,1,8);
	-- fish:setPosition(cc.p(visibleSize.width*0.8,visibleSize.height*0.8));
	-- fish:frozen(1000);

	-- local fish = self:addFish(31,1,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.8,visibleSize.height*0.3));
	-- fish:frozen(1000);

	-- local fish = self:addFish(32,1,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.3));
	-- fish:frozen(1000);

	-- local fish = self:addFish(33,1,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.3,visibleSize.height*0.3));
	-- fish:frozen(1000);

	-- local fish = self:addFish(34,1,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.8,visibleSize.height*0.6));
	-- fish:frozen(1000);

	-- local fish = self:addFish(35,1,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.6));
	-- fish:frozen(1000);

	-- local fish = self:addFish(36,1,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.3,visibleSize.height*0.6));
	-- fish:frozen(1000);

	-- local fish = self:addFish(23,1,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.5));
	-- fish:frozen(1000);

	-- local fish = self:addFish(FishType.FISH_ZHENZHUBEI-1,2,9);
	-- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.8));
	-- fish:frozen(1000);

	-- local fish = self:addFish(24,math.random(1,6),10);
	-- -- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.7));
	-- fish:setPosition(cc.p(visibleSize.width*0.3,visibleSize.height*0.7));
	-- fish:frozen(1000);
-- local fish = self:addFish(41,math.random(1,6000),10);
	-- local fish = self:addFish(30,math.random(0,1000),10);
	-- local fish = self:addFish(31,math.random(0,1000),10);
	-- local fish = self:addFish(32,math.random(0,1000),10);
	-- local fish = self:addFish(33,math.random(0,1000),10);
	-- local fish = self:addFish(34,math.random(0,1000),10);
	-- local fish = self:addFish(35,math.random(0,1000),10);
	-- local fish = self:addFish(36,math.random(0,1000),10);
	-- local fish = self:addFish(37,math.random(0,1000),10);
	-- local fish = self:addFish(38,math.random(0,1000),10);
	-- local fish = self:addFish(39,math.random(0,1000),10);
	-- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.5));
	-- fish:setPosition(cc.p(visibleSize.width*0.5,visibleSize.height*0.5));
	-- fish:frozen(1000);
	-- if self.ii == nil then
	-- 	self.ii = 0;
	-- end
	
	-- local fish = self:addFish(27,self.ii,self.ii);
	
	-- local fish = self:addFish(51,math.random(1,1000),10);
	-- local fish = self:addFish(42,math.random(1,1000),10);
	-- local fish = self:addFish(43,math.random(1,1000),10);
	-- if ist == true then
	-- 	fish:setPosition(cc.p(visibleSize.width*0.7,visibleSize.height*0.3));
	-- 	fish:setVisible(true)
	-- end
	-- ist=true;
	-- performWithDelay(self,function() fish:frozen(1000); end,0.2)
	-- self.ii = self.ii+1;
	-- local fish = self:addFish(41,2,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.3,visibleSize.height*0.3));
	-- fish:frozen(1000);
	-- local fish = self:addFish(42,1,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.7,visibleSize.height*0.7));
	-- fish:frozen(1000);
	-- local fish = self:addFish(40,6,10);
	-- fish:setPosition(cc.p(visibleSize.width*0.7,visibleSize.height*0.3));
	-- fish:frozen(1000);

	-- fish:setFlipRotate(true);

	-- local fishList = {};
	-- for i=1,185 do
	-- 	local fishInfo = {};
	-- 	fishInfo.fishKind = 1;
	-- 	fishInfo.fishID = 1000+i;
	-- 	fishList[i] = fishInfo;
	-- end
	-- self:addFishGroup(15,math.random(0,6),{2,4,5,6,7,9})
	-- FishMatrix:createFishMatrix(self, 3,{});
	performWithDelay(self, function() FishMatrix:createFishMatrix(self, 1,{}); end,1);
	-- performWithDelay(self, function() FishMatrix:createFishMatrix(self, 2,{}); end,20);
	-- performWithDelay(self, function() FishMatrix:createFishMatrix(self, 3,{}); end,30);
	-- FishMatrix:createFishMatrix(self, 0,fishList);
	-- FishMatrix:createFishMatrix(self, 103,fishList);
	-- FishMatrix:createFishMatrix(self, 104,fishList);
	-- FishMatrix:createFishMatrix(self, 105,fishList);
	-- FishMatrix:createFishMatrix(self, 106,fishList);
	-- FishMatrix:createFishMatrix(self, 107,fishList);
	-- local s = math.random(1,5000000);
	-- local m = math.random(1,500)
	-- local k = math.random(0,43)
	-- self:gainCoin(0, cc.p(640,360), s, m);
	-- self:gainScore(0, s, k, m,false,50000);
	-- self:getDropGoods({{goodsID=1,goodsCount=2}},0,cc.p(0,0))
	-- local info = {chair_id=0,fish_id=20000,fish_kind=47,bullet_ion=false,fish_score=3000,user_score=30000,fish_mulriple=50}
	-- info.goodsInfoList = {{goodsID=10000,goodsCount=0.024}};

	-- self:catchFish(info)
end

function TableLayer:fireToPonit(pt,isAutoShoot)
	if self.isResponeClick ~= true then
		luaPrint("子弹ID 异常，未收到服务器回复");
		-- return;
	end

	if self.my and self.my.cannon:getCoolDownState() == false then
		if self.isLockFish then
			if(self.my.lockFish)then
				local pt = self.my.lockFish:getFishPos();
				self.my:fireToPonit(pt);
				self:click(pt);
			else
				--锁定没有鱼的时候不发子弹
				if(isAutoShoot == false)then
					self.my:setLockFish(nil)
					self.my:fireToPonit(pt);
					self.isResponeClick = true;
				end
			end
		else
			self.my:setLockFish(nil)
			self.my:fireToPonit(pt);
		end
	end
end

function TableLayer:addClickEffect(pos)
	local postion = self:convertToNodeSpace(pos);

	local armatureObj = DataCacheManager:createEffect(GAMME_CLICK_EFFECT)
	armatureObj:setPosition(postion)
	armatureObj:playAction()
	self.csbNode:addChild(armatureObj,100);
end

function TableLayer:addSeatEffect()
	--位置提示
	if(self.my)then
		local seatArmature = createArmature("effect/zuowei/ani_weizhi0.png","effect/zuowei/ani_weizhi0.plist","effect/zuowei/ani_weizhi.ExportJson");
		seatArmature:setPosition(cc.p(0,200));
		seatArmature:getAnimation():playWithIndex(0);
		self.my.cannon:addChild(seatArmature,100);

		local sequence = cc.Sequence:create(
						cc.DelayTime:create(5),
						cc.FadeOut:create(1),
						cc.CallFunc:create(function() seatArmature:removeFromParent(); end)
		);

		seatArmature:runAction(sequence)
	end
end

function TableLayer:onContactBegin(contact,nodeA,nodeB)
	if(contact)then
		nodeA = contact:getShapeA():getBody():getNode();
		nodeB = contact:getShapeB():getBody():getNode();
	end

		if (nodeA and nodeB)then

			if nodeA:getTag() ~= nodeB:getTag() then

				if(nodeA:getTag() == THIS_BULLET_TAG and nodeB:getTag() == FISH_TAG)then

					local result = nodeA:showNet(nodeB);

					if(result)then
						nodeA:setMainTarget(nodeB);
						nodeB:setInAttack(nodeA,true);
					end
					
					return false
				elseif(nodeB:getTag() == THIS_BULLET_TAG and nodeA:getTag() == FISH_TAG)then
					
					local result = nodeB:showNet(nodeA);
					if(result)then
						nodeB:setMainTarget(nodeA);
						nodeA:setInAttack(nodeB,true);
					end

					return false
				elseif(nodeA:getTag() == OTHER_BULLET_TAG and nodeB:getTag() == FISH_TAG)then

					local result = nodeA:showNet(nodeB);
					
					if(result)then

						if nodeA:isRobot() then
							nodeA:setMainTarget(nodeB);
						end

						nodeB:setInAttack(nodeA,false);
					end

					return false
				elseif(nodeB:getTag() == OTHER_BULLET_TAG and nodeA:getTag() == FISH_TAG)then

					local result = nodeB:showNet(nodeA);
					if(result)then

						if nodeB:isRobot() then
							nodeB:setMainTarget(nodeA);
						end

						nodeA:setInAttack(nodeB,false);
					end

					return false
				end

			end
		end

	return false
end

function TableLayer:checkCollision()
	self.checkCount = self.checkCount + 1;

	if self.checkCount % 3 ~= 0 then
		return;
	end

	if getTableLength(self.bulletList) <= 0 then
		return;
	end

	for m,bullet in pairs(self.bulletList) do
		if not bullet.hit then
			if bullet.lockFish == nil then
				for k,fish in pairs(self.checkFishList) do
					if not tolua.isnull(fish) then
						local point = self.fishLayer:convertToWorldSpace(cc.p(bullet:getPositionX(),bullet:getPositionY()));
						local bulletSize = bullet:getContentSize();
						local pos = fish:convertToNodeSpace(point);
						local bulletRect = cc.rect(pos.x-bulletSize.width/4,pos.y-bulletSize.height/4,bulletSize.width/2,bulletSize.height/2)
						if cc.rectIntersectsRect(fish.fishRect,bulletRect) and fish:isVisible() and not fish.isKilled then
							self:onContactBegin(nil,fish,bullet)
						end
					end
				end
			else
				if not tolua.isnull(bullet.lockFish) then
					local point = self.fishLayer:convertToWorldSpace(cc.p(bullet:getPositionX(),bullet:getPositionY()));
					local bulletSize = bullet:getContentSize();
					local pos = bullet.lockFish:convertToNodeSpace(point);
					local bulletRect = cc.rect(pos.x-bulletSize.width/4,pos.y-bulletSize.height/4,bulletSize.width/2,bulletSize.height/2)
					if cc.rectIntersectsRect(bullet.lockFish.fishRect,bulletRect) and bullet.lockFish:isVisible() and not bullet.lockFish.isKilled then
						self:onContactBegin(nil,bullet.lockFish,bullet)
					end
				end
			end
		end
	end
end

function TableLayer:updateGame(dt)
	if self.m_bGameStart ~= true then
		return;
	end

	if isPhysics ~= true then
		self:checkCollision();
	end

	if not RoomLogic:isConnect() and self._isGameEnd ~= true then
		-- self:onGameDisconnect();
		return;
	end

	for k,player in pairs(self.playerNodeInfo) do
		if player.cannon then
			player.cannon:cannonUpdate(dt);
		end
	end

	self:setLockFish();

	--瞄准线
	local pos = self.lastClick;
	if self.my and self.my.lockFish then
		pos = self.my.lockFish:getFishPos();
	end

	self:aimLockFish(pos);

	if self.isInClearFishCD == true then
		return;
	end

	--普通点击射击
	if self.isFiring and self.lastClick then
		if(self.my and self.my.cannon and self.my.cannon:getCoolDownState() == false)then
			self:fireToPonit(self.lastClick,true);
		end
	end

	--锁定自动射击
	if(self.isAutoShoot == true and self.m_changeGameTable == false)then
		if(self.my and self.my.cannon:getCoolDownState() == false)then
			-- self:fireToPonit(pos,true);
		end

		if self.lockSkillRunTime ~= -1 then
			self.lockSkillRunTime = self.lockSkillRunTime - dt;

			if(self.lockSkillRunTime <= 0)then
				self.lockSkillRunTime = 0;
				self:autoShoot(false)
				self:lockFish(false)
			end
		end
	end
end

function TableLayer:autoShoot(isAutoShoot)
	if self.my then
		if(isAutoShoot == true)then	
			self.isAutoShoot=true;
			self.lockSkillRunTime = LOCK_SKILL_CD_TIME
			self.my.cannon.lockFishObj:setVisible(true);
		else
			self.lockSkillRunTime = 0
			self.isAutoShoot=false;
			self.my.cannon.lockFishObj:setVisible(false);
		end
	end
end

function TableLayer:lockFish(isLockFish)
	if self.my then
		if(isLockFish==true)then
			self.isLockFish=true;
			self.my.cannon:setLockFishTime(LOCK_SKILL_CD_TIME)
		else
			self.isLockFish=false;

			self.my:setLockFish(nil);
		end
	end
end

function TableLayer:catchFishUpdate()
	for k,catchFishInfo in pairs(self.catchFishDataCacheList) do
		self:catchFish(catchFishInfo)
		self.catchFishDataCacheList[k] = nil
	end
end

function TableLayer:checkFishValid(checkFish) 
	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0,0)
	-- draw:setName("draw222");
	-- draw:setLocalZOrder(10000)
	-- self.playerLayer:addChild(draw, 1000)
	if self.my == nil then
		return false;
	end

	local size = cc.size(220,80);
	local pos = cc.p(self.my:getPositionX(),self.my:getPositionY()+3);
	-- draw:drawPoint((cc.p(pos.x,pos.y)), 4, cc.c4f(1,1,0,1))
	-- draw:drawRect(cc.p(pos.x-size.width/2,pos.y-size.height/2), cc.p(pos.x+size.width/2,pos.y+size.height/2), cc.c4f(1,1,0,1))

	local size1 = cc.size(100,160);
	local pos1 = cc.p(self.my:getPositionX(),self.my:getPositionY()+35);
	-- draw:drawPoint((cc.p(pos1.x,pos1.y)), 4, cc.c4f(1,1,0,1))
	-- draw:drawRect(cc.p(pos1.x-size1.width/2,pos1.y-size1.height/2), cc.p(pos1.x+size1.width/2,pos1.y+size1.height/2), cc.c4f(1,1,0,1))
	if(checkFish and not tolua.isnull(checkFish) and checkFish:isFishAlive() and checkFish:isFishOutScreen() == false and checkFish:isFishBelowPlayer(pos,size) == false and checkFish:isFishBelowPlayer(pos1,size1) == false)then
		return true
	else
		return false
	end
end

function TableLayer:catchFish(catchFishInfo)
	if self.m_bGameStart ~= true then
		return;
	end

	local catchinfo = catchFishInfo;

	local tarFish = nil
	for k, fish in pairs(self.fishData) do
		if fish and not tolua.isnull(fish) and fish:getFishID() == catchinfo.fish_id then
			tarFish = fish
			break;
		end
	end

	local flag = false;
	for k,goodsInfo in pairs(catchinfo.goodsInfoList) do
		if goodsInfo.goodsID == GOODS_HUAFEI and goodsInfo.goodsCount > 0 then
			flag = true;
			break;
		end
	end

	if tarFish then
		--金币动画
		local mult = catchinfo.fish_mulriple--FishModule.m_gameFishConfig.fish_multiple[catchinfo.fish_kind+1];
		self:gainCoin(catchinfo.chair_id, tarFish:getFishPos(), catchinfo.fish_score, catchinfo.fish_kind, flag);
		self:gainScore(catchinfo.chair_id, catchinfo.fish_score, catchinfo.fish_kind, mult,tarFish:checkIsLiQuan(),catchinfo.user_score);

		--只有自己的时候播放音效
		if self.my and self.my:getSeatNo() == catchinfo.chair_id then
			tarFish:killFish(true,catchinfo.chair_id)
		else
			tarFish:killFish(false,catchinfo.chair_id)
		end

		--获得额外物品展示
		self:getDropGoods(catchinfo.goodsInfoList,catchinfo.chair_id,tarFish:getFishPos())
	else
		luaPrint("gain coin without Fish!!!!!!!!!!!!!!")
		local mult = catchinfo.fish_mulriple--FishModule.m_gameFishConfig.fish_multiple[catchinfo.fish_kind+1];
		self:gainCoin(catchinfo.chair_id, nil, catchinfo.fish_score, catchinfo.fish_kind,flag);
		self:gainScore(catchinfo.chair_id, catchinfo.fish_score, catchinfo.fish_kind, mult,false,catchinfo.user_score);

		--获得额外物品展示
		self:getDropGoods(catchinfo.goodsInfoList,catchinfo.chair_id)
	end

	--能量炮处理,开启能量炮模式
	if catchinfo.bullet_ion == true then
		self:refreshPlayerIon(catchinfo.chair_id, true, 3);
	end

	local id = catchinfo.fish_kind + 1;
	local pos = getScreenCenter();
	if tarFish then
		pos = tarFish:getFishPos();
	end

	if id == 22 then--定屏炸弹
		self:frozenFish(1);
	elseif id == FishType.FISH_GIFTEGGS then--礼蛋
		self:giftEggsFish(catchinfo,pos);
	elseif id == FishType.FISH_ROCKMONEYTREE then--摇钱树
		self:rockingMoneyTreeFish(catchinfo,pos);
	elseif id == FishType.FISH_CHAOTICBEADS then--混沌珠
		self:showChaoticBeads(catchinfo,pos);
	end

	-- self:showSpecialRewardLayer({_usedata={fish_score=999,UserFishscore=44,iLotteries=0,UserLotteries=8}})
end

--刷新玩家能量炮
function TableLayer:refreshPlayerIon(chairid, enable, isReset)
	local players = self.playerNodeInfo;

	if players[chairid] ~= nil then
		players[chairid]:setPlayerMode(enable,isReset);
	end
end

--场景消息时，刷新所有玩家鱼分
function TableLayer:refreshAllPlayer(msg)
	self.GLOBAL_BULLET_ID = msg.bulletid + 1;
	self.isResponeClick = true;

	for i=1,PLAY_COUNT do
		if self.playerNodeInfo[i-1] ~= nil then
			-- self.playerNodeInfo[i-1]:updateScore(msg.fish_score[i]);
		end
	end
end

--刷新当前玩家炮倍
function TableLayer:refreshFortMultip(msg)
	if self.my then
		if globalUnit:getGameMode() == true then
			if totalFishScore == nil then
				self.my:setFortMultSection(msg.min_bullet_multiple, msg.max_bullet_multiple);
			end
			self.my:updateScore(msg.MatchScore);
			self.my:updateGetSocre(msg.UserNowMatch);
			totalFishScore = msg.InitScore;

			if self.gameMatchEndAction then
				self:stopAction(self.gameMatchEndAction);
				self.gameMatchEndAction = nil;
			end

			if self.gameMatchEndAction == nil then
				luaPrint("比赛场断线回来 ---------------------------")
				self.gameMatchEndAction = performWithDelay(self,function()
					if msg.MatchScore <= 0 and bulletCurCount <= 0 then--比赛场断线回来
						self:gameMatchEnd(true);
						self.gameMatchEndAction = nil;
					end
				end,1)
			end
		else
			self.my:setFortMultSection(msg.min_bullet_multiple, msg.max_bullet_multiple);
		end
	end
end

--创建新的鱼
function TableLayer:refreshNewFish(msg,isSpec)
	--鱼阵不出鱼
	if self.isCreateMatrix == true then
		return;
	end

	if self.m_bGameStart ~= true then
		return;
	end

	if isSpec == true then
		for k,item in pairs(msg) do
			if item.pathid < 20000 then--刚进入初始鱼，召唤鱼不处理
				self:addFish(item.fish_kind, item.pathid, item.fish_id,nil,isSpec);
			end
		end
		-- local layer = self:getChildByName("tableMaskLayer");
		-- if layer then
		-- 	layer.colorLayer:runAction(cc.Sequence:create(cc.FadeOut:create(2),cc.CallFunc:create(function() layer:removeSelf() end)))
		-- end
		return;
	end
	if self.cacheCallFish == nil then
		self.cacheCallFish = {};
	end

	for k,item in pairs(msg) do
		if item.pathid >= 20000 then
			table.insert(self.cacheCallFish, item);
			if self.cacheCallFish and #self.cacheCallFish > 0 then
				self:callFish(true);
			end
			return;
		else
			-- return;
		end
	end

	--冰冻不出鱼
	if self._isFrozen == true then
		if self.cacheFish == nil then
			self.cacheFish = {}
		end

		for k,item in pairs(msg) do
			if item.fish_kind >= 40 then
				table.insert(self.cacheFish, {item});
			end
		end
		return;
	end

	local lastFishType=-1;
	local lastFishPath=-1;
	local lastFishGroup={};
	local lastFishID=-1;
	local groupFlag=false;

	if isUserServerFishPath == true then

	else
		for k,item in pairs(msg) do
			if(lastFishType == item.fish_kind and lastFishPath == item.pathid )then
				if(groupFlag==false)then
					groupFlag=true;
					lastFishGroup={};
					table.insert(lastFishGroup,lastFishID);
					table.insert(lastFishGroup,item.fish_id);
				else
					table.insert(lastFishGroup,item.fish_id);
				end
			else
				if(groupFlag)then
					groupFlag=false;
					self:addFishGroup(lastFishType, lastFishPath, lastFishGroup);
				else
					if(k~=1)then
						self:addFish(lastFishType, lastFishPath, lastFishID);
					end
				end
			end

			lastFishType = item.fish_kind; 
			lastFishPath = item.pathid;
			lastFishID = item.fish_id;
		
			if(k == #msg)then
				if(groupFlag)then
					self:addFishGroup(lastFishType, lastFishPath, lastFishGroup);
				else
					self:addFish(lastFishType, lastFishPath, lastFishID);
				end
			end
		end
	end
end

function TableLayer:refreshFishLkMult(msg)
	for fishPoint, fish in pairs(self.fishData) do
		if fish and not tolua.isnull(fish) and fish:getFishID() == msg.fish_id then
			fish:setFishMult(msg.fish_mulriple);
			break;
		end
	end
end

function TableLayer:showFishMatrixTip(msg)
	if self.isCreateMatrix == true then
		return;
	end
	
	self:showAbigWaveOfFishComeon();
end

function TableLayer:createMatrix(msg)
	if self.isCreateMatrix == true then
		return;
	end

	self.isCreateMatrix = true

	self:cleanFishGetOut();

	-- if true then
	-- 	performWithDelay(self,function()
	-- 		if self.fishData and next(self.fishData) == nil then
	-- 			self:matrixEnd();
	-- 		end
	-- 	 end,20);
	-- 	return;
	-- end

	local winSize = cc.Director:getInstance():getWinSize();
	-- local particle = cc.ParticleSystemQuad:create("effect/lizi_paopao_1.plist");
	-- particle:setPosition(cc.p(winSize.width/2, -50));
	-- self:addChild(particle);

	--海浪
	local animation= cc.Animation:create();
	local strname = "";
	for i=1,3 do
		strname = "fishing/scene/wave/wave"..i..".png"
		animation:addSpriteFrameWithFile(strname)
	end
	animation:setDelayPerUnit(0.1);
	animation:setRestoreOriginalFrame(false);
	-- animation:setLoops(-1) --设置 -1，表示无限循环
	local action = cc.Animate:create(animation)

	local num = FishPath:fakeRandomS(math.ceil(os.time()/60), 6,398)%4;
	if num == self.bgNum then
		num = (num+1)%4;
	end
	
	self.bgNum = num;

	num = num + 1;

	local index = 1;
	local bg1 = self.Sprite_bg:getChildByName("bg1");
	local bg2 = self.Sprite_bg:getChildByName("bg2");

	if bg1 == nil then
		bg1 = ccui.ImageView:create("fishing/scene/newbg"..num..".png");
		bg1:setName("bg1");
		bg1:ignoreContentAdaptWithSize(false)
		bg1:setContentSize(self.Sprite_bg:getContentSize())
		self.Sprite_bg:addChild(bg1,0);
		index = 1;
	else
		if bg2 == nil then
			bg2 = ccui.ImageView:create("fishing/scene/newbg"..num..".png");
			bg2:setName("bg2");
			bg2:ignoreContentAdaptWithSize(false)
			bg2:setContentSize(self.Sprite_bg:getContentSize())
			self.Sprite_bg:addChild(bg2,0);
			index = 2;
		elseif bg1 and bg1:isVisible() ~= true then
			bg1:setVisible(true);
			bg1:loadTexture("fishing/scene/newbg"..num..".png");
			index = 1;
		elseif bg2 and bg2:isVisible() ~= true then
			bg2:setVisible(true);
			bg2:loadTexture("fishing/scene/newbg"..num..".png");
			index = 2;
		end
	end

	local wave = cc.Sprite:create("fishing/scene/wave/wave1.png");
	wave:setScale(1.1)
	self.Sprite_bg:addChild(wave,0);
	wave:runAction(cc.RepeatForever:create(action));

	local move = nil;
	local movebg = nil;
	local size = wave:getContentSize();

	local newbg = self.Sprite_bg:getChildByName("bg"..index);
	local oldbg = self.Sprite_bg:getChildByName("bg"..(index%2+1))
	if FLIP_FISH then
		wave:setAnchorPoint(0,0.5);
		wave:setPosition(winSize.width-15,winSize.height/2);
		self.Sprite_bg:getChildByName("bg"..index):setAnchorPoint(0,0.5);
		self.Sprite_bg:getChildByName("bg"..index):setPosition(winSize.width,winSize.height/2);
		move = cc.MoveBy:create((winSize.width+size.width)/250, cc.p(-size.width-winSize.width,0));
		movebg = cc.MoveBy:create((winSize.width)/250, cc.p(-winSize.width,0));
	else
		wave:setFlippedX(true);
		wave:setAnchorPoint(1,0.5);
		wave:setPosition(15,winSize.height/2);
		newbg:setAnchorPoint(1,0.5);
		newbg:setPosition(0,winSize.height/2);
		move = cc.MoveBy:create((winSize.width+size.width)/250, cc.p(winSize.width+size.width,0));
		movebg = cc.MoveBy:create((winSize.width)/250, cc.p(winSize.width,0));
	end

	wave:setLocalZOrder(2);
	wave:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()  
		if fishMatrixEffect then
			audio.stopSound(fishMatrixEffect);
			fishMatrixEffect = nil;
		end

		gameResumeMusic();

		wave:removeFromParentAndCleanup(); end)));
		newbg:setLocalZOrder(1);
		newbg:runAction(cc.Sequence:create(movebg,
		cc.CallFunc:create(function()
			if oldbg then 
				oldbg:setVisible(false); 
				end 
		end)));

	if oldbg then
		oldbg:setLocalZOrder(newbg:getLocalZOrder()-1);
	end

	local function playPop(dt)
		for k, fish in pairs(self.fishData) do
			fish:quickGoOut();
		end

		if isShowFishRect == true then
			FishManager:getGameLayer().fishLayer:removeAllChildren();
		end

		local fishList = {};
		for i=1,msg.fish_count do
			fishList[i] = {fishKind=msg.fish_kind[i], fishID=msg.fish_id[i]};
		end
		local matrixTm = FishMatrix:createFishMatrix(self,msg.scene_kind,fishList);
		self.checkFish = schedule(self,function()
			if self.fishData and next(self.fishData) == nil then
				self:matrixEnd();
			end
		end,2);
	end

	performWithDelay(self, playPop, (winSize.width)/250);

	--提示鱼阵即将出来
	self:showGameTip(math.floor((winSize.width)/250))
end

function TableLayer:showAbigWaveOfFishComeon(msg)
	if self.bigFishComeAnmiate == nil then
		local winSize = cc.Director:getInstance():getWinSize();
		self.bigFishComeAnmiate = createSkeletonAnimation("yidaboyu","fishing/scene/yidaboyu/yidaboyu.json", "fishing/scene/yidaboyu/yidaboyu.atlas");
		if self.bigFishComeAnmiate then
			self.bigFishComeAnmiate:setPosition(cc.p(winSize.width/2, winSize.height/2));
			self.bigFishComeAnmiate:setAnchorPoint(cc.p(0.5,0.5));
			self.bigFishComeAnmiate:setLocalZOrder(100);
			self.Sprite_bg:addChild(self.bigFishComeAnmiate);
		end
	end

	if self.bigFishComeAnmiate then
		self.bigFishComeAnmiate:setVisible(true);
		self.bigFishComeAnmiate:setAnimation(1, "yidaboyu", false);
		self.bigFishComeAnmiate:runAction(cc.Sequence:create(
			cc.DelayTime:create(4), 
			cc.CallFunc:create(function() self.bigFishComeAnmiate:setVisible(false) end)
			-- cc.DelayTime:create(3),
			-- cc.CallFunc:create(function() self:createMatrix(msg); end)
			))
	end
end

function gameResumeMusic(isMatrix)
	local userDefault = cc.UserDefault:getInstance();
	local volume = userDefault:getIntegerForKey(MUSIC_VALUE_TEXT, 100);
	if volume > 0 then
		if isMatrix then--鱼阵时清理boss
			audio.playMusic("sound/bg"..globalUnit.iRoomIndex..".mp3", true);

			if audio.isMusicPlaying() ~= true then
				audio.playMusic("sound/bg"..globalUnit.iRoomIndex..".mp3", true);
			end
			luaPrint("boss 意外 ----------  恢复音乐===================")
			audio.pauseMusic();
			return;
		end

		if TableLayer:getInstance().isCreateMatrix then
			audio.resumeMusic();
		else
			audio.playMusic("sound/bg"..globalUnit.iRoomIndex..".mp3", true);

			if audio.isMusicPlaying() ~= true then
				audio.playMusic("sound/bg"..globalUnit.iRoomIndex..".mp3", true);
			end
		end
	end
end

function TableLayer:cleanFishGetOut()
	self:frozenFish(false);
	self:callFish(false);

	for k, fish in pairs(self.fishData) do
		fish:quickGoOut();
	end

	audio.pauseMusic();
	fishMatrixEffect = audio.playSound("fishing/sound/wave.mp3",true);
end

function TableLayer:matrixEnd()
	--鱼阵结束
	self.isCreateMatrix = false
	if self.checkFish then
		self:stopAction(self.checkFish);
		self.checkFish = nil;
	end
end

--玩家开炮
function TableLayer:refreshUserFire(msg)
	if self.m_bGameStart ~= true then
		return;
	end

	--打出一发子弹后，收到服务端回复，才允许打下一发
	self.isResponeClick = true;

	if msg.angle > 360 then
		msg.angle = msg.angle % 360;
	end

	local cost = msg.bullet_mulriple;
	if not cost then
		cost = 100;
	end

	-- cost = goldConvert(cost)

	--同步子弹
	self:userFire(msg.chair_id, msg.angle, cost, msg.lock_fishid, msg.bullet_id, msg.android_chairid);
	if msg.bullet_kind < 8 then
		if self.playerNodeInfo[msg.chair_id] then
			msg.bullet_kind =  self.playerNodeInfo[msg.chair_id]:getFireGunLevel(msg.bullet_mulriple/100)
		end
	end
	
	--同步炮倍 鱼分
	self:refreshPlayerInfo(msg.chair_id, cost,msg.fish_score,msg.bullet_kind);
end

function TableLayer:userFire(chairID, angle, cost, lockFishID, bullet_id, android_chairid)
	local players = self.playerNodeInfo;

	if players[chairID] ~= nil and chairID ~= self.my:getSeatNo() and players[chairID].isRobot ~= true then
		if lockFishID > 0 then
			local lockFish = self:getLockFish(lockFishID);
			players[chairID]:setLockFish(lockFish);
		else
			players[chairID]:setLockFish(nil);
			players[chairID]:hideAimLine();
		end

		players[chairID]:fireToDirection(angle,cost,bullet_id,android_chairid,lockFishID);
	end
end

function TableLayer:refreshPlayerInfo(chairID, paoMult, fishScore, bullet_kind)
	local player = self.playerNodeInfo[chairID];

	if player ~= nil then
		if player.cannon.isMoreFastShoot == true then
			if #player.fireBulletDataCache == 3 then
				if player.score > fishScore then
					player:updateScore(fishScore);
				end
			end
		else
			if player.score > fishScore then
				player:updateScore(fishScore);
			end
		end
		local ismyRobot = false
		if self.robotLayer.robotList[chairID] ~= nil then
			ismyRobot = true;
		end
		if chairID ~= self.my:getSeatNo() and not ismyRobot then
			local ret = (bullet_kind == ionPaoLv or bullet_kind == ionPaoLv+8)
			self:refreshPlayerIon(chairID,ret,2);
			player:setFortMultip(paoMult,bullet_kind);
		end
	end
end

--抓到鱼处理 普通鱼
function TableLayer:refreshCatchFish(msg)
	luaPrint("refreshCatchFish 抓到鱼处理");

	--放到缓存列表
	table.insert(self.catchFishDataCacheList,msg);
end

--炸弹鱼处理 
function TableLayer:refreshBombFish(msg)
	if msg.chair_id ~= self.my:getSeatNo() and msg.android_chairid ~= self.my:getSeatNo() and self.robotLayer.robotList[msg.chair_id] == nil then
		return;
	end

	local bombFish = nil

	for fishPoint, fish in pairs(self.fishData) do
		if fish._fishID ==  msg.fish_id then
			bombFish = fish;
			break;
		end
	end

	if bombFish then
		luaPrint("找到炸弹鱼")
		if msg.chair_id == self.my:getSeatNo() or msg.android_chairid == self.my:getSeatNo() or self.robotLayer.robotList[msg.chair_id] ~= nil  then
			if bombFish._fishType == 23 then--局部炸弹
				local size = cc.size(FishModule.m_gameFishConfig.bomb_range_width,FishModule.m_gameFishConfig.bomb_range_height);
				local allFishID = {};
				local pos = cc.p(bombFish:getPositionX(), bombFish:getPositionY());
				-- if self.fishLayer:getChildByName("draw") then
				-- 	self.fishLayer:getChildByName("draw"):removeFromParent();
				-- end
				-- local draw = cc.DrawNode:create()
				-- draw:setAnchorPoint(0,0)
				-- draw:setName("draw");
				-- self.fishLayer:addChild(draw, 1000)
				-- draw:drawPoint((cc.p(pos.x,pos.y)), 4, cc.c4f(1,1,0,1))
				-- draw:drawRect(cc.p(pos.x-size.width/2,pos.y-size.height/2), cc.p(pos.x+size.width/2,pos.y+size.height/2), cc.c4f(1,1,0,1))
				for fishPoint, fish in pairs(self.fishData) do
					if fish:isFishInFixRange(pos.x, pos.y, size) and fish:checkIsBombKilled() and fish:isFishInScreen() then
						allFishID[#allFishID + 1] = fish:getFishID();
					end
					-- draw:drawPoint((cc.p(fish:getPositionX(),fish:getPositionY())), 4, cc.c4f(1,0,0,1))
				end

				self.tableLogic:sendCatchSweepFish(msg.chair_id, msg.fish_id, allFishID, #allFishID);
			elseif bombFish._fishType == 24 then--超级炸弹
				local allFishID = {};
				for fishPoint, fish in pairs(self.fishData) do
					if fish:checkIsBombKilled() and fish:isFishInScreen() then
						allFishID[#allFishID + 1] = fish:getFishID();
					end
				end

				self.tableLogic:sendCatchSweepFish(msg.chair_id, msg.fish_id, allFishID, #allFishID);
			elseif bombFish._fishType >= FishType.FISH_FENGHUANG and bombFish._fishType <= FishType.FISH_KIND_40 then--鱼王
				local allFishID = {};
				for fishPoint, fish in pairs(self.fishData) do 
					if fish._fishType == bombFish._fishType - 30 and fish:isFishInScreen() then
						allFishID[#allFishID + 1] = fish:getFishID();
					end
				end

				self.tableLogic:sendCatchSweepFish(msg.chair_id, msg.fish_id, allFishID, #allFishID);
			else
				luaPrint("客户端未定义炸弹 bombFish._fishType = "..bombFish._fishType);
			end
		end
	else
		luaPrint("未找到炸弹鱼");
	end
end

--炸弹鱼捕获结果
function TableLayer:refreshCatchBombFish(msg)
	self:onCatchBomFish(msg);

	for i=1,msg.catch_fish_count do
		if msg.catch_fish_id[i] then
			luaPrint("msg.catch_fish_id[i] = "..msg.catch_fish_id[i]);
			for k, fish in pairs(self.fishData) do
				if fish:getFishID() == msg.catch_fish_id[i] then
					luaPrint("找到打中的鱼")
					if self.my and self.my:getSeatNo() == msg.chair_id then
						fish:killFish(true,msg.chair_id,false)
					else
						fish:killFish(false,msg.chair_id,false)
					end
					break
				end
			end
		end
	end
end

function TableLayer:onCatchBomFish(msg)
	local tarFish = nil
	local winSize = cc.Director:getInstance():getWinSize();
	local pos = cc.p(winSize.width/2, winSize.height/2);

	for k, fish in pairs(self.fishData) do
		if fish:getFishID() == msg.fish_id then
			tarFish = fish
			local p = self:convertToWorldSpace(cc.p(fish:getPositionX(),fish:getPositionY()));
			pos = self.Sprite_bg:convertToNodeSpace(p);
			break
		end
	end

	if tarFish and tarFish._fishType == 24 and not self.Sprite_bg:getChildByTag(10001) then
		local layer = require("likuipiyu.game.core.quanPingArmatureLayer").new(pos)
		layer:setTag(10001)
		self.Sprite_bg:addChild(layer,100)
	end

	local mult = msg.fish_mulriple--FishModule.m_gameFishConfig.fish_multiple[tarFish._fishType];

	if tarFish then
		self:gainCoin(msg.chair_id, tarFish:getFishPos(), msg.fish_score, tarFish._fishType-1);
		self:gainScore(msg.chair_id, msg.fish_score, tarFish._fishType-1, mult,tarFish:checkIsLiQuan(),msg.user_score);

		if self.my and self.my:getSeatNo() == msg.chair_id then
			tarFish:killFish(true,msg.chair_id)
		else
			tarFish:killFish(false,msg.chair_id)
		end
	else
		self:gainCoin(msg.chair_id, nil, msg.fish_score, msg.fish_kind);--下周
		self:gainScore(msg.chair_id, msg.fish_score, msg.fish_kind, mult,false,msg.user_score);
	end
end

--游戏内提示
function TableLayer:showGameTip(second)
	self.isInClearFishCD = true

	local winSize = cc.Director:getInstance():getWinSize()

	local maskLayer = ccui.ImageView:create("fishing/game/blank.png");
	maskLayer:setScale9Enabled(true)
	maskLayer:setContentSize(cc.size(winSize.width, winSize.height));
	maskLayer:setPosition(cc.p(winSize.width/2, winSize.height/2));
	maskLayer:setTouchEnabled(true);
	maskLayer:setLocalZOrder(20);
	self.Sprite_bg:addChild(maskLayer)

	--bgSprite
	local bgSprite = ccui.ImageView:create("common/tip2.png");
	bgSprite:setPosition(winSize.width/2, winSize.height/2)
	bgSprite:setScale9Enabled(true)
	bgSprite:setScaleX(1.2)
	bgSprite:addTo(maskLayer)

	local tip = FontConfig.createWithSystemFont("等待鱼阵开始，暂时不能出炮哦！ "..second.."s", 28, cc.c3b(40,70,112));
	tip:setPosition(winSize.width/2, winSize.height/2)
	maskLayer:addChild(tip)

	bgSprite:setContentSize(cc.size(tip:getContentSize().width + 50,bgSprite:getContentSize().height))

	local callFunc = function()
		if second > 0 then
			second = second - 1
			tip:setString("等待鱼阵开始，暂时不能出炮哦！ "..second.."s")
		end
		if second == 0 then
			maskLayer:stopAllActions()
			local sequence = transition.sequence(
				{
					cc.DelayTime:create(0.3),
					cc.CallFunc:create(
						function()
							self.isInClearFishCD = false
							maskLayer:removeFromParent()
						end
					)
				}
			)
			maskLayer:runAction(sequence)
		end
	end

	local sequence = transition.sequence(
		{
			cc.DelayTime:create(1.0),
			cc.CallFunc:create(callFunc)
		}
	)
	maskLayer:runAction(cc.RepeatForever:create(sequence))
end

--鱼分兑换
function TableLayer:refreshFishScore(msg)
	luaDump(msg,"鱼分兑换")
	local players = self.playerNodeInfo;
	
	if players[msg.chair_id] ~= nil then
		players[msg.chair_id]:updateScore(tonumber(msg.exchange_fish_score));
	end
end

function TableLayer:updateFishScore(score)
	self.Text_fishScore:setText(FormatNumToString(score));
end

--用户开炮
function TableLayer:userFireRequest(bulletKind, angle, bulletMulr, bulletID, lockFishID, lSeatNo)
	if self.tableLogic then
		self.tableLogic:sendUserFire(bulletKind, angle, bulletMulr, bulletID, lockFishID,lSeatNo);
	end
end

--抓鱼
function TableLayer:catchFishWithNet(bulletNode)
	if bulletNode.myFire then
		if self.tableLogic then
			self.tableLogic:sendCatchFish(bulletNode.paoLevel, bulletNode.id, self.my.cur_zi_dan_cost, bulletNode.sendAttackFishList[1],self.tableLogic:getMySeatNo());
		end
		-- if bulletNode.m_attackFishList[1]._fishType == FishType.FISH_LONGXIA then
		--	 self.tableLogic:sendHitFishLk(bulletNode.sendAttackFishList[1]);
		-- end
	elseif bulletNode:isRobot() and self.playerNodeInfo[bulletNode.charID] and self.playerNodeInfo[bulletNode.charID]:getIsAlive()==true then
		-- Hall.showTips("机器人捕鱼了charID ="..charID.."  ,"..self.playerNodeInfo[bulletNode.charID].cur_zi_dan_cost);
		if self.tableLogic then
			self.tableLogic:sendCatchFish(bulletNode.paoLevel, bulletNode.id, self.playerNodeInfo[bulletNode.charID].cur_zi_dan_cost, bulletNode.sendAttackFishList[1],bulletNode.charID-1);
		end
	end
end

function TableLayer:getLockFish(lockFishID)
	if lockFishID <= 0 then
		return nil;
	end

	if lockFishID ~= 65535 then
		--当前鱼不存在
		for fishPoint, fish in pairs(self.fishData) do
			if fish._fishID ==  lockFishID then
				if fish:isFishValid()then
					return fish;
				else
					break;
				end
			end
		end
	else
		local size = cc.size(220,80);
		local pos = cc.p(self.my:getPositionX(),self.my:getPositionY()+3);

		local size1 = cc.size(100,160);
		local pos1 = cc.p(self.my:getPositionX(),self.my:getPositionY()+35);

		local tempLockFish = nil;
		for fishPoint, fish in pairs(self.fishData) do
			if fish and not tolua.isnull(fish) then
				if fish:isFishValid() and fish:isFishOutScreen() == false and fish:isFishBelowPlayer(pos,size) == false and fish:isFishBelowPlayer(pos1,size1) == false then
					if(tempLockFish == nil)then
						tempLockFish = fish;
					elseif( tempLockFish and fish._multiple > tempLockFish._multiple)then
						tempLockFish = fish;
					end
				end
			else
				self.fishData[fishPoint] = nil;
			end
		end

		return tempLockFish
	end

	return nil;
end

function TableLayer:setLockFish()
	if self.isLockFish and self.my and self.m_changeGameTable == false then
		if(self:checkFishValid(self.my.lockFish) == false)then
			local lockFish = self:getLockFish(65535);
			self.my:setLockFish(lockFish)
		end
	end
end

function TableLayer:aimLockFish(pos)
	for i=0,PLAY_COUNT-1 do
		if self.playerNodeInfo[i] then
			if(self.m_changeGameTable == false)then
				if(self.playerNodeInfo[i].lockFish and self:checkFishValid(self.playerNodeInfo[i].lockFish))then
					if self.playerNodeInfo[i].lSeatNo == self.my.lSeatNo then
						self.playerNodeInfo[i]:showAimLine(pos);
					else
						self.playerNodeInfo[i]:showAimLine();
					end
				else
					self.playerNodeInfo[i]:setLockFish(nil);
					self.playerNodeInfo[i]:hideAimLine();
				end
			else
				self.playerNodeInfo[i]:setLockFish(nil);
				self.playerNodeInfo[i]:hideAimLine();
			end
		end
	end
end

function TableLayer:gainScore(chairID, score, kind, fishMulti, isLiquan, realScore)
	if isLiquan == nil then
		isLiquan = false;
	end

	if isCrit == nil then
		isCrit = false;
	end

	if self.playerNodeInfo[chairID] then
		self.playerNodeInfo[chairID]:changeScore(score, kind, fishMulti,isLiquan,isCrit,realScore);
	end
end

function TableLayer:gainCoin(chairID, filshPos, score, multi, isHaveHuafei)
	if not chairID then
		luaPrint("GameLayer:gainCoin(chairID, filshPos, score, multi, isLiquan) err")
		return
	end

	if(not filshPos)then
		filshPos = getScreenCenter();
	end

	local flip = 1;

	if not self.playerNodeInfo[chairID]then
		return;
	end

	local player = self.playerNodeInfo[chairID];
	local target =player:getParent():convertToWorldSpace(cc.p(player:getPositionX(),player:getPositionY()))

	local coinTag = 1;
	if chairID == self.tableLogic._mySeatNo then
		coinTag = 1
	else
		coinTag = 2
	end

	self:createCurrencyAnimation(target,filshPos,score,flip,coinTag,multi,isHaveHuafei)

	--金币提示
	if(score and score > 0)then
		--抓到鱼了一个x,y值给label
		local randomX = math.random(-30,30)
		local randomY = math.random(-30,30)

		--获得金币数目飞入口袋
		local content = DataCacheManager:createEffect(COIN_TEXT)
		content:setData(score,chairID == self.tableLogic._mySeatNo)
		
		content:setPosition(cc.p(filshPos.x + randomX,filshPos.y + randomY))
		self.coinLayer:addChild(content)

		content:playAction()
	end
end

function TableLayer:getDropGoods(goodsInfoList , chairID ,fishPos)
	if true then
		return
	end
	if goodsInfoList == nil then
		return
	end

	if chairID ~= self.tableLogic:getMySeatNo() then
		return;
	end

	local count = 0;
	local flag = false;
	local goodsRedInfo = false;
	for k,v in pairs(goodsInfoList) do
		if v.goodsID > 0 and v.goodsCount > 0 then
			count = count + 1;
			if v.goodsID == GOODS_REDENVELOPES then
				flag = true;
				goodsRedInfo = v;
			end
		end
	end

	if count == 0 then
		return;
	end

	local player = self.playerNodeInfo[chairID];
	if not player or not self.my then
		luaPrint("当前用户不存在 chairID = "..chairID.."  自己的座位是 thisChairID = "..self.my.userInfo.chairID)
		return
	end
	-- luaDump(goodsInfoList,"掉落的物品")
	if fishPos == nil then
		fishPos = getScreenCenter();
	end

	if flag == true then
		count = count - 1;
	end

	local goodsItemWidth = 130
	local goodsItemHeight = 256
	local winSize = cc.Director:getInstance():getWinSize()

	if fishPos.x-goodsItemWidth/2 <= 0 then
		fishPos.x = goodsItemWidth;
	elseif fishPos.x + goodsItemWidth * (count-1) + goodsItemWidth/2 > winSize.width then
		-- fishPos = getScreenCenter();
		fishPos.x = winSize.width - goodsItemWidth*count
	end

	if fishPos.y - goodsItemHeight/2 < 0 then
		fishPos.y = goodsItemHeight;
	elseif fishPos.y + goodsItemHeight/2 > winSize.height then
		fishPos.y = winSize.height - goodsItemHeight;
	end

	local i = 1;
	for k,goodsInfo in pairs(goodsInfoList) do
		if goodsInfo.goodsID > 0 and goodsInfo.goodsCount > 0 and goodsInfo.goodsID ~= GOODS_REDENVELOPES then
			local target = cc.p(player:getPositionX(),player:getPositionY());
			local wordPos = player:getParent():convertToWorldSpace(target)

			--其他物品加到背包
			local getDropGoodsNode = require("likuipiyu.game.core.getDropGoods").new(goodsInfo)
			getDropGoodsNode:setPosition(cc.p(fishPos.x + goodsItemWidth * (i-1),fishPos.y))
			getDropGoodsNode:addLinePathTo(wordPos)
			getDropGoodsNode:setLocalZOrder(100)
			self.Sprite_bg:addChild(getDropGoodsNode)

			i = i + 1;
		end
	end

	if flag == true then--红包动画
		if self.redEnvelopesNode then
			-- local wordPos = self.fishLayer:convertToWorldSpace(fishPos);
			self.redEnvelopesNode:playGetRedEnvelopesAction(goodsRedInfo,fishPos);
		end
	end
end

function TableLayer:createCurrencyAnimation(target,filshPos,multi,flip,coinTag,fishkind,isHaveHuafei)
	luaPrint("multi =------------==  "..multi)
	local num = multi;
	if (num <= 0) then
		return;
	end

	if isHaveHuafei == nil then
		isHaveHuafei = false;
	end

	luaPrint("分数 ： "..num);
	if fishkind <= 8 then
		num = 4;
	elseif	fishkind <= 14 then
		num = 6;
	elseif	fishkind <= 18 then
		num = 10;
	elseif	fishkind <= 21 then
		num = 15;
	elseif	fishkind <= 30 then
		num = 10;
	else
		-- return;
		num = 10;
	end

	if isHaveHuafei == true then
		num = num + 1;
	end
	
	-- num = math.floor(multi / 100);

	-- if num > 30 then
	-- 	num = 30
	-- end

	local rowCount = 1;
	local lineCount = 1;
	local coinWight = 60;
	local coinHeight = 60;
	local coinNodePosX=filshPos.x;
	local coinNodePosY=filshPos.y;
	local coinEndPosX = 1;
	--分金币有几排

	if (num < 8) then
		rowCount = num;
	elseif (num <= 10) then
		rowCount = 5;
	elseif (num <= 10) then
		rowCount = 5;
	elseif (num <= 12) then
		rowCount = 6;
	elseif (num <= 16) then
		rowCount = 8;
	elseif (num <= 18) then
		rowCount = 5;
	elseif (num <= 20) then
		rowCount = 10;
	elseif (num <= 40) then
		rowCount = 10;
	elseif (num <= 60) then
		rowCount = 10;
	else
		rowCount = 10;
	end

	if(num%rowCount ~= 0)then
		num = num + (rowCount - (num%rowCount));
	end

	--起点
	coinNodePosX = coinNodePosX - coinWight*rowCount/2;

	if(num % rowCount ~= 0)then
		coinNodePosY = coinNodePosY + coinHeight*(num/rowCount+1)/2;
	else
		coinNodePosY = coinNodePosY + coinHeight*(num/rowCount)/2;
	end

	coinEndPosX = filshPos.x + coinWight*num/2;

	--金币从中间依次开始运动
	local middleIndex = math.ceil(rowCount/2.0);
	if (rowCount%2 == 0) then
		middleIndex = middleIndex + 0.5;
	end

	local j = 1;
	local moveFangxiang = 1;

	-- if (math.abs(filshPos.x - target.x) < 80) then
	-- 	moveFangxiang = 0;
	-- else
		if (filshPos.x > target.x) then
			moveFangxiang = -1;
		end		
	-- end
	luaPrint("num ---------------- "..num)
	for i=1,num do
		if((i-1)%rowCount == 0)then
			lineCount = lineCount+1;
			j = 1;
		end	

		local delay = 0.1;
		
		if (moveFangxiang == 0) then
			if (rowCount%2 == 0) then
				delay = 0.1 * (math.abs((middleIndex - j)) + 0.5 - 1);
			else
				delay = 0.1 * (math.abs(middleIndex - j));	
			end
		elseif (moveFangxiang == 1) then
			delay = 0.1 * (rowCount - j + 1);
		else
			delay = 0.1 * j; 
		end

		j = j + 1;

		--缓存创建
		local coin = DataCacheManager:createCoin(isHaveHuafei,coinTag);
		coin:setPosition(cc.p(coinNodePosX + coinWight*((i-1)%rowCount) + 10,coinNodePosY - coinHeight * (lineCount-1) - 10));
		coin:addLinePathTo(target,flip);
		self.coinLayer:addChild(coin);
		coin:goCoin(delay);
		isHaveHuafei = false;
	end
	audio.playSound("sound/deay_coin.mp3");
end

--救济金处理
function TableLayer:requestReliefMoney()
	if globalUnit:getIsRequestReliefMoney() == false then
		Hall.showTips("您的金币不足，请前往商城购买！");
		return;
	end

	local tmCha = 5;
	
	if self.reliefTm then
		tmCha = os.time() - self.reliefTm;
	end

	if self.isReliefMoneyCode == true and tmCha < 6 then--已发送请求 ，5秒内不再请求
		return;
	elseif self.isReliefMoneyCode == false and globalUnit:getIsRequestReliefMoneyStatue() == true then--救济金正在处理
		return;
	end

	self.reliefTm = os.time();

	globalUnit:setIsRequestReliefMoneyStatue(true);
	self.tableLogic:sendRequestReliefMoney();

	self.isReliefMoneyCode = true;
end

function TableLayer:gameReliefMoney(msg)
	luaDump(msg,"救济金")
	local ret = msg.ret;

	self.isReliefMoneyCode = false;

	if msg.JiuJiTimes == 2 then--次数已用完
		globalUnit:setIsRequestReliefMoney(false);
	end

	if self.my.score >= FishModule.m_gameFishConfig.min_bullet_multiple then
		return;
	end

	if ret == 0 then
		if self.my then
			local paotaiBg = self.my.cannon.paoTai
			if paotaiBg:getChildByName("freeCoin") then
				return;
			end

			local layer = require("likuipiyu.game.core.freeCoinNode").new(2,5,function() globalUnit:setIsRequestReliefMoneyStatue(false); self:sendRequestReliefMoneyResult(); end)			
			layer:setPosition(cc.p(paotaiBg:getContentSize().width/2,200))
			paotaiBg:addChild(layer,100)
			layer:setName("freeCoin");
		end
	else--if ret == 1 then
		self:createBankLayer();
	end
end

function TableLayer:hideFreeCoin(ftype)
	if ftype == 1 then
		if self.my then
			local paotaiBg = self.my.cannon.paoTai
			if paotaiBg:getChildByName("freeCoin") then
				paotaiBg:removeChildByName("freeCoin");
				globalUnit:setIsRequestReliefMoneyStatue(false);
				self:reqOnlineTime(); --请求在线奖励同步时间
			end
		end
	elseif ftype == 2 then
		local layerOnline = self:getChildByName("OnlinefreeCoin");
		if layerOnline then
			layerOnline:removeFromParent();
		end
	end
end

--发送救济金领取
function TableLayer:sendRequestReliefMoneyResult()
	self.tableLogic:sendRequestReliefMoneyResult();
end

--救济金领取结果
function TableLayer:gameReliefMoneyResult(msg)
	local ret = msg.ret;

	local str = ""
	if ret == 0 then
		local lSeatNo = self.tableLogic:getlSeatNo(msg.UserID);

		if self.playerNodeInfo[lSeatNo] then
			self.playerNodeInfo[lSeatNo]:updateScore(msg.Score);
		end

		local remainingCount = 2 - msg.JiuJiTimes;
		if remainingCount < 0 then
			remainingCount = 0
		end

		str = "成功领取救济金:"..msg.OperatScore.."金币,今日剩余"..remainingCount.."次";
	else
		str = "救济金领取成功！";
	end

	if msg.UserID == PlatformLogic.loginResult.dwUserID then
		Hall.showTips(str);
		self:reqOnlineTime(); --请求在线奖励同步时间
	end
end

--升级
function TableLayer:gameUserLevelUp(msg)
	local leave = msg.PlayerLevel;
	local duserid = msg.UserID;
	local myuserid = PlatformLogic.loginResult.dwUserID
	local players = self.playerNodeInfo;

	if duserid == myuserid then
		audio.playSound("sound/ding_marry.mp3", false);
		-- GamePromptLayer:create():showPrompt("恭喜你升到"..leave.."级");
		local shenjiAct = createSkeletonAnimation("shengji","game/shengji/shengji.json", "game/shengji/shengji.atlas");
		if shenjiAct then
			shenjiAct:setAnchorPoint(cc.p(0.5,0.5));
			shenjiAct:setPosition(cc.p(640,350));
			shenjiAct:setAnimation(0,"shengji", false);
			self:addChild(shenjiAct);
		end

		local labelValue = FontConfig.createWithCharMap(leave, "game/shengji/zitiao.png", 73, 99, "0")--FontConfig.createLabel(FontConfig.gFontConfig_28, self.cur_zi_dan_cost, cc.c3b(255,224,20));
		shenjiAct:addChild(labelValue);
		labelValue:setPosition(cc.p(-5,35))
		labelValue:setScale(0.8) 
		shenjiAct:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function() shenjiAct:removeFromParent(); end)))
	end

	for i=1,4 do
		local userInfo = self.tableLogic:getUserBySeatNo(i-1);
		if userInfo and userInfo.dwUserID == duserid then
			players[i-1]:updateLv(leave);
		end
	end
end

--创建保险柜界面
function TableLayer:createBankLayer()
	if device.platform == "ios" and appleView == 1 then
		return;
	end

	-- if true then
	-- 	-- Hall.showTips("请到大厅进行充值，游戏内暂不支持");
	-- 	return;
	-- end

	if self.Sprite_bg:getChildByName("banklayer") then
		return;
	end

	if roleData ~= nil then
		roleData.Score = self.my.score;	
		local layer = BankLayer:create(roleData);
		layer:setName("banklayer");
		layer:setCallBack(function(type,value) self:sendExchangeGold(type,value); end, function() globalUnit:setIsRequestReliefMoneyStatue(false); end)
		layer:setLocalZOrder(101);
		self.Sprite_bg:addChild(layer); 
	end
end

--发送存取金币
function TableLayer:sendExchangeGold(ftype,value)
	local msg = {};
	msg.Score = value;
	luaDump(msg,"发送存取")
	if ftype == 1 then
		RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_GET_SCORE,msg,RoomMsg.CMD_C_GET_SCORE) --角色取分
	else
		RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_STORE_SCORE,msg,RoomMsg.CMD_C_STORE_SCORE) --角色存分
	end
end

--存金币结果
function TableLayer:gameBankSaveScoreResult(msg)
	local text = "";
	luaDump(msg,"存取结果")
	if msg.ret == 0 then
		text = "恭喜您操作成功！";

		local lSeatNo = self.tableLogic:getlSeatNo(msg.UserID);

		if self.playerNodeInfo[lSeatNo] then
			self.playerNodeInfo[lSeatNo]:updateScore(msg.Score);
		end

		local layer = self.Sprite_bg:getChildByName("banklayer")
		if layer then
			msg.Score = msg.OperatScore;
			layer:refreshUserGameSaveInfo(msg);
		end
	elseif msg.ret == 1 then
		text = "用户ID不存在！";
	elseif msg.ret == 2 then
		text = "角色ID不存在！";
	elseif msg.ret == 3 then
		text = "金币不足！";
	elseif msg.ret == 4 then
		text = "您正在游戏中！";
	else
		text = "操作失败！";
	end

	if msg.UserID == PlatformLogic.loginResult.dwUserID then
		GamePromptLayer:create():showPrompt(text);
	end
end

--取金币结果
function TableLayer:gameBankGetScoreResult(msg)
	local text = "";
	luaDump(msg,"存取结果")
	if msg.ret == 0 then
		text = "恭喜您操作成功！";
		local lSeatNo = self.tableLogic:getlSeatNo(msg.UserID);

		if self.playerNodeInfo[lSeatNo] then
			self.playerNodeInfo[lSeatNo]:updateScore(msg.Score);
		end

		local layer = self.Sprite_bg:getChildByName("banklayer")
		if layer then
			msg.Score = msg.OperatScore;
			layer:refreshUserGameGetInfo(msg);
		end
	elseif msg.ret == 1 then
		text = "用户ID不存在！";
	elseif msg.ret == 2 then
		text = "角色ID不存在！";
	elseif msg.ret == 3 then
		text = "金币不足！";
	elseif msg.ret == 4 then
		text = "您正在游戏中！";
	else
		text = "操作失败！";
	end

	if msg.UserID == PlatformLogic.loginResult.dwUserID then
		GamePromptLayer:create():showPrompt(text);
	end
end

function TableLayer:showBossWarning(fishType)
	if self.specDeath == nil then
		local winSize = cc.Director:getInstance():getWinSize();
		self.specDeath = createSkeletonAnimation("bosschuchang","boosWaring/bosschuchang.json", "boosWaring/bosschuchang.atlas");
		if self.specDeath then
			self.specDeath:setPosition(cc.p(winSize.width/2, winSize.height/2));
			self.specDeath:setAnchorPoint(cc.p(0.5,0.5));
			self.specDeath:setLocalZOrder(100);
			self:addChild(self.specDeath);
		end
	end

	if self.specDeath then
		self.specDeath:setVisible(true);
		local name = {"guafuxiezi","jinjiadujiaoshou","dongfangjiaolong","shenniaohuofenghuang"};
		self.specDeath:setAnimation(fishType-40,name[fishType-40], false);
		audio.playSound("sound/boss/jingbao.mp3");
		performWithDelay(self,function()
			audio.playMusic("sound/boss/bossbg.mp3",true)
			if audio.isMusicPlaying() ~= true then
				audio.playMusic("sound/boss/bossbg.mp3",true)
			end
			end,3)
		self.specDeath:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function() self.specDeath:setVisible(false) end)))
	end
end

function TableLayer:showBossDeadWarning()
	if self.bossDeadAnimate == nil then
		local size = cc.Director:getInstance():getWinSize();

		self.bossDeadAnimate = createSkeletonAnimation("bosstaopao","boosWaring/bosstaopao/bosstaopao.json", "boosWaring/bosstaopao/bosstaopao.atlas");
		if self.bossDeadAnimate then
			self.bossDeadAnimate:setPosition(size.width/2,size.height/2);
			self.bossDeadAnimate:setLocalZOrder(102)
			self.Sprite_bg:addChild(self.bossDeadAnimate);
		end
	end

	if self.bossDeadAnimate then
		self.bossDeadAnimate:setVisible(true);
		self.bossDeadAnimate:setAnimation(1,"bosstaopao", false);
		performWithDelay(self,function() self.bossDeadAnimate:setVisible(false); end,5)
	end
end

--广播消息
function TableLayer:gameWorldMessage(event)
	local event = event._usedata

	local msg = event.data;
	local msgType = event.messageType;

	if msgType == 0 then
		Hall:showScrollMessage(event,MESSAGE_ROLL);
	elseif msgType == 1 then
		Hall:showFishMessage(event)
	elseif msgType == 3 then--停服更新
		-- Hall:showFishMessage(event);
	end
end

--任务列表
function TableLayer:gameGetTaskList(msg,code)
	 if self.TaskList == nil then
		self.TaskList = {};
	end
	if code == 0 then
		table.insert(self.TaskList, msg);
	elseif code == 1 then
		local layer = self:getChildByName("TaskLayer")
		if layer then
			layer:updateTastLlist(self.TaskList);
		end

		local count = 0
		for i,v in ipairs(self.TaskList) do
		 	if v.Task ==1 then
		 		count = count +1;
		 	end
		end 

		if self.newbg then
			if count == 0 then
					self.newbg:setVisible(false)
					self.Atlnum:setString("")
			else
				self.newbg:setVisible(true);
				self.Atlnum:setString(count);
			end
		end

		self.TaskList = {};
	else
		luaPrint(event, "GetTaskList error");
	end
end

--任务奖励
function TableLayer:gameRewarldRes(msg)
	-- luaDump(msg,"任务奖励")
	local str = "";

	if msg.ret == 0 then
		if msg.Score > 0 then
			local lSeatNo = self.tableLogic:getlSeatNo(msg.UserID);

			if self.playerNodeInfo[lSeatNo] then
				self.playerNodeInfo[lSeatNo]:updateScore(msg.Score);
			end

			str = "领取成功,奖励已发放！";
		else
			str = "领取失败";
		end
	else
		str = "领取失败";
	end

	if msg.UserID == PlatformLogic.loginResult.dwUserID then
		self:sendTaskReq();
		GamePromptLayer:create():showPrompt(str);
	end
end

--请求任务列表
function TableLayer:sendTaskReq()
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;

	RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_GET_TASKLIST,msg,RoomMsg.CMD_C_GET_TASKLIST)--获取邮件列表
end

--一键领取
function TableLayer:onClickReceiveAll()
	self.TaskList = {};

	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.TaskID = 0;
	luaDump(msg,"一键领取")
	RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_UPDATE_TASK,msg,RoomMsg.CMD_C_UPDATETASKLIST)
end

function TableLayer:onClickReceive(taskid)
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.TaskID = taskid;
	luaDump(msg,"领取")
	RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_UPDATE_TASK,msg,RoomMsg.CMD_C_UPDATETASKLIST)
end

--同步时间
function TableLayer:createOnlineReward(time)
	-- if globalUnit:getGameMode() then
	-- 	return;
	-- end

	-- local size = cc.Director:getInstance():getWinSize();
	-- local layer = require("likuipiyu.game.core.OnlineFreeCoinNode").new(1,time,function() self:reqOnlineReward(); end)			
	-- layer:setPosition(cc.p(size.width-70,size.height*0.85))
	-- self.Sprite_bg:addChild(layer,30)
	-- layer:setLocalZOrder(30)
	-- layer:setName("OnlinefreeCoin");
	-- layer:setRecCallBack(function() self:reqOnlineTime();end);
end

--同步时间
function TableLayer:showUpdataTime(msg)
	-- if globalUnit:getGameMode() then
	-- 	return;
	-- end

	-- if self.updateOnlineTime then
	-- 	self:stopAction(self.updateOnlineTime);
	-- 	self.updateOnlineTime = nil;
	-- end
	-- local layer = self.Sprite_bg:getChildByName("OnlinefreeCoin");
	-- if layer then
	-- 	layer:removeFromParent();
	-- end
	-- self:createOnlineReward(math.ceil(120 - msg.times/1000))
end

--领取在线奖励
function TableLayer:showRewarldOnline(msg)
	-- if globalUnit:getGameMode() then
	-- 	return;
	-- end

	-- local size = cc.Director:getInstance():getWinSize();
	-- if self.updateOnlineReward then
	-- 	self:stopAction(self.updateOnlineReward);
	-- 	self.updateOnlineReward = nil;
	-- end
	-- self.my:updateScore(msg.fish_score)
	-- self:reqOnlineTime();
	-- self:gainCoin(self.my:getSeatNo(),cc.p(size.width-70,size.height*0.85),msg.score,1)
end

--完成任务未领取数量 
function TableLayer:gameTaskcount(msg)
	if msg.Taskcount > 0 then
		if self.newbg then
			self.newbg:setVisible(true);
			self.Atlnum:setString(msg.Taskcount);
		end
	end
end

--请求同步在线奖励时间
function TableLayer:reqOnlineTime()
	-- if globalUnit:getGameMode() then
	-- 	return;
	-- end

	-- if self.updateOnlineTime then
	-- 	self:stopAction(self.updateOnlineTime);
	-- 	self.updateOnlineTime = nil;
	-- else
	-- 	self.tableLogic:sendUserUpdataTime();
	-- end
	
 -- 	self.updateOnlineTime = schedule(self, function() self.tableLogic:sendUserUpdataTime(); end, 1)
end

--请求领取在线奖励
function TableLayer:reqOnlineReward()
	-- if globalUnit:getGameMode() then
	-- 	return;
	-- end

	-- if self.updateOnlineReward then
	-- 	self:stopAction(self.updateOnlineReward);
	-- 	self.updateOnlineReward = nil;
	-- else
	-- 	self.tableLogic:sendUserRewardOnline();
	-- end
	
	-- self.updateOnlineReward = schedule(self, function() self.tableLogic:sendUserRewardOnline(); end, 1)
end

--充值刷新金币
function TableLayer:gameBuymoney(msg)
	local lSeatNo = self.tableLogic:getlSeatNo(msg.UserID);

	if self.playerNodeInfo[lSeatNo] then
		self.playerNodeInfo[lSeatNo]:updateScore(msg.score);
	end
end

function TableLayer:refreshGoodsButton(event)
	if globalUnit:getGameMode() then
		return;
	end
	
	luaDump(event._usedata,"goodsbtn");
	if self.isSkillClicking == nil then
		self.isSkillClicking = {};
	end

	local x = 0;
	local y = 10;
	local dis=0;
	local size = cc.Director:getInstance():getWinSize();
	local count = #GameGoodsInfo:getGoodsListInfo(1);
	local w = 74;
	local h = 84;
	local anch = cc.p(0.5,0);
	local offsetX = 0;
	
	dis = 20;
	x = size.width/2 - count*w/2 - dis*(count-1)/2 + w/2
	offsetX = w + dis;

	if globalUnit.isEnterRoomMode ~= true then --单人场
		x =  x - (size.width-size.width/3.5-size.width/2);
	end

	local goodsInfo = GameGoodsInfo:getGoodsInfoByID(GOODS_CALLFISH);

	if self.my == nil then
		return;
	end

	if goodsInfo then--召唤
		local wp = self.Sprite_bg:convertToWorldSpace(cc.p(x,y));
		local lp = self.my:convertToNodeSpace(wp);
		local zhaohuanBtn = ccui.Button:create(goodsInfo.goodsIcon,goodsInfo.goodsIcon);
		zhaohuanBtn:setAnchorPoint(anch);
		zhaohuanBtn:setPosition(lp);
		zhaohuanBtn:setLocalZOrder(100);
		zhaohuanBtn:setTouchEnabled(true);
		-- self.Sprite_bg:addChild(zhaohuanBtn);
		self.my:addChild(zhaohuanBtn)
		zhaohuanBtn:addClickEventListener(
			function(sender)
				self:onclickZhaohuanBtn(sender);
			end);
		self.zhaohuanBtn = zhaohuanBtn;

		self:createGoodsBg(self.zhaohuanBtn,goodsInfo);
		self.zhaohuanProgess = self:openProgressTimer(self.zhaohuanBtn)
		self.zhaohuanLabel = self:createGoodsNumLabel(self.zhaohuanBtn,goodsInfo);
		self.zhaohuanLabel:setString(goodsInfo.goodsCount);

		self.isSkillClicking[GOODS_CALLFISH] = false;
	end

	goodsInfo = GameGoodsInfo:getGoodsInfoByID(GOODS_KUANGBAO);

	if goodsInfo then--狂暴
		x = x + offsetX
		local wp = self.Sprite_bg:convertToWorldSpace(cc.p(x,y));
		local lp = self.my:convertToNodeSpace(wp);
		local kuangbaoBtn = ccui.Button:create(goodsInfo.goodsIcon,goodsInfo.goodsIcon);
		kuangbaoBtn:setAnchorPoint(anch);
		kuangbaoBtn:setPosition(lp);
		kuangbaoBtn:setLocalZOrder(100);
		kuangbaoBtn:setTouchEnabled(true);
		-- self.Sprite_bg:addChild(kuangbaoBtn);
		self.my:addChild(kuangbaoBtn)
		kuangbaoBtn:addClickEventListener(
			function(sender)
				self:onclickKuangbaoBtn(sender);
			end);
		self.kuangbaoBtn = kuangbaoBtn;

		self:createGoodsBg(self.kuangbaoBtn,goodsInfo);
		self.kuangbaoProgess = self:openProgressTimer(self.kuangbaoBtn)
		self.kuangbaoLabel = self:createGoodsNumLabel(self.kuangbaoBtn,goodsInfo);
		self.kuangbaoLabel:setString(goodsInfo.goodsCount);

		self.isSkillClicking[GOODS_KUANGBAO] = false;
	end

	goodsInfo = GameGoodsInfo:getGoodsInfoByID(GOODS_BINGDONG);

	if goodsInfo then--冰冻
		x = x + offsetX
		local wp = self.Sprite_bg:convertToWorldSpace(cc.p(x,y));
		local lp = self.my:convertToNodeSpace(wp);
		x = x + offsetX
		local bingdongBtn = ccui.Button:create(goodsInfo.goodsIcon,goodsInfo.goodsIcon);
		bingdongBtn:setAnchorPoint(anch);
		bingdongBtn:setPosition(lp);
		bingdongBtn:setLocalZOrder(100);
		bingdongBtn:setTouchEnabled(true);
		-- self.Sprite_bg:addChild(bingdongBtn);
		self.my:addChild(bingdongBtn)
		bingdongBtn:addClickEventListener(
			function(sender)
				self:onclickBingdongBtn(sender);
			end);
		self.bingdongBtn = bingdongBtn;

		self:createGoodsBg(self.bingdongBtn,goodsInfo);
		self.bingdongProgess = self:openProgressTimer(self.bingdongBtn)
		self.bingdongLabel = self:createGoodsNumLabel(self.bingdongBtn,goodsInfo);
		self.bingdongLabel:setString(goodsInfo.goodsCount);

		self.isSkillClicking[GOODS_BINGDONG] = false;
	end
end

--扇形进度条
function TableLayer:openProgressTimer(parent)
	local amrkIcon = cc.Sprite:create("goods/progress.png");
	local myProgressTimer = cc.ProgressTimer:create(amrkIcon)
	myProgressTimer:setAnchorPoint(cc.p(0.5,0.5));
	myProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	myProgressTimer:setPercentage(100)
	myProgressTimer:setVisible(false);
	myProgressTimer:setPosition(cc.p(parent:getContentSize().width/2,parent:getContentSize().height/2))

	parent:addChild(myProgressTimer)

	return myProgressTimer;
end

function TableLayer:createGoodsBg(parent,goodsInfo)
	if goodsInfo == nil then
		return;
	end

	local image = ccui.ImageView:create(goodsInfo.goodsBg);
	image:setPosition(parent:getContentSize().width/2,parent:getContentSize().height/2);
	parent:addChild(image);

	return image;
end

function TableLayer:createGoodsNumLabel(parent,goodsInfo)
	if goodsInfo == nil then
		return;
	end

	local bg = ccui.ImageView:create(goodsInfo.goodsTextBg);
	bg:setPosition(parent:getContentSize().width,parent:getContentSize().height);
	bg:setAnchorPoint(1,1);
	parent:addChild(bg);

	local label = FontConfig.createWithCharMap(0,goodsInfo.goodsTextNum.image,goodsInfo.goodsTextNum.width,goodsInfo.goodsTextNum.height,goodsInfo.goodsTextNum.char)--FontConfig.createWithSystemFont("0",16,FontConfig.colorWhite);
	label:setAnchorPoint(0.5,0.5);
	label:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2));
	bg:addChild(label);

	return label;
end

function TableLayer:onclickZhaohuanBtn(sender)
	if self.isCreateMatrix == true then
		Hall.showTips("鱼阵期间，不能使用召唤卡");
		return;
	end

	if self.isCallFish == true then
		return;
	end

	if self.isSkillClicking[GOODS_CALLFISH] == true then
		return;
	end

	self.isSkillClicking[GOODS_CALLFISH] = true;

	GameGoodsInfo:sendUseGoodsRequest(GOODS_CALLFISH,-1);

	performWithDelay(self,function() self.isSkillClicking[GOODS_CALLFISH] = false; end,5):setTag(2222+GOODS_CALLFISH);
end

function TableLayer:onclickKuangbaoBtn(sender)
	if self.isFastShoot == true then
		return;
	end

	if self.isSkillClicking[GOODS_KUANGBAO] == true then
		return;
	end

	self.isSkillClicking[GOODS_KUANGBAO] = true;

	GameGoodsInfo:sendUseGoodsRequest(GOODS_KUANGBAO,-1);

	performWithDelay(self,function() self.isSkillClicking[GOODS_KUANGBAO] = false; end,5):setTag(2222+GOODS_KUANGBAO);
end

function TableLayer:onclickBingdongBtn(sender)
	if self.isCreateMatrix == true then
		Hall.showTips("鱼阵期间，不能使用冰冻卡");
		return;
	end

	if self.isBingdongFish == true then
		return;
	end

	if self.isSkillClicking[GOODS_BINGDONG] == true then
		return;
	end

	self.isSkillClicking[GOODS_BINGDONG] = true;

	GameGoodsInfo:sendUseGoodsRequest(GOODS_BINGDONG,-1);

	performWithDelay(self,function() self.isSkillClicking[GOODS_BINGDONG] = false; end,5):setTag(2222+GOODS_BINGDONG);
end

--技能使用
function TableLayer:refreshGoodsOperation(event)
	local data = event._usedata;
	if self.isSkillClicking == nil then
		self.isSkillClicking = {};
	end
	self.isSkillClicking[data.goodsID] = false;
	self:stopActionByTag(2222+data.goodsID);

	local str = "";

	if data.ret == 0 then
		self:refreshDropGoods(event);

		--鱼阵期间，除狂暴外，其他技能不能使用
		if self.isCreateMatrix and data.goodsID ~= GOODS_KUANGBAO then
			return;
		end

		if data.goodsID == GOODS_KUANGBAO then--狂暴
			if self.isFastShoot == false then
				self:fastShoot(true)
			else
				Hall.showTips("狂暴卡正在使用中");
			end
		elseif data.goodsID == GOODS_CALLFISH then
			if self.isCallFish == false then
				-- self:callFish(true)
			else
				Hall.showTips("召唤卡正在使用中");
			end
		elseif data.goodsID == GOODS_BINGDONG then
			self:frozenFish(true,true);--可叠加
		end
	elseif data.ret == 1 then
		str = GameGoodsInfo:getGoodsName(data.goodsID).."数量不足！";
	elseif data.ret == 2 then
		--todo
	elseif data.ret == 3 then
		--todo
	end

	if str ~= "" then
		Hall.showTips(str);
	end
end

--掉落物品
function TableLayer:refreshDropGoods(event)
	local data = event._usedata;

	if data.goodsID == GOODS_KUANGBAO then
		if self.kuangbaoLabel then
			self.kuangbaoLabel:setString(data.goodsCount);
		end
	elseif data.goodsID == GOODS_CALLFISH then
		if self.zhaohuanLabel then
			self.zhaohuanLabel:setString(data.goodsCount);
		end
	elseif data.goodsID == GOODS_BINGDONG then
		if self.bingdongLabel then
			self.bingdongLabel:setString(data.goodsCount);
		end
	end
end

function TableLayer:synGoodsOperation(event)
	local data = event._usedata;
	luaDump(data,"synGoodsOperation")

	local seatNo = self.tableLogic:getlSeatNo(data.UserID);

	if data.goodsID == GOODS_KUANGBAO then--狂暴
		self.playerNodeInfo[seatNo].cannon:setFastFireTime(FAST_SKILL_CD_TIME);
	elseif data.goodsID == GOODS_CALLFISH then
		-- self.playerNodeInfo[seatNo].cannon:setCallFishTime(CALLFISH_SKILL_CD_TIME);
	elseif data.goodsID == GOODS_BINGDONG then
		self:frozenFish(true,2);--可叠加
	end
end

function TableLayer:synDropGoods(event)
	local data = event._usedata;
end

function TableLayer:fastShoot(isFastShoot)
	if self.my then
		if(isFastShoot==true)then
			self.my.cannon:setFast(true);
			self.isFastShoot=true;
			--进度条
			if self.kuangbaoProgess then
				self.kuangbaoProgess:setVisible(true);
				self.kuangbaoProgess:setPercentage(100);
			end

			self.fastSkillRunTime = FAST_SKILL_CD_TIME*10;
			self.my.cannon:setFastFireTime(FAST_SKILL_CD_TIME);

			if self.kuangbaoSchedule then
				self.my:stopAction(self.kuangbaoSchedule);
				self.kuangbaoSchedule = nil;
			end

			local func = function(dt)
				--狂暴
				if(self.isFastShoot == true)then
					self.fastSkillRunTime = self.fastSkillRunTime - dt
					if self.kuangbaoProgess then
						self.kuangbaoProgess:setPercentage(self.fastSkillRunTime/(FAST_SKILL_CD_TIME*10)*100)
					end

					if(self.fastSkillRunTime <= 0)then
						self.fastSkillRunTime = 0;
						self:fastShoot(false)
						if self.kuangbaoSchedule then
							self.my:stopAction(self.kuangbaoSchedule);
							self.kuangbaoSchedule = nil;
						end
					end
				end
			end

			self.kuangbaoSchedule = schedule(self.my, function() func(1) end,0.1);
		else
			self.my.cannon:setFast(false);
			self.isFastShoot=false;
			if self.kuangbaoProgess then
				self.kuangbaoProgess:setVisible(false)
			end
		end
	end
end

function TableLayer:callFish(isCallFish)
	if isCallFish == true then
		if self.cacheCallFish[1].chair_id == self.tableLogic:getMySeatNo() then
			self.isCallFish = true;
			if self.zhaohuanProgess then
				self.zhaohuanProgess:setVisible(true);
				self.zhaohuanProgess:setPercentage(100);
			end
			self.callFishSkilRunTime = CALLFISH_SKILL_CD_TIME*10;

			if self.callFishSchedule then
				self.my:stopAction(self.callFishSchedule);
				self.callFishSchedule = nil;
			end

			local func = function(dt)
				--召唤
				if(self.isCallFish == true)then
					self.callFishSkilRunTime = self.callFishSkilRunTime - dt
					if self.zhaohuanProgess then
						self.zhaohuanProgess:setPercentage(self.callFishSkilRunTime/(CALLFISH_SKILL_CD_TIME*10)*100)
					end

					if(self.callFishSkilRunTime <= 0)then
						self.callFishSkilRunTime = 0;
						self:callFish(false);
						if self.callFishSchedule then
							self.my:stopAction(self.callFishSchedule);
							self.callFishSchedule = nil;
						end
					end
				end
			end

			self.callFishSchedule = schedule(self.my, function() func(1) end,0.1);
		end
		if self.playerNodeInfo[self.cacheCallFish[1].chair_id] then
			self.playerNodeInfo[self.cacheCallFish[1].chair_id].cannon:setCallFishTime(CALLFISH_SKILL_CD_TIME);	
		end
	else
		if self.callFishSchedule then
			self.my:stopAction(self.callFishSchedule);
			self.callFishSchedule = nil;
		end

		self.isCallFish = false;
		if self.zhaohuanProgess then
			self.zhaohuanProgess:setVisible(false)
		end
	end
end

function TableLayer:refreshCallFish()
	if self.cacheCallFish == nil then
		return;
	end

	luaDump(self.cacheCallFish,"self.cacheCallFish")

	for k,item in pairs(self.cacheCallFish) do
		local fish = self:addFish(item.fish_kind, item.pathid, item.fish_id);
		fish:setLocalZOrder(2000);
	end

	self.cacheCallFish = nil;
end

function TableLayer:frozenFish(isFrozen,isShowProgess)
	if isFrozen == true or isFrozen == 1 then
		if self.isCreateMatrix == true then
			return;
		end

		--如果是冰冻效果，先假去掉
		if self.isBingdongFish == true then
			self:frozenFish(2);
		end

		self._isFrozen = true;

		if self.my and isFrozen == true then
			self.isBingdongFish = true;
			self.frozenSkillRunTime = BINGDONG_SKILL_CD_TIME*10;

			local func = function(dt)
				--冰冻
				if(self._isFrozen == true)then
					self.frozenSkillRunTime = self.frozenSkillRunTime - dt

					if(self.frozenSkillRunTime <= 0)then
						self.frozenSkillRunTime = 0;
						if self.bingdongSchedule then
							self.my:stopAction(self.bingdongSchedule);
							self.bingdongSchedule = nil;
						end
					end
				end
			end

			--进度条
			if isShowProgess == true then
				if self.bingdongProgess then
					self.bingdongProgess:setVisible(true);
					self.bingdongProgess:setPercentage(100);
				end

				func = function(dt)
					--冰冻
					if(self._isFrozen == true)then
						self.frozenSkillRunTime = self.frozenSkillRunTime - dt
						if self.bingdongProgess then
							self.bingdongProgess:setPercentage(self.frozenSkillRunTime/(BINGDONG_SKILL_CD_TIME*10)*100)
						end

						if(self.frozenSkillRunTime <= 0)then
							self.frozenSkillRunTime = 0;
							if self.bingdongSchedule then
								self.my:stopAction(self.bingdongSchedule);
								self.bingdongSchedule = nil;
							end
						end
					end
				end
			end

			if self.bingdongSchedule then
				self.my:stopAction(self.bingdongSchedule);
				self.bingdongSchedule = nil;
			end

			self.bingdongSchedule = schedule(self.my, function() func(1) end,0.1);
		end

		for k, fish in pairs(self.fishData) do
			if fish:isVisible() then
				fish:frozen(BINGDONG_SKILL_CD_TIME);
			end
		end

		if self.frozenAction then
			self:stopAction(self.frozenAction)
			self.frozenAction = nil
		end

		local layer = self.Sprite_bg:getChildByName("bingdongLayer");

		if layer then
			layer:removeFromParent();
		end

		--冰冻特效层
		local layer = DataCacheManager:createEffect(BING_DONG_LAYER,BINGDONG_SKILL_CD_TIME)
		layer:setLocalZOrder(10)
		layer:showFrozenTips(isShowProgess);
		self.Sprite_bg:addChild(layer,100)
		layer:setName("bingdongLayer")

		if isFrozen == true then
			isFrozen = false;
		elseif isFrozen == 1 then
			isFrozen = nil;
		end

		self.frozenAction = performWithDelay(self, function() self:frozenFish(isFrozen); end, BINGDONG_SKILL_CD_TIME);
		self.frozenAction:setTag(99999);
	else
		if isFrozen ~= 2 then
			local layer = self.Sprite_bg:getChildByName("bingdongLayer");

			if layer then
				layer:removeFromParent();
			end

			if self.bingdongSchedule then
				self.my:stopAction(self.bingdongSchedule);
				self.bingdongSchedule = nil;
			end

			self._isFrozen = false;
			self:stopActionByTag(99999);
			self.frozenAction = nil;

			local isHaveBoss = false;

			for k, fish in pairs(self.fishData) do
				fish._frozenTimer = 0;
				fish:resumeFrozen();
				if fish:checkIsBoss() then
					isHaveBoss = true;
				end
			end

			if self.cacheFish and next(self.cacheFish) ~= nil then
				if isHaveBoss == true then
					-- for k,v in pairs(self.cacheFish) do
					-- 	if v.fish_kind < 40 then
					-- 		performWithDelay(self,function() self:refreshNewFish(v);  end,0.2*(k-1))
					-- 	end
					-- end
				else
					for k,v in pairs(self.cacheFish) do
						performWithDelay(self,function() self:refreshNewFish(v);  end,0.2*(k-1))
					end
				end

				self.cacheFish = nil;
			end
		end

		if isFrozen == false or isFrozen == 2 then
			self.isBingdongFish = false;
			if self.bingdongProgess then
				self.bingdongProgess:setVisible(false);
			end
		end
	end
end

--比赛重打通知服务端
function TableLayer:sendGameMatchRetry()
	MatchInfo:sendRetryMatch()
end

--比赛分数打完结算
function TableLayer:receiveUserMatchInfo(data)
	if self.my.score > 0 then
		return;
	end

	local data = data._usedata;
	luaDump(data,"receiveUserMatchInfo")

	if data.UserID == PlatformLogic.loginResult.dwUserID then
		data.score = self.my.getScore;
		local layer = self.Sprite_bg:getChildByName("MatchResultLayer");

		if not layer then
			self._isGameEnd = true;
			layer = require("likuipiyu.game.MatchResultLayer"):create(self);
			layer:setLocalZOrder(101)
			layer:setName("MatchResultLayer")
			self.Sprite_bg:addChild(layer);
		end

		layer:showResult(data);
	end
end

--比赛结束时间到了，服务器通知结束处理
function TableLayer:gameMatchEnd(flag)
	if not flag then
		self._isGameEnd = true;

		RoomLogic:close();

		local prompt = GamePromptLayer:create();
		prompt:showPrompt(GBKToUtf8("比赛已结束，即将结算排名。"));
		prompt:setBtnClickCallBack(function() 
			self:backPlatform();
		end);
	else
		luaPrint("比赛分数打完通知服务器写分")
		--写分
		MatchInfo:sendMatchWriteSocre()
	end
end

--比赛分数打完通知服务器写分
function TableLayer:gameMatchWriteScore()
	--请求比赛信息
	MatchInfo:sendUserMatchInfoRequest(globalUnit:getEnterGameMatchID());
end

--比赛重打
function TableLayer:gameRetryMatch(msg)
	self.Sprite_bg:removeChildByName("MatchResultLayer");

	if msg.ret == 0 then
		if self.my then
			if totalFishScore == nil then
				totalFishScore = 1000;
			end
			self.my:updateScore(totalFishScore);
			self.my:updateGetSocre(0);
			self._isGameEnd = false;
		end
	else
		local text = "";
		if msg.ret == 1 then
			text = "比赛不存在！";
		elseif msg.ret == 2 then
			text = "比赛未开始！";
		elseif msg.ret == 3 then
			text = "比赛已经结束！";
		elseif msg.ret == 4 then
			text = "金币不足，不能继续比赛！";
		elseif msg.ret == 5 then
			text = "您已经在比赛中，不能报名此比赛！";
		else
			text = "重新比赛失败 errorCode = "..msg.ret;
		end

		local prompt = GamePromptLayer:create();
		prompt:showPrompt(GBKToUtf8(text));
		prompt:setBtnClickCallBack(function() 
			self:backPlatform();
		end);
	end
end

--礼蛋鱼处理
function TableLayer:giftEggsFish(catchinfo,pos)
	if self.my and self.my:getSeatNo() == catchinfo.chair_id then--只有自己才处理
		performWithDelay(self,function() self:showGiftEggsTimer(pos); end,1.5);
	end
end

--显示金蛋倒计时
function TableLayer:showGiftEggsTimer(pos)
	if self.giftEggsBg then
		self.giftEggsBg:removeSelf();
		self.giftEggsBg = nil;
	end

	local size = cc.Director:getInstance():getWinSize();
	local x = size.width/2+50;
	local y = 150;

	-- local target = cc.p(-150,100);
	if self.rockMoneyTreeBg then
		-- target.x = target.x-100;
		x = size.width/2-50;
	end

	if globalUnit.isEnterRoomMode ~= true then --单人场
		x =  x - (size.width-size.width/3.5-size.width/2);
	end

	-- if self.my:getSeatNo() == 2 or self.my:getSeatNo() == 4 then
	-- 	target = cc.p(150,100);
	-- 	if self.rockMoneyTreeBg then
	-- 		target.x = target.x+100;
	-- 	end
	-- end

	local wp = self.Sprite_bg:convertToWorldSpace(cc.p(x,y));
	local target = self.my:convertToNodeSpace(wp);

	-- local wordPos = self.fishLayer:convertToWorldSpace(pos);
	local lp = self.my:convertToNodeSpace(pos);
	local bg = ccui.Button:create("game/common.png","game/common-on.png");
	bg:setPosition(lp);
	bg:setTouchEnabled(false);
	self.my:addChild(bg);
	self.giftEggsBg = bg;
	bg:onClick(function(sender)
		sender:removeSelf();
		self.giftEggsBg = nil;

		--解除锁定
		self:onClickUnLock();
		self:onClickAutoCallBack(self.Button_task,1);

		local layer = require("likuipiyu.game.core.GiftEggsLayer"):create();
		layer:setLocalZOrder(101)
		self.Sprite_bg:addChild(layer);
	end);

	-- local skeleton_animation = sp.SkeletonAnimation:create("fish/danyou.json", "fish/danyou.atlas");
	-- skeleton_animation:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2+5);
	-- skeleton_animation:setScale(0.6);
	-- bg:addChild(skeleton_animation);
	local frames = display.newFrames("fish_52_%d.png", 1, 33);
	local activeFrameAnimation = display.newAnimation(frames, 0.05);
	local sprite = display.newSprite()
	sprite:setSpriteFrame(frames[1]);
	sprite:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2+5);
	sprite:setScale(0.6);
	-- 自身动画
	local animate= cc.Animate:create(activeFrameAnimation);
	local aimateAction=cc.Repeat:create(animate,999999);
	sprite:runAction(aimateAction);
	bg:addChild(sprite);

	local dt = 30

	local timeText = FontConfig.createWithCharMap(dt..":","game/commonNum.png",16,20,0);
	timeText:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-22);
	timeText:setTag(dt);
	bg:addChild(timeText);

	local speed = 800;
	local dt = cc.pGetDistance(pos,lp)/speed;
	local seq = cc.Sequence:create(
		cc.MoveTo:create(dt, target),
		cc.CallFunc:create(function() 
			bg:setTouchEnabled(true);
			local func = function() 
				local tag = timeText:getTag()-1;

				timeText:setString(tag..":");
				timeText:setTag(tag);

				if tag <= 0 then--结束
					bg:stopAllActions();
					bg:removeSelf();
					self.giftEggsBg = nil;
				end
			end

			schedule(bg,func,1);
		end)
	)
	bg:runAction(seq);
end

function TableLayer:showSpecialRewardLayer(event)
	self.rewardData = {_usedata=event._usedata,flag=event.flag};
	luaDump(self.rewardData,"self.rewardData");

	if self.my then
		if event.flag then
			local layer = require("likuipiyu.game.core.GetRewardLayer"):create(function() luaDump(self.rewardData,"self.rewardData1") self:receiveHitGiftEggsInfo(self.rewardData); end,self.rewardData._usedata);
			layer:setLocalZOrder(1010000);
			self.Sprite_bg:addChild(layer);
		else
			performWithDelay(self, function()
				local layer = require("likuipiyu.game.core.GetRewardLayer"):create(function() luaDump(self.rewardData,"self.rewardData2") self:receiveHitGiftEggsInfo(self.rewardData); end,self.rewardData._usedata);
				layer:setLocalZOrder(1010000);
				self.Sprite_bg:addChild(layer);
			end, 0.6);
		end
	end
end

function TableLayer:receiveHitGiftEggsInfo(event)
	luaDump(event,"dafdf")
	local data = event._usedata;
	luaDump(data,"砸金蛋结果");

	if self.my then
		--借用捕鱼处理
		if event.flag then
			local info = {chair_id=self.my:getSeatNo(),fish_id=-1,fish_kind=0,bullet_ion=false,fish_score=data.fish_score,user_score=data.UserFishscore,fish_mulriple=50}
			info.goodsInfoList = {{goodsID=GOODS_HUAFEI,goodsCount=data.iLotteries}};

			self:catchFish(info)
		else
			performWithDelay(self, function()
				local info = {chair_id=self.my:getSeatNo(),fish_id=-1,fish_kind=0,bullet_ion=false,fish_score=data.fish_score,user_score=data.UserFishscore,fish_mulriple=50}
				info.goodsInfoList = {{goodsID=GOODS_HUAFEI,goodsCount=data.iLotteries}};

				self:catchFish(info)
			end, 0.2);
		end
	end
end

--摇钱树鱼处理
function TableLayer:rockingMoneyTreeFish(catchinfo,pos)
	if self.my and self.my:getSeatNo() == catchinfo.chair_id then--只有自己才处理
		performWithDelay(self,function() self:showRockMoneyTreeTimer(pos); end,1.5);
	end
end

--显示摇钱树倒计时
function TableLayer:showRockMoneyTreeTimer(pos)
	if self.rockMoneyTreeBg then
		self.rockMoneyTreeBg:removeSelf();
		self.rockMoneyTreeBg = nil;
	end

	local size = cc.Director:getInstance():getWinSize();
	local x = size.width/2+50;
	local y = 150;
	-- local target = cc.p(-150,100);
	if self.giftEggsBg then
		x = size.width/2-50;
	end

	if globalUnit.isEnterRoomMode ~= true then --单人场
		x =  x - (size.width-size.width/3.5-size.width/2);
	end
	-- if self.my:getSeatNo() == 2 or self.my:getSeatNo() == 4 then
	-- 	target = cc.p(150,100);
	-- 	if self.giftEggsBg then
	-- 		target.x = target.x+100;
	-- 	end
	-- end

	local wp = self.Sprite_bg:convertToWorldSpace(cc.p(x,y));
	local target = self.my:convertToNodeSpace(wp);

	-- local wordPos = self.fishLayer:convertToWorldSpace(pos);
	local lp = self.my:convertToNodeSpace(pos);
	local bg = ccui.Button:create("game/common.png","game/common-on.png")
	bg:setPosition(lp);
	bg:setTouchEnabled(false);
	self.my:addChild(bg);
	self.rockMoneyTreeBg = bg;
	bg:onClick(function(sender)
		sender:removeSelf();
		self.rockMoneyTreeBg = nil;

		--解除锁定
		self:onClickUnLock();
		self:onClickAutoCallBack(self.Button_task,1);

		local layer = require("likuipiyu.game.core.RockingMoneyTreeLayer"):create();
		layer:setLocalZOrder(101)
		self.Sprite_bg:addChild(layer);
	end);

	-- local skeleton_animation = sp.SkeletonAnimation:create("fish/yaoqianchuan.json", "fish/yaoqianchuan.atlas");
	-- skeleton_animation:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-5);
	-- -- skeleton_animation:setAnimation(1,"yaoqianchuan", true);
	-- skeleton_animation:setScale(0.25);
	-- bg:addChild(skeleton_animation);
	local frames = display.newFrames("fish_53_%d.png", 1, 61);
	local activeFrameAnimation = display.newAnimation(frames, 0.1);
	local sprite = display.newSprite()
	sprite:setSpriteFrame(frames[1]);
	sprite:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2+5);
	sprite:setScale(0.25);
	-- 自身动画
	local animate= cc.Animate:create(activeFrameAnimation);
	local aimateAction=cc.Repeat:create(animate,999999);
	sprite:runAction(aimateAction);
	bg:addChild(sprite);

	local dt = 30

	local timeText =  FontConfig.createWithCharMap(dt..":","game/commonNum.png",16,20,0);
	timeText:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-22);
	timeText:setTag(dt);
	bg:addChild(timeText);

	local speed = 800;
	local dt = cc.pGetDistance(pos,lp)/speed;
	local seq = cc.Sequence:create(
		cc.MoveTo:create(dt, target),
		cc.CallFunc:create(function() 
			bg:setTouchEnabled(true);
			local func = function() 
				local tag = timeText:getTag()-1;

				timeText:setString(tag..":");
				timeText:setTag(tag);

				if tag <= 0 then--结束
					bg:stopAllActions();
					bg:removeSelf();
					self.rockMoneyTreeBg = nil;
				end
			end

			schedule(bg,func,1);
		end)
	)
	bg:runAction(seq);
end

--红包处理
function TableLayer:receiveUserExpandInfo(data)
	local data = data._usedata;

	luaDump(data,"用户扩展属性");

	-- if self.uNameId ~= 40010003 and self.uNameId ~= 40010007 and self.uNameId ~= 40010002 and self.uNameId ~= 40010006 then
	if globalUnit.iRoomIndex < 3 then
		return;
	end

	--创建红包碎片
	if self.redEnvelopesNode then
		-- self.redEnvelopesNode:updateUI();
	else
		local size = cc.Director:getInstance():getWinSize();
		local redEnvelopesNode = require("likuipiyu.game.core.RedEnvelopesNode"):create();
		redEnvelopesNode:setLocalZOrder(10);
		redEnvelopesNode:setPosition(size.width/2,size.height);
		self.Sprite_bg:addChild(redEnvelopesNode);
		self.redEnvelopesNode = redEnvelopesNode;
	end
end

--抽奖页面
function TableLayer:showPrizeLayer()
	--解除锁定
	self:onClickUnLock();
	self:onClickAutoCallBack(self.Button_task,1);

	local layer = require("likuipiyu.game.core.PrizeLayer"):create();
	layer:setLocalZOrder(101)
	self.Sprite_bg:addChild(layer);
end

--混沌珠处理
function TableLayer:showChaoticBeads(catchinfo,pos)
	if self.chaoticBeadFish == nil then
		local lp = self.fishLayer:convertToNodeSpace(pos);
		local skeleton_animation = createSkeletonAnimation("heidongyu","fish/heidongyu.json", "fish/heidongyu.atlas");
		if skeleton_animation then
			skeleton_animation:setPosition(lp);
			skeleton_animation:setAnimation(2,"heidongyu-bao", true);
			skeleton_animation:setLocalZOrder(0);
			skeleton_animation:setContentSize(cc.size(FishModule.m_gameFishConfig.bomb_range_width,FishModule.m_gameFishConfig.bomb_range_height));
			self.fishLayer:addChild(skeleton_animation);
			self.chaoticBeadFish = skeleton_animation;
		end
		self.chaoticCatchinfo = catchinfo;

		local seq = cc.Sequence:create(
			cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() self:checkIsSuckFish(); end)), 7),
			cc.CallFunc:create(function()
				skeleton_animation:removeSelf();
				self.chaoticBeadFish = nil;
				self.chaoticCatchinfo = nil;
				for fishPoint, fish in pairs(self.fishData) do
					fish:resumeSuck();
				end
			end)
		)

		skeleton_animation:runAction(seq);
	end
end

function TableLayer:checkIsSuckFish()
	if self.chaoticBeadFish then
		local allFishID = {};
		for fishPoint, fish in pairs(self.fishData) do
			if fish:isSuckChaoticBeas(self.chaoticBeadFish:getPositionX(),self.chaoticBeadFish:getPositionY(),self.chaoticBeadFish:getContentSize()) and fish:isFishInScreen() then	
				fish:suck();
			else
				fish:resumeSuck();
			end

			if fish.isSuck == true then
				allFishID[#allFishID + 1] = fish:getFishID();
			end
		end
		local ismyRobot = false;
		if self.robotLayer.robotList[self.chaoticCatchinfo.chair_id] ~= nil then
			ismyRobot = true;
		end
		if self.my:getSeatNo() == self.chaoticCatchinfo.chair_id or ismyRobot then
			if #allFishID > 0 then
				self.tableLogic:sendCatchChaoticFish(self.chaoticCatchinfo.chair_id, self.chaoticCatchinfo.fish_id, allFishID, #allFishID);
			end
		end
	end
end

--游戏内玩家购买炮
function TableLayer:receiveBuyFortInfo(data)
	local data = data._usedata;

	if data.ret == 0 then
		if PlatformLogic.loginResult.dwUserID == data.UserID then
			if self.my then
				self.my:updateScore(data.Score);
			end
		end
	end
end

function TableLayer:playOutTime()
	self.isNoFire = true
	self:onClickUnLock()
	self:onClickAutoCallBack(self.Button_task,1);
end

--锁定消息
function TableLayer:receiveLockFishInfo(data)
	local data = data._usedata

	local players = self.playerNodeInfo
	local chairID = data.chair_id
	if players[chairID] ~= nil and chairID ~= self.my:getSeatNo() and data.IsLockFire == false then
		players[chairID]:setLockFish(nil)
		players[chairID]:hideAimLine()
	end
end

function TableLayer:gameRobotDeal(data)
	if data._usedata then
		data = data._usedata
	end

	luaDump(data,"机器人")
	-- if not self:getChildByName("robot") then
	-- 		local layer = require("likuipiyu.game.RobotManager").new()
	-- 		layer:setGameLayer(self)
	-- 		layer:setName("robot")
	-- 		self:addChild(layer)
	-- 		self.robotLayer = layer;	
	-- end
	if data.chairID == self.tableLogic:getMySeatNo() then
	
		for k,v in pairs(data.robotChairID) do
			if v == true then
				dispatchEvent("addRobot",{lSeatNo=k-1})
			end
		end
	-- else
		-- self:removeChildByName("robot")
	end
end

function TableLayer:gameHitFish(msg)
	for k,fish in pairs(self.checkFishList) do
		if fish._fishID == msg.fish_id  then
			fish.isCanHit = nil;
		end
	end
end

return TableLayer;
