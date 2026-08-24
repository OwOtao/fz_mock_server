--[[
    武功被动招式组合
]]
local class = require("third.class.NewClass")
local BuffAdder = require("app.FightSystem.FightBuff.BuffAdder.BuffAdder")
local BuffSystemResource = require("app.FightSystem.FightBuff.BuffSystemResource")

local ActiveZhaoCombination = {
    __id = "null", --@desc: 主动招式组合ID
    __activeId = "null", --@desc 主动招式id
    __activeLevel = 0, --@desc 主动招式
    __activeName = "null", --@desc 主动招式名称
    __activeType = 0, --@desc 主动招式类型
    __switchTargets = 0, --@desc 可切换目标
    __tiliCost = 0, --@desc 体力消耗
    __neiliCost = 0, --@desc 内力消耗
    __cd = 0, --@desc 该招式的CD时间
    __useDesc = "", --@desc 招式释放前输出文本
    __readyZhao = nil, --@desc 准备招式动作（可为空）
    __isJumpAttack = 1, --@desc 该动作是否需要前跳释放
    __hurtIDs = {}, --@desc 主动伤害id组
    __attackList = {}, --@desc 主动攻击招式动作组 (可为空，代表该招式是)
    __addBuff = {}, --@desc 附带的buff数据,
    __buffAdder = nil, --@desc buff添加器
    __useConditions = {}, --@desc 主动招式使用条件（界面显示）
    __useHideConditions = {}, --@desc 主动招式使用隐藏条件（界面不显示
    __hurtPosClass = "default",
    __desc = "",
    --@desc: 主动招式描述
    __methods = 1,
    __learnMethod = 0,
    --@desc:学习方式
    __learnConditions = {},
    --@desc:学习条件
    __completionUseAuto = 0, --@desc 是否可接被动技能
    __releaseConditions = {} --@dese 额外主动施放条件
}

function ActiveZhaoCombination:create()
    return self.new()
end

function ActiveZhaoCombination:ctor()
end

function ActiveZhaoCombination:getId()
    return self.__id
end

function ActiveZhaoCombination:getActiveId()
    return self.__activeId
end

function ActiveZhaoCombination:getActiveLevel()
    return self.__activeLevel
end

function ActiveZhaoCombination:getActiveName()
    return self.__activeName
end

function ActiveZhaoCombination:getActiveType()
    return self.__activeType
end

function ActiveZhaoCombination:getSwitchTargets()
    return self.__switchTargets
end

function ActiveZhaoCombination:getCD()
    return self.__cd
end

function ActiveZhaoCombination:getTiliCost()
    return self.__tiliCost
end

function ActiveZhaoCombination:getNeiliCost()
    return self.__neiliCost
end

function ActiveZhaoCombination:getActionText()
    return self.__actionText
end

function ActiveZhaoCombination:getIsJumpAttack()
    return self.__isJumpAttack == 1
end

--@desc : 获得准备招式
--@author:Seven
--@time:2021-06-27 12:45:12
--@return: [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
function ActiveZhaoCombination:getReadyZhao()
    return self.__readyZhao
end

function ActiveZhaoCombination:getHurtIDs()
    return self.__hurtIDs
end

function ActiveZhaoCombination:getAddBuff()
    return self.__addBuff
end

function ActiveZhaoCombination:getBuffAdder()
    return self.__buffAdder
end

-- 获得入场buff添加器
function ActiveZhaoCombination:getEnterFightBuffAdder()
    return self.__enterFightBuffAdder
end

function ActiveZhaoCombination:getAtkList()
    return self.__attackList
end

function ActiveZhaoCombination:getAtkZhaoInfoByIndex(index)
    if index <= 0 then
        assert(false, "获取攻击Atk，参数不能小于1")
    end

    if index > #self.__attackList then
        assert(false, "获取攻击Atk，参数越界：" .. index)
    end

    return self.__attackList[index]
end

function ActiveZhaoCombination:getAtkCount()
    return #self.__attackList
end

function ActiveZhaoCombination:getAttackHurtTotalWeight()
    local totalWeight = 0

    for i, zhaoInfo in ipairs(self.__attackList) do
        totalWeight = totalWeight + zhaoInfo:getHurtWeight()
    end

    return totalWeight
end

function ActiveZhaoCombination:getHurtPosClass()
    return self.__hurtPosClass
end

function ActiveZhaoCombination:getCarryBuffs()
    return self.__carryBuffs or {}
end

function ActiveZhaoCombination:loadFromRes(res_data)
    if res_data.attackList == nil then
        assert(false, "主动招式组合:" .. res_data.id .. "的 attackList 不能为空")
    end

    local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")

    for key, v in pairs(res_data) do
        if key == "attackList" then
            local list = string.split(v, "#")

            if MapIsEmpty(list) == false then
                for _, atk_id in ipairs(list) do
                    local zhaoInfo = ActiveFactory:createActiveZhaoInfo(atk_id)
                    table.insert(self.__attackList, zhaoInfo)
                end
            else
                assert(false, "主动招式组合:" .. res_data.id .. " 的 attackList 解析错误")
            end
        elseif key == "readyZhao" then
            local readyZhao = ActiveFactory:createActiveZhaoInfo(v)
            self.__readyZhao = readyZhao
        elseif key == "hurtIDs" then
            local list = string.split(v, "#")

            if MapIsEmpty(list) == false then
                for _, hurt_id in ipairs(list) do
                    table.insert(self.__hurtIDs, hurt_id)
                end
            end
        elseif key == "addBuff" then
            local buff_info_res = string.split(v, "|")

            if MapIsEmpty(buff_info_res) == false then
                for _, buff_info in ipairs(buff_info_res) do
                    table.insert(self.__addBuff, string.split(buff_info, "#"))
                end
            end
        elseif key == "buffLauncherAdd" then
            self.__buffAdder = BuffAdder:create(string.split(v, "#"))
        elseif key == "useConditions" then
            local condition_info_res = string.split(v, "|")
            if MapIsEmpty(condition_info_res) == false then
                for _, condition_info in ipairs(condition_info_res) do
                    table.insert(self.__useConditions, condition_info)
                end
            end
        elseif key == "useHideConditions" then
            local condition_info_res = string.split(v, "|")
            if MapIsEmpty(condition_info_res) == false then
                for _, condition_info in ipairs(condition_info_res) do
                    table.insert(self.__useHideConditions, condition_info)
                end
            end
        elseif key == "learnConditions" then
            local condition_info_res = string.split(v, "|")
            if MapIsEmpty(condition_info_res) == false then
                for _, condition_info in ipairs(condition_info_res) do
                    table.insert(self.__learnConditions, condition_info)
                end
            end
        elseif key == "cd" then
            self.__cd = tonumber(v)
        elseif key == "releaseConditions" then
            local condition_info_res = string.split(v, "|")
            if MapIsEmpty(condition_info_res) == false then
                for _, condition_info in ipairs(condition_info_res) do
                    table.insert(self.__releaseConditions, condition_info)
                end
            end
        elseif key == "enteredLauncherAdd" then
            local EnterFightBuffAdder = require("app.FightSystem.FightBuff.BuffAdder.EnterFightBuffAdder")
            self.__enterFightBuffAdder = EnterFightBuffAdder:create(string.split(v, "#"))
        elseif key == "carryBuff" then
            self.__carryBuffs = {}
            for i, one in ipairs(string.split(v, '|')) do
                table.insert(self.__carryBuffs, string.split(one, '#'))
            end
        else
            self["__" .. key] = v
        end
    end
end

function ActiveZhaoCombination:getDesc()
    return self.__desc
end

function ActiveZhaoCombination:getMethods()
    return self.__methods
end

function ActiveZhaoCombination:getLearnMethod()
    return self.__learnMethod
end

function ActiveZhaoCombination:getUseConditions()
    return self.__useConditions
end

function ActiveZhaoCombination:getUseHideConditions()
    return self.__useHideConditions
end

function ActiveZhaoCombination:getLearnConditions()
    return self.__learnConditions
end

function ActiveZhaoCombination:getCompletionUseAuto()
    return self.__completionUseAuto
end

function ActiveZhaoCombination:getReleaseConditions()
    return self.__releaseConditions
end

return class("ActiveZhaoCombination", {}, ActiveZhaoCombination)
00