local MessageNotify = class("MessageNotify")

local _instance = nil;

function MessageNotify:getInstance()
	return _instance;
end

function MessageNotify:create(libRoomVoice)
	return MessageNotify.new(libRoomVoice);
end

function MessageNotify:ctor(libRoomVoice)
	self.libRoomVoice = libRoomVoice;

	_instance = self;
end

function MessageNotify:onExit()
	_instance = nil;
end

function MessageNotify:OnUploadFile(code, filePath, fileID)
	luaPrint("OnUploadFile  code ==   "..code);
	luaPrint("OnUploadFile  filePath  =  "..filePath);
	luaPrint("OnUploadFile  fileID  "..fileID);
	if code ==  GCloudVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE then
		self.libRoomVoice:setUploadFileID(fileID);		
	else
		self.libRoomVoice:setUploadFileID();
	end
end

function MessageNotify:OnDownloadFile(code, filePath, fileID)
	if code ==  GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
		-- //下载完成就播放语音
		self.libRoomVoice:playVoice();
	else
		luaPrint("语音正在下载中");
	end
end

function MessageNotify:OnPlayRecordedFile(code, filePath)
	-- //播放语音
	if code ==  GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then

	else

	end
end

function MessageNotify:OnApplyMessageKey(code)
	local msg;
	luaPrint("OnApplyMessageKey code "..code);
	if code == GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SUCC then
		msg = "OnApplyMessageKey success";
		-- self.libRoomVoice:JoinTeamRoom();
	else
		msg = "OnApplyMessageKey error "..code;
		-- // 重新ApplyMessageKey
		local mode = cc.UserDefault:getInstance():getIntegerForKey("gcloudVoice_key", GCloudVoiceMode.RealTime);
		if mode == GCloudVoiceMode.Messages then
			onUnitedPlatformApplyMessageKey();
		end
		
		luaPrint("OnApplyMessageKey faild  code "..code.."    retry  apply !!");
	end
end

function MessageNotify:OnJoinRoom(code, roomName, memberID)
	if code == GCloudVoiceCompleteCode.GV_ON_JOINROOM_SUCC then
		luaPrint("加入语音房间成功");
		self.libRoomVoice:openMic();
		self.libRoomVoice:OpenSpeaker();
	elseif code == GCloudVoiceCompleteCode.GV_ON_JOINROOM_TIMEOUT then
		luaPrint("加入语音房间超时");
	else
		luaPrint("加入语音房间失败");
	end
end

function MessageNotify:OnQuitRoom(code, roomName)
	if code == GCloudVoiceCompleteCode.GV_ON_JOINROOM_SUCC then
		luaPrint("退出语音房间成功");
		self.libRoomVoice:closeMic();
		self.libRoomVoice:closeSpeaker();
	elseif code == GCloudVoiceCompleteCode.GV_ON_JOINROOM_TIMEOUT then
		luaPrint("退出语音房间超时");
	else
		luaPrint("退出语音房间失败");
	end
end

function MessageNotify:OnMemberVoice(members, count)

end

function MessageNotify:OnSpeechToText(code, fileID, result)

end

return MessageNotify
