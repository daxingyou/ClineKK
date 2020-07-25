local LeiJiLayer = class("LeiJiLayer", function()
    return cc.Scene:create();
end)
LeiJiLayer.__index = LeiJiLayer;

--创建场景
function LeiJiLayer:create()
    local layer = LeiJiLayer.new();
    --加载场景
    layer:InitLayer();
    return layer;
end
------------------------------------------------------------------

function LeiJiLayer:ctor()
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
    local uiTable = {
        --最外层元素
        Panel_bg = "Panel_bg",
        btnBack = "btnBack",
  

    }

   
    loadNewCsb(self,"lianhuanduobao/leijiRewardLayer",uiTable);
end


--加载场景
function LeiJiLayer:InitLayer()
    self.Panel_bg:onClick(function(sender)
		self:ClickcloseBtnCallBack(sender);
	end)

    self.btnBack:onClick(function(sender)
		self:ClickcloseBtnCallBack(sender);
	end)
   
    return LeiJiLayer;
end



--关闭按钮的实现
function LeiJiLayer:ClickcloseBtnCallBack(sender)
    --移除界面
    self:removeFromParent();       
end

function LeiJiLayer:ClickpageUpBtnCallBack()


end

function LeiJiLayer:ClickpageDownBtnCallBack()

end

return LeiJiLayer;