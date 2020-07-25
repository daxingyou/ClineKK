local AdNode = class("AdNode", BaseNode)

function AdNode:create()
	return AdNode.new()
end

function AdNode:ctor()
	self.super.ctor(self)

	self:initData()

	self:initUI()
end

function AdNode:initData()
	self.curPageIndex = -1
	self.data = {
		{nontType = 1,url="",path="ad1.png"},
		{nontType = 3,url="",path="ad3.png"}
	}
end

function AdNode:initUI()
	local page=ccui.PageView:create()
	page:setContentSize(cc.size(310,570))
	page:setAnchorPoint(cc.p(0.5,0.5))
	page:setPosition(cc.p(page:getContentSize().width/2,winSize.height*0.47))
	self:addChild(page)
	self.pageView = page

	if checkIphoneX() then
		page:setPositionX(page:getPositionX()+safeX)
	end
	
	-- 总页数
	local pages = #self.data

	-- 默认是往左滑动
	self.lastScrollDir = "left"
	self.infoIndex = pages

	-- 设置滑动灵敏度
	self.pageView:setCustomScrollThreshold(30)

	-- 监听滑动事件
	self.pageView:addEventListener(
		function(sender, eventType)
--			luaPrint("-------eventType:", eventType)
			if eventType == ccui.PageViewEventType.turning then
--				self:freshSchedule();
				self:onPageViewEvent(self.infoIndex,self.lastScrollDir)
				-- 滑动后下面小圆点的状态刷新
				self:updateCircle()
			end
		end)
	
	local size = self.pageView:getContentSize()
	-- 初始化小圆点
	if pages > 1 then
		self.imgList = {}
		local mid =(1 + pages) / 2
		for k = 1,pages do
			local img = ccui.ImageView:create("hall/dian1.png")
			img:setPosition(cc.p(size.width/2 + 30 *(k - mid), winSize.height*0.16))
			self:addChild(img);
			self.imgList[#self.imgList + 1] = img
			if checkIphoneX() then
				img:setPositionX(img:getPositionX()+safeX)
			end
		end
	end

	if 1 == pages then
		self:addNewPage(1, 0)
	elseif pages >= 2 then
		self:addNewPage(pages, 0)
		self:addNewPage(1, 1)
		self:addNewPage(2, 2)
		self.pageView:scrollToPage(1)
		self:updateCircle()
		self:freshSchedule();
	end
end

-- @pageTag:	 该页显示的内容索引(数组的索引1 ~ pages)
-- @pageIdx:	 插入位置（pageView的页码索引）
function AdNode:addNewPage(pageTag, pageIdx)
--	luaPrint("==========>>>>. pageTag = "..pageTag)
	local data = self.data[pageTag]

	local size = self.pageView:getContentSize()
	local newPage=ccui.Layout:create()
	newPage:setContentSize(size)
	newPage:setTag(pageTag)
	local btn = ccui.Button:create("hall/"..data.path,"hall/"..data.path)
	btn:setPosition(size.width/2,size.height/2)
	-- btn:setScale(0.9)
	btn:setPressedActionEnabled(false)
	btn:onClick(handler(self, self.onClick))
	btn:setTag(pageTag)
	newPage:addChild(btn)

	local title = ccui.ImageView:create("hall/adTitle.png")
	title:setPosition(btn:getContentSize().width/2,btn:getContentSize().height+30)
	btn:addChild(title)
	-- 在索引位置插入新页
	self.pageView:insertPage(newPage, pageIdx)
end

-- 滑动响应处理
-- @scrollDir： 滑动方向
-- @infoIndex:  索引
function AdNode:onPageViewEvent(infoIndex,scrollDir)

	-- 总页数
	local pages = #self.data
	-- 当前页
	local curPage = self.pageView:getCurPageIndex()

	local pageInfoIndex = infoIndex
	-- 上次的滚动方向
	local lastScrollDir = scrollDir

	if pages >= 2 then
		if 0 == curPage then
--			luaPrint("111 pageInfoIndex = "..pageInfoIndex)
--			luaPrint("111 lastScrollDir = "..lastScrollDir)
			pageInfoIndex = pageInfoIndex - 1
			if pageInfoIndex <= 0 then
				pageInfoIndex = pages
			end

			-- 方向相反
			if lastScrollDir == "right" then
				pageInfoIndex = pageInfoIndex - 2
				if pageInfoIndex <= 0 then
					pageInfoIndex = pageInfoIndex + pages
				end
			end
			lastScrollDir = "left"

			self.pageView:removePageAtIndex(2)
			self:addNewPage(pageInfoIndex, 0)

		elseif 2 == curPage then
--			luaPrint("222 pageInfoIndex = "..pageInfoIndex)
--			luaPrint("222 lastScrollDir = "..lastScrollDir)
			-- 需要刷新的信息
			pageInfoIndex = pageInfoIndex + 1
			if pageInfoIndex > pages then
				pageInfoIndex = 1
			end

			if lastScrollDir == "left" then
				pageInfoIndex = pageInfoIndex + 2
				if pageInfoIndex > pages then
					pageInfoIndex = pageInfoIndex - pages
				end
			end
			lastScrollDir = "right"

			self.pageView:removePageAtIndex(0)
			self:addNewPage(pageInfoIndex, 2)
		end

		-- 强制滑动到第1页
		self.pageView:scrollToPage(1)
		self.infoIndex = pageInfoIndex
		self.lastScrollDir = lastScrollDir
	end
end

function AdNode:updateCircle()
	local page = self.pageView:getPage(1);
	local toIndex = page:getTag();
--	local page0 = self.pageView:getPage(0);
--	local page2 = self.pageView:getPage(2);
--	luaPrint(string.format("page index ==========%d %d %d",page0:getTag(),page:getTag(),page2:getTag()));
	for i = 1, #self.imgList do
		local img = self.imgList[i]
		if img then
			if toIndex == i then
				img:loadTexture("hall/dian1.png");
			else
				img:loadTexture("hall/dian2.png");
			end
		end
	end
end

function AdNode:onClick(sender)
	local tag = sender:getTag()

	local data = self.data[tag]

	if data.nontType == 1 then
		-- if copyToClipBoard(GameConfig.appVerUrl) then
		-- 	addScrollMessage("网址复制成功")
		-- end
		createGeneralizeLayer()
	elseif data.nontType == 2 then
		-- VipInfo:sendGetVipInfo()
		-- openWeb(SettlementInfo:getConfigInfoByID(serverConfig.diaoqianUrl))
	elseif data.nontType == 3 then
		-- display.getRunningScene():addChild(require("layer.popView.newExtend.hehuoren.Partner"):create())
		local layer;
		if SettlementInfo:getConfigInfoByID(47) == 0 then
			layer = require("layer.popView.newExtend.Generalize.GeneralizeLayer"):create(1)
		else
			layer = require("layer.popView.newExtend.newGeneralize.NewGeneralizeLayer"):create(1)
		end
		if layer then
			display.getRunningScene():addChild(layer);
		end
	elseif data.nontType == 4 then
		createGeneralizeLayer()
	end
end

function AdNode:freshSchedule()
	if self.autoSchdule then
		self:stopAction(self.autoSchdule)
		self.autoSchdule = nil
	end
	self.autoSchdule = schedule(self,function()
			self.pageView:scrollToPage(2)
		end,5)
end

return AdNode