local GeneralizeNode = class("GeneralizeNode", BaseWindow)

--我的推广
--创建类
function GeneralizeNode:create(parent)
	local layer = GeneralizeNode.new(parent);
    layer:setName("GeneralizeNode");
	return layer;
end

--构造函数
function GeneralizeNode:ctor(parent)
    self.super.ctor(self, 0, false);
    local uiTable = {
        Text_fatherId = "Text_fatherId",
        Text_id = "Text_id",
        Text_num = "Text_num",
        Text_player = "Text_player",
        Text_add = "Text_add",
        Text_active = "Text_active",

        Image_qrBg = "Image_qrBg",
        Text_url = "Text_url",
        Button_share = "Button_share",
        Button_copyUrl = "Button_copyUrl",
    }

    loadNewCsb(self,"Node_Generalize",uiTable);

    self.parent = parent;

    self:InitData();

    self:InitUI();

	self:pushEventInfo(ExtendInfo,"ExtendTotalCount",handler(self, self.onExtendTotalCount));
    self:pushEventInfo(SettlementInfo, "configInfo", handler(self, self.receiveConfigInfo))
end

function GeneralizeNode:InitData()
end

function GeneralizeNode:InitUI()
    self.Button_share:setPositionY(self.Button_copyUrl:getPositionY());
    self.Button_share:setVisible(true);
    --生成二维码
    createExtendQr()

    local qrSize = self.Image_qrBg:getContentSize();
    local savePath = cc.FileUtils:getInstance():getWritablePath();
    local teamSp = ccui.ImageView:create(cc.FileUtils:getInstance():getWritablePath()..PlatformLogic.loginResult.dwUserID..".png")
    teamSp:setScale((qrSize.height-30)/teamSp:getContentSize().height);  
    teamSp:setPosition(qrSize.width/2,qrSize.height/2);
    self.Image_qrBg:addChild(teamSp);

    --url分割
    local urlStr = getQrUrl();
    local temp = "http://";
    if type(urlStr) == "string" and #urlStr > #temp then
        if string.sub(urlStr,1,7) == temp then
            urlStr = string.sub(urlStr,8,#urlStr)
        elseif string.sub(urlStr,1,8) == "https://" then
            urlStr = string.sub(urlStr,9,#urlStr)
        end
    end

    self.Text_url:setString(urlStr);

    if self.Button_copyUrl then
        self.Button_copyUrl:onClick(handler(self,self.CopyUrlClick));
    end

    if self.Button_share then
        self.Button_share:onClick(handler(self,self.ShareClick));
    end

    if self.parent.totalCount then
        self:RefreshData(self.parent.totalCount);
    end
end

--进入
function GeneralizeNode:onEnter()
    self.super.onEnter(self); 
end

--拷贝链接
function GeneralizeNode:CopyUrlClick()
    if copyToClipBoard(getQrUrl()) then
        addScrollMessage("推广地址复制成功")
    end
end

--分享按钮回调
function GeneralizeNode:ShareClick()
    local touchLayer = display.newLayer()
    touchLayer:setTouchEnabled(true)
    touchLayer:setLocalZOrder(9000)
    display.getRunningScene():addChild(touchLayer)
    touchLayer:onTouch(function(event) 
                            local eventType = event.name; 
                            if eventType == "began" then
                                return true
                            end
                            if eventType == "ended" or eventType == "cancel" then
                                performWithDelay(self,function() touchLayer:removeSelf() end,0.1)
                            end
                end,false, true)

    local qr = ccui.ImageView:create(qrPath)
    qr:setPosition(winSize.width/2,winSize.height/2)
    touchLayer:addChild(qr)

    saveSystemPhoto(qrPath)
end

--刷新界面
function GeneralizeNode:RefreshData(data)
    self.Text_fatherId:setString(data.UpAgencyID);
    self.Text_id:setString(PlatformLogic.loginResult.dwUserID);
    self.Text_num:setString(data.TeamCount);
    self.Text_player:setString(data.DirectCount);
    self.Text_add:setString(data.NewAdd);
    self.Text_active:setString(data.TodayActive);
end

function GeneralizeNode:onExtendTotalCount(data)
    local msg = data._usedata;
    self:RefreshData(msg);
end

function GeneralizeNode:receiveConfigInfo(data)
    local data = data._usedata

    if data.id == 9 then
       self.Text_url:setString(getQrUrl())
    end
end

return GeneralizeNode;