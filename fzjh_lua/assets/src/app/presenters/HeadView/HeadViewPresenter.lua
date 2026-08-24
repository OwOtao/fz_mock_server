local newClass = require("third.class.NewClass")

local MaskResManager = require("app.models.mask.MaskResManager")

local MaskConst = require("app.models.mask.MaskConst")

local HeadViewBasePresent = require("app.presenters.HeadView.HeadViewBasePresent")

local HeadViewPresenter = {}

function HeadViewPresenter:create(role, ui)
    local p = HeadViewPresenter.new()
    p:__init(role, ui)
    return p
end

function HeadViewPresenter:__init(role, ui)
    --@RefType [src.app.models.role.Role#Role]
    self.__role = role

    --@RefType [HeadView]
    self.__ui = ui

    self:showTheHead()
end

function HeadViewPresenter:showTheHead()
    local borderSys = self.__role:getRoleViewBorderSys()

    self:__setHeadBorder(borderSys:getBorder())

    self:__showHead()
end

function HeadViewPresenter:__showHead()
    local maskAttr = self:__getShowMaskAttr()

    self.__ui:setImageBackgroud(maskAttr:getBackgroundPath())

    if maskAttr:getAnimPath() and maskAttr:getAnimFolderPath() then
        self:__showHeadAnim(maskAttr:getAnimPath(),maskAttr:getAnimFolderPath())
    else
        self:__showHeadImage(maskAttr:getResPath())
    end

    if maskAttr:getEffectPath() then
        self:__showEffectView(maskAttr:getEffectPath())
    else
        self:__hideEffectView()
    end
end

--@desc:
--@author:Seven
--@time:2021-11-23 20:49:34
--@return [src.app.models.mask.MaskAttr#MaskAttr]
function HeadViewPresenter:__getShowMaskAttr()
    local maskAttr = self:__getWearMaskAttr()

    if maskAttr then
        return maskAttr
    end

    maskAttr = self:__getPolymorph()
    if maskAttr then
        return maskAttr
    end

    return self:__getLooksMaskAttr()
end

--@return [src.app.models.mask.MaskAttr#MaskAttr]
function HeadViewPresenter:__getLooksMaskAttr()
    local sex = self.__role:getAttr("sex")
    local looks = self.__role:getAttr("looks")

    local maskAttrId = self:getLookMaskId(looks,sex)
	
	return MaskResManager:getMaskAttr(maskAttrId)
end

--@desc: 获取佩戴的面具信息
--@author:Seven
--@time:2021-11-23 17:16:10
--@return [src.app.models.mask.MaskAttr#MaskAttr]
function HeadViewPresenter:__getWearMaskAttr()
    --@region 兼容某些旧存档，判断装备栏头部是否属于面具
    local equipHead = self.__role:getEquipByName("head")
    local headItemId = nil
    if type(equipHead) == "table" then
        headItemId = equipHead.itemId
    end

    if headItemId then
        local item = self.__role:getOneItemByKey(headItemId)
        if item ~= nil and item.gradeId then
            return MaskResManager:getMaskAttrByMaskIdAndLv(item.gradeId, 1)
        end
    end
    --@endregion

    local maskSystem = self.__role:getMaskSystem()

    local maskId = maskSystem:getPortraitId()

    local maskLv = maskSystem:getPortraitLv()

    if maskId then
        return MaskResManager:getMaskAttrByMaskIdAndLv(maskId, maskLv)
    end

    return nil
end

--@desc: 易容面具
--@author:Seven
--@time:2021-11-23 18:21:25
--@return [src.app.models.mask.MaskAttr#MaskAttr]
function HeadViewPresenter:__getPolymorph()
    local polymorph = self.__role:getAttr("polymorph")
    if type(polymorph) ~= "table" then
        return nil
    end

    if self:__checkRoleInPolymorph(polymorph) then
        local sex = polymorph.sex
        local looks = polymorph.pLooks
        local list = polymorph._yirongSelectList
        if list ~= nil then
            local maskAttrId = self:getSpecialRongMao(list)
            if maskAttrId ~= nil then
                return MaskResManager:getMaskAttr(maskAttrId)
            end
        end

        local maskAttrId = self:getLookMaskId(looks,sex)

        return MaskResManager:getMaskAttr(maskAttrId)
    end

    return nil
end

function HeadViewPresenter:__checkRoleInPolymorph(data)
    if MapIsEmpty(data) then
        return false
    end

    local currTime = GetTime()

    local endTime = data.endTime

    if endTime == 0 then
        return false
    end

    if currTime - endTime > 0 then
        return false
    end

    return true
end

function HeadViewPresenter:__showHeadImage(path)
    self.__ui:setHeadImageVisible(true)

    self.__ui:setHeadImage(path)

    self.__ui:setHeadAnimVisible(false)
end

function HeadViewPresenter:__showHeadAnim(animName,animFolderName)
    self.__ui:setHeadAnimVisible(true)
    self.__ui:showTheHeadAnim(animName,animFolderName)
    self.__ui:setHeadImageVisible(false)
end

function HeadViewPresenter:__setHeadBorder(imgPath)
    self.__ui:setBorderVisible(true)
    self.__ui:setBorderImg(imgPath)
end

function HeadViewPresenter:__showEffectView(effectName)
    self.__ui:setHeadEffectVisible(true)
    self.__ui:playEffect(effectName)
end

function HeadViewPresenter:__hideEffectView()
    self.__ui:setHeadEffectVisible(false)
end

function HeadViewPresenter:setClickEnable(bool)
    self.__ui:setClickEnable(bool)
end

function HeadViewPresenter:setHeadClickFunc(func)
    self.__ui:releaseFunc(
        function()
            func()
        end
    )
end

return newClass("HeadViewPresenter", {HeadViewBasePresent}, HeadViewPresenter)
00000000000