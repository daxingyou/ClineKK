local GameSimpleUser = class("GameSimpleUser")

function GameSimpleUser:ctor()

end

function GameSimpleUser:initData()
	self.nUserIdx = 0;
    self.szName = "";
    self.nScore = 0;
    self.bBoy = false;
    self.ip = 0;
    self.master = false;
end

return GameSimpleUser
