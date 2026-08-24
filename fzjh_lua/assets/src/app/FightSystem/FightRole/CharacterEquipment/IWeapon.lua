local interface = require("third.class.interface")
local IWeapon = {}

--@desc:设置正在使用的角色
--@author:Seven
--@time:2025-10-29 16:57:02
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IWeapon:setUseCharacter(character)
end

function IWeapon:setId(id)
end

function IWeapon:getId()
end

function IWeapon:setItemId(id)
end

function IWeapon:getItemId()
end

function IWeapon:getWeaponAttr(name)
end

--@desc: 这是武器名称
--@author:Seven
--@time:2021-06-30 17:34:18
--@name: 武器名称
function IWeapon:setName(name)
end

--@desc: 该武器分类id
--@author:Seven
--@time:2021-07-08 21:45:02
function IWeapon:getWeaponResId()
end

--@desc: 获取武器名字
--@author:Seven
--@time:2021-06-30 17:32:52
function IWeapon:getName()
end

--@desc: 获取武器伤害力
--@author:Seven
--@time:2021-06-30 17:32:11
function IWeapon:getDamage()
end

--@desc: 设置武器名称
--@author:Seven
--@time:2021-06-30 17:33:07
function IWeapon:setDamage(value)
end

--@desc: 武器所属动作模组
--@author:Seven
--@time:2021-05-29 16:12:03
function IWeapon:getWeaponModule()
end

--@desc: 武器动画皮肤
--@author:Seven
--@time:2021-05-29 16:11:48
--@return
function IWeapon:getWeaponSkin()
end

--@desc: 武器对应的武学准备类型
--@author:Seven
--@time:2021-05-29 16:12:20
function IWeapon:getAutoChooseSkill()
end

--[[
    @desc:获得武器一级类型
    author:唐健
    time:2021-07-06 16:08:31
    @return:
]]
function IWeapon:getFirstType()
end

--@desc: 武器二级类型
--@author:Seven
--@time:2022-09-26 15:34:01
function IWeapon:getSecondType()
end

--[[
    @desc: 武器重量
    author:TangJian
    time:2022-01-14 11:57:47
    @return:
]]
function IWeapon:getWeight()
end

--@desc 坚韧度
function IWeapon:setTenacity(value)
end

function IWeapon:getTenacity()
end
--@desc 淬炼次数
function IWeapon:setCuilianCount(value)
end

function IWeapon:getCuilianCount()
end

--@desc 重量
function IWeapon:setWeight(value)
end

--@desc 坚硬度
function IWeapon:setHardnessValue(value)
end

function IWeapon:getHardnessValue()
end

--@desc 完好度
function IWeapon:setCommence(value)
end

function IWeapon:getCommence()
end

--@desc 损耗值
function IWeapon:setLossOfValue(value)
end

function IWeapon:getLossOfValue()
end

function IWeapon:getCommenceFactor()
end

function IWeapon:setCommenceFactor(value)
end

function IWeapon:updateFightState(state)
end

function IWeapon:getFightState()
end

function IWeapon:setFlyWeapon(value)
end

function IWeapon:getFlyWeapon()
end

function IWeapon:setBeflyWeapon(value)
end

function IWeapon:getBeflyWeapon()
end

function IWeapon:setBreakWeapon(value)
end

function IWeapon:getBreakWeapon()
end

function IWeapon:setBrokenWeapon(value)
end

function IWeapon:getBrokenWeapon()
end

function IWeapon:canFlyWeapon()
end

function IWeapon:canBeFlyWeapon()
end

function IWeapon:canBreakWeapon()
end

function IWeapon:canBrokenWeapon()
end

function IWeapon:getWeaponAttackSoundId()
end

function IWeapon:getBuffAdderGroupIds()
end

function IWeapon:setBuffArray(buffInfos)
end

function IWeapon:setBuffAdderGroupIds(buffLauncherIdList)
end

return interface("IWeapon", IWeapon)
000000000000