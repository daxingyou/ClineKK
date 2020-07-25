local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()

local MailInfo = {}

function MailInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function MailInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function MailInfo:initData()
	self.tempMailList = {}
	self.tempQuestion = {}
	self.cmdList = {
					{PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_GET_MAILLIST},
					{PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_READ_MAIL},
					{PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_DELETE_MAIL},
					{PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_GET_QUESTION},
					{PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_ADD_QUESTION},
					}

	BindTool.register(self, "mailListInfo", {})
	BindTool.register(self, "newMailNotify", 0)
	BindTool.register(self, "mailRead", {})
	BindTool.register(self, "mailDelete", {})
	BindTool.register(self, "questionListInfo", {})
	BindTool.register(self, "addQuestion", {})
	BindTool.register(self, "newQuestionNotify", 0)
end

function MailInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function MailInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function MailInfo:unregisterCmdNotify(mainID,subID)
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

function MailInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_GP_MAIL then
		if subID == PlatformMsg.ASS_GP_GET_MAILLIST then
			self:onReceiveMailList(data)
		elseif subID == PlatformMsg.ASS_GP_READ_MAIL then
			self:onReceiveMailRead(data.data)
		elseif subID == PlatformMsg.ASS_GP_DELETE_MAIL then
			self:onReceiveMailDelete(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_QUESTION then
			self:onReceiveQuestionListInfo(data.data)
		elseif subID == PlatformMsg.ASS_GP_ADD_QUESTION then
			self:onReceiveAddQuestion(data.data)
		end
	end
end

--请求邮件列表
function MailInfo:sendMailListInfoRequest()
	--增加时间戳 判断
	-- --本地邮件时间戳
	-- self.mail_time_stamp_local = 0;
	-- --服务端邮件时间戳
	-- self.mail_time_stamp_sever = 0;
	self.tempMailList = {}
	if globalUnit.mail_time_stamp_local ~= 0 then
		if globalUnit.mail_time_stamp_local == globalUnit.mail_time_stamp_sever then
			self:onReceiveMailList(globalUnit.mail_info,true)
			luaPrint("MailInfo:sendMailListInfoRequest_reload")
			return globalUnit.mail_info;
		end
	end

	luaPrint("MailInfo:sendMailListInfoRequest")
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	PlatformLogic:send(PlatformMsg.MDM_GP_MAIL, PlatformMsg.ASS_GP_GET_MAILLIST, msg, PlatformMsg.MSG_P_GET_MAILLIST)
	return nil
end

--读邮件
function MailInfo:sendMailReadRequest(mailID,rType)
	if rType == nil then
		rType = 0
	end

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.MailID = mailID
	msg.readType = rType

	self.readType = rType

	PlatformLogic:send(PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_READ_MAIL,msg,PlatformMsg.MSG_P_READ_MAIL)
end

function MailInfo:sendMailDeleteRequest(mailID)
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.MailID = mailID
	PlatformLogic:send(PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_DELETE_MAIL,msg,PlatformMsg.MSG_P_DELETE_MAIL)
end

--请求建议
function MailInfo:sendQuestionListRequest()
	self.tempQuestion = {}
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID
	PlatformLogic:send(PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_GET_QUESTION,msg,PlatformMsg.MSG_P_GET_QUESTUONLIST)
end

--提建议
function MailInfo:sendQuestionRequest(question)
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.Question = question
	PlatformLogic:send(PlatformMsg.MDM_GP_MAIL,PlatformMsg.ASS_GP_ADD_QUESTION,msg,PlatformMsg.MSG_P_ADD_QUESTUON)
end

function MailInfo:onReceiveMailList(data,bReload)
	
	if bReload == nil then
		local size1 = data:getHead(1)-20;
		local size2 = getObjSize(PlatformMsg.MSG_GP_S_MAILLIST);
		local num = size1/size2;	
		
		for i=1,num do
			local msg = convertToLua(data,PlatformMsg.MSG_GP_S_MAILLIST)
			table.insert(self.tempMailList,msg);
		end

		local handeCode = data:getHead(4);

		if handeCode == 1 then
			globalUnit.mail_info = clone(self:sortMailList(self.tempMailList));
			globalUnit.mail_time_stamp_local = globalUnit.mail_time_stamp_sever;

			self:setMailListInfo(clone(self:sortMailList(self.tempMailList)))

			local count = 0

			for k,v in pairs(self.tempMailList) do
				if v.IsUse == false then
					count = count + 1
				end
			end
			luaPrint("onReceiveMailList_count ------  "..count)
			self:setNewMailNotify(count)
			self.tempMailList = {}
		else

		end
	else
		self.tempMailList = clone(data);
		self:setMailListInfo(clone(self:sortMailList(self.tempMailList)))

		local count = 0

		for k,v in pairs(self.tempMailList) do
			if v.IsUse == false then
				count = count + 1
			end
		end
		
		self:setNewMailNotify(count)
		self.tempMailList = {}

	end

	
end

--设置已读
function MailInfo:onReceiveMailRead(data)
	luaDump(data,"读邮件")

	--邮件本地时间戳置0
	globalUnit.mail_time_stamp_local = 0;

	self:setMailRead(data)
	
	self.mailListInfo = globalUnit.mail_info;

	if data.ret == 0 then
		if self.readType == 0 then
			for k,v in pairs(self.mailListInfo) do
				if v.MailID == data.MailID then
					v.IsUse = true
					break
				end
			end

			self:setMailListInfo(clone(self:sortMailList(self.mailListInfo)))

			local count = 0

			for k,v in pairs(self.mailListInfo) do
				if v.IsUse == false then
					count = count + 1
				end
			end
			luaPrint("count ------  "..count)
			self:setNewMailNotify(count)
		else
			for k,v in pairs(self.questionListInfo) do
				if v.QuestionID == data.MailID then
					v.IsUse = true
					break
				end
			end

			for k,v in pairs(self.questionListInfo) do
				if v.IsUse == false then
					table.insert(self.questionListInfo,1,v)
					table.remove(self.questionListInfo,k+1)
				end
			end

			self:setQuestionListInfo(self.questionListInfo)
		end
	end
end

function MailInfo:onReceiveMailDelete(data)
	luaDump(data,"删邮件")
	--邮件本地时间戳置0
	luaPrint("-----MailInfo:onReceiveMailDelete-----reset_time_stramp")
	globalUnit.mail_time_stamp_local = 0;

	self.mailListInfo = globalUnit.mail_info;


	self:setMailDelete(data)

	if data.ret == 0 then
		if data.MailID == 0 then
			self.mailListInfo = {}
		else
			for k,v in pairs(self.mailListInfo) do
				if v.MailID == data.MailID then
					table.removebyvalue(self.mailListInfo,v)
					break
				end
			end
		end

		self:setMailListInfo(self.mailListInfo)
		local count = 0

		for k,v in pairs(self.mailListInfo) do
			if v.IsUse == false then
				count = count + 1
			end
		end
		luaPrint("count ------  "..count)
		self:setNewMailNotify(count)
	end
end

function MailInfo:onReceiveQuestionListInfo(data)
	luaDump(data,"建议列表")

	if data[2] == 0 then
		table.insert(self.tempQuestion,data[1])
	else
		self:sortMailList(self.tempQuestion)

		self:setQuestionListInfo(self.tempQuestion)
		local count = 0

		for k,v in pairs(self.tempQuestion) do
			if v.IsUse == 1 then
				count = count + 1
			end
		end
		luaPrint("count ------  "..count)
		self:setNewQuestionNotify(count)
		self.tempQuestion = {}
	end
end

function MailInfo:onReceiveAddQuestion(data)
	luaDump(data,"提建议")

	self:setAddQuestion(data)
end

--邮件排序
function MailInfo:sortMailList(maillist)
	local yiduList = {};
	local weiduList = {};
	local newList = {};
	for k,v in pairs(maillist) do
		if v.IsUse == false or v.IsUse == 1 then
			table.insert(weiduList,v)
		else
			table.insert(yiduList,v)
		end
	end

	table.sort(yiduList,function(a,b) return a.CreateDate > b.CreateDate end)
	table.sort(weiduList,function(a,b) return a.CreateDate > b.CreateDate end)

	for k,v in pairs(weiduList) do
		table.insert(newList,v)
	end

	for k,v in pairs(yiduList) do
		table.insert(newList,v)
	end

	return newList
end

return MailInfo
