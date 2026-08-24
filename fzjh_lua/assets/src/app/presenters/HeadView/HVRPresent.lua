--[[
	根据角色对象展示头像,背景图和特效
]]
local newClass = require("third.class.NewClass")
local MaskResManager = require("app.models.mask.MaskResManager")
local MaskConst = require("app.models.mask.MaskConst")
local HeadViewBasePresent = require("app.presenters.HeadView.HeadViewBasePresent")
local HVRPresent = {}

function HVRPresent:create(node,diNode,role)
    local p = HVRPresent.new()
	p:init(node,diNode,role)
    return p
end

function HVRPresent:init(node,diNode,role)
    if node:getChildByName("headView") then
		self._headView = node:getChildByName("headView")
    else
        local NewHeadView = require("app.views.ui.HeadView.NewHeadView")
        self._headView = NewHeadView:create(node)
    end
	self._role = role
	self._diNode = diNode
end

function HVRPresent:showHead()
	local head = self:_getMaskAttr():getResPath()

    local headDiPath = self:_getMaskAttr():getBackgroundPath()

	self._headView:showHead(head)

	self:_showHeadDi(headDiPath)
end

function HVRPresent:showAnim()
	local animName = self:_getMaskAttr():getAnimPath()

    local animFolderName = self:_getMaskAttr():getAnimFolderPath()

    if animName == nil or animFolderName == nil then
		self:showHead()
    else
        self._headView:showAnim(animName,animFolderName)
    end
end

function HVRPresent:playEffect()
	local effect = self:_getMaskAttr():getEffectPath()

    self._headView:playEffect(effect)
end

function HVRPresent:_showHeadDi(headDiPath)
    self._diNode:loadTexture(headDiPath)
end

function HVRPresent:_getMaskAttr()
    local sex = self._role:getAttr("sex")
	local looks = self._role:getFinalAttr("looks")
	local equips = self._role:getAttr("equips")
	local portrait = self._role:getAttr("portrait")
	local polymorph = self._role:getAttr("polymorph")

	local headItemId = nil
    if type(equips) == "table" then
		if type(equips.head) == "table" then
			headItemId = equips.head.itemId
		end
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

return newClass("HVRPresent", {HeadViewBasePresent}, HVRPresent)000000000000000