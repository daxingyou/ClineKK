local Audio = {}

local GAME_AUDIO_ROOT = "sound/"

-- 赢
function Audio.playWin()
	audio.playSound(GAME_AUDIO_ROOT.."win.mp3")
end

-- 输
function Audio.playLose()
	audio.playSound(GAME_AUDIO_ROOT.."lose.mp3")
end

-- 平
function Audio.playPing()
	audio.playSound(GAME_AUDIO_ROOT.."ping.mp3")
end

-- 发牌 牌
function Audio.playDispathCard()
	audio.playSound(GAME_AUDIO_ROOT.."flop.mp3")
end

-- 发牌
function Audio.startFaPai()
	audio.playSound(GAME_AUDIO_ROOT.."start.mp3")
end

--枪声
function Audio.playdaqiang1()
	audio.playSound(GAME_AUDIO_ROOT.."daqiang3.mp3")
end

--全垒打音效
function Audio.playQLDYX()
	audio.playSound(GAME_AUDIO_ROOT.."QuanLeiDa.mp3")
end

-- 牌型
function Audio.playCardType(cardType, isBoy)
	audio.playSound(GAME_AUDIO_ROOT..(isBoy and "M/" or "W/")..string.format("common%d.mp3", cardType+1))
end

-- 特殊牌型
function Audio.playCardTypeS(cardType, isBoy)
	audio.playSound(GAME_AUDIO_ROOT..(isBoy and "M/" or "W/")..string.format("teshu%d.mp3", cardType))
end

-- 全垒打
function Audio.playqld(isBoy)
	audio.playSound(GAME_AUDIO_ROOT..(isBoy and "M/" or "W/").."special1.mp3")
end

--开始比牌
function Audio.startBiPai(isBoy)
	audio.playSound(GAME_AUDIO_ROOT..(isBoy and "M/" or "W/").."start_compare.mp3")
end

--打枪 人
function Audio.playdaqiang(isBoy)
	audio.playSound(GAME_AUDIO_ROOT..(isBoy and "M/" or "W/").."daqiang1.mp3")
end

return Audio
