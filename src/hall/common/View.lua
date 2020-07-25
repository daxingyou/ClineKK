
local View = class("View")
-- cc.exports.View = View

local SSButton = class("SSButton",View)

function SSButton:ctor(view,uiTable)
    self.view = view
    local text = view:getChildByName("Text_1")
    if text then
        text:removeSelf()
        view:addProtectedChild(text,-1,-1)
    end
    dealUI(self.view,uiTable)
end

function SSButton:getName()
    return self.view:getName();
end

function SSButton:setListener(callback, isPlay)
    self.callback = callback;
    self.isPlay = isPlay;
    -- luaPrint("button "..self.view:getName().."  register click event")

    self.view:addClickEventListener(function(sender) 
            -- luaPrint("button click")        
            if self.isClick == true then
                return;
            end

            if self.isPlay == nil then
                audio.playSound(GAME_SOUND_BUTTON);
            end

            self.isClick = true;

            self.callback(sender);

            self.isClick = nil;            
        end
    )
end

function SSButton:setTouchListener(callback, isPlay)
    self.callback = callback;
    self.isPlay = isPlay;

    self.view:addTouchEventListener(function(sender, eventTouchType) 
            if self.isClick == true then
                return;
            end

            if eventTouchType == ccui.TouchEventType.began then
                if self.isPlay == nil then
                    audio.playSound(GAME_SOUND_BUTTON);
                end            
            end

            self.isClick = true;

            self.callback(sender, eventTouchType);

            self.isClick = nil;
        end
    );
end

function SSButton:setVisible(visible)
    self.view:setVisible(visible);
end

function SSButton:setHighlighted(status)
    self.view:setHighlighted(status);
end

function SSButton:setEnabled(enabled)
    self.view:setEnabled(enabled);
end

function SSButton:isEnabled()
    return self.view:isEnabled();
end

function SSButton:setTouchEnabled(enable)
    self.view:setTouchEnabled(enable);
end

function SSButton:setBright(enable)
    self:setHighlighted(enable);
end

function SSButton:setLocalZOrder(zorder)
    self.view:setLocalZOrder(zorder);
end
function SSButton:removeFromParent()
    self.view:removeFromParent();
end

function SSButton:setTag(tag)
    if tag == nil then
        return;
    end

    self.view:setTag(tag);
end

function SSButton:setPosition(pos)
   self.view:setPosition(pos);
end

function SSButton:getPosition()
   return self.view:getPosition();
end

function SSButton:getTag()
    return self.view:getTag();
end

function SSButton:setName(name)
    self.view:setName(name);
end

function SSButton:runAction(action)
    self.view:runAction(action);
end

function SSButton:getChildByName(name)
    return self.view:getChildByName(name);
end

function SSButton:loadTextures(normal, selected, resType)
    if resType == nil then
        resType = 0
    end
    self.view:loadTextures(normal, selected, normal, resType);
end

function SSButton:addChild(child)
    self.view:addChild(child);
end

function SSButton:setPositionX(x)
    self.view:setPositionX(x);
end

function SSButton:stopAllActions()
    self.view:stopAllActions();
end

function SSButton:getPositionX()
    return self.view:getPositionX();
end

function SSButton:getPositionY()
    return self.view:getPositionY();
end

function SSButton:setLocalZOrder(zorder)
    self.view:setLocalZOrder(zorder);
end

function SSButton:setContentSize(size)
    return self.view:setContentSize(size)
end

function SSButton:getContentSize()
    return self.view:getContentSize();
end

function SSButton:setScale(value)
    self.view:setScale(value);
end

function SSButton:setColor(color)
    self.view:setColor(color);
end

local SSEditBox = class("SSEditBox",View)

function SSEditBox:ctor(view,uiTable)
    self.view = ccui.EditBox:create(view:getCustomSize(),ccui.Scale9Sprite:create())
    local ap = view:getAnchorPoint()
    self.view:setAnchorPoint(ap)
    self.view:setPosition(view:getPosition())
    self.view:setFontSize(view:getFontSize())
    self.view:setFontColor(view:getColor())
    self.view:setPlaceHolder(view:getPlaceHolder())
    self.view:setPlaceholderFontColor(view:getPlaceHolderColor())
    if view:getMaxLength()>0 then
        self.view:setMaxLength(view:getMaxLength())
    end
    self.view:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE);
    self.view:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.view:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
    -- self.view:setHACenter();
    view:getParent():addChild(self.view)
    view:removeFromParent();
    dealUI(self.view,uiTable)
end

--设置返回类型    就是键盘右下角那个键是 return 、Done 、Send 、Search 、Go等字样   （抄来的，不太了解）  
--参数：  
--  cc.KEYBOARD_RETURNTYPE_DEFAULT  --  默认  
--  cc.KEYBOARD_RETURNTYPE_DONE     --  
--  cc.KEYBOARD_RETURNTYPE_SEND     --  
--  cc.KEYBOARD_RETURNTYPE_SEARCH   --  
--  cc.KEYBOARD_RETURNTYPE_GO       -- 

function SSEditBox:setText(text)
    text = text or "";
    self.view:setText(text);
end

function SSEditBox:setPasswordEnabled(enable)
    if enable == true then
        self:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD);
    else
        self:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE);
    end
end

function SSEditBox:setNumberEnabled(enable)
    if enable == true then
        self:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC);
    else
        self:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    end
end

function SSEditBox:setPhoneNumEnabled(enable)
    if enable == true then
        self:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER);
    else
        self:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    end
end

--参数：  
--  cc.EDITBOX_INPUT_MODE_ANY           --用户可以输入任何文字  
--  cc.EDITBOX_INPUT_MODE_EMAILADDR     --用户可以输入一个电子邮件地址  
--  cc.EDITBOX_INPUT_MODE_NUMERIC       --用户被允许进入一个整数值  
--  cc.EDITBOX_INPUT_MODE_PHONENUMBER   --用户可以输入一个电话号码  
--  cc.EDITBOX_INPUT_MODE_URL           --用户可以输入一个网址  
--  cc.EDITBOX_INPUT_MODE_DECIMAL       --用户被允许进入一个真正的数值  
--  cc.EDITBOX_INPUT_MODE_SINGLELINE    --用户可以输入任何文字，换行除外 
function SSEditBox:setInputMode(mode)
    self.view:setInputMode(mode);
end

--参数：  
--  cc.EDITBOX_INPUT_FLAG_PASSWORD                      --密码  
--  cc.EDITBOX_INPUT_FLAG_SENSITIVE                     --表示输入的文本是敏感数据  
--  cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD             --每个单词的首字母应该大写  
--  cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE         --每个句子的首字母应该大写  
--  cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS   --自动大写的所有字符 
function SSEditBox:setInputFlag(flag)
    self.view:setInputFlag(flag);
end

function SSEditBox:getText()
    return self.view:getText();
end

function SSEditBox:getStringLength()
    return string.len(self.view:getText());
end

function SSEditBox:registerScriptEditBoxHandler(callback)
    self.view:registerScriptEditBoxHandler(function(eventname,sender) 
            if callback then
                callback(eventname, sender);
            end
        end
    );
end

local SSText = class("SSText",View)

function SSText:ctor(view,uiTable)
    self.view = view
    dealUI(self.view,uiTable)
end

function SSText:setText(text)
    text = text or 0;

    if type(text) == number then
        text = tostring(text);
    end

    self.view:setString(text)
    -- luaPrint("set complete "..text)
end

function SSText:getText()
    return self.view:getString();
end

function SSText:setVisible(visible)
    self.view:setVisible(visible);
end

function SSText:getPositionX()
    return self.view:getPositionX();
end

function SSText:setPositionX(x)
    return self.view:setPositionX(x);
end

function SSText:setPosition(pos)
    return self.view:setPosition(pos);
end

function SSText:getPositionY()
    return self.view:getPositionY();
end

function SSText:setPositionY(y)
    return self.view:setPositionY(y);
end

function SSText:setColor(color)
    self.view:setColor(color);
end

function SSText:setTag(tag)
    self.view:setTag(tag);
end

function SSText:getTag()
    return self.view:getTag();
end

function SSText:removeFromParent()
    self.view:removeFromParent();
end

function SSText:getContentSize()
    return self.view:getContentSize();
end

function SSText:setLocalZOrder(zorder)
    self.view:setLocalZOrder(zorder);
end

local SSNode = class("SSNode",View)

function SSNode:ctor(view,uiTable)
    self.view = view
    dealUI(self.view,uiTable)
end

function SSNode:setVisible(visible)
    self.view:setVisible(visible);
end

function SSNode:setLocalZOrder(zorder)
    self.view:setLocalZOrder(zorder);
end

function SSNode:addChild(child)
    self.view:addChild(child);
end

function SSNode:setPositionX(x)
    self.view:setPositionX(x);
end

function SSNode:getPositionX()
    return self.view:getPositionX();
end

function SSNode:setPositionY(y)
    self.view:setPositionY(y);
end

function SSNode:getPositionY()
    return self.view:getPositionY();
end

function SSNode:getPosition()
    return cc.p(self.view:getPositionX(), self.view:getPositionY());
end

function SSNode:setPosition(pos)
    self.view:setPosition(pos);
end

function SSNode:getChildByName(T)
    return self.view:getChildByName(T);
end

function SSNode:runAction(action)
    self.view:runAction(action);
end

local SSAtlasLabel = class("SSAtlasLabel",View)

function SSAtlasLabel:ctor(view,uiTable)
    self.view = view
    dealUI(self.view,uiTable)
end

function SSAtlasLabel:setVisible(visible)
    visible = visible or false;

    self.view:setVisible(visible);
end

function SSAtlasLabel:setPosition(pos)
    self.view:setPosition(pos);
end

function SSAtlasLabel:setText(text)
    text = text or "";
    
    if type(text) == number then
        text = tostring(text);
    end

    self.view:setString(text);
end

function SSAtlasLabel:setColor(color)
    self.view:setColor(color);
end

function SSAtlasLabel:setScale(scale)
    self.view:setScale(scale)
end

function SSAtlasLabel:getText()
    return self.view:getString();
end

function  SSAtlasLabel:setTag(tag)
    self.view:setTag(tag);
end

function SSAtlasLabel:getTag()
    return self.view:getTag();
end

local SSSprite = class("SSSprite",View)

function SSSprite:ctor(view,uiTable)
    self.view = view
    dealUI(self.view,uiTable)
end

function SSSprite:setVisible(visible)
    self.view:setVisible(visible);
end

function SSSprite:addChild(child)
    self.view:addChild(child);
end

function SSSprite:getChildByName(name)
    return self.view:getChildByName(name);
end

function SSSprite:getChildByTag(tag)
    return self.view:getChildByTag(tag);
end

function SSSprite:setTexture(path)
    if path == nil or path == "" then
        return;
    end
    self.view:setTexture(path);
end

local SSClip = class("SSClip",View)

function SSClip:ctor(view,uiTable)
    self.view = cc.ClippingNode:create()
    self.view:setAlphaThreshold(0)
    local front = cc.Sprite:createWithSpriteFrame(view:getSpriteFrame())
    self.view:setStencil(front)
    local size = view:getContentSize()
    local ap = view:getAnchorPoint()
    self.view:setInverted(false)
    self.view:setAnchorPoint(0.5,0.5)
    self.view:setPosition(size.width/2,size.height/2)
    self.view1 = view;
    view:addChild(self.view)
    dealUI(self.view,uiTable)
end

function SSClip:addChild(child,flag)
    if flag ~= nil then
        return self.view:addChild(child)
    end
    return self.view:addChild(child);
end

function SSClip:getChildByName(name)
    return self.view:getChildByName(name);
end

function SSClip:setVisible(visible,flag)
    if flag ~= nil then
         self.view1:setVisible(visible);
    end
    self.view:setVisible(visible);
end

function SSClip:getPosition()
    return self.view:getPosition();
end

function SSClip:getChildren()
    return self.view:getChildren();
end

function SSClip:getName()
    return self.view:getName();
end

function SSClip:getContentSize()
    return self.view:getContentSize();
end

function SSClip:removeFromParent()
    self.view:removeFromParent();
end

local SSCheckBox = class("SSCheckBox",View)

function SSCheckBox:ctor(view,uiTable)
    self.view = view
    dealUI(self.view,uiTable)
end

function SSCheckBox:setListener(callback)
   self.callback = callback;

    self.view:addEventListener(function(sender, eventTouchType) 
            if self.isClick == true then
                return;
            end

            if eventTouchType == ccui.TouchEventType.began then
                audio.playSound(GAME_SOUND_BUTTON);
            end

            self.isClick = true;

            self.callback(sender, eventTouchType);

            self.isClick = nil;
        end
    )
end

function SSCheckBox:setTag(tag)
    self.view:setTag(tag);
end

function SSCheckBox:getTag()
    return self.view:getTag();
end

function SSCheckBox:getChildByName(name)
    return self.view:getChildByName(name);
end

function SSCheckBox:setTouchEnabled(enable)
    self.view:setTouchEnabled(enable);
end

function SSCheckBox:setSelected(isSelected)
    self.view:setSelected(isSelected);
end

function SSCheckBox:isSelected()
    return self.view:isSelected();
end

local SSImage = class("SSImage",View)

function SSImage:ctor(view,uiTable)
    self.view = view
    dealUI(self.view,uiTable)
end

function SSImage:setVisible(visible)
    self.view:setVisible(visible);
end

function SSImage:isVisible()
    return self.view:isVisible();
end

function SSImage:loadTexture(path)
    if path == nil or path == "" then
        return;
    end
    
    self.view:loadTexture(path);
end

function SSImage:setAnchorPoint(point)
    self.view:setAnchorPoint(point);
end

function SSImage:setPosition(pos)
    self.view:setPosition(pos)
end

function SSImage:getContentSize()
    return self.view:getContentSize();
end

function SSImage:setContentSize(size)
    return self.view:setContentSize(size)
end

function SSImage:addChild(child)
    self.view:addChild(child);
end

function SSImage:getChildByName(name)
    return self.view:getChildByName(name);
end

function SSImage:removeChildByName(name)
    self.view:removeChildByName(name);
end

function SSImage:getRotation()
    return self.view:getRotation();
end

function SSImage:getPositionX()
    return self.view:getPositionX();
end

function SSImage:getPositionY()
    return self.view:getPositionY();
end

function SSImage:getPosition()
    return self.view:getPosition();
end

function SSImage:setPositionY(y)
    self.view:setPositionY(y)
end

function SSImage:getScaleX()
    return self.view:getScaleX()
end

function SSImage:convertToNodeSpace(worldPoint)
    return self.view:convertToNodeSpace(worldPoint);
end

function SSImage:convertToWorldSpace(nodePoint)
    return self.view:convertToWorldSpace(nodePoint);
end

function SSImage:setLocalZOrder(zorder)
    self.view:setLocalZOrder(zorder);
end

function SSImage:removeAllChildren()
    self.view:removeAllChildren();
end

function SSImage:setOpacity(opacity)
    self.view:setOpacity(opacity);
end

function SSImage:setScale(s)
    self.view:setScale(s);
end

function SSImage:getChildByTag(tag)
    return self.view:getChildByTag(tag);
end

function SSImage:getParent()
    return self.view:getParent();
end

function SSImage:retain()
    self.view:retain();
end

function SSImage:release()
    self.view:release();
end

function SSImage:runAction(action)
    self.view:runAction(action);
end

function SSImage:setupTexture()
    self.view:setupTexture();
end

function SSImage:setTouchEnabled(enable)
    enable = enable or false;
    self.view:setTouchEnabled(enable);
end

function SSImage:addClickEventListener(callback, isPlay)
    self.callback = callback;
    self.isPlay = isPlay;

    self.view:addClickEventListener(function(sender)
            if self.isClick == true then
                return;
            end

            if self.isPlay == nil then
                audio.playSound(GAME_SOUND_BUTTON);
            end

            self.isClick = true;

            self.callback(sender);

            self.isClick = nil;            
        end
    )
end

local SSPanel = class("SSPanel",View)

function SSPanel:ctor(view,uiTable)
    self.view = view
    dealUI(self.view,uiTable)
end

function SSPanel:setVisible(visible)
    visible = visible;

    self.view:setVisible(visible);
end

function SSPanel:setPositionY(y)
    self.view:setPositionY(y);
end

function SSPanel:setScale(s)
    self.view:setScale(s);
end


local SSSlider = class("SSSlider",View)

function SSSlider:ctor(view,uiTable)
    self.view = view
    dealUI(self.view,uiTable)
end

function SSSlider:setListener(callback)
    self.callback = callback;

    self.view:addEventListener(function(sender, eventTouchType)
            if eventTouchType == ccui.TouchEventType.began then
                if self.isClick == true then
                    return;
                end

                if self.isPlay == nil then
                    -- audio.playSound(GAME_SOUND_BUTTON);
                end

                self.isClick = true;



                self.callback(sender, eventTouchType);

                self.isClick = nil;
            end            
        end)
end

function SSSlider:setPercent(percent)
    self.view:setPercent(percent)
end

function SSSlider:setVisible(state)
    self.view:setVisible(state)
end

local SSScrollView = class("SSScrollView",View)

function SSScrollView:ctor(view,uiTable)
    self.view = view;
    dealUI(self.view, uiTable);
end

function SSScrollView:addChild(child)
    if child == nil then
        return;
    end

    self.view:addChild(child);
end

function SSScrollView:getContentSize()
    return self.view:getContentSize();
end

function SSScrollView:setVisible(visible)
    return self.view:setVisible(visible);
end

--是否显示滚动条  
function SSScrollView:setScrollBarEnabled(enable)
    self.view:setScrollBarEnabled(enable);
end

--设置滚动层内容的大小
function SSScrollView:setInnerContainerSize(size)
    self.view:setInnerContainerSize(size);
end

function SSScrollView:setContentSize(size)
    self.view:setContentSize(size);
end

function SSScrollView:getInnerContainerSize()
    return self.view:getInnerContainerSize();
end

function SSScrollView:removeAllChildren()
    self.view:removeAllChildren();
end

function SSScrollView:setVisible(visible)
    self.view:setVisible(visible);
end

local SSLoadingBar = class("SSLoadingBar",View)

function SSLoadingBar:ctor(view, uiTable)
    self.view = view;
end

function SSLoadingBar:setPercent(percent)
    self.view:setPercent(percent);
end

local SSLayer = class("SSLayer",View)

function SSLayer:ctor(view,uiTable)
    -- self.view = display.newLayer({r=0,g=0,b=0,a=0.5})
    -- self.view:setContentSize(view:getContentSize())
    -- local parent = view:getParent()
    -- parent:addChild(self.view,view:getLocalZOrder())
    -- self.view:setIgnoreAnchorPointForPosition(false)
    -- self.view:setAnchorPoint(view:getAnchorPoint())
    -- self.view:setPosition(view:getPosition())
    -- self:dealUI(uiTable)

    self.view = display.newLayer({r=0,g=0,b=0,a=0.5})
    self.view:setContentSize(view:getContentSize())

    view:addChild(self.view)
    self.view:setIgnoreAnchorPointForPosition(false)
    self.view:setAnchorPoint(view:getAnchorPoint())
    local size = view:getContentSize()
    local ap = view:getAnchorPoint()
    self.view:setPosition(size.width*ap.x,size.height*ap.y)
    dealUI(self.view,uiTable)
end

function View:ctor()

end

function View:setVisible(visible)
    visible = visible;
    
    self.view:setVisible(visible);
end

function loadCsb(self,csb,uiTable)
    luaPrint("csb ======== "..csb)
    self.view = ui.csbNode("csbs/" .. csb .. ".csb")
    self:addChild(self.view);
    iphoneXFit(dealUI(self,uiTable))
end

function loadJson(self,json,uiTable)
    self.view =  ccs.GUIReader:getInstance():widgetFromJsonFile(json);
    self:addChild(self.view);
    iphoneXFit(dealUI(self,uiTable))
end

function getChildByName(node,name)
    if node:getName() == name then
        return node;
    end

    local children = node:getChildren();
    for i,node in ipairs(children) do
        if node then
            local child = getChildByName(node,name)

            if child ~= nil then
                return child;
            end
        end
    end

    return nil;
end

function getChildByTag(node,tag)
    if node:getTag() == tag then
        return node;
    end

    local children = node:getChildren();
    for i,node in ipairs(children) do
        if node then
            local child = getChildByTag(node,tag)

            if child ~= nil then
                return child;
            end
        end
    end

    return nil;
end

function dealUI(self,uiTable)
    local view = self.view;
    local node = nil
    for k,v in pairs(uiTable or {}) do
        local strArr = string.split(k,"_")
        -- local view = self.view:getChildByName(k)
        local view = getChildByName(view,k);
        if view ~= nil then
            if strArr[2] == "_bg" then
                node = view
            end

            if "Button" == strArr[1] then
                self[k] = SSButton.new(view,v)
            elseif "EditBox" == strArr[1] then
                self[k] = SSEditBox.new(view,v)
            elseif "Text" == strArr[1] then
                self[k] = SSText.new(view,v)
            elseif "Node" == strArr[1] then
                self[k] = SSNode.new(view,v)
            elseif "AtlasLabel" == strArr[1] then
                self[k] = SSAtlasLabel.new(view,v)
            elseif "Sprite" == strArr[1] then
                self[k] = SSSprite.new(view,v)
            elseif "Clip" == strArr[1] then
                self[k] = SSClip.new(view,v)
            elseif "CheckBox" == strArr[1] then
                self[k] = SSCheckBox.new(view,v)
            elseif "Image" == strArr[1] then
                self[k] = SSImage.new(view,v)
            elseif "Panel" == strArr[1] then
                self[k] = SSPanel.new(view,v)
            elseif "Layer" == strArr[1] then
                self[k] = SSLayer.new(view,v)
            elseif "Slider" == strArr[1] then
                self[k] = SSSlider.new(view,v);
            elseif "ScrollView" == strArr[1] then
                self[k] = SSScrollView.new(view,v);
            elseif "LoadingBar" == strArr[1] then
                self[k] = SSLoadingBar.new(view,v);
            else
                luaPrint("未定义 "..strArr[1].." 类型")
            end
        else
            luaPrint(k.."  is  nil error!!!!!");
        end
    end

    return node
end

