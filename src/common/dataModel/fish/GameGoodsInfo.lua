local RoomDeal = require("net.room.RoomDeal"):getInstance();

local GameGoodsInfo = {}

GOODS_KUANGBAO = 1;--狂暴
GOODS_CALLFISH = 2;--召唤
GOODS_BINGDONG = 3;--冰冻
GOODS_HUAFEI = 10000;--话费券
GOODS_REDENVELOPES = 5;--红包

function GameGoodsInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function GameGoodsInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function GameGoodsInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_GET_GOODSINFO},
					{RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_UPDATE_GOODSINFO},
					{RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_SYN_GOODSINFO}
					}

	self.goodsListInfo = {}
	-- BindTool.register(self, "goodsListInfo", {});--物品表--一次性获取触发
	BindTool.register(self, "requestGoodsInfo", false);--请求物品信息
	BindTool.register(self, "useGoodsInfo", {});--使用物品
	BindTool.register(self, "getGoodsInfo", {});--获得物品

	BindTool.register(self, "synUseGoodsInfo", {});--使用物品
	BindTool.register(self, "synGetGoodsInfo", {});--获得物品

	self:refreshGoodsInfo({goodsID=GOODS_HUAFEI,goodsCount=0});
end

function GameGoodsInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function GameGoodsInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function GameGoodsInfo:unregisterCmdNotify(mainID,subID)
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

function GameGoodsInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_FRAME then
		if subID == RoomMsg.ASS_GET_GOODSINFO then
			self:onReceiveGoodsInfo(data.head,data.data);
		elseif subID == RoomMsg.ASS_UPDATE_GOODSINFO then
			self:onReceiveGoodsInfoChange(data.data);
		elseif subID == RoomMsg.ASS_SYN_GOODSINFO then
			self:onReceiveGoodsInfoSyn(data.data);
		end
	end
end

--获取物品信息
function GameGoodsInfo:sendGoodsInfoRequest()
	if globalUnit.isEnterGame ~= true then
		return;
	end

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_GET_GOODSINFO,msg,RoomMsg.CMD_C_GET_GOODSINFO);
end

--物品使用
function GameGoodsInfo:sendUseGoodsRequest(goodsID, goodsCount)
	if globalUnit.isEnterGame ~= true then
		return;
	end

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.goodsID = goodsID;
	msg.goodsCount = goodsCount or 1;
	luaDump(msg)
	RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_UPDATE_GOODSINFO,msg,RoomMsg.CMD_C_GOODSINFO);
end

--请求物品信息
function GameGoodsInfo:onReceiveGoodsInfo(messageHead,data)
	if PlatformLogic.loginResult.dwUserID ~= data.UserID then
		return;
	end

	luaDump(data,"请求物品");

	if messageHead.bHandleCode == 1 then
		luaDump(self.goodsListInfo,"self.goodsListInfo");
		self:setRequestGoodsInfo(true);
	else
		self:refreshGoodsInfo(data);
	end
end

--物品变化处理
function GameGoodsInfo:onReceiveGoodsInfoChange(data)
	if PlatformLogic.loginResult.dwUserID ~= data.UserID then
		return;
	end

	luaDump(data,"物品变化");

	local code = data.code;

	self:refreshGoodsInfo(data);

	if code == 0 then--使用物品
		self:setUseGoodsInfo(data);
	elseif code == 1 then--捕鱼获得物品
		self:setGetGoodsInfo(data);
	end
end

--同步其他人物品操作结果
function GameGoodsInfo:onReceiveGoodsInfoSyn(data)
	luaDump(data,"syn物品变化");

	if PlatformLogic.loginResult.dwUserID == data.UserID then
		return;
	end

	local code = data.code;
	if code == 0 then--使用物品
		self:setSynUseGoodsInfo(data);
	elseif code == 1 then--捕鱼获得物品
		self:setSynGetGoodsInfo(data);
	end
end

function GameGoodsInfo:refreshGoodsInfo(goodsInfo)
	local flag = false;
	
	goodsInfo.goodsIcon = "goods/goods"..goodsInfo.goodsID..".png";--物品图片
	goodsInfo.goodsBg = "goods/goodsBg1.png";
	goodsInfo.goodsTextBg = "goods/goodsText1.png";
	goodsInfo.goodsEffect = "goodsEffect"..goodsInfo.goodsID;
	goodsInfo.goodsTextNum = {image="goods/goodsNum1.png",width=12,height=17,char="0"};

	if goodsInfo.goodsID < 10000 then
		goodsInfo.isSkilling = true;
	else
		goodsInfo.isSkilling = false;
	end

	for k,v in pairs(self.goodsListInfo) do
		if v.goodsID == goodsInfo.goodsID then
			v.goodsCount = goodsInfo.goodsCount;
			flag = true
			break;
		end
	end

	goodsInfo.goodsName = self:getGoodsName(goodsInfo.goodsID);

	if flag == false then
		table.insert(self.goodsListInfo, goodsInfo);
	end
end

function GameGoodsInfo:refreshOffsetGoodsInfo(goodsInfo)
	for k,v in pairs(self.goodsListInfo) do
		if v.goodsID == goodsInfo.goodsID then
			v.goodsCount = goodsInfo.goodsCount + goodsInfo.goodsCount;
		end
	end
end

function GameGoodsInfo:getGoodsInfoByID(goodsID)
	luaPrint("find goodsID ----- "..goodsID)
	for k,v in pairs(self.goodsListInfo) do
		luaPrint("v.goodsID   ---------  "..v.goodsID)
		if v.goodsID == goodsID then
			return v;
		end
	end

	return nil;
end

function GameGoodsInfo:getGoodsListInfo(findType)
	if findType == 1 then
		local temp = {};

		for k,v in pairs(self.goodsListInfo) do
			if v.isSkilling == true then
				table.insert(temp,v);
			end
		end

		return temp;
	else
		return self.goodsListInfo;
	end
end

function GameGoodsInfo:getGoodsName(goodsID)
	if goodsID == GOODS_KUANGBAO then
		return "狂暴卡";
	elseif goodsID == GOODS_CALLFISH then
		return "召唤卡";
	elseif goodsID == GOODS_BINGDONG then
		return "冰冻卡";
	elseif goodsID == GOODS_HUAFEI then
		return "话费券";
	end

	return "";
end

return GameGoodsInfo;
