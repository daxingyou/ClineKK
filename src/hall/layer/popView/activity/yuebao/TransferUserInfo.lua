local TransferUserInfo = class("TransferUserInfo",PopLayer)

function TransferUserInfo:create(phoneNumber,zhuanzhangMoney,data)
    return TransferUserInfo.new(phoneNumber,zhuanzhangMoney,data);
end

function TransferUserInfo:ctor(phoneNumber,zhuanzhangMoney,data)
    self.super.ctor(self, PopType.middle)

    luaPrint("TransferUserInfo",phoneNumber,zhuanzhangMoney);
    self.phoneNumber = phoneNumber;
    self.zhuanzhangMoney = zhuanzhangMoney;
    self.data = data;

    self.TextColor = cc.c3b(255, 255, 255);

    self:initUI();
    self:bindEvent();
end

function TransferUserInfo:initUI()
	self.sureBtn:removeSelf()
	local size = self.bg:getContentSize();

	local title = ccui.ImageView:create("activity/yuebao/title_wenxintishi.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local headbg = ccui.ImageView:create("activity/yuebao/kuang.png");
	self.bg:addChild(headbg);
	headbg:setPosition(size.width*0.5,size.height*0.6+50);

	local head = ccui.ImageView:create("activity/yuebao/touxiangkuang.png");
	headbg:addChild(head);
	head:setPosition(headbg:getContentSize().width*0.2,headbg:getContentSize().height*0.5);
	head:loadTexture(getHeadPath(self.data.LogoID));

	local userName = FontConfig.createWithSystemFont("昵称:"..self.data.NickName, 40,self.TextColor);
	userName:setPosition(headbg:getContentSize().width*0.6,headbg:getContentSize().height*0.7);
	headbg:addChild(userName);

	local userId = FontConfig.createWithSystemFont("ID:"..self.data.UserID, 40,self.TextColor);
	userId:setPosition(headbg:getContentSize().width*0.6,headbg:getContentSize().height*0.3);
	headbg:addChild(userId);

	local text = FontConfig.createWithSystemFont("转账金额:", 40,self.TextColor);
	text:setPosition(self.bg:getContentSize().width*0.4,self.bg:getContentSize().height*0.4+30);
	self.bg:addChild(text)

	local scoreText = FontConfig.createWithSystemFont(goldConvertFour(self.zhuanzhangMoney,1), 40,self.TextColor);
	scoreText:setPosition(self.bg:getContentSize().width*0.6,self.bg:getContentSize().height*0.4+30);
	self.bg:addChild(scoreText)

	local againButton = ccui.Button:create("activity/yuebao/chongxinshuru.png","activity/yuebao/chongxinshuru-on.png");
	self.bg:addChild(againButton);
	againButton:setPosition(self.bg:getContentSize().width*0.5-200,self.bg:getContentSize().height*0.25);
	againButton:setTag(1);
	againButton:onClick(function (sender)
		self:buttonClick(sender);
	end);

	local sureButton = ccui.Button:create("activity/yuebao/querenzhuanzhang.png","activity/yuebao/querenzhuanzhang-on.png");
    self.bg:addChild(sureButton);
    sureButton:setTag(2);
    sureButton:setPosition(self.bg:getContentSize().width*0.5+200,self.bg:getContentSize().height*0.25);
    sureButton:onClick(function (sender)
		self:buttonClick(sender);
	end);

end

function TransferUserInfo:bindEvent()
    self:pushEventInfo(YuEBaoInfo,"TransferScore",handler(self, self.receiveTransferScore))
end

function TransferUserInfo:receiveTransferScore()
	self:removeSelf();
end

function TransferUserInfo:buttonClick(sender)
	local tag = sender:getTag();
	if tag == 1 then
		self:removeSelf();
	else
		YuEBaoInfo:onTransferMoney(self.phoneNumber,self.zhuanzhangMoney,globalUnit:getBankPwd())
	end
end

return TransferUserInfo;