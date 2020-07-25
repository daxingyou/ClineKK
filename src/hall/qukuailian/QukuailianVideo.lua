local QukuailianVideo = class("QukuailianVideo",PopLayer)

local winSize = cc.Director:getInstance():getWinSize();

function QukuailianVideo:ctor()
	self.super.ctor(self,PopType.none)

	self:initUI()

end

function QukuailianVideo:initUI()
	local closeBtn = ccui.Button:create("common/close.png","common/close-on.png")
    closeBtn:setPosition(winSize.width-50,winSize.height-50);
    self:addChild(closeBtn);

    closeBtn:onClick(handler(self,function(sender)  self:delayCloseLayer(0) end));
end

function QukuailianVideo:onEnter()
	self.super.onEnter(self);
	
	if device.platform ~= "windows" then
        videoPlayer = ccexp.VideoPlayer:create()
        videoPlayer:setAnchorPoint(cc.p(0.5,0.5))
        videoPlayer:setContentSize(cc.size(winSize.width*0.85,winSize.height*0.85))
        videoPlayer:setPosition(cc.p(winSize.width/2,winSize.height/2))
        self:addChild(videoPlayer)

        if nil ~= videoPlayer then
               videoPlayer:setFileName("qukuailian/image2/help.mp4")   
               videoPlayer:play()
        end
    end  

end


return QukuailianVideo
