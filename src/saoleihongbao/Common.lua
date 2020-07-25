local Common = {}


Common = {
	EVT_DEAL_MSG = "SLHB_EVT_DEAL_MSG",
	EVT_VIEW_MSG = "SLHB_EVT_VIEW_MSG",
	ACTION_BEGIN = "SLHB_ACTION_BEGIN",
	ACTION_END   = "SLHB_ACTION_END",
}

function Common.gameRealMoney(money)
	if money == nil then
		return 0;
	end
	return string.format("%.2f", money/100);
end





return Common;