local DecorativeSelectLayerEx = class("DecorativeSelectLayerEx", require("app.views.base.BaseLayer"))
--@RefType [app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")
--@RefType [app.models.Decorative.DecorativeSelect#DecorativeSelect]
local DecorativeSelect = require("app.models.Decorative.DecorativeSelect")

function DecorativeSelectLayerEx:create()
    local p = DecorativeSelectLayerEx:new()
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

local _spclNum = 0

local RandomShiPing = {}

local NOR_COST = nil --消耗饰品材料数量

function DecorativeSelectLayerEx:init()
    self._UI = require("Layer/DecorativeUI/DecorativeSelectedUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self.Button_Right:setTouchEnabled(true)
    self.Button_Right:setBright(true)
    self.Text_2:setVisible(true)
    self.Text_3:setVisible(true)
end

--@desc: 设置兑换成功后执行的方法
--@author:Liang SongQiang
--@time:2018-02-08 14:22:33
--@func: type must function
function DecorativeSelectLayerEx:setSuccessText(text)
    if type(text) == "string" then
        self._successText = text
    end
end

function DecorativeSelectLayerEx:showLayer(selectList, npc)
    NOR_COST = 100

    HttpManagerEx:viewCurrencyByType(
        "spcl",User:getRole():getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    _spclNum = Helper:getDef(tonumber(data.number), 0)
                    __list = DecorativeSelect:setSelectList(selectList)

                    local role = User:getRole()

                    local costNumFactor = npc:getBuffAttr("zhicuoCostReduce")
                    costNumFactor = Helper:getRange(costNumFactor,0,1)
                    
                    NOR_COST = math.ceil(NOR_COST * (1-costNumFactor))

                    self:createRowsListView(#__list)
                    self:createSelctedListView(__list)
                    self:setText()
                    self:show(true)
                else
                    print("viewCurrencyByType", errmsg, errcode)
                end
            else
                print("viewCurrencyByType", errmsg, errcode)
            end
        end,
        IS_SHOW_WAITING
    )
end

function DecorativeSelectLayerEx:hideLayer()
    PopupLayerController:hideLayer(
        "DecorativeSelectLayerEx",
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
            layer:hide(true)
        end
    )
end

--@desc: 创建行listView
--@author:Liang SongQiang
--@time:2018-02-07 17:25:25
--@count: 数量
function DecorativeSelectLayerEx:createRowsListView(count)
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

function DecorativeSelectLayerEx:createSelctedListView(list)
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
--@author:Liang SongQiang
--@time:2018-02-07 18:04:45
--@listView: panel所在的listView
--@index: panel的索引
--@data: 需绑定的数据结构
function DecorativeSelectLayerEx:createPanel(listView, index, data)
    local panel = listView:getItem(index - 1)
    if panel == nil then
        panel = self.Panel_Mask:clone()
        Helper:convertUIByParent(panel)
        listView:pushBackCustomItem(panel)
    end

    local mask = Item:getOneItemByKey(data.maskId)
    local maskName = User:getRole():getMaskSystem():getMaskGrade(mask.gradeId,1):getMaskName()
    table.insert(RandomShiPing, mask)
    local present = require("app.presenters.HeadView.HVPPresent"):create(panel.Image_head_1,panel.Image_di_1,{
        portrait = mask.gradeId,
    })
    present:showAnim()
    panel.Text_name_1:setString(maskName)
end

function DecorativeSelectLayerEx:initButton_1(name)
    if type(name) ~= "string" then
        PopText("参数有误")
        return
    end
    self.Button_Right.Text_name:setString(name)
    self.Button_Right:setTouchEnabled(true)
    self.Button_Right:setBright(true)
    self.Button_Right:releaseFunc(
        function()
            local ShiPing = RandomShiPing[math.random(1, #RandomShiPing)]
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            if _spclNum < NOR_COST then
                PopText("你的饰品材料不够")
                return
            end

            if not role:checkCanBuyTwoOrMoreThings({[ShiPing.id] = 1}) then
                return
            end

            HttpManagerEx:updateCurrencyByType("remove","spcl",NOR_COST,nil, function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        role:addItemCount(ShiPing.id, 1)
                        PopText("获得"..ShiPing.name)
                        _spclNum = _spclNum - NOR_COST
                        self:hideLayer()
                        RichPrint("main", "她取来制作面具的一应材料，在面具之上仔细描绘起来。只见她手指上下翻飞，快而熟练，画工精细，不一会便制作出一张逼真的面具来。")
                    else
                        PopText(errmsg)
                    end
                end
            end, IS_SHOW_WAITING)
        end
    )
end

function DecorativeSelectLayerEx:initButton_2(name)
    if type(name) ~= "string" then
        -- PopText("参数有误")
        return
    else
        self.Button_Left.Text_name:setString(name)
        self.Button_Left:releaseFunc(
            function()
                self:hideLayer()
            end
        )
    end
end

function DecorativeSelectLayerEx:setText()
    local role = User:getRole()
    self.Text_2:setString("消耗" .. tostring(NOR_COST) .. "饰品材料")
    self.Text_3:setString("饰品材料：" .. _spclNum .. "个")
end

function DecorativeSelectLayerEx:setTitle(name)
    self.Panel_Title.Text_1:setString(name)
end

Helper:classDefNodeGetInstance(DecorativeSelectLayerEx)
return DecorativeSelectLayerEx
0