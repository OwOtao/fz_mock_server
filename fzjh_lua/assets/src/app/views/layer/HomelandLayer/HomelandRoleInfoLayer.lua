local HomelandRoleInfoLayer = class("HomelandRoleInfoLayer", LayerEx)

--@desc 列表控件中，描述+标题最大宽度
local TEXT_MAX_WIDTH = 880

--@desc 设置panel高度
local DISTANCE_FACTOR = 10

function HomelandRoleInfoLayer:create()
    local p = HomelandRoleInfoLayer:new()
    p:init()
    return p
end

function HomelandRoleInfoLayer:init()
    self._UI = require("Layer/HomelandUI/HomelandRoleInFoUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self.Button_fire:setVisible(false)
    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

function HomelandRoleInfoLayer:hideLayer()
    PopupLayerController:hideLayer(
        "HomelandRoleInfoLayer",
        function(layer)
            layer:hide()
        end
    )
end

function HomelandRoleInfoLayer:showLayer(role,map,isShowBtn)
    self.ListView_Info:removeAllItems()

    self.Text_name:setString(role.name)

    self.Text_job:setVisible(false)

    if isShowBtn then 
        local prName = role.realName or role.name
        self.Text_name:setString(prName)
        self.Text_job:setString("（"..role.cType.."）")
        self.Text_job:setPositionX(self.Text_name:getPositionX()+self.Text_name:getContentSize().width/2 + self.Text_job:getContentSize().width/2 + 5)
        self.Text_job:setVisible(true)
    end

    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local info = HomelandRoleUtil:createShowRoleInfo(role)

    for i,v in ipairs(info) do
        local row
        if v.panel_type == 1 then
            row = self:createPanelBase(v.title,v.desc)
        elseif v.panel_type == 2 then
            row = self:createPanelValue(v.title,v.desc,v.value)
        elseif v.panel_type == 3 then
            row = self:createMultiRowDescPanel(v.title,v.desc_list)
        end

        self:setRowTipDesc(row,v.tips)

        self.ListView_Info:pushBackCustomItem(row)
    end

    self:initFireBtnFun(map,role,isShowBtn)

    self:show()
end

function HomelandRoleInfoLayer:createPanelBase(title, desc)
    local row = self.Panel_Base:clone()
    Helper:convertUIByParent(row)

    row.Text_Title:setString(title)

    local title_ui_width = row.Text_Title:getAutoRenderSize().width

    local title_ui_pos_x = row.Text_Title:getPositionX()

    local desc_ui_width = TEXT_MAX_WIDTH - title_ui_width

    row.Text_Desc:setTextAreaSize(cc.size(desc_ui_width, 0))
    row.Text_Desc:setString(desc)

    local text_desc_height = row.Text_Desc:getAutoRenderSize().height

    local row_height = text_desc_height + DISTANCE_FACTOR * 2
    row:setSize({width = 1000, height = row_height})

    --@desc 调整控件位置
    row.Panel_Tip:setPosition(cc.p(22.00, row_height - DISTANCE_FACTOR))
    row.Text_Title:setPosition(cc.p(title_ui_pos_x, row_height - DISTANCE_FACTOR))
    row.Text_Desc:setPosition(cc.p(title_ui_pos_x + title_ui_width + 5, row_height - DISTANCE_FACTOR))

    return row
end

function HomelandRoleInfoLayer:createPanelValue(title, desc, value)
    local row = self.Panel_Value:clone()
    Helper:convertUIByParent(row)

    row.Text_Title:setString(title)
    row.Text_Desc:setString(desc)
    row.Text_Value:setString(value)

    local title_ui_width = row.Text_Title:getAutoRenderSize().width

    local title_ui_pos_x = row.Text_Title:getPositionX()

    local text_desc_height = row.Text_Desc:getAutoRenderSize().height

    local row_height = text_desc_height + DISTANCE_FACTOR * 2
    row:setSize({width = 1000, height = row_height})

    --@desc 调整控件位置
    row.Panel_Tip:setPosition(cc.p(22.00, row_height - DISTANCE_FACTOR))
    row.Text_Title:setPosition(cc.p(title_ui_pos_x, row_height - DISTANCE_FACTOR))

    local desc_ui_pos_x = title_ui_pos_x + title_ui_width + 5
    local desc_ui_width = row.Text_Desc:getAutoRenderSize().width
    row.Text_Desc:setPosition(cc.p(desc_ui_pos_x, row_height - DISTANCE_FACTOR))
    row.Text_Value:setPosition(cc.p(desc_ui_pos_x + desc_ui_width + 5, row_height - DISTANCE_FACTOR))

    return row
end

function HomelandRoleInfoLayer:createMultiRowDescPanel(title, desc_list)
    local row = self.Panel_Base:clone()
    Helper:convertUIByParent(row)

    row.Text_Title:setString(title)

    row.Text_Desc:setVisible(false)

    local title_ui_width = row.Text_Title:getAutoRenderSize().width

    local desc_ui_width = TEXT_MAX_WIDTH - title_ui_width

    local total_height = 0

    local ui_list = {}

    for index, desc in ipairs(desc_list) do
        local ui = row.Text_Desc:clone()

        ui:setVisible(true)

        ui:setTextAreaSize(cc.size(desc_ui_width, 0))

        ui:setString(desc)

        total_height = total_height + ui:getAutoRenderSize().height

        table.insert(ui_list, ui)
    end

    local title_ui_pos_x = row.Text_Title:getPositionX()

    --@desc 整个控件高度
    local row_height = total_height + DISTANCE_FACTOR * 2
    row:setSize({width = 1000, height = row_height})

    local top_pos_y = row_height - DISTANCE_FACTOR

    --@desc 调整控件位置
    row.Panel_Tip:setPosition(cc.p(22.00, top_pos_y))
    row.Text_Title:setPosition(cc.p(title_ui_pos_x, top_pos_y))

    local pre_ui_total_height = 0
    for index, desc_ui in ipairs(ui_list) do
        row:addChild(desc_ui)

        --@desc 当前控件高度
        local curr_ui_height = desc_ui:getAutoRenderSize().height

        --@desc 计算当前控件Y轴的高度
        local pos_y = top_pos_y - pre_ui_total_height

        --@desc 前面描述控件的总高度
        pre_ui_total_height = curr_ui_height + pre_ui_total_height

        desc_ui:setPosition(cc.p(title_ui_pos_x + title_ui_width, pos_y))
    end

    return row
end

function HomelandRoleInfoLayer:setRowTipDesc(row, desc)
    local panel_tip = row.Panel_Tip

    panel_tip:releaseFunc(
        function()
            local isShow = panel_tip.Image_7:isVisible()

            if isShow then
                panel_tip.Image_7:setVisible(false)
                local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")

                local dialog = DialogELayer:getInstance()

                dialog:show(desc)

                dialog:setPanelBack(
                    function()
                        panel_tip.Image_7:setVisible(true)
                    end
                )
            end
        end
    )
end

function HomelandRoleInfoLayer:setMiaoShuCallback(callback)
    self.Button_DecorativeBox:releaseFunc(
        function()
            if type(callback) ~= "function" then
                return
            end

            callback()

            self:hideLayer()
        end
    )
end

--遣散功能
function HomelandRoleInfoLayer:initFireBtnFun(map,role,isVisible)
    if not isVisible then 
        isVisible =false
    end

    self.Button_DecorativeBox:setVisible(not isVisible)
    self.Button_fire:setVisible(isVisible)
    self.Button_fire:releaseFunc(function()
        local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
        HomelandRoleUtil:firedRole(map,role,function()
            self:hideLayer()
            PopupLayerController:hideLayer("PuRenManagementLayer", function(layer)
                layer:hide()
            end)
        end)
        
    end)
end

Helper:classDefNodeGetInstance(HomelandRoleInfoLayer)
return HomelandRoleInfoLayer
000000000