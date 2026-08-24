--[[
	在商人处购物二次确认界面，黑商，小贩，冥商
]]

local ShoppingDialogUI = class("ShoppingDialogUI", cc.Layer)

function ShoppingDialogUI:create()
	local p = ShoppingDialogUI:new()
	p:init()
	return p
end

function ShoppingDialogUI:init()
	self._round = require("Layer/Dialog/ShoppingDialogUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点

	self.rich_text = nil
	self:initRichText()
end

function ShoppingDialogUI:initRichText()
	if self.rich_text ~= nil then
        self.rich_text:removeFromParent()
	end

	local x, y = self.Text_extraDsc:getPosition()
    local size = self.Text_extraDsc:getContentSize()

    self.rich_text = ExtRichTextScroll:create()

    self.Text_extraDsc:getParent():addChild(self.rich_text)
    self.rich_text:move(cc.p(x, y))
    self.rich_text:setSize(size)
    self.rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    self.rich_text:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text:getRichText():setVerticalSpace(20)
end

function ShoppingDialogUI:setRichText(text)
	self.Text_extraDsc:setString("")
	self:initRichText()

	local textColor = cc.c3b(255, 255, 255)
    self.rich_text:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 45)
end

function ShoppingDialogUI:show(textList, func)
	self._isShowDiscountLayer = false
	self:setVisible(true)

	if func then
		func()
	end
    
    -- textList = {
    --     Text_tital = "",
    --     Text_type = "",
    --     Text_dsc = "",
    --     Text_price = "",
    --     Text_affirm = "",
    --     Text_havenum = "",
    -- }

    self:setText_tital(textList["Text_tital"])
    self:setText_type(textList["Text_type"])
    self:setText_dsc(textList["Text_dsc"])
    self:setText_price(textList["Text_price"])
    self:setText_affirm(textList["Text_affirm"])
    self:setText_havenum(textList["Text_havenum"])

	self:setBack()
end

function ShoppingDialogUI:hide()
	self:setVisible(false)
end

--物品名字
function ShoppingDialogUI:setText_tital(text)
	self.Text_tital:setColor(cc.c3b(255,255,255))
	self.Text_tital:setString(text)
end

--物品类型
function ShoppingDialogUI:setText_type(text)
	self.Text_type:setString(text)
end

--物品描述
function ShoppingDialogUI:setText_dsc(text)
	self.Text_dsc:setString(text)
end

--物品价格
function ShoppingDialogUI:setText_price(text)
	self.Text_price:setString(text)
end

--确认描述文本
function ShoppingDialogUI:setText_affirm(text)
	self.Text_affirm:setColor(cc.c3b(255,255,255))
	self.Text_affirm:setString(text)
end

--拥有的财富
function ShoppingDialogUI:setText_havenum(text)
	self.Text_havenum:setString(text)
end


--按钮注册事件
function ShoppingDialogUI:setButton(name, title, func)
	if not name then
		return
	end

	if not title then
		self[name]:setVisible(false)
	else
		self[name]:setVisible(true)
		self[name].Text_buttonName:setString(title)
	end

	--显示折扣界面
	if name == "Button_confirm" and self._isShowDiscountLayer == true then
		self[name]:releaseFunc(function()
			Audio:playEffect("xiaoAnNiu")
			self:hide()

			local role = User:getRole()
			PopupLayerController:showLayer("DiscountLayer",function(layer)
				layer:setButton("Button_1", "九折优惠券", function()
					if layer:checkHaveDiscountCoupon("shuangshiyiwp3") == false then
						PopText("没有对应折扣的优惠券。")
						return 
					end
					if func then
						func("shuangshiyiwp3")
					end
					layer:hide()
				end)
				layer:setButton("Button_2", "八折优惠券", function()
					if layer:checkHaveDiscountCoupon("shuangshiyiwp2") == false then
						PopText("没有对应折扣的优惠券。")
						return 
					end
					if func then
						func("shuangshiyiwp2")
					end
					layer:hide()
				end)
				layer:setButton("Button_3", "七折优惠券", function()
					if layer:checkHaveDiscountCoupon("shuangshiyiwp1") == false then
						PopText("没有对应折扣的优惠券。")
						return 
					end
					if func then
						func("shuangshiyiwp1")
					end
					layer:hide()
				end)
				layer:setButton("Button_4", "直接购买", function()
					if func then
						func()
					end
					layer:hide()
				end)
				layer:showLayer("是否使用优惠券？")
			end)
		end)
	else
		self[name]:releaseFunc(function()
			Audio:playEffect("xiaoAnNiu")
			self:hide()
			if func then
				func()
			end
		end)
	end
end

function ShoppingDialogUI:setButton_confirm(title, func)
	self:setButton("Button_confirm", title, func)
end

function ShoppingDialogUI:setButton_close(title, func)
	self:setButton("Button_close", title, func)
end

function ShoppingDialogUI:setButton_batchBuy(title, func)
	self:setButton("Button_batchBuy", title, func)
end

-- canHide false 点击背景不能隐藏界面  true 点击背景可以隐藏界面 默认 true
function ShoppingDialogUI:setBack(canHide)
	self.Panel_back:setTouchEnabled(true)
	if canHide == nil then
		canHide = true
	end
	self.Panel_back:releaseFunc(function()
		if canHide == false then
			return
		end
		self:hide()
	end)
end

--是否显示打折页面
function ShoppingDialogUI:isShowDiscountLayer(boolean)
	self._isShowDiscountLayer = Helper:getDef(boolean,false) 
end

return ShoppingDialogUI000000000000