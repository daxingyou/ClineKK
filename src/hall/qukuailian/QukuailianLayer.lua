-- local QklConfig = require("qukuailian.Config")

local QukuailianLayer = class("QukuailianLayer", BaseWindow)

function QukuailianLayer:ctor(_bar,_gameType,_recordList)
	-- self.super.ctor(self,PopType.small)
	self.super.ctor(self, 0, true);
	self:bindEvent();

	self:initData(_bar,_gameType,_recordList);
	self:initUI();
	

	


end

function QukuailianLayer:create(_bar,_gameType,_recordList)
	local layer = QukuailianLayer.new(_bar,_gameType,_recordList);

	return layer;
end

function QukuailianLayer:bindEvent()
	-- self:pushEventInfo(SettlementInfo, "configInfo", handler(self, self.receiveConfigInfo))
end

function QukuailianLayer:initUI()
	local framesize = cc.Director:getInstance():getWinSize()
	self.Panel_root = ccui.Layout:create();
	self.Panel_root:setContentSize(cc.size(1280,720));
	self.Panel_root:setAnchorPoint(cc.p(0.5,0.5));
	self.Panel_root:setPosition(framesize.width/2,framesize.height/2);
	self:addChild(self.Panel_root);

	--背景图
	self.Image_bg = ccui.ImageView:create("hall/common/commonBg5.png",ccui.TextureResType.localType);
	self.Panel_root:addChild(self.Image_bg);
	self.Image_bg:setPosition(640,360);

	--底图
	local imgBg = ccui.ImageView:create("qukuailian/image2/qklian_dikuang.png");
	self.Panel_root:addChild(imgBg);
	imgBg:setPosition(743,338);

	--标题
	local title = ccui.ImageView:create("qukuailian/image2/qklian_jianyanzhushou.png",ccui.TextureResType.localType);
	self.Panel_root:addChild(title);
	title:setPosition(640,650);

	--历史记录按钮
	self.Button_record = ccui.Button:create("qukuailian/image2/qklian_fangjianlishijilu1.png","qukuailian/image2/qklian_fangjianlishijilu1-on.png","qukuailian/image2/qklian_fangjianlishijilu.png",ccui.TextureResType.localType);
	self.Panel_root:addChild(self.Button_record);
	self.Button_record:setPosition(cc.p(166,535));

	--验证按钮
	self.Button_verify = ccui.Button:create("qukuailian/image2/qklian_disanfangyanzheng1.png","qukuailian/image2/qklian_disanfangyanzheng1-on.png","qukuailian/image2/qklian_disanfangyanzheng.png",ccui.TextureResType.localType);
	self.Panel_root:addChild(self.Button_verify);
	self.Button_verify:setPosition(cc.p(166,438));
	
	

	--历史记录面板
	self.Panel_record = ccui.Layout:create();
	self.Panel_record:setContentSize(cc.size(906,525));
	self.Panel_record:setPosition(cc.p(292,72));
	self.Panel_root:addChild(self.Panel_record);

	--最近五局提示
	local title5 = ccui.ImageView:create("qukuailian/image2/qklian_zuixin.png",ccui.TextureResType.localType);
	self.Panel_record:addChild(title5);
	title5:setPosition(453,505);

	--scrollview record
	local ScrollView_record = ccui.ScrollView:create();
	ScrollView_record:setContentSize(cc.size(906,475));
	self.Panel_record:addChild(ScrollView_record);
	ScrollView_record:setPosition(cc.p(0,475+5));
	ScrollView_record:setInnerContainerSize(cc.size(906,475));
	ScrollView_record:setAnchorPoint(cc.p(0,1));
	ScrollView_record:setBounceEnabled(true);
	ScrollView_record:setInertiaScrollEnabled(true);
	
	self.ScrollView_record = ScrollView_record;

	-- self.ScrollView_record:setBackGroundColorType(1)
	-- self.ScrollView_record:setBackGroundColor(cc.c3b(255,0,0));
	-- self.ScrollView_record:setBackGroundColorOpacity(255);

	--验证面板
	self.Panel_verify = ccui.Layout:create();
	self.Panel_verify:setContentSize(cc.size(906,515));
	self.Panel_verify:setPosition(cc.p(291,80));
	self.Panel_root:addChild(self.Panel_verify);

	--scrollview verify
	local ScrollView_verify = ccui.ScrollView:create();
	ScrollView_verify:setContentSize(cc.size(906,515));
	self.Panel_verify:addChild(ScrollView_verify);
	ScrollView_verify:setPosition(cc.p(0,515));
	ScrollView_verify:setInnerContainerSize(cc.size(906,935));
	ScrollView_verify:setAnchorPoint(cc.p(0,1));
	ScrollView_verify:setBounceEnabled(true);
	ScrollView_verify:setInertiaScrollEnabled(true);
	self.ScrollView_verify = ScrollView_verify;

	--验证滚动内容
	local panel = ccui.Layout:create();
	panel:setContentSize(cc.size(906,925-30));
	panel:setPosition(cc.p(0,0));
	self.ScrollView_verify:addChild(panel);

	local didth = 20;
	--1.粘贴验证码 获取验证地址
	local image_1 = ccui.ImageView:create("qukuailian/image2/qklian_1.png",ccui.TextureResType.localType);
	panel:addChild(image_1);
	image_1:setAnchorPoint(0,0.5);
	image_1:setPosition(cc.p(36-didth,871));
	--帮助
	local buttonHelp = ccui.Button:create("qukuailian/image2/qklian_bangzhu.png","qukuailian/image2/qklian_bangzhu-on.png","qukuailian/image2/qklian_bangzhu-on.png",ccui.TextureResType.localType);
	panel:addChild(buttonHelp);
	buttonHelp:setPosition(cc.p(446,873));
	self.Button_help = buttonHelp;

	--验证码背景图
	local image_2 = ccui.ImageView:create("qukuailian/image2/qklian_niantiekuang.png",ccui.TextureResType.localType);
	panel:addChild(image_2);
	image_2:setAnchorPoint(0,0.5);
	image_2:setPosition(cc.p(91-didth,801));
	--hash code text
	local text_hashCode = FontConfig.createWithSystemFont("",24,FontConfig.colorWhite,cc.size(600,60),"Arial",cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	panel:addChild(text_hashCode);
	text_hashCode:setPosition(cc.p(400,800));
	self.Text_hashCode = text_hashCode;

	--粘贴验证码
	local buttonPaste = ccui.Button:create("qukuailian/image2/qklian_niantie.png","qukuailian/image2/qklian_niantie-on.png","qukuailian/image2/qklian_niantie-on.png",ccui.TextureResType.localType);
	panel:addChild(buttonPaste);
	buttonPaste:setPosition(cc.p(831-didth,803));
	self.Button_paste = buttonPaste;

	--2.以太地址title
	local image_2 = ccui.ImageView:create("qukuailian/image2/qklian_2.png",ccui.TextureResType.localType);
	panel:addChild(image_2);
	image_2:setAnchorPoint(0,0.5);
	image_2:setPosition(cc.p(36-didth,730));
	--以太地址背景
	local imageAddr = ccui.ImageView:create("qukuailian/image2/qklian_lianjiedizhi.png",ccui.TextureResType.localType);
	panel:addChild(imageAddr);
	imageAddr:setAnchorPoint(0,0.5);
	imageAddr:setPosition(cc.p(91-didth,682));
	--hash code text
	local Text_ethernetUrl = FontConfig.createWithSystemFont("",24,FontConfig.colorWhite,cc.size(800,30),"Arial",cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER);
	panel:addChild(Text_ethernetUrl);
	Text_ethernetUrl:setPosition(cc.p(504-didth,682));
	self.Text_ethernetUrl = Text_ethernetUrl;
	--open addr
	local buttonOpen = ccui.Button:create("qukuailian/image2/qklian_dakai.png","qukuailian/image2/qklian_dakai-on.png","qukuailian/image2/qklian_dakai-on.png",ccui.TextureResType.localType);
	panel:addChild(buttonOpen);
	buttonOpen:setPosition(cc.p(306-didth,623));
	self.Button_open = buttonOpen;
	--copy addr
	local buttonCopy = ccui.Button:create("qukuailian/image2/qklian_fuzhi.png","qukuailian/image2/qklian_fuzhi-on.png","qukuailian/image2/qklian_fuzhi-on.png",ccui.TextureResType.localType);
	panel:addChild(buttonCopy);
	buttonCopy:setPosition(cc.p(603-didth,623));
	self.Button_copy = buttonCopy;

	--3.输入查看结果
	local image_3= ccui.ImageView:create("qukuailian/image2/qklian_3.png",ccui.TextureResType.localType);
	panel:addChild(image_3);
	image_3:setAnchorPoint(0,0.5);
	image_3:setPosition(cc.p(36-didth,556));
	--以太地址背景
	local imageHelp = ccui.ImageView:create("qukuailian/image2/qklian_shiyitu.png",ccui.TextureResType.localType);
	panel:addChild(imageHelp);
	imageHelp:setAnchorPoint(0.5,0);
	imageHelp:setScale(0.943);
	imageHelp:setPosition(cc.p(448,0));
	
    self.Button_verify:setEnabled(true);
	self.Button_record:setEnabled(false);

	self.Panel_verify:setVisible(false);
	self.Panel_record:setVisible(true);

	-- self.Panel_item:setVisible(false);
	-- self.Panel_brnn:setVisible(false);
    --返回按钮
	self.Panel_root:onClick(handler(self,self.onBtnClickEvent))
	self.Panel_root:setName("Panel_root");

	self.Button_record:onClick(handler(self,self.onBtnClickEvent))
	self.Button_record:setName("Button_record");

	self.Button_verify:onClick(handler(self,self.onBtnClickEvent))
	self.Button_verify:setName("Button_verify");

	local size = self.ScrollView_verify:getInnerContainerSize();
	-- luaDump(size, "ScrollView_verify---123", 5)

	self.Text_hashCode:setString("");
	self.Text_ethernetUrl:setString("");

	--验证
	self.Button_help:onClick(handler(self,self.onBtnClickEvent))
	self.Button_help:setName("Button_help");

	self.Button_paste:onClick(handler(self,self.onBtnClickEvent))
	self.Button_paste:setName("Button_paste");

	self.Button_open:onClick(handler(self,self.onBtnClickEvent))
	self.Button_open:setName("Button_open");

	self.Button_copy:onClick(handler(self,self.onBtnClickEvent))
	self.Button_copy:setName("Button_copy");


	self.Button_close = ccui.Button:create("common/close.png","common/close-on.png");
	self.Panel_root:addChild(self.Button_close);
	self.Button_close:setPosition(1250,648)
	self.Button_close:onTouchClick(handler(self,self.onBtnClickEvent),1);
	self.Button_close:setName("Button_close");


	--hashcode item
	local panelItem = ccui.Layout:create();
	panelItem:setContentSize(cc.size(910,123));
	panelItem:setPosition(cc.p(6,10));
	self.Panel_root:addChild(panelItem);
	

	local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao1.png",ccui.TextureResType.localType);
	panelItem:addChild(imageBack);
	imageBack:setPosition(cc.p(455,61.5));
	imageBack:setName("Image_back");

	local imageExpand = ccui.ImageView:create("qukuailian/image2/qklian_jianhao.png",ccui.TextureResType.localType); --qklian_jiahao
	panelItem:addChild(imageExpand);
	imageExpand:setPosition(cc.p(45,100));
	imageExpand:setName("Image_expand");

	local imageShrink = ccui.ImageView:create("qukuailian/image2/qklian_jiahao.png",ccui.TextureResType.localType); --qklian_jianhao
	panelItem:addChild(imageShrink);
	imageShrink:setPosition(cc.p(45,100));
	imageShrink:setName("Image_shrink");
	--第几场tip
	local textTip = ccui.Text:create();
	panelItem:addChild(textTip);
	textTip:setFontSize(20);
	textTip:setAnchorPoint(cc.p(1,0.5));
	textTip:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT);
	textTip:setPosition(cc.p(810,102));
	textTip:setName("Text_tip");
	--验证码
	local textCode = ccui.Text:create();
	textCode:ignoreContentAdaptWithSize(false);
	textCode:setFontSize(24);
	textCode:setTextAreaSize(cc.size(616,48))
	panelItem:addChild(textCode);
	textCode:setPosition(cc.p(384,53));
	textCode:setName("Text_code");

	local buttonCopy = ccui.Button:create("qukuailian/image2/qklian_fuzhi.png","qukuailian/image2/qklian_fuzhi-on.png","qukuailian/image2/qklian_fuzhi-on.png",ccui.TextureResType.localType);
	panelItem:addChild(buttonCopy);
	buttonCopy:setPosition(cc.p(781,48));
	buttonCopy:setName("Button_copyit");

	panelItem:setVisible(false);
	self.Panel_item = panelItem;

	-- self.Button_test1 = ccui.Button:create("qukuailian/image2/qklian_hong.png");
	-- self.Panel_root:addChild(self.Button_test1);
	-- self.Button_test1:setPosition(127,292)

	-- self.Button_test2 = ccui.Button:create("qukuailian/image2/qklian_hu.png");
	-- self.Panel_root:addChild(self.Button_test2);
	-- self.Button_test2:setPosition(127,167)

	-- self.Button_test1:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	-- self.Button_test1:setName("Button_test1");

	-- self.Button_test2:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	-- self.Button_test2:setName("Button_test2");

	-- self.ScrollView_record:addEventListener (function(sender, touchEvent) self:onCCSEventListener(sender, touchEvent); end)
	self:initList();
end


function QukuailianLayer:initData(_bar,_gameType,_recordList)
	self.m_bar = _bar;
	self.m_gameType = _gameType;
	self.m_recordList = {}  --
	self.m_recordDataList = _recordList; --

	self.m_hashCodeUrl = ""; --当前显示以太网网址
	self.m_hashCode = "";   --当前公正码

	-- luaDump(QklConfig, "QklConfig", 4)
	-- luaDump(_gameType, "_gameType", 4)
	self.GameItem = require(QukuailianMsg.path[_gameType]);

	self:pushGlobalEventInfo("QUKUAILIAN_HASHCODE",handler(self, self.onRecHashCode));
	self:pushGlobalEventInfo("pasteString",handler(self, self.onRecPasteHashCode));
end


function QukuailianLayer:refreshRecord()
	self.m_recordList = {};
	self.m_recordDataList = {};
	self.ScrollView_record:removeAllChildren();
	  --
	self.m_recordDataList = self.m_bar:getRecordDataList(); --
	luaDump(self.m_recordDataList, "self.m_recordDataList_abcdefg", 5);
	self:initList();
end

--进入
function QukuailianLayer:onEnter()
    self.super.onEnter(self);
    globalUnit.isHashCodeMode = true;
end


--退出
function QukuailianLayer:onExit()
	self.super.onExit(self);
	globalUnit.isHashCodeMode = false;
end




function QukuailianLayer:updateRecordListPos()
	local didth = 10;
	local size1 = self.ScrollView_record:getContentSize();
	local num = table.nums(self.m_recordList);
	local length = 0
	local size2 = self.Panel_item:getContentSize();

	for i,v in ipairs(self.m_recordList) do
		local size = v:getContentSize();
		length = length + size.height;
	end

	if length < size1.height then
		length = size1.height;
	end

	self.ScrollView_record:setInnerContainerSize(cc.size(size2.width+5,length+10));
	local lastPosY = 0;
	for i,v in ipairs(self.m_recordList) do
		local size = v:getContentSize();
		local height = size.height;
		v:setAnchorPoint(cc.p(0,1));

		v:setPosition(0,length - lastPosY+10);
		lastPosY = height + lastPosY;
		v:setVisible(true);
		v:setTouchEnabled(true);
	end
end




function QukuailianLayer:updateScrollView(index)
	local size1 = self.ScrollView_record:getInnerContainerSize();
	local height2 = 0;
	for i,v in ipairs(self.m_recordList) do
		local size = v:getContentSize();
		height2 = height2 + size.height;
	end

	local lastPos = self.ScrollView_record:getInnerContainerPosition();
	local newPos = cc.p(lastPos.x,lastPos.y - height2 + size1.height);
	self.ScrollView_record:setInnerContainerSize(cc.size(size1.width,height2))
	self.ScrollView_record:setInnerContainerPosition(newPos);

	self:updateRecordListPos();
	self.ScrollView_record:setBounceEnabled(false);


end



function QukuailianLayer:getItemIndex(itemId)
	for i,v in ipairs(self.m_recordList) do
		if v.itemId == itemId then
			return i
		end
	end

	return 1;
end


function QukuailianLayer:initList()
	local size = self.Panel_item:getContentSize();
	-- local didth = 10;
	-- local height = size.height*5 + didth*4;
	-- self.ScrollView_record:setInnerContainerSize(cc.size(size.width,height));

	-- self.m_recordDataList;
	-- luaDump(self.m_recordDataList,"self.m_recordDataList111111111111")
	for i,v in ipairs(self.m_recordDataList) do
		-- luaDump(v, "data-hash", 5)
		local item = self.Panel_item:clone();
		self.ScrollView_record:addChild(item);
		item:setVisible(true);
		item:setAnchorPoint(cc.p(0,1));
		-- item:setPosition(cc.p(43,height-(i-1)*size.height-didth*(i-1)));
		-- item:setTag(i);

		item.itemId = i;
		item.result = v;

		local children = item:getChildren();
		local textTip = item:getChildByName("Text_tip");
		textTip:setTextColor(cc.c3b(111,65,32))
		if i == 1 then
			textTip:setString("最新1局公正码");
		else
			textTip:setString("第"..i.."局公正码");
		end
		table.insert(self.m_recordList,item);


		local labelCode = cc.Label:createWithSystemFont("","Arial", 24,cc.size(616,50),cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER);    
		labelCode:setString(QukuailianMsg.hashCode2Line(v.HashResult));
		--labelCode:setString(i.."(da3c9beee6bcf96fe7c12bb93bfde72742b139bea1599643b4034f88ca12b152");
		-- labelCode:setLineBreakWithoutSpace(true);
		item:addChild(labelCode);
		labelCode:setPosition(cc.p(383,53));

		local imgShrink = item:getChildByName("Image_shrink"); --收起
		local imgExpand = item:getChildByName("Image_expand"); --展开
		imgShrink:setVisible(true);
		imgExpand:setVisible(false);

		local btnCopy =  item:getChildByName("Button_copyit");--
		btnCopy.hashCode = v.HashResult; --当前轮数hashcode
		btnCopy:onClick(function(sender)			    	
		    	addScrollMessage("复制成功");
		    	self.m_hashCode = sender.hashCode;
		    	copyToClipBoard(self.m_hashCode);
		    	--pasteFromClipBoard();
		end);


		item:setTouchEnabled(true);
		--展开第一项
		if i == 1 then
			item:getChildByName("Image_shrink"):setVisible(false); --减号
			item:getChildByName("Image_expand"):setVisible(true);	--加号
			--游戏结果展开面板
    		local detailItem = self.GameItem:create(item.result);			    		
	    	detailItem:setAnchorPoint(cc.p(0,1));
	    	detailItem:setVisible(true);
	    	self.ScrollView_record:addChild(detailItem);
	    	detailItem.itemId = item.itemId;

	    	local index = self:getItemIndex(item.itemId);
	    	table.insert(self.m_recordList,index+1,detailItem);
	    	-- self:updateScrollView(index);	
		end

		item:onClick(function(sender)

		    	if item:getChildByName("Image_shrink"):isVisible() then
		    		item:getChildByName("Image_shrink"):setVisible(false); --减号
		    		item:getChildByName("Image_expand"):setVisible(true);	--加号

		    		--游戏结果展开面板
		    		local detailItem = self.GameItem:create(sender.result);			    		
			    	detailItem:setAnchorPoint(cc.p(0,1));
			    	detailItem:setVisible(true);
			    	self.ScrollView_record:addChild(detailItem);
			    	detailItem.itemId = sender.itemId;

			    	local index = self:getItemIndex(sender.itemId);
			    	table.insert(self.m_recordList,index+1,detailItem);
			    	self:updateScrollView(index);

		    	else
		    		item:getChildByName("Image_shrink"):setVisible(true);
		    		item:getChildByName("Image_expand"):setVisible(false);

		    		local index = self:getItemIndex(sender.itemId);
		    		local itemId = sender.itemId;

		    		if table.nums(self.m_recordList) > index then
		    			local detailItem = self.m_recordList[index+1];
		    			if detailItem.itemId == itemId then
		    				table.remove(self.m_recordList,index+1);
		    				detailItem:removeSelf();
		    			end
		    		end

		    		self:updateScrollView(index);
		    	end
				
			end);

	end
	self:updateRecordListPos();

end

--接收到网络url数据
function QukuailianLayer:onRecHashCode(msg)
	local data = msg._usedata;
	local handCode = data:getHead(4);
	-- luaPrint("QukuailianLayer_handcode234:",handCode);
	local msg2 = convertToLua(data,QukuailianMsg.CMD_S_HTTPURL);
	-- luaDump(msg2, "QukuailianLayer_onRecHashCode123", 4)

	--设置 以太网地址
	self.m_hashCodeUrl = msg2.URL;
	self.Text_ethernetUrl:setText(QukuailianMsg.hashCode2Part(tostring(self.m_hashCodeUrl)));
end


--接收到 粘帖板消息
function QukuailianLayer:onRecPasteHashCode(msg)
	local strCode = msg._usedata;
	if string.len(strCode) ~= 64 then
		addScrollMessage("公正码错误！")	
	end

	-- luaPrint("QukuailianLayer_onRecPasteHashCode567:",strCode);
	local strCode2 = QukuailianMsg.hashCode2Line(strCode);
	-- luaPrint("QukuailianLayer_onRecPasteHashCode2Line:",strCode2)
	self.Text_hashCode:setString(strCode2);

	local msg = {};
	msg.szMessage = strCode;
	RoomLogic:send(RoomMsg.MDM_GR_ROOM, QukuailianMsg.ASS_GR_GET_HASH, msg, QukuailianMsg.MSG_GR_HASH);

end

function QukuailianLayer:hashCode2(_hashCode)
	local len = string.len(_hashCode)
	local str1 = string.sub(_hashCode,1,40);
	local str2 = string.sub(_hashCode,41,len);
	local str = str1.."\n"..str2;
	return str;
end

--按钮响应
function QukuailianLayer:onBtnClickEvent(sender)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if "Button_record" == btnName then --返回
    	self.Button_verify:setEnabled(true);
    	self.Button_record:setEnabled(false);


    	self.Panel_verify:setVisible(false);
    	self.Panel_record:setVisible(true);

    	self:refreshRecord()
    elseif "Button_verify" == btnName then --返回
    	self.Button_verify:setEnabled(false);
    	self.Button_record:setEnabled(true);

    	self.Panel_verify:setVisible(true);
    	self.Panel_record:setVisible(false);
    elseif "Button_test1"== btnName then --返回
    	-- self:test1();
    elseif "Button_test2"== btnName then 



    elseif "Button_help"== btnName then --帮助
    	local help = require("qukuailian.QukuailianHelp")
    	local layer = help:create();
    	self:addChild(layer);
    elseif "Button_paste"== btnName then --粘贴
    	if device.platform == "windows" then
    		local strCode2 = QukuailianMsg.hashCode2Line(self.m_hashCode);
			self.Text_hashCode:setString(strCode2);

			local msg = {};
			msg.szMessage = self.m_hashCode;
			RoomLogic:send(RoomMsg.MDM_GR_ROOM, QukuailianMsg.ASS_GR_GET_HASH, msg, QukuailianMsg.MSG_GR_HASH);

    	else
    		pasteFromClipBoard();	
    	end
    	
--      	self.Text_hashCode:setString(self.m_hashCode);
--      	self.Text_ethernetUrl:setString(self.m_hashCode.."_ethernetAdd");


    	-- local msg = {};
    	-- msg.szMessage = "055d13bbb66d3a0302dbf5c5589fb7abfd8ea813b48743134dbeef589613b15b";
		-- msg.szMessage = "da3c9beee6bcf96fe7c12bb93bfde72742b139bea1599643b4034f88ca12b152";
		-- RoomLogic:send(RoomMsg.MDM_GR_ROOM, QukuailianMsg.ASS_GR_GET_HASH, msg, QukuailianMsg.MSG_GR_HASH);
		-- luaPrint("ASS_GR_HASH--123");


    elseif "Button_open"== btnName then --打开网址
    	-- self.m_hashCodeUrl = "http://www.baidu.com";
    	if not isEmptyString(self.m_hashCodeUrl) then
    		local hashCodeUrl = self.m_hashCodeUrl;
    		if not string.find(hashCodeUrl,"index1") then --找不到index1:简洁版 区块链查询，index:完整版区块链查询
    			
		    	hashCodeUrl = string.gsub (hashCodeUrl, "index", "index1");
		    	
    		end
    		

	        local WebView = require("qukuailian.QukuailianWeb");
	        local web = WebView:create(hashCodeUrl);
	        self:addChild(web);
	    end
    elseif "Button_copy"== btnName then --复制以太网网址
    	
    	if string.find(self.m_hashCodeUrl,"index1") then
    		self.m_hashCodeUrl = string.gsub (self.m_hashCodeUrl, "index1", "index");
    	end
    	

    	copyToClipBoard(tostring(self.m_hashCodeUrl));
		addScrollMessage("复制成功")

    elseif "Button_close"== btnName then --关闭
    	self:removeSelf();
    end


end




return QukuailianLayer
