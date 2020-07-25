local TrustLayer = class("TrustLayer", PopLayer)

function TrustLayer:create(tableLayer)
	return TrustLayer.new(tableLayer);
end

function TrustLayer:ctor(tableLayer)
	--self.super.ctor(self)
	self.super.ctor(self,PopType.none)
	self:removeAllChildren();
	self.tableLayer = tableLayer;
	--self.super.ctor(self, nil, true);
	self:setName("TrustLayer");
	local uiTable = {
		Button_quxiaotuoguan = "Button_quxiaotuoguan",
		Button_close = "Button_close",
	}
	self:initData();

	loadNewCsb(self,"errenniuniu/TrustLayer",uiTable)
	self.xBg = self.csbNode
	self:initUI();

	--self.colorLayer:setOpacity(100);
end

function TrustLayer:initData()
end

function TrustLayer:initUI()
	
	if self.Button_quxiaotuoguan then
		self.Button_quxiaotuoguan:onClick(function(sender)
			luaPrint("Button_quxiaotuoguan");
			self:onClick();
		end)
	end

	if self.Button_close then
		self.Button_close:onClick(function(sender)
			luaPrint("Button_close");
			self:onClick();
		end)
	end
end

function TrustLayer:start()
	-- self:setVisible(true);
	-- self:setTouchEnabled(true);
end

function TrustLayer:stop()
	-- self:setVisible(false)
	-- self:setTouchEnabled(false);
end

function TrustLayer:onClick()
	luaPrint("取消托管");
	ERNNInfo:sendTrust(100)
end

return TrustLayer
