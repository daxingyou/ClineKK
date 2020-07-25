local MsgId = {
	MSG_EVENT_VIEW = 'MSG_EVENT_VIEW';   --游戏UI消息
	MSG_EVENT_DEAL = 'MSG_EVENT_DEAL';   --游戏消息处理

	EVT_BEGIN_MSG = 1;         --开始处理消息
	EVT_END_MSG = 2;            --处理完消息了

	TABLE_FREE = 1001,	--游戏空闲
	TABLE_PLAYING = 1002,	--游戏进行中
}


return MsgId;

