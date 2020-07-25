--托管

local EndLayer = class("TrustLayer", PopLayer)

function EndLayer:create(tableLayer)
	return EndLayer.new(tableLayer);
end

function EndLayer:ctor(tableLayer)
	self.super.ctor(self,PopType.none)
	self:removeAllChildren();
	self.tableLayer = tableLayer;
	self:setName("EndLayer");
	local uiTable = {
		Button_end = "Button_end",
		Button_jixu = "Button_jixu",
		Image_time = "Image_time",
		--Button_qizhuang = "Button_qizhuang",
	}
	self:initData();

	loadNewCsb(self,"ershiyidian/EndLayer",uiTable)
	self.xBg = self.csbNode
	self:initUI();

end

function EndLayer:initData()
end

function EndLayer:initUI()
	
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

	local n_time = 5
	local seq1 = cc.CallFunc:create(function ( ... )
		n_time = n_time - 1;
		self.Image_time:loadTexture("ershiyidian/time/"..n_time..".png");
		if n_time == 0 then
			self:ExitGame();
		end
	end);
	self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1.0),seq1)));
end


function EndLayer:onClick_jixu()
	luaPrint("onClick_jixu");
	self:stopAllActions();
	ESYDInfo:sendjixuGame()
	self:removeFromParent();
end

function EndLayer:ExitGame()
	luaPrint("ExitGame");
	self:stopAllActions();
	self.tableLayer:onClickExitGameCallBack();
end

return EndLayer
