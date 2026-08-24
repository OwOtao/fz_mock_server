local DecorativeSelectLayer = class("DecorativeSelectLayer", require("app.views.base.BaseLayer"))
--@RefType [app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")
--@RefType [app.models.Decorative.DecorativeSelect#DecorativeSelect]
local DecorativeSelect = require("app.models.Decorative.DecorativeSelect")

function DecorativeSelectLayer:create()
    local p = DecorativeSelectLayer:new()
    p:init()
    return p
end

local __list = {}

local selected =
    binding.bindable(
    {
        itemId = "",
        name = ""
    }
)

local _changeItemId = ""

function DecorativeSelectLayer:init()
    self._UI = require("Layer/DecorativeUI/DecorativeSelectedUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)
end

function DecorativeSelectLayer:initButton()
    self.Panel_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )

    self.Button_Right:releaseFunc(
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()
            --@RefType [app.models.item.BaseItem#BaseItem]
            local item = Item:getOneItemByKey(selected.itemId)
            local changeItem = Item:getOneItemByKey(_changeItemId)

            local Dialog = require("app.views.layer.DialogLayer.DialogALayer")
            --@RefType [app.views.layer.DialogLayer.DialogALayer#DialogALayer]
            local dialog = Dialog:getInstance()
            dialog:show("你确定要兑换" .. item:getNcname(item.name) .. "吗？")
            dialog:setBack(false)
            dialog:setButton1(
                "确定",
                function()
                    if role:checkCanBuyTwoOrMoreThings({[selected.itemId] = 1}) then
                        role:addItemCount(_changeItemId,-1)
                        role:addItemCount(selected.itemId, 1)
                        PopText("你获得了"..item.name.." X1")
                        RichPrint("main","你消耗了"..changeItem.name.." X1")

                        --@desc 成功兑换执行的方法
                        if self._successText and type(self._successText) == "string" then
                            local text = string.gsub( self._successText,"#name#",item.name)
                            RichPrint("main",text)
                        end

                    end
                    self:hideLayer()
                end
            )

            dialog:setButton2(
                "取消",
                function()
                end
            )
            dialog:setWeChatVisible(false)
        end
    )

    self.Button_Left:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

--@desc: 设置兑换成功后执行的方法
--@author:Liang SongQiang
--@time:2018-02-08 14:22:33
--@func: type must function
function DecorativeSelectLayer:setSuccessText(text)
    if type(text) == "string" then
        self._successText = text
    end
end

function DecorativeSelectLayer:showLayer(selectList, changeItemId)
    _changeItemId = changeItemId

    self:initButton()

    __list = DecorativeSelect:setSelectList(selectList)

    selected._tag =
        binding.watch(
        selected,
        "name",
        function()
            if selected.name == "" then
                self.Text_CurrSelect:setVisible(false)
                self.Button_Right:setTouchEnabled(false)
                self.Button_Right:setBright(false)
            else
                self.Text_CurrSelect:setVisible(true)
                self.Text_CurrSelect:setString("当前选择：" .. selected.name)
                self.Button_Right:setTouchEnabled(true)
                self.Button_Right:setBright(true)
            end
        end
    )

    self:createRowsListView(#__list)
    self:createSelctedListView(__list)
    self:show(true)
end

function DecorativeSelectLayer:hideLayer()
    PopupLayerController:hideLayer(
        "DecorativeSelectLayer",
        function(layer)
            for _, group in ipairs(__list) do
                for _, _data in ipairs(group) do
                    if _data.state == 1 then
                        _data.state = 0
                    end
                    binding.unwatch(_data, "state", _data._tag)
                end
            end
            selected.itemId = ""
            selected.name = ""
            binding.unwatch(selected, "name", selected._tag)
            _changeItemId = ""
            layer:hide(true)
        end
    )
end

--@desc: 创建行listView
--@author:Liang SongQiang
--@time:2018-02-07 17:25:25
--@count: 数量
function DecorativeSelectLayer:createRowsListView(count)
    for i = 1, count do
        local row = self.ListView_Masks:getItem(i - 1)
        if row == nil then
            row = self.ListView_SelectMasks:clone()
            Helper:convertUIByParent(row)
            self.ListView_Masks:pushBackCustomItem(row)
        end
    end

    local rowsCount = #self.ListView_Masks:getItems()
    if rowsCount > count then
        for i = rowsCount - 1, count, -1 do
            self.ListView_Masks:removeItem(i)
        end
    end

    self.ListView_Masks:jumpToTop()
end

function DecorativeSelectLayer:createSelctedListView(list)
    for rowIndex, panelList in ipairs(list) do
        local selectListView = self.ListView_Masks:getItem(rowIndex - 1)
        for panelIndex, panel_data in ipairs(panelList) do
            self:createPanel(selectListView, panelIndex, panel_data)
        end

        local panelCount = #selectListView:getItems()
        local dataCount = #panelList

        if panelCount - dataCount > 0 then
            for i = panelCount - 1, dataCount, -1 do
                selectListView:removeItem(i)
            end
        end
    end
end

--@desc: 创建可选择的panel
--@author:Liang SongQiang创建可选择的panel
--@time:2018-02-07 18:04:45
--@listView: panel所在的listView
--@index: panel的索引
--@data: 需绑定的数据结构
function DecorativeSelectLayer:createPanel(listView, index, data)
    local panel = listView:getItem(index - 1)
    if panel == nil then
        panel = self.Panel_Mask:clone()
        Helper:convertUIByParent(panel)
        listView:pushBackCustomItem(panel)
    end

    local mask = Item:getOneItemByKey(data.maskId)
    local maskName = User:getRole():getMaskSystem():getMaskGrade(mask.gradeId,1):getMaskName()
    local present = require("app.presenters.HeadView.HVPPresent"):create(panel.Image_head_1,panel.Image_di_1,{
        portrait = mask.gradeId,
    })
    present:showAnim()

    panel.Text_name_1:setString(maskName)

    data._tag =
        binding.watch(
        data,
        "state",
        function()
            if data.state == 1 then
                panel.Image_kuang_1:setVisible(true)
                panel.Image_gou_1:setVisible(true)
                panel.Text_name_1:setTextColor({r = 80, g = 244, b = 244})
                selected.itemId = mask.id
                selected.name = maskName
            elseif data.state == 0 then
                panel.Image_kuang_1:setVisible(false)
                panel.Image_gou_1:setVisible(false)
                panel.Text_name_1:setTextColor({r = 159, g = 159, b = 159})
                selected.itemId = ""
                selected.name = ""
            end
        end
    )

    panel:releaseFunc(
        function()
            for _, group in ipairs(__list) do
                for _, _data in ipairs(group) do
                    if _data.maskId ~= data.maskId then
                        _data.state = 0
                    end
                end
            end
            if data.state == 1 then
                data.state = 0
            else
                data.state = 1
            end
        end
    )
end

Helper:classDefNodeGetInstance(DecorativeSelectLayer)
return DecorativeSelectLayer
0000000000