local class = require("third.class.NewClass")
local EmotionMgr = require("app.models.DreamWorldModel.EmotionStatus.EmotionMgr")
local FondDreamEmotionMgr = {}

function FondDreamEmotionMgr:create(role)
    local p = FondDreamEmotionMgr:new()
    p:_init(role)
    return p
end

function FondDreamEmotionMgr:_init(role)
    role.emotion = {}

    self:init(role)
end

function FondDreamEmotionMgr:changeEmotion(type)
end

--@desc: 随机更换自身情绪（不能是当前情绪）
function FondDreamEmotionMgr:randomChangeEmotion()
end

--@desc: 获取当前的情绪状态
--@author:Seven_L
--@time:2020-06-22 16:08:40
--@return [BaseEmotion]
function FondDreamEmotionMgr:getCurrEmotion()
    return self.currEmotion
end

function FondDreamEmotionMgr:getTalkHistory()
    return {}
end

function FondDreamEmotionMgr:talk(context)
end

function FondDreamEmotionMgr:triggerRandomEvent(context)
    return false
end

function FondDreamEmotionMgr:triggerOpenBoxEvent(context)
end

--@desc: 进入了新楼层
--@author:Seven_L
--@time:2020-07-06 14:31:46
--@context:
function FondDreamEmotionMgr:enterNewFloor(context)
end

--@desc 切磋完成
function FondDreamEmotionMgr:battleFinish(context)
end

--@desc 决斗完成
function FondDreamEmotionMgr:fightFinish(context)
end

--@desc 进入战斗事件
function FondDreamEmotionMgr:enterFightEvent()
end

--@desc:效果触发
--@author:Seven_L
--@time:2020-07-06 14:14:05
--@effectStr: 效果id列表（“1;2;3;4”）
--@context: 上下文环境
function FondDreamEmotionMgr:_triggerEffect(effectStr, context)
    return false
end

function FondDreamEmotionMgr:enterRoom(map, roomId)
end

function FondDreamEmotionMgr:leaveRoom(map, roomId)
end

--@desc 获取基础值
function FondDreamEmotionMgr:getBaseAttr(attrType)
    return 0
end

--@desc: 获取属性值
--@author:Seven_L
--@time:2020-07-08 14:23:31
function FondDreamEmotionMgr:getAttr(attrType)
    return 0
end

function FondDreamEmotionMgr:addBuffAttr(attrType, value)
end

--@desc: 获取因情绪带来的攻击失败文本
--@author:Seven
--@time:2020-08-10 15:03:54
function FondDreamEmotionMgr:getAttackFailDesc()
    return ""
end

function FondDreamEmotionMgr:getAttackAddPercentDesc()
    return ""
end

function FondDreamEmotionMgr:getTargetAttackFailDesc()
    return ""
end

function FondDreamEmotionMgr:getBeHitAtkAddDesc()
    return ""
end

function FondDreamEmotionMgr:getTiliConsumeDesc()
    return ""
end

function FondDreamEmotionMgr:destory()
    self.currEmotion:destory()
end

--@desc: 序列化
--@author:Seven_L
--@time:2020-07-06 14:10:02
function FondDreamEmotionMgr:serialization()
    self.role.emotion = {
        type = self.currEmotion:getType()
    }
end

return class("FondDreamEmotionMgr", { EmotionMgr }, FondDreamEmotionMgr)
00000