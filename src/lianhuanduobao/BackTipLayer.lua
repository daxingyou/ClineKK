local BackTipLayer = class("BackTipLayer", function()
    return cc.Scene:create();
end)
BackTipLayer.__index = BackTipLayer;

--创建场景
function BackTipLayer:create()
    local layer = BackTipLayer.new();
    layer:InitLayer();

    return layer;
end

function BackTipLayer:ctor()
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
    local uiTable = {
        --最外层元素
        Panel_bg = "Panel_bg",
        btnget = "btnget",
        btngive = "btngive",
        btnBack = "btnBack",

    }

    
    loadNewCsb(self,"lianhuanduobao/tipLayer",uiTable);
end

function BackTipLayer:InitLayer()
    self.Panel_bg:onClick(function(sender)
		self:ClickcloseBtnCallBack(sender);
	end)

    self.btnBack:onClick(function(sender)
		self:ClickcloseBtnCallBack(sender);
	end)

    return BackTipLayer;
end



--关闭按钮的实现
function BackTipLayer:ClickcloseBtnCallBack(sender)
    --移除界面
    self:removeFromParent();       
end

function BackTipLayer:getGiveupbtn()
    return  self.btngive
end

function BackTipLayer:getSavebtn()
    return  self.btnget
end

return BackTipLayer;