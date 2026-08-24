--[[
    author:Seven
    time:2025-10-17 16:04:50
    desc:
]]
local BackgroundLayer = class("BackgroundLayer", cc.Layer)

local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")

local BACKGROUND_IMAGE_LAYER = -4
local BACKGROUND_BASE_IMAGE_LAYER = -3
local BACKGROUND_ANIMATION_LAYER = -2
local BACKGROUND_SHADE_LAYER = -1

function BackgroundLayer:create()
    return BackgroundLayer:new():init()
end

function BackgroundLayer:init()
    -- 当前背景配置
    self.__bgPic = HouseSkin:getDefaultBackgroundImage()
    self.__currBgNodeUI = self:__newBackPicImageNode(self.__bgPic)

    -- 当前场景图配置
    self.__basePic = nil
    self.__currBasePicNodeUI = nil

    -- 当前背景动画层配置
    self.__baseAnim = nil
    self.__currBaseAnimNodeUI = nil

    -- 遮罩层
    local shadeLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
    shadeLayer:setLocalZOrder(BACKGROUND_SHADE_LAYER)
    shadeLayer:addTo(self)
    shadeLayer:setContentSize(display.width, display.height)
    shadeLayer:setPosition(0, 0)
    self.__shadeLayer = shadeLayer

    self:setVisible(false)

    return self
end

function BackgroundLayer:__newBackPicImageNode(image)
    local node = cc.Sprite:create(image)
    if node == nil then
        assert(false, "背景图片加载失败:" .. tostring(image))
    end
    node:setPosition(display.cx, display.cy)
    node:addTo(self)
    node:setLocalZOrder(BACKGROUND_IMAGE_LAYER)
    return node
end

function BackgroundLayer:__newBasePicImageNode(image)
    local node = cc.Sprite:create(image)
    if node == nil then
        -- assert(false, "背景场景图片加载失败:" .. tostring(image))
        node = cc.Sprite:create(HouseSkin:getDefaultBaseImage())
    end
    node:setAnchorPoint(0, 0)
    node:setPosition(0, 0)
    node:addTo(self)
    node:setLocalZOrder(BACKGROUND_BASE_IMAGE_LAYER)
    return node
end

-- 切换背景图片
function BackgroundLayer:__switchBackPicImage(image)
    if image == nil then
        self.__bgPic = nil
        self.__currBgNodeUI:setVisible(false)
        return
    end

    self.__currBgNodeUI:setVisible(true)
    if self.__bgPic ~= image then
        -- 直接换图
        self.__currBgNodeUI:setTexture(image)
        self.__bgPic = image
        return
    end
end

function BackgroundLayer:__switchAnimLayer(anim_path)
    if self.__baseAnim == anim_path then
        -- 如果与当前动画相同则不切换
        return
    end

    self.__baseAnim = anim_path

    if anim_path == nil and self.__currBaseAnimNodeUI ~= nil then
        self.__currBaseAnimNodeUI:removeFromParent()
        self.__currBaseAnimNodeUI = nil
        return
    end

    -- 移除当前动画节点
    if self.__currBaseAnimNodeUI ~= nil then
        self.__currBaseAnimNodeUI:removeFromParent()
        self.__currBaseAnimNodeUI = nil
    end

    local anim_info = string.split(anim_path, ";")

    if #anim_info ~= 2 then
        return
    end
    local filePath = anim_info[1]

    self.__currBaseAnimNodeUI = assert(spine38.NewSkeletonAnimation:createWithBinaryFile(filePath .. ".skel", filePath .. ".atlas", 1), "背景动画加载失败:" .. tostring(anim_path))

    self.__currBaseAnimNodeUI:setPosition(display.cx, display.cy)
    self.__currBaseAnimNodeUI:addTo(self)
    self.__currBaseAnimNodeUI:setLocalZOrder(BACKGROUND_ANIMATION_LAYER)

    self.__currBaseAnimNodeUI:setAnimation(0, anim_info[2], true)
end

-- 切换场景图
function BackgroundLayer:__switchBasePicImage(image, duration)
    if self.__currBasePicNodeUI == nil then
        if image == nil then
            return
        end

        self.__currBasePicNodeUI = self:__newBasePicImageNode(image)
        self.__basePic = image
        self:setVisible(true)
        return
    end

    local duration = duration / 2

    -- 动画切换，先向下移动出屏幕，再更换图片，再向上移动进屏幕
    local imgHeight = self.__currBasePicNodeUI:getContentSize().height
    local moveOut = cc.MoveTo:create(duration, cc.p(0, -imgHeight))
    local moveIn = cc.MoveTo:create(duration, cc.p(0, 0))

    local seq = nil
    if self.__basePic ~= image then
        if image ~= nil then
            local changeImage =
                cc.CallFunc:create(
                function()
                    -- 检查文件是否存在
                    if not cc.FileUtils:getInstance():isFileExist(image) then
                        LogSystem:log("error : 图片不存在 ， " .. image)
                        image = HouseSkin:getDefaultBaseImage()
                    end

                    local t = self.__currBasePicNodeUI:setTexture(image)
                    self.__basePic = image
                end
            )
            seq = cc.Sequence:create(moveOut, changeImage, moveIn)
            self.__currBasePicNodeUI:runAction(seq)
        else
            local removeNode =
                cc.CallFunc:create(
                function()
                    self.__currBasePicNodeUI:removeFromParent()
                    self.__currBasePicNodeUI = nil
                    self.__basePic = nil
                end
            )
            seq = cc.Sequence:create(moveOut, removeNode)
            self.__currBasePicNodeUI:runAction(seq)
        end
    else
        -- seq = cc.Sequence:create(moveOut, moveIn)
    end
end

--
function BackgroundLayer:__updateShadeLayer(opacity)
    -- 将百分比（0-100）转换为实际透明度值（0-255）
    local actualOpacity = math.floor(opacity * 255 / 100)
    self.__shadeLayer:setOpacity(actualOpacity)
end

function BackgroundLayer:switchTo(toName)
    local skinConfig = HouseSkin:getBackgroundLayerConfig(toName)
    return self:__show(skinConfig)
end

function BackgroundLayer:__show(skinConfig)
    self:__switchBackPicImage(skinConfig.MainbgPic)

    self:__switchBasePicImage(skinConfig.MainBasePic, 0.3)

    self:__switchAnimLayer(skinConfig.MainbgAnim)

    self:__updateShadeLayer(skinConfig.MainbgShade)
end

function BackgroundLayer:showBackground(toName, skinId)
    local skinConfig = HouseSkin:getBackgroundLayerConfigByCustomSkinId(toName, skinId)
    return self:__show(skinConfig)
end

return BackgroundLayer
00000000