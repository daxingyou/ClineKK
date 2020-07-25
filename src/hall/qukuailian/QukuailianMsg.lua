local QukuailianMsg = {
		ASS_GR_HASH	= 28,
		ASS_GR_GET_HASH	= 29,
		ASS_GR_SEND_HASH	= 30,  --游戏开始收到hash

		PLAY_COUNT = 4;
}


 QukuailianMsg.path = {
	bairenniuniu = "qukuailian.ItemBrnn",	--百人牛牛
	feiqinzoushou = "qukuailian.ItemFqzs",	--飞禽走兽
	benchibaoma = "qukuailian.ItemBcbm", 	--奔驰宝马
	dezhoupuke = "qukuailian.ItemDzpk", 	--德州扑克
	doudizhu = "qukuailian.ItemDdz", 		--斗地主
	baijiale = "qukuailian.ItemBjl", 		--百家乐
	longhudou = "qukuailian.ItemLhd", 		--龙虎斗
	hongheidazhan = "qukuailian.ItemHhdz", 	--红黑大战
	saoleihongbao = "qukuailian.ItemSlhb", 	--扫雷红包
	shisanzhang = "qukuailian.ItemSsz", 	--十三张
	sanzhangpai = "qukuailian.ItemSzp", 	--三张牌
	shidianban = "qukuailian.ItemSdb", 		--十点半
	qiangzhuangniuniu = "qukuailian.ItemQznn", 	--抢庄牛牛
	yaoyiyao = "qukuailian.ItemYYY", 		--摇一摇
	ershiyidian = "qukuailian.ItemEsyd", 	--二十一点
	errenniuniu = "qukuailian.ItemErnn",	--二人牛牛
	chaojishuiguoji = "qukuailian.ItemCjsgj", --超级水果机
    shuihuzhuan = "qukuailian.ItemShz" ,--水浒传
    tangguopaidui = "qukuailian.ItemTgpd" ,--糖果派对
    lianhuanduobao = "qukuailian.ItemLhdb" --连环夺宝
}

QukuailianMsg.MSG_GR_HASH = {
	{"szMessage","CHARSTRING[65]"}, 
}


QukuailianMsg.CMD_S_HASH = {
	
	{"HashResult","CHARSTRING[64]"},  
	{"Reslut","BYTE[1000]"},  
}

QukuailianMsg.CMD_GR_SEND_HASH = {
	{"HashResult","CHARSTRING[64]"},  
}

QukuailianMsg.CMD_S_HTTPURL = {
	{"URL","CHARSTRING[1000]"},  
}


--区块链 游戏消息结构
QukuailianMsg.config = {
	--百家乐
	baijiale = {
						{"HashResult","CHARSTRING[64]"},  
						{"m_cbTableCardArray","BYTE[2][3]"},  --庄闲牌号
					},
	--扫雷红包
	saoleihongbao_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"llRedBagScore","LLONG"},	--开奖红包值
						   	-- {"m_lUserWinScore","LLONG"}, --输赢得分
							},
	saoleihongbao = {
						{"HashResult","CHARSTRING[64]"},
						{"llRedBagScore","LLONG"},	--埋雷金额  
						{"ucMinesIndex","BYTE"},  --雷号
						{"ucNum","BYTE"}, --已开红包数
						{"itemlist","QukuailianMsg.config.saoleihongbao_item[10]"}
					},
	--百人牛牛
	bairenniuniu = 	{
						{"HashResult","CHARSTRING[64]"}, 
						{"cbTableCardArray","BYTE[5][5]"}
					},
	--奔驰宝马
	benchibaoma  =  {
						{"HashResult","CHARSTRING[64]"},
						{"m_cbResultIndex","BYTE"} ,  --开奖结果
					},
	--飞禽走兽
	feiqinzoushou  =  {
						{"HashResult","CHARSTRING[64]"},
						{"m_gAnimal","INT"} ,  --开奖结果
					},

	--三张牌
	sanzhangpai_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"cbHandCardData","BYTE[3]"},	--牌值
						},

	sanzhangpai  =  {
						{"HashResult","CHARSTRING[64]"},
						{"itemlist","QukuailianMsg.config.sanzhangpai_item[5]"} ,
					},
	--德州扑克					
	dezhoupuke_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"cbHandCardData","BYTE[2]"},	--牌值
						},

	dezhoupuke  =  {
						{"HashResult","CHARSTRING[64]"},
						{"iPublicCard","BYTE[5]"} ,  --公共牌
						{"itemlist","QukuailianMsg.config.dezhoupuke_item[5]"} ,
					},
	--斗地主 todo					
	doudizhu_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"cbHandCardData","BYTE[17]"},	--牌值
						},

	doudizhu  =  {
						{"HashResult","CHARSTRING[64]"},
						{"m_cbBankerCard","BYTE[3]"} ,  --底牌
						{"itemlist","QukuailianMsg.config.doudizhu_item[3]"} ,
					},
	--二人牛牛 todo					
	errenniuniu_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"cbHandCardData","BYTE[5]"},	--牌值
						},

	errenniuniu  =  {
						{"HashResult","CHARSTRING[64]"},
						{"itemlist","QukuailianMsg.config.errenniuniu_item[2]"} ,
					},
	--二十一点 todo					
	ershiyidian_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"cbHandCardData","BYTE[2]"},	--牌值
						},

	ershiyidian  =  {
						{"HashResult","CHARSTRING[64]"},
						{"itemlist","QukuailianMsg.config.ershiyidian_item[5]"} ,
					},

	--龙虎
	longhudou = {
					{"HashResult","CHARSTRING[64]"},  
					{"m_iRBCard","BYTE[2][1]"},  --牌值
				},

	--红黑
	hongheidazhan = {
						{"HashResult","CHARSTRING[64]"},  
						{"m_iRBCard","BYTE[2][3]"},  --牌值
					},

	--摇一摇
	yaoyiyao = {
					{"HashResult","CHARSTRING[64]"},  
					{"DiceData","BYTE[3]"} ,  --开奖结果
				},

	--十点半
	shidianban_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"m_cbHandCardData","BYTE[5]"},	--牌值
						},

	shidianban  =  {
						{"HashResult","CHARSTRING[64]"},
						{"itemlist","QukuailianMsg.config.shidianban_item[5]"} ,
					},
	--抢庄牛牛 todo					
	qiangzhuangniuniu_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"cbHandCardData","BYTE[5]"},	--牌值
						},
	qiangzhuangniuniu  =  {
						{"HashResult","CHARSTRING[64]"},
						{"itemlist","QukuailianMsg.config.qiangzhuangniuniu_item[5]"} ,
					},

	--十三张
	shisanzhang_item = {
							{"nickName","CHARSTRING[32]"}, --用户昵称
						   	{"m_cbHandCardData","BYTE[13]"},	--牌值
						},

	shisanzhang  =  {
						{"HashResult","CHARSTRING[64]"},
						{"itemlist","QukuailianMsg.config.shisanzhang_item[4]"} ,
					},
    --超级水果机
	chaojishuiguoji = {
							{"HashResult","CHARSTRING[64]"}, 
						   	{"m_cbResultData","BYTE[3][5]"},	--转盘结果
						},
    --水浒传
	shuihuzhuan = {
							{"HashResult","CHARSTRING[64]"}, 
						   	{"m_cbResultData","BYTE[3][5]"},	--转盘结果
						},
     --糖果派对
	tangguopaidui = {
							{"HashResult","CHARSTRING[64]"}, 
						   	{"m_cbResultData","BYTE[20]"},	--结果
						},
     --连环夺宝
	lianhuanduobao = {
							{"HashResult","CHARSTRING[64]"}, 
						   	{"m_cbResultData","BYTE[20]"},	--结果
						},

}


--两行显示hashcode
function QukuailianMsg.hashCode2Line(_hashCode)
	if device.platform == "windows" then
		local len = string.len(_hashCode)
		local str1 = string.sub(_hashCode,1,40);
		local str2 = string.sub(_hashCode,41,len);
		local str = str1.."\n"..str2;
		return str;
	else
		return _hashCode;
	end

	
end


--截取区块链显示地址内容
function QukuailianMsg.hashCode2Part(_hashCode)
	-- local len = string.len(_hashCode);

	local pos = string.find(_hashCode,"/index",1,true)
	local str1 = string.sub(_hashCode,1,pos-1);
	-- local str2 = string.sub(_hashCode,len-16,len);
	-- local str = str1.."..."..str2;

	return str1;
	-- local len = string.len(_hashCode);
	-- if len > 48 then
	-- 	local str1 = string.sub(_hashCode,1,32);
	-- 	local str2 = string.sub(_hashCode,len-16,len);
	-- 	local str = str1.."..."..str2;
	-- 	return str;
	-- end

	-- return _hashCode;
end

-- QukuailianMsg.cf2 = {
-- 						{"nickName","CHARSTRING[32]"}, 
-- 					   	{"llRedBagScore","LLONG"},
-- 					   	{"m_lUserWinScore","LLONG"}, 

-- 						}
-- QukuailianMsg.cf = {
-- 				{"HashResult","CHARSTRING[64]"},  

-- 				{"ucMinesIndex","BYTE"}, 
-- 				{"ucNum","BYTE"}, 
-- 				{"player","QukuailianMsg.cf2[10]"}
			   
-- 			}




return QukuailianMsg;