local UpdateLayer = class("UpdateLayer",PopLayer)

function UpdateLayer:create(callback)
	return UpdateLayer.new(callback)
end

function UpdateLayer:ctor(callback)
	self.super.ctor(self,PopType.small)

	--关闭回调
	self.callback = callback

	self:initUI()
end

function UpdateLayer:initUI()
	local title = ccui.ImageView:create("common/updateTitle.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)

	local text = ""

	if GameConfig.serverVersionInfo.updateText then
		text = GameConfig.serverVersionInfo.updateText
	else
		text = "1、修复bug\n2、优化性能"
	end

	local label = FontConfig.createWithSystemFont(text,26)
	label:setPosition(self.size.width*0.5, self.size.height*0.7)
	label:setAnchorPoint(0.5,1)
	label:setDimensions(600,0)
	self.bg:addChild(label)

	self:updateSureBtnImage("gameUpdate/qianwang.png","gameUpdate/qianwang-on.png")

	local isShowClose = GameConfig.serverVersionInfo.androidMandatoryUpdate

	if device.platform == "ios" then
		isShowClose = GameConfig.serverVersionInfo.iosMandatoryUpdate
	end

	if tonumber(isShowClose) == 0 then
		self:updateCloseBtnImage("gameUpdate/hulue.png","gameUpdate/hulue-on.png")
		self.sureBtn:setPosition(self.size.width*0.65,self.sureBtn:getPositionY())
		self.closeBtn:setPosition(self.size.width*0.35,self.sureBtn:getPositionY())
	else
		self:removeBtn(1)
	end
end

function UpdateLayer:onClickSure(sender)
	-- self:clearOldResources()
	openWeb(GameConfig.appVerUrl)
end

function UpdateLayer:onClickClose(sender)
	if self.callback then
		self.callback()
	end
	self:delayCloseLayer(0)
end

function UpdateLayer:clearOldResources()
	local rootPath = {"cache/","res/","src/"};
	local writePath = cc.FileUtils:getInstance():getWritablePath()
	if next(rootPath) == nil then
		return
	end

	for k,v in pairs(rootPath) do
		local path1 = writePath..v;
		if cc.FileUtils:getInstance():isDirectoryExist(path1) then
			cc.FileUtils:getInstance():removeDirectory(path1)
			if cc.FileUtils:getInstance():isDirectoryExist(path1) then
				luaPrint("path1 ="..path1.."删除失败")
			else
				luaPrint("path1 ="..path1.."删除成功")
			end
		else
			luaPrint("path1 ="..path1.."不存在，无需删除")
		end
	end
end

return UpdateLayer
