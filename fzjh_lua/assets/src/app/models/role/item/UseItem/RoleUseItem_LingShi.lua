local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_LingShi = {}

function RoleUseItem_LingShi:__canUseItem()
	local  currLayer =  MainControllLayer:getCurrLayer()
	if currLayer == "BiWuMainLayer" then
		self:__popText("论剑擂台鱼龙混杂，不宜使用灵石！")
		return false
	end

	if Map:getMapState("fb25") ~= MAP_STATE.COMPLETE then
		self:__richPrint("需通关“柳玄风卷上”第五章方可开启灵石")
		return false
	end

	if DEBUG_MODE == 1 then
		return true
	end

	local date = tonumber(Helper:date("%H%M%S", GetTime()))

	if date < tonumber("000001") or date > tonumber("230000") then
		self:__richPrint("灵石需在每日0时-23时使用")
		return false
	end

    return true
end

function RoleUseItem_LingShi:__doUseItem()
    local item = self._item
    local itemId = item.id
	local role = self._role

	local ShenShuHelper = require("app.models.shenshu.shenshu")
	--开启神书任务之前，需判断是否需要重置刷新
	if ShenShuHelper:checkNeedResetTask(role, GetTime()) then
		ShenShuHelper:resetTask(role)
	end

	local ShenShu = require("app.views.layer.ShenShu.ShenShuLayer")
	local currLayer = MainControllLayer:getCurrLayer()
	local layer
	if currLayer ~= "AttrLayer" then
		layer = currLayer
	end
	ShenShu:shouLayer(1, layer, function()
		local testList =
		{
			"YEL你将灵石放于掌心，以内力灌注其中。",
			"HIC手中灵石温度陡升，泛出道道金光。",
			"HIM只见一道璀璨光芒显现于空中，光中飞出一本本书籍，飞向江湖各处角落。",
			"HIY神书再现，有缘者方可得之！"
		}
		for i = 1, #testList do
			role._iOutput:delayTextPrint(i/2, testList[i])
		end

		role:addItemCount(itemId, - 1)
		self:__onUseAft()
	end)

    return true
end

return NewClass("RoleUseItem_LingShi", {AbstractUseItem}, RoleUseItem_LingShi)
0000000000000