local ChatModel = {}

--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

--@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

--@RefType [src.app.models.HomelandModel.MapMeetModel.ShenShiTask#ShenShiTask]
local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")

--@desc: 闲聊对外接口
--@author:Liang SongQiang
--@time:2018-07-14 17:07:40
function ChatModel:chat(npc, map)
    --@RefType [src.app.models.role.Role#Role]
    self._npc = npc

    if self._npc:getTimeLimitFlag("chat") == 1 then
        RichPrint("main", "你刚才才与" .. self._npc.name .. "闲聊过，还是待会再来吧。")
        return
    end

    self._npc:setTimeLimitFlag("chat", 1, 5)

    self:addDuanZaoExp(npc)
    self:addExpByFirstChat(npc)
    self:addDuShuShiZiExpByFirstChat(npc)

    local addValue, random = self:getAddValueAndRandom(self._npc)

    if User:getRole():getDayFlag("chat_day_limit"..self._npc.id) == 1 then  
        PopText("闲聊忠诚度达到本日上限！")
        return
    end

    if random < math.random(1, 100) then
        local text1 = HomelandDesc:getChatText(self._npc, false)
        RichPrint("main", text1)
        return
    end

    HttpManagerEx:updateEmployRoleData(
        self._npc.id,
        map.mid,
        "chat",
        addValue,
        0,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    HomelandRoleUtil:updateFidelity(data.defaultZhongCheng, self._npc)

                    do
                        local shenShiStatus = ShenShiTask:getTaskStatus(self._npc)
                        local lv = HomelandRoleUtil:getFidelityLv(npc.defaultZhongCheng)
                        if shenShiStatus == 0 and lv == 7 then
                            ShenShiTask:unlockTask(npc,map,data.level_up,data.trait)
                            return
                        end
                    end

                    if data.day_limit == 1 then
                        User:getRole():setDayFlag("chat_day_limit"..self._npc.id,1)
                    end

                    self:chatNormalSuccess(map,data.level_up,data.trait)
                elseif errcode == 1 then
                    PopText(errmsg)
                elseif errcode == 2 then
                    RichPrint("main", "今日" .. self._npc.name .. "已经与你聊的够多了，还是明日再来吧。")
                elseif errcode == 3 then
                    do
                        --闲聊时，即使忠诚度满了，需要判断身世任务是否解锁
                        local shenShiStatus = ShenShiTask:getTaskStatus(self._npc)
                        if shenShiStatus == 0 then
                            ShenShiTask:unlockTask(npc,map)
                            return
                        end
                    end

                    local text = "YEL#ch#，" .. self._npc.name .. "如今已是对你生死与共，忠诚度无法再提升了。"
                    text = HomelandDesc:subChengHuText(text)
                    RichPrint("main", text)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 正常闲聊成功
--@author:Liang SongQiang
--@time:2018-08-02 14:20:40
--@map:[src.app.models.map.BaseMap#BaseMap]
--@isLvUp: 是否升级
function ChatModel:chatNormalSuccess(map,isLvUp,traits)
    local text = HomelandDesc:getChatText(self._npc,true)
    RichPrint("main", text)
    if isLvUp == true then
        HomelandRoleUtil:DeblockRoleTrait(self._npc, traits)
        HomelandRoleUtil:updateRoleFunc(self._npc, map)
        RichPrint("main", "经过长时间的相处，" .. self._npc.name .. "对你更为忠心了。")
    end
end


--获取人物闲聊忠诚度增长值和闲聊成功概率
--@author:Liang SongQiang
--@time:2018-07-17 14:23:52
--@npc: [src.app.models.role.Role#Role]
function ChatModel:getAddValueAndRandom(npc)
    assert(npc, "ChatModel:getSpeedZhongCheng 检查参数")

    local npcCharaFactor = HomelandRoleUtil:getCharacterFactor(npc.jobType)
    local characterAttr = HomelandRoleUtil:getCharacterAttr(npc.character)

    local gossipzhongcheng1 = npcCharaFactor.Gossipzhongcheng1
    local gossipzhongcheng = characterAttr.Gossipzhongcheng
    local value = gossipzhongcheng * gossipzhongcheng1
    local addFactor = npc:getBuffAttr("fidelityAddByChat")
    value = value + addFactor

    local gossipvalue1 = npcCharaFactor.Gossipvalue1
    local gossipvalue = characterAttr.Gossipvalue
    local random = gossipvalue * gossipvalue1
    if DEBUG_MODE == 1 then
        print("仆人特性闲聊增长忠诚度概率 = ",npc:getBuffAttr("fidelityRateByChat"))
    end
    local successFactor = npc:getBuffAttr("fidelityRateByChat")
    random = random + successFactor

    return value, random
end

--@desc 闲聊增加玩家锻造之术经验 几率统一为3%
function ChatModel:addDuanZaoExp(npc)
    local role = User:getRole()
    local addExp = npc:getBuffAttr("firstXianliaoDuanzaoExp")
    local addExpTime = role:getDayFlag("addDZZSTime"..npc.id)
    local randomNum = math.random(1,100)

    if 3 < randomNum and DEBUG_MODE ~= 1 then
        return
    end

    if addExp == 0 then
        return
    end
    
    if addExpTime >= 5 then
        print("每日闲聊获得锻造之术经验次数达到上限")
        return
    end

    --@RefType [src.app.models.role.Role#Role]
    
    local skillLv = role:getSkillLv("duanzaozhishu")
    if skillLv == 0 then
        print("你没有锻造之术，闲聊无法获得经验")
        return
    end

    role:addSkillExp("duanzaozhishu", addExp)
    role:setDayFlag("addDZZSTime"..npc.id,addExpTime + 1)
    RichPrint("main","你的锻造之术经验提升了。")
end

--@desc 每次闲聊小几率获得一定的人物经验值 几率统一为5%
function ChatModel:addExpByFirstChat(npc)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local addExpTime = role:getDayFlag("addRoleExpTime"..npc.id)
    local randomNum = math.random(1,100)

    if 5 < randomNum and DEBUG_MODE ~= 1 then
        return
    end

    if addExpTime >= 5 then
        print("每日闲聊获得经验次数达到上限")
        return
    end

    local addExp = npc:getBuffAttr("firstChatliaoExp")

    if addExp > 0 then
        role:addAttr("exp", addExp)
        role:setDayFlag("firstChat", 1)
        role:setDayFlag("addRoleExpTime"..npc.id,addExpTime + 1)
        RichPrint("main", "【经验】 + " .. addExp)
    end
end

--@desc 每次闲聊可获得读书识字经验 几率统一为3%
function ChatModel:addDuShuShiZiExpByFirstChat(npc)
    local role = User:getRole()
    local addExpTime = role:getDayFlag("addDSSZTime"..npc.id)
    local randomNum = math.random(1,100)

    if 3 < randomNum and DEBUG_MODE ~= 1 then
        return
    end

    local addExp = npc:getBuffAttr("firstXianliaoDushuExp")

    if addExp == 0 then
        return
    end

    if addExpTime >= 5 then
        print("每日闲聊获得读书识字经验次数达到上限")
        return
    end

    local skillLv = role:getSkillLv("dushushizi")
    if skillLv == 0 then
        print("你没有读书识字，闲聊无法获得读书识字的经验")
        return
    end

    role:addSkillExp("dushushizi", addExp)
    role:setDayFlag("addDSSZTime"..npc.id,addExpTime + 1)

    RichPrint("main","你的读书识字经验提升了。")
end

return ChatModel
000000000