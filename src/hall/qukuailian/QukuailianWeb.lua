local QukuailianWeb = class("QukuailianWeb", PopLayer)


function QukuailianWeb:ctor(_url)
	-- self.super.ctor(self, 0, true);
	self.super.ctor(self,PopType.middle)
	self:initUI(_url);	
end

function QukuailianWeb:create(_url)
	local layer = QukuailianWeb.new(_url);

	return layer;
end

function QukuailianWeb:initUI(_url)
	self.m_url = _url;
	luaPrint("self.m_url123:",self.m_url);

	self.sureBtn:setVisible(false)

	local title = ccui.ImageView:create("qukuailian/image2/qklian_jianyanzhushou.png");
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local panel = ccui.Layout:create();
	panel:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	panel:setAnchorPoint(0.5,0);
    -- panel:setBackGroundColor(cc.c3b(128, 128, 128))
	panel:setContentSize(cc.size(950, 410));

	panel:setPosition(cc.p(self.bg:getContentSize().width/2,130));

	self.panel = panel;
	if self.bg then
    	self.bg:addChild(self.panel);
	end

	-- if device.platform ~= "windows" then
 --        	local size = self.panel:getContentSize();
	-- 		local webView = ccexp.WebView:create()
	-- 		webView:setContentSize(size)
	-- 		webView:setPosition(size.width*0.5,size.height/2)
	-- 		webView:loadURL(self.m_url);
	-- 		webView:setScalesPageToFit(true)
	-- 		-- webView:setScaleX(0.82)
	-- 		webView:setOnShouldStartLoading(function(sender, url)
	-- 	        luaPrint("onWebViewShouldStartLoading, url is ", url)
	-- 	        return true
	-- 	    end)
	-- 	    webView:setOnDidFinishLoading(function(sender, url)
	-- 	        luaPrint("onWebViewDidFinishLoading, url is ", url)
	-- 	    end)
	-- 	    webView:setOnDidFailLoading(function(sender, url)
	-- 	        luaPrint("onWebViewDidFinishLoading, url is ", url)
	-- 	    end)


	-- 		self.panel:addChild(webView);
	-- 		self.webView = webView;		
	-- else
	-- 		cc.Application:getInstance():openURL(self.m_url);
	-- end


	

	-- -- self:addChild(panel);

	-- -- local size = panel:getContentSize();
	
	-- -- local closeBtn = ccui.Button:create("common/close.png","common/close-on.png")
	-- -- closeBtn:setPosition(size.width-45,size.height-45)
	-- -- panel:addChild(closeBtn)
	
	-- -- closeBtn:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	-- self.m_checkTimeId = -1;

	-- if device.platform ~= "windows" then
	-- 	local function checkExitDialog( delta )
	--    		if display.getRunningScene():getChildByName("exitGameLayer") then
	--    			if self.webView then
	--    				self.webView:setVisible(false);
	--    				luaPrint("self.webView------visible false")
	--    			end
	--    		else
	--    			if self.webView then
	--    				self.webView:setVisible(true);
	--    				luaPrint("self.webView------visible true")
	--    			end
	--    		end  
	--    	end

	-- 	self.m_checkTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) checkExitDialog(delta) end, 0.1 ,false);
	-- end
	

	

end

function QukuailianWeb:initWeb()
	if device.platform ~= "windows" then
        	local size = self.panel:getContentSize();
			local webView = ccexp.WebView:create()
			webView:setContentSize(size)
			webView:setPosition(size.width*0.5,size.height/2)
			webView:loadURL(self.m_url);
			webView:setScalesPageToFit(true)
			-- webView:setScaleX(0.82)
			webView:setOnShouldStartLoading(function(sender, url)
		        luaPrint("onWebViewShouldStartLoading, url is ", url)
		        return true
		    end)
		    webView:setOnDidFinishLoading(function(sender, url)
		        luaPrint("onWebViewDidFinishLoading, url is ", url)
		    end)
		    webView:setOnDidFailLoading(function(sender, url)
		        luaPrint("onWebViewDidFinishLoading, url is ", url)
		    end)


			self.panel:addChild(webView);
			self.webView = webView;		
	else
			cc.Application:getInstance():openURL(self.m_url);
	end


	

	-- self:addChild(panel);

	-- local size = panel:getContentSize();
	
	-- local closeBtn = ccui.Button:create("common/close.png","common/close-on.png")
	-- closeBtn:setPosition(size.width-45,size.height-45)
	-- panel:addChild(closeBtn)
	
	-- closeBtn:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.m_checkTimeId = -1;

	if device.platform ~= "windows" then
		local function checkExitDialog( delta )
	   		if display.getRunningScene():getChildByName("exitGameLayer") then
	   			if self.webView then
	   				self.webView:setVisible(false);
	   				luaPrint("self.webView------visible false")
	   			end
	   		else
	   			if self.webView then
	   				self.webView:setVisible(true);
	   				luaPrint("self.webView------visible true")
	   			end
	   		end  
	   	end

		self.m_checkTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) checkExitDialog(delta) end, 0.1 ,false);
	end
end



function QukuailianWeb:onEnter()
	self.super.onEnter(self);
	luaPrint("QukuailianWeb:onEnter----------------------abc")
	self:initWeb();
end

function QukuailianWeb:onExit()
	self.super.onExit(self);
	luaPrint("QukuailianWeb:onExit----------------------abc")
	if self.m_checkTimeId ~= nil and self.m_checkTimeId ~= -1 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_checkTimeId);
        self.m_checkTimeId = -1;
    end
end

--按钮响应
function QukuailianWeb:onBtnClickEvent(sender,event)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        
    elseif event == ccui.TouchEventType.ended then
    	self:removeSelf();
    end
end

return QukuailianWeb;