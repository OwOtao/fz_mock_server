local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

local PayLayer = class("PayLayer", cc.Layer)

function PayLayer:create()
    local p = PayLayer:new()
    p:init()
    return p
end

function PayLayer:init()
    local UI = require("Layer/StoreUI/PayUI.lua").create()["root"]
    UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Text_qun:setString("官方客服：" .. Game:getKFQQ())
    if Game:isOpenKFQQ() == true or Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN then
        self.Text_qun:setVisible(false)
    end

    self.__products = {}

    self.__discount = {}

    self:setButtonClose()

    self:setPanelBack()

    self:setVisible(false)
end

function PayLayer:show()
    self:initProducts(function()
        self:setVisible(true)
    end)
end

function PayLayer:initProducts(func)
    HttpManagerEx:getAppStoreData(
        function(status, errcode, errmsg, data, isEncrypted)
            -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
            if isEncrypted == false then
                PopText("数据异常，请不要使用第三方工具进行游戏。")
                Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
                return
            end

            if status == 200 then
                if errcode == 0 then
                    if data.store_status == "OPEN" and MapIsEmpty(data.list) == false then
                        self.__products = data.list

                        self.__discount = Helper:getDef(data.discount, {["1"] = 1, ["2"] = 1, ["3"] = 1, ["4"] = 1})

                        self:setTitle(data.title)

                        self:__showActionDesc(data.time)

                        self:__createProductsList()

                        if func then
                            func()
                        end
                    else
                        if errmsg == nil then
                            errmsg = "充值商店已关闭"
                        end
                        PopText(errmsg)
                        self:hide()
                    end
                else
                    PopText(errmsg)
                    self:hide()
                    PopText(data)
                end
            else
                self:hide()
                PopText("网络异常,无法获取充值列表")
            end
        end,
        IS_SHOW_WAITING
    )
end

function PayLayer:setTitle(titleName)
    self.Text_title:setString(Helper:getDef(titleName, ""))
end

function PayLayer:hide()
    MainControllLayer:getLayer("StoreLayer"):refreshYuanBaoNumber()
    PopupLayerController:hideLayer(
        "PayLayer",
        function(layer)
            self:setVisible(false)
        end
    )
end

function PayLayer:__createProductsList()
    self.ListView_list:removeAllItems()
    for i, product in ipairs(self.__products) do
        local productUI = self:createOneItem(product)

        local product_discount = self.__discount[tostring(product.id)]

        local buyYuanBaoInfo = {
            real_yuanbao = 0
        }

        if product_discount > 1 then
            productUI.Text_origin:setVisible(true)
            productUI.Image_quan:setVisible(true)
            productUI.Text_discount:setVisible(true)

            local discount_fator = Helper:mathFloor((product_discount - 1) * 100)

            productUI.Text_discount:setString("+" .. discount_fator .. "%")
            productUI.Text_origin:setString(product.yuanbao)
            productUI.Text_real:setString("+" .. product.yuanbao * product_discount)

            buyYuanBaoInfo.real_yuanbao = product.yuanbao * product_discount
        else
            productUI.Text_origin:setVisible(false)
            productUI.Image_quan:setVisible(false)
            productUI.Text_discount:setVisible(false)
            productUI.Text_real:setString(product.dsc)

            buyYuanBaoInfo.real_yuanbao = product.yuanbao
        end

        productUI.Text_name:setString(product.name)
        productUI.Text_money:setString(product.price)

        productUI:releaseFunc(
            function()
                if self.Is_Click == true then
                    -- PopText("您已发出充值请求，请不要重复点击")
                    return
                end
                self.Is_Click = true

                HttpManagerEx:checkPaySign(
                    product.key,
                    function(status, errcode, errmsg, data, isEncrypted)
                        if status == 200 then
                            if errcode == 0 then
                                local dialog = DialogALayer:getInstance()
                                dialog:show("正在充值,请稍后")
                                dialog:setBack(false)
                                dialog:setButton1()
                                dialog:setButton2()

                                SdkMethod:IosPurchase_SetCallback(
                                    function(eventName)
                                        if not eventName or string.len(eventName) <= 0 then
                                            PopText("异常，请联系客服人员")
                                            return
                                        end
                                        local errcode = tonumber(eventName)

                                        local text
                                        if errcode == 1 then
                                            text = "仅支持IOS7以上系统"
                                        elseif errcode == 2 then
                                            text = "不允许程序内付费，玩家关闭了应用内购买功能"
                                        elseif errcode == 3 then
                                            text = "没有该商品"
                                        elseif errcode == 4 then
                                            text = "购买出错"
                                            HttpManagerEx:updateOrderState()
                                        elseif errcode == 7 then
                                            text = "已经购买过此商品"
                                        elseif errcode == 9 then
                                            text = "交易失败"
                                            HttpManagerEx:updateOrderState()
                                        elseif errcode == 12 then
                                            text = "错误的头信息"
                                        elseif 13 <= errcode and errcode <= 14 then
                                            text = "服务器异常，物品可能延迟到账"
                                        elseif 15 <= errcode and errcode <= 20 then
                                            text = "请勿使用非法渠道购买物品"
                                        elseif errcode == 21 then
                                            text = "未知错误"
                                        elseif errcode == 22 then
                                            text = "订单ID获取失败,请重新尝试"
                                        elseif errcode == 23 then
                                            text = "交易失败，订单ID非法。"
                                        elseif errcode == 24 then
                                            text = "订单异常，服务器无法获取订单信息。"
                                        elseif errcode == 25 then
                                            text = "角色存档数据不存在，请联系客服。"
                                        elseif errcode == 26 then
                                            text = "取消登录"
                                        elseif errcode == 27 then
                                            text = "放弃支付"
                                            HttpManagerEx:updateOrderState()
                                        elseif errcode == 28 then
                                            text = "登录成功"
                                        elseif errcode == 29 then
                                            text = "登录失败"
                                        elseif errcode == 30 then
                                            text = "订单已提交或处理中"
                                        elseif errcode == 31 then
                                            text = "登录状态过期"
                                        else
                                            text = ""
                                        end

                                        if errcode == 0 then
                                            local ybNum = buyYuanBaoInfo.real_yuanbao
                                            PopText("成功购买，元宝 + " .. tostring(ybNum))
                                            -- 真实价格,支付渠道1:游戏客户端
                                            Mob.pay(product.real_price, 21, product.name, 1, tonumber(ybNum) / tonumber(product.real_price))
                                            
                                            if self.__discount[tostring(product.id)] > 1 then
                                                self:initProducts(function()
                                                    self.Is_Click = false
                                                end)
                                            else
                                                self.Is_Click = false
                                            end
                                            
                                            HttpManagerEx:getYuanBao(
                                                function(status, errcode, errmsg, data)
                                                    if status == 200 then
                                                        if errcode == 0 then
                                                            User:setRoleAttr("yuanbao", data.yuanbao)
                                                        else
                                                            if type(errmsg) == "string" then
                                                                PopText(errmsg)
                                                            end
                                                        end
                                                    end
                                                end
                                            )
                                            dialog:hide()
                                        else
                                            PopText(text)
                                        end

                                        if text ~= "" then
                                            self.Is_Click = false
                                            dialog:hide()
                                        end
                                    end
                                )
                                if PRINT_MODE == 1 then
                                    print("product.key = " .. tostring(product.key))
                                end
                                SdkMethod:IosPurchase_BuyItem(product.key)
                            else
                                self.Is_Click = false
                                PopText(errmsg)
                            end
                        else
                            self.Is_Click = false
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            end
        )
        self.ListView_list:pushBackCustomItem(productUI)
    end

    self.ListView_list:jumpToTop()
end

function PayLayer:setButtonClose()
    self.Button_close:releaseFunc(
        function()
            self:hide()
        end
    )
end

function PayLayer:createOneItem(product)
    local row = self.Panel_item:clone()
    Helper:convertUIByParent(row)
    row:setVisible(true)
    return row
end

function PayLayer:setPanelBack()
    self.Panel_back:releaseFunc(
        function()
            self:hide()
        end
    )
end

function PayLayer:onResume()
    self.Is_Click = false
end

function PayLayer:__showActionTime(timeDesc)
    self.Panel_Action_Desc.Text_Action_Time:setString(timeDesc)
end

function PayLayer:__showActionDesc(timeDesc)
    if timeDesc ~= nil and timeDesc ~= "" then
        self.Panel_Action_Desc:setVisible(true)
        self:__showActionTime(timeDesc)
    else
        self.Panel_Action_Desc:setVisible(false)
    end
end

Helper:classDefNodeGetInstance(PayLayer)
return PayLayer
00000