GCloudLanguage =
{
	China       = 0,
	Korean      = 1,
	English     = 2,
	Japanese    = 3,
}
        
-- /**
--  * Mode of voice engine.
--  *
--  * You should set to one first.
    --  */
GCloudVoiceMode = 
{
	RealTime = 0, --// realtime mode for TeamRoom or NationalRoom
	Messages = 1,     --// voice message mode
	Translation = 2,  --// speach to text mode
}
        
        -- /**
        --  * Member's role for National Room.
        --  */
GCloudVoiceMemberRole =
{
    Anchor = 1, --// member who can open microphone and say
    Audience = 2,   --// member who can only hear anchor's voice
}

-- return GCloudLanguage,GCloudVoiceMode,GCloudVoiceMemberRole
