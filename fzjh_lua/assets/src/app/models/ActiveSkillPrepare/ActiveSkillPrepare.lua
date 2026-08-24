local class = require("third.class.NewClass")
local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local IActiveSkillPrepareInput = require("app.models.ActiveSkillPrepare.IActiveSkillPrepareInput")
local IActiveSkillPrepareOutput = require("app.models.ActiveSkillPrepare.IActiveSkillPrepareOutput")
local ActiveSkillPrepare = {}

function ActiveSkillPrepare:create()
    local o = ActiveSkillPrepare.new()
    return o
end

function ActiveSkillPrepare:ctor()
    self.__role = nil
    self.__weaponType = nil
    self.__activeSkillPrepare = nil
    self.__preparedActiveSkillList = nil -- {{skillId = "xianglongshibazhang", activeSkillId = "feilongzaitian", level = 9}}
    self.__canPrepareActiveSkillList = nil -- {{skillId = "xianglongshibazhang", activeSkillId = "kanglongyouhui", level = 9}}
end

function ActiveSkillPrepare:setRole(role)
    self.__role = assert(role, "role can not is nil")
end

function ActiveSkillPrepare:initialize()
    -- 获得当前武器类型
    if self.__weaponType == nil then
        self.__weaponType = self.__role:getCurrWeaponType()
    end
    assert(self.__weaponType ~= nil, "weaponType can not is nil")
    -- 获得当前已经准备的主动技能列表
    self.__preparedActiveSkillList, self.__canPrepareActiveSkillList = self.__role:getPreparedActiveZhaoListAndCanPrepareActiveZhaoList(self.__weaponType)
    
    -- 每次初始化完成都存一次（需求）
    self:__savePreparedActiveSkillList()
end

function ActiveSkillPrepare:setOutput(output)
    self.__output = assertIsInstance(output, IActiveSkillPrepareOutput)
end

--[[
    @desc: 设置武器第一类型
    author:TangJian
    time:2022-09-14 16:27:29
    --@weaponType: 武器第一类型
    @return:
]]
function ActiveSkillPrepare:setWeaponType(weaponType)
    self.__weaponType = weaponType
    self:initialize()
end

function ActiveSkillPrepare:setWeaponSecType(weaponSecType)
    assert(false, "该类对应旧版角色数据，旧版数据规则无需使用武器二类型")
end

--[[
    @desc: 获取武器第一类型
    author:TangJian
    time:2022-09-14 16:27:16
    @return:
]]
function ActiveSkillPrepare:getWeaponType()
    return self.__weaponType
end

--[[
    @desc: 获得当前准备的主动技能id列表
    author:TangJian
    time:2022-09-14 16:26:43
    @return:
]]
function ActiveSkillPrepare:getPreparedActiveSkillList()
    return self.__preparedActiveSkillList
end

--[[
    @desc: 准备主动技能
    author:TangJian
    time:2022-09-14 16:21:01
    --@idx: 准备的位置
	--@skillId: 技能id
    @return:
]]
function ActiveSkillPrepare:prepareActiveSkill(currIndex, toIndex)
    if toIndex > 6 then
        self.__preparedActiveSkillList[currIndex] = self.__canPrepareActiveSkillList[toIndex - 6]
    else
        local temp = self.__preparedActiveSkillList[currIndex]
        self.__preparedActiveSkillList[currIndex] = self.__preparedActiveSkillList[toIndex]
        self.__preparedActiveSkillList[toIndex] = temp
    end
    self:__savePreparedActiveSkillList()
    self:initialize()
end

--[[
    @desc: 获取当前能准备的主动技能列表
    author:TangJian
    time:2022-09-14 17:14:06
    @return:
]]
function ActiveSkillPrepare:getCanPrepareActiveSkillList()
    return self.__canPrepareActiveSkillList
end

--[[
    @desc: 保存准备的技能列表
    author:TangJian
    time:2022-10-19 17:03:34
    @return:
]]
function ActiveSkillPrepare:__savePreparedActiveSkillList()
    -- 准备过一次主动技能后，保存配置
    self.__role:savePreparedActiveZhaoList(
        self.__weaponType,
        table.map(
            self.__preparedActiveSkillList,
            function(v)
                v = clone(v)
                v.level = nil
                return v
            end
        )
    )
end

return class("ActiveSkillPrepare", {IActiveSkillPrepareInput}, ActiveSkillPrepare)
0000000000000