local coinText = class( "coinText", function() return display.newSprite("game/blank.png"); end )
local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();

function coinText:ctor()
    self:initGui()
end

function coinText:setData(score,isme)
	score = score or 0
	self.score = goldConvert(score)
    self.isme = isme;
end

function coinText:resetData()
    self:updateData();
end

function coinText:updateData()
    if self.content and not tolua.isnull(self.content) then
        self.content:setScale(1)
        self.content:setOpacity(255)
        self.content:setPosition(cc.p(0,0))
        self.content:setRotation(0)
    end
end

function coinText:initGui()
   --获得金币数目飞入口袋
    local content = FontConfig.createWithBMFont("0", "common/big_num.fnt");
    content:setScale(0.5)
    self:addChild(content)

    self.content = content
    self.contentScale = content:getScale()
end

function coinText:playAction()
    local flipY = 1;

    if self.isme ~= true then
        if self.content and not tolua.isnull(self.content) then
            self.content:removeFromParent()
        end
        self.content = nil
        local content = FontConfig.createWithCharMap("", "common/zitiao.png", 30, 42, "+")
        content:setScale(1)
        self:addChild(content)
        self.content = content
        self.contentScale = content:getScale()
    else
        if self.content and not tolua.isnull(self.content) then
            self.content:removeFromParent()
        end
        self.content = nil
        local content = FontConfig.createWithBMFont("0", "common/big_num.fnt");
        content:setScale(0.5)
        self:addChild(content)

        self.content = content
        self.contentScale = content:getScale()
    end

	self.content:setString("+"..self.score)

    local sequence = cc.Sequence:create(
    cc.EaseSineOut:create(cc.ScaleTo:create(0.2,self.contentScale + 0.2)),
    cc.EaseSineOut:create(cc.ScaleTo:create(0.1,self.contentScale)),
    cc.Spawn:create(cc.MoveBy:create(0.8,cc.p(0,50*flipY)),
        cc.FadeOut:create(0.6)),
    cc.CallFunc:create(function() self:nodeDead(); end)
    );
    self.content:runAction(sequence)	
end

function coinText:deleteNode()
    self:removeSelf()
end

function coinText:nodeDead()
    --缓存托管
    DataCacheManager:removeEffect(self);
end

return coinText;
