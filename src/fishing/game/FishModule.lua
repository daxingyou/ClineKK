--封装的公共参数

local FishModule = class("FishModule")

local _fishModule = _fishModule or nil;

function FishModule:getInstance()
	if _fishModule == nil then
		_fishModule = FishModule.new();
	end

	return _fishModule;
end

function FishModule:destroyInstance()
	_fishModule = nil
end

function FishModule:ctor()
	self:initData();
end

--初始化相关数据
function FishModule:initData()
	self.m_byGameStation = GameMsg.GS_FREE;--游戏状态

	self.m_gameFishConfig = nil;--鱼配置

	self.m_gameSceneData = nil;--场景数据
end

function FishModule:clearData()
	self:initData();
end

return FishModule;
