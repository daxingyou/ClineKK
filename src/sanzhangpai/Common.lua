local Common = {}


Common.STATUS_IDLE	  = 0;  --虚席以待
Common.STATUS_WAITING = 1;  --旁观等待
Common.STATUS_PLAYING = 2;	--游戏中
Common.STATUS_FOLDED = 3;	--弃牌
Common.STATUS_LOST   = 4;	--比牌失败
Common.STATUS_ALLIN  = 5;   --全下
Common.STATUS_COMPARE_REQ  = 6;   --请求比牌
Common.STATUS_COMPARE  = 7;   --比牌



Common.TIP_FOLD 	= 0;	--弃牌
Common.TIP_BET	 	= 1;	--下注
Common.TIP_RAISE 	= 2;	--加注
Common.TIP_FOLLOW 	= 3;	--跟注
Common.TIP_CARD 	= 4;	--亮牌
Common.TIP_CHECK 	= 5;	--看牌
Common.TIP_COMP 	= 6;	--比牌
Common.TIP_ALLIN 	= 7;	--全下





-- GameMsg.TYPE_GIVE_UP	= 0x00;		--放弃
-- GameMsg.TYPE_NOTE		= 0x01;		--下注
-- GameMsg.TYPE_ADD		= 0x02;		--加注
-- GameMsg.TYPE_FOLLOW		= 0x03;		--跟注
-- GameMsg.TYPE_OPENCARD	= 0x04;		--开牌
-- GameMsg.TYPE_LOOKCARD	= 0x05;		--看牌
-- GameMsg.TYPE_NORMAL		= 0x06;		--正常状态


Common.TIP_RES = {
	"szp_xiazhude.png",	--下注
	"szp_jiazhutishi.png",	--加注
	"szp_genzhutishi.png",	--跟注
	"szp_liangpaitishi.png",	--亮牌
	"szp_kanpaitishi.png",	--看牌
	"szp_bipaitishi.png",   --比牌
	"szp_quanxiatishi.png",	--全下
	
}

Common.TIP_RES[0] = "szp_qipaitishi.png";  --弃牌

--下注筹码配置
Common.BetGameTb ={
	{0.2,0.4,0.6,0.8,1.0},
	{2,4,6,8,10},
	{20,40,60,80,100},
	{100,200,300,400,500},
}

-- Common.BetTb ={
-- 	{10,20,30,40,50},
-- 	{100,200,300,400,500},
-- 	{500,1000,1500,2000,2500},
-- 	{1000,2000,3000,4000,5000},
-- }

Common.BetTb ={
	{20,40,60,80,100},
	{200,400,600,800,1000},
	{2000,4000,6000,8000,10000},
	{10000,20000,30000,40000,50000},
}

Common.BetBase = {
	-- 10,100,500,1000
	10,100,1000,5000  -- 0.1,1,10,50
}




Common.CHIP_IMG = {
	"szp_chouma1.png",
	"szp_chouma2.png",
	"szp_chouma3.png",
	"szp_chouma4.png",
	"szp_chouma5.png",
	"szp_chouma6.png",
	"szp_chouma7.png",
	"szp_chouma8.png",
	"szp_chouma9.png",
	"szp_chouma10.png",
	"szp_chouma1.png",
}


--游戏消息
Common.EVT_DEAL_MSG = "EVT_DEAL_MSG";
--动画消息
Common.EVT_VIEW_MSG = "EVT_VIEW_MSG";

Common.ACTION_BEGIN = "ACTION_BEGIN";
Common.ACTION_END = "ACTION_END";


--游戏房间等待
Common.MSG_TABLE_FREE = 101;
--游戏房间发牌
Common.MSG_TABLE_SEND = 102;
--游戏进行中
Common.MSG_TABLE_PLAYING = 103;
--游戏开始
Common.MSG_BEGIN_GAME = 104;
--开始发牌
Common.MSG_SEND_CARD = 105;
--开始下注
Common.MSG_BEGIN_BET = 106;
--玩家下注
Common.MSG_PLAYER_BET = 107;
--通知玩家下注
Common.MSG_TURN_BET	  = 108;
--玩家看牌
Common.MSG_CHECK_CARD = 109;
--游戏结束
Common.MSG_GAME_END = 110;
--比牌结果
Common.MSG_COMP_CARD = 111;
--亮牌
Common.MSG_EVEAL_CARD = 112;
--全局比牌
Common.MSG_ALL_COMPARE = 113;
--比牌请求
Common.MSG_REQ_COMPARE = 114;
--比牌亮牌
Common.MSG_OPPONENT_CARD = 115;
--自动跟注
Common.MSG_AUTO_BET 	 = 116;

Common.colorGray = cc.c3b(128, 128, 128); 
Common.colorNormal = cc.c3b(255, 255, 255);

function Common.setGray(image,bGray)

	-- local sprite = image:getVirtualRenderer():getSprite()
	-- if sprite then
	-- 	if bGray then
	-- 		sprite:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("SHADER_NAME_POSITION_GRAYSCALE")))
	-- 	else
	-- 		sprite:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")))
	-- 	end
		
	-- end


	if bGray then
		image:setColor(Common.colorGray);
	else
		image:setColor(Common.colorNormal);	
	end
end



function Common.setImageGray(image,bGray)
	local sprite = image:getVirtualRenderer():getSprite()
	if bGray then
		local vertShaderByteArray = "\n"..
	        "attribute vec4 a_position; \n" ..
	        "attribute vec2 a_texCoord; \n" ..
	        "attribute vec4 a_color; \n"..
	        "#ifdef GL_ES  \n"..
	        "varying lowp vec4 v_fragmentColor;\n"..
	        "varying mediump vec2 v_texCoord;\n"..
	        "#else                      \n" ..
	        "varying vec4 v_fragmentColor; \n" ..
	        "varying vec2 v_texCoord;  \n"..
	        "#endif    \n"..
	        "void main() \n"..
	        "{\n" ..
	        "gl_Position = CC_PMatrix * a_position; \n"..
	        "v_fragmentColor = a_color;\n"..
	        "v_texCoord = a_texCoord;\n"..
	        "}"
	 
	    local flagShaderByteArray = "#ifdef GL_ES \n" ..
	        "precision mediump float; \n" ..
	        "#endif \n" ..
	        "varying vec4 v_fragmentColor; \n" ..
	        "varying vec2 v_texCoord; \n" ..
	        "void main(void) \n" ..
	        "{ \n" ..
	        "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
	        "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..
	        "gl_FragColor.w = c.w; \n"..
	        "}"
	    local glProgram = cc.GLProgram:createWithByteArrays(vertShaderByteArray,flagShaderByteArray)
	    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
	    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
	    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
	    glProgram:link()
	    glProgram:updateUniforms()
	    sprite:setGLProgram( glProgram )
	else
		sprite:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")))
	end

end


function Common.delayBtnEnable(btn,dt)
	btn:stopAllActions();
	if dt == nil then
		dt = 1.0
	end
	local actionCallback = cc.CallFunc:create(function (sender)
			btn:setTouchEnabled(true);
	end)

	btn:setTouchEnabled(false);
	local delayIt = cc.DelayTime:create(dt)
	local action = cc.Sequence:create(delayIt,actionCallback)
	btn:runAction(action);
end



--申请列表
function Common.getCoinStr(lCoin)
	if not lCoin then
		luaPrint("lCoin error:",lCoin);
		return "";
	end
	-- local str = math.ceil(lCoin/100);
 --    return tostring(str);
 	if not tagStr then
 		tagStr = "";
 	end

    local remainderNum = lCoin%100;
	local remainderString = "";
	

	-- if remainderNum == 0 then--保留2位小数
	-- 	remainderString = "";
	-- else
	-- 	if remainderNum%10 == 0 then
	-- 		remainderString = remainderString.."0";
	-- 	end
	-- end

	return tagStr..(lCoin/100)..remainderString;
end



return Common;