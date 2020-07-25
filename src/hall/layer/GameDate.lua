-- 游戏断线重连

local GameDate = class("GameDate")
local PlatformLogin = require("logic.platformLogic.PlatformLogin");

STATE = {
	STATE_OVER = 0,--//重连结束
	STATE_CONNECTING = 1,--//重连中
	PLATFORM_STATE_CONNECTING = 2,--//平台重连中
}

local _instance = nil;

function GameDate:getInstance()
	if _instance == nil then
		_instance = GameDate.new();
	end

	return _instance;
end

function GameDate:destroyInstance()
	luaPrint("666666666666----**********--")
	globalUnit.m_gameConnectState = STATE.STATE_OVER;
	_instance = nil;
end

function GameDate:ctor()
	self:initData();
end

function GameDate:initData()
	self._gameLogin = PlatformLogin.new();
	luaPrint("77777777777----**********--")
	globalUnit.m_gameConnectState = STATE.STATE_OVER;
end

function GameDate:login()
	globalUnit.m_gameConnectState = STATE.STATE_CONNECTING;
	RoomLogic:close();
	PlatformLogic:close();

	if self._gameLogin then
		self._gameLogin:stop();
		self._gameLogin = nil;
	end

	self._gameLogin = PlatformLogin.new();
	self._gameLogin:start();

	self._gameLogin:requestLogin(globalUnit.m_account, globalUnit.m_password);
end

-- 大厅中重连，执行的登陆
function GameDate:platformLogin()
	globalUnit.m_gameConnectState = STATE.PLATFORM_STATE_CONNECTING;
	RoomLogic:close();
	PlatformLogic:close();

	if self._gameLogin then
		self._gameLogin:stop();
		self._gameLogin = nil;
	end

	self._gameLogin = PlatformLogin.new();
	self._gameLogin:start();

	self._gameLogin:requestLogin(globalUnit.m_account, globalUnit.m_password);
end

function GameDate:loginend()
	globalUnit.m_gameConnectState = STATE.STATE_OVER;
	globalUnit.m_connectCount = 0;
	luaPrint("连接结束 重置网络状态------");

	if self._gameLogin then
		self._gameLogin:stop();
		self._gameLogin = nil;
	end
end

return GameDate
