local Role_Family = {}

-- 门派数据
function Role_Family:getFamily()
    local Family = require("app.models.family.Family")

    local family = Family:getFamily(self.family.name)

    if family == nil then
        error("门派数据不存在 ：" .. tostring(self.family.name))
    end

    return family
end

--@desc: 获取门派名字
--@author:LvBin
--@time:2023-11-06 16:24:42
--@return
function Role_Family:getFamilyName()
    return self:getFamily():getName()
end

--@desc: 获取门派id
--@author:LvBin
--@time:2023-11-06 16:24:56
--@return
function Role_Family:getFamilyId()
    return self.family.name
end

--@desc: 获取门派辈分
--@author:LvBin
--@time:2023-11-10 18:16:19
--@return
function Role_Family:getFamilyLevel()
    return self.family.level
end

--@desc: 获取门派类型
--@author:LvBin
--@time:2023-11-10 18:16:30
--@return
function Role_Family:getFamilyType()
    return self:getFamily():getFamilyType()
end

--@desc: 是否加入门派,门派分类类型为1属于加入门派，门派类型为2不属于加入门派（默认散人门派或者叛师后归隐门派）
--@author:LvBin
--@time:2023-11-06 17:09:47
--@return
function Role_Family:hasFamily()
    return self:getFamilyType() == 1
end

--@desc: 是游侠
--@author:LvBin
--@time:2023-11-08 17:22:46
--@return
function Role_Family:isYouXia()
    return self:getFamilyId() == "youxia"
end

function Role_Family:checkCanApprentice(teacher)
    -- 拜师的人和当前师傅是同一个人就是磕头
    if teacher:getAttr("id") == self:getAttr("teacherId") then
        return false,"他就是你师傅"
    end

    if self:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
        return false,"正在练功中，无法拜入师门，请取消练功后再次拜师"
    end

    if self:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
        return false,"正在闭关中，无法拜入师门，请取消闭关后再次拜师"
    end

    if self:isInCurrState(ROLE_CURR_STATE_DAZUO) then
        return false,"正在打坐中，无法拜入师门，请取消打坐后再次拜师"
    end

    local function checkApprenticeCondition(list)
        local restult, text = true, ""
        if not MapIsEmpty(list) then
            for i, condition in ipairs(list) do
                if not (condition.type and condition.name and condition.cond and condition.value) then
                    -- 条件不齐将无法判断
                else
                    local value
                    if condition.type == "技能" then
                        -- value = Skill:getLv(roleSkill.exp)
                        local roleSkill = self:getSkill(condition.name)
                        if not roleSkill or not roleSkill.exp then
                            -- 技能不存在的情况,直接判断为失败
                            text = condition.failed
                            restult = false
                            break
                        end
                        value = self:getSkillLv(condition.name)
                    elseif condition.type == "属性" then
                        value = self:getFinalAttr(condition.name)
                    end

                    if not value then
                        -- 属性值获取不到的情况也直接判断为失败
                        text = condition.failed
                        restult = false
                        break
                    end

                    local condValue
                    -- 如果判断值是字符串则直接判断是否相等
                    if type(condition.value) == "string" then
                        condValue = tostring(condition.value)
                        if value ~= condValue then
                            text = condition.failed
                            restult = false
                            break
                        end
                    else
                        condValue = tonumber(condition.value)
                        -- 非字符串需要判断 = >= < 等条件
                        if ((condition.cond == "=" and value == condValue) or (condition.cond == "<" and value < condValue) or (condition.cond == ">=" and value >= condValue)) then
                        else
                            text = condition.failed
                            restult = false
                            break
                        end
                    end
                end
            end
        end
        return restult, text
    end

    local ret, text = checkApprenticeCondition(teacher:getAttr("apprenticeCondition"))
    
    -- 没有 或 条件,并且第一个条件判断也不通过,需要弹出提示文本
    if ret == false and teacher:getAttr("apprenticeRelation") ~= "or" then
        -- 只有第一个条件判断不通过,并且拜师条件关系为 或 关系时,才需要判断第二个类条件
        return false,text
    elseif ret == false and teacher:getAttr("apprenticeRelation") == "or" then
        -- 判断 或 的条件
        ret, text = checkApprenticeCondition(teacher:getAttr("apprenticeOrCondition"))
        if ret == false then
            return false,text
        end
    end

    if self:hasFamily() and teacher:getFamilyId() ~= self:getFamilyId() then
        return false,"你已经加入其他门派。"
    end

    return true
end

-- 拜师
function Role_Family:obApprentice(teacher)
    local result,resultText = self:checkCanApprentice(teacher)

    if result == false then
        if resultText == "他就是你师傅" then
            self:keTou(teacher)
        else
            PopText(resultText)
        end

        return false
    end

    -- 没有门派 直接拜师成功
    if not self:hasFamily() then
        local result = self:__joinFamily(teacher)

        return result
    elseif self:hasFamily() and teacher:getFamilyId() == self:getFamilyId() then
        local result = self:__changeTeacher(teacher)

        return result
    end

    return false
end

--@desc: 向师傅磕头
--@author:LvBin
--@time:2023-12-04 17:06:23
--@teacher: 师傅
--@return
function Role_Family:keTou(teacher)
    if Helper:diffWithDate(GetTime(), self:getFlag("磕头时间")) >= 1 then
        self:setFlag("磕头次数", tostring(0))
        self:setFlag("磕头时间", GetTime())
    end

    if tonumber(self:getFlag("磕头次数")) > 1000 then
        PopText("你已经头破血流了，明天再来吧！")
        return
    end

    if self._currKeTouTime and GetTime() - self._currKeTouTime < 1 then
        PopText("别把头磕坏了")
        return
    end

    local pot = self:getAttr("pot")
    pot = pot + 5

    -- 经脉印记
    -- 磕头时，有几率额外获得更多潜能
    local Meridian = require("app.models.Meridian.Meridian")
    if self:isHaveImprintingId("ganchengyin") then
        local meridianBuffValue = Meridian:getMeridianBuffValue("ganchengyin")
        meridianBuffValue = string.split(meridianBuffValue, ";")
        local odds = tonumber(meridianBuffValue[1])
        local addValue = tonumber(meridianBuffValue[2])
        if odds >= math.random(1, 100) then
            print("经脉印记效果 磕头获得更多潜能")
            pot = pot + addValue
        end
    end

    -- 磕头时，有几率额外获得少量经验
    if self:isHaveImprintingId("nianchengyin") then
        local meridianBuffValue = Meridian:getMeridianBuffValue("nianchengyin")
        meridianBuffValue = string.split(meridianBuffValue, ";")
        local odds = tonumber(meridianBuffValue[1])
        local addValue = tonumber(meridianBuffValue[2])
        if odds >= math.random(1, 100) then
            print("经脉印记效果 磕头获得少量经验")
            self:addAttr("exp", addValue)
        end
    end

    -- 磕头时，有几率额外获得少量阅历
    if self:isHaveImprintingId("tichengyin") then
        local meridianBuffValue = Meridian:getMeridianBuffValue("tichengyin")
        meridianBuffValue = string.split(meridianBuffValue, ";")
        local odds = tonumber(meridianBuffValue[1])
        local addValue = tonumber(meridianBuffValue[2])
        if odds >= math.random(1, 100) then
            print("经脉印记效果 磕头获得少量阅历")
            self:addAttr("yueli", addValue)
        end
    end

    self:setAttr("pot", pot)
    RichPrint("main", "你恭恭敬敬地向[" .. tostring(teacher:getName()) .. "]磕头请安，叫道：「师父！」")
    self._currKeTouTime = GetTime()
    self:setFlag("磕头次数", tostring(tonumber(self:getFlag("磕头次数")) + 1))

    do
        local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

        if LimitedTimeExperience:checkTaskIsOpen("smketou") then
            LimitedTimeExperience:setRole(User:getRole())
            LimitedTimeExperience:finishTaskByTaskType("smketou")
        end
    end
end

--@desc: 加入门派
--@author:LvBin
--@time:2024-01-25 16:43:30
--@teacher: 
--@return
function Role_Family:__joinFamily(teacher)
    local result = true

    local familyId = assert(teacher:getFamilyId())

    HttpManagerEx:joinFamily(familyId,self:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__apprenticeSuc(teacher)
                    
                    --取消当前装备武学
                    self:clearPrepareSkills()

                    --重新刷新精力最大值
                    self:setJingMax()

                    if self:getSkill("langrenmindskill") ~= nil then
                        --删除散人心法
                        self:removeSkill("langrenmindskill")

                        RichPrint("main", "你已忘却了逍遥心法。")
                    end

                    self:setAttr("mcmrestrictId", nil)

                    if data.currencyVersion then
                        self:setCurrencyVersion(data.currencyVersion)
                    end

                    RichPrint("main", "由于已拜入师门，你已遵循师门门规，今后需要根据论武堂名位使用其他门外武学。")
                else
                    PopText(errmsg)
                    result = false
                    return false
                end
            else
                PopText(errmsg)
                result = false
                return false
            end
            return true
        end,
        IS_SHOW_WAITING
    )

    return result
end

--@desc: 同门派更换师傅
--@author:LvBin
--@time:2024-01-25 17:44:30
--@teacher: 
--@return
function Role_Family:__changeTeacher(teacher)
    local tcFmlLv = assert(teacher:getFamilyLevel())
    local tcFmlId = assert(teacher:getFamilyId())

    local roleFmlLv = self:getFamilyLevel()
    local roleFmlId = self:getFamilyId()

    -- 拜师
    if roleFmlLv == tcFmlLv then
        local str = "师弟"
        if self:getAttr("sex") == "女" then
            str = "师妹"
        end
        RichPrint("main", "YEL" .. teacher.name .. "：" .. str .. "，你我同辈，我怎能收你为徒？")
    elseif roleFmlLv == tcFmlLv - 1 then
        RichPrint("main", "YEL" .. teacher.name .. "：师叔，您快别开玩笑了，掌门知道了要罚我目无尊长了。")
    elseif roleFmlLv <= tcFmlLv - 2 then
        RichPrint("main", "YEL" .. teacher.name .. "：师叔祖，您老糊涂了么？")
    else
        self:__apprenticeSuc(teacher)
        
        return true
    end

    return false
end

--@desc: 成功拜师
--@author:LvBin
--@time:2024-01-25 16:42:36
--@teacher: 
--@return
function Role_Family:__apprenticeSuc(teacher)
    local tcFmlLv = assert(teacher:getFamilyLevel())
    local tcFmlId = assert(teacher:getFamilyId())

    RichPrint("main", "你决定拜[" .. tostring(teacher:getName()) .. "] 为师。")
    
    RichPrint("main", tostring(teacher:getName()) .. "说道：" .. tostring(teacher.masterSucceed))

    RichPrint("main", "HIC你跪了下来向[" .. tostring(teacher:getName()) .. "] 恭恭敬敬地磕了四个响头，叫道：「师父！」")
    
    if tcFmlId then
        if tcFmlId == "guanfu" then -- add by XiaoZhiWei 2017/03/14 11:45:43 官府拜师成功文本修改
            if tcFmlLv == 1 then
                RichPrint("main", "HIC恭喜你成为[" .. tostring(teacher:getFamilyName()) .. "]的[崇武卫副统领]。")
            elseif tcFmlLv == 2 and tcFmlId == "guanfu" then
                RichPrint("main", "HIC恭喜你成为[" .. tostring(teacher:getFamilyName()) .. "]的[捕风密探]。")
            elseif tcFmlLv == 3 and tcFmlId == "guanfu" then
                RichPrint("main", "HIC恭喜你成为[" .. tostring(teacher:getFamilyName()) .. "]的[京兆捕快]。")
            end
        else
            RichPrint("main", "HIC恭喜你成为[" .. tostring(teacher:getFamilyName()) .. "]的第[" .. tostring(Helper:numberCast(tcFmlLv + 1)) .. "]代弟子。")
            if tcFmlLv == 3 and self:getInheritFlag("新手引导") == 2 then
                self:setInheritFlag("新手引导", 3)
                RichPrint("main", "YEL" .. tostring(teacher:getName()) .. "： “起来吧，从今日起你就是我门下弟子了，我现在可以传授你一些本门的基本功法，之后你就去HIR江湖NORYEL中先历练一番吧。”")
            end
        end
    end

    local family = {
        name = tcFmlId,
        level = tcFmlLv + 1
    }
    
    self:setAttr("family", family)
    
    self:setAttr("teacherName", teacher:getName())
    
    self:setAttr("teacherId", teacher:getAttr("id"))
    
    self:setAttr("isSeclusion", nil)
end 

return Role_Family
00000000000