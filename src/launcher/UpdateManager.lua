local UpdateManager = class("UpdateManager")

local _instance = nil

-- 下载状态  0 未下载 1 正在下载 2 停止下载 3 下载完成 4待下载 5没有更新 6有文件可更新
STATUE_NODOWN = 0
STATUE_DOWNING = 1
STATUE_STOPDOWN = 2
STATUE_DOWNCOMPELTE = 3
STATUE_WAITDOWN = 4
STATUE_NOUPDATE = 5
STATUE_HAVEUPDATE = 6

function UpdateManager:getInstance()
	if _instance == nil then
		_instance = UpdateManager.new()
	end

	return _instance
end

function UpdateManager:ctor()
	self:initData()

	self:bindEvent()
end

--初始化更新数据
function UpdateManager:initData()
	--下载缓存功能
	self.isUseCacheDir = false--下载文件时是否开启缓存目录功能
	self.cacheDir = "temp"--缓存目录

	self.tbServerMD5List = {}

	--下载MD5文件后保存目录 默认值为合集
	self.md5Path = cc.FileUtils:getInstance():getWritablePath().."cache"

	self:createDirectory("cache")

	if self.isUseCacheDir == true then
		self:createDirectory(self.cacheDir)
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

function UpdateManager:bindEvent()
	self.globalBindCustomIds = {}
	self.globalBindCustomIds[#self.globalBindCustomIds + 1] = bindGlobalEvent("removeUpdateNotify",handler(self, self.removeUpdateNotify))
end

--设置下载回调信息
--list {下载游戏名,更新所在node,下载进度回调，下载完成回调}
function UpdateManager:setDownloadListInfo(list)
	if list then
		if not GameConfig:getServerVersion(list[1]) then
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
function UpdateManager:updateDownLoadList(gameName,key,value,isDown)
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
		end

		if key == "downloadState" and self.downLoadListCallback[gameName] then
			luaPrint("下载状态变化 "..gameName.." value "..value)
			if value == STATUE_DOWNCOMPELTE then
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
					addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."下载完成")
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
function UpdateManager:getDownLoadListValue(gameName,key)
	if self.downLoadList[gameName] then
		return self.downLoadList[gameName][key]
	end

	return nil
end

--获取下载信息
function UpdateManager:getDownLoadInfo(target,gameName)
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
function UpdateManager:removeUpdateNotify(list)
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

--开始下载 isDown 是否立即开始下载 默认不传，即开始
function UpdateManager:startDownload(gameName,isDown)
	local ret = false

	if not GameConfig:getServerVersion(gameName) then
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

function UpdateManager:checkLuaVersion(gameName,isDown)
	local localVer = GameConfig:getLuaVersion(gameName)
	local curVer = GameConfig:getServerVersion(gameName)

	luaPrint(gameName.."  resVersion -- "..tostring(localVer).." serverVer "..tostring(curVer))

	if localVer == nil then
		localVer = 0
	end

	if curVer == nil then
		curVer = 0
	end

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if localVer > curVer then--本地资源版本高时，不需要更新
		-- self:updateDownLoadList(gameName,"downloadState",STATUE_NOUPDATE,isDown)
		self:updateResource(gameName,0,isDown)
	else
		local temp = {}
		temp.md5Url = self.md5Url.."/"..gameName.."/"..gameName..".txt"--MD5文件下载地址
		temp.fileUrl = self.md5Url--资源文件下载地址
		temp.newMD5Path = self.md5Path.."/"..gameName..".txt" --下载MD5文件后存储的路径
		temp.newMD5Content = ""--下载的MD5数据 保存起来免得再读文件
		temp.localWriteMD5FilePath = writablePath.."cache/old"..gameName..".txt"--本地old MD5文件路径
		temp.localMD5FilePath = "res/"..gameName..".txt"--安装路径下MD5文件路径
		temp.midPath = ""
		if self.isUseCacheDir == true then
			temp.midPath = self.cacheDir
		end
		self.readyDownMD5list[gameName] = temp
		self:requestMd5File(gameName,isDown)
	end
end

--下载MD5文件
function UpdateManager:requestMd5File(gameName,isDown)
	local md5Url = self.readyDownMD5list[gameName].md5Url

	luaPrint("url "..md5Url)
	HttpUtils:requestHttp(md5Url,function(result,response) self:requestMd5Callback(gameName,isDown,result,response) end)
end

--下载MD5回调
function UpdateManager:requestMd5Callback(gameName,isDown,result,response)
	if result == false or response == nil or response == "" then
		luaPrint("gameName md5 文件 异常，请求失败 "..gameName)
		if runMode == "release" then
			HttpUtils:showError("更新检查异常",true)
		else
			HttpUtils:showError("更新检查异常"..gameName,true)
		end

		self.readyDownMD5list[gameName].fileUrl = GameConfig:getSwitchUrl()
		self.readyDownMD5list[gameName].md5Url = GameConfig:getSwitchUrl().."/"..gameName.."/"..gameName..".txt"

		self:requestMd5File(gameName,isDown)
	else
		local info = self.readyDownMD5list[gameName]

		if self.readyDownMD5list[gameName].newMD5Content ~= "" then
			return
		end

		local path = info.newMD5Path
		self.readyDownMD5list[gameName].newMD5Content = response
		self:writeFile(path, response)

		luaPrint(path.." md5下载完成")

		self:compareFileMd5(gameName,isDown,info.newMD5Content,info.newMD5Path,info.localWriteMD5FilePath,info.localMD5FilePath,info.fileUrl,info.midPath)
	end
end

--MD5文件比对
--serverMD5 服务器上保存的值
--md5Path 新的MD5文件路径
--lwMd5Path 可读写路径下旧的MD5路径
--lMd5Path 安装路径下MD5路径
function UpdateManager:compareFileMd5(gameName,isDown,serverMD5,md5Path,lwMd5Path,lMd5Path,fileUrl,dirName)
	--服务器MD5
	if not serverMD5 then
		serverMD5 = cc.FileUtils:getInstance():getStringFromFile(md5Path)
	end

	local tbServerMD5 = {}
	local tbLocalMD5 = {}

	if self.tbServerMD5List[gameName] == nil then
		self.tbServerMD5List[gameName] = {}
	end

	local sMD5 = string.split(serverMD5,"\r\n")

	for k,v in pairs(sMD5) do
		local t = string.split(v,"\t")
		tbServerMD5[t[2]] = t[1]
		self.tbServerMD5List[gameName][t[2]] = t[1]
	end

	luaDump(self.tbServerMD5List[gameName],"self.tbServerMD5List["..gameName.."]")

	--本地MD5文件读取
	local data =  cc.FileUtils:getInstance():getStringFromFile(lwMd5Path)

	if data == "" or data == nil then
		data =  cc.FileUtils:getInstance():getStringFromFile(cc.FileUtils:getInstance():getWritablePath().."res/"..gameName..".txt")
		if data == "" or data == nil then
			data =  cc.FileUtils:getInstance():getStringFromFile(lMd5Path)
			if data == "" or data == nil then
				luaPrint("本地MD5文件为空 "..tostring(lMd5Path))
			end
		end
	end
	-- luaPrint("self.localWriteMD5FilePath ="..lwMd5Path)
	-- luaPrint("self.localMD5FilePath ="..lMd5Path)

	if data ~= "" then
		local lMD5 = string.split(data,"\r\n")
		for k,v in pairs(lMD5) do
			local t = string.split(v,"\t")
			tbLocalMD5[t[2]] = t[1]
		end
		-- luaDump(self.tbLocalMD5,"self.tbLocalMD5")
	end

	--MD5值比对,不一致的保存到下载列表
	-- if self.tbDownloadFileList[gameName] == nil then
		self.tbDownloadFileList[gameName] = {}
	-- end

	-- if self.tbDownFileUrl[gameName] == nil then
		self.tbDownFileUrl[gameName] = {}
	-- end

	-- if self.tbDownDirName[gameName] == nil then
		self.tbDownDirName[gameName] = {}
	-- end

	local downloadFileCount = 0

	for k,v in pairs(tbServerMD5) do
		if tbLocalMD5[k] ~= v then
			table.insert(self.tbDownloadFileList[gameName],k)
			table.insert(self.tbDownFileUrl[gameName],fileUrl)
			table.insert(self.tbDownDirName[gameName],dirName)
			downloadFileCount = downloadFileCount + 1
		end
	end

	luaPrint(gameName.." 更新文件个数 为 "..downloadFileCount)

	self:updateResource(gameName,downloadFileCount,isDown)
end

--资源下载更新
function UpdateManager:updateResource(gameName,count,isDown)
	if count == 0 then
		self:updateDownLoadList(gameName,"downloadState",STATUE_NOUPDATE,isDown)
	else
		self:updateDownLoadList(gameName,"totalNum",count)
		if isDown == nil then
			self:updateDownLoadList(gameName,"downloadState",STATUE_DOWNING)
			self:downLoadFile(gameName)
		else
			self:updateDownLoadList(gameName,"downloadState",STATUE_HAVEUPDATE)
		end
	end

	if isDown ~= nil and self.advanceStatue ~= true then
		self.advanceDownMd5 = self.advanceDownMd5 + 1
		if self.advanceDownMd5 == #GameConfig.serverVersionInfo.gameListInfo then
			self.advanceStatue = true
		end

		for k,v in pairs(GameConfig.serverVersionInfo.gameListInfo) do
			if v.gameName == gameName then
				v.isDownMD5 = true
				break
			end
		end

		-- if self.advanceDownMd5 ~= #GameConfig.serverVersionInfo.gameListInfo then
		if gameName ~= "hall" then-- and self.advanceDownMd5 ~= #GameConfig.serverVersionInfo.gameListInfo then
			dispatchEvent("startDownload",gameName)
			-- self:startDownload(GameConfig.serverVersionInfo.gameListInfo[self.advanceDownMd5+1].gameName,true)
		else
			-- self.advanceStatue = true
			luaPrint("预下载MD5文件完成")
			if NO_UPDATE ~= true then--网络正常启动大厅下载
				self:startDownload("hall")
			else
				dispatchEvent("restartDownloadSuccess")
			end
		end
	end
end

--下载文件
function UpdateManager:downLoadFile(gameName,isSwitchNet)
	local num = self:getDownLoadListValue(gameName,"finishNum")

	if num == nil then
		dispatchEvent("downloadTerm")
		return
	end

	local index = num + 1

	if num == self:getDownLoadListValue(gameName,"totalNum") then
		luaPrint("下载完成，意外还在下载，停止下载")
		if self.readyDownMD5list[gameName] then
			cc.FileUtils:getInstance():renameFile(string.gsub(self.readyDownMD5list[gameName].newMD5Path,gameName..".txt",""),gameName..".txt","old"..gameName..".txt");
			cc.FileUtils:getInstance():purgeCachedEntries();
		end

		self:updateDownLoadList(gameName,"downloadState",STATUE_DOWNCOMPELTE)
		return
	end

	local path = self.tbDownloadFileList[gameName][index]

	if path == nil then
		if self:getDownLoadListValue(gameName,"totalNum") == self:getDownLoadListValue(gameName,"finishNum") then
			if self.readyDownMD5list[gameName] then
				cc.FileUtils:getInstance():renameFile(string.gsub(self.readyDownMD5list[gameName].newMD5Path,gameName..".txt",""),gameName..".txt","old"..gameName..".txt");
				cc.FileUtils:getInstance():purgeCachedEntries();
			end

			self:updateDownLoadList(gameName,"downloadState",STATUE_DOWNCOMPELTE)
		end

		return
	end

	local url = self.tbDownFileUrl[gameName][index].."/"..gameName..path

	if isSwitchNet == true then-- and runMode == "release" then
		url = GameConfig:getSwitchUrl().."/"..gameName..path
	end

	self:createDirectory(self.tbDownDirName[gameName][index]..path, false)

	HttpUtils:downLoadFile(url,
		cc.FileUtils:getInstance():getWritablePath()..self.tbDownDirName[gameName][index]..path,
		function(result, savePath, response) self:downLoadCallback(gameName, result, savePath, response) end)
end

function UpdateManager:downLoadCallback(gameName, result, savePath, response)
	if self.fileDownCount[gameName] == nil then
		self.fileDownCount[gameName] = {}
	end

	if self.fileDownCount[gameName][savePath] == nil then
		self.fileDownCount[gameName][savePath] = 0
	end

	self.fileDownCount[gameName][savePath] = self.fileDownCount[gameName][savePath] + 1

	local isDown = nil

	if result == false then
		if runMode == "release" then
			HttpUtils:showError("下载文件失败！")
		else
			HttpUtils:showError("下载文件失败 : "..string.gsub(savePath,cc.FileUtils:getInstance():getWritablePath(),""))
		end

		isDown = self:downFileFailRemedy(gameName,savePath)
	else
		if response then--下载成功，写文件失败
			self:createDirectory(savePath,false)--重新创建目录
			local ret = self:writeFile(savePath,response)
			if ret then

			else
				luaPrint("写文件失败  "..savePath)
			end
		end

		if device.platform ~= "windows" then
			--比较下载文件对错
			local md5 = self:checkDownloadFileMD5(savePath)

			local newMd5 = nil
			if self:getDownLoadListValue(gameName,"finishNum") == nil then
				return
			end

			if self.tbDownloadFileList[gameName][self:getDownLoadListValue(gameName,"finishNum") + 1] then
				newMd5 = self.tbServerMD5List[gameName][self.tbDownloadFileList[gameName][self:getDownLoadListValue(gameName,"finishNum") + 1]]
			end

			if newMd5 ~= nil and md5 ~= nil and md5 ~= newMd5 then--下载文件有问题
				luaPrint("md5不一致， 下载文件有问题 md5 ="..tostring(md5))
				luaPrint("newMd5 ="..newMd5," ,gameName ",gameName)
				self:downFileFailRemedy(gameName,savePath,2)--下载失败，无限下载
				return
			end
		end

		isDown = true
	end

	if isDown == true then
		self:updateDownLoadList(gameName,"finishNum", self:getDownLoadListValue(gameName,"finishNum")+1)
		luaPrint(gameName.." 已下载 "..self:getDownLoadListValue(gameName,"finishNum").." 总 "..self:getDownLoadListValue(gameName,"totalNum"))

		if self:getDownLoadListValue(gameName,"finishNum") == self:getDownLoadListValue(gameName,"totalNum") then
			--修改newMD5文件名
			-- for k,v in pairs(self.readyDownMD5list) do
			if self.readyDownMD5list[gameName] then
				cc.FileUtils:getInstance():renameFile(string.gsub(self.readyDownMD5list[gameName].newMD5Path,gameName..".txt",""),gameName..".txt","old"..gameName..".txt");
				cc.FileUtils:getInstance():purgeCachedEntries();
			end
			-- end

			--创建临时目录的，进行移动处理
			if self.isUseCacheDir == true then
				if gameName == "hall" then
					self:moveFileOrDir(cc.FileUtils:getInstance():getWritablePath()..self.cacheDir,cc.FileUtils:getInstance():getWritablePath())			
				else
					self:moveFileOrDir(cc.FileUtils:getInstance():getWritablePath()..self.cacheDir.."/src/"..gameName,cc.FileUtils:getInstance():getWritablePath().."/src/"..gameName)
					self:moveFileOrDir(cc.FileUtils:getInstance():getWritablePath()..self.cacheDir.."/res/"..gameName,cc.FileUtils:getInstance():getWritablePath().."/res/"..gameName)
				end
			end

			self:updateDownLoadList(gameName,"downloadState",STATUE_DOWNCOMPELTE)
		else
			luaPrint("下载下一个 isCanDown "..tostring(self:getDownLoadListValue(gameName,"isCanDown")))
			if self:getDownLoadListValue(gameName,"isCanDown") == true then
				self:downLoadFile(gameName)
			end
		end
	end
end

--单个文件下载完成检验
function UpdateManager:checkDownloadFileMD5(path)
	local file = io.open(path, "rb")
	if file then
		local currrent = file:seek()
		local size = file:seek("end")
		file:seek("set",currrent)
		local testM =file:read(size)
		-- 关闭打开的文件
		file:close()
		local fileMD5 = ToMD5(testM,size)
		return fileMD5
	end
	return nil
end

--创建可读写路径下的目录
--dirPath 创建目录
--isLastCreate 目录包含文件名的话，传false 默认不传
function UpdateManager:createDirectory(dirPath, isLastCreate)
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

--下载的文件写到本地
function UpdateManager:writeFile(path,content)
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

function UpdateManager:moveFileOrDir(source, target, isFile)
	local ret, command
	if device.platform=="windows" then
		source = string.gsub(source, "/", "\\")
		target = string.gsub(target, "/", "\\")
		command = string.format("echo %s|xcopy /e /y %s %s && rd /s/q %s", isFile and "f" or "d", source, target, source)
	else
		command = string.format("cp -r %s %s && rm -rf %s", source, target, source)
	end
	-- log(command)
	ret = os.execute(command)

	-- log(ret)
end

--下载失败补救
function UpdateManager:downFileFailRemedy(gameName,savePath,iType)
	if iType == nil then
		iType = 1
	end

	luaPrint("下载失败补救  "..gameName..","..string.gsub(savePath,cc.FileUtils:getInstance():getWritablePath(),"").." iType "..iType)

	if iType == 1 then--文件失败
		local s = string.gsub(savePath,cc.FileUtils:getInstance():getWritablePath(),"")
		if not fileNameVerify(s) then
			luaPrint("文件名包含中文或非法字符")
			return true
		else
			luaPrint("文件下载异常")
			self:downLoadFile(gameName,runMode == "release")
		end
	elseif iType == 2 then--MD5有问题
		-- if gameName ~= "hall" then
			dispatchEvent("downFileFail",gameName)
		-- else
		-- 	self:downLoadFile(gameName,runMode == "release")
		-- end
	end

	--尝试5次，提示下载失败
	-- if self.fileDownCount[gameName][savePath] == 5 then
	-- 	dispatchEvent("downFileFail",gameName)
	-- else
	-- 	if self.fileDownCount[gameName][savePath] == 2 and runMode == "release" then
	-- 		self:downLoadFile(gameName,true)
	-- 	else
	-- 		self:downLoadFile(gameName)
	-- 	end
	-- end

	return false
end

--重置某游戏下载
function UpdateManager:resetDwon(gameName)
	self.downLoadList[gameName] = nil
	self.downLoadListCallback[gameName] = nil
	self.fileDownCount[gameName] = nil
end

return UpdateManager
