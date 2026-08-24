local ZhaoBreakThroughPresent = class("ZhaoBreakThroughPresent", cc.Layer)

function ZhaoBreakThroughPresent:create()
    local p = ZhaoBreakThroughPresent:new()
    p:init()
    return p
end

function ZhaoBreakThroughPresent:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveBreakThroughUI"):create()
    self.__ui:addTo(self)
end

function ZhaoBreakThroughPresent:onResume()
	self:showLayer()
end

function ZhaoBreakThroughPresent:setRole(role)
	self.__role = role
end

function ZhaoBreakThroughPresent:initData(martialData)
    self.__martialData = martialData
    self.__amartial = martialData.amartial
    self.__bmartial = martialData.bmartial
    self.__cmartial = martialData.cmartial
    self.__dmartial = martialData.dmartial
end

function ZhaoBreakThroughPresent:setIndex(index)
    self.__index = index
end

function ZhaoBreakThroughPresent:showLayer()
    self:setIndex(1)

    self:initSkillTitleList()
    
    self:setTitleListView()

    self:refreshSkillListView()
    
    self:setTextWxxdCount()
end

function ZhaoBreakThroughPresent:refreshUI()
    self:refreshSkillListView()

    self:setTextWxxdCount()
end

function ZhaoBreakThroughPresent:setTextWxxdCount()
    self.__ui:setWxxdCount1(self.__role:getCHAttrName("amartial").."："..self.__amartial)
    self.__ui:setWxxdCount2(self.__role:getCHAttrName("bmartial").."："..self.__bmartial)
    self.__ui:setWxxdCount3(self.__role:getCHAttrName("cmartial").."："..self.__cmartial)
    self.__ui:setWxxdCount4(self.__role:getCHAttrName("dmartial").."："..self.__dmartial)
end

function ZhaoBreakThroughPresent:initSkillTitleList()
    local skillList = self.__role:getSkillBreakThroughSystem():getZhaoBreakThroughList()
    self.__skillTitleList = {
        {name = "拳脚", list = {}},
        {name = "兵器", list = {}},
        {name = "轻功", list = {}},
        {name = "内功", list = {}},
        {name = "招架", list = {}}
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

function ZhaoBreakThroughPresent:setTitleListView()
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
            self:initSkillList(skillTab.list)
            self.__ui:clearListViewInnerContainerPos()
            self:setSkillListView()
        end
        table.insert(retArray, tab)
    end
    
    self.__ui:setTitleListView(retArray)
end

function ZhaoBreakThroughPresent:refreshSkillListView()
    self.__ui:lightTab(self.__skillTitleList[self.__index].name)
    self:initSkillList(self.__skillTitleList[self.__index].list)
    self:setSkillListView()
end

function ZhaoBreakThroughPresent:initSkillList(list)
    self.__skillList = list

    self.__showList = self.__skillList

    if not MapIsEmpty(self.__skillList) then
        table.sort(self.__skillList, function(a, b)
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
    end
end

function ZhaoBreakThroughPresent:insertZhaoList(zhaoList,skillId)
    local insetPos = 1
    
    local skillList = clone(self.__skillList)

    for i,v in ipairs(skillList) do
        if v.id == skillId then
            insetPos = i
        end
    end

    for i,zhao in ipairs(zhaoList) do
        if self.__role:getSkillZhaoExp(zhao.id) > 0 then
            insetPos = insetPos + 1
            zhao.isZhao = true
            table.insert(skillList,insetPos,zhao)
        end
    end

    self.__showList = skillList
end

function ZhaoBreakThroughPresent:setSkillListView()
    local retArray = {}
    local list = self.__showList

    if MapIsEmpty(list) == false then
        for index,v in ipairs(list) do
            local tab = {}

            if v.isZhao == true then
                tab.name = v.name
                tab.lv = Helper:mathFloor(self.__role:getSkillZhaoExp(v.id)).."/"..self.__role:getZhaoExpLimit(v.id,self.__role:getZhaoLvLimit(v.id))
                tab.namePosX = 104
                tab.func = function()
                    if self.__role:getSkillBreakThroughSystem():isZhaoBreakThroughMaxLevel(v.id) then
                        PopText("该招式已是最高重数，不可再突破")
                        return
                    end
                    self:showConfirmTip(v)
                end
            else
                tab.name = v.name
                tab.lv = self.__role:getSkillLv(v.id).."级"
                tab.namePosX = 58
                tab.func = function()
                    
                    local zhaoList = self.__role:getSkillZhaoList(v.id)
                    self:insertZhaoList(zhaoList,v.id)
                    self:setSkillListView()
                end
            end

            table.insert(retArray, tab)
        end
    end

    self.__ui:setSkillListView(retArray)
end

function ZhaoBreakThroughPresent:showConfirmTip(zhao)
    PopupLayerController:showLayer(
        "ZhaoBreakPopPresent",
        function(layer)
            layer:setZhao(zhao)
            layer:setRole(self.__role)
            layer:setCallBack(function()
                self:refreshUI()
            end)
            layer:showLayer()
        end
    )
end

Helper:classDefNodeGetInstance(ZhaoBreakThroughPresent)
return ZhaoBreakThroughPresent
000000000000000