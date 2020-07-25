local PokerCommonDefine = {}

PokerCommonDefine.GOLD_CARD_COLOR = cc.c3b(255, 240, 0)

PokerCommonDefine.OwnMahjonType = {
	First_Perspective = 0,      --自己看的手牌
    show_other = 1,             --展现给别人的牌
}

PokerCommonDefine.HOR_WALL_MAHJONG_PATH          =        "hor_wall.png"              --//水平
PokerCommonDefine.VERTICAL_WALL_MAHJONG_PATH     =        "vertical_wall.png"         --//垂直
PokerCommonDefine.MAHJONG_OUTNeedle_PATH         =        "Mahjong/ZhuanZhuanMahjong/gameTime/out_sign.png"
-- 动画特效文件路径

--麻将动作TAG
PokerCommonDefine.POKER_PASS_TAG			=		10001
PokerCommonDefine.POKER_TISHI_TAG			=		10002
PokerCommonDefine.POKER_OUTCARD_TAG			=		10003

--摸牌时麻将的起手位置
PokerCommonDefine.vcStartPosition = {
	pos0		=		cc.p(0, 0),                    --//南
	pos1		=		cc.p(0, 0),                    	 --//西
	pos2		=		cc.p(0, 0),                    --//北
	pos3		=		cc.p(0, 0),                      --//东
}

--出牌时麻将显示的位置
PokerCommonDefine.vcShowPosition = {
	pos0		=		cc.p(330 - 50 - 70, 100 - 10),
	pos1		=		cc.p(250, 440 + 20),
	pos2		=		cc.p(800 + 37 - 20, 490),
	pos3		=		cc.p(960, 220 - 10),
}

--麻将位置
PokerCommonDefine.Poker_Seat_Mark  = {
	Poker_South = 0,         --//南(自己)
    Poker_West = 1,          --//西
    Poker_North = 2,         --//北
    Poker_East = 3,           --//东
}    --//玩家座位标志(相对第一视角位置）

--结局种类
PokerCommonDefine.Poker_Result = {
	Result_Draw 			= 0,        --//流局
    Result_Win 				= 1,        --//赢
    Result_Lose				= 2,        --//输
    Result_Win_YPDX			= 3,    	--//一炮多响赢
    Result_Lost_YPDX		= 4,    	--//一炮多响输
}

    
--麻将精灵帧动画种类
PokerCommonDefine.Poker_Animation_Type = {
	Poker_NoOutCard = 0,			--
	Poker_TiShi 	= 1,			--
	Poker_OutCard 	= 2,			--
	Poker_Win		= 3,			--
}

PokerCommonDefine.POKER_NORTH_PATH          =           "Mahjong/majiang/north/north.plist"         --//北
PokerCommonDefine.POKER_EAST_PATH           =           "Mahjong/majiang/east/east.plist"           --//东
PokerCommonDefine.POKER_SOUTH_PATH          =           "Mahjong/majiang/south/south.plist"         --//南
PokerCommonDefine.POKER_WEST_PATH           =           "Mahjong/majiang/west/west.plist"           --//西

--游戏数据长度相关
PokerCommonDefine.POKER_MAX_CARDS       =      54     --//麻将张数

--关于扑克牌牌值的定义
PokerCommonDefine.PokerKind = {
	HeiTao 		= 0,        --黑桃
    ThongTao 	= 10,       --红桃
    MeiHua 		= 20,       --梅花
    FangKuai 	= 30,       --方块
    Unknown 	= 255,   	--未知花型
}

--通过牌值返回牌的类型
function PokerCommonDefine.GetKind(byPs)
    if byPs >= 1 and byPs <= 13 then
        return self.PokerKind.HeiTao;
    elseif byPs >= 21 and byPs <= 33 then
        return self.PokerKind.ThongTao;
    elseif byPs >= 41 and byPs <= 53 then
        return self.PokerKind.MeiHua;
    elseif byPs >= 61 and byPs <= 73 then
        return self.PokerKind.FangKuai;
    else
    	return self.PokerKind.Unknown;
    end
end

--判断一张牌是否有效
function PokerCommonDefine.Verify(byPs)
    return self.PokerKind.Unknown ~= self.GetKind(byPs);
end

--通过牌值返回牌的点数
function PokerCommonDefine.GetDian(byPs)
    return byPs % 10;
end

PokerCommonDefine.m_cbCardData=
{
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,   --//方块 A - K
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,   --//梅花 A - K
    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,   --//红桃 A - K
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,   --//黑桃 A - K
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,   --//方块 A - K
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,   --//梅花 A - K
    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,   --//红桃 A - K
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,   --//黑桃 A - K
}

function PokerCommonDefine.adjustmentGame()
    if PLAY_COUNT ~= nil and type(PLAY_COUNT) == "number" and PLAY_COUNT > 0 then
        if PLAY_COUNT == 3 then
            PokerCommonDefine.Poker_Seat_Mark  = {
                Poker_South = 0,         --//南(自己)
                Poker_West = 1,          --//西
                Poker_North = 3,         --//北
                Poker_East = 2,           --//东
            }  
        elseif PLAY_COUNT == 2 then
            PokerCommonDefine.Poker_Seat_Mark  = {
                Poker_South = 0,         --//南(自己)
                Poker_West = 2,          --//西
                Poker_North = 1,         --//北
                Poker_East = 3,           --//东
            }
        elseif PLAY_COUNT == 4 then
            PokerCommonDefine.Poker_Seat_Mark  = {
            Poker_South = 0,         --//南(自己)
            Poker_West = 1,          --//西
            Poker_North = 2,         --//北
            Poker_East = 3,           --//东
            }    --//玩家座位标 
        end
    end
end 


PokerCommonDefine.OutCardType = {
--//扑克类型
CT_ERROR                    =0  ,                                 --//错误类型
CT_SINGLE                   =1  ,                                 --//单牌类型
CT_DOUBLE                   =2  ,                                 --//对子类型
CT_THREE                    =3  ,                                 --//三条类型
CT_SINGLE_LINK              =4  ,                                 --//单连类型
CT_DOUBLE_LINK              =5  ,                                 --//对连类型
CT_THREE_LINK               =6  ,                                 --//三连类型
CT_THREE_DOUBLE             =7  ,                                 --//三带二型
CT_TONG_HUA_SHUN            =8  ,                                 --//同花顺型
CT_BOMB                     =9  ,                                 --//炸弹类型
CT_BOMB_TW                  =10 , 
}



return PokerCommonDefine;
