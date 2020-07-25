local EndLayer = class("EndLayer", PopLayer)

function EndLayer:create(tableLayer)
	return EndLayer.new(tableLayer);
end

function EndLayer:ctor(tableLayer)
	self.super.ctor(self,PopType.none)
	--self:removeAllChildren();
	self.tableLayer = tableLayer;
	self:setName("EndLayer");

	self:initData();

	self:initUI();

end

function EndLayer:initData()
end

function EndLayer:initUI()

	local size = self:getContentSize();
	
	self.Button_jixu = ccui.Button:create("bg/ernn_jixuyouxi.png","bg/ernn_jixuyouxi-on.png","bg/ernn_jixuyouxi-on.png");
	self.Button_jixu:setPosition(cc.p(size.width/2-200,size.height/2-80));
	self:addChild(self.Button_jixu);

	self.Button_end = ccui.Button:create("bg/ernn_likaifangjian.png","bg/ernn_likaifangjian-on.png","bg/ernn_likaifangjian-on.png");
	self.Button_end:setPosition(cc.p(size.width/2+200,size.height/2-80));
	self:addChild(self.Button_end);

	if self.Button_jixu then
		self.Button_jixu:onClick(function(sender)
			self:onClick_jixu();
		end)
	end

	if self.Button_end then
		self.Button_end:onClick(function(sender)
			self:ExitGame();
		end)
	end

	-- local n_time = 5
	-- local seq1 = cc.CallFunc:create(function ( ... )
	-- 	n_time = n_time - 1;
	-- 	if n_time == 0 then
	-- 		self:ExitGame();
	-- 	end
	-- end);
	-- self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1.0),seq1)));
end


function EndLayer:onClick_jixu()
	luaPrint("onClick_jixu");
	self:stopAllActions();
	self.tableLayer.tableLogic:sendMsgReady();
	self:removeFromParent();
end

function EndLayer:ExitGame()
	luaPrint("ExitGame");
	self:stopAllActions();
	self.tableLayer:onClickExitGameCallBack();
end

return EndLayer
