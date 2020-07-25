local QukuailianBar = class("QukuailianBar", BaseWindow)
function QukuailianBar:ctor(gameType,target,align)
	-- self.super.ctor(self,PopType.small)
	self.super.ctor(self, 0, false);
	self:bindEvent();


	self:initData(gameType,target,align);

	self:initUI();
	
end

--align 验证按钮显示位置  0:靠下，1：靠左边 2:靠右边 默认靠下
function QukuailianBar:create(gameType,target,align)
	local layer = QukuailianBar.new(gameType,target,align);
	layer:setVisible(SettlementInfo:getConfigInfoByID(44) == 1);
	return layer;
end

function QukuailianBar:onEnter()
	self.super.onEnter(self);
	if self.target == nil then
		self.target = self:getParent();
	end
end

function QukuailianBar:bindEvent()

	self:pushGlobalEventInfo("QUKUAILIAN_RESULT",handler(self, self.onRecHashResult));
	self:pushGlobalEventInfo("QUKUAILIAN_SEND",handler(self, self.onRecHashCode));
end

function QukuailianBar:initUI()

	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("qukuailian/image/qukuailian/image2/qklian_img.plist");
	
	self.Panel_root = ccui.Layout:create();

	if self.m_align == 0 then
		self:setContentSize(cc.size(120,135));
		self.Panel_root:setContentSize(cc.size(120,135));
	elseif self.m_align == 1 or self.m_align == 2 then
		self:setContentSize(cc.size(190,70));
		self.Panel_root:setContentSize(cc.size(190,70));
	end

	self:ignoreAnchorPointForPosition(false);
	self:setAnchorPoint(cc.p(0.5,0.5));


	
	self.Panel_root:setPosition(cc.p(0,0));
	
	self:addChild(self.Panel_root);


	--缩略验证按钮
	self.Button_verify = ccui.Button:create("qukuailian/image2/qklian_yanzheng.png","qukuailian/image2/qklian_yanzheng-on.png","qukuailian/image2/qklian_yanzheng-on.png",ccui.TextureResType.localType);
	self.Panel_root:addChild(self.Button_verify);

	self.Button_verify:onClick(handler(self,self.onBtnClickEvent))
	self.Button_verify:setName("Button_verify");

	--缩略复制按钮
	self.Button_copy = ccui.Button:create("qukuailian/image2/qklian_fuzhigongzhengma.png","qukuailian/image2/qklian_fuzhigongzhengma-on.png","qukuailian/image2/qklian_fuzhigongzhengma-on.png",ccui.TextureResType.localType);
	self.Panel_root:addChild(self.Button_copy);
	-- self.Button_copy:setPosition(cc.p(60,30));
	self.Button_copy:onClick(handler(self,self.onBtnClickEvent))
	self.Button_copy:setName("Button_copy");

	--缩略hash code
	self.Text_hashCodeDot = FontConfig.createWithSystemFont("",20,FontConfig.colorWhite,cc.size(110,20),"Arial",cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	self.Text_hashCodeDot:setAnchorPoint(cc.p(0,0.5))
	self.Button_copy:addChild(self.Text_hashCodeDot);
	-- self.Text_hashCodeDot:setPosition(cc.p(9,47));

	--align 验证按钮显示位置  0:靠下，1：靠左边 2:靠右边 默认靠下
	luaPrint("self.m_align_123:",self.m_align)
	if self.m_align == 0 then
		self.Button_verify:setPosition(cc.p(58,93));
		self.Button_copy:setPosition(cc.p(60,30));
		self.Text_hashCodeDot:setPosition(cc.p(9,47));
	elseif self.m_align == 1 then
		self.Button_verify:setPosition(cc.p(35,35));
		self.Button_copy:setPosition(cc.p(130,32));
		self.Text_hashCodeDot:setPosition(cc.p(9,47));
	elseif self.m_align == 2  then
		self.Button_verify:setPosition(cc.p(155,35));
		self.Button_copy:setPosition(cc.p(60,32));
		self.Text_hashCodeDot:setPosition(cc.p(9,47));
	end


	--详细hashcode底图
	-- if self.m_align == 1 then
	-- 	self.Image_hashCode = ccui.ImageView:create("qukuailian/image2/qklian_tanchuang.png",ccui.TextureResType.localType);
	-- else
	-- 	-- self.Image_hashCode = ccui.ImageView:create("qukuailian/image2/qklian_tanchuang.png",ccui.TextureResType.localType);
	-- end
	

	-- -- self.Panel_root:addChild(self.Image_hashCode);
	-- -- self.Image_hashCode:setPosition(cc.p(-478,35));


	-- --panel_image
	-- local panel_image = ccui.Layout:create();
	-- local sizeImg = self.Image_hashCode:getContentSize();
	-- panel_image:setContentSize(sizeImg);

	-- local titleImg = ccui.ImageView:create("qukuailian/image2/qklian_benjugongzhengma.png",ccui.TextureResType.localType);
	-- panel_image:addChild(titleImg);

	-- if self.m_align == 1 then
	-- 	panel_image:setPosition(cc.p(-475,35));
	-- 	titleImg:setPosition(cc.p(483,153));
	-- else
	-- 	-- panel_image:setPosition(cc.p(593,35));
	-- 	-- self.Image_hashCode:setFlippedX(true);
	-- 	-- titleImg:setPosition(cc.p(480,153));
	-- end
	
	-- panel_image:setAnchorPoint(cc.p(0.5,0.5));
	-- self:addChild(panel_image);
	-- panel_image:addChild(self.Image_hashCode);
	-- self.Image_hashCode:setPosition(cc.p(sizeImg.width*0.5,sizeImg.height*0.5))

	-- self.Panel_image = panel_image;
	-- -- --详细hash code
	-- self.Text_hashCode = FontConfig.createWithSystemFont("12345",24,FontConfig.colorWhite,cc.size(890,28),"Arial",cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	
	-- self.Text_hashCode:setAnchorPoint(cc.p(0.5,0.5))
	-- self.Panel_image:addChild(self.Text_hashCode);
	-- self.Text_hashCode:setPosition(cc.p(480,100));
	-- self.Text_hashCode:setName("Text_hashCode");

	-- if self.m_align == 1 then
	-- 	self.Text_hashCode:setPosition(cc.p(480,100));
	-- else
	-- 	-- self.Text_hashCode:setPosition(cc.p(514,100));
	-- end

	-- --详细复制按钮
	-- self.Button_copyCode = ccui.Button:create("qukuailian/image2/qklian_fuzhianniu.png","qukuailian/image2/qklian_fuzhianniu-on.png","qukuailian/image2/qklian_fuzhianniu-on.png",ccui.TextureResType.localType);
	-- self.Panel_image:addChild(self.Button_copyCode);
	-- self.Button_copyCode:setPosition(cc.p(480,40));
	-- self.Button_copyCode:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	-- self.Button_copyCode:setName("Button_copyCode");
	-- self.Button_copyCode.hashCode = ""; ---需要复制的消息
	
	-- self.Button_copyCode:setName("Button_copyCode");

	-- self.Panel_image:setVisible(false);
end





function QukuailianBar:initData(gameType,target,align)
	self.m_gameType = gameType; --游戏名称  例如 bairenniuniu,baijiale
	self.m_recordList = {}  --
	self.m_recordDataList = {}  --

	self.m_ethernetAdd = ""; --当前显示以太网网址
	self.m_hashCode = "";   --当前公正码
	--默认右边
	if align == nil then
		align = 0;
	end

	self.m_align = align;

	self.m_hashLayer = nil;

	self.target = target;

end


function QukuailianBar:showNewHashCode(hashCode)

	local image_hashCode = ccui.ImageView:create("qukuailian/image2/qklian_tanchuang.png",ccui.TextureResType.localType);
	

	local panel_image = ccui.Layout:create();
	local sizeImg = image_hashCode:getContentSize();
	panel_image:setContentSize(sizeImg);

	

	panel_image:setAnchorPoint(cc.p(0.5,0.5));
	panel_image:addChild(image_hashCode);
	image_hashCode:setPosition(cc.p(sizeImg.width*0.5,sizeImg.height*0.5));

	local titleImg = ccui.ImageView:create("qukuailian/image2/qklian_benjugongzhengma.png",ccui.TextureResType.localType);
	panel_image:addChild(titleImg);
	titleImg:setPosition(cc.p(sizeImg.width*0.5,153));
	-- --详细hash code
	local text_hashCode = FontConfig.createWithSystemFont(hashCode,24,FontConfig.colorWhite,cc.size(890,28),"Arial",cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	
	text_hashCode:setAnchorPoint(cc.p(0.5,0.5))
	panel_image:addChild(text_hashCode);
	text_hashCode:setPosition(cc.p(sizeImg.width*0.5,100));
	text_hashCode:setName("Text_hashCode");

	--详细复制按钮
	local button_copyCode = ccui.Button:create("qukuailian/image2/qklian_fuzhi.png","qukuailian/image2/qklian_fuzhianniu.png","qukuailian/image2/qklian_fuzhianniu.png",ccui.TextureResType.localType);
	panel_image:addChild(button_copyCode);
	button_copyCode:setPosition(cc.p(sizeImg.width*0.5,40));
	button_copyCode:onClick(handler(self,self.onBtnClickEvent))
	button_copyCode:setName("Button_copyCode");
	button_copyCode.hashCode = hashCode; ---需要复制的消息
	
	button_copyCode:setName("Button_copyCode");

	local framesize = cc.Director:getInstance():getWinSize()
	panel_image:setPosition(framesize.width/2,framesize.height - panel_image:getContentSize().height*0.5*0.7);
	self.target:addChild(panel_image,10000);
	panel_image:setScale(0.7);
	panel_image:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(2.5),cc.Hide:create(),cc.RemoveSelf:create()));

end

--onRecHashCode
function QukuailianBar:onRecHashCode(msg)
	luaPrint("QukuailianBar:onRecHashCode--123")
	local data = msg._usedata;
	local handCode = data:getHead(4);
	luaPrint("handCode:",handCode);


	local result = convertToLua(data,QukuailianMsg.CMD_GR_SEND_HASH);
	luaDump(result, "onRecHashCode---234", 5)

	if self.m_hashCode == result.HashResult then
		luaPrint("same hashcode :",result.HashResult);
		return;
	end

	self.m_hashCode = result.HashResult;
	--最新的hashCode缩略
	self.Text_hashCodeDot:setString(string.sub(self.m_hashCode,1,8).."...");
	--详细
	if self:isVisible() then
		--不显示 横条
		-- self:showNewHashCode(self.m_hashCode);
	end
	

	-- self.Text_hashCode:setString(self.m_hashCode);
	-- self.Button_copyCode.hashCode = self.m_hashCode;

	-- self.Panel_image:stopAllActions();

	-- self.Image_hashCode:setScale(0.1);
	-- panel_image:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(2.5),cc.Hide:create()));

end

function QukuailianBar:getRecordDataList()
	return self.m_recordDataList;
end

function QukuailianBar:onRecHashResult(msg)
	luaPrint("QukuailianBar:onRecHashResult--123")
	local data = msg._usedata;
	local handCode = data:getHead(4);
	

	local result = convertToLua(data,QukuailianMsg.config[self.m_gameType]);
	luaDump(result, "onRecHashResult---234", 5)

	table.insert(self.m_recordDataList,1,result);

	if table.nums(self.m_recordDataList) > 5 then
		local num = table.nums(self.m_recordDataList);
		for i=num,6,-1 do
			table.remove(self.m_recordDataList,i);
		end
	end

	-- self.m_hashCode = result.HashResult;
	-- --最新的hashCode缩略
	-- self.Text_hashCodeDot:setString(string.sub(self.m_hashCode,1,8).."...");
	-- --详细
	-- self.Text_hashCode:setString(self.m_hashCode);
	-- self.Button_copyCode.hashCode = self.m_hashCode;

	-- if handCode == 0 then --最新的弹出
	-- 	-- self.Image_hashCode:setVisible(true);
	-- 	self.Image_hashCode:stopAllActions();
	-- 	self.Image_hashCode:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(3.0),cc.Hide:create()));
	-- elseif handCode == 1 then --历史记录
	-- 	self.Image_hashCode:setVisible(false);

	-- end

	-- if self.m_gameType == "saoleihongbao" then
	-- 	local result = convertToLua(data,QukuailianMsg.config[self.m_gameType]);
	-- 	luaDump(result, "onRecHashCode---234", 5)

	-- 	table.insert(self.m_recordDataList,result);
	-- 	if table.nums(self.m_recordDataList) > 5 then
	-- 		table.remove(self.m_recordDataList,1);
	-- 	end

	-- 	self.m_hashCode = result.HashResult;
	-- 	--最新的hashCode
	-- 	self.Text_hashCodeDot:setString(string.sub(self.m_hashCode,1,8).."...");

			
	-- 	if table.nums(self.m_recordDataList) == 5 then
	-- 		luaDump(self.m_recordDataList, "self.m_recordDataList", 6)

	-- 		self.m_hashCode = self.m_recordDataList[5].HashResult;
	-- 		--最新的hashCode
	-- 		self.Text_hashCodeDot:setString(string.sub(self.m_hashCode,1,8).."...");
	-- 	end
	-- end





end

--按钮响应
function QukuailianBar:onBtnClickEvent(sender)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if "Button_verify" == btnName then --打开详细验证码
    	local FineLayer = require("qukuailian.QukuailianLayer");
    	local finePop = FineLayer:create(self,self.m_gameType,self.m_recordDataList);
    	finePop:ignoreAnchorPointForPosition(false);
		finePop:setAnchorPoint(cc.p(0.5,0.5));
    	
    	local size = self:getParent():getContentSize();
    	local size2 = self.target:getContentSize();
    	local framesize = cc.Director:getInstance():getWinSize()
    	finePop:setPosition(framesize.width/2,framesize.height/2);
    	self.target:addChild(finePop,9999);
    elseif "Button_copy"== btnName then --复制缩略验证码
   		copyToClipBoard(tostring(self.m_hashCode));
		addScrollMessage("复制成功");

    elseif "Button_copyCode"== btnName then --复制详细验证码
		copyToClipBoard(tostring(self.m_hashCode));
		addScrollMessage("复制成功");        	
    end


end


return QukuailianBar;