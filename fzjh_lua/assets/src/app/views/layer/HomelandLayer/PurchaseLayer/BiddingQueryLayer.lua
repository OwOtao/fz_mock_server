local BiddingQueryLayer = class("BiddingQueryLayer", cc.Layer)

--@RefType [app.models.HomelandModel.DiQiModel#DiQiModel]
local DiQiModel = require("app.models.HomelandModel.DiQiModel")

function BiddingQueryLayer:create()
    local p = BiddingQueryLayer:new()
    p:init()
    return p
end

local _currPoint = 0

function BiddingQueryLayer:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:initButtons()

    self:schedule(
        function()
            local listCount = #self.ListView_1:getItems()
            if listCount ~= #self.ListView_1:getItems() then
                self.Text_weight:setString((#listCount) .. "/" .. User:getRoleAttr("weight"))
                self:initLeftList()
            end
        end,
        1
    )
end

function BiddingQueryLayer:showLayer()
    HttpManagerEx:querybiddingInfo(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    print("-----------------------------")
                    Helper:print_lua_table(data)
                    print("-----------------------------")

                    self:initRightList(data.list)
                    self:initLeftList()

                    self.Text_money:setVisible(true)
                    _currPoint = Helper:getDef(data.point, 0)
                    self.Text_money:setString("银票：" .. _currPoint)

                    self:refreshUI()

                    self:show()
                else
                    PopText(errmsg)
                    self:hideLayer()
                end
                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function BiddingQueryLayer:initRightList(serverData)
    self.ListView_2:removeAllItems()

    local i = 1
    for k, v in pairs(serverData) do
        local dpData = DiQiModel:getDpInfoById(v.dpId)
        --bid_state 1竞价进行中，2、竞价已截止、3、竞价失败，领取银票
        local row = self.ListView_2:getItem(i - 1)
        i = i + 1
        if not row then
            row = self.Panel_item2:clone()
            self.ListView_2:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
            row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
            row.Text_num:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        else
            row.Text_name:setTextColor({r = 255, g = 255, b = 255})
        end
        row.Text_status:setVisible(true)
        row.Text_status:enableOutline(cc.c4b(17, 18, 18, 255), 4)
        row.Text_status:setRotationSkewX(-23.00000000000000000000000)
        row.Text_status:setRotationSkewY(-23.00000000000000000000000)

        local color = Helper:getDef(dpData.color, "HIW")
        row.Text_name:setString(color .. dpData.name .. "NOR")
        row.Text_num:setString(v.high_price .. "银票")

        local dsc = "这是一张地契，地契上写着：\n此地为" .. dpData.place .. dpData.name .. "。\n"
        dsc = dsc .. "每日地税为" .. dpData.cost .. "元宝/天。\n"
        dsc = dsc .. "此地上天三丈，入地三丈均归地主所有。\n"

        local btnName
        local btnFunc = EMPTY_FUNC

        if v.bid_state == 1 then
            --@desc 竞拍中
            dsc = dsc .. "竞价人为：" .. v.high_name .. "\n"
            row.Text_status:setColor(cc.c3b(219, 187, 57))
            row.Text_status:setString("竞拍中")
            btnName = "关闭"

            if v.surplusTime then
                local time = v.surplusTime - GetTime()
                if time > 0 then
                    local hour = math.floor(time / 3600)
                    local min = math.floor(math.mod(time / 60, 60))
                    local sec = math.floor(math.mod(time, 60))
                    dsc = dsc .. "竞价剩余时间：" .. hour .. "小时" .. min .. "分钟" .. sec .. "秒"
                end
            end
            
        elseif v.bid_state == 2 then
            --@desc 竞拍成功
            row.Text_status:setColor(cc.c3b(219, 187, 57))
            row.Text_status:setString("成功")
            dsc = dsc .. "您已竞拍该土地成功，可领取对应地契。\n"

            if v.surplusTime then
                local time = v.surplusTime - GetTime()
                if time > 0 then
                    local hour = math.floor(time / 3600)
                    local min = math.floor(math.mod(time / 60, 60))
                    local sec = math.floor(math.mod(time, 60))
                    dsc = dsc .. "领取剩余时间：" .. hour .. "小时" .. min .. "分钟" .. sec .. "秒"
                end
            end

            print("============= state 2 ======================")
            Helper:print_lua_table(v)
            btnName = "领取地契"
            btnFunc =
                function()
                local role = User:getRole()

                --@desc 只为检查是否可以加入一件物品
                if role:checkCanBuyTwoOrMoreThings({["jian111"] = 1}) == false then
                    return
                end

                HttpManagerEx:getbiddingLand(
                    v.dpId,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                --@RefType [app.models.HomelandModel.DiQiModel#DiQiModel]
                                local DiQiModel = require("app.models.HomelandModel.DiQiModel")

                                DiQiModel:getDiQi(v)

                                local rowIndex = self.ListView_2:getIndex(row)
                                self.ListView_2:removeItem(rowIndex)

                                self:initLeftList()

                                PopText("您获得了一张地契。")
                                return true
                            else
                                print(" errcode = " .. errcode)
                                PopText(errmsg)
                                return true
                            end
                        else
                            print("errcode = ", errcode)
                            PopText(errmsg)
                            return false
                        end
                    end,
                    IS_SHOW_WAITING,
                    HTTP_MANAGER_RETRY_TYPE_RETRY
                )
            end
        elseif v.bid_state == 3 then
            row.Text_status:setColor(cc.c3b(219, 57, 57))
            row.Text_status:setString("领取银票")
            row.Text_num:setString(v.return_point .. "银票")
            --@desc 竞拍返还
            dsc = dsc .. "已有人出价比您更高，现将您竞价花费的" .. v.return_point .. "银票返还\n"

            if v.surplusTime then
                local time = v.surplusTime - GetTime()
                if time > 0 then
                    local hour = math.floor(time / 3600)
                    local min = math.floor(math.mod(time / 60, 60))
                    local sec = math.floor(math.mod(time, 60))
                    dsc = dsc .. "领取剩余时间：" .. hour .. "小时" .. min .. "分钟" .. sec .. "秒"
                end
            end

            btnName = "领取银票"
            btnFunc =
                function()
                --@desc 通知服务器增加银票
                HttpManagerEx:getBiddingReturnPoint(
                    v.dpId,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                local rowIndex = self.ListView_2:getIndex(row)
                                self.ListView_2:removeItem(rowIndex)

                                self.Text_money:setString("银票：" .. _currPoint + data.return_point)
                                PopText("您领取了" .. data.return_point .. "银票")
                            else
                                print("errcode", errcode)
                                PopText(errmsg)
                            end
                        else
                            print("errcode", errcode)
                            PopText(errmsg)
                            return
                        end
                    end,
                    IS_SHOW_WAITING
                )
            end
        end

        row:releaseFunc(
            function()
                PopupLayerController:showLayer(
                    "DetialWithButtonPopLayer",
                    function(layer)
                        local text = v.dsc.."\n \n".."WHT"..dsc

                        layer:showLayer(
                            DiQiModel:getNameColor(v.dpId),
                            "地契",
                            text,
                            btnName,
                            function()
                                btnFunc()
                                layer:hideLayer()
                            end
                        )
                    end
                )
            end
        )
    end
end

function BiddingQueryLayer:initLeftList()
    self.ListView_1:removeAllItems()

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
            end
        )
    end
end

function BiddingQueryLayer:initButtons()
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

function BiddingQueryLayer:hideLayer()
    PopupLayerController:hideLayer(
        "BiddingQueryLayer",
        function(layer)
            layer:hide()
        end
    )
end

function BiddingQueryLayer:refreshUI()
    self.Image_title.Text_title2:setString("购地信息")
    self.Text_weight:setString((#self.ListView_1:getItems()) .. "/" .. User:getRoleAttr("weight"))
end

Helper:classDefNodeGetInstance(BiddingQueryLayer)
return BiddingQueryLayer
0000000000000000