local AliyunLayer = class("AliyunLayer",PopLayer)

function AliyunLayer:create(callback)
	return AliyunLayer.new(callback)
end

function AliyunLayer:ctor(callback)
	self.super.ctor(self,PopType.small)

	self.callback = callback

	self:initUI()

	self:bindEvent()
end

function AliyunLayer:bindEvent()
	self:pushGlobalEventInfo("checkFangShuaFailed",handler(self, self.checkFangShuaFailed))
end

function AliyunLayer:initUI()
	self:updateSureBtnPos(-25)
	local title = ccui.ImageView:create("common/wenxintishi.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)

	local image = ccui.ImageView:create("hall/huadongyanzheng.png")
	image:setPosition(self.size.width/2,self.size.height*0.75)
	self.bg:addChild(image)

	local image = ccui.ImageView:create("hall/jiantou.png")
	image:setPosition(self.size.width/2,self.size.height*0.45)
	self.bg:addChild(image)

	local image = ccui.ImageView:create("hall/shoushi.png")
	image:setPosition(self.size.width/2,self.size.height*0.35)
	self.bg:addChild(image)

	local move = cc.MoveBy:create(0.3,cc.p(20,0))

	image:runAction(cc.RepeatForever:create(cc.Sequence:create(move,move:reverse())))

	self:createWebView()
end

function AliyunLayer:createWebView()
	if device.platform ~= "windows" and isEmptyString(globalUnit.jsstring2) then
		local rd,code,pcode = createCheckCode(1356)

		local webView = ccexp.WebView:create()
		webView:setContentSize(cc.size(650, 100))
		webView:setScalesPageToFit(true)
		webView:setPosition(cc.p(self.size.width/2-20, self.size.height*0.6))
		local url = GameConfig.AliyunUrl.."/fs/index.html?AppKey="..pcode
		webView:loadURL(url,false)
		webView:setBackgroundTransparent()
		webView:setBounces(false)
		self.bg:addChild(webView)
		self._webView = webView
		webView:setOnShouldStartLoading(function(sender, url)
			luaPrint("onWebViewShouldStartLoading,url is ", url)
			return true
		end)

		webView:setOnDidFinishLoading(function(sender, url)
			luaPrint("onWebViewDidFinishLoading,url is ", url)
			if self:isVisible() then
				sender:show()
			end
		end)

		webView:setOnDidFailLoading(function(sender, url)
			luaPrint("onWebViewDidFailLoading,url is ", url)
			webView:reload()
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
					if #js > 2 then
						if js[2] == "fangshua" then
							if tonumber(js[3]) == 1 then
								local endIndex = string.len(url)-string.len(js[#js])-1
								local startIndex = string.len(js[1])+string.len(js[2])+string.len(js[3])+3+1
								if endIndex < startIndex then
									endIndex = string.len(url)
								end
								local realStr = string.sub(url,startIndex,endIndex)

								i,j = string.find(realStr,js[#js]) 
								if i and j then
									realStr = string.gsub(realStr,js[#js],"_")
								end
								luaPrint(realStr)

								globalUnit.jsstring2 = realStr

								if self._webView then
									self._webView:setJavascriptInterfaceScheme("")
									self._webView:setOnJSCallback(function(sender,url) end)
								end
							else
								addScrollMessage("请稍后重试")
								self._webView:reload()
							end
						end
					end
				end
			end)
		end
	end
end

function AliyunLayer:onClickSure(sender)
	if isEmptyString(globalUnit.jsstring2) then
		addScrollMessage("请先滑动确认")
		return
	end

	self:delayCloseLayer(0,self.callback)
end

return AliyunLayer
