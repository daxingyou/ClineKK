local RoomDeal = require("net.room.RoomDeal"):getInstance();

local SDBInfo = {}

function SDBInfo:init()
	self:initData();

	self:registerCmdNotify();

end

function SDBInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function SDBInfo:initData()
	self.cmdList = {
					--//命令定义\
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},-- //游戏开始
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},-- //游戏结束
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_ADD_SCORE},-- //玩家操作命令
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_CARD},-- //发牌命令
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GIVE_UP},-- //停牌命令
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_PLAY},-- //游戏开始
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BANKER_CARD},-- //庄家的牌
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_NO_ACTION},-- //玩家未操作
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SCORE},-- //玩家下注
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BAO},-- //玩家爆牌
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_QIANG},-- //玩家抢庄
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BEGIN},-- //开始抢庄
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GIVE_UP_BANK},-- //放弃庄
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLAY_BANK},-- //播放跑马灯动画
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLAYEFFECT},-- //玩家开始状态
					}
	BindTool.register(self, "GameStart", {});--游戏开始
	BindTool.register(self, "GameEnd", {});--游戏结束
	BindTool.register(self, "AddScore", {});--玩家操作命令
	BindTool.register(self, "SendCard", {});--发牌命令
	BindTool.register(self, "GiveUp", {});--停牌命令
	BindTool.register(self, "GamePlay", {});--游戏开始
	BindTool.register(self, "BankerCard", {});--庄家的牌
	BindTool.register(self, "NoAction", {});--玩家未操作
	BindTool.register(self, "PutScore", {});--玩家下注
	BindTool.register(self, "BaoCard", {});--玩家爆牌
	BindTool.register(self, "PlayerQiang", {});--玩家抢庄
	BindTool.register(self, "QiangBegin", {});--开始抢庄
	BindTool.register(self, "GiveUpBank", {});--放弃庄
	BindTool.register(self, "PlayBank", {});--播放跑马灯动画
	BindTool.register(self, "Begin", {});--玩家开始状态
end

function SDBInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end

end

--注销本表注册的所有事件
function SDBInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function SDBInfo:unregisterCmdNotify(mainID,subID)
	local isHave = false

	for k,v in pairs(self.cmdList) do
		if v[1] == mainID and v[2] == subID then
			isHave = true
			break
		end
	end

	if isHave then
		RoomDeal:unregisterCmdReceiveNotify(mainID,subID,self)
	end
end

function SDBInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_GAME_START then -- 游戏开始
			self:onGameStart(data);
		elseif subID == GameMsg.SUB_S_GAME_END then --游戏结束
			self:onGameEnd(data);
		elseif subID == GameMsg.SUB_S_ADD_SCORE then --玩家操作命令
			self:onAddScore(data);
		elseif subID == GameMsg.SUB_S_SEND_CARD then --发牌命令
			self:onSendCard(data);
		elseif subID == GameMsg.SUB_S_GIVE_UP then --停牌命令
			self:onGiveUp(data);
		elseif subID == GameMsg.SUB_S_GAME_PLAY then--游戏开始
			self:onGamePlay(data);
		elseif subID == GameMsg.SUB_S_BANKER_CARD then --庄家的牌
			self:onBankerCard(data);
		elseif subID == GameMsg.SUB_S_NO_ACTION then --玩家未操作
			self:onNoAction(data);
		elseif subID == GameMsg.SUB_S_SCORE then --玩家下注
			self:onPutScore(data);
		elseif subID == GameMsg.SUB_S_BAO then --玩家爆牌
			self:onBaoCard(data);
		elseif subID == GameMsg.SUB_S_QIANG then --玩家抢庄
			self:onPlayerQiang(data);
		elseif subID == GameMsg.SUB_S_BEGIN then --开始抢庄
			self:onQiangBegin(data);
		elseif subID == GameMsg.SUB_S_GIVE_UP_BANK then --放弃庄
			self:onGiveUpBank(data);
		elseif subID == GameMsg.SUB_S_PLAY_BANK then --播放跑马灯动画
			self:onPlayBank(data);
		elseif subID == GameMsg.SUB_S_PLAYEFFECT then --播放跑马灯动画
			self:onBegin(data);
		end
	end
end

--游戏开始
function SDBInfo:onGameStart(data)
	local msg = convertToLua(data, GameMsg.CMD_S_GameStart);
	luaDump(msg,"游戏开始")
	
	self:setGameStart(msg);
end
--游戏结束
function SDBInfo:onGameEnd(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd)
	luaDump(msg,"游戏结束");
	self:setGameEnd(msg);
end

--玩家操作命令
function SDBInfo:onAddScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_AddScore)
	luaDump(msg,"玩家操作命令");
	self:setAddScore(msg);
end

--发牌命令
function SDBInfo:onSendCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_SendCard)
	luaDump(msg,"发牌命令");
	self:setSendCard(msg);
end

--停牌命令
function SDBInfo:onGiveUp(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GiveUp)
	luaDump(msg,"停牌命令");
	self:setGiveUp(msg);
end

--游戏开始
function SDBInfo:onGamePlay(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GamePlay)
	luaDump(msg,"游戏开始");
	self:setGamePlay(msg);
end

--庄家的牌
function SDBInfo:onBankerCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_BankerCard)
	luaDump(msg,"庄家的牌");
	self:setBankerCard(msg);
end

--玩家未操作
function SDBInfo:onNoAction(data)
	self:setNoAction();
end

--玩家下注
function SDBInfo:onPutScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Score)
	luaDump(msg,"玩家下注");
	self:setPutScore(msg);
end

--玩家爆牌
function SDBInfo:onBaoCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Bao)
	luaDump(msg,"玩家爆牌");
	self:setBaoCard(msg);
end

--玩家抢庄
function SDBInfo:onPlayerQiang(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Qiang)
	luaDump(msg,"玩家抢庄");
	self:setPlayerQiang(msg);
end

--开始抢庄
function SDBInfo:onQiangBegin(data)
	local msg = convertToLua(data,GameMsg.CMD_S_BEGIN_BANK)
	luaDump(msg,"开始抢庄");
	self:setQiangBegin(msg);
end

--放弃庄
function SDBInfo:onGiveUpBank(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GIVE_UP_BANK)
	luaDump(msg,"放弃庄");
	self:setGiveUpBank(msg);
end

--播放跑马灯动画
function SDBInfo:onPlayBank(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PlayBank)
	luaDump(msg,"播放跑马灯动画");
	self:setPlayBank(msg);
end

--玩家开始状态
function SDBInfo:onBegin()
	self:setBegin(msg);
end

return SDBInfo;

