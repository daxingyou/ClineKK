

local VipgudongSetLayer = class("VipgudongSetLayer", PopLayer)


--创建类
function VipgudongSetLayer:create(data,GuildID,gudongID)

	local layer = VipgudongSetLayer.new(data,GuildID,gudongID);

	return layer;
end

--构造函数
function VipgudongSetLayer:ctor(data,GuildID,gudongID)
	self.super.ctor(self,PopType.middle)
	self.data = data;
	self.GuildID = GuildID;
	self.gudongID = gudongID
	self:initData();

	self:initUI()
	self:bindEvent()
	--loadNewCsb(self,"hehuoren/setTime",uiTable)
end

function VipgudongSetLayer:bindEvent()
	self:pushEventInfo(VipInfo,"changeUserNodeInfo",handler(self, self.receiveChangeUserNodeInfo))
end

--//修改备注
function VipgudongSetLayer:receiveChangeUserNodeInfo(data)
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
function VipgudongSetLayer:onEnter()
	--self:initUI()

	--self:bindEvent();--绑定消息
	self.super.onEnter(self);
end

function VipgudongSetLayer:initData()
	
end

function VipgudongSetLayer:initUI()
	
	self.sureBtn:removeSelf()
	-- self.size = self.bg:getContentSize()

	local title = ccui.ImageView:create("newExtend/vip/gudong/gudongshezhi-biaoti.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	
	
	local sprite = ccui.ImageView:create("newExtend/vip/gudong/tuijianzhancheng.png");
	sprite:setPosition(self.size.width*0.25,self.size.height*0.7);
	self.bg:addChild(sprite);

	local name = ccui.ImageView:create("newExtend/vip/gudong/zhenshixingming.png");
	name:setPosition(self.size.width*0.31,self.size.height*0.7);
	self.bg:addChild(name);

	self.biliEdit = createEditBox(name,"请输入占成比例",cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.biliEdit:setMaxLength(15);


	local sprite = ccui.ImageView:create("newExtend/vip/gudong/baifen.png");
	sprite:setPosition(self.size.width*0.72,self.size.height*0.7);
	self.bg:addChild(sprite);

	--推广人数
	local tuijianrenshu = ccui.ImageView:create("newExtend/vip/gudong/tuijianrenshu.png");
	tuijianrenshu:setPosition(self.size.width*0.25,self.size.height*0.55);
	self.bg:addChild(tuijianrenshu);
	self.tuijianrenshu = tuijianrenshu;
	self.tuijianrenshu:setVisible(false)

	self.renshuText = FontConfig.createWithSystemFont(self.data.iCommendCount, 30,cc.c3b(250, 200, 3));
	self.bg:addChild(self.renshuText);
	self.renshuText:setPosition(self.size.width*0.4,self.size.height*0.55);
	self.renshuText:setVisible(false)

	
	local spriteZhu = ccui.ImageView:create("newExtend/vip/gudong/zhu.png");
	spriteZhu:setPosition(self.size.width*0.5,self.size.height*0.1+12);
	self.bg:addChild(spriteZhu);

 	local renshu = FontConfig.createWithSystemFont(self.data.iNeedCount, 20,cc.c3b(193, 210, 246));
	spriteZhu:addChild(renshu);
	renshu:setPosition(315,10);

	local sureBtn = ccui.Button:create("newExtend/vip/gudong/baocun.png","newExtend/vip/gudong/baocun-on.png");
	sureBtn:setPosition(self.size.width/2+200,self.size.height*0.3);
	self.bg:addChild(sureBtn);
	sureBtn:setTag(0)
	sureBtn:onClick(function ()
		luaPrint("确定");
		self:sureCallBack(0);
	end);
	self.sureBtn = sureBtn;

	local CancelBtn = ccui.Button:create("newExtend/vip/gudong/chexiaogudong.png","newExtend/vip/gudong/chexiaogudong-on.png");
	CancelBtn:setPosition(self.size.width/2-200,self.size.height*0.3);
	self.bg:addChild(CancelBtn);
	CancelBtn:setVisible(false)
	CancelBtn:setTag(1)
	CancelBtn:onClick(function ()
		luaPrint("撤销股东");
		self:sureCallBack(1);
	end);
	self.CancelBtn = CancelBtn;

	if self.data.iMemberType == 2 then  --//成员类型 0 普通成员 2 股东
		self.biliEdit:setText(self.data.iCommendRate/10)
		self.tuijianrenshu:setVisible(true)
		self.renshuText:setVisible(true)
		self.CancelBtn:setVisible(true)
		self.sureBtn:setPositionX(self.size.width/2+200)
		if self.data.iCommendCount >=self.data.iNeedCount then
			self.CancelBtn:setVisible(false)
			self.sureBtn:setPositionX(self.size.width/2)
		end
	else
		self.sureBtn:setPositionX(self.size.width/2)
	end

end

--确定按钮
function VipgudongSetLayer:sureCallBack(itype)
	
	local number = self.biliEdit:getText();
	
	-- VipInfo:sendChangeUserNode(self.GuildID,self.data.UserID,nameStr,number)
	local num = tonumber(number)
	local len = string.len(number)
	if num == nil or num<=0  or num > 100 or len>4 or (len == 4 and num<10) then
		addScrollMessage("请输入正确占成比例")
		return;
	end

	VipInfo:sendGuildHolderSet(self.GuildID,self.gudongID,itype,num*10)
end

function VipgudongSetLayer:setUserNodeInfoCallback(callback)
	self.callback = callback;
end

--按钮回调
function VipgudongSetLayer:btnClick(sender)

	local tag = sender:getTag();
	
	self:updata(tag);
	
end

function VipgudongSetLayer:updataLayer(data)

	if data.opType == 0 then  --0 设置 1 撤销
		addScrollMessage("设置成功")
		self.tuijianrenshu:setVisible(true)
		self.renshuText:setVisible(true)
		self.CancelBtn:setVisible(true)
		self.sureBtn:setPositionX(self.size.width/2+200)
		if self.data.iCommendCount >=self.data.iNeedCount then
			self.CancelBtn:setVisible(false)
			self.sureBtn:setPositionX(self.size.width/2)
		end
	else
		addScrollMessage("撤销成功")
		self.biliEdit:setText("")
		self.tuijianrenshu:setVisible(false)
		self.renshuText:setVisible(false)
		self.CancelBtn:setVisible(false)
		self.sureBtn:setPositionX(self.size.width/2)
	end
	
end


return VipgudongSetLayer;