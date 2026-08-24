local BuyLandLayer = class("BuyLandLayer", cc.Layer)

--@RefType [app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")

--@RefType [app.models.HomelandModel.HomelandBuyModel.BuyLandModel#BuyLandModel]
local BuyLandModel = require("app.models.HomelandModel.HomelandBuyModel.BuyLandModel")

--@RefType [app.models.HomelandModel.DiQiModel#DiQiModel]
local DiQiModel = require("app.models.HomelandModel.DiQiModel")

--@desc 用于保存绑定列表
local _tagList = {}

function BuyLandLayer:create()
    local p = BuyLandLayer:new()
    p:init()
    return p
end

function BuyLandLayer:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:initButtons()

    self.Text_money:setVisible(true)

    self:schedule(
        function()
            if BuyLandModel._needRefresh then
                self:setMoney(BuyLandModel:getCurrPoiont())
            end
        end,
        1
    )
end

local _npcId = ""
local _mapId = ""

local _isLand = false

function BuyLandLayer:setMoney(value)
    self.Text_money:setString("银票：" .. value)
end

function BuyLandLayer:showLayer(mapId, npcId)
    _npcId = npcId
    _mapId = mapId

    HttpManagerEx:getLandStoreList(
        _mapId,
        _npcId,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    -- Helper:print_lua_table(data)
                    BuyLandModel:initData(data.list)
                    if data.hasLand == "Y" then
                        _isLand = true
                    elseif data.hasLand == "N" then
                        _isLand = false
                    end

                    BuyLandModel:setCurrPoint(data.point)
                    self:setMoney(BuyLandModel:getCurrPoiont())

                    self:initRightList()
                    self:initLeftList()
                    self:refreshUI()
                    self:show()
                else
                    PopText(errmsg .. ", err = " .. errcode)
                    self:hideLayer()
                end
                return true
            else
                PopText(errmsg)
                return true
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function BuyLandLayer:initLeftList()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local items = role:getItems()

    for i, v in ipairs(items) do
        local row = self.ListView_1:getItem(i - 1)

        if not row then
            row = self.Panel_item1:clone()
            self.ListView_1:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
            row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        end

        local itemAttr = Item:getOneItemByKey(v.itemId)

        row.Text_name:setTextColor({r = 255, g = 255, b = 255})
        if v.count > 1 then
            row.Text_name:setString(itemAttr.name .. " X" .. v.count)
        else
            row.Text_name:setString(itemAttr.name)
        end

        row:releaseFunc(
            function()
                PopText("此处无法出售道具。")
            end
        )
    end
end

function BuyLandLayer:initRightList()
    self.ListView_2:removeAllItems()
    
    local list = BuyLandModel:getLandList()

    for i, land in ipairs(list) do
        local row = self.ListView_2:getItem(i - 1)

        if not row then
            row = self.Panel_item2:clone()
            self.ListView_2:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
            row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
            row.Text_num:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        else
            row.Text_name:setTextColor({r = 255, g = 255, b = 255})
            row.Text_status:setVisible(false)
        end

        self:bingRow(row, land, i)
    end
end

--@desc:初始化地皮控件，并绑定数据
--@author:Liang SongQiang
--@time:2018-05-22 15:25:37
function BuyLandLayer:bingRow(row, data, index)
    data.color = Helper:getDef(data.color, "HIW")
    row.Text_name:setString(data.color .. data.name .. "NOR")
    row.Text_num:setString(tostring(data.high_price) .. "银票")

    local _tagData = {
        index = index,
        _tag1 = "",
        _tag2 = "",
        _k1 = "",
        _k2 = ""
    }

    _tagData._tag1 =
        binding.watch(
        data,
        "high_price",
        function(value)
            row.Text_num:setString(tostring(value) .. "银票")
        end
    )

    _tagData._tag2 =
        binding.watch(
        data,
        "state",
        function(value)
            if value == 2 then
                --@desc setRotation 方法BUG，后面的0不能省略
                row.Text_status:enableOutline(cc.c4b(17, 18, 18, 255), 4)
                row.Text_status:setRotationSkewX(-23.00000000000000000000000)
                row.Text_status:setRotationSkewY(-23.00000000000000000000000)
                row.Text_status:setColor(cc.c3b(219, 187, 57))
                row.Text_status:setVisible(true)
                row.Text_status:setString("竞拍中")
            elseif value == 3 then
                --@desc setRotation 方法BUG，后面的0不能省略
                row.Text_status:enableOutline(cc.c4b(17, 18, 18, 255), 4)
                row.Text_status:setRotationSkewX(-23.00000000000000000000000)
                row.Text_status:setRotationSkewY(-23.00000000000000000000000)
                row.Text_status:setColor(cc.c3b(219, 57, 57))
                row.Text_status:setVisible(true)
                row.Text_status:setString("竞拍截止")
            else
                row.Text_status:setColor(cc.c3b(255, 255, 255))
                row.Text_status:setVisible(false)
            end
        end
    )

    _tagData._k1 = "high_price"
    _tagData._k2 = "state"
    _tagList[index] = _tagData

    row:releaseFunc(
        function()
            PopupLayerController:showLayer(
                "DetialWithButtonPopLayer",
                function(layer)
                    local text = data.dsc .. "\n \n"
                    text = text.."WHT这是一张地契，"
                    text = text .. "此地为" .. data.name .. "\n当前持有人为官府\n"
                    text = text .. "每日地税为" .. data.cost .. "元宝/天\n此地上天三丈，入地三丈均归地主所有。\n"

                    if data.high_name and data.high_name ~= "" then
                        text = text .. "竞价人为 ：" .. data.high_name .. "\n"
                    end

                    local time = 0
                    if data.surplusTime then
                        time = data.surplusTime - GetTime()
                    end

                    if time > 0 then
                        local hour = math.floor(time / 3600)
                        local min = math.floor(math.mod(time / 60, 60))
                        local sec = math.floor(math.mod(time, 60))
                        text = text .. "竞价剩余时间：" .. hour .. "小时" .. min .. "分钟" .. sec .. "秒"
                    end

                    local name
                    if data.state ~= 3 then
                        name = "竞价"
                    end

                    layer:showLayer(
                        DiQiModel:getNameColor(data.dpId),
                        data.type,
                        text,
                        name,
                        function()
                            PopupLayerController:showLayer(
                                "BiddingLayer",
                                function(layer1)
                                    layer1:showLayer(data, _npcId, _isLand)
                                end
                            )

                            layer:hideLayer()
                        end
                    )
                end
            )

            print("当前价格：", data.high_price)
        end
    )
end

function BuyLandLayer:initButtons()
    local createBtn = function()
        local roleButton = Resource:getUIByName("Button_4")
        Helper:convertUI(roleButton)
        roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        return roleButton
    end

    local button_right = createBtn()
    -- local button_left = createBtn()
    self:addChild(button_right)
    -- self:addChild(button_left)
    -- button_left:move(cc.p(270, 200))
    button_right:move(cc.p(810, 200))

    button_right:setVisible(true)
    button_right.Text_buttonName:setString("确定")
    button_right:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")
            self:hideLayer()
        end
    )
end

function BuyLandLayer:hideLayer()
    PopupLayerController:hideLayer(
        "BuyLandLayer",
        function(layer)
            --@desc 解除绑定
            if not MapIsEmpty(_tagList) then
                local landList = BuyLandModel:getLandList()
                for k, v in pairs(_tagList) do
                    binding.unwatch(landList[k], v._k1, v._tag1)
                    binding.unwatch(landList[k], v._k2, v._tag2)
                end
                _tagList = {}
            end

            layer:hide()
        end
    )
end

function BuyLandLayer:refreshUI()
    self.Image_title.Text_title2:setString("售地列表")
    self.Text_weight:setString((#self.ListView_1:getItems()) .. "/" .. User:getRoleAttr("weight"))
end

Helper:classDefNodeGetInstance(BuyLandLayer)
return BuyLandLayer
00000