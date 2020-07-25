local TableLogic = require("shuihuzhuan.TableLogic");
local TurntableSprite = class("TurntableSprite",function()
    return cc.Sprite:create();
end);

local FRAME_PNG_NAME = {
    [TableLogic.SHZ_TYPE.SHUIHUZHUAN] = "shz_shuihuzhuan",
    [TableLogic.SHZ_TYPE.ZHONGYITANG] = "shz_zhongyitang",
    [TableLogic.SHZ_TYPE.TITIANXINGDAO] = "shz_titianxingdao",
    [TableLogic.SHZ_TYPE.SONG] = "shz_song",
    [TableLogic.SHZ_TYPE.LIN] = "shz_lin",
    [TableLogic.SHZ_TYPE.LU] = "shz_lu",
    [TableLogic.SHZ_TYPE.DAO] = "shz_dao",
    [TableLogic.SHZ_TYPE.QIANG] = "shz_qiang",
    [TableLogic.SHZ_TYPE.FU] = "shz_fu",
};

function TurntableSprite:create(shzType)
    local sprite = TurntableSprite.new();
    sprite:init(shzType);
    return sprite;
end

function TurntableSprite:init(shzType)
    local spriteFrame = cc.SpriteFrameCache:getInstance();
    spriteFrame:addSpriteFrames("shuihuzhuan/image/IconEffect_one.plist");
    spriteFrame:addSpriteFrames("shuihuzhuan/image/IconEffect_two.plist");  

    self._shzType = shzType;

    self:initData();
    self:initUI();
end

function TurntableSprite:initData()
    self._frameAnimate4 = nil;
    self._frameAnimate20 = nil;
    self._bEnable = true;
    self._bNeedShowEffect = false;

    self:updateFrameName();
end

function TurntableSprite:updateFrameName()
    if FRAME_PNG_NAME[self._shzType] then
        local strName = FRAME_PNG_NAME[self._shzType];
        self._strNameNormal = strName..".png";
        self._strNameGray = strName.."_gray.png";
    end
end

function TurntableSprite:initUI()
    self:setSpriteFrame(self._strNameNormal);
end

function TurntableSprite:updateSpriteFrameByType(shzType)
    self._shzType = shzType;
    self._bNeedShowEffect = false;
    self:updateFrameName();

    self:setSpriteEnable(self._bEnable);
end

function TurntableSprite:setSpriteEnable(bEnable)
    self._bEnable = bEnable;

    if bEnable and self._strNameNormal then
        self:setSpriteFrame(self._strNameNormal);
    end

    if not bEnable and self._strNameGray then
        self:setSpriteFrame(self._strNameGray);
    end
end

--播放帧动画
function TurntableSprite:playFrameAnimateBlink()
    self:stopAllFrameAnimate();

    local spriteFrame = cc.SpriteFrameCache:getInstance();
    spriteFrame:addSpriteFrames("shuihuzhuan/image/IconEffect_one.plist");
    spriteFrame:addSpriteFrames("shuihuzhuan/image/IconEffect_two.plist");  

    --帧动画
    local frames = {};
    for i = 0, 3 do
        local imgIndex = self._shzType+1;
        table.insert(frames,"result_"..imgIndex.."_2_"..i..".png");
    end
    local animation= cc.Animation:create()
    for _, strFrame in pairs(frames) do
		local frameName = cc.SpriteFrameCache:getInstance():getSpriteFrame(strFrame);
        if frameName then
    	    animation:addSpriteFrame(frameName)  
        end
    end
    animation:setDelayPerUnit( 0.1 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( true )--设置播放完成后是否回归最初状态  

    local frameAnimate = cc.Animate:create(animation);
    self:runAction(cc.RepeatForever:create( frameAnimate));

    self._bNeedShowEffect = true;
end

function TurntableSprite:playFrameAnimateEffect(bNeedShowEffect)
    self:stopAllFrameAnimate();

    if bNeedShowEffect ~= nil then
        self._bNeedShowEffect = bNeedShowEffect;
    end

    if not self._bNeedShowEffect then
        return false;
    end

    local spriteFrame = cc.SpriteFrameCache:getInstance();
    spriteFrame:addSpriteFrames("shuihuzhuan/image/IconEffect_one.plist");
    spriteFrame:addSpriteFrames("shuihuzhuan/image/IconEffect_two.plist");  

    --帧动画
    local frames = {};
    for i = 0, 18 do
        local imgIndex = self._shzType+1;
        table.insert(frames,"result_"..imgIndex.."_3_"..i..".png");
    end
    local animation= cc.Animation:create()
    for _, strFrame in pairs(frames) do
		local frameName = cc.SpriteFrameCache:getInstance():getSpriteFrame(strFrame);
        if frameName then
    	    animation:addSpriteFrame(frameName)  
        end
    end
    animation:setDelayPerUnit( 0.08 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( true )--设置播放完成后是否回归最初状态  

    local frameAnimate = cc.Animate:create(animation);
    self:runAction(cc.RepeatForever:create( frameAnimate));
    return true;
end

function TurntableSprite:stopAllFrameAnimate()
    self:stopAllActions();

    self:setSpriteEnable(true);
end

return TurntableSprite;
