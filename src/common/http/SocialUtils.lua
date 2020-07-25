local SocialUtils = {}

function SocialUtils:init()
	self._wx_unionid = "";--//用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的。
	self._wx_nickname = "";--//微信昵称
	self._wx_sex = "";
end

return SocialUtils
