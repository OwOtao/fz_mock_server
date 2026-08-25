--[[
    商品重复购买检索详情展示
]]
local GoodsDuplicatePurchasePresenter = class("GoodsDuplicatePurchasePresenter", cc.Layer)

local FLOW_TYPE = {
    BLOCK = "block",
    CONTINUE = "continue"
}

local PROMPT_TEXT = {
    [FLOW_TYPE.BLOCK] = "已满足以下条件，无法继续购买：",
    [FLOW_TYPE.CONTINUE] = "已满足以下条件，是否确认继续购买："
}

local CONTINUE_TIPS_TEXT = [[一般情况下若继续购买商品，获得的道具将无法使用。存在特殊情况，举例如下：
1.若已学习武学，继续购买武学宝箱，打开会获得对应武学残篇，使用后会增加相应的武学经验
2.若重复购买的面具/挂饰，可在家园-绣女处分解获得饰品材料
3.若提示道具即将/已经达到可持有上限，继续兑换将会溢出，溢出的道具会通过邮件发放，但邮件过期将无法领取]]

local isValidFlowType = function(flowType)
    return flowType == FLOW_TYPE.BLOCK or flowType == FLOW_TYPE.CONTINUE
end

local getGoodsNameText = function(goodsInfo)
    local goodsName = goodsInfo.goodsName or goodsInfo.goodsId

    assert(goodsName ~= nil, "GoodsDuplicatePurchasePresenter:getGoodsNameText() - goodsName is nil")

    return tostring(goodsName) .. "："
end

local getGoodsDescText = function(goodsInfo)
    assert(not MapIsEmpty(goodsInfo.hitResults), "GoodsDuplicatePurchasePresenter:getGoodsDescText() - hitResults is empty")

    local textList = {}

    for _, hitInfo in ipairs(goodsInfo.hitResults) do
        if hitInfo.msg ~= nil and tostring(hitInfo.msg) ~= "" then
            table.insert(textList, tostring(hitInfo.msg))
        end
    end

    assert(#textList > 0, "GoodsDuplicatePurchasePresenter:getGoodsDescText() - msg is empty")

    return table.concat(textList, "\n")
end

function GoodsDuplicatePurchasePresenter:create()
    local p = GoodsDuplicatePurchasePresenter:new()
    p:init()
    return p
end

function GoodsDuplicatePurchasePresenter:init()
    self.__ui = require("app.views.ui.GoodsInfoUI.GoodsDuplicatePurchaseUI"):create()
    self.__ui:addTo(self)
end

function GoodsDuplicatePurchasePresenter:getUI()
    return self.__ui
end

--[[
    params = {
        searchInfo = GoodsHelper 检索返回结构,
        flowType = "block" | "continue",
        onBack = function() end,
        onConfirm = function() end
    }
]]
function GoodsDuplicatePurchasePresenter:showLayer(params)
    assert(params ~= nil, "GoodsDuplicatePurchasePresenter:showLayer() - params is nil")
    assert(params.searchInfo ~= nil, "GoodsDuplicatePurchasePresenter:showLayer() - searchInfo is nil")
    assert(not MapIsEmpty(params.searchInfo.goodsResults), "GoodsDuplicatePurchasePresenter:showLayer() - goodsResults is empty")
    assert(isValidFlowType(params.flowType), "GoodsDuplicatePurchasePresenter:showLayer() - unsupported flowType : " .. tostring(params.flowType))
    assert(params.onBack == nil or type(params.onBack) == "function", "GoodsDuplicatePurchasePresenter:showLayer() - onBack must be function")
    assert(params.onConfirm == nil or type(params.onConfirm) == "function", "GoodsDuplicatePurchasePresenter:showLayer() - onConfirm must be function")

    self.__flowType = params.flowType
    self.__onBack = params.onBack
    self.__onConfirm = params.onConfirm

    self.__ui:clearGoodsResultList()
    self.__ui:setPromptText(PROMPT_TEXT[self.__flowType])
    self.__ui:setContinueTipsText(self.__flowType == FLOW_TYPE.CONTINUE and CONTINUE_TIPS_TEXT or nil)

    self:__initGoodsResults(params.searchInfo.goodsResults)
    self:__initButtons()

    self.__ui:showUI()
end

function GoodsDuplicatePurchasePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "GoodsDuplicatePurchasePresenter",
        function(layer)
            layer.__ui:hideUI()
        end
    )
end

function GoodsDuplicatePurchasePresenter:__initGoodsResults(goodsResults)
    for _, goodsInfo in ipairs(goodsResults) do
        self.__ui:addGoodsResultItem(getGoodsNameText(goodsInfo), getGoodsDescText(goodsInfo))
    end

    self.__ui:jumpGoodsResultListToTop()
end

function GoodsDuplicatePurchasePresenter:__initButtons()
    self.__ui:setBackButton(
        function()
            local onBack = self.__onBack

            self:hideLayer()

            if onBack then
                onBack()
            end
        end
    )

    self.__ui:setConfirmButton(
        function()
            local onConfirm = self.__onConfirm

            self:hideLayer()

            if onConfirm then
                onConfirm()
            end
        end
    )

    self.__ui:setBackButtonVisible(true)
    self.__ui:setConfirmButtonVisible(self.__flowType == FLOW_TYPE.CONTINUE)
end

Helper:classDefNodeGetInstance(GoodsDuplicatePurchasePresenter)

return GoodsDuplicatePurchasePresenter
0