function initConfig()
	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	cc.FileUtils:getInstance():addSearchPath("src/",true)
	cc.FileUtils:getInstance():addSearchPath("res/",true)
	cc.FileUtils:getInstance():addSearchPath("res/hall",true)

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath,true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/hall",true)
	end

	NO_UPDATE = true --热更控制

	appleView = 0--苹果审核控制 1 审核打开

	runMode = "release"--运行模式 内测

	if device.platform == "android" then
		GameConfig.A_SERVER_IP = "wbqplogin.310890.com"
	elseif device.platform == "ios" then
		GameConfig.A_SERVER_IP = "wbqplogin.310890.com"
	else
		runMode = "debug"
	end

	if runMode == "debug" then
		GameConfig.A_SERVER_IP = "47.91.166.58"
	end

	initUrl()
end

function initUrl()
	if device.platform == "ios" then
		if runMode == "release" and appleView == 1 then
			NO_UPDATE = true
		else
			NO_UPDATE = false
		end
	else
		if runMode == "debug" then
			if device.platform == "windows" then
				NO_UPDATE = true
			else
				NO_UPDATE = false
			end
		else
			NO_UPDATE = false
		end
	end

	if runMode == "debug" then
		GameConfig.A_SERVER_PORT = 37025
		GameConfig.tuiguanUrl = "http://47.90.8.221:37420"
		GameConfig.md5Url = "47.90.8.221:37430"
		GameConfig.webIp=""
	end
end
