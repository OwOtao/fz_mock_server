--[[
	根据性别，容貌，装备，头像，易容术数据展示 头像,背景图 和播放特效
]]
local newClass = require("third.class.NewClass")
local MaskResManager = require("app.models.mask.MaskResManager")
local MaskConst = require("app.models.mask.MaskConst")
local HeadViewBasePresent = require("app.presenters.HeadView.HeadViewBasePresent")
local HVPPresent = {}

function HVPPresent:create(node,diNode,data)
    local p = HVPPresent.new()
	p:init(node,diNode,data)
    return p
end

function HVPPresent:init(node,diNode,data)
    if node:getChildByName("headView") then
		self._headView = node:getChildByName("headView")
    else
        local NewHeadView = require("app.views.ui.HeadView.NewHeadView")
        self._headView = NewHeadView:create(node)
    end
    self._data = data
    self._diNode = diNode
end

function HVPPresent:showHead()
    local head = self:_getMaskAttr():getResPath()

    self._headView:showHead(head)

	local headDiPath = self:_getMaskAttr():getBackgroundPath()
	
	self._diNode:loadTexture(headDiPath)
end

function HVPPresent:showAnim()
    local animName = self:_getMaskAttr():getAnimPath()

    local animFolderName = self:_getMaskAttr():getAnimFolderPath()

    if animName == nil or animFolderName == nil then
		self:showHead()
    else
        self._headView:showAnim(animName,animFolderName)

		local headDiPath = self:_getMaskAttr():getBackgroundPath()
	
		self._diNode:loadTexture(headDiPath)
    end
end

function HVPPresent:playEffect()
    local effect = self:_getMaskAttr():getEffectPath()

    self._headView:playEffect(effect)
end

function HVPPresent:_getMaskAttr()
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

return newClass("HVPPresent", {HeadViewBasePresent}, HVPPresent)0000000000000