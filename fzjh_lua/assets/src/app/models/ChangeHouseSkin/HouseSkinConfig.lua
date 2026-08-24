local configs = require("script.others.houseSkinConfig")["界面部件配置表"]

local HouseSkinConfig = {}

local defaultSkinUIPath = {
    ["MainUI"] = "Layer/MainUI.lua",
    ["AttrUI"] = "Layer/AttrUI/AttrUI.lua",
    ["JiangHuAttrUI"] = "Layer/AttrUI/JiangHuAttrUI.lua",
    ["TaskBtnUI1"] = "Layer/TaskUI/TaskBtnUI1.lua",
    ["TaskBtnUI"] = "Layer/TaskUI/TaskBtnUI.lua",
    ["TableUI"] = "Layer/AttrUI/TableUI.lua",
    ["BagUI"] = "Layer/AttrUI/BagUI.lua"
}

local defaultSkinResPath = "Layer/SkinNewUI/"

function HouseSkinConfig:getMainSkin(id)
    if not configs[id] then
        assert(false,"皮肤配置有问题，皮肤id:"..id)
    end

    local value = configs[id]["Main"]

    if defaultSkinUIPath[value] then
        return defaultSkinUIPath[value]
    end

    print("path:",defaultSkinResPath.."Main/Main"..value..".lua")
    
    return defaultSkinResPath.."Main/Main"..value..".lua"
end

function HouseSkinConfig:getRoleAttrSkin(id)
    if not configs[id] then
        assert(false,"皮肤配置有问题，皮肤id:"..id)
    end

    local value = configs[id]["RoleAttr"]

    if defaultSkinUIPath[value] then
        return defaultSkinUIPath[value]
    end

    print("path:",defaultSkinResPath.."RoleAttr/RoleAttr"..value..".lua")
    
    return defaultSkinResPath.."RoleAttr/RoleAttr"..value..".lua"
end

function HouseSkinConfig:getJiangHuSkin(id)
    if not configs[id] then
        assert(false,"皮肤配置有问题，皮肤id:"..id)
    end
    
    local value = configs[id]["JiangHu"]

    if defaultSkinUIPath[value] then
        return defaultSkinUIPath[value]
    end

    print("path:",defaultSkinResPath.."JiangHu/JiangHu"..value..".lua")
    
    return defaultSkinResPath.."JiangHu/JiangHu"..value..".lua"
end

function HouseSkinConfig:getRoleAttrTabSkin(id)
    if not configs[id] then
        assert(false,"皮肤配置有问题，皮肤id:"..id)
    end

    local value = configs[id]["RoleAttrTab"]

    if defaultSkinUIPath[value] then
        return defaultSkinUIPath[value]
    end

    print("path:",defaultSkinResPath.."RoleAttrTab/RoleAttrTab"..value..".lua")
    
    return defaultSkinResPath.."RoleAttrTab/RoleAttrTab"..value..".lua"
end

function HouseSkinConfig:getGuaJiTaskSkin(id)
    if not configs[id] then
        assert(false,"皮肤配置有问题，皮肤id:"..id)
    end

    local value = configs[id]["GuaJiTask"]

    if defaultSkinUIPath[value] then
        return defaultSkinUIPath[value]
    end

    print("path:",defaultSkinResPath.."GuaJiTask/GuaJiTask"..value..".lua")
    
    return defaultSkinResPath.."GuaJiTask/GuaJiTask"..value..".lua"
end

function HouseSkinConfig:getLiLianTaskSkin(id)
    if not configs[id] then
        assert(false,"皮肤配置有问题，皮肤id:"..id)
    end
    
    local value = configs[id]["LiLianTask"]

    if defaultSkinUIPath[value] then
        return defaultSkinUIPath[value]
    end
    
    print("path:",defaultSkinResPath.."LiLianTask/LiLianTask"..value..".lua")

    return defaultSkinResPath.."LiLianTask/LiLianTask"..value..".lua"
end

function HouseSkinConfig:getBagSkin(id)
    if not configs[id] then
        assert(false,"皮肤配置有问题，皮肤id:"..id)
    end
    
    local value = configs[id]["BagUI"]

    if defaultSkinUIPath[value] then
        return defaultSkinUIPath[value]
    end
    
    print("path:",defaultSkinResPath.."Bag/Bag"..value..".lua")

    return defaultSkinResPath.."Bag/Bag"..value..".lua"
end

function HouseSkinConfig:setCurrSkinId(skinId)
    self.__currSkinId = skinId
end

function HouseSkinConfig:getCurrSkinId()
    return self.__currSkinId
end

function HouseSkinConfig:getSkinAnimResPath()
    if self.__currSkinId == "uijiemian5" then
        return "Anim/UIAnim/skin/skin5/"
    end
end

function HouseSkinConfig:getSkinAnimName()
    if self.__currSkinId == "uijiemian5" then
        return "canghuangui"
    end
end

local showBgConfig = {
    ["uijiemian3"] = {
        ["MainLayer"] = true
    },

    ["uijiemian5"] = {
        ["MainLayer"] = true,
        ["AttrLayer"] = true,
        ["BagLayer"] = true,
        ["MainTaskPresenter"] = true,
    },
}
--[[
    @desc: 当前皮肤界面是否有展示自身背景
    author:tanqinjian
    time:2025-03-19 20:19:31
    --@layerName: 当前界面
    @return: true 则需要取消游戏backLayer动作
]]
function HouseSkinConfig:isShowBg(layerName)
    if not layerName then
        return false
    end
    
    if showBgConfig[self.__currSkinId] then
        local config = showBgConfig[self.__currSkinId]
        return config[layerName]
    end

    return false
end

return HouseSkinConfig000000000000000