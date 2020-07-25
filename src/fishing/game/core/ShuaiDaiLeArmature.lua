local ShuaiDaiLeArmature = class( "ShuaiDaiLeArmature", function() return display.newSprite("gaem/blank.png"); end )
local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();

--帅呆了动画
function ShuaiDaiLeArmature:ctor()
    self.score = 0
    self:initGui()
end

function ShuaiDaiLeArmature:setData(score)
    score = score or 0
    self.score = goldConvert(score)
end

function ShuaiDaiLeArmature:resetData()
    self.score = 0;
    self:setScale(1);

    local paths = {};
    table.insert(paths,cc.DelayTime:create(0.3));
    table.insert(paths, cc.CallFunc:create(function() self:palyArmature(); end));
    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function ShuaiDaiLeArmature:updateData()
    self:setScale(1)
end

function ShuaiDaiLeArmature:addLinePathTo(endPos,filp)
	self.endPos = endPos; 
	self.filp = filp;
end

function ShuaiDaiLeArmature:initGui()
    self.armatureObj = createArmature("fishEffect/eff_shuaidaile0.png","fishEffect/eff_shuaidaile0.plist","fishEffect/eff_shuaidaile.ExportJson");
    self:addChild(self.armatureObj);

    --加个label
    local content = cc.ui.UILabel.new({UILabelType = 1,
                                         text  = FormatNumToString(self.score),
                                         font  = "common/big_num.fnt"})
    content:setAnchorPoint(cc.p(0.5,0.5));   
    content:setPosition(cc.p(0, 50))
    self:addChild(content)
    self.scoreLabel = content

    --延时播放动画
    local paths = {};
    table.insert(paths,cc.DelayTime:create(0.3));
    table.insert(paths, cc.CallFunc:create(function() self:palyArmature(); end));
    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function ShuaiDaiLeArmature:playAction()
    self.scoreLabel:setVisible(false)
    self:runAction(self.sequenceAction);
    self.sequenceAction:release()
end

function ShuaiDaiLeArmature:palyArmature()
    self.scoreLabel:setString("+"..FormatNumToString(self.score))
    self.armatureObj:getAnimation():playWithIndex(0); 

	local paths = {};

	table.insert(paths,cc.DelayTime:create(0.8));
    table.insert(paths, cc.CallFunc:create(function()  self.scoreLabel:setVisible(true) end));
    table.insert(paths,cc.DelayTime:create(1));
    local moveTo = cc.EaseExponentialIn:create(cc.MoveTo:create(1,  self.endPos));
    local saleTo = cc.EaseExponentialIn:create(cc.ScaleTo:create(1,0));
	local SpawnAction = cc.Spawn:create(moveTo,saleTo);
    table.insert(paths, SpawnAction);
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead();end));

    self:runAction(cc.Sequence:create(paths));
end

function ShuaiDaiLeArmature:nodeDead()
    --缓存托管
    DataCacheManager:removeEffect(self);
end

function ShuaiDaiLeArmature:deleteNode()
    self.sequenceAction:release()
    self:removeSelf()
end

return ShuaiDaiLeArmature;
