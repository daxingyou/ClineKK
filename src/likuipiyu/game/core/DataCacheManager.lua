
local DataCacheManager = class("DataCacheManager");

local _dataCacheManager = nil;

GAMME_CLICK_EFFECT = 1
GAME_ZHUANLUN_EFFECT = 2
GAME_ZHUANFAN_EFFECT = 3
FISH_CATCH_BIG_EFFECT = 4
FISH_CATCH_SMALL_EFFECT = 5
QUAN_PING_EFFECT = 6
JUBU_EFFECT = 12
BING_DONG_EFFECT = 7
COIN_TEXT = 8
SHUAI_DAI_LE = 9
HUA_FEI_EFFECT = 10
BING_DONG_LAYER = 11

FISH_ARMATION = 1
FISH_ARMATURE = 2

function DataCacheManager:getInstance()
    if _dataCacheManager == nil then
        _dataCacheManager = DataCacheManager.new();
    end
    return _dataCacheManager;
end

function DataCacheManager:ctor()
  --是否开启子弹缓存
  self._bulletIsDataCache = true;
  --是否开启鱼缓存
  self._fishIsDatacache = true;
  --游戏内获取金币缓存
  self._coinIsDatacache = true;
  --特效缓存
  self._effectIsDatacache = true;

  --相同鱼最多缓存个数
  self._identicalFishMaxCount = 15
  self._identicalSmallFishMaxCount = 50

  self._bulletMaxCount = 80;
  --金币最多个数
  self._coinMaxCount = 500

  --特效缓存数量
  self._effectMaxCount = 8;

  --显示缓存信息
  self._showDataCache = false

  self._bulletDataCacheList = {};
  self._fishDataCacheList = {};
  self._coinDataCacheList = {};
  self._effectDataCacheList = {};
  self.fishTextureDataCacheList = {}

  self.frames = {
              -- "likuipiyu/fishing/fish/boss2",
              -- "likuipiyu/fishing/fish/boss",
              -- "likuipiyu/fishing/fish/boss1",
              "likuipiyu/fishing/lkpy_fort",
              -- "likuipiyu/fishing/fish/lkpy_fish_test4",
              "likuipiyu/fishing/fish/lkpy_fish_test3",
              "likuipiyu/fishing/fish/lkpy_fish_test2",
              "likuipiyu/fishing/fish/lkpy_fish_test1",
              "likuipiyu/fishing/game/gamefish_lkpy",
              "likuipiyu/fishing/scene/gold_lkpy",
              "likuipiyu/fishing/scene/lkpy_other_gold"
                  };

  --用户子弹倍数缓存
  self.playersBulletConst = 0
  self.roomIndex = 1

  if(self._showDataCache)then
    -- local sharedScheduler = cc.Director:getInstance():getScheduler()

    -- self._dataCacheManagerScheduler = sharedScheduler:scheduleScriptFunc(function() self:showDataCache() end, 10, false)
  end
end

function DataCacheManager:clearDataCache()
  -- luaPrint("缓存资源被释放了 ////////////")
  for k, bullet in pairs(self._bulletDataCacheList) do
    bullet:release();
  end

  self._bulletDataCacheList = {}

  for k, fishItem in pairs(self._fishDataCacheList) do
      fishItem._fish:release()
      fishItem._fishShadow:release()
  end

  self._fishDataCacheList = {};

  for k,v in pairs(self._coinDataCacheList) do
    v:release();
  end

  self._coinDataCacheList = {};

  for k,v in pairs(self._effectDataCacheList) do
    for kk,effect in pairs(v) do
      effect:release();
    end
  end

  self._effectDataCacheList = {};
end

function DataCacheManager:updateDataCache()
  for k,v in pairs(self.frames) do
    display.loadSpriteFrames(v..".plist",v..".png");
  end
end

function DataCacheManager:createBullet(database,paoOption,paoLevel,memberOrder,bSetLockFishSlow)
  self:updateDataCache();
 --查找缓存数据 
  if(self:bulletIsDatacache())then
    local bullet = self:checkDataCacheBullet(database,paoOption,paoLevel,memberOrder,bSetLockFishSlow);  
    if(bullet)then
      bullet:resetData(database,paoOption,paoLevel,memberOrder,bSetLockFishSlow);
      bullet.isUse = true;
     
      return bullet
    end
  end

  local bullet = require("likuipiyu.game.core.bullet").new(database,paoOption,paoLevel,memberOrder,bSetLockFishSlow);
  bullet.isUse = true;
  bullet:retain();

  return bullet;
end

function DataCacheManager:checkDataCacheBullet(database,paoOption,paoLevel,memberOrder,bSetLockFishSlow)
  local bullet = self._bulletDataCacheList[1];
  if bullet then
    bullet.isUse = true;
    bullet:setVisible(true);
    table.removebyvalue(self._bulletDataCacheList,bullet,false);
    -- luaPrint("DataCacheManager:checkDataCacheFish(fishType) 子弹缓存 .. ");
  end

  return bullet
end

function DataCacheManager:bulletIsDatacache()
  return self._bulletIsDataCache
end

function DataCacheManager:removeBullet(bullet)  
  bullet:removeFromParent()
  if(self:bulletIsDatacache())then
    if globalUnit.isEnterGame == true and #self._bulletDataCacheList < self._bulletMaxCount then
      bullet.isUse = false;
      bullet:setVisible(false);
      table.insert(self._bulletDataCacheList,bullet);
    else
      bullet:release();
    end
  else
    bullet:release();
  end
end

-------------------------------------------------------------------------------------------------------------------

function DataCacheManager:createFish(fishType,path)
  --查找缓存数据 
  if(self:fishIsDatacache())then
    local fish = self:checkDataCacheFish(fishType,path);
    if(fish)then
      fish:resetData(fishType);
      fish.fishShadow:initGui();
      fish.fishShadow:setFlipScreen(false,false);
      FishManager:getGameLayer().fishLayer:addChild(fish.fishShadow,fish._fishType-1);
      fish.fishShadow:release();
      fish:setPosition(cc.p(0,0));
      fish.fishShadow:setPosition(cc.p(0,0));
      fish.isUse = true;
      return fish
    end
  end

  --鱼
  local fish = nil;
  if (fishType == FishType.FISH_ZHENZHUBEI-1 or fishType == FishType.FISH_XIAOFEIYU-1 or fishType == FishType.FISH_ALILAN-1 or fishType == FishType.FISH_ZHADANFISH-1 or fishType == FishType.FISH_NORMAL_TYPEMAX-1 or fishType == FishType.FISH_WORLDBOSS-1) then
    fish = require("likuipiyu.game.core.SpecialFish").new(fishType);
  elseif fishType == FishType.FISH_LONGXIA-1 then
    fish = require("likuipiyu.game.core.BossFish").new(fishType);
  else
    fish = require("likuipiyu.game.core.Fish").new(fishType);
  end

  if fish == nil then
    luaPrint("fish is nil, not find fishType = "..fishType);
    return nil;
  end

  fish.isUse = true;
  fish:retain();

  --鱼阴影
  local fishShadow = fish:createShadow()

  -- if(self:fishIsDatacache())then
  --   --加入缓存列表  
  --   local fishItem = {}
  --   fishItem._fish = fish
  --   fishItem._fishShadow = fishShadow
  --   self._fishDataCacheList[ tostring(fish) ] = fishItem
  -- end

  return fish
end

function DataCacheManager:fishIsDatacache()
  return self._fishIsDatacache
end

function DataCacheManager:checkDataCacheFish(fishType,path)
    local tempFishType = getLocalType(fishType)

    local isSpec = false;
    local fishType = tempFishType;
    local isLine = false;
    
    if fishType == FishType.FISH_ZHENZHUBEI or fishType == FishType.FISH_XIAOFEIYU or fishType == FishType.FISH_ALILAN then
      isSpec = true;
      local rd = self:fakeRandomS(path*tempFishType, 2,198)%80;--math.random(1,1000);
      if rd%2 == 0 then
        isLine = true;
      end
    elseif fishType == FishType.FISH_ZHADANFISH or fishType == FishType.FISH_NORMAL_TYPEMAX or fishType == FishType.FISH_WORLDBOSS then
      isSpec = true;
      local rd = self:fakeRandomS(path*tempFishType, 12,398)%210;
      if rd%2 == 0 then
        isLine = true;
      end
    end

    -- luaPrint("查找缓存鱼 tempFishType =====  "..tempFishType)
    local fish;
    for k, fishItem in pairs(self._fishDataCacheList) do
      -- luaPrint("isuse -------  "..tostring(fishItem._fish.isUse).." type  --  "..fishItem._fish._fishType.." isSpec =  "..tostring(isSpec))
      if((fishItem._fish.isUse == false and fishItem._fish._fishType == tempFishType  and isSpec == false) or
        (fishItem._fish.isUse == false and fishItem._fish._fishType == tempFishType  and isSpec == true and isLine == fishItem._fish.isLine))then
        fishItem._fish:setVisible(true);
        -- fishItem._fishShadow:setVisible(true);
        fishItem._fish.fishShadow = fishItem._fishShadow
        table.removebyvalue(self._fishDataCacheList,fishItem,false);
        -- luaPrint("DataCacheManager:checkDataCacheFish(fishType) 鱼缓存 .. "..tempFishType);
        fish = fishItem._fish;
        break;
      end
    end

    return fish
end

function DataCacheManager:fakeRandomS(random, startNum, endNum)
    return ((random*131497+35729)%(endNum-startNum)) + startNum;
end

function DataCacheManager:updateCacheFishShadow(fish)
  if(self:fishIsDatacache())then
    local fishItem = {}
    fishItem = self._fishDataCacheList[ tostring(fish)];
    fishItem._fishShadow = fish.fishShadow;
    self._fishDataCacheList[ tostring(fish)] = fishItem;
  end
end

function DataCacheManager:removeFish(fish)
  if fish.isUse == false then
    luaPrint("DataCacheManager:removeFish(fish) err")
    return
  end

  fish:removeFromParent();
  if(self:fishIsDatacache())then
    --检测鱼缓存个数
    if(globalUnit.isEnterGame == true and self:cheackIdenticalFishCount(fish._fishType))then
      if fish.fishShadow then
        fish.fishShadow:retain();
        fish.fishShadow:removeFromParent();
        fish:setVisible(false);
        fish.isUse = false;
        local fishItem = {}
        fishItem._fish = fish
        fishItem._fishShadow = fish.fishShadow
        table.insert(self._fishDataCacheList,fishItem);
      else
        fish:release();
      end
    else
      if fish.fishShadow then
        fish.fishShadow:removeFromParent();
      end
      fish:release();
    end
  else
    if fish.fishShadow then
      fish.fishShadow:removeFromParent();
    end
    fish:release();
  end
end

--缓存指定鱼类型个数
function DataCacheManager:cheackIdenticalFishCount(fishType)
  local fishCount = 0
    for k, fishItem in pairs(self._fishDataCacheList) do
        if(fishItem._fish.isUse == false and fishItem._fish._fishType == fishType)then
          fishCount = fishCount+1
        end
    end
  
    if(fishType > 10 and fishCount <= self._identicalFishMaxCount) or (fishType <= 10 and fishCount <= self._identicalSmallFishMaxCount) then
      return true
    else
      return false
    end
end

-------------------------------------------------------------------------------------------------------------------
function DataCacheManager:createFishAnimation(fish ,fishType)
  -- if fishType == 21 then --原李逵  现在没有
  --   return;
  -- end
  self:updateDataCache()
  cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
  --先查找缓存
  if self.fishTextureDataCacheList[ tostring(fishType) ] then
    -- luaPrint("创建缓存鱼 fishType  ================== "..fishType)
    local fishTextureDataCacheItem = self.fishTextureDataCacheList[ tostring(fishType)]

    fish:setContentSize(fishTextureDataCacheItem._fishSize)

    if(fishTextureDataCacheItem._textureType == FISH_ARMATION)then

      local aimateSpeed = fishTextureDataCacheItem._fishTexture:clone()
      fish.aimateSpeed = aimateSpeed

      fish:runAction(aimateSpeed);
    end
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    return
  end

  --动画初始化
  local isFrames = true;
  local frames=nil;
  local fileName = nil;

  local armatureObj = nil
  local activeFrameAnimation = nil

  local tempFishType = fishType;

  --鱼王时特殊处理
  if fishType >= FishType.FISH_FENGHUANG and fishType <= FishType.FISH_KIND_40 then
    tempFishType = fishType - 30;
  elseif fishType == FishType.FISH_ZHENZHUBEI or fishType == FishType.FISH_XIAOFEIYU or fishType == FishType.FISH_ALILAN or fishType == FishType.FISH_ZHADANFISH or fishType == FishType.FISH_NORMAL_TYPEMAX or fishType == FishType.FISH_WORLDBOSS then
    tempFishType = fishType - 20;
  elseif fishType == FishType.FISH_ZHADANFISH or fishType == FishType.FISH_NORMAL_TYPEMAX or fishType == FishType.FISH_WORLDBOSS then
    tempFishType = fishType - 20;
  elseif fishType >= FishType.FISH_HUAFEI1 and fishType <= FishType.FISH_HUAFEI6 then
    tempFishType = fishType - 32;
  elseif fishType == FishType.FISH_HUAFEI7 then
    tempFishType = 20;
  elseif fishType >= FishType.FISH_GIFTEGGS+1 and fishType ~= FishType.FISH_GOLDTORTOISE and fishType ~= FishType.FISH_COLORFULFISH and fishType ~= FishType.FISH_YINLONG then
    -- tempFishType = 22;
    if fishType == FishType.FISH_HUAFEI8 then
      tempFishType = fishType - 3;
    end
  end

  -- if fishType == FishType.FISH_GIFTEGGS then--金蛋
  --   cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
  --   armatureObj = sp.SkeletonAnimation:create("fish/danyou.json", "fish/danyou.atlas");
  --   armatureObj:setAnimation(1,"danyou", true);
  --   armatureObj:setContentSize(cc.size(240,240));
  --   isFrames = false;
  -- elseif fishType == FishType.FISH_ROCKMONEYTREE then--摇钱树
  --   cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
  --   armatureObj = sp.SkeletonAnimation:create("fish/yaoqianchuan.json", "fish/yaoqianchuan.atlas");
  --   armatureObj:setAnimation(1,"yaoqianchuan", true);
  --   armatureObj:setContentSize(cc.size(240,240));
  --   isFrames = false;
  -- elseif fishType == FishType.FISH_REDENVELOPES then--红包鱼
  --   cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
  --   armatureObj = sp.SkeletonAnimation:create("fish/hongbaoyou.json", "fish/hongbaoyou.atlas");
  --   armatureObj:setAnimation(1,"hongbaoyou", true);
  --   armatureObj:setContentSize(cc.size(240,240));
  --   isFrames = false;
  -- elseif fishType == FishType.FISH_CHAOTICBEADS then--混沌珠鱼
  --   cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
  --   armatureObj = sp.SkeletonAnimation:create("fish/heidongyu.json", "fish/heidongyu.atlas");
  --   armatureObj:setAnimation(1,"heidongyu", true);
  --   armatureObj:setContentSize(cc.size(240,240));
  --   isFrames = false;
  -- end

  if(tempFishType <= FishType.FISH_KIND_COUNT and tempFishType >= 0 )then
    fileName = ("lkpy_fish_"..tempFishType.."_%d.png")
  else
    --没有替换的鱼
    fileName = "lkpy_fish_1_%d.png"
    luaPrint("没有此鱼 self._fishType = "..fishType)
  end

  --是否是序列帧加载动画
  if(isFrames == true)then
    frames = display.newFrames(fileName, 1, fish._activeFrameCount);
    activeFrameAnimation = display.newAnimation(frames, fish._activeFrameDelay);
  end

  if(activeFrameAnimation)then
    -- local sprite = display.newSprite()
    fish:setSpriteFrame(frames[1]);
    
    -- fish:setContentSize(sprite:getContentSize());
    -- 自身动画
    local animate= cc.Animate:create(activeFrameAnimation);
    local aimateAction=cc.Repeat:create(animate,999999);
    local aimateSpeed = cc.Speed:create(aimateAction, 1);
    fish.aimateSpeed = aimateSpeed
    fish:runAction(fish.aimateSpeed);

    if self.fishTextureDataCacheList[tostring(fishType)] == nil then
      aimateSpeed:retain()
      --缓存
      local fishTextureDataCacheItem = {}
      fishTextureDataCacheItem._fishTexture = aimateSpeed
      fishTextureDataCacheItem._textureType = FISH_ARMATION
      fishTextureDataCacheItem._fishType = fishType
      fishTextureDataCacheItem._fishSize = fish:getContentSize()
      fishTextureDataCacheItem._fishSpirteFrame = frames[1];

      self.fishTextureDataCacheList[ tostring(fishType) ] = fishTextureDataCacheItem
    end
    
  elseif(armatureObj)then
    fish:setContentSize(armatureObj:getContentSize());
    fish:addChild(armatureObj);
    armatureObj:setPosition(cc.p(fish:getContentSize().width/2,fish:getContentSize().height/2))
    fish.armatureObj = armatureObj

  else
    luaPrint("generateFrameAnimation()   动画获取失败 "..fishType);
  end
  cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
end

-------------------------------------------------------------------------------------------------------------------
function DataCacheManager:createCoin(isLiquan,coinType)
  self:updateDataCache();
  --查找缓存数据 
  if(self:coinIsDatacache())then
    local coin = self:checkDataCacheCoin(isLiquan,coinType);
    if(coin)then
      coin:resetData(isLiquan, coinType)
      coin.isUse = true;
      return coin
    end
  end  

  local coin = require("likuipiyu.game.core.coin").new(isLiquan,coinType);
  coin._coinType = coinType;
  coin.isUse = true;
  coin:retain();

  return coin
end

function DataCacheManager:coinIsDatacache()
  return self._coinIsDatacache
end

function DataCacheManager:checkDataCacheCoin(isLiquan,coinType)
  local coin = self._coinDataCacheList[1];
  if coin and not tolua.isnull(coin) then
    coin.isUse = true;
    coin:setVisible(true);
    table.removebyvalue(self._coinDataCacheList,coin,false);
    luaPrint("DataCacheManager:checkDataCacheFish(fishType) 金币缓存 .. ");
  else
    coin = nil
  end

  return coin
end

function DataCacheManager:removeCoin(coin)
  coin:removeFromParent()
  if(self:coinIsDatacache())then
    if globalUnit.isEnterGame == true and  #self._coinDataCacheList < self._coinMaxCount then    
      coin:setVisible(false);
      table.insert(self._coinDataCacheList, coin);
    else
      coin:release();
    end
  else
    coin:release();
  end
end

function DataCacheManager:checkCoinMaxCount()
  local coinCount = 0
  for k, coin in pairs(self._coinDataCacheList) do
    coinCount = coinCount +1
  end

  if(coinCount >= self._coinMaxCount)then
    return false
  else
    return true
  end
end

--特效缓存
-------------------------------------------------------------------------------------------------------------------

function DataCacheManager:createEffect(effectType,tm)
  --查找缓存数据 
  if(self:effectIsDatacache())then
    local effect = self:checkDataCacheEffect(effectType);
    if(effect)then
      effect.isUse = true;
      effect:resetData(effectType,tm);
      return effect
    end
  end

  --创建特效
  local effect = self:initEffect(effectType,tm)
  if(effect)then
    effect._effectType = effectType;
    effect.isUse = true;
    effect:retain();
  end

  return effect
end

function DataCacheManager:initEffect(effectType,tm)
    local effect = nil
    --点击动画
    if(effectType == GAMME_CLICK_EFFECT)then
      effect = require("likuipiyu.game.core.clickEffect").new();
    --转轮动画
    elseif(effectType == GAME_ZHUANLUN_EFFECT)then
      effect = require("likuipiyu.game.core.zhuanlunEffect").new();
    --赚翻了动画
    elseif(effectType == GAME_ZHUANFAN_EFFECT)then
      effect = require("likuipiyu.game.core.BigFishCoinArmature").new();
    --捕获大鱼粒子特效
    elseif(effectType == FISH_CATCH_BIG_EFFECT)then
      effect = require("likuipiyu.game.core.bigArmature").new();
    --捕获一般粒子特效
    elseif(effectType == FISH_CATCH_SMALL_EFFECT)then
      effect = require("likuipiyu.game.core.smallArmature").new();
    --全屏
    elseif(effectType == QUAN_PING_EFFECT)then
      effect = require("likuipiyu.game.core.quanPingArmature").new(2);
    --局部
    elseif effectType == JUBU_EFFECT then
    effect = require("likuipiyu.game.core.quanPingArmature").new(1);
    --冰冻
    elseif(effectType == BING_DONG_EFFECT)then
      effect = require("likuipiyu.game.core.bingDongArmature").new();
    --获取金币
    elseif(effectType == COIN_TEXT)then
      effect = require("likuipiyu.game.core.coinText").new();
    elseif(effectType == SHUAI_DAI_LE)then
      effect = require("likuipiyu.game.core.ShuaiDaiLeArmature").new();
    elseif(effectType == HUA_FEI_EFFECT)then
      effect = require("likuipiyu.game.core.huaFeiArmature").new();
    elseif effectType == BING_DONG_LAYER then--冰冻层
      effect = require("likuipiyu.game.core.FrozenLayer").new(tm)
    end

    return  effect
end

function DataCacheManager:effectIsDatacache()
  return self._effectIsDatacache
end  

function DataCacheManager:checkDataCacheEffect(effectType)
  if self._effectDataCacheList[effectType] == nil then
    self._effectDataCacheList[effectType] = {};
  end

  local effect = self._effectDataCacheList[effectType][1];
  if effect then
    effect.isUse = true;
    effect:setVisible(true);
    table.removebyvalue(self._effectDataCacheList[effectType],effect,false);
  end

  return effect
end

function DataCacheManager:removeEffect(effect)
  effect:removeFromParent()
  if(self:effectIsDatacache())then
    if self._effectDataCacheList[effect._effectType] == nil then
      self._effectDataCacheList[effect._effectType] = {};
      effect:release();
    end

    if globalUnit.isEnterGame == true and  #self._effectDataCacheList[effect._effectType] < self._effectMaxCount then
      effect.isUse = false 
      effect:setVisible(false);
      table.insert(self._effectDataCacheList[effect._effectType],effect);
    else
      effect:release();
    end
  else
    effect:release();
  end
end

--子弹倍数缓存
-------------------------------------------------------------------------------------------------------------------
function DataCacheManager:setPlayerBulletConst(roomIndex,bulletConst)
  self.playersBulletConst = bulletConst
  self.roomIndex = roomIndex
end

function DataCacheManager:getPlayerBulletConst(roomIndex,minBulletConst,maxBulletConst)
    if(self.roomIndex == roomIndex and self.playersBulletConst and self.playersBulletConst >= minBulletConst  and self.playersBulletConst <= maxBulletConst)then
      return self.playersBulletConst
    else
      self:setPlayerBulletConst(roomIndex,minBulletConst)
    end

    return self.playersBulletConst
end

function DataCacheManager:clearPlayerConstDataCache()
    self.playersBulletConst = nil
end

--缓存信息显示
-------------------------------------------------------------------------------------------------------------------
local numCount ,notUseCount,useCount;
function getDataCacheCount(dataCacheList,tag)
  numCount = 0
  notUseCount = 0
  useCount =0
  tag = tag or nil

  if(tag == nil)then
    for k, value in pairs(dataCacheList) do
      if(value.isUse == false)then
        notUseCount = notUseCount+1
      else
        useCount = useCount + 1
      end
      numCount = numCount + 1
    end
  else

    for k, value in pairs(dataCacheList) do
      if(value._effectType == tag)then
        if(value.isUse == false)then
          notUseCount = notUseCount+1
        else
          useCount = useCount + 1
        end
        numCount = numCount + 1
      end
    end

  end

end

function DataCacheManager:showDataCache()
  
  luaPrint("--------------------------------- DataCacheManager:showDataCache() --------------------------------- begin")

  getDataCacheCount(self._bulletDataCacheList)
  luaPrint("bullet DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);
  getDataCacheCount(self._fishDataCacheList)
  luaPrint("fish DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);
  getDataCacheCount(self._coinDataCacheList)
  luaPrint("coin DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);
  
  getDataCacheCount(self._effectDataCacheList,GAMME_CLICK_EFFECT)
  luaPrint("GAMME_CLICK_EFFECT DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);

  getDataCacheCount(self._effectDataCacheList,GAME_ZHUANLUN_EFFECT)
  luaPrint("GAME_ZHUANLUN_EFFECT DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);

  getDataCacheCount(self._effectDataCacheList,FISH_CATCH_BIG_EFFECT)
  luaPrint("FISH_CATCH_BIG_EFFECT DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);

  getDataCacheCount(self._effectDataCacheList,FISH_CATCH_SMALL_EFFECT)
  luaPrint("FISH_CATCH_SMALL_EFFECT DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);

  getDataCacheCount(self._effectDataCacheList,QUAN_PING_EFFECT)
  luaPrint("QUAN_PING_EFFECT DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);

  getDataCacheCount(self._effectDataCacheList,BING_DONG_EFFECT)
  luaPrint("BING_DONG_EFFECT DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);

  getDataCacheCount(self._effectDataCacheList,COIN_TEXT)
  luaPrint("COIN_TEXT DataCacheList numCount = "..numCount.."   not use count = "..notUseCount.."  use Count = "..useCount);

  -- for k, value in pairs(self._bulletDataCacheList) do
  --   if(value.isUse)then
  --     local x,y = value:getPosition();
  --     if(value.hit == true)then
  --       luaPrint("use bullet pos x = "..x.."    y = "..y.." bullet.hit = true");
  --     else
  --       luaPrint("use bullet pos x = "..x.."    y = "..y.." bullet.hit = false");
  --     end
  --   end

  -- end
  luaPrint("--------------------------------- DataCacheManager:showDataCache() --------------------------------- end")
end

return DataCacheManager