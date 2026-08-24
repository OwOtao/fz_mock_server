--[[
    author:Seven
    time:2025-10-21 15:28:42
    desc:
]]
local skin_ui_config = require("script.skin.UISkinlistConfig")["Sheet1"]

local HouseSkin = {}

--@region 背景相关默认配置
-- 背景层的默认图片
local DEFAULT_BACKGROUND_IMAGE = "Image/UI/MainUI/backgurand.jpg"
-- 背景层的场景图的默认图片
local DEFAULT_BASE_IMAGE = "Image/UI/MainUI/changjing01.png"
-- 背景层的默认动态层配置
local DEFAULT_ANIMATION = nil
--@endregion

--@region 输出打印相关配置
local DEFAULT_PRINT_BG_IMAGE = "Image/UI/MainUI/kuangdown.png"
local MAP_PRINT_BG_IMAGE = "Image/UI/MapUI/ding2.png"
--@endregion

local DEFAULT_SKIN_ID = "default"

local currSkinId = DEFAULT_SKIN_ID

-- 对应UISkinlistConfig导出的列对应配置文件名
local LAYERNAME_SKIN_UI_CONFIG_NAME = {
    MainLayer = "mainuiconfig",
    MainTaskPresenter = "guajitaskuiconfig",
    AttrLayer = "baguiconfig",
    SkillInfoLayer = "skilluiconfig",
    TeacherLayer = "familyuiconfig",
    TeacherBuildMenuPresenter = "familybuilduiconfig"
}
--@region 技能界面相关excel配置
LAYERNAME_SKIN_UI_CONFIG_NAME.SkillPrepareLayer = LAYERNAME_SKIN_UI_CONFIG_NAME.SkillInfoLayer
LAYERNAME_SKIN_UI_CONFIG_NAME.ActiveSkillPrepareUI = LAYERNAME_SKIN_UI_CONFIG_NAME.SkillInfoLayer
--@endregion

--@region 师门配置
LAYERNAME_SKIN_UI_CONFIG_NAME.SelectTeacherLayer_type = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherLayer
LAYERNAME_SKIN_UI_CONFIG_NAME.SelectTeacherLayer_family = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherLayer
--@endregion

--@region 师门建设
LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildGuaJiPresenter = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildMenuPresenter
LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildListPresenter = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildMenuPresenter
LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildTaskPresenter = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildListPresenter
LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildInfoPresenter = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildListPresenter
LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildDonatePresenter = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildListPresenter
LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherFeatPresenter = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildListPresenter
LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherFeatClassPresenter = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildListPresenter
LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherGuidancePresenter = LAYERNAME_SKIN_UI_CONFIG_NAME.TeacherBuildListPresenter
--@endregion

HouseSkin.LAYERNAME_SKIN_UI_CONFIG_NAME = LAYERNAME_SKIN_UI_CONFIG_NAME

-- todo : 背景层代码中的硬编码，需后续考虑迁移至策划配置
local P_UI_LAYER_CONFIG = {
    ActionLayer = {
        MainbgPic = nil,
        MainBasePic = nil
    },
    MenuLayer = {
        MainbgPic = "0",
        MainBasePic = nil
    },
    SetupLayer = {
        MainbgPic = "0",
        MainBasePic = "default"
    },
    QuietRoomLayer = {
        MainbgPic = "0",
        MainBasePic = "Image/UI/MainUI/back/taohuadao.png"
    },
    HiddenMeridianMenuPresenter = {
        MainbgPic = "0",
        MainBasePic = nil
    },
    TuJianInFoLayer = {
        MainbgPic = "0",
        MainBasePic = nil
    },
    TuJianMenuLayer = {
        MainbgPic = "0",
        MainBasePic = "Image/UI/MainUI/back/tujian.png"
    },
    SelectMapMenuPresenter = {
        MainbgPic = "Image/UI/PopUI/hesezhezhao.png",
        MainBasePic = nil
    },
    SelectMapLayer = {
        MainbgPic = "Image/UI/MapUI/beijing.png",
        MainBasePic = nil
    },
    MapLayer = {
        MainbgPic = "Image/UI/MapUI/beijing.png",
        MainBasePic = nil
    },
    JiangHuAnecdotePresenter = {
        MainbgPic = nil,
        MainBasePic = nil
    },
    FistFootMenuPresenter = {
        MainbgPic = "0",
        MainBasePic = "sex"
    },
    TechniquePresenter = {
        MainbgPic = "0",
        MainBasePic = nil
    },
    FistFootGuaJiPresenter = {
        MainbgPic = "0",
        MainBasePic = "Image/UI/MainUI/back/xiaoyaopai.png"
    },
    FamilyGroupRankLayer = {
        MainbgPic = "0",
        MainBasePic = "family"
    }
}
-- 设置系统
P_UI_LAYER_CONFIG.SetupLayerInMenuLayer = P_UI_LAYER_CONFIG.SetupLayer

-- 拳脚系统
P_UI_LAYER_CONFIG.FistFootTaskPresenter = P_UI_LAYER_CONFIG.TechniquePresenter
P_UI_LAYER_CONFIG.TalentPagePresenter = P_UI_LAYER_CONFIG.TechniquePresenter
P_UI_LAYER_CONFIG.CharacterInfoPresenter = P_UI_LAYER_CONFIG.TechniquePresenter
P_UI_LAYER_CONFIG.ComprehendCharacterUI = P_UI_LAYER_CONFIG.TechniquePresenter

-- 副本地图
P_UI_LAYER_CONFIG.NewMapLayer = P_UI_LAYER_CONFIG.MapLayer

-- 经脉相关界面背景配置策略
P_UI_LAYER_CONFIG.MeridianBreakLayer = P_UI_LAYER_CONFIG.QuietRoomLayer
P_UI_LAYER_CONFIG.MeridianImprintingPresenter = P_UI_LAYER_CONFIG.QuietRoomLayer

local function from_excel_config(layerName, skinId)
    local configName = LAYERNAME_SKIN_UI_CONFIG_NAME[layerName]
    if not configName then
        return nil
    end

    local skinConfig = skin_ui_config[skinId]
    if not skinConfig then
        skinConfig = skin_ui_config[DEFAULT_SKIN_ID]
    end

    local value = skinConfig[configName]
    if not value then
        return nil
    end

    return require("script.skin." .. tostring(configName))["Sheet1"][value]
end

local function getBackgroundConfigFromLayerName(layerName, skinId)
    local config = from_excel_config(layerName, skinId)

    if config ~= nil then
        return config
    end

    config = P_UI_LAYER_CONFIG[layerName]
    if config ~= nil then
        return config
    end

    return nil
end

-- 根据填写策略来获取背景图片
local function getBackgroundBaseImage(image_strategy)
    if image_strategy == nil then
        return nil
    end

    if image_strategy == "default" then
        -- 使用默认图片
        return DEFAULT_BASE_IMAGE
    end

    if image_strategy == "sex" then
        -- 当前玩家角色性别
        local role = User:getRole()
        if role == nil then
            return "Image/UI/AttrUI/nv.png"
        end

        local sex = role:getAttr("sex")
        if sex == "男" then
            return "Image/UI/AttrUI/nan.png"
        else
            return "Image/UI/AttrUI/nv.png"
        end
    end

    if image_strategy == "family" then
        -- 当前角色玩家门派
        local role = User:getRole()
        if role == nil then
            return "Image/UI/MainUI/back/wudang.png"
        end

        if not role:hasFamily() then
            return "Image/UI/MainUI/back/wudang.png"
        else
            return "Image/UI/MainUI/back/" .. tostring(role:getFamilyId()) .. ".png"
        end
    end

    -- 非策略配置默认为图片路径
    return image_strategy
end

function HouseSkin:getDefaultSkinId()
    return DEFAULT_SKIN_ID
end

function HouseSkin:getDefaultBackgroundImage()
    return DEFAULT_BACKGROUND_IMAGE
end

function HouseSkin:getDefaultBaseImage()
    return DEFAULT_BASE_IMAGE
end

function HouseSkin:setSkinId(skinId)
    if skinId == nil then
        assert(false, "HouseSkin:setSkinId skinId cannot be nil")
    end
    currSkinId = skinId
end

function HouseSkin:getSkinId()
    return currSkinId
end

function HouseSkin:getBackgroundLayerConfig(layerName)
    return self:getBackgroundLayerConfigByCustomSkinId(layerName, currSkinId)
end

function HouseSkin:getBackgroundLayerConfigByCustomSkinId(layerName, skinId)
    local bg_config = {
        MainbgPic = DEFAULT_BACKGROUND_IMAGE,
        MainBasePic = DEFAULT_BASE_IMAGE,
        MainbgAnim = DEFAULT_ANIMATION,
        MainbgShade = 0
    }

    local configs = getBackgroundConfigFromLayerName(layerName, skinId)
    if configs == nil then
        return bg_config
    end

    if configs.MainbgPic ~= "0" then
        -- "0"表示使用默认，nil表示图片不显示
        bg_config.MainbgPic = configs.MainbgPic
    end

    bg_config.MainBasePic = getBackgroundBaseImage(configs.MainBasePic)

    if configs.MainbgAnim ~= nil then
        bg_config.MainbgAnim = configs.MainbgAnim
    end

    -- 遮罩层透明度
    if configs.MainbgShade ~= nil then
        bg_config.MainbgShade = configs.MainbgShade
    end

    return bg_config
end

function HouseSkin:getSkinConfigFromLayerName(layerName)
    return self:getSkinConfigFromLayerNameByCustomSkinId(layerName, currSkinId)
end

function HouseSkin:getSkinConfigFromLayerNameByCustomSkinId(layerName, skinId)
    return getBackgroundConfigFromLayerName(layerName, skinId)
end

--@region 输出打印层相关配置

local P_PRINT_LAYER_CONFIG = {
    MapLayer = {
        OutputPrintBg = MAP_PRINT_BG_IMAGE
    }
}

P_PRINT_LAYER_CONFIG.NewMapLayer = P_PRINT_LAYER_CONFIG.MapLayer

local function getPrintConfigFromLayerName(layerName, skinId)
    local config = from_excel_config(layerName, skinId)

    if config ~= nil then
        return config
    end

    config = P_PRINT_LAYER_CONFIG[layerName]
    if config ~= nil then
        return config
    end

    return nil
end

function HouseSkin:getPrintLayerConfigBySkinId(layerName, skinId)
    local print_config = {
        OutputPrintBg = DEFAULT_PRINT_BG_IMAGE
    }
    local config = getPrintConfigFromLayerName(layerName, skinId)
    if config == nil then
        return print_config
    end

    if config.OutputPrintBg ~= nil then
        print_config.OutputPrintBg = config.OutputPrintBg
    end

    return print_config
end

function HouseSkin:getPrintLayerConfig(layerName)
    return self:getPrintLayerConfigBySkinId(layerName, currSkinId)
end

function HouseSkin:hasPrintLayerCurrentConfig(layerName)
    local config = getPrintConfigFromLayerName(layerName, currSkinId)
    if config == nil then
        return false 
    end

    --@TODO 2026-05-21 14:50:02 暂时只有这个属性，先这么处理着
    if config.OutputPrintBg == nil then
        return false
    end
    
    return true
end
--@endregion

return HouseSkin
000