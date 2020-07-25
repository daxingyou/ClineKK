local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()
local RoomDeal = require("net.room.RoomDeal"):getInstance()

local SignInInfo = {}

function SignInInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function SignInInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function SignInInfo:initData()
	self.cmdList = {
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_OPEN},
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_SIGNIN},
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_RECORD},
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_CLOSE},
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_RECORDToc}
					}

	BindTool.register(self, "SignWeekOpen", {})
	BindTool.register(self, "SignWeekSignIn", {})
	BindTool.register(self, "SignWeekRecord", {})
	BindTool.register(self, "SignWeekClose", {})
	BindTool.register(self, "SignWeekRecordTol", {})

	self.isSignIn = nil;
end


function SignInInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function SignInInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

function SignInInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_GP_ACTIVITIES then
		if subID == PlatformMsg.ASS_GP_SIGNWEEK_OPEN then
			self:onSignWeekOpen(data)
		elseif subID == PlatformMsg.ASS_GP_SIGNWEEK_SIGNIN then
			self:onSignWeekSignIn(data)
		elseif subID == PlatformMsg.ASS_GP_SIGNWEEK_RECORD then
			self:onSignWeekRecord(data)
		elseif subID == PlatformMsg.ASS_GP_SIGNWEEK_CLOSE then
			self:onSignWeekClose(data)
		elseif subID == PlatformMsg.ASS_GP_SIGNWEEK_RECORDToc then
			self:onSignWeekRecordTol(data)
		end
	end
end

function SignInInfo:onSignWeekOpen(data)
	local msg = convertToLua(data,PlatformMsg.SignWeekOpen);
	luaDump(msg,"ASS_GP_SIGNWEEK_OPEN");
	self:setSignWeekOpen(msg);

	--判断是否签过
	if self.isSignIn == nil then
		PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_SIGNWEEK_CLOSE);
	end

	if msg.SignState[msg.DayCount] == 1 then--已签过到
		self.isSignIn = true;
	else
		self.isSignIn = false;
	end

end

function SignInInfo:onSignWeekRecordTol(data)
	local msg = convertToLua(data,PlatformMsg.SignWeekOpen);
	luaDump(msg,"ASS_GP_SIGNWEEK_RECORDToc");
	self:setSignWeekRecordTol(msg);
end

function SignInInfo:onSignWeekSignIn(data)
	local handCode = data:getHead(4);

	if handCode == 0 then
		local msg = convertToLua(data,PlatformMsg.SignWeekSignIn);
		luaDump(msg,"ASS_GP_SIGNWEEK_SIGNIN");
		self:setSignWeekSignIn(msg);
	elseif handCode == 1 then
		addScrollMessage("签到失败");
	elseif handCode == 3 then--需绑定手机
		local layer = GameMessageLayer:create("common/wenxintishi.png","升级账号后可签到领奖励！","login/accountUp1")
        layer:setBtnClickCallBack(
            function()
                local layer = require("layer.popView.RegisterLayer"):create()
                display.getRunningScene():addChild(layer)
            end)
        display.getRunningScene():addChild(layer)
	elseif handCode == 4 then--需充值
		local layer = GameMessageLayer:create("common/wenxintishi.png","充值任意金额，可领取签到奖励！\n周周惊喜领不停！","hall/quchongzhi")
		layer:setBtnClickCallBack(function() showShop() end)
		display.getRunningScene():addChild(layer,9999999)
	end
end

function SignInInfo:onSignWeekRecord(data)
	local msg = convertToLua(data,PlatformMsg.SignRecordElem);
	luaDump(msg,"ASS_GP_SIGNWEEK_RECORD");
	self:setSignWeekRecord(msg);
end

function SignInInfo:onSignWeekClose()
	-- luaDump(msg,"ASS_GP_SIGNWEEK_OPEN");
end



return SignInInfo
