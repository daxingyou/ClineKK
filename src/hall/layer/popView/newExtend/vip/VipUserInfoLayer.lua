

local VipUserInfoLayer = class("VipUserInfoLayer", PopLayer)


--创建类
function VipUserInfoLayer:create(data,GuildID)

	local layer = VipUserInfoLayer.new(data,GuildID);

	return layer;
end

--构造函数
function VipUserInfoLayer:ctor(data,GuildID)
	self.super.ctor(self,PopType.small)
	self.data = data;
	self.GuildID = GuildID
	self:initData();

	self:initUI()
	self:bindEvent()
	--loadNewCsb(self,"hehuoren/setTime",uiTable)
end

function VipUserInfoLayer:bindEvent()
	self:pushEventInfo(VipInfo,"changeUserNodeInfo",handler(self, self.receiveChangeUserNodeInfo))
end

--//修改备注
function VipUserInfoLayer:receiveChangeUserNodeInfo(data)
    local data = data._usedata;
    local code = data[1]

    if code == 0 then--
    	if self.callback then
    		self.callback(self.NoteName,self.NotePhone)
    		self:removeSelf();
    	end
    else

    end
    
end

--进入
function VipUserInfoLayer:onEnter()
	--self:initUI()

	--self:bindEvent();--绑定消息
	self.super.onEnter(self);
end

function VipUserInfoLayer:initData()
	
end

function VipUserInfoLayer:initUI()
	self:setName("VipUserInfoLayer");
	self.sureBtn:removeSelf()

	local title = ccui.ImageView:create("newExtend/vip/management/beizhubiaoti.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	-- iphoneXFit(self.bg,1)
	
	local sprite = ccui.ImageView:create("newExtend/vip/management/nichen.png");
	sprite:setPosition(self.size.width*0.1,self.size.height*0.8-15);
	self.bg:addChild(sprite);

	self.nameText = FontConfig.createWithSystemFont(FormotGameNickName(self.data.NickName,6), 30,cc.c3b(250, 200, 3));
	self.bg:addChild(self.nameText);
	self.nameText:setPosition(self.size.width*0.3,self.size.height*0.8-15);

	local sprite = ccui.ImageView:create("newExtend/vip/management/id.png");
	sprite:setPosition(self.size.width*0.6,self.size.height*0.8-15);
	self.bg:addChild(sprite);

	self.idText = FontConfig.createWithSystemFont(self.data.UserID, 30,cc.c3b(250, 200, 3));
	self.bg:addChild(self.idText);
	self.idText:setPosition(self.size.width*0.73,self.size.height*0.8-15);

	local name = ccui.ImageView:create("newExtend/vip/management/zhenshixingming.png");
	name:setPosition(self.size.width*0.25,self.size.height*0.6);
	self.bg:addChild(name);

	self.nameEdit = createEditBox(name,"请输入名字",cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.nameEdit:setMaxLength(15);

	if self.data.NoteName ~= "" then
		self.nameEdit:setText(self.data.NoteName)
	end

	local phone = ccui.ImageView:create("newExtend/vip/management/lianxishouji.png");
	phone:setPosition(self.size.width*0.25,self.size.height*0.4);
	self.bg:addChild(phone);

	self.phoneEdit = createEditBox(phone,"请输入手机号码",cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	self.phoneEdit:setMaxLength(15);
	if self.data.NotePhone ~= "" then
		self.phoneEdit:setText(self.data.NotePhone)
	end

	local sureBtn = ccui.Button:create("common/ok.png","common/ok-on.png");
	sureBtn:setPosition(self.size.width/2,self.size.height*0.2);
	self.bg:addChild(sureBtn);
	sureBtn:onClick(function ()
		luaPrint("确定");
		self:sureCallBack();
	end);

end

--确定按钮
function VipUserInfoLayer:sureCallBack()
	local nameStr = self.nameEdit:getText();
	local number = self.phoneEdit:getText();
	-- if nameStr == "" and tonumber(number) == nil then
	-- 	if nameStr == nil or nameStr == "" then
	-- 		addScrollMessage("请输入正确的名字！");
	-- 		return;
	-- 	end

	-- 	if tonumber(number) == nil then
	-- 		addScrollMessage("请输入正确的手机号码！");
	-- 		return 
	-- 	end
	-- end
	self.NoteName = nameStr;
	self.NotePhone = number;
	VipInfo:sendChangeUserNode(self.GuildID,self.data.UserID,nameStr,number)
	luaPrint("sureCallBack",nameStr,number);
end

function VipUserInfoLayer:setUserNodeInfoCallback(callback)
	self.callback = callback;
end
--按钮回调
function VipUserInfoLayer:btnClick(sender)

	local tag = sender:getTag();
	
	self:updata(tag);
	
end


return VipUserInfoLayer;