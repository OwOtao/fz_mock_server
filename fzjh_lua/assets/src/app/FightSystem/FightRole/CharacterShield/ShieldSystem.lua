--[[
    author:Seven
    time:2023-02-10 16:26:36
    desc: 角色护盾系统
    ]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local BasicShield = require("app.FightSystem.FightRole.CharacterShield.BasicShield")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local ShieldSystem = {}

function ShieldSystem:create()
    return ShieldSystem.new()
end

function ShieldSystem:onInit()
    --@desc 存放气血护盾对象
    self.__qiShields = {}

    self.__shieldIndexId = 500
end

--@desc: 消耗气血护盾
--@author:Seven
--@time:2023-02-10 17:16:22
--@costValue: 消耗护盾的值
--@return 返回被消耗的护盾数组
function ShieldSystem:costQiShieldValue(costValue)
    if costValue < 0 then
        error("ShieldSystem:costQiShieldValue 参数不可小于0")
    end

    if costValue > self:getTotalQiShieldValue() then
        error("ShieldSystem:costQiShieldValue 参数不可大于当前气血护盾总值")
    end

    local removeList = {}

    local remainValue = costValue

    while self.__qiShields[1] ~= nil and remainValue > 0 do
        --@RefType [src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield]
        local shield = self.__qiShields[1]

        local shieldValue = shield:getShieldValue()

        if shieldValue > remainValue then
            shield:setShieldValue(shieldValue - remainValue)
            remainValue = 0
        else
            remainValue = remainValue - shieldValue
            shield:setShieldValue(0)
            table.remove(self.__qiShields, 1)
            table.insert(removeList, shield)
        end
    end

    if table.getn(removeList) > 0 then
        for _, removedShield in ipairs(removeList) do
            --@RefType [src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield]
            removedShield = removedShield

            --@desc 移除的护盾
            if removedShield:getShieldSource() == "buffShield" then
                --@desc 除buff
                self.__character:removeCharacterBuff(removedShield:getBuffId())
            end
        end
    end

    return removeList
end

--@desc: 获取气血护盾值
--@author:Seven
--@time:2023-02-10 17:17:32
function ShieldSystem:getTotalQiShieldValue()
    local value = 0

    self:__walkQiShields(
        function(index, shield)
            --@RefType [src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield]
            shield = shield

            value = value + shield:getShieldValue()
        end
    )

    return value
end

--@desc: 根据气血护盾id获取护盾对象
--@author:Seven
--@time:2024-01-02 15:38:29
--@shieldId: 护盾id
--@return [src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield]
function ShieldSystem:getQiShield(shieldId)
    local shield
    self:__walkQiShields(
        function(index, s)
            if s:getShieldId() == shieldId then
                shield = s
                return true
            end
        end
    )

    return shield
end

--@desc: 增加护盾
--@author:Seven
--@time:2023-02-10 17:27:33
--@shield: [src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield]
--@return 气血护盾id
function ShieldSystem:addQiShield(shield)
    local id = self:__getNewShieldId()

    shield:setShieldId(id)

    table.insert(self.__qiShields, isImpl(shield, BasicShield))

    self:__sortShields(self.__qiShields)

    return shield:getShieldId()
end

--@desc: 移除护盾
--@author:Seven
--@time:2023-02-10 20:05:03
--@id: 护盾id
--@return [src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield]
function ShieldSystem:removeQiShield(id)
    local removeIndex
    local removeShield
    self:__walkQiShields(
        function(index, shield)
            if id == shield:getShieldId() then
                removeIndex = index
                removeShield = shield
                return true
            end
        end
    )

    if removeIndex == nil then
        return nil
    end

    table.remove(self.__qiShields, removeIndex)

    return removeShield
end

--@desc: 获取气血护盾
--@author:Seven
--@time:2023-02-10 20:06:50
--@index: 索引
--@return src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield
function ShieldSystem:__getQiShieldByIndex(index)
    return self.__qiShields[index]
end

--@desc: 获取当前生效的护盾动画id，可能返回nil
--@author:Seven
--@time:2023-02-10 20:07:30
--@return: 护盾动画id
function ShieldSystem:getCurrQiShieldAnimId()
    local shield = self:__getQiShieldByIndex(1)

    if shield ~= nil then
        return shield:getShieldAnimId()
    end

    return nil
end

--@desc: 护盾排序
--@author:Seven
--@time:2023-02-10 20:08:09
--@shields: 护盾数组
function ShieldSystem:__sortShields(shields)
    table.sort(
        shields,
        function(a, b)
            return a:getPriority() > b:getPriority()
        end
    )
end

function ShieldSystem:__getNewShieldId()
    self.__shieldIndexId = self.__shieldIndexId + 1

    return self.__shieldIndexId
end

--@desc: 遍历气血护盾
--@author:Seven
--@time:2023-02-10 17:19:44
--@func:
function ShieldSystem:__walkQiShields(func)
    if table.getn(self.__qiShields) <= 0 then
        return
    end

    for index, shield in ipairs(self.__qiShields) do
        if func(index, shield) == true then
            break
        end
    end
end

function ShieldSystem:onDestory()
end

function ShieldSystem:onUpdate(ft)
end

return newClass("ShieldSystem", {ABasicCharacterFuncSystem}, ShieldSystem)
000