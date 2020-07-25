local Player = class("Player", BaseWindow)
Factory(Player)

function Player:ctor(userID)
	self.wid_playerNode = nil
	self._userID = INVALID_USER_ID
	self._money = nil
	self._name = nil
	self._isDown = nil
	self._cardCount = nil
	self._path = nil
	self._textCardCount = nil
	self.img_head = nil
	self.img_master = nil
	self.text_name = nil
	self.text_money = nil
	self.text_money_gold = nil
	self.ui_tableUI = nil

	self:init(userID)
end

function Player:init(userID)
	self:setLayerTouchEnabled(true)

	self._userID = userID

	local uiTable = {
		{"img_head", "iHead"},
		{"img_master", "Image_1"},
		{"img_fen", "img_fen"},
		{"text_name", "lName"},
		{"text_money", "AtlasLabel_lMoney"},
		{"text_money_gold", "AtlasLabel_lMoney_gold"},
	}

	local jsonNode = UILoader:load("player/player.json", self, uiTable)
			:align(cc.p(0, 0), 0, 0)
			:addTo(self)
	self:setContentSize(jsonNode:getContentSize())
	self:initUI()
end

function Player:initUI()
	self.text_name:setString("")
	self.text_money:setString(0)
	self.text_money_gold:setString(0)

	self.img_master:hide()
end

function Player:setUserID(userID)
	self._userID = userID
end

function Player:setUserName(name)
	self._name = name or ""
	self.text_name:setString(self._name)
end

function Player:setUserMoney(money)
	self.text_money_gold:hide()
	self._money = money or ""
	self.text_money:setString(self._money)
end

-- 设置金币money
function Player:setUserMoneyGold(money)
	self.text_money:hide()
	self._money = money or ""
	if self._money~="" then
		self._money = goldConvert(self._money, true)
	end
	self.text_money_gold:setString(self._money)
end

function Player:setCutHead()
	self.img_head:loadTexture("player/duanx.png")
end

function Player:setHead(userID, path)
	self:setEmptyHead()
	self.img_head:loadTexture(path)
end

function Player:setEmptyHead()
	self.img_head:loadTexture("player/room_default_none.png")
end

function Player:setMysteryHead()
	self.img_head:loadTexture("player/head_mystery.png")
end

function Player:showMoney(visible)
	self.text_money:setVisible(visible)
end

function Player:showMoneyGold(visible)
	self.text_money_gold:setVisible(visible)
end

function Player:setTableUI(tableUI)
	self._tableUI = tableUI
end

--是否创建房间
function Player:setMaster(bMaster)
	if self.img_master then
		self.img_master:setVisible(bMaster)
		if bMaster then
			self.img_master:loadTexture("GameTable/shui13_res/fangzhu.png")
		end
   end

end

function Player:setBanker(bBanker)
	if self.img_master then
		self.img_master:setVisible(bBanker)
		if bBanker then
			self.img_master:loadTexture("GameTable/shui13_res/zhuangjia.png")
		end
    end
end

--设置玩家头像是否刷新
function Player:setNeedFreshHead(isNeed)
	self.img_head.needRefresh = isNeed
end

function Player:onTouchBegan(event)

end

function Player:onTouchEnded(event)

end

return Player
