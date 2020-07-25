local TableLayer = class("TableLayer", BaseWindow)

local Player = require("shisanzhang.Player")
local TableLogic = require("shisanzhang.TableLogic")
local Audio = require("shisanzhang.Audio")
local CardListBoard = require("shisanzhang.CardListBoard")
local PokerCard = require("shisanzhang.PokerCard")
local CardLogic = require("shisanzhang.CardLogic")
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

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



local leaveFlag = -1;

local VSCardDelay = 0.7

function TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster)
	Event:clearEventListener();
	
	local layer = TableLayer.new(uNameId, bDeskIndex, bAutoCreate, bMaster)

	globalUnit.isFirstTimeInGame = false

	return layer
end

function TableLayer:ctor(uNameId, bDeskIndex, bAutoCreate, bMaster)
	--body
	self.super.ctor(self, 0, true)

	self.uNameId = uNameId
	self.bDeskIndex = bDeskIndex or 0
	self.bAutoCreate = bAutoCreate or false
	self.bMaster = bMaster or 0
	shisanzhangInfo:init()
	
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

	self.m_playerLeave = false;

	self.m_showEnd = false;

	self:init()
end

function TableLayer:init()
	self:loadLayout()

	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster)
	self.tableLogic:enterGame()

	self.IsGameEndEnter = {false,false,false,false}    --是否比牌时进入,不刷新金币

end

function TableLayer:onEnter()
	display.removeUnusedSpriteFrames()

	cc.FileUtils:getInstance():addSearchPath("shisanshui/specialAni/")

	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("NewAnimation/NewAnimation10.png", "NewAnimation/NewAnimation10.plist", "NewAnimation/NewAnimation1.ExportJson")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("NewAnimation/NewAnimation20.png", "NewAnimation/NewAnimation20.plist", "NewAnimation/NewAnimation2.ExportJson")
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("NewAnimation/NewAnimation30.png", "NewAnimation/NewAnimation30.plist", "NewAnimation/NewAnimation3.ExportJson")

	-- -- 特殊牌光效
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("NewAnimation/gameBtnAni0.png", "NewAnimation/gameBtnAni0.plist", "NewAnimation/gameBtnAni.ExportJson")

	cc.SpriteFrameCache:getInstance():addSpriteFrames("shisanzhang/cards/cards.plist")

	self:bindEvent()

	audio.playMusic("sound/background.mp3", true);

	self.super.onEnter(self)
end

function TableLayer:onExit()
	self.tableLogic:stop()
	self.super.onExit(self)
end

function TableLayer:bindEvent()
	self:pushEventInfo(shisanzhangInfo, "gameStartInfo", handler(self, self.receiveGameStartInfo))        		--游戏开始
	self:pushEventInfo(shisanzhangInfo, "sendCardInfo", handler(self, self.receiveSendCardInfo))  				--发牌
	self:pushEventInfo(shisanzhangInfo, "gameResultInfo", handler(self, self.receiveGameResultInfo))            --比牌结果
	self:pushEventInfo(shisanzhangInfo, "gameEndInfo", handler(self, self.receiveGameEndInfo))        			--游戏结束
	self:pushEventInfo(shisanzhangInfo, "openCardInfo", handler(self, self.receiveOpenCardInfo))           		--摊牌

	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack))      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame))      --后台回来
end

function TableLayer:receiveGameStartInfo(data)

end

function TableLayer:receiveSendCardInfo(data)
	luaDump(data._usedata, "fapai")

	data = data._usedata

	self.isPlaying = true
	for k,v in pairs(self.IsGameEndEnter) do
		v = false;
	end

	if self.isPlaying then
		self.tableLogic:onFaPai(data)
		for k,v in pairs(self.readyIMG) do
			v:setVisible(false)
		end
	end

	local dengdaitip = self._imgBg:getChildByName("dengdaitip");
    if dengdaitip then
        dengdaitip:removeFromParent();
    end
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
	self.bAutoGiveUp = data.bAutoGiveUp
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
		-- {"_panelRoomInfo",   "Panel_info"  },
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

	-- 牌型btn
	self._btnCardType:show()
	self._btnCardType:onClick(function() self:btnCardTypeCallback() end)

	-- 离开btn
	self._btnExit:show()
	self._btnExit:onClick(function() 
		self:onClickExitGameCallBack()
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
	local function loadYinyue()
		local tag = self._btnYinyue:getTag()

		if tag==1 then
			self._btnYinyue:loadTextures("settting/yinyue.png", "settting/yinyue-on.png")
		else
			self._btnYinyue:loadTextures("settting/yinyuex.png", "settting/yinyuex-on.png")
		end
	end

	if getMusicIsPlay() then
		self._btnYinyue:setTag(1)
	end
	loadYinyue()

	self._btnYinyue:onClick(function(sender)
		local tag = self._btnYinyue:getTag()

		setMusicIsPlay(not getMusicIsPlay())
		if tag==1 then
			self._btnYinyue:setTag(2)
			-- self._btnYinyue:loadTextures("settting/yinyuex.png", "settting/yinyuex-on.png")
		else
			self._btnYinyue:setTag(1)
			audio.playMusic("sound/background.mp3", true)
			-- self._btnYinyue:loadTextures("settting/yinyue.png", "settting/yinyue-on.png")
		end
		loadYinyue()
	end)

	self._btnYinxiao:show()
	local function loadYinxiao()
		local tag = self._btnYinxiao:getTag()

		if tag==1 then
			self._btnYinxiao:loadTextures("settting/yinxiao.png", "settting/yinxiao-on.png")
		else
			self._btnYinxiao:loadTextures("settting/yinxiaox.png", "settting/yinxiaox-on.png")
		end
	end

	if getEffectIsPlay() then
		self._btnYinxiao:setTag(1)
	end
	loadYinxiao()

	self._btnYinxiao:onClick(function(sender)
		setEffectIsPlay(not getEffectIsPlay());
		local tag = self._btnYinxiao:getTag()

		if tag==1 then
			self._btnYinxiao:setTag(2)
			-- self._btnYinxiao:loadTextures("settting/yinxiaox.png", "settting/yinxiaox-on.png")
		else
			self._btnYinxiao:setTag(1)
			-- self._btnYinxiao:loadTextures("settting/yinxiao.png", "settting/yinxiao-on.png")
		end
		loadYinxiao()
	end)

	self.readyIMG = {}
	--玩家初始化
	for i=1, PLAY_COUNT do
		local isSelf = (i==1)
		-- 玩家信息板
		local panel = UILoader:seekNodeByName(self._mainUI, "Image_playerHeadFrame"..i)
		local panelS = panel:getContentSize()
		if panel then
			local player = Player:create(INVALID_USER_ID)
			player:setAnchorPoint(cc.p(0.5, 0.5))
			player:setPosition(panelS.width/2, panelS.height/2)
			player:setEmptyHead()
			player:setTableUI(self)

			self._players[i] = player
			panel:addChild(player)
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

		local readyIMG = ccui.ImageView:create("desk/zhunbeiIMG.png")
	    readyIMG:setPosition(handCard:getPosition())
	    self._imgBg:addChild(readyIMG)
	    readyIMG:setVisible(false)
	    table.insert(self.readyIMG,readyIMG)
	end




	self._btnStart:hide()

	self._btnStart:onClick(handler(self,function()
			self.tableLogic:sendMsgReady()
		end))
	
	self._btnStart:setLocalZOrder(999)

	local winSize = cc.Director:getInstance():getWinSize()

	local btn = ccui.Button:create("shui13_res/jixuyouxi.png","shui13_res/jixuyouxi-on.png")
    btn:setPosition(winSize.width*0.4,winSize.height*0.35)
    self:addChild(btn,999)
    btn:onClick(handler(self,self.onClickBtnCallBack))
    btn:setName("Button_jixu")
    btn:setVisible(false)
    self.Button_jixu = btn;

    local btn1 = ccui.Button:create("shui13_res/likaifangjian.png","shui13_res/likaifangjian-on.png")
    btn1:setPosition(winSize.width*0.6,winSize.height*0.35)
    self:addChild(btn1,999)
    btn1:onClick(handler(self,self.onClickBtnCallBack))
    btn1:setName("Button_likai")
    btn1:setVisible(false)
    self.Button_likai = btn1;
	

	changeParent(self._btnCardType, self, TopZorder)
	changeParent(self._btnExit, self, TopZorder)
	changeParent(self._btnGZ, self, TopZorder)
	-- changeParent(self._btnYinyue, self, TopZorder)
	-- changeParent(self._btnYinxiao, self, TopZorder)
	changeParent(self._btnMore, self, TopZorder)
	changeParent(self._imgMore, self, TopZorder)

	self._btnMore:setPositionX(self._btnMore:getPositionX()-10);
	local pos = cc.p(self._btnMore:getPosition());
    --区块链bar
    self.m_qklBar = Bar:create("shisanzhang",self);
    self:addChild(self.m_qklBar,150);
    self.m_qklBar:setPosition(pos.x,pos.y-100);

    QukuailianMsg.PLAY_COUNT = PLAY_COUNT;
    QukuailianMsg.config.shisanzhang[2][2] = "QukuailianMsg.config.shisanzhang_item["..PLAY_COUNT.."]";
	
	if globalUnit.isShowZJ then
		self.m_logBar = LogBar:create(self,true);
		self._btnMore:addChild(self.m_logBar);
	end

	if globalUnit.isShowZJ then
		self._btnGZ:loadTextures("shisanzhang/zhanji/paixing.png","shisanzhang/zhanji/paixing-on.png")
		self._btnMore:loadTextures("shisanzhang/zhanji/gengduo-shisanzhang.png","shisanzhang/zhanji/gengduo-shisanzhang-on.png")
		self._imgMore:loadTexture("shisanzhang/zhanji/xialadiban.png")
		self._imgMore:setContentSize(cc.size(96,234))
		self._imgMore:setPositionY(self._imgMore:getPositionY()-30)

		local btn = ccui.Button:create("shisanzhang/zhanji/zhanji.png","shisanzhang/zhanji/zhanji-on.png");
		btn:setPosition(self._btnYinxiao:getPosition());
		self._imgMore:addChild(btn);
		btn:setName("Button_zhanji")
		btn:onClick(handler(self,function()
			if self.m_logBar then
				self.m_logBar:CreateLog();
			end
		end))

		self._btnYinyue:setPositionY(self._btnYinyue:getPositionY()+65)
		self._btnYinxiao:setPositionY(self._btnYinxiao:getPositionY()+70)
		
	end
end

function TableLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
    local tag = sender:getTag();
    if name == "Button_jixu" then
    	self.tableLogic:sendMsgReady()
    	self.Button_jixu:setVisible(false);
    	self.Button_likai:setVisible(false);
    elseif name == "Button_likai" then
    	self:onClickExitGameCallBack()
    end
end

function TableLayer:btnCardTypeCallback()
	local cardTypeWidget = UILoader:load("CardType.json"):addTo(self, TopZorder)
	local bg = UILoader:seekNodeByName(cardTypeWidget, "h_bg")
	bg:onClick(function() cardTypeWidget:removeFromParent() end)
end

-- 金币房信息
function TableLayer:showDeskInfoGold(nBasePoint, nMoneyLimit)
	-- self._panelRoomInfo:hide()
	-- self._lbPwd:setPositionY(100)
	-- self._lbMode:setPositionY(70)
	-- self._lbMoreRule:setPositionY(35)
	-- self._lbPwd:setString("金币场")
	-- self._lbMode:setString("底注:100倍")     	-- 游戏模式
	-- self._btnRule:hide()
	-- self._lbMoreRule:setString("打枪X2\n自动配牌")
	-- self._lbCount:hide()

	self.difen = string.format("%.2f", nBasePoint/100)
	-- self.ruchang = nMoneyLimit

	self.ruchang = nMoneyLimit
	
	if self.difen and self.difen~=0 then
		self._lbDiFen:show()
		self._lbDiFen:setString(self.difen)
	else
		self._lbDiFen:hide()
	end
end

-- 是否游戏开始
function TableLayer:isGameBegin()
	return g_nRoomCurJuCount == 0
end

function TableLayer:showUserState(seatNo, visible, name)
	if not self:isValidSeat(seatNo) then return end

	local img = UILoader:seekNodeByName(self._mainUI, string.format("role%d_state", seatNo))
	img:setLocalZOrder(20)
	img:setVisible(visible)

	local isSelf = (seatNo==1)
	if visible then
		local textures = {
			ready = "shui13_res/w_ready.png",
			outCard = "shui13_res/w_chupai.png",
			startVS = "shui13_res/w_bipai.png",
			qiangYes = "shui13_res/w_qiangz.png",
			qiangNo = "shui13_res/w_buqiangz.png",
		}
		img:loadTexture(textures[name])
	end

	if name=="ready" and isSelf then
		if visible then
			self:showStartBtn(false)
		else
			self:showStartBtn(true)
		end
	end

end

function TableLayer:hideAllState()
	for i=1, PLAY_COUNT do
		self:showUserState(i, false)
	end
end

function TableLayer:showGameStateTipWord(state, visible)

	local statePicName
	if state==GTipEnum.GTip_NoTips then
		statePicName = "shui13_res/alpha_0.png"
	elseif state==GTipEnum.GTip_Pls_Outcard then
		statePicName = "shui13_res/w_chupai.png"
		self._bExitOverGame = false
	elseif state==GTipEnum.GTip_Start_VScard
	or state==GTipEnum.GTip_Start_VScard_Spec  -- 这里原来是1111
	or state==GTipEnum.GTip_Start_VScard_End
	or state==GTipEnum.GTip_Start_VScard_Spec_End then -- 这里原来是1111
		statePicName = "shui13_res/w_bipai.png"
		Audio.startBiPai(true)
	elseif state==GTip_Wait_Next then
		statePicName = "shui13_res/w_dengdai.png"
	end

	local img = UILoader:seekNodeByName(self._mainUI, "img_gstate")
	img:loadTexture(statePicName)
	img:setVisible(visible)
	img:setLocalZOrder(10)

	if not visible then
		return
	end

	if state==GTipEnum.GTip_Pls_Outcard then
		local armature = ccs.Armature:create("NewAnimation1")
		armature:setPosition(display.center)
		armature:setScale(0.7)
		armature:getAnimation():play("kaishi")
		armature:setLocalZOrder(MainZorder)
		armature:setTag(12465)
		self._mainUI:addChild(armature)

		img:setScale(0)
		local action = cc.Sequence:create(
			cc.DelayTime:create(0.8),
			cc.ScaleTo:create(0.3, 1.2),
			cc.ScaleTo:create(0.1, 1),
			cc.DelayTime:create(2.5),
			cc.CallFunc:create(function()
				-- self.tableLogic:sendSendAllCardOK()
				self:changeToArrangeCardView()
				img:hide()
				self._mainUI:removeChildByTag(12465)
			end)
		)
		action:setTag(111)
		img:runAction(action)
	elseif state==GTipEnum.GTip_Start_VScard then
		local playercount = self.tableLogic:getUserCountInGame()
		
		log("playercount----------", playercount)
		self:clearShowCard()
		self.bWatcher = nil
		local action = cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.ScaleTo:create(0.3, 1.2),
			cc.ScaleTo:create(0.1, 1),
			cc.DelayTime:create(VSCardDelay),
			cc.CallFunc:create(function()
				-- 调用逻辑显示第几蹲
				self:runAction(cc.Sequence:create(
					cc.CallFunc:create(function()
						self.tableLogic:getVSCardResult(1, false, false)
					end), cc.DelayTime:create(playercount * VSCardDelay),
					cc.CallFunc:create(function()
						self.tableLogic:getVSCardResult(2, false, false)
					end), cc.DelayTime:create(playercount * VSCardDelay),
					cc.CallFunc:create(function()
						self.tableLogic:getVSCardResult(3, false, false)
					end), cc.DelayTime:create(playercount * VSCardDelay),
					cc.CallFunc:create(function()
						self.tableLogic:callGunOrKoAll()
					end), cc.DelayTime:create(self.tableLogic:getGunOrKoAll()+1),
					cc.CallFunc:create(function()
						self.tableLogic:dealGameEnd()
					end), cc.DelayTime:create(playercount * VSCardDelay)
				))
				img:hide()
			end)
		)
		action:setTag(222)
		img:runAction(action)
	elseif state==GTipEnum.GTip_Start_VScard_Spec then
		local playercount = self.tableLogic:getUserCountInGame(true)


		log("playercount----------", playercount)
		self:clearShowCard()
		self.bWatcher = nil
		for i=1, PLAY_COUNT do
			if self.tableLogic._gsbf.isteshu[i] then
				self:showBiPaiFinish(self.tableLogic:logicToViewSeatNo(i), true)
			end
		end
		local action = cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.ScaleTo:create(0.3, 1.2),
			cc.ScaleTo:create(0.1, 1),
			cc.DelayTime:create(VSCardDelay),
			cc.CallFunc:create(function()
				-- 调用逻辑显示第几蹲
				self:runAction(cc.Sequence:create(
					cc.CallFunc:create(function()
						self.tableLogic:getVSCardResult(1, true, false)
					end), cc.DelayTime:create(playercount * VSCardDelay),
					cc.CallFunc:create(function()
						self.tableLogic:getVSCardResult(2, true, false)
					end), cc.DelayTime:create(playercount * VSCardDelay),
					cc.CallFunc:create(function()
						self.tableLogic:getVSCardResult(3, true, false)
					end), cc.DelayTime:create(playercount * VSCardDelay),
					cc.CallFunc:create(function()
						self.tableLogic:callGunOrKoAll()
					end),
					cc.DelayTime:create(self.tableLogic:getGunOrKoAll()),
					cc.CallFunc:create(function()
						self.tableLogic:callSpecCard()
						self.tableLogic:callSpecCardEffect()
					end),
					cc.DelayTime:create(self.tableLogic:getSpecCardEffect()*3.2),
					cc.CallFunc:create(function()
						self.tableLogic:dealGameEnd()
					end), cc.DelayTime:create(playercount * VSCardDelay)
				))
				img:hide()
			end))
		action:setTag(222)
		img:runAction(action)
	end

end

-- 显示牌背
function TableLayer:showUserHandCardBack(seatNo, values)
	for i=1, PLAY_COUNT do
		for j=1, 3 do
			self:showPlayerDunScore(i, j, 0, false)
			self:showCardType(i, j, 0, false)
		end
	end

	if self:isValidSeat(seatNo) and self._players[seatNo] then
		if not self._cardListBoard[seatNo] then
			self:addHandCardList(seatNo)
		end

		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.1),
			
		cc.CallFunc:create(function()
			local i = self.tableLogic:viewToLogicSeatNo(seatNo)
			if not self.bWatcher or not self.bWatcher[i] then
				if self._cardListBoard[seatNo] then
					self._cardListBoard[seatNo]:clear()
					self._cardListBoard[seatNo]:addCardBack(values)
				end
			end
		end)))
	end
end

function TableLayer:clearShowCard()
	for i=1, PLAY_COUNT do
		for j=1, 3 do
			self:showPlayerDunScore(i, j, 0, false)
			self:showCardType(i, j, 0, false)
		end
	end
end

function TableLayer:showBiPaiFinish(seatNo, visible)
	if not self:isValidSeat(seatNo) then return end

	if self._readyBiPai[seatNo] then
		self._readyBiPai[seatNo]:setVisible(visible)

		if visible then
			if self._cardListBoard[seatNo] then
				self._cardListBoard[seatNo]:clear()
			end
		end
	end
end

function TableLayer:hideUserHandCard(seatNo)
	if not self:isValidSeat(seatNo) then return end

	if self._cardListBoard[seatNo] then
		self._cardListBoard[seatNo]:clear()
		self._cardListBoard[seatNo]:removeFromParent(true)
		self._cardListBoard[seatNo] = nil
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
	if self.isPlaying == false then
		self.IsGameEndEnter[seatNo] = true;
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
    globalUnit.isEnterGame = false;
    self:stopAllActions();
    _instance = nil;

    if source == nil then
        globalUnit.isEnterGame = false;
        if globalUnit.nowTingId == 0 then
	        RoomLogic:close();
	    end
    end
end

function TableLayer:setWaitTime(visible, time, onEndCallback)

	if self._imgClock then
		self._imgClock:setVisible(visible)

		if visible then
			if self._lbTimer then
				self._lbTimer:setTag(time)
				self._lbTimer:setString(time)
				self._lbTimer.onEndCallback = onEndCallback
				self:startTimer()
			end
		else
			self:stopTimer()
		end
	end
end

function TableLayer:startTimer()
	self:stopTimer()
	self:schedule(self.callEverySecond, 1)
end

function TableLayer:stopTimer()
	self:unschedule(self.callEverySecond)
end

function TableLayer:callEverySecond()
	if not self._lbTimer then
		self:stopTimer()
		return
	end

	local count = self._lbTimer:getTag()

	if count <=0 then
		self:stopTimer()

		if self._lbTimer.onEndCallback then
			self._lbTimer.onEndCallback()
		end
		return
	end

	count = count - 1
	self._lbTimer:setTag(count)
	self._lbTimer:setString(count)
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

	local dengdaitip = self._imgBg:getChildByName("dengdaitip");
    if dengdaitip then
        dengdaitip:removeFromParent();
    end

    self.m_playerLeave = false;
    self.m_showEnd = false;
    self._btnHZ:stopAllActions();
end

function TableLayer:showPlayerDunScore(seatNo, dunIdx, score, visible)
	if self._bExitOverGame and not visible then return end

	if self._roleDunLb[seatNo][dunIdx] then
		self._roleDunLb[seatNo][dunIdx]:setVisible(visible)
		if visible then
			local str_score = string.format(score>0 and "+%d" or (score<0 and "%d" or "/%d"), score)
			self._roleDunLb[seatNo][dunIdx]:setString(str_score)
			-- self._roleDunLb[seatNo][dunIdx]:setString("0")
		end
	end
end
-- 显示普通牌型
function TableLayer:showCardType(seatNo, dunIdx, cardType, visible)
	if self._bExitOverGame and not visible then return end

	-- cardType = PaiXinEnum.GRANDSTRAIGHT

	local sp = self._roleDunSpr[seatNo][dunIdx]
	local texture = PaiXinT[cardType].texture
	texture = type(texture)=="table" and texture[1] or texture
	if sp then
		sp:loadTexture(texture)
		sp:setVisible(visible)
		sp:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.2), cc.ScaleTo:create(0.2, 1)))
	end
end

function TableLayer:addHandCardList(seatNo)
	local ptr = UILoader:seekNodeByName(self._mainUI, string.format("iHandCard%d", seatNo))

	if ptr then
		self._cardListBoard[seatNo] = CardListBoard:create(seatNo==1, true, seatNo)
		self._cardListBoard[seatNo]:setPosition(ptr:getPosition())
		self._cardListBoard[seatNo]:setAnchorPoint(ptr:getAnchorPoint())
		self._cardListBoard[seatNo]:setRotation(ptr:getRotation())
		ptr:getParent():addChild(self._cardListBoard[seatNo], 2)
	end
end

function TableLayer:changeToArrangeCardView()
	if self._arrangeWidget then
		self._arrangeWidget:removeFromParent(true)
		self._arrangeWidget = nil
	end

	if self.tableLogic:getMySeatNo()==INVALID_DESKSTATION then
		return
	end

	local uiTable = {
		{"_panelMask", "Panel_mask"},
		{"_btnRecallD1", "btn_cancel1"},
		{"_btnRecallD2", "btn_cancel2"},
		{"_btnRecallD3", "btn_cancel3"},
		{"_btnRecallAll", "btn_allcancell"},
		{"_btnConfirmCard", "btn_confirm"},

		{"_btnPairs", "btn_tip_1"},
		{"_btnTwoPairs", "btn_tip_2"},
		{"_btnTriples", "btn_tip_3"},
		{"_btnStraight", "btn_tip_4"},
		{"_btnFlush", "btn_tip_5"},
		{"_btnFullHouse", "btn_tip_6"},
		{"_btnFour", "btn_tip_7"},
		{"_btnGrandStraight", "btn_tip_8"},
		{"_btnFive", "btn_tip_9"},
		{"_btnSpecial", "btn_tip_10"},

		{"_dun1", "dun1_left"},
		{"_dun2", "dun2_left"},
		{"_dun3", "dun3_left"},
		{"_touch_1", "touch_1dun"},
		{"_touch_2", "touch_2dun"},
		{"_touch_3", "touch_3dun"},
		{"_imgCombinationTips1", "Img_cbn_tips_1"},
		{"_imgCombinationTips2", "Img_cbn_tips_2"},
		{"_imgCombinationTips3", "Img_cbn_tips_3"},

		{"_lbTimerArrange", "clock_num"},
	}

	self._arrangeWidget = UILoader:load(PLAY_COUNT==4 and "ArrangeCard_1.json" or "ArrangeCard_2.json", self, uiTable):addTo(self, ArrangeZorder)

	self._arrangeWidget:move(0, display.height)
	self._arrangeWidget:runAction(cc.MoveTo:create(0.6, cc.p(0, 0)))
	

	self._panelMask:setAnchorPoint(cc.p(0.5, 0.5))
	self._panelMask:setPosition(display.center)
	iphoneXFit(self._panelMask)


	self._btnRecallD1:onClick(function(sender) self:arrangeMenuCallback(sender, 1) end)
	self._btnRecallD2:onClick(function(sender) self:arrangeMenuCallback(sender, 2) end)
	self._btnRecallD3:onClick(function(sender) self:arrangeMenuCallback(sender, 3) end)
	self._btnRecallAll:onClick(function(sender) self:arrangeMenuCallback(sender) end)
	self._btnConfirmCard:onClick(function(sender) self:arrangeMenuCallback(sender) end)

	self._btnPairs:onClick(function(sender) self:arrangeMenuCallback(sender, 1) end)
	self._btnTwoPairs:onClick(function(sender) self:arrangeMenuCallback(sender, 2) end)
	self._btnTriples:onClick(function(sender) self:arrangeMenuCallback(sender, 3) end)
	self._btnStraight:onClick(function(sender) self:arrangeMenuCallback(sender, 4) end)
	self._btnFlush:onClick(function(sender) self:arrangeMenuCallback(sender, 5) end)
	self._btnFullHouse:onClick(function(sender) self:arrangeMenuCallback(sender, 6) end)
	self._btnFour:onClick(function(sender) self:arrangeMenuCallback(sender, 7) end)
	self._btnGrandStraight:onClick(function(sender) self:arrangeMenuCallback(sender, 8) end)
	if self._btnFive then
		self._btnFive:onClick(function(sender) self:arrangeMenuCallback(sender, 9) end)
	end
	self._btnSpecial:onClick(function(sender) self:arrangeMenuCallback(sender) end)

	self._touch_1:onClick(function(sender) self:arrangeImageCallback(sender, 1) end)
	self._touch_2:onClick(function(sender) self:arrangeImageCallback(sender, 2) end)
	self._touch_3:onClick(function(sender) self:arrangeImageCallback(sender, 3) end)

	local armature = ccs.Armature:create("gameBtnAni")
	armature:move(self._btnSpecial:getContentSize().width/2, self._btnSpecial:getContentSize().height/2)
	armature:getAnimation():play("specBtn")
	self._btnSpecial:addChild(armature)

	for i=1, 3 do
		self.tableLogic._canRecall[i] = false
	end

	self:setCtrlBtn()

	-- 启动倒计时  显示玩家手牌cardlist
	self.tableLogic:showArrangeTime()

	-- 摆牌列表
	self:addArrangeCardList()
	self:showUserArrangeCard(self.tableLogic:getMyCard(), false)
end

function TableLayer:arrangeMenuCallback(sender, index)
	local name = sender:getName()

	if name=="btn_cancel1" or name=="btn_cancel2" or name=="btn_cancel3" then
		self.tableLogic:callOnRecall(index)

	elseif name=="btn_allcancell" then
		self.tableLogic:callOnRecallAll()
	elseif name=="btn_confirm" then
		self:confirmSubmit()

	elseif name=="btn_tip_1"
	or name=="btn_tip_2"
	or name=="btn_tip_3"
	or name=="btn_tip_4"
	or name=="btn_tip_5"
	or name=="btn_tip_6"
	or name=="btn_tip_7"
	or name=="btn_tip_8"
	or name=="btn_tip_9" then
		self.tableLogic:callOnCardsByType(index)
	elseif name=="btn_tip_10" then
		self:confirmSubmitSpec()
	end
end

-- 摆牌蹲位点击回调
function TableLayer:arrangeImageCallback(sender, dunIdx)
	local pos = sender:getTouchEndPosition()

	local count = CommonDunT[dunIdx].count
	local gap = CommonDunT[dunIdx].gap

	local index = math.floor((pos.x-sender:getPositionX()+sender:getContentSize().width/2)/gap)+1
	local card = self._dunCards[dunIdx][index]
	if not card then
		card = self._dunCards[dunIdx][index-1]
	end
	local value = card and CardLogic.BBWToGDI(card:getCardValue())
	local isCardUp = self.tableLogic:callOnDun(dunIdx, value)

	-- 两蹲摆满时自动上蹲
	local fullCount = 0
	local noFullIdx

	if isCardUp then
		-- 计算满蹲的个数
		for i=1, 3 do
			if self._dunCards[i].isFull then
				fullCount = fullCount + 1
			else
				noFullIdx = i
			end
		end
		if fullCount==2 then
			self.tableLogic:callOnDun(noFullIdx, 0)
		end
	end
end

-- 摆牌时间倒计时
function TableLayer:setArrangeCardTime(time, visible)
	local ptr = UILoader:seekNodeByName(self._arrangeWidget, "a_clock")

	if ptr then
		ptr:setVisible(visible)

		if visible then
			if self._lbTimerArrange and not tolua.isnull(self._lbTimerArrange) then
				UI.registerTimerLabel(self._lbTimerArrange, time, 0) 
			end
		end
	end
end

function TableLayer:getArrangeCardTime()
	local ptr = UILoader:seekNodeByName(self._arrangeWidget, "a_clock")

	if ptr then
		if self._lbTimerArrange then
			return self._lbTimerArrange:getTag()
		end
	end
	return 0;
end

-- 添加摆牌列表
function TableLayer:addArrangeCardList()
	local ptr = UILoader:seekNodeByName(self._arrangeWidget, "card_pos")

	if ptr then
		self._arrangeCardList = CardListBoard:create(true, false, 0)
		self._arrangeCardList:setPosition(ptr:getPosition())
		self._arrangeCardList:setAnchorPoint(ptr:getAnchorPoint())
		self._arrangeCardList:setCallFunction(handler(self, self.autoOutCallFunction))
		self._arrangeCardList:setCallFunctionUp(handler(self, self.autoUpCallFunction))
		self._arrangeCardList:setCallFunctionDown(handler(self, self.autoDownCallFunction))
		ptr:getParent():addChild(self._arrangeCardList, ptr:getLocalZOrder())
	end
end

function TableLayer:autoOutCallFunction(board)
	if not board then return end

	local outCards = board:getTouchedCards()
	self.tableLogic:autoOutCheck(outCards)
end

-- 上牌
function TableLayer:autoUpCallFunction(board, card)
	if not board then return end

	self.tableLogic:callSingleUp(card)
end

-- 下牌
function TableLayer:autoDownCallFunction(board, card)
	if not board then return end

	self.tableLogic:callSingleDown(card)
end

-- 设置点上的牌
function TableLayer:setUpCardList(upCards)
	if self._arrangeCardList then
		self._arrangeCardList:upCards(upCards)
	end
end

-- 显示摆牌界面手牌
function TableLayer:showUserArrangeCard(values, isUp)
	if not self._arrangeCardList then
		self:addArrangeCardList()
	end

	if not isUp then
		self._arrangeCardList:clear()
	end

	self._arrangeCardList:addCardAllOnce(values, isUp)
end

-- 设置按钮显隐状态
function TableLayer:setCtrlBtn()
	local bShowBtn = true
	local btnState = {}

	btnState[1] = self.tableLogic:canBtnRecallShow(1)
	btnState[2] = self.tableLogic:canBtnRecallShow(2)
	btnState[3] = self.tableLogic:canBtnRecallShow(3)
	btnState[4] = self.tableLogic:canBtnSubmitCancelShow()
	btnState[5] = self.tableLogic:canBtnSubmitCancelShow()
	btnState[6] = self.tableLogic:canBtnTipsShow(1)
	btnState[7] = self.tableLogic:canBtnTipsShow(2)
	btnState[8] = self.tableLogic:canBtnTipsShow(3)
	btnState[9] = self.tableLogic:canBtnTipsShow(4)
	btnState[10] = self.tableLogic:canBtnTipsShow(5)
	btnState[11] = self.tableLogic:canBtnTipsShow(6)
	btnState[12] = self.tableLogic:canBtnTipsShow(7)
	btnState[13] = self.tableLogic:canBtnTipsShow(8)
	btnState[14] = self.tableLogic:canBtnTipsShow(9)

	self._btnRecallD1:setVisible(btnState[1])
	self._btnRecallD2:setVisible(btnState[2])
	self._btnRecallD3:setVisible(btnState[3])
	self._btnRecallAll:setVisible(btnState[4])
	self._btnConfirmCard:setVisible(btnState[5])

	if btnState[4] and btnState[5] then
		bShowBtn = false
	end

	self._btnPairs:setVisible(bShowBtn)
	self._btnPairs:setEnabled(btnState[6])
	self._btnTwoPairs:setVisible(bShowBtn)
	self._btnTwoPairs:setEnabled(btnState[7])
	self._btnTriples:setVisible(bShowBtn)
	self._btnTriples:setEnabled(btnState[8])
	self._btnStraight:setVisible(bShowBtn)
	self._btnStraight:setEnabled(btnState[9])
	self._btnFlush:setVisible(bShowBtn)
	self._btnFlush:setEnabled(btnState[10])
	self._btnFullHouse:setVisible(bShowBtn)
	self._btnFullHouse:setEnabled(btnState[11])
	self._btnFour:setVisible(bShowBtn)
	self._btnFour:setEnabled(btnState[12])
	self._btnGrandStraight:setVisible(bShowBtn)
	self._btnGrandStraight:setEnabled(btnState[13])
	if self._btnFive then
		self._btnFive:setVisible(bShowBtn)
		self._btnFive:setEnabled(btnState[14])
	end

	-- 根据特殊牌反馈 进行显示
	self._btnSpecial:setVisible(self.tableLogic._gsSendCard.isteshu==1)
	self._btnSpecial:setEnabled(self.tableLogic._gsSendCard.isteshu==1)

end

-- 移除蹲牌
function TableLayer:removeDunCards(dunIdx)
	local dun = self._dunCards[dunIdx]
	for i=1, CommonDunT[dunIdx].count do
		if dun[i] then
			dun[i]:removeFromParent(true)
			dun[i] = nil
		end
	end
	dun.isFull = false
	self["_imgCombinationTips"..dunIdx]:hide()
end

-- 显示蹲牌
function TableLayer:showUserDun(dunIdx, values)
	self:removeDunCards(dunIdx)
	local touchDun = self["_touch_"..dunIdx]
	for i=1, #values do
		local cardPos = UILoader:seekNodeByName(touchDun, "card_bg_"..i)
		self._dunCards[dunIdx][i] = PokerCard:create(values[i])
		self._dunCards[dunIdx][i]:setPosition(cardPos:getPosition())
		self._dunCards[dunIdx][i]:setScale(cardPos:getScale())
		touchDun:addChild(self._dunCards[dunIdx][i])
	end

	-- 该蹲是否占满
	self._dunCards[dunIdx].isFull = (#values==CommonDunT[dunIdx].count)

end

-- 蹲之间比较大小错误提示
function TableLayer:warningArrangeError(errCode, dunIdx)
	if errCode==0 then
		return
	end

	-- 具体顿显示信息
	local sp = cc.Sprite:create(string.format("arrenge_res/errTip%d.png", errCode))
			:move(display.cx, display.cy+100)
			:addTo(self, ErrTipZorder)
			:runAction(cc.Sequence:create(
				cc.DelayTime:create(2),
				cc.FadeOut:create(1.5),
				cc.RemoveSelf:create()
			))

	-- 玩家操作  撤回
	self.tableLogic:callOnRecall(dunIdx)
end

-- 设置蹲位牌型提示
function TableLayer:showDunCardTips(dunIdx, cardType)
	local img_tips = self["_imgCombinationTips"..dunIdx]
	local texture = PaiXinT[cardType].texture
	texture = type(texture)=="table" and texture[2] or texture
	img_tips:show()
	img_tips:loadTexture(texture)
end

function TableLayer:confirmSubmitSpec()
	if self._arrangeWidget then
		self._arrangeWidget:runAction(cc.Sequence:create(
			cc.MoveTo:create(0.6, cc.p(0, display.height)),
			cc.CallFunc:create(function()
				self._arrangeWidget:removeFromParent(true)
				self._arrangeWidget = nil
			end)
		))
		self.tableLogic:callOnConfirmSubmitSpec()
	end
end

function TableLayer:confirmSubmit()
	if self._arrangeWidget then
		self._arrangeWidget:runAction(cc.Sequence:create(
			cc.MoveTo:create(0.6, cc.p(0, display.height)),
			cc.CallFunc:create(function()
				self._arrangeWidget:removeFromParent(true)
				self._arrangeWidget = nil
			end)
		))
		self.tableLogic:callOnConfirmSubmit()
	end
end

-- 显示比牌
function TableLayer:showVSCardResult(dunIdx, seatNo, score, px, cards, rank)
	local vsCards, count
	
	-- 特殊牌显示
	if dunIdx == 0 then
		vsCards = self._VSCards[1][seatNo]
		count = PLAYCARTCOUNT
	-- 非特殊牌
	else
		vsCards = self._VSCards[dunIdx][seatNo]
		count = CommonDunT[dunIdx].count
	end
	
	
	-- 排序
	if px >= 0 or px~=-9 then
		log("putong")
		CardLogic.SortPokers(cards)
	else	-- 三同花按花色牌型
		log("santonghua")
		CardLogic.SortPokersByColor(cards)
	end


	-- 六人场一起报牌
	if TableGlobal.isShowTogether() then
		rank = 1
	end
	
	local isSelf = (seatNo==1)
	local ptr, ptr1
	if dunIdx == 0 then
		ptr = UILoader:seekNodeByName(self._mainUI, string.format("iHandCard%d_spec", seatNo))
	else
		ptr1 = UILoader:seekNodeByName(self._mainUI, string.format("iHandCard%d", seatNo))
		ptr1:show()
		ptr = UILoader:seekNodeByName(ptr1, string.format("dun%d", dunIdx))
	end
	ptr:hide()

	for i=1, count do
		vsCards[i] = UILoader:seekNodeByName(ptr, string.format("card%d", i))
		log("loadtexture", string.format("0x%02X.png", cards[i]))
		vsCards[i]:loadTexture(string.format("0x%02X.png", cards[i]), ccui.TextureResType.plistType)
		vsCards[i]:removeChildByTag(666)
		if TableGlobal.iMaValue then
			if TableGlobal.iMaValue==cards[i] then
				local maFlag = cc.Sprite:create("cards/matag.png")
					:align(cc.p(0, 0.5), 4, 82)
					:addTo(vsCards[i])
				maFlag:setTag(666)
			end
		end

	end

	if self._arrangeWidget then
		self._arrangeWidget:removeFromParent(true)
		self._arrangeWidget = nil
	end

	-- local delayTime = PLAY_COUNT==6 and 0.6 or 0.9

	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(VSCardDelay*(rank-1)),
		cc.CallFunc:create(function()
			ptr:show()
			for i=1, count do
				vsCards[i]:show()
			end
			
			if px>=0 then
				local isboy = self.tableLogic:isBoy(self.tableLogic:viewToLogicSeatNo(seatNo))
				if not TableGlobal.isShowTogether() or isSelf then
					Audio.playCardType(px, isboy)
				end
				self:showPlayerDunScore(seatNo, dunIdx, score, true)
				self:showCardType(seatNo, dunIdx, px, true)
			else
				local specCardType = -1*px-1
				self:showCardTypeSpec(seatNo, specCardType)
			end
		end)
	))
end

function TableLayer:clearUI()
	-- 摆牌界面
	if self._arrangeWidget then
		self._arrangeWidget:removeFromParent(true)
		self._arrangeWidget = nil
	end

	-- 比牌动作
	luaPrint("stopAllActions")
	local img = UILoader:seekNodeByName(self._mainUI, "img_gstate")
	img:stopActionByTag(222)
	self:stopAllActions()

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

	-- 即将开始
	if self.willStartSpine then
		self.willStartSpine:removeFromParent()
		self.willStartSpine = nil
	end

end

function TableLayer:exitGame()
	if self._isGameEnd and self._isLeft then
		MessageRegister_HandleBackToMainScene()
	else
		self:leaveDesk()
	end
end

function TableLayer:showdaqiang(seat1, seat2, dt)
	local isboy = self.tableLogic:isBoy(seat1)
	seat1 = self.tableLogic:logicToViewSeatNo(seat1)
	seat2 = self.tableLogic:logicToViewSeatNo(seat2)

	local ptr1 = UILoader:seekNodeByName(self._mainUI, string.format("Image_playerHeadFrame%d", seat1))
	local ptr2 = UILoader:seekNodeByName(self._mainUI, string.format("allHandCard_%d", seat2))

	local armature = ccs.Armature:create("NewAnimation2"):addTo(self)
	armature:setPosition(ptr1:getPosition())
	armature:setLocalZOrder(100)


	local function showRandDong()
		local spr = cc.Sprite:create("shui13_res/dong.png")
				:move(ptr2:getPositionX()+math.random(-50, 50), ptr2:getPositionY()+math.random(-50, 50))
				:addTo(self._mainUI, CardZorder)
				:runAction(cc.Sequence:create(
					cc.FadeOut:create(3),
					cc.RemoveSelf:create()
				))
		Audio.playdaqiang1()
	end

    local x1,y1 = ptr1:getPosition()
    local x2,y2 = ptr2:getPosition()
    local directionP = cc.p(x2 - x1,y2 - y1)
    local angle = cc.pGetAngle(directionP,cc.p(1,0))
    local degree =  math.deg(angle)

    armature:setScaleX(0.65)
    armature:setRotation(degree)
    armature:setScaleY(directionP.x < 0 and - 0.65 or 0.65 )

	armature:hide()
	armature:runAction(cc.Sequence:create(
		cc.DelayTime:create(dt),
		cc.CallFunc:create(function()
			armature:show()
			armature:getAnimation():play("daqiang")
			Audio.playdaqiang(isboy)
		end),
		cc.DelayTime:create(0.2),
		cc.CallFunc:create(showRandDong),
		cc.DelayTime:create(0.2),
		cc.CallFunc:create(showRandDong),
		cc.DelayTime:create(0.2),
		cc.CallFunc:create(showRandDong),
		cc.DelayTime:create(0.2),
		cc.RemoveSelf:create()
	))

end

function TableLayer:removeUser(seatNo, bMe,bLock)
	if not self:isValidSeat(seatNo) then return end

	-- if bMe then
	-- 	self._btnExit:setTouchEnabled(false);
	-- 	self:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function()
	-- 		self._btnExit:setTouchEnabled(true);
	-- 		addScrollMessage("您的金币不足或长时间未操作,自动退出游戏。")
	-- 		self:onClickExitGameCallBack(5);
	-- 	end)))
	-- 	return
	-- end

	if bMe then
		luaPrint("removeUser--------------",bLock)

		leaveFlag = bLock;

		if bLock == 1 then
            self._btnHZ:setVisible(false);
            if self._btnKS then
            	self._btnKS:setVisible(false);
            end
			self._btnFH:setPositionX(self._btnFH:getPositionX()-110);
            -- addScrollMessage("您的金币不足!")
            -- self:BackCallBack(5);
            -- addScrollMessage("您的金币不足!")
        elseif bLock == 0 then
            
            -- BackCallBack(5);
        elseif bLock == 4 then
            -- self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
            --     self:onClick(self.Button_startgame);
            -- end)));
        elseif bLock == 3 then
            self._btnHZ:setVisible(false);
            if self._btnKS then
            	self._btnKS:setVisible(false);
            end
			-- self._btnFH:setPositionX(self._btnFH:getPositionX()-110);
            -- addScrollMessage("您长时间未操作!")
            addScrollMessage("您长时间未操作,自动退出游戏!")
			self:onClickExitGameCallBack()
        elseif bLock == 2 or bLock == 5 then
            -- self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
            --     BackCallBack(5);
            --     addScrollMessage("房间已关闭,自动退出游戏。")
            -- end)));  

   --          self._btnHZ:setVisible(false);
   --          if self._btnKS then
   --          	self._btnKS:setVisible(false);
   --          end
			-- self._btnFH:setPositionX(self._btnFH:getPositionX()-110);
			
			
			if self.isPlaying ~= true and self.tableLogic._bTanPaiFinished ~= true then
				if leaveFlag == 2 then
					addScrollMessage("您被厅主踢出VIP厅,自动退出游戏。")
				else
					addScrollMessage("VIP房间已关闭,自动退出游戏。")
				end
				self:onClickExitGameCallBack()
			end
        end
     

	else
		if globalUnit.nowTingId > 0 then
			self:RefreshHead(seatNo);
		elseif globalUnit.nowTingId == 0 then
			self.m_playerLeave = true;
			if self.m_showEnd then
                addScrollMessage("有玩家离开房间");
            end

			local dengdaitip = self._imgBg:getChildByName("dengdaitip");
	        if dengdaitip then
	            self:ClickReStart();
	        end
		end
	end
end

--刷新头像 seatNo视图位置
function TableLayer:RefreshHead(seatNo)
	self:showUserState(seatNo, false)

	self:setUserName(seatNo, "")
	self:setUserMoney(seatNo, 0)
	self:showUserMoney(seatNo, false)

	self._players[seatNo]:setUserID(INVALID_USER_ID)
	self._players[seatNo]:setEmptyHead()
	log("clear head", seatNo)

	local lSeatNo = self.tableLogic:viewToLogicSeatNo(seatNo)
	self._bDestion[lSeatNo] = false
	self._name[lSeatNo] = false

	-- 清空玩家 卡牌列表
	if self._cardListBoard[seatNo] then
		self._cardListBoard[seatNo]:clear()
		self._cardListBoard[seatNo]:removeFromParent(true)
		self._cardListBoard[seatNo] = nil
	end

	self:playerGetReady(seatNo, false)
end

-- 播放全垒打特效
function TableLayer:showquanleida(dt)
	local skeleton = createSkeletonAnimation("quanleida", "spine/quanleida.json", "spine/quanleida.atlas")
			:move(display.cx, display.cy)
			:hide()
			:addTo(self, SkeletonZorder)
	skeleton:runAction(cc.Sequence:create(
				cc.DelayTime:create(dt+0.5),
				cc.CallFunc:create(function()
					skeleton:show()
					skeleton:setAnimation(0, "quanleida", false)
				end),
				cc.DelayTime:create(0.2),
				cc.CallFunc:create(function()
					Audio.playqld(true)
					Audio.playQLDYX()
				end),
				cc.DelayTime:create(3),
				cc.RemoveSelf:create()
			))
end

-- 播放特殊牌特效
function TableLayer:playSpecCardEffect(cardTypeList)
	for i, v in ipairs(cardTypeList) do
		local specType = bit:_and(v, 0x7f)
		local isBoy = bit:_and(v, 0x8f)

		log(specType)
		local skeleton = createSkeletonAnimation(SpecialCardTypeT[specType].aniName, unpack(SpecialCardTypeT[specType].animation))
				:move(display.cx, display.cy)
				:hide()
				:addTo(self, SkeletonZorder)
		skeleton:runAction(cc.Sequence:create(
			cc.DelayTime:create((i-1)*3.2),
			cc.CallFunc:create(function()
				Audio.playCardTypeS(specType, isBoy)
				skeleton:show()
				skeleton:setAnimation(0, SpecialCardTypeT[specType].aniName, false)
			end),
			cc.DelayTime:create(3),
			cc.RemoveSelf:create()
		))
	end
end

-- 显示特殊牌型名
function TableLayer:showCardTypeSpec(seatNo, specType)

	local ptr = UILoader:seekNodeByName(self._mainUI, string.format("iHandCard%d_spec", seatNo))
	-- local ptr1 = UILoader:seekNodeByName(ptr, "special_type")

	-- local pos = cc.p(ptr:getPositionX()+ptr1:getPositionX(), ptr:getPositionY()+ptr1:getPositionY())
	-- local scale = ptr:getScale()*ptr1:getScale()

	self._imgSpec[seatNo] = UILoader:seekNodeByName(ptr, "special_type")
	self._imgSpec[seatNo]:show()
	self._imgSpec[seatNo]:loadTexture(string.format("shui13_res/teshu%d.png", specType))
	-- self._imgSpec[seatNo] = cc.Sprite:create(string.format("shui13_res/teshu%d.png", specType))
	-- 		:align(cc.p(0.5, 0.5), pos.x, pos.y)
	-- 		:addTo(self._mainUI)
	self._imgSpec[seatNo]:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.3, 1.2),
		cc.ScaleTo:create(0.2, 1)
	))
			
end

-- 分数特效
function TableLayer:showScoreLabel(seatNo, score)
	local str = ""
	if score then
		self._lbScore[seatNo]:show()
		if score>=0 then
			score = goldConvert(score, true)
			str = "+"..score
			self._lbScore[seatNo]:setProperty(str,"shui13_res/jiesuanzitiao1.png", 26, 50, '+')
		else
			score = goldConvert(score, true)
			str = score
			self._lbScore[seatNo]:setProperty(str,"shui13_res/jiesuanzitiao2.png", 26, 50, '+')
		end
	else
		self._lbScore[seatNo]:hide()
	end
end

-- 播放胜负平特效
function TableLayer:playResultEffect(result)
	-- local aniPath, aniName
	-- if result==1 then
	-- 	aniPath = {"spine/shengli.json", "spine/shengli.atlas"}
	-- 	aniName = "shengli"
	-- elseif result==2 then
	-- 	aniPath = {"spine/shibai.json", "spine/shibai.atlas"}
	-- 	aniName = "shibai"
	-- elseif result==3 then
	-- 	aniPath = {"spine/pingju.json", "spine/pingju.atlas"}
	-- 	aniName = "pingju"
	-- end

	-- local skeleton = createSkeletonAnimation(aniName, unpack(aniPath))
	-- 			:move(display.cx, display.cy)
	-- 			:hide()
	-- 			:addTo(self, SkeletonZorder)

	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(1),
		cc.CallFunc:create(function()
			if result==1 then
				Audio.playWin()
			elseif result==2 then
				Audio.playLose()
			elseif result==3 then
				Audio.playPing()
			end
			self:showResultWidget(true)
			if globalUnit.nowTingId> 0 then
				performWithDelay(self,function() 
					if leaveFlag == -1 then
						self:playWillStart() 
					else
						self:onClickExitGameCallBack()
					end
				end,2);
			end
			-- skeleton:show()
			-- skeleton:setAnimation(0, aniName, false)
		end)
		-- cc.DelayTime:create(2.5),
		-- cc.RemoveSelf:create(),
		-- cc.CallFunc:create(function()
			-- self:showResultWidget(true)
		-- end)
	))
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

function TableLayer:onClickExitGameCallBack()
	local func = function()
		self.tableLogic:sendUserUp();
    	self.tableLogic:sendForceQuit();
		self:leaveDesk();
	end
	Hall:exitGame(self.isPlaying,func);
end

function TableLayer:showGameStatus(obj, status)
	local data
	if status == GameMsg.GS_TK_FREE then
		data = convertToLua(obj,GameMsg.CMD_S_StatusFree)

	elseif status == GameMsg.GS_TK_GAME then
		data = convertToLua(obj,GameMsg.CMD_S_StatusPlay)
	end

	luaDump(data, status)

	self.bWatcher = data.bWatcher
	-- self:playDengDaiEffect(true,2);

	self:showDeskInfoGold(data.nBasePoint, data.nMoneyLimit)

	local mySeatNo = self.tableLogic:getMySeatNo()
	self:showGameStateTipWord(GTip_Wait_Next, status==GameMsg.GS_TK_FREE or data.bWatcher[mySeatNo])

	-- 游戏未开始
	if status == GameMsg.GS_TK_FREE then
		if data.bWatcher[mySeatNo] then
			self.isPlaying = false
		end
		if globalUnit.nowTingId == 0 then
			addScrollMessage("游戏已结束，自动退出房间");
			self:onClickExitGameCallBack();
		end
	-- 游戏中
	elseif status == GameMsg.GS_TK_GAME then
		self.isPlaying = not data.bWatcher[mySeatNo]

		if self.isPlaying then
			self.tableLogic:onFaPai({
				bHand = data.cbHandCardData,
				isteshu = data.bOxCard,
				time = data.iSYTime,
				bOpen = data.bOpen
			})
		else
			for i=1, PLAY_COUNT do
				local bExistPlayer = self.tableLogic._existPlayer[i]
				if not data.bWatcher[i] and bExistPlayer then
					local seatNo = self.tableLogic:logicToViewSeatNo(i)
					if data.bOpen[i]==1 then
						self:showBiPaiFinish(seatNo, true)
					else
						self:showUserHandCardBack(seatNo, Array(0, 13))
					end
				end
			end
		end
	end
end

-- 显示小结算
function TableLayer:showResultWidget(visible)
	if self._resultWidget then
		self._resultWidget:setVisible(visible)
		if visible then
			self._btnHZ:setEnabled(true);
			self._resultWidget:runAction(cc.MoveTo:create(0.5, cc.p(0, 0)))
			if globalUnit.isShowZJ then
				self.m_logBar:refreshLog();
			end
			if leaveFlag == 2 then
				addScrollMessage("您被厅主踢出VIP厅,自动退出游戏。")
				self:onClickExitGameCallBack()
			elseif leaveFlag == 1 then
				addScrollMessage("您的金币不足!")
			elseif leaveFlag == 5 then
				addScrollMessage("VIP房间已关闭,自动退出游戏。")
				self:onClickExitGameCallBack()
			elseif leaveFlag == 3 then	
				addScrollMessage("您长时间未操作!")
			end

			if globalUnit.nowTingId == 0 then
				if self.m_playerLeave then
					addScrollMessage("有玩家离开房间");
				end
				-- self.m_playerLeave = false;
				self.m_showEnd = true;

				--创建闹钟
				local naozhong = self._resultWidget:getChildByName("naozhong");
				if naozhong then
					naozhong:removeFromParent();
				end

				local framesize = cc.Director:getInstance():getWinSize()
				local naozhong = ccui.ImageView:create("shisanzhang/arrenge_res/jishiqi.png");
				naozhong:setPosition(230+(framesize.width-1280)/2,70);
				naozhong:setName("naozhong");
				self._resultWidget:addChild(naozhong);

				local time = 10;
				local nzSize = naozhong:getContentSize();
				local shuzi = FontConfig.createWithCharMap(tostring(time), "shisanzhang/arrenge_res/shuzi.png", 22, 30, "0");
				shuzi:setPosition(nzSize.width/2,nzSize.height/2);
				shuzi:setName("shuzi");
				naozhong:addChild(shuzi);

				self._btnHZ:setTag(time);
				self._btnHZ:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
					local tag = self._btnHZ:getTag();

					local naozhong = self._resultWidget:getChildByName("naozhong");
					local shuzi = nil;
					if naozhong then
						shuzi = naozhong:getChildByName("shuzi");
					end

					if tag > 0 then
						tag = tag-1;
						self._btnHZ:setTag(tag);
						if shuzi and not tolua.isnull(shuzi) then
							shuzi:setString(tag);
						end
					else
						-- self:ClickHZ(self._btnHZ);
						self._btnHZ:stopAllActions();
						self:onClickExitGameCallBack();
						addScrollMessage("结算阶段未操作，自动离开房间");
					end

					

				end))))
			end
		end
	end
end

--匹配
function TableLayer:ClickHZ()
	-- sender:setEnableWithTime()

	local flag = true;

    --随机概率
    local randomNum = math.random(1,10);

    if randomNum > 9 then
        flag = false;
        addScrollMessage("有玩家离开房间");
    end

    --有人离开直接匹配
    if self.m_playerLeave then
        flag = false;
    end

    if flag then
        self.tableLogic:sendMsgReady();
    else
		self:ClickReStart();
	end
end

--重新匹配
function TableLayer:ClickReStart()
	self.tableLogic:sendUserUp();
    self.tableLogic:sendForceQuit();
	UserInfoModule:clear()

	local score = tonumber(self._players[1]._money)*100
	local cellScore = self.difen

	if score < self.ruchang then
		local prompt = GamePromptLayer:create();
		prompt:showPrompt(GBKToUtf8("最低需要"..goldConvert(self.ruchang).."金币以上！"));
		prompt:setBtnClickCallBack(function() 
			local func = function()
				self:leaveDesk();
			end
			Hall:exitGame(false,func);
		end); 
		return;
	end
	
    local shisanzhang = require("shisanzhang");
    shisanzhang.reStart = true;
    UserInfoModule:clear();

	Hall:exitGame(1,function() 
        self:leaveDesk(1);
        shisanzhang:ReSetTableLayer(score,cellScore); 
    end);
end

function TableLayer:leaveDeskDdz(source)
    luaPrint("leaveDeskDdz",self._bLeaveDesk)
    if not self._bLeaveDesk then
        self._bLeaveDesk = true;

    end

    -- globalUnit.isEnterGame = false;
end

-- 初始小结算界面
function TableLayer:showGameResultView()

	for i=1, PLAY_COUNT do
		if self._cardListBoard[i] then
			self._cardListBoard[i]:clear()
			self._cardListBoard[i]:removeFromParent(true)
			self._cardListBoard[i] = nil
		end
	end

	if self._arrangeWidget then
		self._arrangeWidget:removeFromParent(true)
		self._arrangeWidget = nil
	end

	-- 中途结算移除UI
	self:setWaitTime(false)

	self:removeChildByName("sresult")
	local uiTable = {
		{"_imgBg", "img_bg"},
		{"_btnHZ", "Button_match"},
		{"_btnFH", "Button_close"},
		{"_btnShowUp", "show_up"},
		{"_btnHideDown", "hide_down"},
	}

	self._resultWidget = UILoader:load(string.format("FinishLayer_%dr.json", PLAY_COUNT), self, uiTable)
			:move(0, display.height*2)
			:addTo(self, ResultZorder)
	self._resultWidget:setName("sresult")
	self._resultWidget:hide()

	self._btnShowUp.pType = 1
	self._btnHideDown.pType = 1
	
	iphoneXFit(self._imgBg)

	-- 换桌
	self._btnHZ:onClick(function(sender)
		self:ClickReStart();
	end)

	-- 返回
	self._btnFH:onClick(function(sender)
		sender:setEnableWithTime()
		self:onClickExitGameCallBack()
	end)


	local function upDownFinishCallback(isUp)
		self._btnShowUp:setEnableWithTime()
		self._btnHideDown:setEnableWithTime()
		if self._resultWidget then
			if isUp then
				self._resultWidget:setOpacity(130)
				self._btnShowUp:hide()
	
				self._imgBg:runAction(cc.Sequence:create(
					cc.MoveTo:create(0.3, cc.p(self._imgBg:getPositionX(), display.height/2)),
					cc.CallFunc:create(function()
						self._btnHideDown:show()
					end)
				))
			else
				self._resultWidget:setOpacity(0)
				self._btnHideDown:hide()
	
				self._imgBg:runAction(cc.Sequence:create(
					cc.MoveTo:create(0.3, cc.p(self._imgBg:getPositionX(), 3*display.height/2)),
					cc.CallFunc:create(function()
						self._btnShowUp:show()
					end)
				))
			end
		end
	end

	if leaveFlag == 1 or leaveFlag == 2 or leaveFlag == 5 or globalUnit.nowTingId >0 then
		self._btnHZ:setVisible(false);
		self._btnFH:setPositionX(self._btnFH:getPositionX()-110);
	-- else
	-- 	if globalUnit.nowTingId >0 then
	-- 		self._btnHZ:setVisible(false);
	-- 		local btn = ccui.Button:create("desk/kaishiyouxi.png","desk/kaishiyouxi-on.png")
	--         btn:setPosition(self._btnHZ:getPosition())
	--         self._btnKS = btn
	--         self._imgBg:addChild(btn)
	--         btn:onClick(handler(self,function()
	-- 			self.tableLogic:sendMsgReady()
	-- 		end))
	-- 	end
	else
		local huanzhuo = ccui.Button:create("shui13_res/jixuyouxi.png","shui13_res/jixuyouxi-on.png");
        huanzhuo:setPosition(self._btnHZ:getPositionX()-50,self._btnHZ:getPositionY());
        self._imgBg:addChild(huanzhuo);
        huanzhuo:onClick(function(sender)
            self:ClickHZ();
        end)

        self._btnHZ:setPositionX(huanzhuo:getPositionX()+250);
        self._btnFH:setPositionX(self._btnHZ:getPositionX()+250);
        local framesize = cc.Director:getInstance():getWinSize()
        self._btnHideDown:setPositionX(self._btnHideDown:getPositionX()+(framesize.width-1280)/2);
        self._btnShowUp:setPositionX(self._btnShowUp:getPositionX()+(framesize.width-1280)/2);
	end

	performWithDelay(self,function() 
			if self.bAutoGiveUp then
				self._btnFH:setVisible(false);
			end
	end,2);
	

	self._btnShowUp:onClick(function(sender)
		upDownFinishCallback(true)
	end)

	self._btnHideDown:onClick(function(sender)
		upDownFinishCallback(false)
	end)

end

function TableLayer:setGameResultInfo(seatNo, rank, user, score, point, totalPoint, cards, specType)

	if self._resultWidget then
		self._resultWidget:hide()
		local bar = UILoader:seekNodeByName(self._imgBg, string.format("role_fbar_%d", rank))
		local barScale = bar:getScale()
		bar:show()

		local isSelf = (seatNo==1)
		-- 胜负
		if isSelf then
			local winTitle = UILoader:seekNodeByName(self._imgBg, "finish_win")
			local pingTitle = UILoader:seekNodeByName(self._imgBg, "finish_ping")
			local loseTitle = UILoader:seekNodeByName(self._imgBg, "finish_lose")

			winTitle:setVisible(score>0)
			pingTitle:setVisible(score==0)
			loseTitle:setVisible(score<0)
		end

		-- 玩家头像
		local head = UILoader:seekNodeByName(bar, "head_pic")
		-- 玩家昵称
		local lbName = UILoader:seekNodeByName(bar, "label_nick")
		head:loadTexture(getHeadPath(user.bLogoID, user.bBoy))
		lbName:setString(user.nickName)
		
		-- 玩家本局游戏得分
		local lbScore = UILoader:seekNodeByName(bar, "score_num")
		if score>=0 then
			lbScore:setProperty(str,"finish_res/zitiao-ying.png", 32, 40, '+')
			if score>0 then
				lbScore:setString("+"..goldConvert(score, true))
			else
				lbScore:setString(goldConvert(score, true))
			end
		else
			lbScore:setProperty(str,"finish_res/zitiao-shu.png", 32, 40, '+')
			lbScore:setString(goldConvert(score, true))
		end

		-- 特殊牌显示牌型
		local cardType = UILoader:seekNodeByName(bar, "label_teshu")
		if specType then
			-- local sp = cc.Sprite:create(string.format("shui13_res/teshu%d.png", specType))
			-- sp:setScale(0.8)
			-- sp:setAnchorPoint(cc.p(0.5, 0.5))
			-- sp:setPosition(lbScore:getContentSize().width/2, 70)
			-- lbScore:addChild(sp)
			-- lbScore:setPositionY(lbScore:getPositionY()-25)
			cardType:show()
			cardType:loadTexture(string.format("shui13_res/teshu%d.png", specType))
		else
			cardType:hide()
		end 

		-- 牌
		local cardList = UILoader:seekNodeByName(bar, specType and "card_list_teshu" or "card_list")
		for i=1, PLAYCARTCOUNT do
			local card = PokerCard.new(cards[i])
			local tempCard = UILoader:seekNodeByName(cardList, string.format("card_%d", i))

			card:setPosition(tempCard:getPosition())
			card:setScale(barScale*tempCard:getScale())
			tempCard:hide()
			cardList:show()
			cardList:addChild(card, 1000)
		end

	end
end

function TableLayer:showChangeLoading()
    luaPrint("showChangeLoading-----------------")
    local scene = display.getRunningScene();

    if scene then
        local layer = scene:getChildByTag(9999);
        if layer then
            if layer:getChildByName("enterText") and layer:getChildByName("loadImage") then
                self:ChangeOldLayer(layer);--更改统一的loading界面
                self:startClock(layer) --创建启动倒计时
                self:cancelMatch(layer);
            end
        end
    end
end
--更改统一的loading界面
function TableLayer:ChangeOldLayer(layer)
    --隐藏进入房间字
    local enterText = layer:getChildByName("enterText");
    if enterText then
        enterText:setVisible(false);
    end
    --将动画向上移动
    local loadImage = layer:getChildByName("loadImage");
    if loadImage then
        loadImage:setPositionY(560);
    end
    local winSize = cc.Director:getInstance():getWinSize();
    local enterText = cc.Sprite:create("shisanzhang/bg/ddz_fangjian.png");
    enterText:setPosition(winSize.width/2,winSize.height/2);
    layer:addChild(enterText)

    -- layer:updateLayerOpacity(200)
end

function TableLayer:startClock(layer)
    local times = 10
    local winSize = cc.Director:getInstance():getWinSize();
    local daojishi = FontConfig.createWithCharMap(tostring(times), "shisanzhang/number/ddz_daojishizitiao.png", 34, 42, "+");
    daojishi:setPosition(winSize.width/2,winSize.height/3);
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
        if temp <= 0 then
            -- RoomLogic:close();
            self:sendCancelMatchMsg();
            --self.Node_3:stopAllActions();
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
    local btn = ccui.Button:create("shisanzhang/bg/ddz_quxiao.png","shisanzhang/bg/ddz_quxiao-on.png")
    btn:setPosition(winSize.width/2,winSize.height/6);
    layer:addChild(btn)
    btn:onClick(handler(self, self.onClickCancel))
end

-- //服务器收到玩家已经准备好了
function TableLayer:playerGetReady(byStation, bAgree, isRecur)
    -- //准备好图片
    -- addScrollMessage("playerGetReady"..byStation)
    if globalUnit.nowTingId == 0 and byStation == 1 then
    	if self._btnHZ then
	    	self._btnHZ:stopAllActions();
	    	self._btnHZ:setEnabled(false);
	    end
		local bgSize = self._imgBg:getContentSize();
		local tip = ccui.ImageView:create("hall/game/ddz_fangjian.png");
		tip:setPosition(bgSize.width/2,bgSize.height/2);
		self._imgBg:addChild(tip,90);
		tip:setName("dengdaitip");
		if self.m_playerLeave then
	        self:ClickReStart();
	    end
	end
end

--即将开始 
function TableLayer:playWillStart()
	if self.isPlaying == true then
		return;
	end
	if self.bAutoGiveUp == true then
		self.Button_jixu:setVisible(true);
    	self.Button_likai:setVisible(true);
    	self._btnFH:setVisible(false);
	end
	local winSize = cc.Director:getInstance():getWinSize()
	local jijiangkaishi = createSkeletonAnimation("jijiangkaishi","spine/jijiangkaishi.json","spine/jijiangkaishi.atlas");
	if jijiangkaishi then
		jijiangkaishi:setPosition(winSize.width/2,winSize.height/2);
		jijiangkaishi:setAnimation(1,"5s", true);
		self:addChild(jijiangkaishi,999);
	end
	self.willStartSpine = jijiangkaishi;
	-- self:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function() 
	-- 	if self.willStartSpine then
	-- 		self.willStartSpine:removeFromParent();
	-- 	end
		
	-- 	self.willStartSpine = nil;
	-- 	self:clearUI()
    -- 	self:showResultWidget(false)
    -- 	-- 移除顿得点显示
	-- 	for i=1, PLAY_COUNT do
	-- 		for j=1, 3 do
	-- 			self:showPlayerDunScore(i, j, 0, false)
	-- 			self:showCardType(i, j, 0, false)
	-- 		end
	-- 	end
		
	-- 	self.Button_jixu:setVisible(false);
    -- 	self.Button_likai:setVisible(false);
		
	-- end)))
end

function TableLayer:playDengDaiEffect(enable,iType)
	if enable then
		if self.dengDaiSpine then
			self.dengDaiSpine:setVisible(true);
		end
	else
		if self.dengDaiSpine then
			self.dengDaiSpine:setVisible(false);
		end
		return;
	end
	local tipzi = {"dengxiaju","dengwanjia"}
	if self.dengDaiSpine then
		self.dengDaiSpine:clearTracks();
		self.dengDaiSpine:setAnimation(1,tipzi[iType], true);
	else
		self.dengDaiSpine = createSkeletonAnimation("dengdai","game/dengdai/dengdai.json","game/dengdai/dengdai.atlas");
		if self.dengDaiSpine then
			self.dengDaiSpine:setPosition(550,100);
			self.dengDaiSpine:setAnimation(1,tipzi[iType], true);
			self:addChild(self.dengDaiSpine,100);
		end
	end
end

return TableLayer
