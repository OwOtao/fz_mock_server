local ChallengeMapConstant = {}

ChallengeMapConstant.EventType = {}
ChallengeMapConstant.EventType.Talk = 1
ChallengeMapConstant.EventType.ChallengeWin = 2
ChallengeMapConstant.EventType.ChallengeLose = 3
ChallengeMapConstant.EventType.ChallengeRunaway = 4
ChallengeMapConstant.EventType.ChallengeFinish = 5
ChallengeMapConstant.EventType.DuelWin = 6
ChallengeMapConstant.EventType.DuelLose = 7
ChallengeMapConstant.EventType.DuelRunaway = 8

ChallengeMapConstant.EventType.PlayerLeaveRoom = 6

ChallengeMapConstant.EventType.PlayerLeaveMap = 11
ChallengeMapConstant.EventType.PlayerInRoom = 12

ChallengeMapConstant.FlagType = {}
ChallengeMapConstant.FlagType.Map = 1
ChallengeMapConstant.FlagType.Role = 2
ChallengeMapConstant.FlagType.Player = 3
ChallengeMapConstant.FlagType.PlayerInherit = 4
ChallengeMapConstant.FlagType.TimeLimit = 5

ChallengeMapConstant.RewardType = {}
ChallengeMapConstant.RewardType.Loc_Item = 1
ChallengeMapConstant.RewardType.Loc_Attr = 2
ChallengeMapConstant.RewardType.net_Res = 3
ChallengeMapConstant.RewardType.BasicTitle = 4

ChallengeMapConstant.FinishType = {}
ChallengeMapConstant.FinishType.Normal = 1 -- 普通通关
ChallengeMapConstant.FinishType.Faster = 2 -- 快速通关

ChallengeMapConstant.MapType = {}
ChallengeMapConstant.MapType.Normal = 1 -- 普通挑战副本
ChallengeMapConstant.MapType.Festival = 2 -- 节日活动挑战副本
ChallengeMapConstant.MapType.Conceal = 3 --隐藏副本

return ChallengeMapConstant
00000000000