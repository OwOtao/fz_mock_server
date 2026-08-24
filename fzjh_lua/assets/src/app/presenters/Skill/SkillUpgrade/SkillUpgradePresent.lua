--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-07-19 15:57:15
--]]
local SkillUpgradePresent = class("SkillUpgradePresent", cc.Layer)

local SkillAdvance = require("app.models.skill.SkillAdvance.SkillAdvance")

local skillUpgradeConf = require("script.skill.skillUpgradeConf")["武功进阶"]

function SkillUpgradePresent:create()
    local p = SkillUpgradePresent:new()
    p:init()
    return p
end

function SkillUpgradePresent:init()
    self.__ui = require("app.views.ui.SkillUI.SkillUpgradeUI"):create()
    self.__ui:addTo(self)
end

function SkillUpgradePresent:showLayer(role,npcName)
    self.__role = role

    self.__ui:setTextName(npcName)

    self.__ui:setTextDesc("少侠希望老朽传授哪一门功法？")

    self:__initSkillList()

    self:setSkillListView()

    self:setBackFunc()

    self.__ui:showUI()
end

function SkillUpgradePresent:refreshLayer()
    self:__initSkillList()

    self:setSkillListView()
end

function SkillUpgradePresent:__initSkillList()
    self.__skillList = {}
    
    for k,v in pairs(skillUpgradeConf) do
        local skillAdvance = SkillAdvance:create(v)

        table.insert(self.__skillList, skillAdvance)
    end

    if #self.__skillList > 1 then
        table.sort(self.__skillList,function(a, b)
            if self.__role:getSkillExp(a:getSkillId()) > 0 and self.__role:getSkillExp(b:getSkillId()) <= 0 then
                return false
            elseif self.__role:getSkillExp(a:getSkillId()) <= 0 and self.__role:getSkillExp(b:getSkillId()) > 0 then
                return true

            else
                return a:getId() < b:getId()
            end
        end)
    end
end

function SkillUpgradePresent:setSkillListView()
    self.__ui:removeSkillListViewAllItems()

    for i,skillAdvance in ipairs(self.__skillList) do
        local skillPanel = self.__ui:createPanel()

        local isLearn = self.__role:getSkillExp(skillAdvance:getSkillId()) > 0

        local textColor = {r = 255, g = 255, b = 255}

        if isLearn then
            textColor = {r = 103, g = 103, b = 103}
        end

        self.__ui:setTextPanelName(skillPanel,skillAdvance:getSkillName(),textColor)

        self.__ui:setTextCondition1(skillPanel,"需要"..skillAdvance:getNeedSkillName().."达到"..skillAdvance:getNeedSkillLv().."级",textColor)

        local needZhaoText1 = ""

        if skillAdvance:getNeedActiveZhaoId1() then
            needZhaoText1 = "需要"..skillAdvance:getNeedActiveZhaoName1().."达到"..skillAdvance:getNeedActiveZhaoExp1().."点熟练度"
        end

        self.__ui:setTextCondition2(skillPanel,needZhaoText1,textColor)

        local needZhaoText2 = ""

        if skillAdvance:getNeedActiveZhaoId2() then
            needZhaoText2 = "需要"..skillAdvance:getNeedActiveZhaoName2().."达到"..skillAdvance:getNeedActiveZhaoExp2().."点熟练度"
        end
        
        self.__ui:setTextCondition3(skillPanel,needZhaoText2,textColor)

        self.__ui:setLearnTextVisible(skillPanel,isLearn,textColor)

        self.__ui:setLearnButtonVisible(skillPanel,not isLearn)

        self.__ui:setLearnButtonFunc(skillPanel,function()
            self:showConfirmTip(skillAdvance)
        end)
        
        self.__ui:insertPanelToSkillListView(skillPanel)
    end
end

function SkillUpgradePresent:setBackFunc()
    self.__ui:setBackFunc(function()
        PopupLayerController:hideLayer(
            "SkillUpgradePresent",
            function(layer)
                self.__ui:hideUI()
            end
        )
    end)
end

function SkillUpgradePresent:showConfirmTip(skillAdvance)
    PopupLayerController:showLayer(
        "SkillUpgradeConfirmPresent",
        function(layer)
            layer:setConfirmFunc(function()
                self:refreshLayer()
            end)
            layer:showLayer(self.__role,skillAdvance)
        end
    )
end

Helper:classDefNodeGetInstance(SkillUpgradePresent)
return SkillUpgradePresent
0000000