local newClass = require("third.class.NewClass")

local MaskResManager = require("app.models.mask.MaskResManager")

local MaskConst = require("app.models.mask.MaskConst")

local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")

local HeadViewBasePresent = require("app.presenters.HeadView.HeadViewBasePresent")

local HeadDataHeadViewPresenter = {}

function HeadDataHeadViewPresenter:create(headData, ui)
    local p = HeadDataHeadViewPresenter.new()
    p:__init(headData, ui)
    return p
end

function HeadDataHeadViewPresenter:__init(headData, ui)
    self.__headData = headData

    self.__maskAttr = self:_getMaskAttr()

    --@RefType [HeadView]
    self.__ui = ui
end

function HeadDataHeadViewPresenter:showTheHead()
	if self.__maskAttr:getFramePath() then
		self.__ui:setBorderImg(self.__maskAttr:getFramePath())
	else
		self.__ui:setBorderImg(BorderConfigManager:getBorderConf("10000"):getFramePath())
	end

    self.__ui:setImageBackgroud(self.__maskAttr:getBackgroundPath())
    
    local animPath = self.__maskAttr:getAnimPath()

    local animFolderName = self.__maskAttr:getAnimFolderPath()

    if animPath and animFolderName then
        self.__ui:setHeadAnimVisible(true)
        self.__ui:setHeadImageVisible(false)
        self.__ui:showTheHeadAnim(animPath,animFolderName)
    else
        self.__ui:setHeadAnimVisible(false)
        self.__ui:setHeadImageVisible(true)
        self.__ui:setHeadImage(self.__maskAttr:getResPath())
    end

    local effectName = self.__maskAttr:getEffectPath()

    if effectName then
        self.__ui:setHeadEffectVisible(true)
        self.__ui:playEffect(effectName)
    else
        self.__ui:setHeadEffectVisible(false)
    end
end

function HeadDataHeadViewPresenter:_getMaskAttr()
    local sex = self.__headData.sex == nil and "男" or self.__headData.sex
	local looks = tonumber(self.__headData.looks) or 0
    local equipHead = self.__headData.head
	local portrait = self.__headData.portrait
	local polymorph = self.__headData.polymorph

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

function HeadDataHeadViewPresenter:setClickEnable(bool)
    self.__ui:setClickEnable(bool)
end

function HeadDataHeadViewPresenter:setHeadClickFunc(func)
    self.__ui:releaseFunc(
        function()
            func()
        end
    )
end

return newClass("HeadDataHeadViewPresenter", {HeadViewBasePresent}, HeadDataHeadViewPresenter)
0000000000000