local TableLayer = class("TableLayer", BaseWindow)

local Player = require("shisanzhang.Player")
local TableLogic = require("shisanzhang.TableLogic")
local Audio = require("shisanzhang.Audio")
local CardListBoard = require("shisanzhang.CardListBoard")
local PokerCard = require("shisanzhang.PokerCard")
local CardLogic = require("shisanzhang.CardLogic")
local shisanzhang = require("shisanzhang");

local MainZorder = 100
local RoomInfoZorder = 101
local QiePaiZorder = 101
local CardZorder = 101
local SkeletonZorder = 101
local ExitLayerZorder = 101
local ChatBubbleZorder = 101
local TipZorder = 101
local ArrangeZorder = 102
local ErrTipZorder = 102
local ResultZorder = 102
local ResultAllZorder = 102
local ExitDialogZorder = 103
local TopZorder = 200

PLAY_COUNT = 4

function TableLayer:create(userScore,cellScore)
	Event:clearEventListener();
	
	local layer = TableLayer.new(userScore,cellScore)

	globalUnit.isFirstTimeInGame = false

	return layer
end

function TableLayer:ctor(userScore,cellScore)
	--body
	self.super.ctor(self, 0, true)

	self.uNameId = uNameId
	self.bDeskIndex = bDeskIndex or 0
	self.bAutoCreate = bAutoCreate or false
	self.bMaster = bMaster or 0
	-- shisanzhangInfo:init()
	
	self.tableLogic = nil       -- 逻辑控制

	self._mainUI = nil      -- 主UI
	self._imgBg = nil       -- 桌面

	self._vaildUserCount = 0                    -- 有效的玩家数量
	self._players = Array(Player, PLAY_COUNT)   -- 各玩家UI
	self._name = Array(false, PLAY_COUNT)       -- 当前玩家昵称
	self._nameAllEnd = Array(false, PLAY_COUNT) -- 大局结束玩家昵称
	self._bDestion = Array(false, PLAY_COUNT)   -- 各玩家ID


	self._btnShake = {}                         -- 震动btn            

	self._roleDunLb = Array(false, PLAY_COUNT, 3)   -- 每蹲每玩家分数
	self._roleDunSpr = Array(false, PLAY_COUNT, 3)  -- 每蹲每玩家牌型
	self._roleDun	= Array(false, PLAY_COUNT, 3)
	self._specialDun	= Array(false, PLAY_COUNT)

	self._readyBiPai = {}                           -- 比牌结束扇形

	self._bLeaveDesk = false                        -- 是否离开桌子

	self._imgSpec = Array(false, PLAY_COUNT)        -- 特殊牌文字

	self._cardListBoard = {}                        -- 玩家牌背

	self._dunCards = Array("table", 3)              -- 摆牌蹲显示

	self._isGameEnd = false     -- 是否本大局游戏结束
	self._isLeft = false        -- 自己是否离开桌子
	self._isOffline = false     -- 是否掉线

	self._VSCards = Array("table", 3, PLAY_COUNT)   -- 比牌显示

    self._isClose = true
    
	if globalUnit.isTryPlay == true then
    	self.userScore = userScore or 10000000;
    else
        self.userScore = userScore or PlatformLogic.loginResult.i64Money;
    end

	self:init()
end

function TableLayer:init()
	self:loadLayout()

	-- self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster)
	-- self.tableLogic:enterGame()

end

function TableLayer:onEnter()
	-- display.removeUnusedSpriteFrames()

	-- cc.FileUtils:getInstance():addSearchPath("shisanshui/specialAni/")

	-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("NewAnimation/NewAnimation10.png", "NewAnimation/NewAnimation10.plist", "NewAnimation/NewAnimation1.ExportJson")
	-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("NewAnimation/NewAnimation20.png", "NewAnimation/NewAnimation20.plist", "NewAnimation/NewAnimation2.ExportJson")
	-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("NewAnimation/NewAnimation30.png", "NewAnimation/NewAnimation30.plist", "NewAnimation/NewAnimation3.ExportJson")

	-- -- -- 特殊牌光效
	-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("NewAnimation/gameBtnAni0.png", "NewAnimation/gameBtnAni0.plist", "NewAnimation/gameBtnAni.ExportJson")

	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("shisanzhang/cards/cards.plist")

	self:bindEvent()

	audio.playMusic("sound/background.mp3", true);

	self.super.onEnter(self)
end

function TableLayer:onExit()
	-- self.tableLogic:stop()
	self.super.onExit(self)
end

function TableLayer:bindEvent()
	-- self:pushEventInfo(shisanzhangInfo, "gameStartInfo", handler(self, self.receiveGameStartInfo))        		--游戏开始
	-- self:pushEventInfo(shisanzhangInfo, "sendCardInfo", handler(self, self.receiveSendCardInfo))  				--发牌
	-- self:pushEventInfo(shisanzhangInfo, "gameResultInfo", handler(self, self.receiveGameResultInfo))            --比牌结果
	-- self:pushEventInfo(shisanzhangInfo, "gameEndInfo", handler(self, self.receiveGameEndInfo))        			--游戏结束
	-- self:pushEventInfo(shisanzhangInfo, "openCardInfo", handler(self, self.receiveOpenCardInfo))           		--摊牌

	-- self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack))      --进入后台
	-- self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame))      --后台回来
	self:pushGlobalEventInfo("I_R_M_EndMatchRoom",handler(self, self.onEndMatch))
    self:pushGlobalEventInfo("I_P_M_Login",handler(self, self.onReceiveLogin))--断线重连刷新
    self:pushGlobalEventInfo("I_R_M_DisConnect",handler(self, self.onReceiveLogin))--断线重连刷新
end

function TableLayer:receiveGameStartInfo(data)

end

function TableLayer:receiveSendCardInfo(data)
	luaDump(data._usedata, "fapai")

	self.isPlaying = true
	data = data._usedata

	self.tableLogic:onFaPai(data)
end

function TableLayer:receiveOpenCardInfo(data)
	luaDump(data._usedata, "tanpai")

	data = data._usedata

	self.tableLogic:onBaiPaiFinish(data)
end

function TableLayer:receiveGameResultInfo(data)
	luaDump(data._usedata, "bipai")

	data = data._usedata

	self.tableLogic:onBaEnd(data)
end

function TableLayer:receiveGameEndInfo(data)
	luaDump(data._usedata, "jieshu")
	self.isPlaying = false
	data = data._usedata

	self.tableLogic:onGameEnd(data)
end

--进入后台
function TableLayer:refreshEnterBack(data)
end

--后台回来
function TableLayer:refreshBackGame(data)
end

-- 初始化界面
function TableLayer:loadLayout()

	local uiTable = {
		{"_imgBg",      "sss_bg"           },
		{"_panelRoomInfo",   "Panel_info"  },
		{"_lbPwd",      "Label_rMima"      },
		{"_lbMode",     "Label_Mode"       },
		{"_lbCount",    "Label_dCount"     },
		{"_lbMoreRule", "Label_MoreRules"  },
		{"_btnRule",    "Button_roomInfo"  },
		{"_btnExit",    "Button_havething" },
		{"_lbDiFen",    "lb_difen" },

		{"_btnStart",    "btn_start"       },

		{"_btnSetting",  "Button_Setting"  },
		{"_btnCardType", "Button_CardType" },
		{"_btnShare",    "Button_share"    },
		{"_btnShare_AY", "Button_share_AY" },
		{"_btnChat",     "Button_liaotian" },
		{"_btnYY",       "Button_yy"       },
		{"_btnGZ",       "Button_guize"    },
		{"_btnMore",     "Button_more"     },
		{"_imgMore",     "Image_more"      },
		{"_btnYinyue",   "Button_yinyue"   },
		{"_btnYinxiao",  "Button_yinxiao"  },
		{"_imgClock",    "game_clock"      },
		{"_lbTimer",     "clock_num"       },
		{"_layerYaFen",  "stake_bg"        },
		{"_layerQiangZ", "layer_QiangZ"    },
		{"_imgDeng",     "img_deng"        },
		{"_voiceState",  "chatview"        },
		{"_voiceLbl",    "Text_1"          },

		{"_ChartBuble",           "chat%d",                  PLAY_COUNT},
		{"_btnShake",             "btn_shake_%d",            PLAY_COUNT},
	    {"Image_playerHeadFrame", "Image_playerHeadFrame%d", PLAY_COUNT},  --头像框--
	    {"role_state",            "role%d_state",            PLAY_COUNT}, --准备图标--
	    {"allHandCard",           "allHandCard_%d",          PLAY_COUNT},   --牌背--
	    {"img_deng",              "img_deng_%d",             PLAY_COUNT}, --等待图标--
	    {"iHandCard",             "iHandCard%d",             PLAY_COUNT},  --三墩牌--
	    {"iHandCard_spec",        "iHandCard%d_spec",        PLAY_COUNT},     --牌--
	    {"_lbScore",        	  "lb_score%d",        		 PLAY_COUNT}     --结算分数--
	}

    self._mainUI = UILoader:load(string.format("Shisanshui_%dr.json", PLAY_COUNT), self, uiTable)
	self:addChild(self._mainUI, MainZorder)
	
	self._btnExit.pType = 0
	self._btnExit.pTarget = 1
	self._btnCardType.pType = 0
	
	self._btnGZ.pType = 1
	self._btnMore.pType = 1
	self._imgMore.pType = 1
	iphoneXFit(self._imgBg)

	-- 开始btn
	self._btnStart:onClick(function()
        self:showFangjian();
	end)
	self._btnStart:hide()

	-- 牌型btn
	self._btnCardType:show()
	self._btnCardType:onClick(function() self:btnCardTypeCallback() end)

	-- 离开btn
	self._btnExit:show()
	self._btnExit:onClick(function() 
		self:onClickExitGameCallBack(true)
	end)

	self._btnGZ:show()
	self._btnGZ:onClick(function()
		local HelpLayer = require("shisanzhang.HelpLayer")
		local layer = HelpLayer:create()
    	self:addChild(layer, TopZorder)
	end)

	self._btnMore:show()
	self._btnMore:onClick(function()
		self._imgMore:setVisible(not self._imgMore:isVisible())
	end)

	self._btnYinyue:show()
	self._btnYinyue:setTag(1)
	self._btnYinyue:onClick(function(sender)
		local tag = self._btnYinyue:getTag()

		setMusicIsPlay(not getMusicIsPlay())
		if tag==1 then
			self._btnYinyue:setTag(2)
			self._btnYinyue:loadTextures("settting/yinyuex.png", "settting/yinyuex-on.png")
		else
			self._btnYinyue:setTag(1)
			self._btnYinyue:loadTextures("settting/yinyue.png", "settting/yinyue-on.png")
			audio.playMusic("sound/background.mp3", true)
		end
	end)

	self._btnYinxiao:show()
	self._btnYinxiao:setTag(1)
	self._btnYinxiao:onClick(function(sender)
		setEffectIsPlay(not getEffectIsPlay());
		local tag = self._btnYinxiao:getTag()

		if tag==1 then
			self._btnYinxiao:setTag(2)
			self._btnYinxiao:loadTextures("settting/yinxiaox.png", "settting/yinxiaox-on.png")
		else
			self._btnYinxiao:setTag(1)
			self._btnYinxiao:loadTextures("settting/yinxiao.png", "settting/yinxiao-on.png")
		end
	end)

	--玩家初始化
	for i=1, PLAY_COUNT do
		local isSelf = (i==1)
		-- 玩家信息板
		local panel = UILoader:seekNodeByName(self._mainUI, "Image_playerHeadFrame"..i)

		if panel then
			local player = Player:create(INVALID_USER_ID)
			player:setAnchorPoint(cc.p(0.5, 0.5))
			player:setPosition(panel:getPosition())
			player:setEmptyHead()
			player:setTableUI(self)
			self._players[i] = player
			panel:getParent():addChild(player, panel:getLocalZOrder())
			self:setUserMoney(i, 0)
			self:showUserMoney(i, false)
		end

		-- 玩家蹲 显示
		local handCard = UILoader:seekNodeByName(self._mainUI, string.format("iHandCard%d", i))
		for j=1, 3 do
			local dun = UILoader:seekNodeByName(handCard, string.format("dun%d", j))
			local scoreLb = UILoader:seekNodeByName(dun, "score")
			local typeSpr = UILoader:seekNodeByName(scoreLb, "cardtype")

			self._roleDunLb[i][j] = scoreLb
			self._roleDunSpr[i][j] = typeSpr
			self._roleDun[i][j] = dun
		end


		self._readyBiPai[i] = UILoader:seekNodeByName(self._mainUI, "allHandCard_"..i)
	end

	if globalUnit.iRoomIndex == 1 then
		self.difen = "1.00"
		self.ruchang = 30
	elseif globalUnit.iRoomIndex == 2 then
		self.difen = "10.00"
		self.ruchang = 300
	elseif globalUnit.iRoomIndex == 3 then
		self.difen = "20.00"
		self.ruchang = 600
	elseif globalUnit.iRoomIndex == 4 then
		self.difen = "50.00"
		self.ruchang = 1500
	end
	if self.difen then
		self._lbDiFen:show()
		self._lbDiFen:setString(self.difen)
	else
		self._lbDiFen:hide()
	end

    -- self._btnStart:show()

    log(9999999, self.userScore)
    self:setUserName(1, FormotGameNickName(PlatformLogic.loginResult.nickName,nickNameLen))
    self:setUserMoney(1, self.userScore)
    self:showUserMoney(1, true)
    self._players[1]:setHead(PlatformLogic.loginResult.dwUserID, getHeadPath(PlatformLogic.loginResult.bLogoID,PlatformLogic.loginResult.bBoy))

	changeParent(self._btnCardType, self, TopZorder)
	changeParent(self._btnExit, self, TopZorder)
	changeParent(self._btnGZ, self, TopZorder)
	-- changeParent(self._btnYinyue, self, TopZorder)
	-- changeParent(self._btnYinxiao, self, TopZorder)
	changeParent(self._btnMore, self, TopZorder)
	changeParent(self._imgMore, self, TopZorder)
	if globalUnit.isShowZJ then
		self._btnGZ:loadTextures("shisanzhang/zhanji/paixing.png","shisanzhang/zhanji/paixing-on.png")
		self._btnMore:loadTextures("shisanzhang/zhanji/gengduo-shisanzhang.png","shisanzhang/zhanji/gengduo-shisanzhang-on.png")
	end
end

function TableLayer:btnCardTypeCallback()
	local cardTypeWidget = UILoader:load("CardType.json"):addTo(self, TopZorder)
	local bg = UILoader:seekNodeByName(cardTypeWidget, "h_bg")
	bg:onClick(function() cardTypeWidget:removeFromParent() end)
end

-- 金币房信息
function TableLayer:showDeskInfoGold()
	self._panelRoomInfo:hide()
	-- self._lbPwd:setPositionY(100)
	-- self._lbMode:setPositionY(70)
	-- self._lbMoreRule:setPositionY(35)
	-- self._lbPwd:setString("金币场")
	-- self._lbMode:setString("底注:100倍")     	-- 游戏模式
	-- self._btnRule:hide()
	-- self._lbMoreRule:setString("打枪X2\n自动配牌")
	-- self._lbCount:hide()
end

function TableLayer:hideAllState()
	for i=1, PLAY_COUNT do
		self:showUserState(i, false)
	end
end

function TableLayer:gameUserCut(vSeatNo, user)
	if not self:isValidSeat(vSeatNo) then return end

	local isSelf = (vSeatNo==1)
	if not self._isGameEnd then
		if not user.bOnline then
			self._players[vSeatNo]:setCutHead()
			self._players[vSeatNo]:setNeedFreshHead(false)
		else
			self._players[vSeatNo]:setHead(user.dwUserID, getHeadPath(user.bLogoID,user.bBoy))
		end
	end
end

function TableLayer:addUser(seatNo, bMe)
	if not self:isValidSeat(seatNo) then return end

	self._players[seatNo]:setUserID(self.tableLogic:getUserUserID(seatNo))
	self:setUserName(seatNo, "")
	self:setUserMoney(seatNo, 0)
	self:showUserMoney(seatNo, false)
	
	local lSeatNo = self.tableLogic:viewToLogicSeatNo(seatNo)
	if lSeatNo <= PLAY_COUNT then
		local LogonResult = self.tableLogic:getUserBySeatNo(lSeatNo)

		-- if LogonResult then
		-- 	self._name[lSeatNo] = self:checkUserNickName(LogonResult.sName)
		-- 	self._bDestion[lSeatNo] = LogonResult.dwUserID
		-- end
	end
end

function TableLayer:isValidSeat(seatNo)
	return (seatNo <= PLAY_COUNT and seatNo >= 0)
end

function TableLayer:checkUserNickName(nickName)
	-- return string.gsub(nickName, "\'", " ")
end

function TableLayer:setUserName(seatNo, name)
	if not self:isValidSeat(seatNo) then return end

	self._players[seatNo]:setUserName(name)
end

function TableLayer:setUserMoney(seatNo, money)
	if not self:isValidSeat(seatNo) then return end
	self._players[seatNo]:setUserMoneyGold(money)
end

function TableLayer:showUserMoney(seatNo, visible)
	if not self:isValidSeat(seatNo) then return end
	self._players[seatNo]:showMoneyGold(visible)
end

function TableLayer:leaveDesk(source)
    self:stopAllActions();
    _instance = nil;

    if source == nil then
        globalUnit.isEnterGame = false;
        RoomLogic:close();
    end
end

function TableLayer:clearDesk()
	for i=1, PLAY_COUNT do
		if self._cardListBoard[i] then
			self._cardListBoard[i]:clear()
			self._cardListBoard[i]:removeFromParent(true)
			self._cardListBoard[i] = nil
		end
	end
	-- 移除顿得点显示
	for i=1, PLAY_COUNT do
		for j=1, 3 do
			self:showPlayerDunScore(i, j, 0, false)
			self:showCardType(i, j, 0, false)
		end
	end

	self:showYaFenTip(false)
end

function TableLayer:clearUI()
	-- 摆牌界面
	if self._arrangeWidget then
		self._arrangeWidget:removeFromParent(true)
		self._arrangeWidget = nil
	end

	-- 特殊牌文字
	for i=1, PLAY_COUNT do
		if self._imgSpec[i] then
			self._imgSpec[i]:hide()
		end

		self:showScoreLabel(i, false)
	end
	self._imgSpec = Array(false, PLAY_COUNT)

	self._isPaidByOther = false
	self._isPaidPlayerExit = false

	-- 比牌
	for i=1, 3 do
		for j=1, PLAY_COUNT do
			for _, card in ipairs(self._VSCards[i][j]) do
				card:removeChildByTag(666)
				card:hide()
			end
		end
	end
	self._VSCards = Array("table", 3, PLAY_COUNT)

	-- 摆牌界面的蹲牌
	for i=1, 3 do
		for _, card in ipairs(self._dunCards[i]) do
			if not tolua.isnull(card) then
				card:removeFromParent()
			end
		end
	end
	self._dunCards = Array("table", 3)

end

function TableLayer:exitGame()
	if self._isGameEnd and self._isLeft then
		MessageRegister_HandleBackToMainScene()
	else
		self:leaveDesk()
	end
end

function TableLayer:showExitBtn(visible)
	self._btnExit:setVisible(visible)
end

function TableLayer:showPlayerInfo(vSeatNo, user, isShow)
	if not self:isValidSeat(vSeatNo) then return end

	local lSeat = self.tableLogic:viewToLogicSeatNo(vSeatNo)

	local isSelf = (vSeatNo==1)
	self:setUserMoney(vSeatNo, 0)

	if isShow or isSelf then
		self:setUserName(vSeatNo, user.nickName)
		self:showUserMoney(vSeatNo, true)
		self:setUserMoney(vSeatNo, user.i64Money)

		self._players[vSeatNo]:setHead(user.dwUserID, getHeadPath(user.bLogoID,user.bBoy))
	-- else
	-- 	self:setUserName(vSeatNo, "神秘玩家")
	-- 	self:showUserMoney(vSeatNo, false)

	-- 	self._players[vSeatNo]:setMysteryHead()
	end

end

function TableLayer:onClickExitGameCallBack(isRemove)
    if self.isTouchLayer then
        addScrollMessage("房间匹配中,请稍等!")
        return;
    end
    Hall:exitGame(false,function()
        RoomLogic:close();
    end);
end


function TableLayer:showChangeLoading()
    luaPrint("showChangeLoading-----------------")
    local scene = display.getRunningScene();

    LoadingLayer:createLoading(FontConfig.gFontConfig_22,"正在匹配,请稍后");

    if scene then
        local layer = scene:getChildByTag(9999);
        if layer then
            layer:updateLayerOpacity(0)
            if layer:getChildByName("enterText") then
                self:ChangeOldLayer(layer);--更改统一的loading界面
                self:startClock(layer) --创建启动倒计时
                self:cancelMatch(layer);
            end
        end
    end
end

--更改统一的loading界面
function TableLayer:ChangeOldLayer(layer)
    luaPrint("ChangeOldLayer------------");
    --隐藏进入房间字
    local enterText = layer:getChildByName("enterText");
    if enterText then
        enterText:setVisible(false);
    end
    --将动画向上移动
    local loadImage = layer:getChildByName("loadImage");
    if loadImage then
        loadImage:setPositionY(560);
        loadImage:removeSelf()
    end
    local winSize = cc.Director:getInstance():getWinSize();
    local enterText = cc.Sprite:create("game/ddz_fangjian.png");
    enterText:setPosition(winSize.width/2,winSize.height*0.65);
    enterText:setScale(0.5)
    layer:addChild(enterText)

    -- layer:updateLayerOpacity(200)
end

function TableLayer:startClock(layer)
    local times = 10
    local winSize = cc.Director:getInstance():getWinSize();
    local daojishi = FontConfig.createWithCharMap(tostring(times), "game/ddz_daojishizitiao.png", 34, 42, "+");
    daojishi:setPosition(winSize.width/2,winSize.height/2);
    layer:addChild(daojishi)

    daojishi:setString(tostring(times));
    local temp = tostring(times);
    -- local checkClockScheduler = nil;
    -- self.checkClockScheduler = schedule(self, function() 
    --     temp = temp -1;
    --     daojishi:setString(temp);
    --     if temp <= 0 then
    --         -- RoomLogic:close();
    --         self:sendCancelMatchMsg();
    --         self:stopAction(self.checkClockScheduler)
    --         self.checkClockScheduler = nil;
    --     end
    -- end, 1)

    local action1 = cc.DelayTime:create(1.0);
    local action2 = cc.CallFunc:create(function()
        temp = temp -1;
        if temp == 0 then
            -- RoomLogic:close();
            self:sendCancelMatchMsg();
            --self.Node_3:stopAllActions();
        elseif temp < 0 then
            temp = 0
        end

        local scene = display.getRunningScene();
        local layer = scene:getChildByTag(9999);
        if layer and daojishi and not tolua.isnull(daojishi) then 
            daojishi:setString(temp);
        end
    end);

    layer:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)));
end

function TableLayer:cancelMatch(layer)
    local winSize = cc.Director:getInstance():getWinSize();
    local btn = ccui.Button:create("game/ddz_quxiao.png","game/ddz_quxiao-on.png")
    btn:setPosition(winSize.width/2,winSize.height*0.35);
    layer:addChild(btn)
    btn:onClick(handler(self, self.onClickCancel))
end

function TableLayer:onClickCancel()
    luaPrint("TableLayer:onClickCancel")
    -- self:stopAction(self.checkClockScheduler)
    -- self.checkClockScheduler = nil; 
    --self.Node_3:stopAllActions();
    -- RoomLogic:close();
    self:sendCancelMatchMsg();
end

function TableLayer:sendCancelMatchMsg()
    local msg = {};
    msg.dwUserID = PlatformLogic.loginResult.dwUserID
    local cf = {
     {"dwUserID","INT"}
    }
    RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_END_MATCH_ROOM, msg, cf)
end

function TableLayer:onEndMatch()
    luaPrint("TableLayer 取消匹配",globalUnit.isEnterGame)
    LoadingLayer:removeLoading();
    Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end);
end

function TableLayer:onReceiveLogin()
	addScrollMessage("网络不太好哦，请检查网络")
	LoadingLayer:removeLoading();
    Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end);
end

function TableLayer:showFangjian()
    if self.isTouchLayer then
        return;
    end
    self.isTouchLayer = true;
    performWithDelay(self,function()  self.isTouchLayer = false end,1);
    shisanzhang.erterRoom = true;
    dispatchEvent("matchRoom",globalUnit.selectedRoomID);
    self:showChangeLoading();
end


return TableLayer
