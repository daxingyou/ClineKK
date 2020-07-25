local ClientUpdate = class("ClientUpdate")

local _instance = nil

--下载信息
DOWN_PRO_INFO						= 1 									--下载进度
DOWN_COMPELETED						= 3 									--下载结果
DOWN_ERROR_PATH						= 4 									--路径出错
DOWN_ERROR_CREATEFILE				= 5 									--文件创建出错
DOWN_ERROR_CREATEURL				= 6 									--创建连接失败
DOWN_ERROR_NET						= 7 									--下载失败

-- 下载状态  0 未下载 1 正在下载 2 停止下载 3 下载完成 4待下载 5没有更新 6有文件可更新
STATUE_NODOWN 				= 0
STATUE_DOWNING 				= 1
STATUE_STOPDOWN 			= 2
STATUE_DOWNCOMPELTE 		= 3
STATUE_WAITDOWN 			= 4
STATUE_NOUPDATE 			= 5
STATUE_HAVEUPDATE 			= 6
STATUEUNZIP_COMPLETE		= 7										--解压完成
STATUEUNZIP_ERROR			= 8										--解压错误
STATUEUNZIP_UNING			= 9										--解压中

threadCount = 4--线程个数默认4 可改

function ClientUpdate:getInstance()
	if _instance == nil then
		_instance = ClientUpdate.new()
	end

	return _instance
end

function ClientUpdate:destroyInstance()
	if _instance then
		_instance:onExit()
	end

	_instance = nil
end

function ClientUpdate:ctor()
	self:initData()

	self:bindEvent()
end

--创建可读写路径下的目录
--dirPath 创建目录
--isLastCreate 目录包含文件名的话，传false 默认不传
function createDir(dirPath, isLastCreate)
	local dirs = string.split(dirPath,"/")
	local nextDir = cc.FileUtils:getInstance():getWritablePath()
	local len = #dirs

	for k,v in pairs(dirs) do
		if k == 1 then
			nextDir = nextDir..v
		else
			nextDir = nextDir.."/"..v
		end
		-- luaPrint("next 	:"..nextDir)
		if k ~= len then
			createDirectory(nextDir)
		elseif k == len and isLastCreate ~= false then
			createDirectory(nextDir)
		end
	end
end

--初始化更新数据
function ClientUpdate:initData()
	--下载缓存功能
	self.isUseCacheDir = false--下载文件时是否开启缓存目录功能
	self.cacheDir = "temp"--缓存目录

	self.tbServerMD5List = {}

	--下载MD5文件后保存目录 默认值为合集
	self.md5Path = cc.FileUtils:getInstance():getWritablePath().."cache"

	createDir("cache")

	if self.isUseCacheDir == true then
		createDir(self.cacheDir)
	end

	--下载文件列表
	self.tbDownloadFileList = {}
	self.tbDownFileUrl = {}
	self.tbDownDirName = {}

	--记录待下载MD5url
	self.readyDownMD5list = {}
	self.md5Url = GameConfig:getMd5Url()

	self.downLoadList = {}--下载列表
	self.downLoadListCallback = {}--下载回调列表

	self.advanceDownMd5 = 0

	self.fileDownCount = {}
end

function ClientUpdate:setDelegate(delegate,callback)
	self.delegate = delegate
	self.callback = callback
end

function ClientUpdate:bindEvent()
	self.globalBindCustomIds = {}
	self.globalBindCustomIds[#self.globalBindCustomIds + 1] = bindGlobalEvent("removeUpdateNotify",handler(self, self.removeUpdateNotify))
end

function ClientUpdate:onExit()
	for _, bindid in ipairs(self.globalBindCustomIds) do
		unbindEvent(bindid)
	end

	self.globalBindCustomIds = {}
end

--设置下载回调信息
--list {下载游戏名,更新所在node,下载进度回调，下载完成回调}
function ClientUpdate:setDownloadListInfo(list)
	if list then
		if not self:getServerZipVersion(list[1]) then
			return
		end

		local temp = {}
		temp.gameName = list[1]

		if self.downLoadList[temp.gameName] == nil then
			self.downLoadList[temp.gameName] = {}
			temp.finishNum = 0--已下载文件个数
			temp.totalNum = 0--总下载文件个数
			temp.downloadState = STATUE_NODOWN
			temp.isCanDown = false
			self.downLoadList[temp.gameName] = temp
		end

		if list[2] then
			temp = {}
			temp.target = list[2]
			temp.downProgressCallback = list[3]-- or function(finishNum,totalNum) luaPrint("更新下载进度，",finishNum,totalNum,"无回调函数") end
			temp.downFinishCallback = list[4]-- or function() luaPrint("更新下载完成，无回调函数") end
			temp.downNoUpdateCallback = list[5]
			temp.unzipCallback = list[6]
			temp.unzipFinishCallback = list[7]

			if self.downLoadListCallback[list[1]] == nil then
				self.downLoadListCallback[list[1]] = {}
			end

			local ret = false
			for k,v in pairs(self.downLoadListCallback[list[1]]) do
				if v.target == temp.target then
					v = temp
					ret = true
					break
				end
			end

			if not ret then
				table.insert(self.downLoadListCallback[list[1]], temp)
			end
		end
	end
end

--更新下载列表值
function ClientUpdate:updateDownLoadList(gameName,key,value,isDown)
	self:setDownloadListInfo({gameName})

	if self.downLoadList[gameName] then
		self.downLoadList[gameName][key] = value
		if key == "finishNum" then
			for k,v in pairs(self.downLoadListCallback[gameName]) do
				if v.target and not tolua.isnull(v.target) then
					if v.downProgressCallback then
						v.downProgressCallback(value,self.downLoadList[gameName].totalNum)
					end
				end
			end
		elseif key == "unzipPercent" then
			for k,v in pairs(self.downLoadListCallback[gameName]) do
				if v.target and not tolua.isnull(v.target) then
					if v.unzipCallback then
						v.unzipCallback(value)
						break
					end
				end
			end
		end

		if key == "downloadState" and self.downLoadListCallback[gameName] then
			luaPrint("下载状态变化 "..gameName.." value "..value)
			if value == STATUE_DOWNCOMPELTE or (value == STATUEUNZIP_UNING and gameName ~= GameConfig.dbSourceName) then
				local ret = false
				for k,v in pairs(self.downLoadListCallback[gameName]) do
					if v.target and not tolua.isnull(v.target) then
						if v.downFinishCallback then
							v.downFinishCallback()
							ret = true
							break
						end
					end
				end

				if not ret then
					-- addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."下载完成")
				end
			elseif value == STATUEUNZIP_COMPLETE then
				local ret = false
				for k,v in pairs(self.downLoadListCallback[gameName]) do
					if v.target and not tolua.isnull(v.target) then
						if v.unzipFinishCallback then
							v.unzipFinishCallback(value)
						end

						if v.unzipCallback then
							ret = true
						end
					end
				end

				if not ret then
					if Hall:isHaveGame(Hall:getNameIDByGameName(gameName)) then
						addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."下载完成")--.."解压完成")
					end
				end
			elseif value == STATUE_NOUPDATE and isDown == nil then
				for k,v in pairs(self.downLoadListCallback[gameName]) do
					if v.target and not tolua.isnull(v.target) then
						if v.downNoUpdateCallback then
							v.downNoUpdateCallback()
							break
						end
					end
				end
			end
		end
	end
end

--获取下载列表某值
function ClientUpdate:getDownLoadListValue(gameName,key)
	if self.downLoadList[gameName] then
		return self.downLoadList[gameName][key]
	end

	return nil
end

--获取下载信息
function ClientUpdate:getDownLoadInfo(target,gameName)
	local temp = self.downLoadList[gameName]

	if temp then
		luaDump(temp,"temp")
		if self.downLoadListCallback[gameName] then
			local ret = false
			for k,v in pairs(self.downLoadListCallback[gameName]) do
				if v.target == target then
					temp.target = target
					ret = true
					break
				end
			end

			if not ret then
				temp.target = self.downLoadListCallback[gameName][1].target
			end
		end
	end

	return temp
end

--layer关闭时，清除此下载回调信息
function ClientUpdate:removeUpdateNotify(list)
	local list = list._usedata

	if list then
		if list[1] and self.downLoadListCallback[list[1]] then
			for k,v in pairs(self.downLoadListCallback[list[1]]) do
				if v.target == list[2] then
					table.removebyvalue(self.downLoadListCallback[list[1]],v.target,true)
					break
				end
			end
		end
	end
end

function ClientUpdate:getLocalZipVersion(gameName)
	local path = cc.FileUtils:getInstance():getWritablePath().."/cache/zipVersions.txt"
	if cc.FileUtils:getInstance():isFileExist(path) then
		local text = cc.FileUtils:getInstance():getStringFromFile(path)
		luaDump(json.decode(text),"zip")
		local version = json.decode(text).gameListInfo

		for k,v in pairs(version) do
			if v.gameName == gameName then
				return v.luaVer
			end
		end
	end

	return 0
end

function ClientUpdate:getServerZipVersion(gameName)
	if GameConfig.serverZipVersionInfo and GameConfig.serverZipVersionInfo.gameListInfo then
		for k,v in pairs(GameConfig.serverZipVersionInfo.gameListInfo) do
			if v.gameName == gameName then
				return v.luaVer
			end
		end
	end

	return 0
end

--开始下载 isDown 是否立即开始下载 默认不传，即开始
function ClientUpdate:startDownload(gameName,isDown)
	self.gameName = gameName
	local ret = false

	if not self:getServerZipVersion(gameName) then
		if isDown == nil then
			addScrollMessage("此游戏暂未开放")
		end
		return
	end

	if self.downLoadList[gameName] then
		if self.downLoadList[gameName].downloadState == STATUE_NODOWN or 
			self.downLoadList[gameName].downloadState == STATUE_STOPDOWN then
			self.downLoadList[gameName].downloadState = STATUE_WAITDOWN
			self.downLoadList[gameName].finishNum = 0
			self.downLoadList[gameName].totalNum = 0
			ret = true
		elseif self.downLoadList[gameName].downloadState == STATUE_HAVEUPDATE then
			ret = true
		elseif self.downLoadList[gameName].downloadState == STATUE_NOUPDATE then
			ret = true
		end
	end

	if isDown ~= nil then
		ret = true
	end

	if ret then
		local statue = self:getDownLoadListValue(gameName,"downloadState")
		if statue == STATUE_HAVEUPDATE or statue == STATUE_NOUPDATE then
			self:updateDownLoadList(gameName,"isCanDown",true)
			luaPrint("start isCanDown "..tostring(self:getDownLoadListValue(gameName,"isCanDown")))
			self:updateResource(gameName,self:getDownLoadListValue(gameName,"totalNum"),isDown)
		else
			self:checkLuaVersion(gameName,isDown)
		end
	end
end

function ClientUpdate:checkLuaVersion(gameName,isDown)
	local localVer = GameConfig:getLuaVersion(gameName)
	local curVer = self:getServerZipVersion(gameName)

	luaPrint(gameName.." zip resVersion -- "..tostring(localVer).." serverVer "..tostring(curVer))

	if localVer == nil then
		localVer = 0
	end

	if curVer == nil then
		curVer = 0
	end

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if localVer > curVer then--本地资源版本高时，不需要更新
		--self:updateDownLoadList(gameName,"downloadState",STATUE_NOUPDATE,isDown)
		self:updateResource(gameName,0,isDown)
	else
		local temp = {}
		temp.fileUrl = self.md5Url--资源文件下载地址
		temp.md5Url = self.md5Url.."/"..gameName..".txt"--MD5文件下载地址
		temp.newMD5Path = self.md5Path.."/"..gameName..".txt" --下载MD5文件后存储的路径
		temp.localWriteMD5FilePath = writablePath.."cache/oldz"..gameName..".txt"--本地old MD5文件路径
		temp.backMD5Path = self.md5Path.."/b"..gameName..".txt"
		self.readyDownMD5list[gameName] = temp
		self:requestMd5File(gameName,isDown)
	end
end

--下载MD5文件
function ClientUpdate:requestMd5File(gameName,isDown)
	local md5Url = self.readyDownMD5list[gameName].md5Url

	luaPrint("url "..md5Url)
	HttpUtils:requestHttp(md5Url,function(result,response) self:requestMd5Callback(gameName,isDown,result,response) end)
end

--下载MD5回调
function ClientUpdate:requestMd5Callback(gameName,isDown,result,response)
	if result == false or response == nil or response == "" then
		luaPrint("gameName md5 文件 异常，请求失败 "..gameName)
		if runMode == "release" then
			HttpUtils:showError("更新检查异常",true)
		else
			HttpUtils:showError("更新检查异常"..gameName,true)
		end

		self.readyDownMD5list[gameName].fileUrl = GameConfig:getSwitchUrl()
		self.readyDownMD5list[gameName].md5Url = self.readyDownMD5list[gameName].fileUrl.."/"..gameName..".txt"

		self:requestMd5File(gameName,isDown)
	else
		local info = self.readyDownMD5list[gameName]

		local path = info.newMD5Path
		self.readyDownMD5list[gameName].newMD5Content = response
		self:writeFile(path, response)

		luaPrint(path.." md5下载完成")

		if(gameName ~= "child") then
			self:compareFileMd5(gameName,info.newMD5Content,info.newMD5Path,info.localWriteMD5FilePath,info.fileUrl,isDown)
		else
			local writablePath = cc.FileUtils:getInstance():getWritablePath()
			local sMD5 = string.split(response,"\r\n")
			for k,v in pairs(sMD5) do
				local t = string.split(v,"\t")

				local name = string.sub(t[2],2,#t[2]-4)

				local temp = {}
				temp.fileUrl = self.md5Url--资源文件下载地址
				temp.md5Url = self.md5Url.."/"..name..".txt"--MD5文件下载地址
				temp.newMD5Path = self.md5Path.."/"..name..".txt" --下载MD5文件后存储的路径
				temp.localWriteMD5FilePath = writablePath.."cache/oldz"..name..".txt"--本地old MD5文件路径
				temp.backMD5Path = self.md5Path.."/b"..name..".txt"
				self.readyDownMD5list[name] = temp
				self:requestMd5Callback(name,true,true,v)
				for k,v in pairs(GameConfig.serverZipVersionInfo.gameListInfo) do
					if v.gameName == name then
						v.isDownMD5 = true
						break
					end
				end
			end

			self:updateDownLoadList(gameName,"downloadState",STATUE_DOWNCOMPELTE,isDown)
		end
	end
end

--MD5文件比对
--serverMD5 服务器上保存的值
--md5Path 新的MD5文件路径
--lwMd5Path 可读写路径下旧的MD5路径
function ClientUpdate:compareFileMd5(gameName,serverMD5,md5Path,lwMd5Path,fileUrl,isDown)
	--服务器MD5
	if not serverMD5 then
		serverMD5 = cc.FileUtils:getInstance():getStringFromFile(md5Path)
	end

	local tbServerMD5 = {}
	local tbLocalMD5 = {}

	if self.tbServerMD5List[gameName] == nil then
		self.tbServerMD5List[gameName] = {}
	end

	--MD5值比对,不一致的保存到下载列表
	self.tbDownloadFileList[gameName] = {}
	self.tbDownFileUrl[gameName] = {}
	self.tbDownDirName[gameName] = {}

	local sMD5 = string.split(serverMD5,"\r\n")

	for k,v in pairs(sMD5) do
		local t = string.split(v,"\t")
		tbServerMD5[t[2]] = t[1]
		self.tbServerMD5List[gameName][t[2]] = t[1]
	end

	luaDump(self.tbServerMD5List[gameName],"zip self.tbServerMD5List["..gameName.."]")

	--下载前判断，处理下载部分和下载已旧情况
	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	--本地MD5文件读取
	local data =  cc.FileUtils:getInstance():getStringFromFile(lwMd5Path)
	local ret = false

	if not cc.FileUtils:getInstance():isFileExist(lwMd5Path) then
		data =  cc.FileUtils:getInstance():getStringFromFile(writablePath.."cache/old"..gameName..".txt")
		luaPrint("cache/old"..gameName..".txt ","老文件检查 ",data)
	end

	-- cc.FileUtils:getInstance():removeFile(self.md5Path.."/b"..gameName..".txt")

	if data == "" or data == nil then
		data =  cc.FileUtils:getInstance():getStringFromFile(writablePath.."cache/b"..gameName..".txt")
		if data == "" or data == nil then
			luaPrint("本地MD5文件为空 "..tostring(lMd5Path))
			data =  cc.FileUtils:getInstance():getStringFromFile("res".."/"..gameName..".txt")
			if data == "" or data == nil then
				luaPrint("本地resMD5文件为空 "..tostring("res".."/"..gameName..".txt"))
			end
		else
			ret = true
		end
	else
		cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath()..gameName..".zip")
		for i=1,4 do
			local path = cc.FileUtils:getInstance():getWritablePath()..i..gameName..".zip"
			cc.FileUtils:getInstance():removeFile(path)
		end
	end

	if data ~= "" then
		local lMD5 = string.split(data,"\r\n")
		for k,v in pairs(lMD5) do
			local t = string.split(v,"\t")
			tbLocalMD5[t[2]] = t[1]
		end
	end

	local downloadFileCount = 0

	local flag = false

	luaDump(tbLocalMD5,"tbLocalMD5")

	for k,v in pairs(tbServerMD5) do
		if tbLocalMD5[k] ~= v then
			if ret == true then
				cc.FileUtils:getInstance():removeFile(writablePath..k)
			end
			table.insert(self.tbDownloadFileList[gameName],k)
			table.insert(self.tbDownFileUrl[gameName],fileUrl)
			table.insert(self.tbDownDirName[gameName],dirName)
			downloadFileCount = downloadFileCount + 1
			flag = true
		end
	end

	if not flag and ret == true then--续传有用
		for k,v in pairs(tbServerMD5) do
			table.insert(self.tbDownloadFileList[gameName],k)
			table.insert(self.tbDownFileUrl[gameName],fileUrl)
			table.insert(self.tbDownDirName[gameName],dirName)
			downloadFileCount = downloadFileCount + 1
		end
	end

	luaPrint(gameName.." 更新文件个数 为 "..downloadFileCount,"  ",flag," ",ret)
	self.readyDownMD5list[gameName].md5 = serverMD5

	self:updateResource(gameName,downloadFileCount,isDown)
end

function ClientUpdate:updateResource(gameName,count,isDown)
	if count == 0 then
		self:updateDownLoadList(gameName,"downloadState",STATUE_NOUPDATE,isDown)
		-- self.delegate:downloadFinish()
	else
		self:updateDownLoadList(gameName,"totalNum",100)
		if isDown == nil then
			self:updateDownLoadList(gameName,"downloadState",STATUE_DOWNING)
			self:downLoadFile(gameName)
		else
			self:updateDownLoadList(gameName,"downloadState",STATUE_HAVEUPDATE)
		end
	end
end

--下载文件
function ClientUpdate:downLoadFile(gameName)
	local url = self.tbDownFileUrl[gameName][1]..self.tbDownloadFileList[gameName][1]
	-- luaDump(self.tbDownFileUrl,"self.tbDownFileUrl")
	-- luaDump(self.tbDownloadFileList,"self.tbDownloadFileList")
	luaPrint("zip url = ",url)
	-- self.delegate:updateZipProgress({0,0,0,0,0})
	cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath()..gameName..".zip")
	downFileAsync(url,self.tbDownloadFileList[gameName][1],cc.FileUtils:getInstance():getWritablePath(),function(mainID,precent,nowDownloaded,totalToDownload,speed,leftTime) self:downloadCallback(gameName,mainID,precent,nowDownloaded,totalToDownload,speed,leftTime) end,threadCount)
end

function ClientUpdate:downloadCallback(gameName,mainID,precent,nowDownloaded,totalToDownload,speed,leftTime)
	luaPrint("-------------mainID = ",mainID,tonumber(precent))
	self:updateDownLoadList(gameName,"finishNum", tonumber(precent)/100)
	if mainID == DOWN_PRO_INFO then
		if self.readyDownMD5list[gameName].isBack == nil then
			self.readyDownMD5list[gameName].isBack = true
			self:writeFile(self.readyDownMD5list[gameName].backMD5Path, self.readyDownMD5list[gameName].md5)
		end
	elseif mainID == DOWN_COMPELETED then
		for k,v in pairs(self.tbDownloadFileList) do
			if k == gameName then
				-- self:updateDownLoadList(gameName,"downloadState",STATUE_DOWNCOMPELTE)
				cc.FileUtils:getInstance():removeFile(self.md5Path.."/b"..k..".txt")
				self:updateDownLoadList(gameName,"downloadState",STATUEUNZIP_UNING)
				unZipAsync(cc.FileUtils:getInstance():getWritablePath()..k..".zip",cc.FileUtils:getInstance():getWritablePath(),function(mainID,result) self:unzipCallback(gameName,mainID,result) end)
				break
			end
		end
	else
		if gameName == GameConfig.dbSourceName then
			for k,v in pairs(self.tbDownloadFileList) do
				if k == gameName then
					cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath()..gameName..".zip")
					self:downLoadFile(k)
					break
				end
			end
		else
			self:updateDownLoadList(gameName,"downloadState",STATUE_HAVEUPDATE)
			dispatchEvent("downFileFail",gameName)
		end
	end
end

function ClientUpdate:unzipCallback(gameName,mainID,result)
	luaPrint(mainID,"解压结果 result ",result)
	if mainID == 6 then
		if result == 1 then
			self:updateDownLoadList(gameName,"unzipPercent","5_100")
		end
	end

	self:updateDownLoadList(gameName,"unzipPercent",mainID.."_"..result)

	if mainID == 6 then
		cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath()..gameName..".zip")
		for i=1,threadCount do
			local path = cc.FileUtils:getInstance():getWritablePath()..i..gameName..".zip"
			cc.FileUtils:getInstance():removeFile(path)
		end

		if result == 1 then
			for k,v in pairs(self.tbDownloadFileList) do
				if k == gameName then
					cc.FileUtils:getInstance():renameFile(cc.FileUtils:getInstance():getWritablePath().."cache/",k..".txt","oldz"..k..".txt");
					cc.FileUtils:getInstance():purgeCachedEntries();
					break
				end
			end
			self:updateDownLoadList(gameName,"downloadState",STATUEUNZIP_COMPLETE)
		elseif result == 0 then
			self:updateDownLoadList(gameName,"downloadState",STATUE_HAVEUPDATE)
			self:updateDownLoadList(gameName,"finishNum",0)
			if gameName ==  GameConfig.dbSourceName then
				dispatchEvent("downFileFail",gameName)
			end
		end
	end
end

--下载的文件写到本地
function ClientUpdate:writeFile(path,content)
	if content ~= nil and content ~= "" then
		local f, err = io.open(path, 'wb')

		if f then
			f:write(content)

			f:close()
			return true
		else
			return false
		end
	end

	return false
end

--重置某游戏下载
function ClientUpdate:resetDwon(gameName)
	-- self.downLoadList[gameName] = nil
	-- self.downLoadListCallback[gameName] = nil
	-- self.fileDownCount[gameName] = nil
end

return ClientUpdate
