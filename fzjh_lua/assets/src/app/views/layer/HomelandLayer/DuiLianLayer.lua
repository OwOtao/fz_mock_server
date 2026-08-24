--对联改造界面
local DuiLianLayer = class("DuiLianLayer", LayerEx)
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

local familylist = requireWithEncrypt("script.others.familylist")
local duilianList = familylist["对联"]

local function sortDuilianMap()
    local temp = {}
    for k, v in pairs(duilianList) do
        table.insert(temp, v)
    end

    table.sort(
        temp,
        function(a, b)
            return tonumber(a.cost) < tonumber(b.cost)
        end
    )

    duilianList = temp
end

sortDuilianMap()

local currDuilianInfo = {}

function DuiLianLayer:create()
    local p = DuiLianLayer:new()
    p:init()
    return p
end

function DuiLianLayer:init()
    local UI = require("Layer/HomelandUI/DuiLianUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)

    self:setChangeButton()
    self:setBackButton()
end

function DuiLianLayer:hideLayer()
    PopupLayerController:hideLayer(
        "DuiLianLayer",
        function(layer)
            
            layer:hide()
        end
    )
end

function DuiLianLayer:showLayer(map, item)
    self:show()
    if map then
        self._map = map
        self.item = item
        local currRoomId = self._map:getCurrRoomId()
        self._currRoomAttr = self._map:getRoomById(currRoomId)
        self._currDuiLianId = self._map.extra.couplet
    end
    self:getYinPiao()
    self:initDuilianList()

    self.changeData = {}
end

--设置对联列表
function DuiLianLayer:initDuilianList()
    self.ListView_1:removeAllItems()
    self.Text_money:setVisible(false)
    for k, v in ipairs(duilianList) do
        local row = self:createPanel(v)
        -- Helper:print_lua_table(row)
        row:releaseFunc(
            function()
                if v.id == self._currDuiLianId then
                    PopText("当前门联已经是这副门联了！")
                    return
                end
                -- row.Text_info:setColor(cc.c3b(0, 255, 255)) --颜色待给出
                --变色
                row.Text_kuang:setVisible(true)
                self.Text_money:setVisible(true)
                self.Text_money:setString("花费" .. v.cost .. "银票")

                self.changeData = v

                local list = self.ListView_1:getItems()
                local index = self.ListView_1:getIndex(row) + 1
                for k, v in ipairs(list) do
                    if k ~= index then
                        --还原
                        -- v.Text_info:setColor(cc.c3b(159, 159, 159))
                        v.Text_kuang:setVisible(false)
                    end
                end
            end
        )
        self.ListView_1:pushBackCustomItem(row)
    end

    local currDuilianData = self:getCurrDuilianInfo()

    if not MapIsEmpty(currDuilianData) then
        self.Text_currinfo:setString("『" .. currDuilianData.dsc .. "』")
    else
        self.Text_currinfo:setString("")
    end
end

function DuiLianLayer:createPanel(list)
    list = Helper:getDef(list, {})
    local panel = self.Panel_1:clone()
    Helper:convertUIByParent(panel)
    panel.Text_info:setString("『" .. list.dsc .. "』")
    return panel
end

--获取当前对联信息
function DuiLianLayer:getCurrDuilianInfo()
    local currDuiLianId = self._currDuiLianId

    if currDuiLianId == nil then
        return
    end

    for k, v in pairs(duilianList) do
        if v.id == currDuiLianId then
            return v
        end
    end
end

--获取当前银票数量
function DuiLianLayer:getYinPiao()
    HttpManagerEx:viewCurrencyByType(
        "yinpiao",User:getRole():getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self._currYinPiao = data.number
                    self:setYinPiao()
                else
                    PopText(errmsg)
                    self:hideLayer()
                end
            else
                PopText(errmsg)
                self:hideLayer()
            end
        end,
        IS_SHOW_WAITING
    )
end

--设置银票显示数值
function DuiLianLayer:setYinPiao()
    self.Text_yinpiao:setString("『银票』" .. tostring(self._currYinPiao))
end

--设置离开按钮
function DuiLianLayer:setBackButton()
    self.Button_NO.Text_buttonNoName:setString("离开")
    self.Button_NO:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

--设置更换按钮
function DuiLianLayer:setChangeButton()
    self.Button_Yes.Text_buttonYesName:setString("更换")
    self.Button_Yes:releaseFunc(
        function()
            local changeData = self.changeData
            if MapIsEmpty(changeData) then
                PopText("你尚未选择对联")
                return
            end

            local needyinpiao = changeData.cost

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()

            dialog:show("对联改造需要花费" .. changeData.cost .. "银票，你确定改造吗？")
            dialog:setWeChatVisible(false)
            dialog:setButton1(
                "确定",
                function()
                    local fjId = self._map:getCurrRoomId()
                    local mid = self._map.mid
                    local attr = {}
                    attr.couplet = changeData.id
                    local point = changeData.cost
                    HttpManagerEx:uploadMapExtra(
                        mid,
                        attr,
                        point,
                        function(status, errcode, errmsg, data)
                            if status == 200 and errcode == 0 then
                                self._currDuiLianId = attr.couplet
                                self._map.extra.couplet = attr.couplet
                                self._currYinPiao = self._currYinPiao - data.remove_point
                                self:setYinPiao()
                                self:initDuilianList()
                                HomelandRoomUtil:updateDoorRoomAndDoorItemDsc(self.item, self._currRoomAttr, self._map)
                                self._map.__MapLayer:refreshMap()
                                self.changeData = {}
                                PopText("扣除银票：" .. data.remove_point)
                            else
                                PopText(errmsg)
                                print("errcode : " .. errcode)
                            end
                        end,
                        IS_SHOW_WAITING
                    )
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

Helper:classDefNodeGetInstance(DuiLianLayer)
return DuiLianLayer
000000000000000