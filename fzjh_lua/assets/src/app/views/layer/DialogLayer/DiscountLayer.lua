-- 特殊商人 打折选择界面
local DiscountLayer = class("DiscountLayer", cc.Layer)

function DiscountLayer:create()
	local p = DiscountLayer:new()
	p:init()
	return p
end

function DiscountLayer:init()
	local UI = require("Layer/Dialog/DiscountUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点
    
    self:setBack()
end


function DiscountLayer:showLayer(text)
    self.Text_text:setString(text or "")

    self:show()
end


--按钮注册事件
function DiscountLayer:setButton(name, title, func)
	if not name then
		return
	end

	if not title then
		self[name]:setVisible(false)
	else
		self[name]:setVisible(true)
		self[name].Text_name:setString(title)
	end

    self[name]:releaseFunc(function()
        Audio:playEffect("xiaoAnNiu")
        -- self:hide()
        if func then
            func()
        end
    end)
end

function DiscountLayer:setBack(canHide)
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

--检查是否有指定折扣的优惠券
function DiscountLayer:checkHaveDiscountCoupon(itemId)
    if itemId == nil then
        return false
    end
    local role = User:getRole()
    local items =
        role:getItems(function(item)
            return item.itemId == itemId
        end
    )
    
    if #items > 0 then
        return true
    end

    return false
end

Helper:classDefNodeGetInstance(DiscountLayer)

return DiscountLayer00