local TaiQingTaiLayer = class("TaiQingTaiLayer", LayerEx)

--@RefType [app.models.HomelandModel.FurnitureModel.TaiQingTaiModel#TaiQingTaiModel]
local TaiQingTaiModel = require("app.models.HomelandModel.FurnitureModel.TaiQingTaiModel")

function TaiQingTaiLayer:create()
    local p = TaiQingTaiLayer:new()
    p:init()
    return p
end

function TaiQingTaiLayer:init()
    self._UI = require("Layer/HomelandUI/TaiQingTaiUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Image_Back:releaseFunc(
        function()
            TaiQingTaiModel:clear()
            self:hideLayer()
        end
    )
end

function TaiQingTaiLayer:pushLeft(data)
    TaiQingTaiModel:pushLeftItem(data)

    self:refreshLeftList()
end

function TaiQingTaiLayer:popLeft(index)
    local data = TaiQingTaiModel:getLeftItem(index)

    if data.zc >= 4000 then
        PopText("此人对你的忠诚已无以复加，不需再宴请了！")
        return
    end

    if #self.ListView_Right:getItems() >= 9 then
        PopText("同时最多宴请9人！")
        return
    end

    self:pushRight(data)
    TaiQingTaiModel:popLeftItem(index)
    self.ListView_Left:removeItem(index - 1)
end

function TaiQingTaiLayer:pushRight(data)
    TaiQingTaiModel:pushRightItem(data)

    self:refreshRightList()

    self:refreshCost()
end

function TaiQingTaiLayer:popRight(index)
    local data = TaiQingTaiModel:getRightItem(index)

    self:pushLeft(data)
    TaiQingTaiModel:popRightItem(index)
    self.ListView_Right:removeItem(index - 1)
    self:refreshCost()
end

function TaiQingTaiLayer:hideLayer()
    PopupLayerController:hideLayer(
        "TaiQingTaiLayer",
        function(layer)
            layer:hide()
        end
    )
end

function TaiQingTaiLayer:showLayer(map)
    HttpManagerEx:viewCurrencyByType(
        "yinpiao",User:getRole():getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    TaiQingTaiModel:setYinPiao(data.number)
                    TaiQingTaiModel:initLeftList(map)
                    TaiQingTaiModel:initRightList()

                    self:refreshLeftList()
                    self:refreshRightList()

                    self:setBtnOk(
                        function()
                            TaiQingTaiModel:fete(function ()
                                self:hideLayer()
                            end)
                        end
                    )

                    self:refreshCost()

                    self:show()
                    return true
                else
                    print("viewCurrencyByType", errmsg, errcode)
                    return false
                end
            else
                print("viewCurrencyByType", errmsg, errcode)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function TaiQingTaiLayer:createRow1()
    local row = self.Panel_1:clone()
    Helper:convertUIByParent(row)
    row.Text_Desc:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Text_Name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Text_Value:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    return row
end

function TaiQingTaiLayer:createRow2()
    local row = self.Panel_2:clone()
    Helper:convertUIByParent(row)
    row.Text_Desc:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Text_Name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    row.Text_Value:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
    return row
end


function TaiQingTaiLayer:refreshRightList()
    local list = TaiQingTaiModel:getRightList()

    local currNum = #list

    for index, role in ipairs(list) do
        local row = self.ListView_Right:getItem(index - 1)
        if row == nil then
            row = self:createRow2()
            self.ListView_Right:pushBackCustomItem(row)
        end

        row.Text_Name:setString(role.name)

        --@RefType [app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
        local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

        local jobName = HomelandRoleUtil:getCHAJobTypeName(role.jobType) or ""

        row.Text_Desc:setString(jobName)

        local currLv = HomelandRoleUtil:getFidelityLv(role.zc)
        local nextValue = HomelandRoleUtil:getFidelityByLv(currLv + 1)

        row.Text_Value:setString(role.zc .. "/" .. nextValue)

        row:releaseFunc(
            function()
                local index = self.ListView_Right:getIndex(row)
                self:popRight(index + 1)
            end
        )
    end

    local listNum = #self.ListView_Right:getItems()

    if listNum > currNum then
        local removePosition = listNum - currNum
        for i = listNum - 1, currNum, -1 do
            self.ListView_Right:removeItem(i)
        end
    end
end

function TaiQingTaiLayer:refreshLeftList()
    local list = TaiQingTaiModel:getLeftList()

    local currNum = #list

    for index, role in ipairs(list) do
        local row = self.ListView_Left:getItem(index - 1)
        if row == nil then
            row = self:createRow1()
            self.ListView_Left:pushBackCustomItem(row)
        end

        row.Text_Name:setString(role.name)

        --@RefType [app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
        local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

        local jobName = HomelandRoleUtil:getCHAJobTypeName(role.jobType) or ""

        row.Text_Desc:setString(jobName)

        local currLv = HomelandRoleUtil:getFidelityLv(role.zc)
        local nextValue = HomelandRoleUtil:getFidelityByLv(currLv + 1)

        row.Text_Value:setString(role.zc .. "/" .. nextValue)

        row:releaseFunc(
            function()
                local index = self.ListView_Left:getIndex(row)
                self:popLeft(index + 1)
            end
        )
    end

    local listNum = #self.ListView_Left:getItems()

    if listNum > currNum then
        local removePosition = listNum - currNum
        for i = listNum - 1, currNum, -1 do
            self.ListView_Left:removeItem(i)
        end
    end
end

function TaiQingTaiLayer:refreshCost()
    self.Text_Cost:setString(TaiQingTaiModel:getCost())
end

function TaiQingTaiLayer:setBtnOk(func)
    self.Button_OK:releaseFunc(
        function()
            func()
        end
    )
end

Helper:classDefNodeGetInstance(TaiQingTaiLayer)
return TaiQingTaiLayer
0000000