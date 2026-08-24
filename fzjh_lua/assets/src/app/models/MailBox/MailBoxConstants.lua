local MailBoxConstants = {}

--@desc 邮件是否阅读
MailBoxConstants.UnRead = 0 
MailBoxConstants.IsRead = 1

--@desc 邮件当前类型
MailBoxConstants.NotAward = 0 --不包含奖励
MailBoxConstants.UnGetAward = 1 --包含奖励还未领取完
MailBoxConstants.GetAward = 2 --包含奖励已领取

--@desc 附件中一个物品的领取状态
MailBoxConstants.OneItemUnGet = 0 --未领取
MailBoxConstants.OneItemIsGet= 1 --已领取
MailBoxConstants.OneItemExceedLimit = 2 --超出领取条件

MailBoxConstants.StateName = {
    [MailBoxConstants.OneItemUnGet] = "未领取",
    [MailBoxConstants.OneItemIsGet] = "已领取",
    [MailBoxConstants.OneItemExceedLimit] = "逾限",
}

return MailBoxConstants0000000000000