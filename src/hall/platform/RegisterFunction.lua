
function registerLuaFunctions()
    if device.platform == "ios" then
        local args = {onWXResp = onWXResp,
                    getVersion = getVersion,
                    doIAPVerifyHttpRequest = doIAPVerifyHttpRequest,
                    OnJoinRoom = OnJoinRoom,
                    OnStatusUpdate = OnStatusUpdate,
                    OnQuitRoom = OnQuitRoom,
                    OnUploadFile = OnUploadFile,
                    OnDownloadFile = OnDownloadFile,
                    OnPlayRecordedFile = OnPlayRecordedFile,
                    OnApplyMessageKey = OnApplyMessageKey,
                    OnSpeechToText = OnSpeechToText,
                    OnRecording = OnRecording,
                    OnStreamSpeechToText = OnStreamSpeechToText,
                    onBaiDuResp = onBaiDuResp,
                    AutoLoginFormWeb = AutoLoginFormWeb,
                    writePackageType = writePackageType,
                    connectToServer = connectToServer,
                    initQsuSDK = initQsuSDK,
                }

        local ok,ret  = luaCallFun.callStaticMethod("MethodForLua","registerLuaListener",args)

        if ok == false then
            luaPrint("ios registerLuaListener  error")
        end
        
    elseif device.platform == "android" then
    
    end
end