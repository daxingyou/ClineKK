local Common = {}


--入场限制
Common.EntryLimit ={
	5000,20000,50000,100000
}

--小盲注
Common.SmallBlind ={
	50,200,500,1000,
}

--大盲注
Common.BigBlind ={
	100,400,1000,2000,
}


Common.BET_CALL = 1; --下注跟注
Common.BET_RAISE = 2; --加注
Common.BET_ALLIN = 3; --全下









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
	 
	    -- local flagShaderByteArray = "#ifdef GL_ES \n" ..
	    --     "precision mediump float; \n" ..
	    --     "#endif \n" ..
	    --     "varying vec4 v_fragmentColor; \n" ..
	    --     "varying vec2 v_texCoord; \n" ..
	    --     "void main(void) \n" ..
	    --     "{ \n" ..
	    --     "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
	    --     "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..
	    --     "gl_FragColor.w = c.w; \n"..
	    --     "}"
	   	
	    local flagShaderByteArray = "#ifdef GL_ES \n" ..
	        "precision mediump float; \n" ..
	        "#endif \n" ..
	        "varying vec4 v_fragmentColor; \n" ..
	        "varying vec2 v_texCoord; \n" ..
	        "void main(void) \n" ..
	        "{ \n" ..
	        "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
	        "gl_FragColor.xyz = vec3(0.3*c.r + 0.25*c.g +0.25*c.b); \n"..
	        "gl_FragColor.w = c.w; \n"..
	        "}"
	   	--(0.3*c.r + 0.15*c.g +0.11*c.b)

 

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