local RoleLife = {}
local Life_res = requireWithEncrypt("script.others.familyspecial")["Life"]

--@desc: 获取身世信息
--@author:Liang SongQiang
--@time:2018-08-03 17:50:30
--@lifeId: 身世ID
function RoleLife:getLifeInfo(lifeId)
    return assert(Life_res[lifeId], "没有身世资源，身世ID：" .. lifeId)
end

--@desc: 获取身世对应的事件ID
--@author:Liang SongQiang
--@time:2018-08-03 17:54:17
--@lifeId: 身世ID
function RoleLife:getLifeTaskId(lifeId)
    local info = self:getLifeInfo(lifeId)

    return info.eventId
end

--@desc: 获取闲聊成功话题列表
--@author:Liang SongQiang
--@time:2018-08-03 21:11:12
--@lifeId: 身世ID
function RoleLife:getSuccessChatIdList(lifeId)
    local info = self:getLifeInfo(lifeId)

    local chatStr = info.chatId

    local list = string.split(chatStr, ";")

    return list
end

--@desc: 获取闲聊失败话题列表
--@author:Liang SongQiang
--@time:2018-08-03 21:12:18
--@lifeId: 身世ID
function RoleLife:getFailChatIdList(lifeId)
    local info = self:getLifeInfo(lifeId)

    local chatStr = info.chatId1

    local list = string.split(chatStr, ";")

    return list
end

--@desc: 获取身世对应的title
--@author:Liang SongQiang
--@time:2018-08-03 21:35:26
--@lifeId:
function RoleLife:getLifeTitle(lifeId)
    local life = self:getLifeInfo(lifeId)

    return life.taskTitle
end

--@desc: 获取身世描述，根据忠诚度等级
--@author:Liang SongQiang
--@time:2018-08-04 15:43:28
--@lifeId: 身世ID
function RoleLife:getLifeInfoTextByLv(lifeId, lv)
    local life = self:getLifeInfo(lifeId)
    local tb = {
        {lv = 1, text = "lifeText1"},
        {lv = 3, text = "lifeText2"},
        {lv = 5, text = "lifeText3"}
    }

    local text = ""
    for k, v in pairs(tb) do
        if lv >= v.lv then
            text = life[v.text]
        end
    end

    return text
end

--@desc: 获取交谈文本
--@author:Liang SongQiang
--@time:2018-08-04 15:55:30
function RoleLife:getTalkText(lifeId)
    local life = self:getLifeInfo(lifeId)

    local textArr = string.split(life.talkText, ";")
    
    local text = textArr[math.random(1, #textArr)] or ""

    return text
end

--@desc: 获取身世事件后的交谈文本
--@author:Liang SongQiang
--@time:2018-08-04 15:57:38
function RoleLife:getTalkAftEventText(lifeId)
    local life = self:getLifeInfo(lifeId)

    local textArr = string.split(life.talktext1, ";")

    local text = textArr[math.random(1, #textArr)] or ""

    return text
end

--@desc: 获取身世概况
--@author:Liang SongQiang
--@time:2018-08-04 16:05:12
function RoleLife:getLifeDesc(lifeId)
    local life = RoleLife:getLifeInfo(lifeId)

    local text = life.lifeText or ""

    return text
end

--@desc: 接受身世任务界面的标题
--@author:Liang SongQiang
--@time:2018-08-04 16:43:26
function RoleLife:getDialogTitle(lifeId)
    local life = RoleLife:getLifeInfo(lifeId)

    local text = life.taskText or ""

    return text
end

--@desc: 接受身世任务时的描述文本
--@author:Liang SongQiang
--@time:2018-08-04 16:46:56
function RoleLife:getAcceptTaskText(lifeId)
    local life = RoleLife:getLifeInfo(lifeId)

    local text = life.acceptText or ""

    return text
end

--@desc:身世解锁时的描述
--@author:Liang SongQiang
--@time:2018-08-04 16:53:58
function RoleLife:getChatByLifeDesc(lifeId)
    local life = self:getLifeInfo(lifeId)

    local text = life.lifeEvent

    return text
end

return RoleLife
0000