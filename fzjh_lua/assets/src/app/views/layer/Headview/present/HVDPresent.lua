--[[
	根据性别，容貌，装备，头像，易容术数据展示头像和播放特效
]]
local newClass = require("third.class.NewClass")
local MaskResManager = require("app.models.mask.MaskResManager")
local MaskConst = require("app.models.mask.MaskConst")
local HVDPresent = {}

function HVDPresent:create(node,data)
    local p = HVDPresent.new()
	p:init(node,data)
    return p
end

function HVDPresent:init(node,data)
    if node:getChildByName("headView") then
		self._headView = node:getChildByName("headView")
    else
        local NewHeadView = require("app.views.ui.HeadView.NewHeadView")
        self._headView = NewHeadView:create(node)
    end
    self._data = data
end

function HVDPresent:showHead()
    local head = self:_getPathByType("head")
    self._headView:showHead(head)
end

function HVDPresent:showAnim()
    local anim = self:_getPathByType("anim")
    if string.find(anim, ".png") ~= nil then
        self._headView:showHead(anim)
    else
        self._headView:showAnim(anim)
    end
end

function HVDPresent:playEffect()
    local effect = self:_getPathByType("effect")
    self._headView:playEffect(effect)
end

function HVDPresent:_getPathByType(pathType)
    local maskAttr = self:_getMaskAttr()
    if pathType == "head" then
        return maskAttr:getResPath()
    elseif pathType == "anim" then
        return maskAttr:getAnimPath()
    elseif pathType == "effect" then
        return maskAttr:getEffectPath()
    end
end

function HVDPresent:_getMaskAttr()
    local sex = self._data.sex == nil and "男" or self._data.sex
	local looks = tonumber(self._data.looks) or 0
    local equipHead = self._data.head
	local portrait = self._data.portrait
	local polymorph = self._data.polymorph

	local headItemId = nil
	if type(equipHead) == "table" then
        headItemId = equipHead.itemId
	end

	-- 先判断是否佩戴面具
	if headItemId then
		local item = Item:getOneItemByKey(headItemId)
        if item ~= nil and item.gradeId then
            return MaskResManager:getMaskAttrByMaskIdAndLv(item.gradeId,1)
		end
	end
	
	-- 判断是否使用饰品
	if portrait and portrait ~= "" then
		if type(portrait) == "string" then
			portrait = {id = portrait,lv = 1}
		end
		local item = Item:getOneItemByKey(portrait.id)
        if item ~= nil and item.gradeId then
            return MaskResManager:getMaskAttrByMaskIdAndLv(item.gradeId,portrait.lv)
		end
	end

	local function getSpecialRongMao(list)
		if MapIsEmpty(list) == false and list.luckNum > 50 and YIRONGSHU == true then
			if list.age == 2 and list.looks == 1 and list.sex == 2 and list.qi == 0 then
				return MaskConst.MaskAttrIdList["special_1"]
			elseif  list.age == 2 and list.looks == 2 and list.sex == 2 and list.qi == 0 then
				return MaskConst.MaskAttrIdList["special_2"]
			elseif  list.age == 2 and list.looks == 1 and list.sex == 1 and list.qi == 0 then
				return MaskConst.MaskAttrIdList["special_3"]
			elseif  list.age == 2 and list.looks == 2 and list.sex == 1 and list.qi == 0 then
				return MaskConst.MaskAttrIdList["special_4"]
			elseif  list.age == 0 and list.looks == 0 and list.sex == 1 and list.qi == 1 then
				return MaskConst.MaskAttrIdList["special_5"]
			elseif  list.age == 0 and list.looks == 0 and list.sex == 2 and list.qi == 1 then
				return MaskConst.MaskAttrIdList["special_6"]
			end
		end
	end

	if type(polymorph) == "table" then
		if self:_checkRoleIsPolymorphByParam(polymorph) then
			sex = polymorph.sex
			looks = polymorph.pLooks
			local list = polymorph._yirongSelectList
			if list ~= nil then
				local maskAttrId = getSpecialRongMao(list)
                if maskAttrId ~= nil then
					return MaskResManager:getMaskAttr(maskAttrId)
				end
			end
		end
	end

	if looks < 9 then
		looks = 9
	elseif looks >= 30 and looks < 35 then
		looks = 30
	elseif looks >= 35 and looks < 40 then
		looks = 31
	elseif looks >= 40 and looks < 50 then
		looks = 32
	elseif looks >= 50 and looks < 60 then
		looks = 33
	elseif looks >= 60 and looks < 70 then
		looks = 34
	elseif looks >= 70 and looks < 80 then
		looks = 35
	elseif looks >= 80 and looks < 100 then
		looks = 36
	elseif looks >= 100 then
		looks = 37
	end
	sex = tostring(sex)
	if sex == "男" then
		sex = "nan"
	else
		sex = "nv"
	end
	local maskAttrId = MaskConst.MaskAttrIdList[tostring(sex).."_head"..tostring(looks - 8)]
	return MaskResManager:getMaskAttr(maskAttrId)
end

function HVDPresent:_checkRoleIsPolymorphByParam(polymorph)
	if MapIsEmpty(polymorph) then
		return false
	end

	local currTime = GetTime()
	local endTime = polymorph.endTime
	if endTime == 0 then
		return false
	end
	if currTime - endTime > 0 then
        return false
    end
	return true
end

return newClass("HVDPresent", {}, HVDPresent)0000