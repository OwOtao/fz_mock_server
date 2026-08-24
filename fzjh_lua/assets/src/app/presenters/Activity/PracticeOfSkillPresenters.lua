--@desc 旧版练武场，已弃用

-- local class = require("third.class.NewClass")
-- local PracticeOfSkillPresenters = {}

-- function PracticeOfSkillPresenters:create(iNianBeastView,iNianBeastModel)
--     local p = PracticeOfSkillPresenters:new()
--     p:init(iNianBeastView,iNianBeastModel)
--     return p
-- end

-- function PracticeOfSkillPresenters:init(iNianBeastView,iNianBeastModel)
--     self.__input = iNianBeastModel
--     self.__output = iNianBeastView
-- end

-- function PracticeOfSkillPresenters:setRole(role)
--     self.__input:setRole(role)
-- end

-- function PracticeOfSkillPresenters:setSkillId(skillId)
--     self.__input:setSkillId(skillId)
-- end

-- function PracticeOfSkillPresenters:showLayer()
--     self.__input:getActionInfo(function()
--         self.__output:showLayer(function()
--             self.__output:showUI()
--             self:__initUI()
--         end)
--     end)

--     self.__input:setAfterRewardFunc(function()
--         self.__input:getActionInfo(function()
--             self.__output:showListView(self.__input:getRewardList())
--         end)
--     end)

--     self:__setRuleFunc()

--     self.__output:setButtonBack(function()
--         self.__output:hideLayer(function()
--             self.__output:hideUI()
--         end)
--     end)
-- end

-- function PracticeOfSkillPresenters:__initUI()
--     self.__output:setTextTitle(self.__input:getActionName())
--     self.__output:setTextDesc(self.__input:getActionDesc())

--     local skillLv = self.__input:getSkillLv()
--     if skillLv == 0 then
--         self.__output:setText_3Str(self.__input:getSkillName().."未领悟")
--     else
--         self.__output:setText_3Str(self.__input:getSkillName().."等级："..tostring(self.__input:getSkillLv()).."级")
--     end

--     self.__output:setText_3StrColor(cc.c3b(255,255,255))
    
--     self.__output:showListView(self.__input:getRewardList())
-- end

-- function PracticeOfSkillPresenters:initRule(ruleInfo)
-- 	self.__ruleInfo = ruleInfo
-- end

-- function PracticeOfSkillPresenters:__setRuleFunc()
-- 	self.__output:setButtonRuleFunc(function()
--         self:__showRule()
--     end)
-- end

-- function PracticeOfSkillPresenters:__showRule()
-- 	PopupLayerController:showLayer("ActionRuleUI",function(layer)
--         layer:showUI()
--         layer:setTextTitle("活动规则")
--         layer:showPanel_1(self.__ruleInfo)
--         layer:setButtonBack(function()
--             PopupLayerController:hideLayer("ActionRuleUI",function(layer)
--                 layer:hideUI()
--             end)
--         end)
--     end)
-- end

-- return class("PracticeOfSkillPresenters", {}, PracticeOfSkillPresenters)

0000000000