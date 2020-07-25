-- //声音上传,下载
local LibRoomVoice = class("LibRoomVoice", BaseWindow)
require("platform.GCloudVoice");
require("platform.GCloudVoiceErrno");

--语音相关key
gcloudVoice_key = "gcloudVoiceMode";
gcloudVoice_maikefeng_key = "maikefeng";

function LibRoomVoice:create()
	return LibRoomVoice.new();
end

function LibRoomVoice:ctor()
	self.super.ctor(self, false, false, false, true);

	self:setLayerNodeEvent(true, true);

	self:initData();

	self:initUI();
end

function LibRoomVoice:initData()
	self._Mnotify = nil;
	self.m_uploadCallBack = nil;
	self.m_downloadCallBack = nil;

	self.startTime = 0;
	self.endTime = 0;

	self._dpath = "";
	self._wpath = "";
	self._fileID = "";
	self.curMode =  cc.UserDefault:getInstance():getIntegerForKey(gcloudVoice_key, GCloudVoiceMode.RealTime);--默认实时语音

	luaPrint("gRoomID   ------  "..gRoomID)
	if gRoomID == nil or gRoomID == "" then
		self.roomName = os.time();
	else
		self.roomName = tostring(gRoomID);
	end

	luaPrint("语音房间名称 "..self.roomName);
end

function LibRoomVoice:onEnter()
	luaPrint("LibRoomVoice  onEnter")
	self._Mnotify = MessageNotify:create(self);
	if self._Mnotify ~= nil then
		luaPrint("注册语音监听")
		onUnitedPlatformSetNotify();
	end

	--默认实时语音
	self:setGCloudMode(self.curMode);
end

function LibRoomVoice:onExit()
	luaPrint("LibRoomVoice  onExit")
	if self.curMode == GCloudVoiceMode.RealTime then--实时语音需退出房间
		self:QuitRoom();
		self:closeMic();
		self:closeSpeaker();
	end

	onUnitedPlatformUnpoll();
	if self._Mnotify then
		self._Mnotify:onExit();
	end
end

function LibRoomVoice:initUI()
	self:onEnter();

	if self.curMode == GCloudVoiceMode.Messages then
		local rst =  onUnitedPlatformApplyMessageKey();
	elseif self.curMode == GCloudVoiceMode.RealTime then
		self:JoinTeamRoom();
	end	

	self._dpath = cc.FileUtils:getInstance():getWritablePath();
	self._wpath = cc.FileUtils:getInstance():getWritablePath();
	self._wpath = self._wpath.."/audio.dat";
	self._dpath = self._dpath.."/downlad.dat";

	-- schedule(self, function() self:update(); end, 1/60);
	self:update();
	luaPrint("LibRoomVoice initUI  complete")
end

function LibRoomVoice:update()
	 onUnitedPlatformPoll();
end

function LibRoomVoice:setGCloudMode(mode)
	if self.curMode ~= mode then
		if self.curMode == GCloudVoiceMode.RealTime then--退出房间
			self:QuitRoom();
		elseif self.curMode == GCloudVoiceMode.Messages then

		end
	end
	
	self.curMode = mode;
	
	luaPrint("更改语音模式");
	cc.UserDefault:getInstance():setIntegerForKey(gcloudVoice_key, mode)

	onUnitedPlatformSetMode(mode);

	performWithDelay(self, function()
		if self.curMode == GCloudVoiceMode.Messages then
			local rst =  onUnitedPlatformApplyMessageKey();
			luaPrint("腾讯语音模式切换 为离线语音 mdoe -- "..mode);
		elseif self.curMode == GCloudVoiceMode.RealTime then
			self:JoinTeamRoom();
			luaPrint("腾讯语音模式切换 为实时语音 mdoe -- "..mode);
		end

	 end, 0.5);
end

function LibRoomVoice:setUploadSuccessCallBack(callback)
	self.m_uploadCallBack = callback;
end

-- //下载完成回调
function LibRoomVoice:setDownloadSuccessCallBack(callback)
	self.m_downloadCallBack = callback;
end

function LibRoomVoice:record()
	self.startTime = 0;
	self.endTime = 0;

	for i=1,5 do
		luaPrint("record");
	end

	local rst = GCloudVoiceErrno.GCLOUD_VOICE_SUCC;
	rst = onUnitedPlatformStopRecording();
	if rst ~= GCloudVoiceErrno.GCLOUD_VOICE_SUCC then

	end

	rst = onUnitedPlatformStartRecording(self._wpath);
	if rst ~= GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		luaPrint("StartRecording error:"..rst);
	end

	--记录录音时间
	self.startTime = os.clock();

	return rst;
end

-- //停止录制
function LibRoomVoice:recordOver()
	self.endTime = os.clock();

	for i=1,5 do
		luaPrint("recordOver");
	end

	local rst = GCloudVoiceErrno.GCLOUD_VOICE_SUCC;
	rst =  onUnitedPlatformStopRecording();
	if rst ~=  GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		luaPrint("StopRecording error:"..rst);
	else
		local seconds = self:getVoiceTime();
		if seconds < 1 then
			luaPrint("getVoiceTime   seconds -----  "..seconds);
			-- return rst;
		end

		luaPrint("开始上传录音");
		rst =  onUnitedPlatformUploadRecordedFile(self._wpath);
		if rst ~=  GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
			luaPrint("UploadRecordedFile error:"..rst);
		end
	end
	return rst;
end

function LibRoomVoice:getVoiceTime()
	-- local  bytes =0;
	-- local seconds = 0;
	-- local ret = onUnitedPlatformGetFileParam(self._wpath);
	-- if ret ~= -1 then
	-- 	seconds = string.split(ret,',')[2];
	-- end
	
	-- return tonumber(seconds);
	
	return self.endTime - self.startTime;
end

-- //停止录制，不发送
function LibRoomVoice:stopRecord()
	local rst = GCloudVoiceErrno.GCLOUD_VOICE_SUCC;
	rst =  onUnitedPlatformStopRecording();
	if rst ~=  GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		luaPrint("StopRecording error:"..rst);
	end

	for i=1,5 do
		luaPrint("stopRecord");
	end

	return rst;
end

-- //下载
function LibRoomVoice:download(fileID, bDestion, bTime)
	-- for i=1,5 do
		luaPrint("download:"..fileID.."bTime"..bTime);
		luaPrint("bDestion   "..bDestion)
	-- end

	local rst = GCloudVoiceErrno.GCLOUD_VOICE_SUCC;
	rst =  onUnitedPlatformDownloadRecordedFile(fileID, self._dpath);
	if rst ~=  GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		luaPrint("DownloadRecordedFile error:"..rst);
	else
		-- //下载完成，直接播放
		if self.m_downloadCallBack then
			luaPrint("bDestion  -------------    "..bDestion)
			self.m_downloadCallBack(bDestion, bTime);
		end
	end

	return rst;
end

-- //播放语音
function LibRoomVoice:playVoice()
	for i=1,5 do
		luaPrint("playVoice");
	end

	local rst = GCloudVoiceErrno.GCLOUD_VOICE_SUCC;
	
	rst = onUnitedPlatformPlayRecordedFile(self._dpath);
	
	if rst ~= GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
		luaPrint("PlayRecordedFile Error "..rst);
	end

	return rst;
end

function LibRoomVoice:setUploadFileID(fileID)
	for i=1,5 do
		-- luaPrint("setUploadFileID:"..fileID);
	end

	if nil == fileID then
		return;
	end

	self._fileID = fileID;

	-- //回调给UI
	if self.m_uploadCallBack then
		self.m_uploadCallBack(self._fileID);
	end
end

function LibRoomVoice:JoinTeamRoom()
	onUnitedPlatformJoinTeamRoom(self.roomName);
end

function LibRoomVoice:QuitRoom()
	onUnitedPlatformQuitRoom(self.roomName);
end

function LibRoomVoice:openMic()
	onUnitedPlatformOpenMic();
end

function LibRoomVoice:closeMic()
	onUnitedPlatformCloseMic();
end

function LibRoomVoice:OpenSpeaker()
	onUnitedPlatformOpenSpeaker();
end

function LibRoomVoice:closeSpeaker()
	onUnitedPlatformCloseSpeaker();
end

return LibRoomVoice
