local SkillUpgradeConfirmPresent = class("SkillUpgradeConfirmPresent", cc.Layer)

local SkillAdvance = require("app.models.skill.SkillAdvance.SkillAdvance")

local skillUpgradeConf = require("script.skill.skillUpgradeConf")["武功进阶"]

local Record = require("app.models.Record.Record")

function SkillUpgradeConfirmPresent:create()
    local p = SkillUpgradeConfirmPresent:new()
    p:init()
    return p
end

function SkillUpgradeConfirmPresent:init()
    self.__ui = require("app.views.ui.SkillUI.SkillUpgradeConfirmUI"):create()
    self.__ui:addTo(self)
end

function SkillUpgradeConfirmPresent:showLayer(role,skillAdvance)
    self.__role = role

    self.__skillAdvance = skillAdvance

    self:setTextDesc()

    self:setTextTitle()

    self:setTextSkillName()

    self:setTextSkillLv()

    self:setTextZhaoName1()

    self:setTextZhaoExp1()

    self:setTextZhaoName2()

    self:setTextZhaoExp2()

    self:setButton1Func()

    self:setButton2Func()

    self.__ui:showUI()
end

function SkillUpgradeConfirmPresent:setConfirmFunc(confirmFunc)
    self.__confirmFunc = confirmFunc
end

function SkillUpgradeConfirmPresent:setTextDesc()
    local skillName = self.__skillAdvance:getSkillName()

    local itemName = self.__role:getOneItemByKey(self.__skillAdvance:getItemId()).name 

    local itemCount = self.__skillAdvance:getItemNum()

    local needSkillName = self.__skillAdvance:getNeedSkillName()

    local needSkillLv = self.__skillAdvance:getNeedSkillLv()
    
    local text = "是否希望老朽传授于你"..skillName.."，若想学习此门功法，需要缴纳"..itemName.."*"..itemCount.."，并且"..needSkillName.."达到"..needSkillLv.."级"
    
    if self.__skillAdvance:getNeedActiveZhaoId1() then
        text = text.."，同时"..self.__skillAdvance:getNeedActiveZhaoName1().."熟练度达到"..self.__skillAdvance:getNeedActiveZhaoExp1()
    end

    if self.__skillAdvance:getNeedActiveZhaoId2() then
        text = text.."，"..self.__skillAdvance:getNeedActiveZhaoName2().."熟练度达到"..self.__skillAdvance:getNeedActiveZhaoExp2()
    end

    text = text.."。"

    self.__ui:setTextDesc(text)
end

function SkillUpgradeConfirmPresent:setTextTitle()
    self.__ui:setTextTitle("领悟后可获得新武学如下：")
end

function SkillUpgradeConfirmPresent:setTextSkillName()
    self.__ui:setTextSkillName(self.__skillAdvance:getSkillName())
end

function SkillUpgradeConfirmPresent:setTextSkillLv()
    self.__ui:setTextSkillLv(self.__skillAdvance:getSkillLv().."级")
end

function SkillUpgradeConfirmPresent:setTextZhaoName1()
    if self.__skillAdvance:getActiveZhaoId1() then
        self.__ui:setTextZhaoName1(self.__skillAdvance:getActiveZhaoName1())
    else
        self.__ui:setTextZhaoName1("")
    end
end

function SkillUpgradeConfirmPresent:setTextZhaoExp1()
    if self.__skillAdvance:getActiveZhaoExp1() then
        self.__ui:setTextZhaoExp1(self.__skillAdvance:getActiveZhaoExp1().."熟练度")
    else
        self.__ui:setTextZhaoExp1("")
    end
end

function SkillUpgradeConfirmPresent:setTextZhaoName2()
    if self.__skillAdvance:getActiveZhaoId2() then
        self.__ui:setTextZhaoName2(self.__skillAdvance:getActiveZhaoName2())
    else
        self.__ui:setTextZhaoName2("")
    end
end

function SkillUpgradeConfirmPresent:setTextZhaoExp2()
    if self.__skillAdvance:getActiveZhaoExp2() then
        self.__ui:setTextZhaoExp2(self.__skillAdvance:getActiveZhaoExp2().."熟练度")
    else
        self.__ui:setTextZhaoExp2("")
    end
end

function SkillUpgradeConfirmPresent:setButton1Func()
    self.__ui:setButton1Func(function()
        local isAdvance,msg = self.__role:isCanSkillAdvance(self.__skillAdvance)

        if isAdvance then
            self.__role:startSkillAdvance(self.__skillAdvance)

            local sucText = "你已成功领悟"..self.__skillAdvance:getSkillName().."。"

            if type(self.__confirmFunc) == "function" then
                self.__confirmFunc()
            end

            PopText(sucText)

            RichPrint("main", sucText)

            self:hideLayer()

            self:recordSkillAdvance()
        else
            PopText(msg)

            RichPrint("main", msg)
            
            self:hideLayer()
        end
    end)
end

function SkillUpgradeConfirmPresent:setButton2Func()
    self.__ui:setButton2Func(function()
        self:hideLayer()
    end)
end

function SkillUpgradeConfirmPresent:hideLayer()
    PopupLayerController:hideLayer(
        "SkillUpgradeConfirmPresent",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function SkillUpgradeConfirmPresent:recordSkillAdvance()
    Record:addLogData(Record.RECORD_TYPE.SKILL_ADVANCE, {
        addSkill = self.__skillAdvance:getSkill(),
        addActiveZhao1 = self.__skillAdvance:getActiveZhao1(),
        addActiveZhao2 = self.__skillAdvance:getActiveZhao2(),
        Items = self.__skillAdvance:getItems(),
        befItemNum = self.__role:getItemCount(self.__skillAdvance:getItemId()) + self.__skillAdvance:getItemNum(),
        aftItemNum = self.__role:getItemCount(self.__skillAdvance:getItemId()),
        needSkill = self.__skillAdvance:getNeedSkill(),
        needActiveZhao1 = self.__skillAdvance:getNeedActiveZhao1(),
        needActiveZhao2 = self.__skillAdvance:getNeedActiveZhao2(),
    })
end

Helper:classDefNodeGetInstance(SkillUpgradeConfirmPresent)
return SkillUpgradeConfirmPresent
000000