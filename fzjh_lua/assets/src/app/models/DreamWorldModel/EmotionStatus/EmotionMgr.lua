local EmotionMgr = class("EmotionMgr")

local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionAttr = DreamConst.EmotionAttr

local EmotionType = DreamConst.EmotionType

local EmotionClassPath = {
    [EmotionType.Impressed] = "app.models.DreamWorldModel.EmotionStatus.ImpressedEmotion",
    [EmotionType.Agitated] = "app.models.DreamWorldModel.EmotionStatus.AgitatedEmotion",
    [EmotionType.Calmdown] = "app.models.DreamWorldModel.EmotionStatus.CalmdownEmotion",
    [EmotionType.Ecstasy] = "app.models.DreamWorldModel.EmotionStatus.EcstasyEmotion",
    [EmotionType.Fear] = "app.models.DreamWorldModel.EmotionStatus.FearEmotion",
    [EmotionType.Sad] = "app.models.DreamWorldModel.EmotionStatus.SadEmotion",
    [EmotionType.None] = "app.models.DreamWorldModel.EmotionStatus.BaseEmotion"
}

function EmotionMgr:create(role)
    local p = EmotionMgr:new()
    p:init(role)
    return p
end

function EmotionMgr:init(role)
    self.role = role

    self.talkHistory = {}

    self.npcTalkRule = {
        talkCount = {},
        maxCount = {}
    }

    self.canNotChangeEmotionRoom = {}

    self.randomEventCoolDown = {}

    self.attrs = {
        [EmotionAttr.talkWeight1] = 0,
        [EmotionAttr.talkWeightPercent1] = 1,
        [EmotionAttr.talkWeight2] = 0,
        [EmotionAttr.talkWeightPercent2] = 1,
        [EmotionAttr.talkWeight3] = 0,
        [EmotionAttr.talkWeightPercent3] = 1,
        [EmotionAttr.talkWeight4] = 0,
        [EmotionAttr.talkWeightPercent4] = 1,
        [EmotionAttr.talkWeight5] = 0,
        [EmotionAttr.talkWeightPercent5] = 1,
        [EmotionAttr.talkWeight6] = 0,
        [EmotionAttr.talkWeightPercent6] = 1,
        [EmotionAttr.talkWeight7] = 0,
        [EmotionAttr.talkWeightPercent7] = 1,
        [EmotionAttr.randomEventWeight1] = 0,
        [EmotionAttr.randomEventWeightPercent1] = 1,
        [EmotionAttr.randomEventWeight2] = 0,
        [EmotionAttr.randomEventWeightPercent2] = 1,
        [EmotionAttr.randomEventWeight3] = 0,
        [EmotionAttr.randomEventWeightPercent3] = 1,
        [EmotionAttr.randomEventWeight4] = 0,
        [EmotionAttr.randomEventWeightPercent4] = 1,
        [EmotionAttr.randomEventWeight5] = 0,
        [EmotionAttr.randomEventWeightPercent5] = 1,
        [EmotionAttr.randomEventWeight6] = 0,
        [EmotionAttr.randomEventWeightPercent6] = 1,
        [EmotionAttr.randomEventWeight7] = 0,
        [EmotionAttr.randomEventWeightPercent7] = 1,
        [EmotionAttr.boxEventWeight1] = 0,
        [EmotionAttr.boxEventWeightPercent1] = 1,
        [EmotionAttr.boxEventWeight2] = 0,
        [EmotionAttr.boxEventWeightPercent2] = 1,
        [EmotionAttr.boxEventWeight3] = 0,
        [EmotionAttr.boxEventWeightPercent3] = 1,
        [EmotionAttr.boxEventWeight4] = 0,
        [EmotionAttr.boxEventWeightPercent4] = 1,
        [EmotionAttr.boxEventWeight5] = 0,
        [EmotionAttr.boxEventWeightPercent5] = 1,
        [EmotionAttr.boxEventWeight6] = 0,
        [EmotionAttr.boxEventWeightPercent6] = 1,
        [EmotionAttr.boxEventWeight7] = 0,
        [EmotionAttr.boxEventWeightPercent7] = 1,
        [EmotionAttr.newFloorRate] = 0,
        [EmotionAttr.newFloorRatePercent] = 1,
        [EmotionAttr.battleWinRate] = 0,
        [EmotionAttr.battleWinRatePercent] = 1,
        [EmotionAttr.battleLoseRate] = 0,
        [EmotionAttr.battleLoseRatePercent] = 1,
        [EmotionAttr.fightWinRate] = 0,
        [EmotionAttr.fightWinRatePercent] = 1,
        [EmotionAttr.fightLoseRate] = 0,
        [EmotionAttr.fightLoseRatePercent] = 1,
        [EmotionAttr.talkRate] = 0,
        [EmotionAttr.talkRatePercent] = 1,
        [EmotionAttr.randEventRate] = 0,
        [EmotionAttr.randEventRatePercent] = 1
    }

    self.buffAttr = {}

    if MapIsEmpty(self.role.emotion) == false then
        local type = self.role.emotion.type
        local path = switch(type, EmotionClassPath)
        local EmotionClass = require(path)
        self.currEmotion = EmotionClass:create(self.role, self)
    else
        local EmotionClass = require("app.models.DreamWorldModel.EmotionStatus.BaseEmotion")
        self.currEmotion = EmotionClass:create(self.role, self)
    end
end

function EmotionMgr:changeEmotion(type)
    if self.currEmotion.type == type then
        return
    end

    if self.currEmotion ~= nil then
        self.currEmotion:exit()
    end

    local oldEmotion = self.currEmotion.type

    local newEmotion = type

    local path = switch(type, EmotionClassPath)

    local EmotionClass = require(path)

    local nextEmotion = EmotionClass:create(self.role, self)

    nextEmotion:enter()

    --@RefType[BaseEmotion]
    self.currEmotion = nextEmotion

    self.role:dispatchEvent("EmotionChangeEvent", {newEmotionType = newEmotion, oldEmotionType = oldEmotion})
end

--@desc: 随机更换自身情绪（不能是当前情绪）
function EmotionMgr:randomChangeEmotion()
    local currEmotionType = self.currEmotion.type
    local weightList = {}
    for k,v in pairs(EmotionType) do
        if v == currEmotionType then
            weightList[v] = 0
        else
            weightList[v] = 1
        end
    end
    local randomEmotionType = Helper:RandomByWeight(weightList)
    print("当前情绪类型 = ",currEmotionType,"随机情绪类型 = ",randomEmotionType)
    self:changeEmotion(randomEmotionType)
end

--@desc: 获取当前的情绪状态
--@author:Seven_L
--@time:2020-06-22 16:08:40
--@return [BaseEmotion]
function EmotionMgr:getCurrEmotion()
    return self.currEmotion
end

function EmotionMgr:getTalkHistory()
    return self.talkHistory
end

function EmotionMgr:talk(context)
    local target = context.target

    local talkRule = EmotionUtil:getTalkRule()

    if talkRule[target.id] ~= nil then
        if self.npcTalkRule.maxCount[target.id] == nil then
            local strList = string.split(talkRule[target.id].talkMax, ";")
            if strList[1] == nil or strList[2] == nil then
                error("Emotion表中talkRule中npc：" .. target.id .. "规则填写错误")
            end
            local count = math.random(tonumber(strList[1]), tonumber(strList[2]))

            self.npcTalkRule.maxCount[target.id] = count
        end

        if self.npcTalkRule.talkCount[target.id] == nil then
            self.npcTalkRule.talkCount[target.id] = 0
        end

        if self.npcTalkRule.talkCount[target.id] >= self.npcTalkRule.maxCount[target.id] then
            print("该npc已达最大交谈次数，已交谈次数：" .. self.npcTalkRule.talkCount[target.id], "最大次数：" .. self.npcTalkRule.maxCount[target.id])
            RichPrint("main", target.name .. "不愿与你交谈")
            return
        end
    end

    local data = self.currEmotion:getTalkData(context)

    --@desc 该句次数达到输出的最大值时固定输出，也不会触发任何效果
    if data == nil then
        RichPrint("main", target.name .. "不愿与你交谈")
    else
        local str = data.text
        RichPrint("main", "YEL" .. Helper:getDef(target.name, "") .. "：" .. Helper:getDef(str, ""))

        if self.talkHistory[data.id] == nil then
            self.talkHistory[data.id] = 0
        end

        self.talkHistory[data.id] = self.talkHistory[data.id] + 1

        if self.npcTalkRule.maxCount[target.id] ~= nil and self.npcTalkRule.maxCount[target.id] > 0 then
            self.npcTalkRule.talkCount[target.id] = self.npcTalkRule.talkCount[target.id] + 1
        end

        --@desc 当前房间内只可转换一次
        local currMap = context.map
        if self.canNotChangeEmotionRoom[context.roomId] == nil then
            local changeEmotionRate =
                (self.currEmotion.luaData.talkRate + self:getAttr(EmotionAttr.talkRate) + self.role:getFinalAttr(EmotionAttr.talkRate)) *
                (self:getAttr(EmotionAttr.talkRatePercent) + self.role:getFinalAttr(EmotionAttr.talkRatePercent))
            if changeEmotionRate >= math.random(1, 100) then
                self:changeEmotion(data.emotionId)
                self.canNotChangeEmotionRoom[context.roomId] = true
            end
        end

        self:_triggerEffect(data.effect, {role = currMap:getPlayer(), map = context.map, roomId = context.roomId})
    end
end

--@desc: 随机事件
--@author:Seven_L
--@time:2020-07-04 17:51:25
--@context: 上下文环境[map,roomId]
function EmotionMgr:triggerRandomEvent(context)
    if math.random(1, 100) > 50 then
        return false
    end

    local event = self.currEmotion:getRandomEvent(context)

    if self.randomEventCoolDown[event.id] ~= nil and self.randomEventCoolDown[event.id] > event.cooldownCount then
        self.randomEventCoolDown[event.id] = nil
    end

    --@desc 冷却中不触发
    if event.cooldownCount > 0 and self.randomEventCoolDown[event.id] ~= nil and self.randomEventCoolDown[event.id] < event.cooldownCount then
        return false
    end

    if self:_triggerEffect(event.effects, {role = context.map:getPlayer(), map = context.map, roomId = context.roomId}) then
        self.randomEventCoolDown[event.id] = 0

        RichPrint("main", event.text)

        --@desc 当前房间内只可转换一次
        local currMap = context.map
        if self.canNotChangeEmotionRoom[context.roomId] == nil then
            local changeEmotionRate =
                (self.currEmotion.luaData.randEventRate + self:getAttr(EmotionAttr.randEventRate) + self.role:getFinalAttr(EmotionAttr.randEventRate)) *
                (self:getAttr(EmotionAttr.randEventRatePercent) + self.role:getFinalAttr(EmotionAttr.randEventRatePercent))

            if changeEmotionRate >= math.random(1, 100) then
                self:changeEmotion(event.emotionId)
                self.canNotChangeEmotionRoom[context.roomId] = true
            end
        end

    end

    return true
end

--@desc: 开箱事件
--@author:Seven_L
--@time:2020-07-06 14:59:33
--@context: 开箱时环境
function EmotionMgr:triggerOpenBoxEvent(context)
    local event = self.currEmotion:getOpenBoxEvent(context)

    if self:_triggerEffect(event.effects, {role = context.map:getPlayer(), map = context.map, roomId = context.roomId}) then
        local currMap = context.map
        --@desc 把文本中特殊字符装换成npc名字
        local targetName = context.target.name
        local StringUtil = require("app.extends.StringUtil")
        local text = StringUtil:replaceNpcName(event.text, currMap, targetName)
        
        RichPrint("main", text)
        
        --@desc 当前房间内只可转换一次
        local room = currMap:getRoomById(context.roomId)
        if self.canNotChangeEmotionRoom[context.roomId] == nil then
            local changeEmotionRate =
                (self.currEmotion.luaData.randEventRate + self:getAttr(EmotionAttr.randEventRate) + self.role:getFinalAttr(EmotionAttr.randEventRate)) *
                (self:getAttr(EmotionAttr.randEventRatePercent) + self.role:getFinalAttr(EmotionAttr.randEventRatePercent))
            if changeEmotionRate >= math.random(1, 100) then
                self:changeEmotion(event.emotionId)
                self.canNotChangeEmotionRoom[context.roomId] = true
            end
        end


    end
end

--@desc: 进入了新楼层
--@author:Seven_L
--@time:2020-07-06 14:31:46
--@context:
function EmotionMgr:enterNewFloor(context)
    --@desc 进入新楼层，npc对话历史需清除
    self.talkHistory = {}

    self.npcTalkRule = {
        talkCount = {},
        maxCount = {}
    }

    self.canNotChangeEmotionRoom = {}

    self.randomEventCoolDown = {}

    --@desc 情绪转换
    local changeEmotionRate =
        (self.currEmotion.luaData.newFloorRate + self:getAttr(EmotionAttr.newFloorRate) + self.role:getFinalAttr(EmotionAttr.newFloorRate)) *
        (self:getAttr(EmotionAttr.newFloorRatePercent) + self.role:getFinalAttr(EmotionAttr.newFloorRatePercent))
    if changeEmotionRate >= math.random(1, 100) then
        local emotionList = EmotionUtil:getEmotionsArray()
        local emotionId = emotionList[math.random(1, #emotionList)]
        self:changeEmotion(emotionId)
        self.canNotChangeEmotionRoom[context.roomId] = true
    end
end

--@desc 切磋完成
function EmotionMgr:battleFinish(context)
    if self.canNotChangeEmotionRoom[context.roomId] == true then
        return
    end

    local battelResult = context.winTeamId

    local changeEmotionRate

    if battelResult == 1 then
        changeEmotionRate =
            (self.currEmotion.luaData.battleWinRate + self:getAttr(EmotionAttr.battleWinRate) + self.role:getFinalAttr(EmotionAttr.battleWinRate)) *
            (self:getAttr(EmotionAttr.battleWinRatePercent) + self.role:getFinalAttr(EmotionAttr.battleWinRatePercent))
    elseif battelResult == 2 then
        changeEmotionRate =
            (self.currEmotion.luaData.battleLoseRate + self:getAttr(EmotionAttr.battleLoseRate) + self.role:getFinalAttr(EmotionAttr.battleLoseRate)) *
            (self:getAttr(EmotionAttr.battleLoseRatePercent) + self.role:getFinalAttr(EmotionAttr.battleLoseRatePercent))
    else
        print("切磋逃跑。。。。无事发生")
        return
    end

    if changeEmotionRate >= math.random(1, 100) then
        local emotionList = EmotionUtil:getEmotionsArray()
        local emotionId = emotionList[math.random(1, #emotionList)]
        self:changeEmotion(emotionId)
        self.canNotChangeEmotionRoom[context.roomId] = true
    end
end

--@desc 决斗完成
function EmotionMgr:fightFinish(context)
    if self.canNotChangeEmotionRoom[context.roomId] == true then
        return
    end

    local fightResult = context.winTeamId
    local changeEmotionRate
    if fightResult == 1 then
        changeEmotionRate =
            (self.currEmotion.luaData.fightWinRate + self:getAttr(EmotionAttr.fightWinRate) + self.role:getFinalAttr(EmotionAttr.fightWinRate)) *
            (self:getAttr(EmotionAttr.fightWinRatePercent) + self.role:getFinalAttr(EmotionAttr.fightWinRatePercent))
    elseif fightResult == 2 then
        changeEmotionRate =
            (self.currEmotion.luaData.fightLoseRate + self:getAttr(EmotionAttr.fightLoseRate) + self.role:getFinalAttr(EmotionAttr.fightLoseRate)) *
            (self:getAttr(EmotionAttr.fightLoseRatePercent) + self.role:getFinalAttr(EmotionAttr.fightLoseRatePercent))
    else
        print("决斗逃跑。。。。无事发生")
        return
    end

    if changeEmotionRate >= math.random(1, 100) then
        local emotionList = EmotionUtil:getEmotionsArray()
        local emotionId = emotionList[math.random(1, #emotionList)]
        self:changeEmotion(emotionId)
        self.canNotChangeEmotionRoom[context.roomId] = true
    end
end

--@desc 进入战斗事件
function EmotionMgr:enterFightEvent()
    self.currEmotion:enterFightEvent()
end

--@desc:效果触发
--@author:Seven_L
--@time:2020-07-06 14:14:05
--@effectStr: 效果id列表（“1;2;3;4”）
--@context: 上下文环境
function EmotionMgr:_triggerEffect(effectStr, context)
    if effectStr == nil or effectStr == 0 then
        print("无效果触发")
        return false
    end

    local list = string.split(effectStr, ";")

    if MapIsEmpty(list) == true then
        print("无效果触发")
        return false
    end

    local DreamEffects = require("app.models.DreamWorldModel.DreamEffects")

    for i, effectId in ipairs(list) do
        DreamEffects:triggerEffect(effectId, context)
    end

    return true
end

function EmotionMgr:enterRoom(map, roomId)
    if MapIsEmpty(self.randomEventCoolDown) == false then
        for eventId, count in pairs(self.randomEventCoolDown) do
            self.randomEventCoolDown[eventId] = self.randomEventCoolDown[eventId] + 1
        end
    end
end

function EmotionMgr:leaveRoom(map, roomId)
    if self.canNotChangeEmotionRoom[roomId] == true then
        self.canNotChangeEmotionRoom[roomId] = nil
    end
end

--@desc 获取基础值
function EmotionMgr:getBaseAttr(attrType)
    return Helper:getDef(self.attrs[attrType], 0)
end

--@desc: 获取属性值
--@author:Seven_L
--@time:2020-07-08 14:23:31
function EmotionMgr:getAttr(attrType)
    if self.attrs[attrType] == nil then
        error("EmotionMgr 属性未定义 ： " .. attrType)
    end
    return Helper:getDef(self.attrs[attrType], 0) + Helper:getDef(self.buffAttr[attrType], 0)
end

function EmotionMgr:addBuffAttr(attrType, value)
    if self.buffAttr[attrType] ~= nil then
        self.buffAttr[attrType] = self.buffAttr[attrType] + value
    else
        self.buffAttr[attrType] = value
    end
end

--@desc: 获取因情绪带来的攻击失败文本
--@author:Seven
--@time:2020-08-10 15:03:54
function EmotionMgr:getAttackFailDesc()
    return self.currEmotion:getAttackFailDesc()
end

function EmotionMgr:getAttackAddPercentDesc()
    return self.currEmotion:getAttackAddPercentDesc()
end

function EmotionMgr:getTargetAttackFailDesc()
    return self.currEmotion:getTargetAttackFailDesc()
end

function EmotionMgr:getBeHitAtkAddDesc()
    return self.currEmotion:getBeHitAtkAddDesc()
end

function EmotionMgr:getTiliConsumeDesc()
    return self.currEmotion:getTiliConsumeDesc()
end

function EmotionMgr:destory()
    self.currEmotion:destory()
end

--@desc: 序列化
--@author:Seven_L
--@time:2020-07-06 14:10:02
function EmotionMgr:serialization()
    self.role.emotion = {
        type = self.currEmotion:getType()
    }
end

return EmotionMgr
000000