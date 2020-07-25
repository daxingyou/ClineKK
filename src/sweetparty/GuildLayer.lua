
--新手引导界面
local GuideLayer = class("CaiJinLayer",PopLayer)
GuideLayer._index = GuideLayer;
--创建场景
function GuideLayer:create()
    local layer = GuideLayer.new();
    --加载场景
    layer:InitLayer();
--    layer:addChild(layer._rootLayer);

    return layer;
end

function GuideLayer:ctor()
    display.loadSpriteFrames("sweetparty/GameScene.plist", "sweetparty/GameScene.png");
    local uiTable = {
        --最外层元素
		Image_bg = "Image_bg",

        Button_close = "Button_close",
    }

    
    loadNewCsb(self,"sweetparty/HelpLayer",uiTable);
end
------------------------------------------------------------------
--加载场景
function GuideLayer:InitLayer()
    self._index = 1;
--    local guideLayer = cc.CSLoader:createNode("HelpLayer.csb");
    self.Image_gulid = {}
	local pageView = self.Image_bg:getChildByName("PageView");
    self.PageView = pageView;
--    local ScrollView = self.Image_bg:getChildByName("ScrollView");
--    self.ScrollView = ScrollView;

	for i=1,4 do
		local image = ccui.ImageView:create(string.format("GuideLayer/guide_%d.png",i));
        image:setVisible(false);
        self.Image_gulid[i] = image;	
        self.Image_gulid[1]:setVisible(true);
		image:setPosition(510,215);
		--最后一页添加开始游戏按钮
		pageView:addChild(image);
    end

    local size = self.Image_bg:getContentSize();

    self.ScrollView_list = ccui.ListView:create();
    self.ScrollView_list:setAnchorPoint(cc.p(0.5,0.5));
    self.ScrollView_list:setDirection(ccui.ScrollViewDir.vertical);
    self.ScrollView_list:setBounceEnabled(true);
    self.ScrollView_list:setContentSize(cc.size(939, 420));
    self.ScrollView_list:setPosition(cc.p(size.width*0.5,size.height*0.42));
    self.Image_bg:addChild(self.ScrollView_list);

    self.ScrollView_list:setVisible(false);
   
    local layout = ccui.Layout:create();
    layout:setContentSize(cc.size(939, 680));

    local guize = ccui.ImageView:create("sweetparty/gamescene_bg/sweetparty_youxiwanfa.png");
    guize:setPosition(470,350);
         
    layout:addChild(guize);
            
    self.ScrollView_list:pushBackCustomItem(layout);
    
    local Node_PageControl = self.Image_bg:getChildByName("Node_PageControl");
    self.Node_PageControl = Node_PageControl;

    self.Button_PointExplain = self.Image_bg:getChildByName("Button_1");
    if self.Button_PointExplain then
        self.Button_PointExplain:onClick(function(sender)
		    self:ClickPointExplainBtnCallBack(sender);
	    end)
    end   
    self.Button_PointExplain:setEnabled(false);

    self.Button_GameIntroduction = self.Image_bg:getChildByName("Button_2");
    if self.Button_GameIntroduction then
        self.Button_GameIntroduction:onClick(function(sender)
		    self:ClickGameIntroductionBtnCallBack(sender);
	    end)
    end

    local pageUpBtn =  Node_PageControl:getChildByName("Button_PageUP");
    if pageUpBtn then
        pageUpBtn:onClick(function(sender)
		    self:ClickpageUpBtnCallBack(sender);
	    end)
    end
    local pageDownBtn =  Node_PageControl:getChildByName("Button_PageDown");
     if pageDownBtn then
        pageDownBtn:onClick(function(sender)
		    self:ClickpageDownBtnCallBack(sender);
	    end)
    end

    local closeBtn = self.Image_bg:getChildByName("Button_close");
     -- 适配
    local framesize = cc.Director:getInstance():getWinSize()
    local addWidth =(framesize.width - 1280) / 4;

    closeBtn:setPositionX(closeBtn:getPositionX() + addWidth);
    closeBtn:onClick(function(sender)
		self:ClickcloseBtnCallBack(sender);
	end)
end

--设置选中状态
function GuideLayer:SetSelectState()
   local AtlasLabel_PageNum = self.Node_PageControl:getChildByName("AtlasLabel_PageNum");
   AtlasLabel_PageNum:setString(tostring(self._index));        
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

function GuideLayer:ClickpageUpBtnCallBack(sender)   
    luaPrint("ClickpageUpBtnCallBack index",self._index);
    if self._index>1 then
        self._index = self._index - 1;
	    self.Image_gulid[self._index]:setVisible(true);
        self.Image_gulid[self._index + 1]:setVisible(false);   
        self:SetSelectState(self._index)     
    end
	
	if self._index == 1 then
		self.Button_PointExplain:setEnabled(false);
		self.Button_GameIntroduction:setEnabled(true); 
	end
end

function GuideLayer:ClickpageDownBtnCallBack(sender)   
    luaPrint("ClickpageDownBtnCallBack index",self._index);
    if self._index<4 then
		self._index = self._index + 1;
		self.Image_gulid[self._index -1]:setVisible(false);
		self.Image_gulid[self._index]:setVisible(true);
		self:SetSelectState(self._index) 
    end
    self.Node_PageControl:setVisible(true);
end

function GuideLayer:ClickPointExplainBtnCallBack()
    self._index = 1;
    for i=1,3 do
        if i ==1 then
            self.Image_gulid[i]:setVisible(true);
        else
            self.Image_gulid[i]:setVisible(false);
        end
    end
    self.Button_PointExplain:setEnabled(false);
    self.Button_GameIntroduction:setEnabled(true);
    self.PageView:setVisible(true);
    self.ScrollView_list:setVisible(false);
    self.Node_PageControl:setVisible(true);
end

function GuideLayer:ClickGameIntroductionBtnCallBack()
    self.Button_PointExplain:setEnabled(true);
    self.Button_GameIntroduction:setEnabled(false);
    self.PageView:setVisible(false);
    self.ScrollView_list:setVisible(true);  
    self.Node_PageControl:setVisible(false);
end

return GuideLayer;