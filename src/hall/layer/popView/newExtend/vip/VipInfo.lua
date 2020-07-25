
--Vip

local PlatformDeal = require("net.platform.PlatformDeal"):getInstance();
local RoomDeal = require("net.room.RoomDeal"):getInstance()

local VipInfo = {}

function VipInfo:init()
	self:initData();

	self:registerCmdNotify();
end


function VipInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function VipInfo:initData()
	self.cmdList = {
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_CREATE_GUILD_REQ},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GET_GUILD_LIST},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_CREATE_GUILD},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_APPLY_JOIN},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_APPLY_JOIN_REQ},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GET_GUILD_USER},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_AGREE_JOIN},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_REJECT_JOIN},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_CHANGE_USERNOTE},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_QUIT_JOIN},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_DELETE_GUILD},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_KICK_GUILD_USER},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_CHANGE_RULE},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_CREATE_REQ_MEMBER},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_SETTOP},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_TAXDETAIL},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_MEMBERDETAIL},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_RECORD_REQ},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_MEMBER_USERLIST},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GET_CALLTIME},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_ONEKEYCALL},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_CHANGERULE_REQ},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_DELETE_NOTIFY},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_CHANGE_NOTIFY},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_KICK_NOTIFY},

					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_HOLDER_REQ},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_HOLDER_SET},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_TIME},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_REQ},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_AGREE},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_DETAIL},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_DETAIL_HOLDER},
					{VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_SENDMONEY_REQ},



					}

	self.cmdListR = {
					{RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_ROOM_GUILD_CHANGE},
					{RoomMsg.MDM_GR_ROOM,VipMsg.ASS_GR_GUILD_DESKINFO},
					{RoomMsg.MDM_GR_ROOM,VipMsg.ASS_GR_GUILD_DESKINFO_UPDATE},
					}

	BindTool.register(self, "noGuildInfo", {});--没有公会
	BindTool.register(self, "haveGuildInfo", {});--有公会
	BindTool.register(self, "createGuildInfo", {});--创建公会
	BindTool.register(self, "applyjoinGuildInfo", {});--申请加入公会
	BindTool.register(self, "applyjoinGuildReq", {});--查询公会
	BindTool.register(self, "getGuildUser", {});--成员列表
	BindTool.register(self, "agreeJoinInfo", {});--通过申请
	BindTool.register(self, "rejectJoinInfo", {});--拒绝申请
	BindTool.register(self, "changeUserNodeInfo", {});--修改备注
	BindTool.register(self, "quitGuildInfo", {});--成员退出厅
	BindTool.register(self, "deleteGuildInfo", {});--厅主解散厅
	BindTool.register(self, "kickGuildUser", {});--厅主踢人
	BindTool.register(self, "changeRuleInfo", {});--厅主修改规则
	BindTool.register(self, "createReqMember", {});--普通成员界面查询VIP配置
	BindTool.register(self, "guildSettop", {});--置顶
	BindTool.register(self, "guildTaxDetail", {});--税收详情
	BindTool.register(self, "guildMemberDetail", {});--成员详情
	BindTool.register(self, "guildRecordReq", {});--成员战绩
	BindTool.register(self, "memberUserList", {});--成员功能（厅详情）
	BindTool.register(self, "getCallTime", {});--一键召集时间
	BindTool.register(self, "guildOneKeyCall", {});--一键召集
	BindTool.register(self, "guildChangeRuleReq", {});
	BindTool.register(self, "roomGuildChange", {});
	BindTool.register(self, "guildDeleteNotify", {});
	BindTool.register(self, "guildChangeNotify", {});	
	BindTool.register(self, "guildKickNotify", {});	
	BindTool.register(self, "guildDeskInfo", {});	
	BindTool.register(self, "guildDeskInfoUpdate", {});

	--股东
	BindTool.register(self, "guildHolderReq", {});
	BindTool.register(self, "guildHolderSet", {});
	BindTool.register(self, "guildCommendTime", {});
	BindTool.register(self, "guildCommendReq", {});
	BindTool.register(self, "guildCommend", {});
	BindTool.register(self, "guildCommendAgree", {});
	BindTool.register(self, "guildCommendDetail", {});
	BindTool.register(self, "guildSendMoneyReq", {});


end

function VipInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end

	for k,v in pairs(self.cmdListR) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function VipInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end

	if isEmptyTable(self.cmdListR) then
		return
	end

	for k,v in pairs(self.cmdListR) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function VipInfo:unregisterCmdNotify(mainID,subID)
	local isHave = false

	for k,v in pairs(self.cmdList) do
		if v[1] == mainID and v[2] == subID then
			isHave = true
			break
		end
	end

	if isHave then
		PlatformDeal:unregisterCmdReceiveNotify(mainID,subID,self)
	end

	isHave = false

	for k,v in pairs(self.cmdListR) do
		if v[1] == mainID and v[2] == subID then
			isHave = true
			break
		end
	end

	if isHave then
		RoomDeal:unregisterCmdReceiveNotify(mainID,subID,self)
	end
end

function VipInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == VipMsg.MDM_GP_GUILD then
		if subID == VipMsg.ASS_GP_CREATE_GUILD_REQ then --没有公会
			self:onReceiveNoGuildInfo(data.data);
		elseif subID == VipMsg.ASS_GP_GET_GUILD_LIST then --有公会
			self:onReceiveHaveGuildInfo(data.data);
		elseif subID == VipMsg.ASS_GP_CREATE_GUILD then --创建公会
			self:onReceiveCreateGuildInfo(data.data);
		elseif subID == VipMsg.ASS_GP_APPLY_JOIN then --申请加入公会
			self:onReceiveApplyjoinGuildInfo(data.data);
		elseif subID == VipMsg.ASS_GP_APPLY_JOIN_REQ then --查询公会
			self:onReceiveApplyjoinGuildReq(data.data);
		elseif subID == VipMsg.ASS_GP_GET_GUILD_USER then --成员列表
			self:onReceiveGetGuildUser(data.data);
		elseif subID == VipMsg.ASS_GP_AGREE_JOIN then --通过申请
			self:onReceiveAgreeJoinInfo(data.data);
		elseif subID == VipMsg.ASS_GP_REJECT_JOIN then --拒绝申请
			self:onReceiveRejectJoinInfo(data.data);
		elseif subID == VipMsg.ASS_GP_CHANGE_USERNOTE then --修改备注
			self:onReceiveChangeUserNodeInfo(data.data);
		elseif subID == VipMsg.ASS_GP_QUIT_JOIN then --成员退出厅
			self:onReceiveQuitGuild(data.data);
		elseif subID == VipMsg.ASS_GP_DELETE_GUILD then --厅主解散厅
			self:onReceiveDeleteGuild(data.data);
		elseif subID == VipMsg.ASS_GP_KICK_GUILD_USER then --厅主踢人
			self:onReceiveKickGuildUser(data.data);
		elseif subID == VipMsg.ASS_GP_CHANGE_RULE then --厅主修改规则
			self:onReceiveChangeRuleInfo(data.data);
		elseif subID == VipMsg.ASS_GP_CREATE_REQ_MEMBER then --普通成员界面查询VIP配置
			self:onReceiveCreateReqMember(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_SETTOP then --置顶
			self:onReceiveGuildSettop(data.data);
		elseif subID == VipMsg.ASS_GP_GUILD_TAXDETAIL then --税收详情
			self:onReceiveGuildTaxDetail(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_MEMBERDETAIL then --成员详情
			self:onReceiveGuildMemberDetail(data.data);
		elseif subID == VipMsg.ASS_GP_GUILD_RECORD_REQ then --成员战绩
			self:onReceiveGuildRecordReq(data.data);
		elseif subID == VipMsg.ASS_GP_MEMBER_USERLIST then --成员功能（厅详情）
			self:onReceiveMemberUserList(data.data);
		elseif subID == VipMsg.ASS_GP_GET_CALLTIME then --一键召集时间
			self:onReceiveGetCallTime(data.data);			
		elseif subID == VipMsg.ASS_GP_GUILD_ONEKEYCALL then --一键召集
			self:onReceiveGuildOneKeyCall(data.data);
		elseif subID == VipMsg.ASS_GP_GUILD_CHANGERULE_REQ then --
			self:onReceiveGuildChangeRuleReq(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_DELETE_NOTIFY then --
			self:onReceiveGuildDeleteNotify(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_CHANGE_NOTIFY then --
			self:onReceiveGuildChangeNotify(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_KICK_NOTIFY then --
			self:onReceiveGuildKickNotify(data.data);	
		---------股东
		elseif subID == VipMsg.ASS_GP_GUILD_HOLDER_REQ then --
			self:onReceiveGuildHolderReq(data.data);
		elseif subID == VipMsg.ASS_GP_GUILD_HOLDER_SET then --
			self:onReceiveGuildHolderSet(data.data);
		elseif subID == VipMsg.ASS_GP_GUILD_COMMEND_TIME then --
			self:onReceiveGuildCommendTime(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_COMMEND_REQ then --
			self:onReceiveGuildCommendReq(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_COMMEND then --
			self:onReceiveGuildCommend(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_COMMEND_AGREE then --
			self:onReceiveGuildCommendAgree(data.data);	
		elseif subID == VipMsg.ASS_GP_GUILD_COMMEND_DETAIL or subID == VipMsg.ASS_GP_GUILD_COMMEND_DETAIL_HOLDER then --
			self:onReceiveGuildCommendDetail(data.data);		
		elseif subID == VipMsg.ASS_GP_GUILD_SENDMONEY_REQ then --
			self:onReceiveGuildSendMoneyReq(data.data);	

		end
	elseif mainID == RoomMsg.MDM_GM_GAME_FRAME then
		if subID == RoomMsg.ASS_ROOM_GUILD_CHANGE then --
			self:onReceiveRoomGuildChange(data.data);	
		end
	elseif mainID == RoomMsg.MDM_GR_ROOM then
		if subID == VipMsg.ASS_GR_GUILD_DESKINFO then --
			self:onReceiveGuildDeskInfo(data.data);	
		elseif subID == VipMsg.ASS_GR_GUILD_DESKINFO_UPDATE then --
			self:onReceiveGuildDeskInfoUpdate(data.data);	
		end
	
	end
end

--没有公会
function VipInfo:onReceiveNoGuildInfo(data)
	luaDump(data,"没有公会")
	self:setNoGuildInfo(data);
end

--有公会
function VipInfo:onReceiveHaveGuildInfo(data)
	luaDump(data,"有公会")
	self:setHaveGuildInfo(data);
end

--创建公会
function VipInfo:onReceiveCreateGuildInfo(data)
	luaDump(data,"创建公会")
	self:setCreateGuildInfo(data);
end

--申请加入公会
function VipInfo:onReceiveApplyjoinGuildInfo(data)
	luaDump(data,"申请加入公会")
	self:setApplyjoinGuildInfo(data);
end

--查询公会
function VipInfo:onReceiveApplyjoinGuildReq(data)
	luaDump(data,"查询公会")
	self:setApplyjoinGuildReq(data);
end

-- --成员列表
function VipInfo:onReceiveGetGuildUser(data)
	luaDump(data,"成员列表")
	self:setGetGuildUser(data);
end

-- --通过申请
function VipInfo:onReceiveAgreeJoinInfo(data)
	luaDump(data,"通过申请")
	self:setAgreeJoinInfo(data);
end

-- --拒绝申请
function VipInfo:onReceiveRejectJoinInfo(data)
	luaDump(data,"拒绝申请")
	self:setRejectJoinInfo(data);
end

-- --修改备注
function VipInfo:onReceiveChangeUserNodeInfo(data)
	luaDump(data,"修改备注")
	self:setChangeUserNodeInfo(data);
end

-- --成员退出厅
function VipInfo:onReceiveQuitGuild(data)
	luaDump(data,"成员退出厅")
	self:setQuitGuildInfo(data);
end

-- --厅主解散厅
function VipInfo:onReceiveDeleteGuild(data)
	luaDump(data,"厅主解散厅")
	self:setDeleteGuildInfo(data);
end

-- --厅主踢人
function VipInfo:onReceiveKickGuildUser(data)
	luaDump(data,"厅主踢人")
	self:setKickGuildUser(data);
end

-- --厅主修改规则
function VipInfo:onReceiveChangeRuleInfo(data)
	luaDump(data,"厅主修改规则")
	self:setChangeRuleInfo(data);
end

-- --普通成员界面查询VIP配置
function VipInfo:onReceiveCreateReqMember(data)
	luaDump(data,"普通成员界面查询VIP配置")
	self:setCreateReqMember(data);
end

-- --置顶
function VipInfo:onReceiveGuildSettop(data)
	luaDump(data,"置顶")
	self:setGuildSettop(data);
end

-- --税收详情
function VipInfo:onReceiveGuildTaxDetail(data)
	luaDump(data,"税收详情")
	self:setGuildTaxDetail(data);
end

-- --成员详情
function VipInfo:onReceiveGuildMemberDetail(data)
	luaDump(data,"成员详情")
	self:setGuildMemberDetail(data);
end

-- --成员战绩
function VipInfo:onReceiveGuildRecordReq(data)
	luaDump(data,"成员战绩")
	self:setGuildRecordReq(data);
end

-- --成员功能（厅详情）
function VipInfo:onReceiveMemberUserList(data)
	luaDump(data,"成员功能（厅详情）")
	self:setMemberUserList(data);
end

-- --一键召集时间
function VipInfo:onReceiveGetCallTime(data)
	luaDump(data,"一键召集时间")
	self:setGetCallTime(data);
end

-- --一键召集
function VipInfo:onReceiveGuildOneKeyCall(data)
	luaDump(data,"一键召集")
	self:setGuildOneKeyCall(data);
end

-- --
function VipInfo:onReceiveGuildChangeRuleReq(data)
	luaDump(data,"税率")
	self:setGuildChangeRuleReq(data);
end


function VipInfo:onReceiveRoomGuildChange(data)
	luaDump(data,"onReceiveRoomGuildChange")
	self:setRoomGuildChange(data);
end

function VipInfo:onReceiveGuildDeleteNotify(data)
	luaDump(data,"onReceiveGuildDeleteNotify")
	self:setGuildDeleteNotify(data);
end


function VipInfo:onReceiveGuildChangeNotify(data)
	luaDump(data,"onReceiveGuildChangeNotify")
	self:setGuildChangeNotify(data);
end

function VipInfo:onReceiveGuildKickNotify(data)
	luaDump(data,"onReceiveGuildKickNotify")
	self:setGuildKickNotify(data);
end

function VipInfo:onReceiveGuildDeskInfo(data)
	luaDump(data,"onReceiveGuildDeskInfo")
	self:setGuildDeskInfo(data);
end

function VipInfo:onReceiveGuildDeskInfoUpdate(data)
	luaDump(data,"onReceiveGuildDeskInfoUpdate")
	self:setGuildDeskInfoUpdate(data);
end

-----股东
function VipInfo:onReceiveGuildHolderReq(data)
	luaDump(data,"onReceiveGuildHolderReq")
	self:setGuildHolderReq(data);
end

function VipInfo:onReceiveGuildHolderSet(data)
	luaDump(data,"onReceiveGuildHolderSet")
	self:setGuildHolderSet(data);
end

function VipInfo:onReceiveGuildCommendTime(data)
	luaDump(data,"onReceiveGuildCommendTime")
	self:setGuildCommendTime(data);
end

function VipInfo:onReceiveGuildCommendReq(data)
	luaDump(data,"onReceiveGuildCommendReq")
	self:setGuildCommendReq(data);
end

function VipInfo:onReceiveGuildCommend(data)
	luaDump(data,"onReceiveGuildCommend")
	self:setGuildCommend(data);
end

function VipInfo:onReceiveGuildCommendAgree(data)
	luaDump(data,"onReceiveGuildCommendAgree")
	self:setGuildCommendAgree(data);
end

function VipInfo:onReceiveGuildCommendDetail(data)
	luaDump(data,"onReceiveGuildCommendDetail")
	self:setGuildCommendDetail(data);
end

function VipInfo:onReceiveGuildSendMoneyReq(data)
	luaDump(data,"onReceiveGuildSendMoneyReq")
	self:setGuildSendMoneyReq(data);
end


-----------------------------------------------------------------------------------
--查询VIP配置
function VipInfo:sendGetVipInfo()
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_CREATE_GUILD_REQ,msg,VipMsg.MSG_GP_CREATE_GUILD_REQ);
end

--创建公会
function VipInfo:sendBuildGuild(GuildName,GameStates,RoomStates,iTaxRate)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildName = GuildName;
	msg.GameStates = GameStates;
	msg.RoomStates = RoomStates;
	msg.iTaxRate = iTaxRate;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_CREATE_GUILD,msg,VipMsg.MSG_GP_CREATE_GUILD);
end

-- -申请加入公会
function VipInfo:sendApplyjoinGuild(GuildID)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_APPLY_JOIN,msg,VipMsg.MSG_GP_QUIT_JOIN);
end

-- -查询公会
function VipInfo:sendGetGuildInfo(GuildID)
	local msg = {}
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_APPLY_JOIN_REQ,msg,VipMsg.MSG_GP_APPLY_JOIN_REQ);
end

-- -获取公会成员列表
function VipInfo:sendGetGuildUserInfo(GuildID)
	local msg = {}
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_GET_GUILD_USER,msg,VipMsg.MSG_GP_GET_GUILD_USER);
end

--通过申请
function VipInfo:sendAgreeGuildJoinInfo(GuildID,AgreeUserID,AgreeType)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
	msg.AgreeUserID = AgreeUserID;
	msg.AgreeType = AgreeType;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_AGREE_JOIN,msg,VipMsg.MSG_GP_AGREE_JOIN);
end

--拒绝申请
function VipInfo:sendRejectGuildJoinInfo(GuildID,RejectUserID,RejectType)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
	msg.RejectUserID = RejectUserID;
	msg.RejectType = RejectType;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_REJECT_JOIN,msg,VipMsg.MSG_GP_REJECT_JOIN);
end

--修改备注
function VipInfo:sendChangeUserNode(GuildID,TargetUserID,NoteName,NotePhone)
	local msg = {}
	msg.GuildID = GuildID;
	msg.TargetUserID = TargetUserID;
	msg.NoteName = NoteName;
	msg.NotePhone = NotePhone;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_CHANGE_USERNOTE,msg,VipMsg.MSG_GP_CHANGE_USERNOTE);
end

--成员退出厅
function VipInfo:sendUserQuitGuild(GuildID)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
	
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_QUIT_JOIN,msg,VipMsg.MSG_GP_QUIT_JOIN);
end

--厅主解散厅
function VipInfo:sendJiesanGuild(GuildID)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
	
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_DELETE_GUILD,msg,VipMsg.MSG_GP_DELETE_GUILD);
end

--厅主踢人
function VipInfo:sendKickGuildUser(GuildID,KickUserID)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
	msg.KickUserID = KickUserID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_KICK_GUILD_USER,msg,VipMsg.MSG_GP_KICK_GUILD_USER);
end

--厅主修改规则
function VipInfo:sendChangeRule(GuildID,GuildName,GameStates,RoomStates,iTaxRate)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
	msg.GuildName = GuildName;
	msg.GameStates = GameStates;
	msg.RoomStates = RoomStates;
	msg.iTaxRate = iTaxRate;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_CHANGE_RULE,msg,VipMsg.MSG_GP_CHANGE_RULE);
end

-- 普通成员界面查询VIP配置
function VipInfo:sendCreateReqMember()
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_CREATE_REQ_MEMBER,msg,VipMsg.MSG_GP_CREATE_GUILD_REQ);
end

-- 置顶
function VipInfo:sendGuildSettop(GuildID)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_GUILD_SETTOP,msg,VipMsg.MSG_GP_GUILD_SETTOP);
end

--税收详情
function VipInfo:sendGuildTaxDetail(GuildID,iDayIndex)
	local msg = {}
	msg.iDayIndex = iDayIndex;
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_GUILD_TAXDETAIL,msg,VipMsg.MSG_GP_GUILD_TAXDETAIL);
end

-- 成员详情
function VipInfo:sendGuildMemberDetail(GuildID,iDayIndex)
	local msg = {}
	msg.iDayIndex = iDayIndex;
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_GUILD_MEMBERDETAIL,msg,VipMsg.MSG_GP_GUILD_MEMBERDETAIL);
end

-- 成员战绩
function VipInfo:sendGuildRecordReq(UserID,GuildID,iDayIndex)
	local msg = {}
	msg.UserID = UserID;
	msg.iDayIndex = iDayIndex;
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_GUILD_RECORD_REQ,msg,VipMsg.MSG_GP_GUILD_RECORDREQ);
end

-- 成员功能（厅详情）
function VipInfo:sendMemberuserList(GuildID)
	local msg = {}
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_MEMBER_USERLIST,msg,VipMsg.MSG_GP_GET_GUILD_USER);
end

-- 一键召集
function VipInfo:sendGuildOneKeyCall(GuildID)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.GuildID = GuildID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_GUILD_ONEKEYCALL,msg,VipMsg.MSG_GP_GUILD_ONEKEYCALL);
end

function VipInfo:sendGuildChangeRuleReq()
	
    PlatformLogic:send(VipMsg.MDM_GP_GUILD, VipMsg.ASS_GP_GUILD_CHANGERULE_REQ);
end

--请求桌子信息 
function VipInfo:sendGuildDeskReq(GuildID)
	local msg = {}
	msg.iGuildId = GuildID;
    RoomLogic:send(RoomMsg.MDM_GR_ROOM,VipMsg.ASS_GR_GUILD_DESKINFO,msg,VipMsg.MSG_GR_C_GuildDeskReq);
end

-------------------------------------股东
--/股东查询
function VipInfo:sendGuildHolderReq(GuildID,UserID)
	local msg = {}
	msg.GuildID = GuildID;
	msg.UserID = UserID;
	luaDump(msg,"msg股东查询")
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_HOLDER_REQ,msg,VipMsg.MSG_GP_GUILD_HOLDER_REQ);
end

--/股东设置 
function VipInfo:sendGuildHolderSet(GuildID,UserID,opType,Rate)
	local msg = {}
	msg.GuildID = GuildID;
	msg.UserID = UserID;
	msg.opType = opType;
	msg.Rate = Rate;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_HOLDER_SET,msg,VipMsg.MSG_GP_GUILD_HOLDER_SET);
end

--//推荐冷却时间查询
function VipInfo:sendGuildCommendTime(GuildID)
	local msg = {}
	msg.GuildID = GuildID;
	msg.UserID = PlatformLogic.loginResult.dwUserID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_TIME,msg,VipMsg.MSG_GP_GUILD_COMMEND_TIME);
end


--推荐查询
function VipInfo:sendGuildCommReq(GuildID,TargetUserID)
	local msg = {}
	msg.GuildID = GuildID;
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.TargetUserID = TargetUserID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_REQ,msg,VipMsg.MSG_GP_GUILD_COMMEND_REQ);
end

--/推荐
function VipInfo:sendGuildCommend(GuildID,TargetUserID)
	local msg = {}
	msg.GuildID = GuildID;
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.TargetUserID = TargetUserID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND,msg,VipMsg.MSG_GP_GUILD_COMMEND);
end

--//同意推荐
function VipInfo:sendGuildCommendAgree(OpType,MailID)--0 同意 1 拒绝
	local msg = {}
	msg.OpType = OpType;
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.MailID = MailID;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_AGREE,msg,VipMsg.MSG_GP_GUILD_COMMEND_AGREE);
end

--//推荐成员详情(厅主)
function VipInfo:sendGuildCommendDetail(GuildID,DayIndex)
	local msg = {}
	msg.GuildID = GuildID;
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.DayIndex = DayIndex;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_DETAIL,msg,VipMsg.MSG_GP_GUILD_COMMEND_DETAIL);
end

--//股东推荐成员详情
function VipInfo:sendGuildCommendDetailHolder(GuildID,DayIndex)
	local msg = {}
	msg.GuildID = GuildID;
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.DayIndex = DayIndex;
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_COMMEND_DETAIL_HOLDER,msg,VipMsg.MSG_GP_GUILD_COMMEND_DETAIL);
end

--//绑定送金查询
function VipInfo:sendGuildSendMoneyReq()
    PlatformLogic:send(VipMsg.MDM_GP_GUILD,VipMsg.ASS_GP_GUILD_SENDMONEY_REQ);
end

return VipInfo;

