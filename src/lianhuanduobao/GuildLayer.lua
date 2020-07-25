
--新手引导界面
local GuideLayer = class("GuideLayer", function()
    return cc.Scene:create();
end)
GuideLayer.__index = GuideLayer;

--创建场景
function GuideLayer:create()
    local layer = GuideLayer.new();
    --加载场景
    layer:InitLayer();

    return layer;
end

function GuideLayer:ctor()
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
    local uiTable = {
        --最外层元素
        Panel_bg = "Panel_bg",
       -- imgdi = "imgdi",
        imgGuanshow = "imgGuanshow",
        pageDownBtn = "Button_PageDown",
        pageUpBtn = "Button_PageUP",
        btnBack = "btnBack",


    }

   
    loadNewCsb(self,"lianhuanduobao/HelpLayer",uiTable);
end

--加载场景
function GuideLayer:InitLayer()
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");

    self.Panel_bg:onClick(function(sender)
		self:ClickcloseBtnCallBack(sender);
	end)

    self.btnBack:onClick(function(sender)
		self:ClickcloseBtnCallBack(sender);
	end)


    if self.pageUpBtn then
       self.pageUpBtn:onClick(handler(self,self.ClickpageUpBtnCallBack))   
    end

     if self.pageDownBtn then
        self.pageDownBtn:onClick(handler(self,self.ClickpageDownBtnCallBack))   
    end


    self.indexPage = 1
    self:updateImgTexture()

    return guideLayer;
end


function GuideLayer:updateImgTexture()
    self.imgGuanshow:loadTexture("lianhuanduobao/lianhuan_bg/lianhuan_shuoming"..self.indexPage .. ".png");
    self.imgGuanshow:ignoreContentAdaptWithSize(true)
    
end


--按钮的触摸
function GuideLayer:BtnTouchCallBack(sender,eventType)
    if eventType == ccui.TouchEventType.began then
        --播放按钮音效
        ButtonSE();
    end
end

--关闭按钮的实现
function GuideLayer:ClickcloseBtnCallBack(sender)
    --移除界面
    self:removeFromParent();       
end

function GuideLayer:ClickpageUpBtnCallBack()
    self.indexPage = self.indexPage -1
    if self.indexPage < 1 then
       self.indexPage =1
    end
    self:updateImgTexture()

end

function GuideLayer:ClickpageDownBtnCallBack()
    self.indexPage = self.indexPage + 1
    if self.indexPage > 5 then
       self.indexPage = 5
    end
    self:updateImgTexture()
end

return GuideLayer;