local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()

serverConfig = {
	total = 0,
	laBa = 1,
	zhuanYiJiaoSe = 2,
	chuShiKuCun = 3,
	chongZhi = 4,
	tiXian = 5,
	zhuCeSongJinBi = 6,
	daTi = 7,
	houtaiUrl = 8,
	qrUrl = 9,
	yuEBaoShouYi = 10,
	yuEBao = 11,
	jiuJiJinCiShu = 12,
	jiuJiJinLingQu = 13,
	jiuJiJinJiangli = 14,
	qianDao = 16,
	xingYunDuoBao = 19,
	kefuUrl = 20,
	chongzhiUrl = 27,--充值链接
	zhuanZhang = 28,--余额宝转账
	zifubao = 34,  --10000  支付宝提现最低标准  0  0
	yinhangka = 35,  --20000  银行卡提现最低标准  0  0
	tixianbeishu = 36,  --5000  提现满足倍数  0  0
	shuilv = 37,  --2  提现税率  0  0
	huobi = 38,--火币
	zhongbi = 39,--中币
	keyingkele = 40,--可盈可乐
	alipay = 42,--支付宝提现开关
	bank = 43,--银行卡提现开关
	qukuailian = 44,--是否开启区块链
	tuiguanMode = 47,
	diaoqianUrl = 50,
	hotUpdateUrl = 52,
	popWindow = 53,
	dailiZifubao = 55,  --10000  支付宝提现最低标准  0  0
	dailiYinhangka = 56,  --20000  银行卡提现最低标准  0  0
	dailiTixianbeishu = 57,  --5000  提现满足倍数  0  0
	dailiYouxi = 58,
	yinhangkaMax = 73,	--银行卡提现最低标准
	zhifubaoMax = 74	--支付宝提现最低标准
}

local SettlementInfo = {}

function SettlementInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function SettlementInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function SettlementInfo:initData()
	self.cmdList = {
					{PlatformMsg.MDM_CASH, PlatformMsg.ASS_GP_UPDATE_ALIPAY},
					{PlatformMsg.MDM_CASH, PlatformMsg.ASS_GP_GET_CASH},
					{PlatformMsg.MDM_CASH, PlatformMsg.ASS_GP_GET_AGENTWECHAT},
					{PlatformMsg.MDM_CONFIG, PlatformMsg.ASS_GP_GET_CONFIG},
					{PlatformMsg.MDM_CASH, PlatformMsg.ASS_GP_GET_CASH_ACQUIRE},
					{PlatformMsg.MDM_CONFIG, PlatformMsg.ASS_GP_GET_CHARGE_URL},
					}

	BindTool.register(self, "settlementCash", {})
	BindTool.register(self, "bindBank", {})
	BindTool.register(self, "weChat", {})
	BindTool.register(self,"weChatCount",0)
	BindTool.register(self, "configInfo", {})
	BindTool.register(self, "Acquire", {})
	BindTool.register(self, "payConfigInfo",{})
	self.configInfos = {}
	self.payConfig = ""
end

function SettlementInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function SettlementInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function SettlementInfo:unregisterCmdNotify(mainID,subID)
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
end

function SettlementInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_CASH then
		if subID == PlatformMsg.ASS_GP_UPDATE_ALIPAY then
			self:onReceiveBindBank(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_CASH then
			self:onReceiveSettlementCash(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_AGENTWECHAT then
			self:onReceiveweChat(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_CASH_ACQUIRE then
			self:onReceiveAcquire(data);
		end
	elseif mainID == PlatformMsg.MDM_CONFIG then
		if subID == PlatformMsg.ASS_GP_GET_CONFIG then
			self:onReceiveConfigInfo(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_CHARGE_URL then
			self:onReceivePayConfigInfo(data)
		end
	end
end

--提现
function SettlementInfo:sendSettlementCashRequest(sType,sMoney,addr)
	if addr == nil then
		addr = ""
	end

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.bType = sType
	msg.lScore = goldReconvert(sMoney)
	msg.ebetAddr = addr

	luaDump(msg,"提交提现")

	PlatformLogic:send(PlatformMsg.MDM_CASH, PlatformMsg.ASS_GP_GET_CASH, msg, PlatformMsg.MSG_GP_GET_CASH)
end

--绑定
function SettlementInfo:sendBindBankRequest(realName,bankAccount,sType,bankType)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.RealName = realName
	msg.Alipay = bankAccount
	msg.bType = sType
	msg.BankType = bankType
	self.bankInfo = msg

	luaDump(msg,"提交绑定")

	PlatformLogic:send(PlatformMsg.MDM_CASH, PlatformMsg.ASS_GP_UPDATE_ALIPAY, msg, PlatformMsg.MSG_GP_UPDATE_ALIPAY)
end

function SettlementInfo:sendWeChatRequest()
	PlatformLogic:send(PlatformMsg.MDM_CASH, PlatformMsg.ASS_GP_GET_AGENTWECHAT)
end

--提现按钮配置
function SettlementInfo:sendConfigInfoRequest(id)
	local msg = {}
	msg.ID = id
	msg.AgentID = channelID
	PlatformLogic:send(PlatformMsg.MDM_CONFIG, PlatformMsg.ASS_GP_GET_CONFIG, msg, PlatformMsg.MSG_GP_GET_CONFIG)
end

function SettlementInfo:sendPayConfigInfoRequest()
	if self.isSendPay then
		return
	end

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	luaDump(msg,"支付配置请求")

	PlatformLogic:send(PlatformMsg.MDM_CONFIG, PlatformMsg.ASS_GP_GET_CHARGE_URLNEW, msg, PlatformMsg.MSG_P_GET_BANKLOG)
end

function SettlementInfo:onReceiveSettlementCash(data)
	luaDump(data,"提现结果")

	self:setSettlementCash(data)
end

function SettlementInfo:onReceiveBindBank(data)
	luaDump(data,"绑定卡号")

	if data.ret == 0 then
		if self.bankInfo.bType == 2 then
			PlatformLogic.loginResult.BankNo = self.bankInfo.Alipay
		elseif self.bankInfo.bType == 1 then
			PlatformLogic.loginResult.Alipay = self.bankInfo.Alipay
		end
		PlatformLogic.loginResult.szRealName = self.bankInfo.RealName
	end
	data.bType = self.bankInfo.bType
	self:setBindBank(data)
end

function SettlementInfo:onReceiveweChat(data)
	luaDump(data,"微信代理")
	local count = 0
	local temp = {}

	for k,v in pairs(data) do
		if not isEmptyString(v.WeChat) then
			count = count + 1
			table.insert(temp,v)
		end
	end

	self:setWeChatCount(count)
	self:setWeChat(temp)
end

function SettlementInfo:onReceiveConfigInfo(data)
	local temp = data.val
	data.val = tonumber(temp)
	if isEmptyString(data.val) then
		data.val = temp
	end
	luaDump(data,"配置信息")

	self.configInfos[data.id] = data.val

	if data.id == 8 and not isEmptyString(data.val) then--客户端请求后台域名
		if initNet() and isSetTuiguangUrl == nil then
			GameConfig.tuiguanUrl = data.val
			local str = getWebBestIP("kktuiguang")
			local result = string.split(str,":")
			luaPrint("SettlementInfo 1 sdk result ====",str)
			if #result > 1 then
				local ip = result[1]
				local port = tonumber(result[2])

				if checkVersion("1.2.0") == 2 and GameConfig.serverVersionInfo.youXiDun == 1 then
					local qianzhui = string.split(GameConfig.tuiguanUrl,":")[1]
					GameConfig.tuiguanUrl = qianzhui.."://"..ip..":"..port
				elseif checkVersion("1.0.9") == 2 then
					local qianzhui = string.split(GameConfig.tuiguanUrl,":")[1]
					GameConfig.tuiguanUrl = qianzhui.."://"..ip..":"..port
				else
					GameConfig.tuiguanUrl = GameConfig.tuiguanUrl..":"..port
				end
			end
			isSetTuiguangUrl = true
		end
	elseif data.id == 9 and not isEmptyString(data.val) then--二维码推广域名
		globalUnit.tuiguanUrlQr = data.val.."?userid="..(PlatformLogic.loginResult.dwUserID).."&channelCode="..gameName
		createExtendQr()
	elseif data.id == serverConfig.kefuUrl and not isEmptyString(data.val) then
		GameConfig.serverUrl = data.val
	elseif data.id ==  serverConfig.yuEBao then
		globalUnit.isYuEbao = (data.val==1)
	elseif data.id == serverConfig.payUrl and not isEmptyString(data.val) then
	end

	self:setConfigInfo(data)
end

function SettlementInfo:onReceivePayConfigInfo(data)
	self.isSendPay = true
	local handeCode = data:getHead(4);
	local cf = {
		{"c1","CHARSTRING[1000]"},
		{"c2","CHARSTRING[1000]"},
		{"c3","CHARSTRING[1000]"},
		{"c4","CHARSTRING[800]"},
	}
	local size1 = data:getHead(1)-20;
	local size2 = getObjSize(cf);

	local num = size1/size2;

	local msg = convertToLua(data,cf)

	local temp = ""
	temp = temp..msg.c1
	temp = temp..msg.c2
	temp = temp..msg.c3
	temp = temp..msg.c4
	luaPrint("每次的数据 ",temp)

	self.payConfig = self.payConfig..temp

	if handeCode == 1 then
		local temp = json.decode(self.payConfig)
		self.isSendPay = nil
		self.payConfig = ""
		for k,v in pairs(temp.value) do
			v.payType = tonumber(v.payType)
			if v.isInputMoney then
				v.isInputMoney = tonumber(v.isInputMoney)
			end
			if v.minMoney then
				v.minMoney = tonumber(v.minMoney)
			end
			if v.maxMoney then
				v.maxMoney = tonumber(v.maxMoney)
			end

			local val = tonumber(v.discount)
			if val then
				if val == 0 then
					v.discount = ""
				else
					v.discount = val
				end
			end

			if v.payCont then
				for kk,vv in pairs(v.payCont) do
					vv.payType = tonumber(vv.payType)
					if vv.isInputMoney then
						vv.isInputMoney = tonumber(vv.isInputMoney)
					end
					if vv.minMoney then
						vv.minMoney = tonumber(vv.minMoney)
					end
					if vv.maxMoney then
						vv.maxMoney = tonumber(vv.maxMoney)
					end
					local val = tonumber(vv.discount)
					if val then
						if val == 0 then
							vv.discount = ""
						else
							vv.discount = val
						end
					end

					if vv.checkMoney then
						local m = string.split(vv.checkMoney,"|")
						local t = {}
						local flag = false
						if not isEmptyTable(m) then
							for kkk,vvv in pairs(m) do
								local te = string.split(vvv,"_")
								te[1] = tonumber(te[1])
								te[2] = tonumber(te[2])
								table.insert(t,te)
								if te[1] and te[2] then
									flag = true
								end
							end
						end
						vv.checkMoney = clone(t)

						if not flag then
							vv.checkMoney = nil
						end
					end

					if vv.realMoney then
						vv.realMoney = string.split(vv.realMoney,"_")
						local flag = false
						for ka,va in pairs(vv.realMoney) do
							vv.realMoney[ka] = tonumber(va)
							if vv.realMoney[ka] then
								flag = true
							end
						end

						if not flag then
							vv.realMoney = nil
						end
					end
				end
			elseif v.agency then
				for kk,vv in pairs(v.agency) do
					vv.agencyIDType = tonumber(vv.agencyIDType)
					local val = tonumber(vv.discount)
					if val then
						vv.discount = val
					end
				end
			end
		end

		if tonumber(temp.sorttype) == 1 then--从大到小
			table.sort(temp.value,function(a,b) return tonumber(a.sortno) > tonumber(b.sortno) end)
		elseif tonumber(temp.sorttype) == 2 then--从小到大
			table.sort(temp.value,function(a,b) return tonumber(a.sortno) < tonumber(b.sortno) end)
		end

		local temp1 = clone(temp.value)
		temp1.url = temp.url
		luaDump(temp1,"支付配置")
		self:setPayConfigInfo(temp1)
	end
end

function SettlementInfo:getConfigInfoByID(id)
	if self.configInfos[id] == nil then
		self.configInfos[id] = 0
		if id == serverConfig.tixianbeishu then
			self.configInfos[id] = 50
		end
	end

	return self.configInfos[id]
end

function SettlementInfo:onReceiveAcquire(data)
	local ACQUIRE = 
	{
		{"lScore","LLONG"},                             --///用户ID
		{"nTixian","INT"}
	};
	local msg = convertToLua(data,ACQUIRE)
	luaDump(msg,"获取提现需要条件")

	self:setAcquire(msg);
end

--获取提现需要条件
function SettlementInfo:sendAcquire()
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID

	local GET_CASH_ACQUIRE = 
	{
		{"UserID","INT"},                             --///用户ID
	};
	PlatformLogic:send(PlatformMsg.MDM_CASH, PlatformMsg.ASS_GP_GET_CASH_ACQUIRE, msg, GET_CASH_ACQUIRE)
end

--请求游戏的税收
function SettlementInfo:sendGameRat(NameID)
    local msg = {};
    msg.NameID = NameID;
    msg.AgentID = channelID;

    PlatformLogic:send(PlatformMsg.MDM_CONFIG,PlatformMsg.ASS_GP_GET_RAT,msg,PlatformMsg.MSG_GP_GET_RAT);
end

return SettlementInfo
