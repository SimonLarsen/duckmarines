local MusicMgr = {}
MusicMgr.__index = MusicMgr
MusicMgr.STATE_NONE     = 0
MusicMgr.STATE_MENU     = 1
MusicMgr.STATE_INGAME   = 2
MusicMgr.STATE_MINIGAME = 3

local musicState = MusicMgr.STATE_NONE
local ingameSongs = { "factorylife", "fractalbusride", "solarsurfing", "trinitronsunset" }

function MusicMgr.playMenu()
	if musicState == MusicMgr.STATE_MENU then return end
	playMusic("groovecallus")
	musicState = MusicMgr.STATE_MENU
end

function MusicMgr.playIngame()
	if musicState == MusicMgr.STATE_INGAME then return end
	playMusic(table.random(ingameSongs))
	musicState = MusicMgr.STATE_INGAME
end

function MusicMgr.playMinigame()
	if musicState == MusicMgr.STATE_MINIGAME then return end
	playMusic("radiationwoman")
	musicState = MusicMgr.STATE_MINIGAME
end

return MusicMgr
