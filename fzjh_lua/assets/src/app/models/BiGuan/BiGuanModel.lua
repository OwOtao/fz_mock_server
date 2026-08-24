local BiGuanModel = class("BiGuanModel")

--@RefType [src.app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

--@desc 闭关时长列表，单位：小时
local addTimeList = {1, 4, 8, 12, 16, 24, 36, 48, 72}

--@desc 点击增加时间按钮次数
local _addTime = 0

function BiGuanModel:create(skillId)
    local p = BiGuanModel:new()
    p:init(skillId)
    return p
end

function BiGuanModel:print()
    local print_table = {}
    for k, v in pairs(self) do
        if type(v) ~= "function" and k ~= "class" and k ~= "_role" then
            print_table[k] = v
        end
    end

    Helper:print_lua_table(print_table)
end

BiGuanModel.BIGUAN_STATUS = {
    NOT_START = 0,
    RUNNING = 1,
    FNIISH = 2
}

function BiGuanModel:init(skillId)
    self._skillId = skillId
    self._addTimeIndex = 0
    self._reduceCostFactor = 0
    self._jinXinWan = 0
    local role = User:getRole()
    --@RefType [src.app.models.role.Role#Role]
    self._role = role
    self._jinXinWan = self._role:getStatusByName("jingxinwan")
    self._skillLv = Skill:getLv(self._role:getSkillExp(self._skillId))
    self._addSkillLv = self:initAddSkillLv()

    self._cost = self:initCost()

    if self._role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
        self._status = self.BIGUAN_STATUS.RUNNING
        local flag = self._role:getFlag("闭关时长")

        if flag > 0 then
            for i, v in ipairs(addTimeList) do
                if v == flag then
                    self._addTimeIndex = i
                    break
                end
            end
        end
    else
        self._status = self.BIGUAN_STATUS.NOT_START
    end

    self._rate = self:initRate()
end

function BiGuanModel:getSkillId()
    return self._skillId
end

function BiGuanModel:getStatus()
    return self._status
end

function BiGuanModel:changeStatusFinish()
    self._status = self.BIGUAN_STATUS.FNIISH
end

function BiGuanModel:changeStatusRunning()
    self._status = self.BIGUAN_STATUS.RUNNING
end

function BiGuanModel:getSkillName()
    return Skill:getSkill(self._skillId).name
end

function BiGuanModel:setReduceCostFactor(factor)
    self._reduceCostFactor = factor
    self._cost = self:initCost()
end

function BiGuanModel:getReduceCostFactor()
    return self._reduceCostFactor
end

function BiGuanModel:getJingXinWan()
    return self._jinXinWan
end

function BiGuanModel:addUseTime()
    local currIndex = self._addTimeIndex
    self._addTimeIndex = currIndex + 1
    self._rate = self:initRate()
end

--@desc: 获取闭关所用时长
--@author:Liang SongQiang
--@time:2018-10-09 11:33:04
function BiGuanModel:getUseTime()
    local index = self._addTimeIndex
    return Helper:getDef(addTimeList[self._addTimeIndex], 0)
end

function BiGuanModel:initAddSkillLv()
    local addSkillLv = 0

    local skill = Skill:getSkill(self._skillId)

    local skillLv = Skill:getLv(self._role:getSkillExp(self._skillId))

    if skill == nil then
        return addSkillLv
    end

    local roleLv = self._role:getLv()

    local jiBenLv = Skill:getLv(self._role:getSkillExp("jibenneigong"))

    if self._skillId == "jibenneigong" then
        if roleLv > self._role:getSkillLvLimit("jibenneigong") then
            roleLv = self._role:getSkillLvLimit("jibenneigong")
        end

        if roleLv - jiBenLv >= 5 then
            addSkillLv = 5
        else
            addSkillLv = roleLv - jiBenLv
        end

        return addSkillLv
    end

    -- 基本内功特出处理 不能大于角色等级 并且不能超过上限
    if jiBenLv - self._skillLv >= 10 then
        addSkillLv = 10
    else
        addSkillLv = jiBenLv - self._skillLv
    end

    --@desc 闭关不能超过自身武学上限等级
    addSkillLv = math.min(addSkillLv,self._role:getSkillLvLimit(self._skillId) - self._skillLv)

    if addSkillLv <= 0 then
        addSkillLv = 0
    end

    return addSkillLv
end

function BiGuanModel:getAddSkillLv()
    return self._addSkillLv
end

function BiGuanModel:getFailAddSkillLv()
    local addLv = 0
    if self._skillId == "jibenneigong" then
        addLv = 1
    else 
        if self._addSkillLv<=1 then 
            addLv = self._addSkillLv
        else
            if self._addSkillLv == 10 then
                addLv = 5
            else
                addLv = math.min(self._addSkillLv, 5)
            end
        end
    end

    return addLv
end

function BiGuanModel:getMonsterAddSkillLv()
    return -5
end

function BiGuanModel:getskillLv()
    return self._skillLv
end

function BiGuanModel:initRate()
    local succRate, failRate, monsterRate = self._role:biGUanRate(self._skillLv,self._skillId)

    if self._addTimeIndex > 0 then
        succRate = succRate + (self._addTimeIndex * 10)
        failRate = failRate - (self._addTimeIndex * 7)
        monsterRate = monsterRate - (self._addTimeIndex * 3)
    end

    --@region 使用静心丸的情况
    if self._jinXinWan ~= 0 then
        succRate = math.min(succRate + self._jinXinWan, 100)
        failRate = 100 - succRate
        monsterRate = 0
    end
    --@endregion

    if succRate >= 100 then
        succRate = 100
        failRate = 0
        monsterRate = 0
    end

    if monsterRate <= 0 then
        monsterRate = 0
        failRate = 100 - succRate
    end

    if failRate <= 0 then
        failRate = 0
        monsterRate = 100 - succRate
    end

    local rate = {
        succRate = succRate,
        failRate = failRate,
        monsterRate = monsterRate
    }

    return rate
end

function BiGuanModel:getRate()
    return self._rate
end

function BiGuanModel:getSuccRate()
    return self._rate.succRate
end

function BiGuanModel:getFailRate()
    return self._rate.failRate
end

function BiGuanModel:getMonsterRate()
    return self._rate.monsterRate
end

function BiGuanModel:initCost()
    local skill = Skill:getSkill(self._skillId)
    local cost = skill:getNeedExp(self._skillLv, self._addSkillLv) / skill:getPotEfficiency(self._role) * 100

    cost = cost * (1 - self._reduceCostFactor)
    return cost
end

function BiGuanModel:getCost()
    return self._cost
end

--@desc: 获取闭关的角色
--@author:Liang SongQiang
--@time:2018-10-09 16:54:35
--@return [src.app.models.role.Role#Role]
function BiGuanModel:getRole()
    return self._role
end

function BiGuanModel:checkCanBiGuan()
	if self._role:isInCurrState(ROLE_CURR_STATE_BIGUAN) == true and self._skillId ~= self._role:getFlag("当前武功") then
		PopText("正在深入闭关中，切勿分心")
		return false
    end

    local roleBaseNeiGong = self._role:getSkill("jibenneigong")
    local jiBenLv = 0
    if MapIsEmpty(roleBaseNeiGong) then
        PopText("基本内功等级必须大于200才能开始闭关修炼")
        return false
    else
        jiBenLv = Skill:getLv(roleBaseNeiGong.exp)
        if jiBenLv < 200 then
            PopText("基本内功等级必须大于200才能开始闭关修炼")
            return false
        end
    end

    local pot = self._role:getAttr("pot")
    if self._role:isInCurrState(ROLE_CURR_STATE_BIGUAN) == false then
        if self._cost > pot then
            PopText("你的潜能不够，没有办法闭关。")
            return false
        end
    end

    if self._skillId == "jibenneigong" then
        if self._role:getLv() < self._skillLv + 5 then
            PopText("你的人物等级太低,无法闭关此门内功")
            return false
        end
        if self._skillLv >= self._role:getSkillLvLimit("jibenneigong") then 
            PopText("你的基本内功等级已达上限")
            return false
        end
    else
        local prepareSkillId = self._role:getPrepareSkill("neigong")

        if not prepareSkillId or prepareSkillId ~= self._skillId then
            PopText("你只能闭关突破你准备上的内功心法。")
            return false
        end

        if self._skillLv >= jiBenLv then
			PopText("你的基本内功火候未到，必须先打好基础才能继续突破。")
			return false
		end

        -- -- 所需潜能 或者 能提升等级小于10  或者 和基本内功的等级差小于10级并且等级小于 上限 - 10级
        -- if
        --     self._cost <= 0 or
        --         ((self._addSkillLv < 10 or (jiBenLv < self._skillLv + 10)) and self._skillLv <= self._role:getSkillLvLimit("jibenneigong") - 10)
        --  then
        --     PopText("你的基本内功火候未到，必须先打好基础才能继续突破。")
        --     return false
        -- end

        -- if self._role:getLv() < self._skillLv + 10 then
        --     PopText("你的人物等级太低,无法闭关此门内功")
        --     return false
        -- end

        if self._skillLv >= self._role:getSkillLvLimit(self._skillId) then
            PopText("已经达到该武学最高等级，无法闭关")
            return false
        end
    end
end

--@desc:获取消耗的潜能
--@author:Liang SongQiang
--@time:2018-06-06 17:26:08
--@skillLv:现在的等级
--@addLv:增加的等级
--@skill:[src.app.models.skill.BaseSkill#BaseSkill]
function BiGuanModel:getCostPot(skillLv, addLv, skill)
    local role = User:getRole()

    local cost = skill:getNeedExp(skillLv, addLv) / skill:getPotEfficiency(role) * 100
    local m = role:getFlag("闭关加成")
    if m > 0 then
        cost = cost * (1 + m)
    end
    return cost
end

--@desc: 计算剩余时间
--@author:Liang SongQiang
--@time:2018-06-10 21:08:49
function BiGuanModel:calReaminTime()
    local nowTime = GetTime()

    local startTime = self._role:getFlag("闭关时间")

    local t = self:getUseTime()
    if t > 0 then
        t = t * 3600
    else
        t = 60
    end

    local remainTime = math.max(t - (nowTime - startTime), 0)

    return remainTime
end

--@desc: 开始闭关
--@author:Liang SongQiang
--@time:2018-06-11 14:55:38
function BiGuanModel:startBiGuan()
    RoleTaskControllor:clickBiGuanLayer(
        self._skillId,
        function()

            --@RefType [src.app.models.HomelandModel.HomelandUtil#HomelandUtil]
            local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
            if HomelandUtil:isRoomByTypeFromFlag("tsfangjian018") then
                RichPrint("main","你走入闭关室，将身体状态调整至最佳，开始闭关。")
            else
                RichPrint("main", "HIR盘膝坐下，开始冥神运功，闭关修行。")
            end


            self._role:setFlag("闭关时长", addTimeList[self._addTimeIndex])
            self._role:setFlag("闭关时间", GetTime())
            self._role:setFlag("当前武功", self._skillId)
            self._role:setFlag("闭关加成", self._reduceCostFactor)
            self._role:setFlag("武功准备类型", "neigong")
            self._role:addAttr("pot", -self._cost)
            self._role:biGuan()

            self:changeStatusRunning()

            -- _biGuanData.remainTime = _biGuanData.currAddTime - (GetTime() - role:getFlag("闭关时间")) <= 0

            RichPrint("main", "消耗潜能：" .. tostring(math.floor(self._cost)) .. "点")
            
            local currMapLayer = MainControllLayer:getCurrLayer()
            local currMap = self._role:getCurrMap()

            if currMap and currMap:getMapType() and currMapLayer == "MapLayer" then
                
                local text =
                {
                    "你默默运转内力，隐隐有些感觉。",
                    "你将内力运出丹田，过紫宫、入泥丸、透十二重楼，遍布奇经八脉，然后收回丹田。",
                    "你将内力运经诸穴，抵四肢百骸，然后又回收丹田。",
                    "你在丹田中不断积蓄内力，只觉得浑身燥热。",
                    "你缓缓呼吸吐纳，将空气中水露皆收为己用。"
                }
                local i = 1
                currMap:setSchedule(
                    function(tag)
                        if not self._role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
                            currMap:unSchedule(tag)
                            return
                        end
                        RichPrint("main", text[i])
    
                        i = i + 1
    
                        if i > #text then
                            i = 1
                        end
                    end,
                    2
                )
            end

        end,
        function()
        end,
        function()
        end,
        function()
        end,
        function()
        end
    )
end

function BiGuanModel:useJingXinWan(callback)
    local item = Item:getOneItemByKey("jingxinwan")

    local num = self._role:getFlag("jingxinwan")
    if item then
        item:storeItemUse(
            function()
                if num == nil then
                    self._role:setFlag("jingxinwan", 10)
                else
                    self._role:setFlag("jingxinwan", tonumber(num) + 10)
                end
                self._jinXinWan = self._role:getStatusByName("jingxinwan")
                self._rate = self:initRate()

                if callback then
                    callback()
                end
            end
        )
    end
end

function BiGuanModel:stopBiGuan()
    self._role:stopBiGuan()
    
    self._addTimeIndex = 0
end

return BiGuanModel
000000000