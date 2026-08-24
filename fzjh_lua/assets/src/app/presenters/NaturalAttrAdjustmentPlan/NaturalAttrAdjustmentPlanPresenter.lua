--[[
    author:Seven
    time:2024-01-05 17:58:43
    desc:
]]
local NaturalAttrAdjustmentPlanPresenter = class("NaturalAttrAdjustmentPlanPresenter", LayerEx)

local INaturalAttrAdjustmentPlan = require("app.models.role.attr.NaturalAttributePlan.INaturalAttrAdjustmentPlan")

local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")

local AttrAdjustmentPanelUI = require("app.views.ui.AttrUI.NaturalAttrAdjustmentPlanUI.AttrAdjustmentPanelUI")

local isImplement = require("third.assertIsInstance.assertIsInstance")

function NaturalAttrAdjustmentPlanPresenter:create()
    return NaturalAttrAdjustmentPlanPresenter.new():__init()
end

function NaturalAttrAdjustmentPlanPresenter:__init()
    self:setShowAndHideAnimType(LayerEx.ShowAndHideAnimType.ROLL)

    --@RefType [src.app.views.ui.AttrUI.NaturalAttrAdjustmentPlanUI.NaturalAttrAdjustmentPlanUI#NaturalAttrAdjustmentPlanUI]
    self.__ui = require("app.views.ui.AttrUI.NaturalAttrAdjustmentPlanUI.NaturalAttrAdjustmentPlanUI"):create()

    self.__ui:getUINode():addTo(self)

    self.__ui:show()

    self:setVisible(false)

    self.__ui:registerPanelBackClickFunc(
        function()
            self:hideLayer()
        end
    )

    self.__panelUIList = {}

    return self
end

function NaturalAttrAdjustmentPlanPresenter:__initSelectBtnUI(naturalPlanList)
    self.__ui:removeAllBtnSelectNodeFromSelectList()
    local count = #naturalPlanList

    for i = 1, count do
        --@RefType [src.app.models.role.attr.NaturalAttributePlan.INaturalPlan#INaturalPlan]
        local naturalPlan = naturalPlanList[i]
        local uiNode = self.__ui:getSelectBtnUINode()
        self.__ui:addBtnSelectNodeToSelectList(uiNode)

        self.__ui:setSelectBtnNodeName(i, naturalPlan:getNaturalPlanName())

        if self.__uiPlanType == naturalPlan:getNaturalPlanType() then
            self.__ui:setSelectBtnNodeStatus(i, true)
            self:setAssignablePoints(naturalPlan:getAssignablePoints())
        else
            self.__ui:setSelectBtnNodeStatus(i, false)
        end

        uiNode:releaseFunc(
            function()
                if self.__uiPlanType == naturalPlan:getNaturalPlanType() then
                    return
                end

                if naturalPlan:isEnable() == false then
                    PopText("未曾习得易天诀，无法开启此先天属性")
                    return
                end

                self.__uiPlanType = naturalPlan:getNaturalPlanType()

                for j = 1, count do
                    if j == i then
                        self.__ui:setSelectBtnNodeStatus(j, true)
                    else
                        self.__ui:setSelectBtnNodeStatus(j, false)
                    end
                end

                self:setAssignablePoints(naturalPlan:getAssignablePoints())

                self:__initNaturalAttrPanelUIList(naturalPlan)
            end
        )
    end
end

--@desc:
--@author:Seven
--@time:2024-01-09 21:29:30
--@panelUI: [src.app.views.ui.AttrUI.NaturalAttrAdjustmentPlanUI.AttrAdjustmentPanelUI#AttrAdjustmentPanelUI]
--@point: number
function NaturalAttrAdjustmentPlanPresenter:__updatePanelUIDesBtnEnalbe(panelUI, point)
    if point <= 0 then
        panelUI:setBtnDecEnable(false)
    else
        panelUI:setBtnDecEnable(true)
    end
end

--@panelUI: [src.app.views.ui.AttrUI.NaturalAttrAdjustmentPlanUI.AttrAdjustmentPanelUI#AttrAdjustmentPanelUI]
function NaturalAttrAdjustmentPlanPresenter:__updatePanelUIAddBtnEnalbe(panelUI, assignablePoints)
    if assignablePoints <= 0 then
        panelUI:setBtnAddEnable(false)
    else
        panelUI:setBtnAddEnable(true)
    end
end

--@desc: 生成UI界面
--@author:Seven
--@time:2024-01-08 10:50:50
--@naturalPlan: [src.app.models.role.attr.NaturalAttributePlan.INaturalPlan#INaturalPlan]
function NaturalAttrAdjustmentPlanPresenter:__initNaturalAttrPanelUIList(naturalPlan)
    local attrList = naturalPlan:getNaturalPlanAttrList()

    local uiPanelCount = #self.__panelUIList
    local attrCount = #attrList
    if uiPanelCount == 0 then
        for i = 1, attrCount do
            --@RefType [src.app.views.ui.AttrUI.NaturalAttrAdjustmentPlanUI.AttrAdjustmentPanelUI#AttrAdjustmentPanelUI]
            local panelUI = AttrAdjustmentPanelUI:create(self.__ui:getPanelAttrUINode())
            self.__ui:addPanelAttrNodeToAttrList(panelUI:getUINode())
            table.insert(self.__panelUIList, panelUI)
        end
    end

    for i = 1, attrCount do
        local attr = attrList[i]

        local panelUI = self.__panelUIList[i]

        panelUI:setAttrName(Role:getCHAttrName(attr.attrName))

        local attrValue = naturalPlan:getNaturalPlanAttr(attr.attrName)

        local tempValue = naturalPlan:getNaturalAttrTempAssignablePoint(attr.attrName)

        panelUI:setAttrValue(attr.attrValue + tempValue)

        self:__updatePanelUIDesBtnEnalbe(panelUI, naturalPlan:getNaturalAttrTempAssignablePoint(attr.attrName))

        self:__updatePanelUIAddBtnEnalbe(panelUI, naturalPlan:getAssignablePoints())

        local pressTime = 0
        local preUpdateTime = 0
        panelUI:registerBtnAddClickFunc(
            function()
                pressTime = 0
                preUpdateTime = 0
            end,
            function()
                self:__selectAddPoint(panelUI, naturalPlan, attr.attrName)
                preUpdateTime = 0
                pressTime = 0
            end,
            function()
                preUpdateTime = 0
                pressTime = 0
            end,
            function(ft)
                preUpdateTime = preUpdateTime + ft

                if pressTime < 1 then
                    if preUpdateTime > 0.3 then
                        self:__selectAddPoint(panelUI, naturalPlan, attr.attrName)
                        preUpdateTime = 0
                    end
                elseif pressTime >= 1 and preUpdateTime <= 3 then
                    if preUpdateTime > 0.07 then
                        self:__selectAddPoint(panelUI, naturalPlan, attr.attrName)
                        preUpdateTime = 0
                    end
                else
                    if preUpdateTime > 0.01 then
                        self:__selectAddPoint(panelUI, naturalPlan, attr.attrName)
                        preUpdateTime = 0
                    end
                end

                pressTime = pressTime + ft
            end
        )

        panelUI:registerBtnDecClickFunc(
            function()
                pressTime = 0
                preUpdateTime = 0
            end,
            function()
                self:__selectDecPoint(panelUI, naturalPlan, attr.attrName)
                preUpdateTime = 0
                pressTime = 0
            end,
            function()
                preUpdateTime = 0
                pressTime = 0
            end,
            function(ft)
                preUpdateTime = preUpdateTime + ft

                if pressTime < 1 then
                    if preUpdateTime > 0.3 then
                        self:__selectDecPoint(panelUI, naturalPlan, attr.attrName)
                        preUpdateTime = 0
                    end
                elseif pressTime >= 1 and preUpdateTime <= 3 then
                    if preUpdateTime > 0.07 then
                        self:__selectDecPoint(panelUI, naturalPlan, attr.attrName)
                        preUpdateTime = 0
                    end
                else
                    if preUpdateTime > 0.01 then
                        self:__selectDecPoint(panelUI, naturalPlan, attr.attrName)
                        preUpdateTime = 0
                    end
                end

                pressTime = pressTime + ft
            end
        )
    end
end

function NaturalAttrAdjustmentPlanPresenter:__selectAddPoint(panelUI, naturalPlan, attrName)
    local nowAssignablePoints = naturalPlan:getAssignablePoints()

    if nowAssignablePoints <= 0 then
        return
    end

    local point = naturalPlan:getNaturalAttrTempAssignablePoint(attrName)

    point = point + 1

    naturalPlan:setNaturalAttrTempAssignablePoint(attrName, point)

    panelUI:setAttrValue(naturalPlan:getNaturalPlanAttr(attrName) + point)

    local newAssignablePoints = naturalPlan:getAssignablePoints()

    self:setAssignablePoints(newAssignablePoints)

    for i, v in ipairs(self.__panelUIList) do
        self:__updatePanelUIAddBtnEnalbe(v, newAssignablePoints)
    end

    self:__updatePanelUIDesBtnEnalbe(panelUI, point)

    return point
end

function NaturalAttrAdjustmentPlanPresenter:__selectDecPoint(panelUI, naturalPlan, attrName)
    local point = naturalPlan:getNaturalAttrTempAssignablePoint(attrName)

    if point <= 0 then
        return
    end

    point = point - 1

    naturalPlan:setNaturalAttrTempAssignablePoint(attrName, point)

    panelUI:setAttrValue(naturalPlan:getNaturalPlanAttr(attrName) + point)

    local nowAssignablePoints = naturalPlan:getAssignablePoints()

    self:setAssignablePoints(nowAssignablePoints)

    for i, v in ipairs(self.__panelUIList) do
        self:__updatePanelUIAddBtnEnalbe(v, nowAssignablePoints)
    end

    self:__updatePanelUIDesBtnEnalbe(panelUI, point)

    return
end

--@desc:
--@author:Seven
--@time:2024-01-05 18:05:45
--@adjutmentplan: [src.app.models.role.attr.NaturalAttributePlan.INaturalAttrAdjustmentPlan#INaturalAttrAdjustmentPlan]
--@planType:[src.app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst#NaturalAttrAdjustmentConst.PLAN_TYPE]
function NaturalAttrAdjustmentPlanPresenter:showLayer(adjutmentplan, planType, role)
    if table.keyof(NaturalAttrAdjustmentConst.PLAN_TYPE, planType) == nil then
        error("NaturalAttrAdjustmentPlanPresenter:showLayer unknow planType : " .. tostring(planType))
    end

    self.__role = role

    --@RefType [src.app.models.role.attr.NaturalAttributePlan.INaturalAttrAdjustmentPlan#INaturalAttrAdjustmentPlan]
    self.__adjutmentplan = isImplement(adjutmentplan, INaturalAttrAdjustmentPlan)

    --@desc 当前UI所使用的方案类型
    self.__uiPlanType = planType

    self:__initSelectBtnUI(self.__adjutmentplan:getAdjustmentPlanArray())

    self:__initNaturalAttrPanelUIList(self.__adjutmentplan:getPlanByType(self.__uiPlanType))

    self.__ui:registerLeftBtnFunc(
        "确认",
        function()
            if self.__uiPlanType == self.__adjutmentplan:getUsagePlanType() then
                self.__adjutmentplan:useAttrAdjustmentPlanType(self.__uiPlanType)
                PopText("先天属性加点保存成功")
                self:hideLayer()
            else
                PopupLayerController:showLayer(
                    "SelectCostItemToSwitchAttrPlanPresenter",
                    function(layer)
                        layer:registerBtnOneClickFunc(
                            "确定",
                            function(selectIndex)
                                local result, msg = self.__adjutmentplan:switchAttrAdjustmentPlan(selectIndex, self.__uiPlanType)

                                if result == false then
                                    PopText(msg)
                                    return
                                end

                                local costItem = self.__adjutmentplan:getSwitchPlanCostItemList()[selectIndex]

                                local costItemId = costItem.id

                                local costNumber = costItem.count

                                local item = self.__role:getOneItemByKey(costItemId)

                                local costTip = string.format("消耗%s%s%s，成功使用此先天属性", tostring(costNumber), tostring(item.unit), tostring(item.name))

                                layer:hideLayer()

                                self:hideLayer()

                                PopText(costTip)
                            end
                        )

                        layer:registerBtnTwoClickFunc(
                            "取消",
                            function(selectIndex)
                                layer:hideLayer()
                            end
                        )

                        layer:showLayer(self.__adjutmentplan, self.__role)
                    end
                )
            end
        end
    )

    self.__ui:registerRightBtnFunc(
        "取消",
        function()
            self:hideLayer()
        end
    )

    self:__show()
end

function NaturalAttrAdjustmentPlanPresenter:__show()
    self:show(
        function()
            self.__scheduleTag =
                self:schedule(
                function(ft)
                    for i, v in ipairs(self.__panelUIList) do
                        v:updateUI(ft)
                    end
                end,
                0
            )
        end
    )
end

function NaturalAttrAdjustmentPlanPresenter:hideLayer()
    self:unscheduleAll()
    self.__scheduleTag = nil
    self.__adjutmentplan = nil
    self.__uiPlanType = nil
    self:__hide()
end

function NaturalAttrAdjustmentPlanPresenter:__hide()
    self:hide()
end

function NaturalAttrAdjustmentPlanPresenter:setAssignablePoints(value)
    self.__ui:setTextAssignablePoints("可分配先天属性点：" .. tostring(value))
end

Helper:classDefNodeGetInstance(NaturalAttrAdjustmentPlanPresenter)
return NaturalAttrAdjustmentPlanPresenter
00000000000