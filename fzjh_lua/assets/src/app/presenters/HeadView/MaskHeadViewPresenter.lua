--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-09-23 17:28:25
--]]
local newClass = require("third.class.NewClass")

local IHeadViewPresenter = require("app.presenters.HeadView.IHeadViewPresenter")

local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")

local MaskHeadViewPresenter = {}

function MaskHeadViewPresenter:create(maskAttr, ui)
    local p = MaskHeadViewPresenter.new()
    p:__init(maskAttr, ui)
    return p
end

function MaskHeadViewPresenter:__init(maskAttr, ui)
    --@RefType [src.app.models.mask.MaskAttr#MaskAttr]
    self.__maskAttr = maskAttr

    --@RefType [HeadView]
    self.__ui = ui
end

function MaskHeadViewPresenter:showTheHead()
    local animPath = self.__maskAttr:getAnimPath()

    local framePath = self.__maskAttr:getFramePath()

    if framePath == nil then
        framePath = BorderConfigManager:getBorderConf("10000"):getFramePath()
    end

    self.__ui:setBorderImg(framePath)

    self.__ui:setImageBackgroud(self.__maskAttr:getBackgroundPath())

    local animFolderPath = self.__maskAttr:getAnimFolderPath()

    if animPath and animFolderPath then
        self.__ui:setHeadAnimVisible(true)
        self.__ui:setHeadImageVisible(false)
        self.__ui:showTheHeadAnim(animPath,animFolderPath)
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

return newClass("MaskHeadViewPresenter", {IHeadViewPresenter}, MaskHeadViewPresenter)
00000000