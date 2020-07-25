
local FishManager = class("FishManager")
local _fishManager = nil;

local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();

function FishManager:getInstance()
    if _fishManager == nil then
        _fishManager = FishManager.new();
    end
    return _fishManager;
end

function FishManager:ctor()
	self._fishRingLockArray={};
	for i=1,FishType.FISH_All_TYPEMAX do
    
  	end
  	for i=1,SpecialAttr.SPEC_NONE do
    	table.insert(self._fishRingLockArray,false);
  	end

    BindTool.register(self, "touchEvent", false)
    BindTool.register(self, "gameRotateEvent", false)
end

function FishManager:setGameLayer(gameLayer)
    self.gameLayer = gameLayer;
end

function FishManager:getGameLayer()
    return self.gameLayer;
end

function FishManager:setPokerLayer(pokerLayer)
    self.pokerLayer = pokerLayer;
end

function FishManager:getPokerLayer()
    return self.pokerLayer;
end

function FishManager:createSpecFish(parent, fishType)
    local specArray = {
            FishType.FISH_ZHENZHUBEI,
            FishType.FISH_XIAOFEIYU,
            FishType.FISH_ALILAN,
            FishType.FISH_ZHADANFISH,
            FishType.FISH_NORMAL_TYPEMAX,
            FishType.FISH_WORLDBOSS,
    };

    local index = 1;
    for k,v in pairs(specArray) do
        if v == fishType then
            index = k;
            break;
        end
    end

    if self._fishRingLockArray[index]==false then
        _fish:setSpec(index);
    end

    _fish._speedTime = 18;
    return _fish;
end

function FishManager:createSpecificFish( parent , type , path,isSpec)
    -- luaPrint("FishManager:createSpecificFish fishType = "..type)

  --缓存托管    
  -- local _fish = require("core.Fish").new(type);
  local fish = DataCacheManager:createFish(type,path);
  if fish then
      fish._parent=parent;
      fish.path = path;
      fish:generateFrameAnimation();

      if(path >= 0)then
        fish:generateFishPath(path,nil,nil,isSpec);
      end
  end

  return fish;
end

-- //鱼轨迹消息
-- GameMsg.CMD_S_FishTrace = {
--  {"init_pos","GameMsg.FPoint[5]"},
--  {"init_count", "INT"},
--  {"fish_kind", "INT"},
--  {"fish_id", "INT"},
--  {"trace_type", "INT"},
--  {"pathid", "INT"},
-- };
function FishManager:createServerFish(parent, fishInfo, dt)
    local fish = DataCacheManager:createFish(fishInfo.fish_kind);
    if fish then
        fish._parent=parent;
        fish.path = fishInfo.pathid;
        fish:generateFrameAnimation();

        fish:generateServerFishPath(fishInfo.trace_type, fishInfo.init_pos, dt);
    end

    return fish;
end

function FishManager:createGroupFish( parent , type , path , topFish, groupIndex)
    
  --缓存托管    
  -- local _fish = require("core.Fish").new(type);
  local fish = DataCacheManager:createFish(type,path);
  fish._parent=parent;
  fish.path = path;
  fish:generateFrameAnimation();

  if( path > 0 and topFish ~= nil and groupIndex ~= 0)then
    fish:generateFishPath(path, groupIndex, topFish);
  elseif(path>0)then
    fish:generateFishPath(path);
  end
 
  return fish;
end


function FishManager:getFishFilePrefix( type )
    if(type==FishType.FISH_XIAOGUANGYU)then
        return "xiaoguangyu";
    elseif(type==FishType.FISH_XIAOCAOYU)then
        return "xiaocaoyu";
    elseif(type==FishType.FISH_REDAIYU)then
        return "redaiyu";
    elseif(type==FishType.FISH_DAYANJINYU)then
        return "dayanjinyu";
    elseif(type==FishType.FISH_SHUIMU)then
        return "shuimu";
    elseif(type==FishType.FISH_SHANWEIYU)then
        return "shanweiyu";
    elseif(type==FishType.FISH_REDAIZIYU)then
        return "redaiziyu";
    elseif(type==FishType.FISH_XIAOCHOUYU)then
        return "xiaochouyu";
    elseif(type==FishType.FISH_HETUN)then
        return "hetun";
    elseif(type==FishType.FISH_WUZEI)then
        return "wuzei";
    elseif(type==FishType.FISH_SHITOUYU)then
        return "shitouyu";
    elseif(type==FishType.FISH_SHENXIANYU)then
        return "shenxianyu";
    elseif(type==FishType.FISH_WUGUI)then
        return "wugui";
    elseif(type==FishType.FISH_DENGLONGYU)then
        return "denglongyu";
    elseif(type==FishType.FISH_SHIBANYU)then
        return "shibanyu";
    elseif(type==FishType.FISH_HUDIEYU)then
        return "hudieyu";
    elseif(type==FishType.FISH_LINGDANGYU)then
        return "lingdangyu";
    elseif(type==FishType.FISH_JIANYU)then
        return "jianyu";
    elseif(type==FishType.FISH_MOGUIYU)then
        return "moguiyu";
    elseif(type==FishType.FISH_FEIYU)then
        return "feiyu";
    elseif(type==FishType.FISH_LONGXIA)then
        return "longxia";
    elseif(type==FishType.FISH_ZHADAN)then
        return "haitun";
    elseif(type==FishType.FISH_DAZHADAN)then
        return "dayinsha";
    elseif(type==FishType.FISH_FROZEN)then
        return "lanjing";
    elseif(type==FishType.FISH_ZHENZHUBEI)then
        return "zhenzhubei";
    elseif(type==FishType.FISH_XIAOFEIYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_ALILAN)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_ZHADANFISH)then
        return "zhadan";
    elseif(type==FishType.FISH_XIAOHUANGCI)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_LANGUANGYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_QICAIYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_YINGWULUO)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_TIAOWENYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_GANGKUIYU)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_HAIGUAI)then
        return "xiaofeiyu";
    elseif(type==FishType.FISH_HGZHADAN)then
        return "xiaofeiyu";
    else
        return "xiaoguangyu";
    end  
end

function FishManager:getRefreshFishType()
    local freshRateTotal = 0;
    local _i = 1;
  
    if (true)then--//(GameData::getSharedGameData()->getGameType() == GameType_Normal)
        --//? FISH_NORMAL_TYPEMAX-1
        for i=1,FishType.FISH_NORMAL_TYPEMAX do	
            
            freshRateTotal = freshRateTotal+_freshRateArray[i];
            
            _i=i;
        end
        local t = math.random(0,freshRateTotal);
        for i=1,FishType.FISH_NORMAL_TYPEMAX do		
          
            if(t < _freshRateArray[i])then
            	_i=i;
                break;
            end
            t = t -_freshRateArray[i];  
        
            _i=i;
        end
        if (_i >= FishType.FISH_NORMAL_TYPEMAX)then
            _i = FishType.FISH_NORMAL_TYPEMAX - 1;
        end
        return _i;
    else
        for i=FishType.FISH_XIAOHUANGCI,FishType.FISH_HAIGUAI do		
            freshRateTotal = freshRateTotal + _freshRateArray[i];
            _i=i;
        end
        local t = math.random(0,freshRateTotal);
        for i=FishType.FISH_XIAOHUANGCI,FishType.FISH_HAIGUAI do
            if (t < _freshRateArray[i])then
            	_i=i;
               break;
            end
            t = t -_freshRateArray[i];
            _i=i;
        end
        if (_i >= FishType.FISH_HAIGUAI)then
            _i = FishType.FISH_HAIGUAI - 1;
        end
        return _i;
    end
end

function FishManager:getRefreshFishNum(type)
        if(FishType.FISH_XIAOGUANGYU)then
            return math.random(0,4)+4;
        elseif(FishType.FISH_XIAOCAOYU)then
            return math.random(0,3)+4;
        elseif(FishType.FISH_REDAIYU)then
            return math.random(0,3)+2;
        elseif(FishType.FISH_DAYANJINYU or FishType.FISH_ALILAN)then
            return math.random(0,2)+3;
        elseif(FishType.FISH_SHUIMU or FishType.FISH_SHENXIANYU or FishType.FISH_WUZEI or FishType.FISH_XIAOCHOUYU)then
            return math.random(0,2)+2;
        elseif(FishType.FISH_SHANWEIYU or FishType.FISH_REDAIZIYU or FishType.FISH_HETUN or FishType.FISH_WUGUI or FishType.FISH_DENGLONGYU or FishType.FISH_HUDIEYU or FishType.FISH_LINGDANGYU or FishType.FISH_SHIBANYU)then
            return math.random(0,2)+1;
        elseif(FishType.FISH_SHITOUYU)then
            return math.random(0,3)+1;
        elseif(FishType.FISH_XIAOFEIYU)then
            return 6;
        elseif(FishType.FISH_XIAOHUANGCI)then
            return math.random(0, 2 )+ 6;
        elseif(FishType.FISH_LANGUANGYU)then
            return math.random(0, 1 )+ 5;
        elseif(FishType.FISH_QICAIYU)then
            return math.random(0, 2 )+ 3;
        elseif(FishType.FISH_YINGWULUO or FishType.FISH_TIAOWENYU)then
            return math.random(0, 1 )+ 1;    
        else
            return 1;    
        end    
        -- elseif(FishType.FISH_JIANYU)then
        -- elseif(FishType.FISH_FEIYU)then
        -- elseif(FishType.FISH_LONGXIA)then
        -- elseif(FishType.FISH_ZHADAN)then
        -- elseif(FishType.FISH_DAZHADAN)then
        -- elseif(FishType.FISH_FROZEN)then
        -- elseif(FishType.FISH_ZHENZHUBEI)then
        -- elseif(FishType.FISH_GANGKUIYU)then
        -- elseif(FishType.FISH_HAIGUAI)then
end

return FishManager