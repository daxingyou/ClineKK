FIRSTDUNCOUNT = 3     		--前蹲牌数
OTHERDUNCOUNT = 5     		--其他蹲牌数
PLAYCARTCOUNT = 13				--玩家手中牌数
EXCEPTIONCARD = 0xff			--异常牌
EXCEPTIONPOSITION = 0xff	--异常位置

-- 游戏状态定义
GS_WAIT_SETGAME		= 0			--等待东家设置状态
GS_WAIT_ARGEE		= 1			--等待同意设置
GS_SEND_CARD		= 20		--发牌状态
GS_WAIT_BACK		= 21		--等待扣压底牌
GS_PLAY_GAME		= 22		--游戏中状态
GS_WAIT_NEXT		= 23		--等待下一盘开始
GS_BAFINISH			= 24		--游戏把结束状态

GameState = {
    GS_WAIT_NEXT	 			         = 0,       -- 房间游戏状态未开始阶段
    SSS_ROOM_GAME_STATE_CUTS	         = 1,       -- 房间游戏进入切牌阶段
    SSS_ROOM_GAME_STATE_CUTS_ANIMATION	 = 2,	    -- 房间游戏进入切牌阶段
    SSS_ROOM_GAME_STATE_BANKER           = 3,		-- 房间游戏进入抢庄阶段
    SSS_ROOM_GAME_START_BANKER_ANIMATION = 4,		-- 房间游戏进入抢完庄的动画播放状态
    SSS_ROOM_GAME_STATE_BET              = 5,		-- 房间游戏进入下注阶段
    GS_SEND_CARD                         = 6,		-- 房间游戏进入发牌阶段
    GS_PLAY_GAME                         = 7,		-- 房间游戏进入组牌阶段
}


-- 金币场退出倒计时
auto_exit_sec = 20	

PaiXinT = {
    [PaiXinEnum.SINGLE] = {
        texture = {"shui13_res/w_wulong.png", "shui13_res/w_danzhang.png"}
    },
    [PaiXinEnum.PAIRS] = {
        texture = "shui13_res/w_duizi.png",
        checkFunc = function(manager) return manager:HavePairs() end,
        getCardFunc = function(manager)
             return manager:GetPairs(), 3
        end,
    },
    [PaiXinEnum.TWOPAIRS] = {
        texture = "shui13_res/w_liangdui.png",
        checkFunc = function(manager) return manager:HaveTPairs() end,
        getCardFunc = function(manager)
            return manager:GetTPairs(), 1
        end,
    },
    [PaiXinEnum.TRIPLES] = {
        texture = "shui13_res/w_santiao.png",
        checkFunc = function(manager) return manager:HaveTriples() end,
        getCardFunc = function(manager)
            return manager:GetTriples(), 2
        end,
    },
    [PaiXinEnum.STRAIGHT] = {
        texture = "shui13_res/w_shunzi.png",
        checkFunc = function(manager) return manager:HaveStraight() end,
        getCardFunc = function(manager)
            return manager:GetStraight()
        end,
    },
    [PaiXinEnum.FLUSH] = {
        texture = "shui13_res/w_tonghua.png",
        checkFunc = function(manager) return manager:HaveFlush() end,
        getCardFunc = function(manager)
            return manager:GetFlush()
        end,
    },
    [PaiXinEnum.FULLHOUSE] = {
        texture = "shui13_res/w_hulu.png",
        checkFunc = function(manager) return manager:HaveFullHouse() end,
        getCardFunc = function(manager)
            return manager:GetFullHouse()
        end,
    },
    [PaiXinEnum.FOUR] = {
        texture = "shui13_res/w_tiezhi.png",
        checkFunc = function(manager) return manager:HaveFour() end,
        getCardFunc = function(manager)
            return manager:GetFour(), 1
        end,
    },
    [PaiXinEnum.GRANDSTRAIGHT] = {
        texture = "shui13_res/w_tonghuashun.png",
        checkFunc = function(manager) return manager:HaveGrandStraight() end,
        getCardFunc = function(manager)
            return manager:GetGrandStraight()
        end,
    },
    [PaiXinEnum.FIVE] = {
        texture = "shui13_res/w_wutiao.png",
        checkFunc = function(manager) return manager:HaveFive() end,
        getCardFunc = function(manager)
            return manager:GetFive()
        end,
    },
}

CommonDunT = {
    {pos=HandCard.Pos.FIRST, count=FIRSTDUNCOUNT, gap=80},
    {pos=HandCard.Pos.MID, count=OTHERDUNCOUNT, gap=80},
    {pos=HandCard.Pos.LAST, count=OTHERDUNCOUNT, gap=100},
}

ConfigT = {
    [2] = {
        chatSet = {
            true, false
        },
        cardScale = 0.8,
    },
    [3] = {
        chatSet = {
            true, false, true
        },
        cardScale = 0.8,
    },
    [4] = {
        chatSet = {
            true, false, false, true
        },
        cardScale = 0.8,
    },
    
    [5] = {
        chatSet = {
            true, false, false, true, true
        },
        cardScale = 0.65,
    },

    [6] = {
        chatSet = {
            true, false, false, false, true, true
        },
        cardScale = 0.55,
    },

    [7] = {
        chatSet = {
            true, false, false, false, true, true,true
        },
        cardScale = 0.55,
        },
    [8] = {
        chatSet = {
            true, false, false, false, false, true, true, true
        },
        cardScale = 0.55,
    }

}

SpecialCardTypeT = {
    [SpecialCardTypeEnum.LiuDuiBan] = {
        aniName = "liuduiban",
        animation = {"specialAni/liuduiban.json", "specialAni/liuduiban.atlas"}
    },
    [SpecialCardTypeEnum.SanShunZi] = {
        aniName = "sanshunzi",
        animation = {"specialAni/sanshunzi.json", "specialAni/sanshunzi.atlas"},
    },
    [SpecialCardTypeEnum.SanTongHua] = {
        aniName = "santonghua",
        animation = {"specialAni/santonghua.json", "specialAni/santonghua.atlas"},
    },
    [SpecialCardTypeEnum.SanFenTianXia] = {
        aniName = "sanfentianxia",
        animation = {"specialAni/sanfentianxia.json", "specialAni/sanfentianxia.atlas"},
    },
    [SpecialCardTypeEnum.SanTongHuaShun] = {
        aniName = "santonghuashun",
        animation = {"specialAni/santonghuashun.json", "specialAni/santonghuashun.atlas"},
    },
    [SpecialCardTypeEnum.YiTiaoLong] = {
        aniName = "yitiaolong",
        animation = {"specialAni/yitiaolong.json", "specialAni/yitiaolong.atlas"},
    },
    [SpecialCardTypeEnum.QingLong] = {
        aniName = "qinglong",
        animation = {"specialAni/qinglong.json", "specialAni/qinglong.atlas"},
    },
    [SpecialCardTypeEnum.SiTaoSanTiao] = {
        aniName = "sitaosantiao",
        animation = {"specialAni/sitaosantiao.json", "specialAni/sitaosantiao.atlas"},
    },
}

CommonMessage = {
    "快点吧，等到花儿都谢了",
    "你的牌打得太好了",
    "整个一个悲剧啊",
    "一手烂牌臭到底",
    "你家里是开银行的吧",
    "不要吵啦，专心玩儿牌吧",
    "大清早，鸡都还没叫，慌什么",
    "再见啦，我会想念大家的",
    "别墨迹，快点出牌",
}
