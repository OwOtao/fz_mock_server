--[[
    author:Seven
    time:2023-10-26 14:27:46
    desc:
]]
local newClass = require("third.class.NewClass")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local ViewActiveSkill = {}

function ViewActiveSkill:create(...)
    return ViewActiveSkill.new():__init(...)
end

function ViewActiveSkill:__init(id, name, posIndex)
    self.__id = id

    self.__name = name

    self.__posIndex = tostring(posIndex)

    self.__cd = 0

    self.__isEnable = true

    return self
end

function ViewActiveSkill:getViewActiveId()
    return self.__id
end

function ViewActiveSkill:getViewActiveName()
    return self.__name
end

function ViewActiveSkill:getViewActivePosIndex()
    return tostring(self.__posIndex)
end

function ViewActiveSkill:setViewActiveCD(cd)
    self.__cd = cd
end

function ViewActiveSkill:getViewActiveCD()
    return self.__cd
end

function ViewActiveSkill:setLevel(lv)
    self.__lv = lv
end

function ViewActiveSkill:getLevel()
    return Helper:getDef(self.__lv, 0)
end

function ViewActiveSkill:setCooldownTime(cooldownTime)
    self.__cooldownTime = cooldownTime
end

function ViewActiveSkill:getViewActiveCooldownTime()
    return self.__cooldownTime
end

function ViewActiveSkill:setDesc(desc)
    self.__desc = desc
end

function ViewActiveSkill:getDesc()
    return Helper:getDef(self.__desc, "")
end

function ViewActiveSkill:setEnable(isEnable)
    self.__isEnable = isEnable
end

function ViewActiveSkill:getEnable()
    return self.__isEnable
end

function ViewActiveSkill:setConditionText(text)
    self.__conditionText = text
end

function ViewActiveSkill:getConditionText()
    return self.__conditionText
end

function ViewActiveSkill:setCostNeili(neili)
    self.__costNeili = neili
end

function ViewActiveSkill:getCostNeili()
    return self.__costNeili
end

--@desc: 更新视图层主动技能CD时间间隔
--@author:Seven
--@time:2023-10-26 14:43:36
--@mainView: [FightMainView]
--@oldCd: 旧的CD时间
--@newCd: 新的CD时间
--@ft: 时间间隔
function ViewActiveSkill:updateViewCd(mainView, oldCd, newCd, ft)
    self:killUpdateCDTween()

    if ft == nil or ft <= 0 then
        self:setViewActiveCD(newCd)
        mainView:getPlayerButtonViewUI(self.__posIndex):setBtnProgressValue(self:getViewActiveCooldownTime() - newCd, self:getViewActiveCooldownTime())
        return
    end

    self:setViewActiveCD(oldCd)

    self.__updateCDTween =
        mainView:doUINumberTween(
        function()
            return self:getViewActiveCD()
        end,
        function(value)
            self:setViewActiveCD(value)
            mainView:getPlayerButtonViewUI(self.__posIndex):setBtnProgressValue(self:getViewActiveCooldownTime() - value, self:getViewActiveCooldownTime())
        end,
        newCd,
        ft
    )
end

--@author:Seven
--@time:2023-10-26 14:43:36
--@mainView: [FightMainView]
--@isBool: 是否启用
function ViewActiveSkill:updateEnable(mainView, isBool)
    self:setEnable(isBool)
    mainView:getPlayerButtonViewUI(self.__posIndex):setClickEnable(isBool)
end

function ViewActiveSkill:killUpdateCDTween()
    if self.__updateCDTween then
        self.__updateCDTween:kill()
        self.__updateCDTween = nil
    end
end

--@desc:绑定按钮视图UI事件监听器
--@author:Seven
--@time:2023-11-07 16:10:16
--@mainView: [FightMainView]
--@ui: [src.app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.UI.PlayerButtonViewUI#PlayerButtonViewUI]
function ViewActiveSkill:bindClickBtnUI(mainView, ui)
    ui:setBtnStatus(2)
    ui:setBtnName(self:getViewActiveName())
    ui:setBtnProgressValue(self:getViewActiveCooldownTime() - self:getViewActiveCD(), self:getViewActiveCooldownTime())
    ui:setClickEnable(self:getEnable())
    ui:setVisible(true)

    local pressTime = 0
    local isShowDialog = false
    ui:registerClickFunc(
        function()
            pressTime = 0
        end,
        function()
            pressTime = 0

            if isShowDialog then
                mainView:hideActiveSkillPanel()
                isShowDialog = false
            else
                if self.__cd > 0 then
                    mainView:popTextTips(TextResManager:getText("1010"))
                    return
                end

                local FightCommons = require("app.FightSystem.FightCommons")
                mainView:sendPlayerInput(
                    FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL,
                    {
                        self.__id
                    }
                )
            end
        end,
        function()
            if isShowDialog then
                mainView:hideActiveSkillPanel()
                isShowDialog = false
            end

            pressTime = 0
        end,
        function(dt)
            if pressTime >= 0.5 and isShowDialog == false then
                mainView:showActiveSkillPanel(self)
                isShowDialog = true
            end

            pressTime = pressTime + dt
        end
    )
end

function ViewActiveSkill:destory()
    self:killUpdateCDTween()
end
return newClass("ViewActiveSkill", {}, ViewActiveSkill)
000000000