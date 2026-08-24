local FundActivityLayer = class("FundActivityLayer", LayerEx)

-- Reward_type = [1,2,3,4]；1：客户端物品，2：客户端属性，3：服务器货币，4：服务器虚拟物品
local Reward_type = {
    locItem = 1,
    locAttr = 2,
    webCurrency = 3,
    webVirtualItem = 4,
}

function FundActivityLayer:create()
	local p = FundActivityLayer:new()
	p:init()
	return p
end

function FundActivityLayer:init()
	local UI = require("Layer/ActionUI/FundLoginRewardUI.lua").create()['root']
	UI:addTo(self)

    Helper:convertUIByParent(self)
    
    self.Button_back:releaseFunc(function ()
        self:hideLayer()
    end)
    
    self:setVisible(false)
end

function FundActivityLayer:showLayer(actionId,productKey)
    self._actionId = actionId
    self._productKey = productKey
    
    self:getFundActivityInfo(false)
end

function FundActivityLayer:getFundActivityInfo(isRefresh)
    HttpManagerEx:getFundActivityInfo(self._actionId,function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 then
			if errcode == 0 then
                self:initList(data.list,data.unlock_condition.state)
                self:initButtonPay(data.unlock_condition)
                if isRefresh == false then
                    self:show()
                end
			else
				PopText(errmsg)
			end
		end
	end, IS_SHOW_WAITING)
end

function FundActivityLayer:hideLayer()
    PopupLayerController:hideLayer("FundActivityLayer",function()
        self:hide()
    end)
end

function FundActivityLayer:setActionTitle(title)
    self.Text_title:setString(title)
end

function FundActivityLayer:setActionDesc(desc)
    if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
    end
    
    self.Text_dsc:setVisible(false)
    
	local richTextScroll = ExtRichTextScroll:create()
    self.Text_dsc:getParent():addChild(richTextScroll)

    local point = cc.p(self.Text_dsc:getPosition())
    local size = self.Text_dsc:getContentSize()

   	richTextScroll:move(point)
    richTextScroll:setSize(size)
    richTextScroll:setDirection(kCCScrollViewDirectionVertical)
    richTextScroll:setAnchorPoint(cc.p(0.5, 0.5))
    richTextScroll:getRichText():setVerticalSpace(5)

   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
    self.RichText_Print:setTouchEnabled(false)
    
    local textColor = {r = 192, g = 192, b = 192}
    self.RichText_Print:pushBackText(desc, textColor, 255, Resource:getFontPath("default"), 40)
end

function FundActivityLayer:initList(list,state)
    self.ListView_itemList:removeAllItems()
    for i,panelData in ipairs(list) do
        local panel = self.Panel_row:clone()
        Helper:convertUIByParent(panel)

        self:initPanel(panel,panelData,state)
        self.ListView_itemList:pushBackCustomItem(panel)
    end
end

function FundActivityLayer:initPanel(panel,panelData,state)
    panel.Image_kuang.Text_time:setString(panelData.name)
    for i = 1,4 do
        panel.Image_kuang["Text_reward"..i]:setString("")
    end
    local itemStrs = string.split(panelData.desc,";")
    for i,itemStr in ipairs(itemStrs) do
        panel.Image_kuang["Text_reward"..i]:setString(itemStr)
    end

    if panelData.state == 0 then
        panel.Image_kuang.Button_receiveAward:loadTextureNormal("Image/UI/TaskUI/anniuhui.png",0)
        panel.Image_kuang.Button_receiveAward.Text_buttonName:setString("领取")
        panel.Image_kuang.Button_receiveAward:setEnabled(true)
        panel.Image_kuang.Button_receiveAward:setVisible(true)
        panel.Image_kuang.Image_reward:setVisible(false)
        panel.Image_kuang.Button_receiveAward:releaseFunc(function()
            if state == 1 then
                PopText("登录天数不足，请符合条件后再领取。")
            else
                PopText("请先付费购买才能领取对应奖励。")
            end
        end)
    elseif panelData.state == 1 then
        panel.Image_kuang.Button_receiveAward:loadTextureNormal("Image/UI/TaskUI/anniu.png",0)
        panel.Image_kuang.Button_receiveAward.Text_buttonName:setString("领取")
        panel.Image_kuang.Button_receiveAward:setVisible(true)
        panel.Image_kuang.Button_receiveAward:setEnabled(true)
        panel.Image_kuang.Image_reward:setVisible(false)
        panel.Image_kuang.Button_receiveAward:releaseFunc(function()
            local items = {}
            for i,v in ipairs(panelData.reward) do
                if v.type == Reward_type.locItem then
                    if items[v.id] then
                        items[v.id] = items[v.id] + v.number
                    else
                        items[v.id] = v.number
                    end
                end
            end

            local role = User:getRole()
            if role:checkCanBuyTwoOrMoreThings(items) == false then
                return
            else
                HttpManagerEx:getFundReward(self._actionId,panelData.rid,function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            self:getReward(data.reward)
                            panel.Image_kuang.Button_receiveAward.Text_buttonName:setString("已领取")
                            panel.Image_kuang.Image_reward:setVisible(true)
                            panel.Image_kuang.Button_receiveAward:setVisible(false)
                            panel.Image_kuang.Text_time:setVisible(false)
                        else
                            PopText(errmsg)
                        end
                    end
                end, IS_SHOW_WAITING)
            end
        end)
    elseif panelData.state == 2 then
        panel.Image_kuang.Button_receiveAward.Text_buttonName:setString("已领取")
        panel.Image_kuang.Image_reward:setVisible(true)
        panel.Image_kuang.Button_receiveAward:setVisible(false)
        panel.Image_kuang.Text_time:setVisible(false)
    else
        assert(nil,"未知状态，请检查领取状态"..panelData.state)
    end
end

function FundActivityLayer:getReward(reward)
    local role = User:getRole()
    for i,v in ipairs(reward) do
        if v.type == Reward_type.locItem then
            role:addItemCount(v.id,v.number)
            PopText("获得物品 "..v.name.."X"..tostring(v.number))
        elseif v.type == Reward_type.locAttr then
            role:addAttr(v.id,v.number)
            PopText("获得 "..v.name.."X"..tostring(v.number))
        elseif v.type == Reward_type.webCurrency or v.type == Reward_type.webVirtualItem then
            PopText("获得 "..v.name.."X"..tostring(v.number))
        end
    end
end

function FundActivityLayer:toPay()
    if self.Is_Click == true then
        -- PopText("您已发出充值请求，请不要重复点击")
        return
    end
    if self._productKey == nil then
        return
    end
    self.Is_Click = true

    HttpManagerEx:checkActionPaySign(
        self._productKey,self._actionId,
        function(status, errcode, errmsg, data, isEncrypted)
            if status == 200 then
                if errcode == 0 then
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
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
                                self:getFundActivityInfo(true)
                                PopText("购买成功")
                                self.Is_Click = false
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
                    SdkMethod:IosPurchase_BuyItem(self._productKey)
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

function FundActivityLayer:initButtonPay(buttonData)
    if buttonData.state == 0 then
        self.Button_toPay:setEnabled(true)
        self.Button_toPay:loadTextureNormal("Image/UI/TaskUI/anniu.png",0)
        self.Button_toPay.Text_buttonName:setString(buttonData.desc)
        self.Button_toPay:releaseFunc(function()
            Game:openPayLayer(function()
                self:toPay()
            end)
        end)
    elseif buttonData.state == 1 then
        self.Button_toPay:setEnabled(true)
        self.Button_toPay:loadTextureNormal("Image/UI/TaskUI/anniuhui.png",0)
        self.Button_toPay.Text_buttonName:setString("已解锁")
        self.Button_toPay:releaseFunc(function()
            PopText("已购买对应奖励，不能重复购买")
        end)
    elseif buttonData.state == 2 then
        self.Button_toPay:setEnabled(true)
        self.Button_toPay:loadTextureNormal("Image/UI/TaskUI/anniuhui.png",0)
        self.Button_toPay.Text_buttonName:setString(buttonData.desc)
        self.Button_toPay:releaseFunc(function()
            PopText("活动购买时间已结束")
        end)
    else
        assert(nil,"未知状态，请检查"..buttonData.state)
    end
end

Helper:classDefNodeGetInstance(FundActivityLayer)

return FundActivityLayer
000000