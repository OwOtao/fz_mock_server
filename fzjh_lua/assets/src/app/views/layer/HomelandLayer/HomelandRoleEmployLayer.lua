--@desc 仆人雇佣界面
local HomelandRoleEmployLayer = class("HomelandRoleEmployLayer", LayerEx)

--@RefType [app.models.HomelandModel.HomelandRoleModel.EmployDataModel#EmployDataModel]
local EmployDataModel = require("app.models.HomelandModel.HomelandRoleModel.EmployDataModel")
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

function HomelandRoleEmployLayer:create()
    local p = HomelandRoleEmployLayer:new()
    p:init()
    return p
end

function HomelandRoleEmployLayer:init()
    local UI = require("Layer/HomelandUI/GuanJiaEmployUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)
end

function HomelandRoleEmployLayer:showLayer()
    self:setDsc()
    self:setTextTitle()
    self:setReplaceButton()
    self:initHomelandRoleEmployList()
    self:setSchedule()
    self:setBackButton()
    self:show()
end


function HomelandRoleEmployLayer:setDsc()
    local dsc = EmployDataModel:getDsc()
    self.Text_1:setString(dsc)
end

function HomelandRoleEmployLayer:setTextTitle(text)
    self.Text_title:setString(Helper:getDef(text,"雇佣"))
end
--初始化仆人招募列表
function HomelandRoleEmployLayer:initHomelandRoleEmployList()
    local list = EmployDataModel:getEmployData()
    for i = 1, 5 do
        local employee = list[i]

        if employee == nil then
            self.Panel_3["Button_" .. i]:setVisible(false)
        else
            self.Panel_3["Button_" .. i]:setVisible(true)
            self.Panel_3["Button_" .. i].Text_buttonName:setString(list[i].name)
            self.Panel_3["Button_" .. i]:releaseFunc(
                function()
                    PopupLayerController:showLayer(
                        "EmployDscLayer",
                        function(layer)
                            layer:setButtonFunc(function ()
                                --@RefType [app.models.role.Role#Role]
                                local role = User:getRole()
                                local mid = role:getHouseId()
                                if mid == nil then
                                    PopText("少侠，您还没自己的房子呢！")
                                    return
                                end
                                
                                EmployDataModel:employeeNpc(i,function ()
                                    layer:hideLayer()
                                    self:hideLayer()
                                end)
                            end)

                            layer:showLayer(list[i])
                        end
                    )
                end
            )
        end
    end
end

function HomelandRoleEmployLayer:setBackButtonVisible(boole)
    self.Button_back:setVisible(Helper:getDef(boole,true))
end

function HomelandRoleEmployLayer:setReplaceButtonVisible(boole)
    self.Button_replace:setVisible(Helper:getDef(boole,true))
end

function HomelandRoleEmployLayer:setTextMoneyVisible(boole)
    self.Text_money:setVisible(Helper:getDef(boole,true))
end

function HomelandRoleEmployLayer:setTextBackVisible(boole)
    self.Text_back:setVisible(Helper:getDef(boole,true))
end

--设置返回按钮
function HomelandRoleEmployLayer:setBackButton()
    self.Button_back:setVisible(true)
    self.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

--设置换一批按钮
function HomelandRoleEmployLayer:setReplaceButton(func)
    self.Button_back:setVisible(true)
    self.Button_replace:releaseFunc(
        function()
            if func then
                func()
            end

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()

            dialog:show("你确定要花费50元宝换一批来应聘的吗？")

            dialog:setButton1(
                "确定",
                function()
                    EmployDataModel:refreshList(2,function ()
                        self:setDsc()
                        PopText("元宝扣减50！")
                        local list = Helper:getDef(EmployDataModel:getEmployData(),{})
                        if #list == 0 then
                            PopText("暂时没有人来应聘！")
                        else
                            PopText("刷新成功！")
                        end
                    end)
                end
            )
            dialog:setButton2(
                "取消",
                function()
                    dialog:hide()
                end
            )
        end
    )
end

function HomelandRoleEmployLayer:setSchedule()
    self._handle = self:schedule(function ()
        if EmployDataModel:getNeedRefresh() then
            self:initHomelandRoleEmployList()
            EmployDataModel:setNeedRefresh(false)
        end
    end)
end

function HomelandRoleEmployLayer:hideLayer()
    if self._handle then
        self:unschedule(self._handle)
        self._handle = nil
    end
    PopupLayerController:hideLayer(
        "HomelandRoleEmployLayer",
        function(layer)
            layer:hide()
        end
    )
end

--设置点击空白处返回
function HomelandRoleEmployLayer:setPanelBack(canHide)
    self.Panel_back:releaseFunc(
        function()
            if canHide == false then
                return
            end
            self:hideLayer()
        end
    )
end

Helper:classDefNodeGetInstance(HomelandRoleEmployLayer)
return HomelandRoleEmployLayer
0000000