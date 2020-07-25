local GameLogic = {}

GameLogic.Error 		= 0;
GameLogic.Normal 		= 1;
GameLogic.ShiDianBan 	= 2;
GameLogic.WuXiao 		= 3;
GameLogic.RenWuXiao 	= 4;
GameLogic.TianWang 		= 5;
GameLogic.LiuXiao 		= 6;
GameLogic.QiXiao 		= 7;
GameLogic.BaXiao 		= 8;
GameLogic.JiuXiao 		= 9;
GameLogic.DaTianWang 	= 10;
--获取单张牌的牌值大小
function GameLogic:GetCardVaule(cardData)
	local cardVaule = cardData%16;
	if cardVaule > 10 then--大于10点则为半点
		cardVaule = 0.5;
	end
	return cardVaule;
end
--获取游戏牌的大小和类型
function GameLogic:GetCardType(cardData)
	local CardResultVaule = 0;--牌值总和
	local haveRen = true;--判断人五小的值
	local CardCount = 0;
	for k,v in pairs(cardData) do
		if v>0 then
			local cardVaule = self:GetCardVaule(v);
			CardResultVaule = CardResultVaule + cardVaule;
			CardCount = CardCount+1;
			if cardVaule ~= 0.5 then--有小于10的牌不是人五小
				haveRen = false;
			end
		end
	end
	--判断牌的类型
	local CardResultType = GameLogic.Normal;
	if CardResultVaule > 10.5 then
		CardResultType = GameLogic.Error;
	elseif CardCount == 9 and CardResultVaule == 10.5 then
		CardResultType = GameLogic.DaTianWang;
	elseif CardCount == 9 then
		CardResultType = GameLogic.JiuXiao;
	elseif CardCount == 8 then
		CardResultType = GameLogic.BaXiao;
	elseif CardCount == 7 then
		CardResultType = GameLogic.QiXiao;
	elseif CardCount == 6 then
		CardResultType = GameLogic.LiuXiao;
	elseif CardCount == 5 and CardResultVaule == 10.5 then
		CardResultType = GameLogic.TianWang;
	elseif CardCount == 5 and haveRen then
		CardResultType = GameLogic.RenWuXiao;
	elseif CardCount == 5 then
		CardResultType = GameLogic.WuXiao;
	elseif CardResultVaule == 10.5 then
		CardResultType = GameLogic.ShiDianBan;
	end

	return CardResultVaule,CardResultType;

end


return GameLogic