local class = require("third.class.NewClass")
local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local IActiveSkillPreparePresenterInput = require("app.presenters.ActiveSkillPrepare.IActiveSkillPreparePresenterInput")
local IActiveSkillPrepareOutput = require("src.app.models.ActiveSkillPrepare.IActiveSkillPrepareOutput")
local IActiveSkillPrepareInput = require("app.models.ActiveSkillPrepare.IActiveSkillPrepareInput")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")
local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")

local ActiveSkillPreparePresenter = {}

function ActiveSkillPreparePresenter:create()
    local o = ActiveSkillPreparePresenter.new()
    return o
end

function ActiveSkillPreparePresenter:setInput(input)
    --@RefType [IActiveSkillPrepareInput]
    self.__input = assertIsInstance(input, IActiveSkillPrepareInput)
end

function ActiveSkillPreparePresenter:setOutput(output)
    self.__output = output
end

--[[
    @desc: 显示整个界面
    author:TangJian
    time:2022-09-09 19:50:33
    @return:
]]
function ActiveSkillPreparePresenter:show()
    self:__initBarListAndWeaponTypeList()
    self._currNavigationBarIndex = table.indexof(self:__getWeaponTypeList(), self.__input:getWeaponType())
    assert(self._currNavigationBarIndex, "can not find " .. tostring(self.__input:getWeaponType()) .. " in " .. [[{"拳脚", "剑", "刀", "棍", "鞭", "暗器", "双持", "乐器"}]])
    self.__output:setNavigationBar(self:__getNavigationBarList(), self._currNavigationBarIndex)
    self.__output:setTopText("你目前正在使用的技能有：")
    self.__output:showMiddleList(self:__getMiddleList())
    self.__output:setBottomText(self:__getSkillConditionDesc())
end

--[[
    @desc: 点击导航栏
    author:TangJian
    time:2022-09-09 19:49:19
    --@idx: 点击位置
    @return:
]]
function ActiveSkillPreparePresenter:clickNavigationBar(idx)
    self.__input:setWeaponType(self:__getWeaponTypeList()[idx])
    self:show()
end

--[[
    @desc: 点击中间列表项
    author:TangJian
    time:2022-09-09 19:49:37
    --@idx: 位置
    @return:
]]
function ActiveSkillPreparePresenter:clickMiddleItem(idx)
    self._clickActiveSkillIndex = Helper:getDef(idx, 1)
    self:popSelectActiveSkillLayer()
    self.__output:setSelectTextStr("请选择你想要准备在技能" .. tostring(self._clickActiveSkillIndex) .. "的技能")
end

--[[
    @desc: 弹出选择主动技能的界面
    author:TangJian
    time:2022-09-09 19:50:14
    @return:
]]
function ActiveSkillPreparePresenter:popSelectActiveSkillLayer()
    self.__output:showSelectUI()

    local list = {}
    local prepareList = self.__input:getPreparedActiveSkillList()
    local skillIndex = 1
    for i = 1, 6 do
        if prepareList[i] then
            local skill = Skill:getSkill(prepareList[i].skillId)
            local activeZhao = Skill:getActiveZhao(prepareList[i].activeSkillId)
            table.insert(
                list,
                {skillIndex, true, "技能" .. tostring(i), activeZhao.name, tostring(prepareList[i].level) .. "重", skill.name, prepareList[i].skillId, prepareList[i].activeSkillId}
            )
        end
        skillIndex = skillIndex + 1
    end

    local canPrepareList = self.__input:getCanPrepareActiveSkillList()
    for i = 1, #canPrepareList do
        if canPrepareList[i] then
            local skill = Skill:getSkill(canPrepareList[i].skillId)
            local activeZhao = Skill:getActiveZhao(canPrepareList[i].activeSkillId)
            table.insert(
                list,
                {skillIndex, false, "未装备", activeZhao.name, tostring(canPrepareList[i].level) .. "重", skill.name, canPrepareList[i].skillId, canPrepareList[i].activeSkillId}
            )
        end
        skillIndex = skillIndex + 1
    end
    self.__output:showSelectList(list)
end

-- 选择主动技能
function ActiveSkillPreparePresenter:clickSelectItem(idx)
    self.__input:prepareActiveSkill(self._clickActiveSkillIndex, idx)
    self:show()
    self.__output:hideSelectUI()
end

function ActiveSkillPreparePresenter:__getMiddleList()
    local skillList = self.__input:getPreparedActiveSkillList()
    local outputList = {}
    for i = 1, 6 do
        if skillList[i] then
            local skill = Skill:getSkill(skillList[i].skillId)
            local activeZhao = Skill:getActiveZhao(skillList[i].activeSkillId)
            table.insert(outputList, {"栏位" .. tostring(i), tostring(skillList[i].level) .. "重", skill.name, activeZhao.name})
        else
            table.insert(outputList, {"栏位" .. tostring(i), "", "", "点击准备技能", {r = 0, g = 0, b = 0}, 42, cc.c4b(213, 213, 213, 213), 0})
        end
    end
    return outputList
end

function ActiveSkillPreparePresenter:__getSkillConditionDesc()
    local skillList = self.__input:getPreparedActiveSkillList()

    local secondTypeName = self:__getNavigationBarList()[self._currNavigationBarIndex]
    local firstType = SkillClassifyManager:getOldActiveMethodBySecondTypeName(secondTypeName)

    if MapIsEmpty(skillList) then
        return "当前未准备"..secondTypeName.."武学"
    end

    local skillId

    for i = 1, 6 do
        if skillList[i] then
            local activeZhao = Skill:getActiveZhao(skillList[i].activeSkillId)
            if activeZhao:checkTypeIsZhaoMethods(firstType) then
                skillId = skillList[i].skillId
                break
            end
        end
    end

    if not skillId then
        return "当前未准备"..secondTypeName.."武学"
    end

    local skill = Skill:getSkill(skillId)

    if not skill then
        assert(false, "can not find the skillId：" .. skillId)
    end
    
    local weaponTypeDesc = ""

    local currWeaponType = self:__getWeaponTypeList()[self._currNavigationBarIndex]
    if currWeaponType == "拳脚" then
        weaponTypeDesc = "无兵器"
    else
        local weapontypes = skill.weapontype
        if MapIsEmpty(weapontypes) == false then
            local secondTypeNames = {}
            for k, weapontype in pairs(weapontypes) do
                local name = WeaponTypesResManager:getSecondTypeNameBySecondUseType(weapontype)
                table.insert(secondTypeNames, name)
            end

            for i = 1, #secondTypeNames do
                weaponTypeDesc = weaponTypeDesc .. secondTypeNames[i]
                if i < #secondTypeNames then
                    weaponTypeDesc = weaponTypeDesc .. "、"
                end
            end
        else
            --武功weapontype字段为空，则根据当前武学类型获取所有二级兵器
            local secondTypeNames = WeaponTypesResManager:getAllSecondTypeNameByFirstType(currWeaponType)
            for i = 1, #secondTypeNames do
                weaponTypeDesc = weaponTypeDesc .. secondTypeNames[i]
                if i < #secondTypeNames then
                    weaponTypeDesc = weaponTypeDesc .. "、"
                end
            end
        end
    end

    if weaponTypeDesc and weaponTypeDesc ~= "" then
        return "当前武学" .. skill.name .. "需要装备：" .. weaponTypeDesc
    else
        return ""
    end
end

function ActiveSkillPreparePresenter:__initBarListAndWeaponTypeList()
    self.__barNameList = {}

    self.__weaponTypeList = {}

    local weaponFirstTypeForSkillPrepType = WeaponTypesResManager:getWeaponFirstTypeForSkillPrepType()

    local list = {}
    for weaponType, skillPrepType in pairs(weaponFirstTypeForSkillPrepType) do
        table.insert(list, {skillPrepType, weaponType})
    end

    table.sort(
        list,
        function(a, b)
            return tonumber(a[1]) < tonumber(b[1])
        end
    )

    for _, v in ipairs(list) do
        local name = SkillClassifyManager:getSecondTypeName(v[1])

        table.insert(self.__barNameList, name)
        if v[2] == "空手" then
            v[2] = "拳脚"
        end
        table.insert(self.__weaponTypeList, v[2])
    end
end

function ActiveSkillPreparePresenter:__getNavigationBarList()
    return self.__barNameList
end

function ActiveSkillPreparePresenter:__getWeaponTypeList()
    return self.__weaponTypeList
end

return class("ActiveSkillPreparePresenter", {IActiveSkillPrepareOutput, IActiveSkillPreparePresenterInput}, ActiveSkillPreparePresenter)
0000