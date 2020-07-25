--H5充值页面

local RechargeLayer = class("RechargeLayer", PopLayer)

function RechargeLayer:ctor()
	self.super.ctor(self,PopType.small,true)

	self:initUI()
end

function RechargeLayer:initUI()
	self:setName("RechargeLayer");
	self:updateBg("common/rechargeBg.png");

	self:updateCloseBtnPos(10,50)
	self.sureBtn:setVisible(false)

	if device.platform ~= "windows" then
--		LoadingLayer:createLoading(FontConfig.gFontConfig_22,"安全加载中");
		local webView = ccexp.WebView:create()
		webView:setContentSize(cc.size(1000, 600))
		webView:setScalesPageToFit(true)
		webView:setPosition(cc.p(470, 300))
		webView:loadURL(GameConfig:getWebPay()..PlatformLogic.loginResult.dwUserID,true)
		webView:setBackgroundTransparent()
		webView:setBounces(false)
		webView:hide()
		self.bg:addChild(webView)
		self._webView = webView;
		webView:setOnShouldStartLoading(function(sender, url)
			luaPrint("onWebViewShouldStartLoading,url is ", url)
			return true
		end)

		webView:setOnDidFinishLoading(function(sender, url)
			luaPrint("onWebViewDidFinishLoading,url is ", url)
--			LoadingLayer:removeLoading();
			if self:isVisible() then
			sender:show()
			end
		end)

		webView:setOnDidFailLoading(function(sender, url)
			luaPrint("onWebViewDidFailLoading,url is ", url)
		end)
		--设置Scheme 用于iOS复制微信号到剪贴板
		if webView.setOnJSCallback then
			local scheme = "weixincopy"
			webView:setJavascriptInterfaceScheme(scheme)
			webView:setOnJSCallback(function(sender,url)
				luaPrint("js callback ===",url)
				local i,j = string.find(url,"://")
				if i and j then
					local js = string.split(url,"_")
					luaDump(js,"jscallback")
					if #js == 1 then
						luaPrint("老版兼容",string.gsub(url,scheme.."://_"..scheme.."_",""))
						copyToClipBoard(string.urldecode(string.gsub(url,scheme.."://_"..scheme.."_","")))
					else
						if #js > 2 then
							local endIndex = string.len(url)-string.len(js[#js])-1
							local startIndex = string.len(js[1])+string.len(js[2])+2+1
							if endIndex < startIndex then
								endIndex = string.len(url)
							end
							local realStr = string.sub(url,startIndex,endIndex)
							luaPrint(realStr)
							if realStr ~= js[#js] then
								i,j = string.find(realStr,js[#js]) 
								if i and j then
									realStr = string.gsub(realStr,js[#js],":")
								else
									realStr = realStr.."_"..js[#js]
								end
							end
							luaPrint("真正的字符 ",realStr)
							if js[2] == "weixincopy" then
								copyToClipBoard(string.urldecode(realStr))
							elseif js[2] == "tiaozhuan" then
								openWeb(realStr)
							end
						end
					end
				end
			end)
		end
--		webView:stopLoading()
--		webView:reload()
	end
	
	--默认隐藏
	self:hideAll();
	--2秒后移除Loading
--	performWithDelay(self,function() LoadingLayer:removeLoading(); end, 2)
end

function RechargeLayer:onEnterTransitionFinish()
	iphoneXFit(self.xBg,3)
	self:setScale(1)
end

--重新加载网页
function RechargeLayer:reload()
	self:showAll();
end
function RechargeLayer:delayCloseLayer(dt,callback)
	performWithDelay(self, function() self:closeLayer() end, 0.1)
end
--关闭layer 更改为隐藏
function RechargeLayer:closeLayer()
	--重新加载
	if device.platform ~= "windows" then
		if self._webView then
			self._webView:reload()
		end
	end
	self:hideAll();
end

--隐藏所有并且屏蔽点击事件
function RechargeLayer:hideAll()
	self:hide();
	self:setTouchEnabled(false);
	if device.platform ~= "windows" then
		if self._webView then
			self._webView:hide()
			self._webView:setTouchEnabled(false);
		end
	end
end

--显示所有
function RechargeLayer:showAll()
	self:show();
	self:setTouchEnabled(true);
	if device.platform ~= "windows" then
		if self._webView then
			-- self._webView:reload()
			self._webView:show()
			self._webView:setTouchEnabled(true);
		end
	end
end

return RechargeLayer


