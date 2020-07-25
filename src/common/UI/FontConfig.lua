local FontConfig = {}

FontConfig.colorGold 		= cc.c3b(255, 215, 72);                              --//金色
FontConfig.colorYellow 		= cc.c3b(255, 255, 0);                               --//黄色
FontConfig.colorGreen 		= cc.c3b(0, 255, 0);								 --//绿色
FontConfig.colorMagenta 	= cc.c3b(255, 0, 255);							   	 --//紫红色
FontConfig.colorBlue 		= cc.c3b(0, 0, 255);								 --//蓝色
FontConfig.colorOrange 		= cc.c3b(255, 165, 0);                               --//橙色
FontConfig.colorWhite 		= cc.c3b(255, 255, 255);                             --//白色
FontConfig.colorRed 		= cc.c3b(255, 0, 0);                                 --//红色
FontConfig.colorBlack 		= cc.c3b(0, 0, 0);                                   --//黑色
FontConfig.colorGray 		= cc.c3b(128, 128, 128);                             --//灰色

FontConfig.gFontFile = "fonts/DroidSansFallback.ttf";           --//字体文件名称

FontConfig.gFontConfig_50 = {fontFilePath = FontConfig.gFontFile, fontSize = 50};    --//房间名称30号字
FontConfig.gFontConfig_40 = {fontFilePath = FontConfig.gFontFile, fontSize = 40};    --//房间名称30号字
FontConfig.gFontConfig_30 = {fontFilePath = FontConfig.gFontFile, fontSize = 30};    --//房间名称30号字
FontConfig.gFontConfig_28 = {fontFilePath = FontConfig.gFontFile, fontSize = 28};    --//房间名称28号字
FontConfig.gFontConfig_26 = {fontFilePath = FontConfig.gFontFile, fontSize = 26};    --//房间名称28号字
FontConfig.gFontConfig_25 = {fontFilePath = FontConfig.gFontFile, fontSize = 25};    --//房间名称25号字
FontConfig.gFontConfig_24 = {fontFilePath = FontConfig.gFontFile, fontSize = 24};    --//房间名称25号字
FontConfig.gFontConfig_22 = {fontFilePath = FontConfig.gFontFile, fontSize = 22};    --//普通信息22号字
FontConfig.gFontConfig_20 = {fontFilePath = FontConfig.gFontFile, fontSize = 20};    --//玩家信息20号字
FontConfig.gFontConfig_18 = {fontFilePath = FontConfig.gFontFile, fontSize = 18};    --//房间名称18号字
FontConfig.gFontConfig_16 = {fontFilePath = FontConfig.gFontFile, fontSize = 16};    --//玩家信息16号字
FontConfig.gFontConfig_14 = {fontFilePath = FontConfig.gFontFile, fontSize = 14};    --//玩家信息14号字
FontConfig.gFontConfig_12 = {fontFilePath = FontConfig.gFontFile, fontSize = 12};    --//玩家信息12号字
FontConfig.gFontConfig_10 = {fontFilePath = FontConfig.gFontFile, fontSize = 10};    --//玩家信息10号字

function FontConfig.createLabel(ttfConfig, text, color)
	color = color or colorWhite;

	local label = cc.LabelTTF:create(text, ttfConfig.fontFilePath, ttfConfig.fontSize);
	label:setColor(color)

	return label;
end

--创建ttf
--text 				文字
--fontFilePath 		ttf文件路径
--fontSize 			字体大小
--dimensions 		label尺寸
--hA 				水平对齐方式
--vA 				垂直对齐方式
function FontConfig.createWithTTF(text, fontFilePath, fontSize, dimensions, hA, vA)
	local label = nil
	local ttf = ""

	if isEmptyString(fontFilePath) then
		ttf = "fonts/DroidSansFallback.ttf"
	else
		ttf = fontFilePath
	end

	if isEmptyString(text) then
		text = ""
	end

	if type(text) == "number" then
		text = tostring(text)
	end

	if isEmptyString(fontSize) then
		fontSize = 20
	end

	if isEmptyTable(dimensions) then
		dimensions = cc.size(0,0)
	end

	hA = hA or cc.TEXT_ALIGNMENT_CENTER
	vA = vA or cc.VERTICAL_TEXT_ALIGNMENT_CENTER

	label = cc.Label:createWithTTF(text, ttf, fontSize, dimensions, hA, vA)

	return label
end

--创建系统字体标签
--text 				文字
--font 				字体
--fontSize 			字体大小
--dimensions 		label尺寸
--hA 				水平对齐方式
--vA 				垂直对齐方式
function FontConfig.createWithSystemFont(text, fontSize, color, dimensions, font, hA, vA)
	if isEmptyString(text) then
		text = ""
	end

	if type(text) == "number" then
		text = tostring(text)
	end

	if isEmptyString(font) then
		font = "Arial"
	end

	if isEmptyString(fontSize) then
		fontSize = 20
	end

	if isEmptyTable(dimensions) then
		dimensions = cc.size(0,0)
	end

	hA = hA or cc.TEXT_ALIGNMENT_CENTER
	vA = vA or cc.VERTICAL_TEXT_ALIGNMENT_CENTER

	local label = cc.Label:createWithSystemFont(text, font, fontSize, dimensions, hA, vA)
	if color then
		label:setColor(color)
	end

	return label
end

--创建数字标签
--text 				文字
--path 				数字图片路径
--width 			单字符宽
--height 			单字符高
--startCharMap 		起始字符
--replaceChar 		替换字符 根据ascii码表 
function FontConfig.createWithCharMap(text, path, width, height, startCharMap, replaceChar)
	if isEmptyTable(replaceChar) then
		replaceChar = {}
	end

	if type(text) == "number" then
		text = tostring(text)
	end

	for k,v in pairs(replaceChar) do
		text = string.gsub(text,v[1],v[2]);
	end

	local label = cc.Label:createWithCharMap(path, width, height, string.byte(startCharMap))
	label:setString(text)
	label:setAnchorPoint(0.5,0.5)
	label.replaceChar = replaceChar

	return label
end

--数字标签设置文本
--text 	文字
--replaceChar 替换字符 根据ascii码表 此方法为新增
function cc.Label:setText(text,replaceChar)
	if isEmptyTable(replaceChar) then
		replaceChar = self.replaceChar
	end

	if type(text) == "number" then
		text = tostring(text)
	end

	if not isEmptyTable(replaceChar) then
		for k,v in pairs(replaceChar) do
			text = string.gsub(text,v[1],v[2])
		end
	end

	self:setString(text)
end

--创建fnt
--bmfontPath 	fnt路径
--text 			文字
function FontConfig.createWithBMFont(text, bmfontPath)
	local label = cc.Label:createWithBMFont(bmfontPath, text)

	return label
end

function GBKToUtf8(str)
	return str;
end

return FontConfig;
