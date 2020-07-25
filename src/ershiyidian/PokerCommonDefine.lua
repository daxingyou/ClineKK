
local PokerCommonDefine = {}

--牌值类型
PokerCommonDefine.Poker_Value_Type = {
    CT_BAOPAI         =       1 ,                                  --//爆牌
    CT_BJ             =       22 ,                                 --//黑杰克
    CT_SAN_QI         =       30 ,                                 --//777
}
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
        elseif PLAY_COUNT == 5 then
            PokerCommonDefine.Poker_Seat_Mark  = {
            Poker_South = 0,         --//南(自己)
            Poker_West = 1,          --//西
            Poker_North1 = 2,         --//北1
            Poker_North2 = 3,         --//北2
            Poker_East = 4,           --//东
            }    --//玩家座位标 
        end
    end
end 

return PokerCommonDefine;
