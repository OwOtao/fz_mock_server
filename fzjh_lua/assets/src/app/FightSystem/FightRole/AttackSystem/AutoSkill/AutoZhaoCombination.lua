--[[
    武功被动招式组合
]]
local ZhaoInfo = require("app.FightSystem.FightSkill.ZhaoInfo")

local AutoZhaoInfo_Res = require("script.newbattle.demo.autoZhaoInfo")["被动招式"]

local class = require("third.class.NewClass")
local AutoZhaoCombination = {
    __id = "null", --@desc: 招式组合ID
    __skillId = "", --@desc: 对应武学ID
    __zhaoId = "", --@desc: 招式组id
    __zhaoIdText = "", --@desc: 第几招
    __zhaoName = "", --@desc: 招式名称
    __damageType = nil, --@desc 伤害描述文本
    __hurtPosClass = "default", --@desc:击中部位系列
    __actionText = "", --@desc: 出招文本
    __attack = 0, --@desc: 攻击性能
    __hit = 0, --@desc: 命中性能
    __topLimit = 0, --@desc: 伤害性能
    __tiliCost = 0, --@desc: 消耗体力
    __atkList = {}, --@desc: 招式攻击段（攻击段id组合）
    __lv = 0, ---@desc:需求武学等级
    __attackAverage = 0 --@desc 平均攻击性能
}

function AutoZhaoCombination:create()
    return self.new()
end

function AutoZhaoCombination:ctor()
end

--@region 资源属性

--@desc: 招式组合ID
--@author:Seven
--@time:2021-05-15 10:59:55
function AutoZhaoCombination:getId()
    return self.__id
end

--@desc: 需求武学等级
function AutoZhaoCombination:getLv()
    return self.__lv
end

--@desc: 对应武学ID
--@author:Seven
--@time:2021-05-15 10:59:41
function AutoZhaoCombination:getSkillId()
    return self.__skillId
end

--@desc: 招式组id
--@author:Seven
--@time:2021-05-15 10:59:34
function AutoZhaoCombination:getZhaoId()
    return self.__zhaoId
end

--@desc: 第几招
--@author:Seven
--@time:2021-05-15 10:59:10
function AutoZhaoCombination:getZhaoIdText()
    return self.__zhaoIdText
end

--@desc: 招式名称
--@author:Seven
--@time:2021-05-15 10:59:03
function AutoZhaoCombination:getZhaoName()
    return self.__zhaoName
end

--@desc: 出招文本
--@author:Seven
--@time:2021-05-15 10:58:55
function AutoZhaoCombination:getActionText()
    return self.__actionText
end

--@desc: 伤害描述文本类型
--@author:Seven
--@time:2021-07-14 11:53:38
function AutoZhaoCombination:getDamageType()
    return self.__damageType
end

--@desc: 击中部位系列
--@author:Seven
--@time:2021-07-14 11:54:03
function AutoZhaoCombination:getHurtPosClass()
    return self.__hurtPosClass
end

--@desc: 攻击性能
--@author:Seven
--@time:2021-05-15 10:58:35
function AutoZhaoCombination:getAttack()
    return self.__attack
end

--@desc: 命中性能
--@author:Seven
--@time:2021-05-15 10:58:44
function AutoZhaoCombination:getHit()
    return self.__hit
end

--@desc: 伤害性能
--@author:Seven
--@time:2021-05-15 11:47:28
function AutoZhaoCombination:getTopLimit()
    return self.__topLimit
end

--@desc: 消耗体力
--@author:Seven
--@time:2021-05-15 11:47:37
function AutoZhaoCombination:getTiliCost()
    return self.__tiliCost
end

function AutoZhaoCombination:getAttackAverage()
    return self.__attackAverage
end

--@desc: 招式攻击段
--@author:Seven
--@time:2021-05-15 11:11:00
function AutoZhaoCombination:getAtkList()
    return self.__atkList
end

--@desc: 获取攻击招式信息
--@author:Seven
--@time:2021-06-25 20:10:11
--@index: 顺序索引
--@return [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
function AutoZhaoCombination:getAtkZhaoInfoByIndex(index)
    if index <= 0 then
        assert(false, "获取攻击Atk，参数不能小于1")
    end

    if index > #self.__atkList then
        assert(false, "获取攻击Atk，参数越界：" .. index)
    end

    return self.__atkList[index]
end

--@desc: 该招式出招攻击次数
--@author:Seven
--@time:2021-05-15 11:10:55
function AutoZhaoCombination:getAtkCount()
    return #self.__atkList
end

--@desc: 获取招式组合伤害总权重
--@author:Seven
--@time:2021-06-25 20:27:39
function AutoZhaoCombination:getAttackHurtTotalWeight()
    local totalWeight = 0

    for i, zhaoInfo in ipairs(self.__atkList) do
        totalWeight = totalWeight + zhaoInfo:getHurtWeight()
    end

    return totalWeight
end

function AutoZhaoCombination:loadFromRes(res_data)
    if res_data.atkList == nil then
        assert(false, "被动招式组合 atkList 不为空")
    end

    for key, v in pairs(res_data) do
        if key ~= "atkList" then
            self["__" .. key] = v
        else
            local list = string.split(v, "#")
            if MapIsEmpty(list) == false then
                for i, zhaoInfoId in ipairs(list) do
                    local zhaoInfo = self:__getZhaoInfo(zhaoInfoId)
                    table.insert(self.__atkList, zhaoInfo)
                end
            else
                assert(false, "招式组合:" .. res_data.id .. " 的atkList 解析错误")
            end
        end
    end
end
--@endregion

function AutoZhaoCombination:__getZhaoInfo(zhaoInfo_id)
    local res = AutoZhaoInfo_Res[zhaoInfo_id]

    if res == nil then
        assert(false, "武功被动招式 配置表中没有该id：" .. zhaoInfo_id .. " 所对应的信息")
    end

    local zhaoInfo = ZhaoInfo:create(res)

    return zhaoInfo
end

return class("AutoZhaoCombination", {}, AutoZhaoCombination)
0000