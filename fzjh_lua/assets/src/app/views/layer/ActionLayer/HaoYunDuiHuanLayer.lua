local HaoYunDuiHuanLayer = class("HaoYunDuiHuanLayer", LayerEx)
local goodLuck = require("script.others.goodluck")["Sheet1"]
function HaoYunDuiHuanLayer:create()
    local p = HaoYunDuiHuanLayer:new()
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @desc 界面初始化
function HaoYunDuiHuanLayer:init()
	self._UI = require("Layer/MapUI/MapBagUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
    
    self.Text_money:setVisible(true)
	self:initButtons()
end


-- @desc 显示界面
function HaoYunDuiHuanLayer:showLayer(func,num)
    self:show()
	self:setButton1(func)
    self:setButton2(func)
    self:refreshLayer(num)
    self:setBagListLeft()
end

--[[
    @desc: 设置当前已兑换通宝数量
    author:tanqinjian
    time:2025-07-02 17:45:36
    --@num: 
    @return:
]]
function HaoYunDuiHuanLayer:setExchangeNum(num)
    self._exchangeNum = num
end

--[[
    @desc: 设置当前可兑换通宝上限
    author:tanqinjian
    time:2025-07-02 17:45:52
    @return:
]]
function HaoYunDuiHuanLayer:setExchangeNumLimit(num)
    self._exchangeNumLimit = num
end

-- @desc 刷新列表
function HaoYunDuiHuanLayer:refreshLayer(num)
    self.Image_title.Text_title2:setString("兑换")
	self.Text_weight:setString((#self.ListView_1:getItems()) .. "/" .. User:getRoleAttr("weight"))
    self.Text_money:setString("好运通宝:"..Helper:getDef(num,0))
end

-- @desc 设置左边背包
function HaoYunDuiHuanLayer:setBagListLeft()
	--self.ListView_1:removeAllItems()

    local role = User:getRole()
    local trimTab = {}
    for k,v in pairs(goodLuck) do
        trimTab[v.itemid] = true
    end

    
	local items = role:getItems(function(item)
        if trimTab[item.itemId] == true then
            return true
        else
            return false
        end
    end)
    
    for i, v in ipairs(items) do
        local row = self.ListView_1:getItem(i - 1)

        if not row then
            row = self.Panel_item1:clone()
            self.ListView_1:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
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
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		        local goodLuckListItemAttr = self:getGoodLuckListItemAttr(v.itemId)
                if goodLuckListItemAttr == nil then
                    assert(false,"HaoYunDuiHuanLayer:setBagListLeft 检查该物品是否在资源表")
                end

                local str = "是否要用YEL"..itemAttr.name.." X"..goodLuckListItemAttr.num.."NOR兑换YEL"..goodLuckListItemAttr.coin.."NOR好运通宝？"

                if self._exchangeNum + goodLuckListItemAttr.coin > self._exchangeNumLimit then
                    str = "使用YEL"..itemAttr.name.." X"..goodLuckListItemAttr.num.."NOR兑换YEL"..goodLuckListItemAttr.coin.."NOR好运通宝将突破本日最高可获得上限，超出部分将不计入好运通宝数量，是否确认兑换？"
                end

                local dialog = DialogALayer:getInstance()
                dialog:show()
                dialog:setRichText(str)
                
                dialog:setButton1("确定", function()
                    local player = User:getRole()

                    local ret, msg = self:checkDuiHuanConditon(v)
                    if not ret then
                        PopText(msg)
                        return
                    end

                    HttpManagerEx:exchangeLuckyPoint(v.itemId,function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                PopText("兑换成功,获得"..data.get_point.."点好运通宝。")
                                player:addItemCount(v.itemId, -goodLuckListItemAttr.num)
                                if data.upper == true then 
                                    PopText("今日兑换已达上限")
                                end
                                self:setBagListLeft()
                                self:refreshLayer(data.total_point)
                                self:setExchangeNum(data.exchangeNum)
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end, IS_SHOW_WAITING)
                   
                end)

                dialog:setButton2("取消", function()
                    dialog:hide()
                end)
            end
        )
    end

    for i = #items + 1, #self.ListView_1:getItems() do
        self.ListView_1:removeLastItem()
    end
end

function HaoYunDuiHuanLayer:checkDuiHuanConditon(item)
    local goodLuckListItemAttr = self:getGoodLuckListItemAttr(item.itemId)
    if item.count >= goodLuckListItemAttr.num then
         return true
    end
    return false ,"物品数量不足"
end

--根据物品id获取好运资源配表
function HaoYunDuiHuanLayer:getGoodLuckListItemAttr(itemId)
    assert(itemId,"HaoYunDuiHuanLayer:getGoodLuckListItemAttr 检查参数")
    for k,v in pairs(goodLuck) do
        if v.itemid == itemId then
            return v
        end
    end
end

--按钮初始化
function HaoYunDuiHuanLayer:initButtons()
	local button1 = self:createButton() --关闭按钮
	local button2 = self:createButton() --确定按钮
	self:addChild(button1)
	self:addChild(button2)
	button1:move(cc.p(270, 200))
	button2:move(cc.p(810, 200))
	self.Button_1 = button1
	self.Button_2 = button2
end

-- @desc 创建按钮
function HaoYunDuiHuanLayer:createButton()
	local roleButton = Resource:getUIByName("Button_4")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end

-- @desc 设置按钮1
function HaoYunDuiHuanLayer:setButton1(func)
	self.Button_1.Text_buttonName:setString("取消")
	self.Button_1:releaseFunc(function()
        if func then
			func()
		end
		PopupLayerController:hideLayer("HaoYunDuiHuanLayer", function(layer)
			self:hide()
		end)
	end)
end

-- @desc 设置按钮2
function HaoYunDuiHuanLayer:setButton2(func)
	self.Button_2.Text_buttonName:setString("确定")
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
		PopupLayerController:hideLayer("HaoYunDuiHuanLayer", function(layer)
			self:hide()
		end)
	end)
end


Helper:classDefNodeGetInstance(HaoYunDuiHuanLayer)
return HaoYunDuiHuanLayer00