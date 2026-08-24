local ChallengeMapFinishPresenter = class("ChallengeMapFinishPresenter", cc.Layer)
local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local Role = require("app.models.role.Role")

function ChallengeMapFinishPresenter:create()
    local p = ChallengeMapFinishPresenter:new()
    p:init()
    return p
end

function ChallengeMapFinishPresenter:init()
    self._UI = require("app.views.ui.ChallengeMapUI.ChallengeMapFinishUI"):create()
    self._UI:addTo(self)

    self._UI:hideUI()
end

function ChallengeMapFinishPresenter:showLayer(itemList,tips)
    self:setTextTitle()
    self:setTextDesc()
    self:setTextTips()
    self:setListViewReward(itemList)
    self._UI:showUI()
end

function ChallengeMapFinishPresenter:setRole(role)
    self._role = role
end

function ChallengeMapFinishPresenter:setButtonLeave(text, callback)
    self._UI:setButtonLeave(
        text,
        function()
            if callback then
                callback()
            end
        end
    )
end

function ChallengeMapFinishPresenter:setTextTitle()
    self._UI:setTextTitle("恭喜通关")
end

function ChallengeMapFinishPresenter:setTextDesc()
    self._UI:setTextDesc("恭喜成功通关此副本，并且获得如下奖励：")
end

function ChallengeMapFinishPresenter:setTextTips(text)
    self._UI:setTextTips(text)
end

function ChallengeMapFinishPresenter:setListViewReward(rewardArray)
    local retList = {}

    for i, reward in ipairs(rewardArray) do
        local id = reward.id
        local num = reward.num
        local rewardType = reward.type
        local rewardText = ""

        if rewardType == ChallengeMapConstant.RewardType.Loc_Item then
            local itemName = Item:getOneItemByKey(id).name
            rewardText = itemName .. "*" .. num
        elseif rewardType == ChallengeMapConstant.RewardType.Loc_Attr then
            local attrName = Role:getCHAttrName(id)
            rewardText = attrName .. "*" .. num
        elseif rewardType == ChallengeMapConstant.RewardType.net_Res then
            local attrName = Role:getCHAttrName(id)
            rewardText = attrName .. "*" .. num
        elseif rewardType == ChallengeMapConstant.RewardType.BasicTitle then
            local basicTitle = RoleTitleResManager:getBasicTitleClassById(id)
            rewardText = basicTitle:getText() .. "*" .. num
        else
            if DEBUG_MODE == 1 then
                assert(false, "未知奖励类型" .. rewardType)
            end
        end
        table.insert(retList, {rewardText = rewardText})
    end

    self._UI:setListViewReward(retList)
end

function ChallengeMapFinishPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ChallengeMapFinishPresenter",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ChallengeMapFinishPresenter)
return ChallengeMapFinishPresenter
0000000000