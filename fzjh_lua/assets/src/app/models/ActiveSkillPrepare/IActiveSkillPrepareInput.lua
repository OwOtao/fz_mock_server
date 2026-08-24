local IActiveSkillPrepareInput = {}

--[[
    @desc: 设置武器第一类型
    author:TangJian
    time:2022-09-14 16:27:29
    --@weaponType: 武器第一类型
    @return:
]]
function IActiveSkillPrepareInput:setWeaponType(weaponType)
end

--@desc: 设置武器二类型
--@author:Seven
--@time:2022-09-22 15:07:53
--@weaponSecType: 武器二类型
function IActiveSkillPrepareInput:setWeaponSecType(weaponSecType)
end

--[[
    @desc: 获取武器第一类型
    author:TangJian
    time:2022-09-14 16:27:16
    @return:
]]
function IActiveSkillPrepareInput:getWeaponType()
end

--[[
    @desc: 获得当前准备的主动技能id列表
    author:TangJian
    time:2022-09-14 16:26:43
    @return:
]]
function IActiveSkillPrepareInput:getPreparedActiveSkillList()
end

--[[
    @desc: 准备主动技能
    author:TangJian
    time:2022-09-14 16:21:01
    --@idx: 准备的位置
	--@skillId: 技能id
    @return:
]]
function IActiveSkillPrepareInput:prepareActiveSkill(currIndex, toIndex)
end

--[[
    @desc: 获取当前能准备的主动技能列表
    author:TangJian
    time:2022-09-14 17:14:06
    @return:
]]
function IActiveSkillPrepareInput:getCanPrepareActiveSkillList()
end

return IActiveSkillPrepareInput
000000