--[[
	根据性别，容貌，装备，头像，易容术数据展示头像和播放特效
]]
local newClass = require("third.class.NewClass")
local MaskResManager = require("app.models.mask.MaskResManager")
local MaskConst = require("app.models.mask.MaskConst")
local HeadViewBasePresent = require("app.presenters.HeadView.HeadViewBasePresent")
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
    local head = self:_getMaskAttr():getResPath()
    self._headView:showHead(head)
end

function HVDPresent:showAnim()
    local animName = self:_getMaskAttr():getAnimPath()

	local animFolderName = self:_getMaskAttr():getAnimFolderPath()
    
	self._headView:showAnim(animName,animFolderName)
end

function HVDPresent:playEffect()
    local effect = self:_getMaskAttr():getEffectPath()

    self._headView:playEffect(effect)
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

	if type(polymorph) == "table" then
		if self:checkIsPolymorphByParam(polymorph) then
			sex = polymorph.sex
			looks = polymorph.pLooks
			local list = polymorph._yirongSelectList
			if list ~= nil then
				local maskAttrId = self:getSpecialRongMao(list)
                if maskAttrId ~= nil then
					return MaskResManager:getMaskAttr(maskAttrId)
				end
			end
		end
	end

	local maskAttrId = self:getLookMaskId(looks,sex)

	return MaskResManager:getMaskAttr(maskAttrId)
end

return newClass("HVDPresent", {HeadViewBasePresent}, HVDPresent)0000