

local VipRoomInfoModule = class("VipRoomInfoModule");

local _roomInfoModule = nil;

function VipRoomInfoModule:getInstance()
	if _roomInfoModule == nil then
		_roomInfoModule = VipRoomInfoModule.new();
	end

	return _roomInfoModule;
end

function VipRoomInfoModule:ctor()
	self:initData();
end

function VipRoomInfoModule:initData()
	-- 
	self.m_gold = {
		--百家乐
		{id = 3,sGameName= "game_30miao",uNameID = 40011000, uRoomID = 1, nMinRoomKey =3000,gameName="百家乐",roomName="百家乐现金场"},--百家乐
		-- {uNameID = 40011000, uRoomID = 49, nMinRoomKey = 0},

		--奔驰宝马
		{id = 8,sGameName= "game_ppc",uNameID = 40012000, uRoomID = 2, nMinRoomKey = 3000,gameName="奔驰宝马",roomName="奔驰宝马现金场"},--奔驰宝马
		-- {uNameID = 40012000, uRoomID = 50, nMinRoomKey = 0},

		--骰宝
		{id = 6,sGameName= "game_yyy",uNameID = 40013000, uRoomID = 12, nMinRoomKey = 3000,gameName="骰宝",roomName="骰宝现金场"},--骰宝
		-- {uNameID = 40013000, uRoomID = 51, nMinRoomKey = 0},

		--飞禽走兽
		{id = 7,sGameName= "game_fqzs",uNameID = 40014000, uRoomID = 13, nMinRoomKey = 3000,gameName="飞禽走兽",roomName="飞禽走兽现金场"},--飞禽走兽
		-- {uNameID = 40014000, uRoomID = 52, nMinRoomKey = 0},

		--百人牛牛
		-- {id = 2,sGameName= "game_brps",uNameID = 40015000, uRoomID = 3, nMinRoomKey = 3000,gameName="百人牛牛",roomName="百人牛牛4倍场"},--百人牛牛
		{id = 2,sGameName= "game_brps",uNameID = 40015000, uRoomID = 14, nMinRoomKey = 3000,gameName="百人牛牛",roomName="百人牛牛10倍场"},
		-- {uNameID = 40015000, uRoomID = 48, nMinRoomKey = 0},

		--红黑大战
		{id = 5,sGameName= "game_hhdz",uNameID = 40016000, uRoomID = 46, nMinRoomKey = 3000,gameName="红黑大战",roomName="红黑大战现金场"},--红黑大战
		-- {uNameID = 40016000, uRoomID = 58, nMinRoomKey = 0},

		--龙虎斗
		{id = 4,sGameName= "game_lhd",uNameID = 40017000, uRoomID = 47, nMinRoomKey = 3000,gameName="龙虎斗",roomName="龙虎斗现金场"},--龙虎斗
		-- {uNameID = 40017000, uRoomID = 59, nMinRoomKey = 0},

		--斗地主
		{id = 10,sGameName= "dz_ddz",uNameID = 40023000, uRoomID = 15, nMinRoomKey = 3000,gameName="斗地主",roomName="斗地主经典场"},--斗地主
		-- {id = 10,sGameName= "dz_ddz",uNameID = 40023000, uRoomID = 19, nMinRoomKey = 1000,gameName="斗地主",roomName="斗地主场次2"},
		-- {id = 10,sGameName= "dz_ddz",uNameID = 40023000, uRoomID = 20, nMinRoomKey = 1800,gameName="斗地主",roomName="斗地主场次3"},
		-- {id = 10,sGameName= "dz_ddz",uNameID = 40023000, uRoomID = 21, nMinRoomKey = 3000,gameName="斗地主",roomName="斗地主不洗牌场"},
		-- {id = 10,sGameName= "dz_ddz",uNameID = 40023000, uRoomID = 22, nMinRoomKey = 5000,gameName="斗地主",roomName="斗地主不洗牌场"},
		-- {id = 10,sGameName= "dz_ddz",uNameID = 40023000, uRoomID = 23, nMinRoomKey = 10000,gameName="斗地主",roomName="斗地主不洗牌场"},
		-- {id = 10,sGameName= "dz_ddz",uNameID = 40023000, uRoomID = 24, nMinRoomKey = 48000,gameName="斗地主",roomName="斗地主场次7"},

		--捕鱼达人
		{id = 1,sGameName= "lkpy_0",uNameID = 40010000, uRoomID = 4, nMinRoomKey = 3000,gameName="捕鱼达人多人",roomName="捕鱼达人多人新手渔村"},--捕鱼多人
		{id = 1,sGameName= "lkpy_0",uNameID = 40010000, uRoomID = 5, nMinRoomKey = 5000,gameName="捕鱼达人多人",roomName="捕鱼达人多人勇者海湾"},
		{id = 1,sGameName= "lkpy_0",uNameID = 40010000, uRoomID = 6, nMinRoomKey = 10000,gameName="捕鱼达人多人",roomName="捕鱼达人多人深海猎手"},
		{id = 1,sGameName= "lkpy_0",uNameID = 40010000, uRoomID = 7, nMinRoomKey = 15000,gameName="捕鱼达人多人",roomName="捕鱼达人多人海洋神话"},

		{id = 1,sGameName= "lkpy_4",uNameID = 40010004, uRoomID = 8, nMinRoomKey = 3000,gameName="捕鱼达人单人",roomName="捕鱼达人单人新手渔村"},--捕鱼单人
		{id = 1,sGameName= "lkpy_4",uNameID = 40010004, uRoomID = 9, nMinRoomKey = 5000,gameName="捕鱼达人单人",roomName="捕鱼达人单人勇者海湾"},
		{id = 1,sGameName= "lkpy_4",uNameID = 40010004, uRoomID = 10, nMinRoomKey = 10000,gameName="捕鱼达人单人",roomName="捕鱼达人单人深海猎手"},
		{id = 1,sGameName= "lkpy_4",uNameID = 40010004, uRoomID = 11, nMinRoomKey = 15000,gameName="捕鱼达人单人",roomName="捕鱼达人单人海洋神话"},

		--抢庄牛牛
		{id = 15,sGameName= "dz_qzps",uNameID = 40022000, uRoomID = 17, nMinRoomKey = 5000,gameName="抢庄牛牛",roomName="抢庄牛牛平民场"},--抢庄拼十
		{id = 15,sGameName= "dz_qzps",uNameID = 40022000, uRoomID = 28, nMinRoomKey = 25000,gameName="抢庄牛牛",roomName="抢庄牛牛小资场"},
		{id = 15,sGameName= "dz_qzps",uNameID = 40022000, uRoomID = 29, nMinRoomKey = 50000,gameName="抢庄牛牛",roomName="抢庄牛牛老板场"},
		{id = 15,sGameName= "dz_qzps",uNameID = 40022000, uRoomID = 30, nMinRoomKey = 100000,gameName="抢庄牛牛",roomName="抢庄牛牛富豪场"},

		--二人牛牛
		{id = 16,sGameName= "dz_ernn",uNameID = 40021000, uRoomID = 16, nMinRoomKey = 5000,gameName="二人牛牛",roomName="二人牛牛平民场"},--二人拼十
		{id = 16,sGameName= "dz_ernn",uNameID = 40021000, uRoomID = 25, nMinRoomKey = 20000,gameName="二人牛牛",roomName="二人牛牛小资场"},
		{id = 16,sGameName= "dz_ernn",uNameID = 40021000, uRoomID = 26, nMinRoomKey = 100000,gameName="二人牛牛",roomName="二人牛牛老板场"},
		{id = 16,sGameName= "dz_ernn",uNameID = 40021000, uRoomID = 27, nMinRoomKey = 500000,gameName="二人牛牛",roomName="二人牛牛富豪场"},

		--扎金花
		{id = 12,sGameName= "dz_szp",uNameID = 40024000, uRoomID = 18, nMinRoomKey = 3000,gameName="扎金花",roomName="扎金花平民场"},--三张牌
		{id = 12,sGameName= "dz_szp",uNameID = 40024000, uRoomID = 31, nMinRoomKey = 5000,gameName="扎金花",roomName="扎金花小资场"},
		{id = 12,sGameName= "dz_szp",uNameID = 40024000, uRoomID = 32, nMinRoomKey = 30000,gameName="扎金花",roomName="扎金花老板场"},
		{id = 12,sGameName= "dz_szp",uNameID = 40024000, uRoomID = 33, nMinRoomKey = 60000,gameName="扎金花",roomName="扎金花富豪场"},

		--德州扑克
		{id = 11,sGameName= "dz_dzpk",uNameID = 40025000, uRoomID = 42, nMinRoomKey = 5000,gameName="德州扑克",roomName="德州扑克平民场"},--德州扑克
		{id = 11,sGameName= "dz_dzpk",uNameID = 40025000, uRoomID = 43, nMinRoomKey = 20000,gameName="德州扑克",roomName="德州扑克小资场"},
		{id = 11,sGameName= "dz_dzpk",uNameID = 40025000, uRoomID = 44, nMinRoomKey = 50000,gameName="德州扑克",roomName="德州扑克老板场"},
		{id = 11,sGameName= "dz_dzpk",uNameID = 40025000, uRoomID = 45, nMinRoomKey = 100000,gameName="德州扑克",roomName="德州扑克富豪场"},

		--十点半
		{id = 14,sGameName= "dz_sdb",uNameID = 40027000, uRoomID = 38, nMinRoomKey = 5000,gameName="十点半",roomName="十点半平民场"},--十点半
		{id = 14,sGameName= "dz_sdb",uNameID = 40027000, uRoomID = 39, nMinRoomKey = 25000,gameName="十点半",roomName="十点半小资场"},
		{id = 14,sGameName= "dz_sdb",uNameID = 40027000, uRoomID = 40, nMinRoomKey = 50000,gameName="十点半",roomName="十点半老板场"},
		{id = 14,sGameName= "dz_sdb",uNameID = 40027000, uRoomID = 41, nMinRoomKey = 100000,gameName="十点半",roomName="十点半富豪场"},

		--二十一点
		{id = 13,sGameName= "dz_esyd",uNameID = 40026000, uRoomID = 34, nMinRoomKey = 5000,gameName="二十一点",roomName="二十一点平民场"},--二十一点
		{id = 13,sGameName= "dz_esyd",uNameID = 40026000, uRoomID = 35, nMinRoomKey = 25000,gameName="二十一点",roomName="二十一点小资场"},
		{id = 13,sGameName= "dz_esyd",uNameID = 40026000, uRoomID = 36, nMinRoomKey = 50000,gameName="二十一点",roomName="二十一点老板场"},
		{id = 13,sGameName= "dz_esyd",uNameID = 40026000, uRoomID = 37, nMinRoomKey = 100000,gameName="二十一点",roomName="二十一点富豪场"},

		--十三张
		{id = 9,sGameName= "dz_ssz",uNameID = 40028000, uRoomID = 109, nMinRoomKey = 5000,gameName="十三张四人场",roomName="十三张四人平民场"},--十三张
		{id = 9,sGameName= "dz_ssz",uNameID = 40028000, uRoomID = 110, nMinRoomKey = 25000,gameName="十三张四人场",roomName="十三张四人小资场"},
		{id = 9,sGameName= "dz_ssz",uNameID = 40028000, uRoomID = 111, nMinRoomKey = 50000,gameName="十三张四人场",roomName="十三张四人老板场"}, 
		{id = 9,sGameName= "dz_ssz",uNameID = 40028000, uRoomID = 112, nMinRoomKey = 100000,gameName="十三张四人场",roomName="十三张四人富豪场"},

		{id = 9,sGameName= "dz_ssz6r",uNameID = 40028002, uRoomID = 127, nMinRoomKey = 10000,gameName="十三张六人场",roomName="十三张六人平民场"},--十三张 6人
		{id = 9,sGameName= "dz_ssz6r",uNameID = 40028002, uRoomID = 128, nMinRoomKey = 25000,gameName="十三张六人场",roomName="十三张六人小资场"},
		{id = 9,sGameName= "dz_ssz6r",uNameID = 40028002, uRoomID = 129, nMinRoomKey = 50000,gameName="十三张六人场",roomName="十三张六人老板场"}, 
		{id = 9,sGameName= "dz_ssz6r",uNameID = 40028002, uRoomID = 130, nMinRoomKey = 100000,gameName="十三张六人场",roomName="十三张六人富豪场"},

		{id = 9,sGameName= "dz_ssz8r",uNameID = 40028001, uRoomID = 123, nMinRoomKey = 10000,gameName="十三张八人场",roomName="十三张八人平民场"},--十三张 8人
		{id = 9,sGameName= "dz_ssz8r",uNameID = 40028001, uRoomID = 124, nMinRoomKey = 25000,gameName="十三张八人场",roomName="十三张八人小资场"},
		{id = 9,sGameName= "dz_ssz8r",uNameID = 40028001, uRoomID = 125, nMinRoomKey = 50000,gameName="十三张八人场",roomName="十三张八人老板场"}, 
		{id = 9,sGameName= "dz_ssz8r",uNameID = 40028001, uRoomID = 126, nMinRoomKey = 100000,gameName="十三张八人场",roomName="十三张八人富豪场"},

		--乐清十三张
		{id = 20,sGameName= "dz_lq_ssz",uNameID = 40028010, uRoomID = 131, nMinRoomKey = 5000,gameName="十三张四人场",roomName="十三张四人平民场"},--乐清十三张
		{id = 20,sGameName= "dz_lq_ssz",uNameID = 40028010, uRoomID = 132, nMinRoomKey = 25000,gameName="十三张四人场",roomName="十三张四人小资场"},
		{id = 20,sGameName= "dz_lq_ssz",uNameID = 40028010, uRoomID = 133, nMinRoomKey = 50000,gameName="十三张四人场",roomName="十三张四人老板场"}, 
		{id = 20,sGameName= "dz_lq_ssz",uNameID = 40028010, uRoomID = 134, nMinRoomKey = 100000,gameName="十三张四人场",roomName="十三张四人富豪场"},

		{id = 20,sGameName= "dz_lq_ssz6r",uNameID = 40028012, uRoomID = 140, nMinRoomKey = 10000,gameName="十三张六人场",roomName="十三张六人平民场"},--乐清十三张 6人
		{id = 20,sGameName= "dz_lq_ssz6r",uNameID = 40028012, uRoomID = 141, nMinRoomKey = 25000,gameName="十三张六人场",roomName="十三张六人小资场"},
		{id = 20,sGameName= "dz_lq_ssz6r",uNameID = 40028012, uRoomID = 142, nMinRoomKey = 50000,gameName="十三张六人场",roomName="十三张六人老板场"}, 
		{id = 20,sGameName= "dz_lq_ssz6r",uNameID = 40028012, uRoomID = 143, nMinRoomKey = 100000,gameName="十三张六人场",roomName="十三张六人富豪场"},

		{id = 20,sGameName= "dz_lq_ssz8r",uNameID = 40028011, uRoomID = 136, nMinRoomKey = 10000,gameName="十三张八人场",roomName="十三张八人平民场"},--乐清十三张 8人
		{id = 20,sGameName= "dz_lq_ssz8r",uNameID = 40028011, uRoomID = 137, nMinRoomKey = 25000,gameName="十三张八人场",roomName="十三张八人小资场"},
		{id = 20,sGameName= "dz_lq_ssz8r",uNameID = 40028011, uRoomID = 138, nMinRoomKey = 50000,gameName="十三张八人场",roomName="十三张八人老板场"}, 
		{id = 20,sGameName= "dz_lq_ssz8r",uNameID = 40028011, uRoomID = 139, nMinRoomKey = 100000,gameName="十三张八人场",roomName="十三张八人富豪场"},
		
		--扫雷红包
		{id = 17,sGameName= "game_slhb",uNameID = 40018000, uRoomID = 144, nMinRoomKey = 2000,gameName="扫雷红包",roomName="扫雷红包10包1倍(10-50)"}, 
		{id = 17,sGameName= "game_slhb",uNameID = 40018000, uRoomID = 145, nMinRoomKey = 2000,gameName="扫雷红包",roomName="扫雷红包7包1.5倍(10-50)"},
		{id = 17,sGameName= "game_slhb",uNameID = 40018000, uRoomID = 114, nMinRoomKey = 3000,gameName="扫雷红包",roomName="扫雷红包10包1倍(10-500)"}, 
		{id = 17,sGameName= "game_slhb",uNameID = 40018000, uRoomID = 115, nMinRoomKey = 3000,gameName="扫雷红包",roomName="扫雷红包7包1.5倍(10-500)"},
		
		--水果机
		{id = 18,sGameName= "dz_shuiguoji",uNameID = 40050000, uRoomID = 118, nMinRoomKey = 100,gameName="超级水果机",roomName="超级水果机平民场"},--水果机
		{id = 18,sGameName= "dz_shuiguoji",uNameID = 40050000, uRoomID = 119, nMinRoomKey = 10000,gameName="超级水果机",roomName="超级水果机小资场"},
		{id = 18,sGameName= "dz_shuiguoji",uNameID = 40050000, uRoomID = 120, nMinRoomKey = 100000,gameName="超级水果机",roomName="超级水果机老板场"}, 
		
		--水浒传
		{id = 19,sGameName= "game_shz",uNameID = 40060000, uRoomID = 121, nMinRoomKey = 100,gameName="水浒传",roomName="水浒传平民场"}, 
		{id = 19,sGameName= "game_shz",uNameID = 40060000, uRoomID = 158, nMinRoomKey = 1000,gameName="水浒传",roomName="水浒传小资场"}, 
		{id = 19,sGameName= "game_shz",uNameID = 40060000, uRoomID = 159, nMinRoomKey = 10000,gameName="水浒传",roomName="水浒传老板场"}, 
		
		--糖果派对
		{id = 21,sGameName= "game_tgpd",uNameID = 40061000, uRoomID = 146, nMinRoomKey = 100,gameName="糖果派对",roomName="糖果派对平民场"},  
		{id = 21,sGameName= "game_tgpd",uNameID = 40061000, uRoomID = 160, nMinRoomKey = 1000,gameName="糖果派对",roomName="糖果派对小资场"},  
		{id = 21,sGameName= "game_tgpd",uNameID = 40061000, uRoomID = 161, nMinRoomKey = 10000,gameName="糖果派对",roomName="糖果派对老板场"},  

		--连环夺宝
        {id = 22,sGameName= "game_lhdb",uNameID = 40062000  , uRoomID = 148, nMinRoomKey = 100,gameName="连环夺宝",roomName="连环夺宝平民场"}, 
		{id = 22,sGameName= "game_lhdb",uNameID = 40062000  , uRoomID = 162, nMinRoomKey = 1000,gameName="连环夺宝",roomName="连环夺宝小资场"}, 
		{id = 22,sGameName= "game_lhdb",uNameID = 40062000  , uRoomID = 163, nMinRoomKey = 10000,gameName="连环夺宝",roomName="连环夺宝老板场"}, 
		
		--李逵劈鱼
		{id = 23,sGameName= "lkpy_1",uNameID = 40010001, uRoomID = 164, nMinRoomKey = 3000,gameName="李逵劈鱼多人",roomName="李逵劈鱼多人新手渔村"},--捕鱼多人
		{id = 23,sGameName= "lkpy_1",uNameID = 40010001, uRoomID = 165, nMinRoomKey = 5000,gameName="李逵劈鱼多人",roomName="李逵劈鱼多人勇者海湾"},
		{id = 23,sGameName= "lkpy_1",uNameID = 40010001, uRoomID = 166, nMinRoomKey = 10000,gameName="李逵劈鱼多人",roomName="李逵劈鱼多人深海猎手"},
		{id = 23,sGameName= "lkpy_1",uNameID = 40010001, uRoomID = 167, nMinRoomKey = 15000,gameName="李逵劈鱼多人",roomName="李逵劈鱼多人海洋神话"},

		{id = 23,sGameName= "lkpy_5",uNameID = 40010005, uRoomID = 168, nMinRoomKey = 3000,gameName="李逵劈鱼单人",roomName="李逵劈鱼单人新手渔村"},--捕鱼单人
		{id = 23,sGameName= "lkpy_5",uNameID = 40010005, uRoomID = 169, nMinRoomKey = 5000,gameName="李逵劈鱼单人",roomName="李逵劈鱼单人勇者海湾"},
		{id = 23,sGameName= "lkpy_5",uNameID = 40010005, uRoomID = 170, nMinRoomKey = 10000,gameName="李逵劈鱼单人",roomName="李逵劈鱼单人深海猎手"},
		{id = 23,sGameName= "lkpy_5",uNameID = 40010005, uRoomID = 171, nMinRoomKey = 15000,gameName="李逵劈鱼单人",roomName="李逵劈鱼单人海洋神话"},

		--金蟾捕鱼
		{id = 24,sGameName= "lkpy_2",uNameID = 40010002, uRoomID = 172, nMinRoomKey = 3000,gameName="金蟾捕鱼多人",roomName="金蟾捕鱼多人新手渔村"},--捕鱼多人
		{id = 24,sGameName= "lkpy_2",uNameID = 40010002, uRoomID = 173, nMinRoomKey = 5000,gameName="金蟾捕鱼多人",roomName="金蟾捕鱼多人勇者海湾"},
		{id = 24,sGameName= "lkpy_2",uNameID = 40010002, uRoomID = 174, nMinRoomKey = 10000,gameName="金蟾捕鱼多人",roomName="金蟾捕鱼多人深海猎手"},
		{id = 24,sGameName= "lkpy_2",uNameID = 40010002, uRoomID = 175, nMinRoomKey = 15000,gameName="金蟾捕鱼多人",roomName="金蟾捕鱼多人海洋神话"},

		{id = 24,sGameName= "lkpy_6",uNameID = 40010006, uRoomID = 176, nMinRoomKey = 3000,gameName="金蟾捕鱼单人",roomName="金蟾捕鱼单人新手渔村"},--捕鱼单人
		{id = 24,sGameName= "lkpy_6",uNameID = 40010006, uRoomID = 177, nMinRoomKey = 5000,gameName="金蟾捕鱼单人",roomName="金蟾捕鱼单人勇者海湾"},
		{id = 24,sGameName= "lkpy_6",uNameID = 40010006, uRoomID = 178, nMinRoomKey = 10000,gameName="金蟾捕鱼单人",roomName="金蟾捕鱼单人深海猎手"},
		{id = 24,sGameName= "lkpy_6",uNameID = 40010006, uRoomID = 179, nMinRoomKey = 15000,gameName="金蟾捕鱼单人",roomName="金蟾捕鱼单人海洋神话"},

	}
end

function VipRoomInfoModule:getuNameIDBysGameName(sGameName)
	for i,v in ipairs(self.m_gold) do
		if v.sGameName == sGameName then
			return v.uNameID;
		end
	end

	return 0
end

function VipRoomInfoModule:getRoomListBysGameName(sGameName)
	local roomlist = {}
	if string.find(sGameName,"lkpy_0") or string.find(sGameName,"lkpy_4")  then
		sGameName = {"lkpy_0","lkpy_4"}
	elseif string.find(sGameName,"lkpy_1") or string.find(sGameName,"lkpy_5") then
		sGameName = {"lkpy_1","lkpy_5"}
	elseif string.find(sGameName,"lkpy_2") or string.find(sGameName,"lkpy_6") then
		sGameName = {"lkpy_2","lkpy_6"}
	elseif string.find(sGameName,"dz_ssz") then
		sGameName = {"dz_ssz","dz_ssz6r","dz_ssz8r"}
	elseif string.find(sGameName,"dz_lq_ssz") then
		sGameName = {"dz_lq_ssz","dz_lq_ssz6r","dz_lq_ssz8r"}
	end
	for i,v in ipairs(self.m_gold) do
		if type(sGameName) == "string" then
			if v.sGameName == sGameName then
				table.insert(roomlist,v.uRoomID)
			end
		elseif type(sGameName) == "table" then
			for kk,vv in pairs(sGameName) do
				if v.sGameName == vv then
					table.insert(roomlist,v.uRoomID)
				end
			end
		end	
	end
	
	return roomlist
end

function VipRoomInfoModule:getIDByRoomID(uRoomID)
	for i,v in ipairs(self.m_gold) do
		if v.uRoomID == uRoomID then
			return v.id;
		end
	end

	return 0
end

--判断是否真实房间ID
function VipRoomInfoModule:getIsRealyRoomID(uRoomID)
	for i,v in ipairs(self.m_gold) do
		if v.uRoomID == uRoomID then
			return true;
		end
	end

	return false;
end

function VipRoomInfoModule:getIDBysGameName(sGameName)
	for i,v in ipairs(self.m_gold) do
		if v.sGameName == sGameName then
			return v.id;

		end
	end

	return 0
end

function VipRoomInfoModule:getsGameNameByID(id)
	for i,v in ipairs(self.m_gold) do
		if v.id == id then
			return v.sGameName;
		end
	end

	return ""
end

function VipRoomInfoModule:getsGameNameByRoomID(uRoomID)
	for i,v in ipairs(self.m_gold) do
		if v.uRoomID == uRoomID then
			return v.sGameName;
		end
	end

	return ""
end
 
function VipRoomInfoModule:getGameNameByNameID(uNameId)
	for i,v in ipairs(self.m_gold) do
		if v.uNameID == uNameId then
			return v.gameName;
		end
	end

	return ""
end

function VipRoomInfoModule:getRoomNameByRoomID(uRoomID)
	for i,v in ipairs(self.m_gold) do
		if v.uRoomID == uRoomID then
			return v.roomName;
		end
	end

	return ""
end

return VipRoomInfoModule;

