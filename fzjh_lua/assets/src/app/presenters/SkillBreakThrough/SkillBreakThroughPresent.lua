local SkillBreakThroughPresent = class("SkillBreakThroughPresent", cc.Layer)

function SkillBreakThroughPresent:create()
    local p = SkillBreakThroughPresent:new()
    p:init()
    return p
end

function SkillBreakThroughPresent:init()
    self.__ui = require("app.views.ui.SkillUI.SkillBreakThroughUI"):create()
    self.__ui:addTo(self)
end

function SkillBreakThroughPresent:onResume()
	self:showLayer()
end

function SkillBreakThroughPresent:setRole(role)
	self.__role = role
end

function SkillBreakThroughPresent:initData(martialData)
    self.__martialData = martialData
    self.__amartial = martialData.amartial
    self.__bmartial = martialData.bmartial
    self.__cmartial = martialData.cmartial
    self.__dmartial = martialData.dmartial
end

function SkillBreakThroughPresent:setIndex(index)
    self.__index = index
end

function SkillBreakThroughPresent:showLayer()
    self:setIndex(1)

    self:initSkillList()
    
    self:setTitleListView()

    self:refreshSkillListView()
    
    self:setTextWxxdCount()

    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    titleLayer:setCustomButton("技能突破",function()
        local ZhaoBreakThroughPresent = MainControllLayer:getLayer("ZhaoBreakThroughPresent")
        ZhaoBreakThroughPresent:setRole(self.__role)
        ZhaoBreakThroughPresent:initData(self.__martialData)
        MainControllLayer:pushLayer("ZhaoBreakThroughPresent")
    end)
end

function SkillBreakThroughPresent:refreshUI()
    self:refreshSkillListView()

    self:setTextWxxdCount()
end

function SkillBreakThroughPresent:setTextWxxdCount()
    self.__ui:setWxxdCount1(self.__role:getCHAttrName("amartial").."："..self.__amartial)
    self.__ui:setWxxdCount2(self.__role:getCHAttrName("bmartial").."："..self.__bmartial)
    self.__ui:setWxxdCount3(self.__role:getCHAttrName("cmartial").."："..self.__cmartial)
    self.__ui:setWxxdCount4(self.__role:getCHAttrName("dmartial").."："..self.__dmartial)
end

function SkillBreakThroughPresent:initSkillList()
    local skillList = self.__role:getSkillBreakThroughSystem():getSkillBreakThroughList()
    self.__skillTitleList = {
        {name = "拳脚", list = {}},
        {name = "兵器", list = {}},
        {name = "轻功", list = {}},
        {name = "内功", list = {}},
        {name = "招架", list = {}},
    }

    for i,skill in ipairs(skillList) do
        if skill.methods then
            for i,vtype in ipairs(skill.methods) do
                if vtype == SKILL_METHOD_TYPE_QUANJIAO then
                    table.insert(self.__skillTitleList[1].list,skill)
                elseif vtype == SKILL_METHOD_TYPE_NEIGONG then
                    table.insert(self.__skillTitleList[4].list,skill)
                elseif vtype == SKILL_METHOD_TYPE_QINGGONG then
                    table.insert(self.__skillTitleList[3].list,skill)
                elseif vtype == SKILL_METHOD_TYPE_ZHAOJIA and #skill.methods == 1 then
                    table.insert(self.__skillTitleList[5].list,skill)
                elseif vtype == SKILL_METHOD_TYPE_JIAN or vtype == SKILL_METHOD_TYPE_DAO or vtype == SKILL_METHOD_TYPE_GUN or vtype == SKILL_METHOD_TYPE_ANQI or vtype == SKILL_METHOD_TYPE_BIANFA or vtype == SKILL_METHOD_TYPE_SHUANGCHI or vtype == SKILL_METHOD_TYPE_QIN then
                    local temp = false
                    for _,tempSkill in ipairs(self.__skillTitleList[2].list) do
                        if tempSkill.id == skill.id then
                            temp = true
                        end
                    end

                    if temp == false then
                        table.insert(self.__skillTitleList[2].list, skill)
                    end

                end
            end
        end
    end
end

function SkillBreakThroughPresent:setTitleListView()
    local retArray = {}
    for i,skillTab in ipairs(self.__skillTitleList) do
        local tab = {
            name = "",
            func = EMPTY_FUNC
        }
        tab["title"] = skillTab.name
        tab["func"] = function()
            self:setIndex(i)
            self.__ui:lightTab(skillTab.name)
            self:setSkillListView(skillTab.list)
        end
        table.insert(retArray, tab)
    end
    
    self.__ui:setTitleListView(retArray)
end

function SkillBreakThroughPresent:refreshSkillListView()
    self.__ui:lightTab(self.__skillTitleList[self.__index].name)
    self:setSkillListView(self.__skillTitleList[self.__index].list)
end

function SkillBreakThroughPresent:setSkillListView(list)
    local retArray = {}
    local function sortSkill(list)
        if MapIsEmpty(list) == true then
            return list
        end
        table.sort(list, function(a, b)
            if self.__role:getSkillBreId(a.id) == self.__role:getSkillBreId(b.id) then
                if self.__role:getSkillExp(a.id) == self.__role:getSkillExp(b.id) then
                    return a.id < b.id
                else
                    return self.__role:getSkillExp(a.id) < self.__role:getSkillExp(b.id)
                end
            else
                return self.__role:getSkillBreId(a.id) < self.__role:getSkillBreId(b.id)
            end
        end)
        return list
    end
    list = sortSkill(list)
    if MapIsEmpty(list) == false then
        for i,skill in ipairs(list) do
            local tab = {
                name = "",
                lv = "",
                func = EMPTY_FUNC
            }
            local breMap = self.__role:getSkillBreakThroughSystem():getSkillBreakThroughMap(skill.id)
            local currLv = self.__role:getSkillLv(skill.id)
            tab["name"] = skill.name
            tab["lv"] = currLv.."/"..breMap.Blevel.."级"
            tab["func"] = function()
                if self.__role:getSkillBreakThroughSystem():isSkillBreakThroughMaxLevel(skill.id) then
                    PopText("该武学已是最高突破等级上限，不可再突破")
                    return
                end
                self:showConfirmTip(skill)
            end
            table.insert(retArray, tab)
        end
    end

    self.__ui:setSkillListView(retArray)
end

function SkillBreakThroughPresent:showConfirmTip(skill)
    PopupLayerController:showLayer(
        "SkillBreakPopPresent",
        function(layer)
            layer:setSkill(skill)
            layer:setRole(self.__role)
            layer:setCallBack(function(result,arg)
                if result == true then
                    local currency_list = arg
                    self:initData(currency_list)
                    self:refreshUI()
                end
            end)
            layer:showLayer()
        end
    )
end

Helper:classDefNodeGetInstance(SkillBreakThroughPresent)
return SkillBreakThroughPresent
0000