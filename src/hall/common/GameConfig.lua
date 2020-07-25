local GameConfig = {}

--lua版本
GameConfig.luaVer = {
	hall = 220,
	fishing = 220,
	baijiale = 220,
	benchibaoma = 220,
	yaoyiyao = 220,
	fqzs = 220,
	bairenniuniu = 220,
	doudizhu = 220,
	sanzhangpai = 220,
	qiangzhuangniuniu = 220,
	errenniuniu = 220,
	ershiyidian = 220,
	shidianban = 220,
	dezhoupuke = 220,
	hongheidazhan = 220,
	longhudou = 220,
	shisanzhang = 220,
	competition = 220,
	saoleihongbao = 220,
	superfruitgame = 220,
	shuihuzhuan = 220,
	shisanzhanglq = 220,
	sweetparty = 220,
	lianhuanduobao = 220
}

GameConfig.debugIp = ""

GameConfig.appleVersion = "10.0.2"--苹果审核版本

GameConfig.serverVersionInfo = {}--服务器版本信息
GameConfig.serverZipVersionInfo = {}
GameConfig.configInfo = {}

GameConfig.APP_INFO_KEY = "mixproject"

GameConfig.dbSourceName = "wubaiqipai"

gameName = "wubaiqipai"

GameConfig.luaVer[gameName] = 290

GameConfig.chineseGameName = "500棋牌"

GameConfig.A_SERVER_IP = "wbqplogin.310890.com"--默认安卓 正式服
GameConfig.A_SERVER_PORT = 10307
GameConfig.SECRECT_KEY = 20160407

GameConfig.WEB_PORT = ""--":12410"

GameConfig.md5Url = "https://kkwbqpupdatefir-sparekk7.oss-accelerate.aliyuncs.com"--热更地址

GameConfig.webIp = "https://kkwbqpupdatefir-sparekk7.oss-accelerate.aliyuncs.com"

GameConfig.webUrl = GameConfig.webIp..GameConfig.WEB_PORT

GameConfig.firstUrl = "https://kkwbqpupdatefir-sparekk7.oss-accelerate.aliyuncs.com"
GameConfig.spareUrl = "https://kkwbqpupdatefir-sparekk7.oss-accelerate.aliyuncs.com"--备用热更

GameConfig.domain = {"https://kkwbqpupdatefir-sparekk7.oss-accelerate.aliyuncs.com","https://kkwbqpupdatefir-sparekk8.oss-accelerate.aliyuncs.com","https://kkwbqpupdatefir-sparekk9.oss-accelerate.aliyuncs.com"}

GameConfig.payUrl = ""

GameConfig.tuiguanUrl  = "http://tuiguang.gcmu353.com"

GameConfig.firstTuiguan = "kktuiguang.zzbaidali.com"

GameConfig.spareTuiguan = "kktuiguang.zzbaidali.com"

MAX_COUNT = 6

--语音key
GameConfig.GCLOUD_GAME_ID   =   ""
GameConfig.GCLOUD_GAME_KEY  =  ""

GameConfig.WX_APP_ID = "wx7ad02f5b2380fa18"
GameConfig.WX_SECRET = "aff94facb2c8605d58b8f1bd098b4966"

GameConfig.shareToRoom = false--分享是否进入房间

GameConfig.appVerUrl = "https://www.5B.com"--更新地址

GameConfig.BAIDU_KEY = ""--百度key--真正

GameConfig.BAIDU_TKEY = ""--百度key--改签

GameConfig.BAIDU_FKEY = ""--百度key--正式

GameConfig.AliyunUrl = ""

--获得lua版本
function GameConfig:getLuaVersion(gameName)
	return GameConfig.luaVer[gameName]
end

function GameConfig:getServerVersion(gameName)
	local ver = nil

	if GameConfig.serverVersionInfo.gameListInfo then
		for k,v in pairs(GameConfig.serverVersionInfo.gameListInfo) do
			if v.gameName == gameName then
				ver = v.luaVer
				break
			end
		end
	end

	if not ver then
		if gameName == "hall" then
			ver = GameConfig.serverVersionInfo.hallLuaVer
		end
	end

	return ver
end

function GameConfig:getHeadUpLoadUrl()
	-- //头像上传地址
	return "http://"..GameConfig.webUrl.."/Public/XmlHttpUser.aspx?type=AddImg"
end

function GameConfig:getHeadDownloadUrl()
	-- //头像下载地址
	return "http://"..GameConfig.webUrl.."/upload/photo/"
end

--公告地址
function GameConfig:getNoticeUrl()
	return "http://"..GameConfig.webUrl.."/Public/XmlHttpUser.aspx?"
end

function GameConfig:getPlatformViewUrl()
	return "http://"..GameConfig.webUrl.."/Public/SwitchList.ashx?"
end

function GameConfig:getWebServerUrl()
	return GameConfig.webUrl
end

function GameConfig:getAppInfoUrl()
	return "http://"..GameConfig.webUrl.."/Public/AppInfo.ashx?"
end

--验证码
function GameConfig:getVerificationCodeUrl()
	return GameConfig.tuiguanUrl.."/Public/BindUserPhone2.aspx?"
end

--版本配置
function GameConfig:getGameConfigUrl()
	luaPrint("GameConfig:getGameConfigUrl()")
	if runMode == "release" then
		return  GameConfig.md5Url.."/"..gameName.."/"..channelID.."/version.txt"
	else
		if GameConfig.webIp == GameConfig.debugIp then
			return "http://"..GameConfig.md5Url.."/download/"..gameName.."/"..channelID.."/version.txt"
		else
			return GameConfig.md5Url.."/"..gameName.."/"..channelID.."/version.txt"
		end
	end
end

-- MD5文件url
function GameConfig:getMd5Url()
	if runMode == "release" then
		return GameConfig.md5Url.."/"..gameName.."/"..channelID
	else
		if GameConfig.webIp == GameConfig.debugIp then
			return "http://"..GameConfig.md5Url.."/download/"..gameName.."/"..channelID
		else
			return GameConfig.md5Url.."/"..gameName.."/"..channelID
		end
	end
end

--客服
function GameConfig:getServerUrl()
	if isEmptyString(GameConfig.serverUrl) then
		return ""
	else
		return GameConfig.serverUrl
	end
end

--域名切换 根据当前url，相互切
function GameConfig:switchUrl()
	if runMode == "release" then
		if GameConfig.domain then
			local url = GameConfig.domain[1]
			for k,v in pairs(GameConfig.domain) do
				if GameConfig.md5Url == v and k < #GameConfig.domain then
					url = GameConfig.domain[k+1]
					break
				end
			end
			GameConfig.md5Url = url
		else
			if GameConfig.md5Url == GameConfig.firstUrl then
				GameConfig.md5Url = GameConfig.spareUrl
			elseif GameConfig.md5Url == GameConfig.spareUrl then
				GameConfig.md5Url = GameConfig.firstUrl
			end
		end
	end
end

function GameConfig:getSwitchUrl()
	local url = GameConfig.md5Url
	if runMode == "release" then
		if GameConfig.domain then
			url = GameConfig.domain[1]
			for k,v in pairs(GameConfig.domain) do
				if GameConfig.md5Url == v and k < #GameConfig.domain then
					url = GameConfig.domain[k+1]
					break
				end
			end
		else
			if GameConfig.md5Url == GameConfig.firstUrl then
				url = GameConfig.spareUrl
			elseif GameConfig.md5Url == GameConfig.spareUrl then
				url = GameConfig.firstUrl
			end
		end

		GameConfig.md5Url = url
	end

	if GameConfig.webIp == GameConfig.debugIp then
		return url.."/download/"..gameName.."/"..channelID
	else
		return url.."/"..gameName.."/"..channelID
	end
end

function GameConfig:getPayResultUrl()
	return "http://"..GameConfig.tuiguanUrl.."/public/Sendorder.ashx?action=getreturn&userid="
end

function GameConfig:getWebPay()
	return GameConfig.payUrl
end

function GameConfig:getWebNotice()
	return GameConfig.tuiguanUrl.."/public/PublicHandler.ashx?action=getimagenote"
end

--客服链接获取
function GameConfig:getWebKefu()
	return "http://"..GameConfig.tuiguanUrl.."/public/PublicHandler.ashx?action=getcustomserviceconfig"
end

function GameConfig:getSwitchWebUrl()
	if runMode == "release" then
		if GameConfig.tuiguanUrl == GameConfig.firstTuiguan then
			GameConfig.tuiguanUrl = GameConfig.spareTuiguan
		elseif GameConfig.tuiguanUrl == GameConfig.spareTuiguan then
			GameConfig.tuiguanUrl = GameConfig.firstTuiguan
		end
	end
end

function GameConfig:getIPUrl()
	return "http://pv.sohu.com/cityjson?ie=utf-8"
end

return GameConfig