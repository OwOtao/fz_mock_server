--[[
    author:Seven
    time:2022-11-19 15:27:11
    desc: 招式组合资源类
]]
local ZhaoInfo = require("app.FightSystem.FightSkill.ZhaoInfo")

local AutoZhaoInfo_Res = require("script.newbattle.demo.autoZhaoInfo")["被动招式"]

local class = require("third.class.NewClass")
local BasicActiveZhaoCombination = {}

function BasicActiveZhaoCombination:create(res)
    return BasicActiveZhaoCombination.new():__init(res)
end

function BasicActiveZhaoCombination:__init(res)
    self.__res = res

    return self
end

-- 主动招式编号;
function BasicActiveZhaoCombination:getId()
    return self.__res.id
end

-- 主动招式ID;
function BasicActiveZhaoCombination:getActiveId()
    return self.__res.activeId
end

-- 主动招式等级;
function BasicActiveZhaoCombination:getActiveLevel()
    return tonumber(self.__res.activeLevel)
end

-- 主动招式名称;
function BasicActiveZhaoCombination:getCombName()
    return self.__res.activeName
end

-- 主动技能描述;
function BasicActiveZhaoCombination:getDesc()
    return self.__res.desc
end

-- 主动招式类型;
function BasicActiveZhaoCombination:getActiveType()
    return self.__res.activeType
end

-- 可切换目标;
function BasicActiveZhaoCombination:getSwitchTargets()
    return self.__res.switchTargets
end

-- 使用主动消耗体力;
function BasicActiveZhaoCombination:getTiliCost()
    return self.__res.tiliCost
end

-- 使用主动消耗内力;
function BasicActiveZhaoCombination:getNeiliCost()
    return self.__res.neiliCost
end

-- 使用主动冷却时间;
function BasicActiveZhaoCombination:getCd()
    return tonumber(self.__res.cd)
end

-- 主动使用描述
function BasicActiveZhaoCombination:getActionText()
    return self.__res.actionText
end

-- 额外主动施放条件;
function BasicActiveZhaoCombination:getReleaseConditions()
    if self.__releaseConditions == nil then
        self.__releaseConditions = {}
        if self.__res.releaseConditions ~= nil then
            local condition_info_res = string.split(self.__res.releaseConditions, "|")
            if MapIsEmpty(condition_info_res) == false then
                for _, condition_info in ipairs(condition_info_res) do
                    table.insert(self.__releaseConditions, condition_info)
                end
            end
        end
    end

    return self.__releaseConditions
end

--	主动伤害组;
function BasicActiveZhaoCombination:getHurtIDs()
    if self.__hurtIDs == nil then
        self.__hurtIDs = {}
        if self.__res.hurtIDs ~= nil then
            local list = string.split(self.__res.hurtIDs, "#")

            for _, hurt_id in ipairs(list) do
                table.insert(self.__hurtIDs, hurt_id)
            end
        end
    end

    return self.__hurtIDs
end

-- 主动准备招式动作;
function BasicActiveZhaoCombination:getReadyZhao()
    return self.__res.readyZhao
end

-- 主动前跳攻击;
function BasicActiveZhaoCombination:getIsJumpAttack()
    return self.__res.isJumpAttack
end

-- 主动攻击招式动作组;
function BasicActiveZhaoCombination:getAtkList()
    if self.__atkListIds == nil then
        self.__atkListIds = {}
        local list = string.split(self.__res.attackList, "#")
        if MapIsEmpty(list) == false then
            for i, zhaoInfoId in ipairs(list) do
                table.insert(self.__atkListIds, zhaoInfoId)
            end
        else
            assert(false, "主动招式组合:" .. self:getId() .. " 的attackList 解析错误")
        end
    end

    return self.__atkListIds
end

--@desc: 获取攻击招式信息id
--@author:Seven
--@time:2021-06-25 20:10:11
--@index: 顺序索引
--@return [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
function BasicActiveZhaoCombination:getAtkZhaoInfoIdByIndex(index)
    if index <= 0 then
        assert(false, "获取攻击Atk，参数不能小于1")
    end

    if index > self:getAtkCount() then
        assert(false, "获取攻击Atk，参数越界：" .. index)
    end

    return self.__atkListIds[index]
end

--@desc: 该招式组合包含多少个招式
--@author:Seven
--@time:2022-11-19 17:38:47
function BasicActiveZhaoCombination:getAtkCount()
    return table.getn(self:getAtkList())
end

-- 主动效果buff添加;
function BasicActiveZhaoCombination:getAddBuff()
    if self.__addBuff == nil then
        self.__addBuff = {}
        local buff_info_res = string.split(self.__res.addBuff, "|")

        if MapIsEmpty(buff_info_res) == false then
            for _, buff_info in ipairs(buff_info_res) do
                table.insert(self.__addBuff, string.split(buff_info, "#"))
            end
        end
    end

    return self.__addBuff
end

-- 主动buff添加器;
function BasicActiveZhaoCombination:getBuffLauncherAdd()
    if self.__buffLauncherAdd == nil then
        if self.__res.buffLauncherAdd ~= nil then
            self.__buffLauncherAdd = string.split(self.__res.buffLauncherAdd, "#")
        else
            self.__buffLauncherAdd = {}
        end
    end

    return self.__buffLauncherAdd
end

-- 主动招式学习方式;
function BasicActiveZhaoCombination:getLearnMethod()
    return self.__res.learnMethod
end

-- 主动招式学习条件;
function BasicActiveZhaoCombination:getLearnConditions()
    if self.__learnConditions == nil then
        self.__learnConditions = {}
        local condition_info_res = string.split(self.__res.learnConditions, "|")
        if MapIsEmpty(condition_info_res) == false then
            for _, condition_info in ipairs(condition_info_res) do
                table.insert(self.__learnConditions, condition_info)
            end
        end
    end

    return self.__learnConditions
end

-- 主动招式使用条件;
function BasicActiveZhaoCombination:getUseConditions()
    if self.__useConditions == nil then
        self.__useConditions = {}
        if self.__res.useConditions ~= nil then
            local condition_info_res = string.split(self.__res.useConditions, "|")
            if MapIsEmpty(condition_info_res) == false then
                for _, condition_info in ipairs(condition_info_res) do
                    table.insert(self.__useConditions, condition_info)
                end
            end
        end
    end

    return self.__useConditions
end

-- 主动招式使用隐藏条件;
function BasicActiveZhaoCombination:getUseHideConditions()
    if self.__useHideConditions == nil then
        self.__useHideConditions = {}
        if self.__res.useHideConditions ~= nil then
            local condition_info_res = string.split(self.__res.useHideConditions, "|")
            if MapIsEmpty(condition_info_res) == false then
                for _, condition_info in ipairs(condition_info_res) do
                    table.insert(self.__useHideConditions, condition_info)
                end
            end
        end
    end

    return self.__useHideConditions
end

-- 主动攻击完成后接被动招式;
function BasicActiveZhaoCombination:getCompletionUseAuto()
    return self.__res.completionUseAuto
end

-- 主动招式使用对应准备武学类型 (后续废弃，无特殊必要，请勿使用);
--return : number
function BasicActiveZhaoCombination:getMethods()
    return self.__res.methods
end

-- 命中部位系列;
function BasicActiveZhaoCombination:getHurtPosClass()
    return self.__res.hurtPosClass
end

-- 主动入场添加器;
function BasicActiveZhaoCombination:getEnteredLauncherAdd()
    if self.__enteredLauncherAdd == nil then
        if self.__res.enteredLauncherAdd ~= nil then
            self.__enteredLauncherAdd = string.split(self.__res.enteredLauncherAdd, "#")
        else
            self.__enteredLauncherAdd = {}
        end
    end

    return self.__enteredLauncherAdd
end

-- 主动携带Buff;
function BasicActiveZhaoCombination:getCarryBuffs()
    if self.__carryBuffInfos == nil then
        if self.__res.carryBuff ~= nil then
            local buffInfoStrs = string.split(self.__res.carryBuff, "|")

            self.__carryBuffInfos = {}
            if MapIsEmpty(buffInfoStrs) == false then
                for _, buffInfoStr in ipairs(buffInfoStrs) do
                    local buffInfo = string.split(buffInfoStr, "#")
                    table.insert(self.__carryBuffInfos, buffInfo)
                end
            end
        else
            self.__carryBuffInfos = {}
        end
    end

    return self.__carryBuffInfos
end

return class("BasicActiveZhaoCombination", {}, BasicActiveZhaoCombination)
0000