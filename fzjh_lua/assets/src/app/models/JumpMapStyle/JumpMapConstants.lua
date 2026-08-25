local JumpMapConstants = {}

JumpMapConstants.UseFailureState = {}
--副本未通关
JumpMapConstants.UseFailureState.MAP_NOT_COMPLETED = 1
--副本被禁止
JumpMapConstants.UseFailureState.MAP_FORBID = 2
--副本中处于某个状态被禁止使用遁地符
JumpMapConstants.UseFailureState.MAP_STATE_FORBID_ITEM = 3
--副本未刷新
JumpMapConstants.UseFailureState.MAP_NOT_REFRESH = 4
--五行遁法精力不足
JumpMapConstants.UseFailureState.JING_NOT_ENOUGH = 5
--五行遁法次数限制
JumpMapConstants.UseFailureState.COUNT_LIMIT = 6
--五行遁法概率失败
JumpMapConstants.UseFailureState.RATE_FAILURE = 7
--副本中处于某个状态被禁止使用五行遁法
JumpMapConstants.UseFailureState.MAP_STATE_FORBID_SKILL = 8
--跳转失败提示语
JumpMapConstants.UseFailureMsg = {
    [JumpMapConstants.UseFailureState.MAP_NOT_COMPLETED] = "当前副本未通关",
    [JumpMapConstants.UseFailureState.MAP_FORBID] = "你心想遁地前往，但不料遁地失败，看来此地无法遁行。",
    [JumpMapConstants.UseFailureState.MAP_STATE_FORBID_ITEM] = "当前不能使用遁地符",
    [JumpMapConstants.UseFailureState.MAP_STATE_FORBID_SKILL] = "当前不能使用五行遁法",
    [JumpMapConstants.UseFailureState.MAP_NOT_REFRESH] = "副本冷却中，请等待或手动重置后再执行任务",
    [JumpMapConstants.UseFailureState.JING_NOT_ENOUGH] = "您的精力不足，无法使用五行遁法",
    [JumpMapConstants.UseFailureState.COUNT_LIMIT] = "五行遁法一日只能使用四十九次，你今日使用已达上限。",
}

return JumpMapConstants00000000000