--[[
    author:Seven
    time:2022-11-19 15:27:11
    desc: 招式组合资源类
]]
local ZhaoInfo = require("app.FightSystem.FightSkill.ZhaoInfo")

local AutoZhaoInfo_Res = require("script.newbattle.demo.autoZhaoInfo")["被动招式"]

local class = require("third.class.NewClass")
local BasicAutoZhaoCombination = {}

function BasicAutoZhaoCombination:create(res)
    return BasicAutoZhaoCombination.new():__init(res)
end

function BasicAutoZhaoCombination:__init(res)
    self.__res = res

    return self
end

--@desc: 招式组合ID
--@author:Seven
--@time:2021-05-15 10:59:55
function BasicAutoZhaoCombination:getId()
    return self.__res.id
end

--@desc: 需求武学等级
function BasicAutoZhaoCombination:getLv()
    return self.__res.lv
end

--@desc: 对应武学ID
--@author:Seven
--@time:2021-05-15 10:59:41
function BasicAutoZhaoCombination:getSkillId()
    return self.__res.skillId
end

--@desc: 招式组id
--@author:Seven
--@time:2021-05-15 10:59:34
function BasicAutoZhaoCombination:getZhaoId()
    return self.__res.zhaoId
end

--@desc: 第几招
--@author:Seven
--@time:2021-05-15 10:59:10
function BasicAutoZhaoCombination:getZhaoIdText()
    return self.__res.zhaoIdText
end

--@desc: 招式名称
--@author:Seven
--@time:2021-05-15 10:59:03
function BasicAutoZhaoCombination:getZhaoName()
    return self.__res.zhaoName
end

--@desc: 出招文本
--@author:Seven
--@time:2021-05-15 10:58:55
function BasicAutoZhaoCombination:getActionText()
    return self.__res.actionText
end

--@desc: 伤害描述文本类型
--@author:Seven
--@time:2021-07-14 11:53:38
function BasicAutoZhaoCombination:getDamageType()
    return self.__res.damageType
end

--@desc: 击中部位系列
--@author:Seven
--@time:2021-07-14 11:54:03
function BasicAutoZhaoCombination:getHurtPosClass()
    return self.__res.hurtPosClass
end

--@desc: 攻击性能
--@author:Seven
--@time:2021-05-15 10:58:35
function BasicAutoZhaoCombination:getAttack()
    return self.__res.attack
end

--@desc: 命中性能
--@author:Seven
--@time:2021-05-15 10:58:44
function BasicAutoZhaoCombination:getHit()
    return self.__res.hit
end

--@desc: 伤害性能
--@author:Seven
--@time:2021-05-15 11:47:28
function BasicAutoZhaoCombination:getTopLimit()
    return self.__res.topLimit
end

--@desc: 消耗体力
--@author:Seven
--@time:2021-05-15 11:47:37
function BasicAutoZhaoCombination:getTiliCost()
    return self.__res.tiliCost
end

function BasicAutoZhaoCombination:getAttackAverage()
    return self.__res.attackAverage
end

--@desc: 招式攻击段
--@author:Seven
--@time:2021-05-15 11:11:00
function BasicAutoZhaoCombination:getAtkList()
    if self.__atkListIds == nil then
        self.__atkListIds = {}
        local list = string.split(self.__res.atkList, "#")
        if MapIsEmpty(list) == false then
            for i, zhaoInfoId in ipairs(list) do
                table.insert(self.__atkListIds, zhaoInfoId)
            end
        else
            assert(false, "招式组合:" .. self:getId() .. " 的atkList 解析错误")
        end
    end

    return self.__atkListIds
end

--@desc: 获取攻击招式信息
--@author:Seven
--@time:2021-06-25 20:10:11
--@index: 顺序索引
--@return [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
function BasicAutoZhaoCombination:getAtkZhaoInfoIdByIndex(index)
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
function BasicAutoZhaoCombination:getAtkCount()
    return table.getn(self:getAtkList())
end

return class("BasicAutoZhaoCombination", {}, BasicAutoZhaoCombination)
000000000000