local class = require("third.class.NewClass")
local WareHousePresentrs = {}

function WareHousePresentrs:create(iView,iModel)
    local p = WareHousePresentrs:new()
    p:init(iView,iModel)
    return p
end

function WareHousePresentrs:init(iView,iModel)
    self.__model = iModel
    self.__ui = iView
end

function WareHousePresentrs:setRole(role)
    self.__model:setRole(role)
end

function WareHousePresentrs:getRole()
    return self.__model:getRole()
end

function WareHousePresentrs:setRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function WareHousePresentrs:showLayer()
    self.__model:getActionInfo(function()
        self.__ui:showLayer(function()
            self.__ui:showUI()
            self:__initUI()
        end)
    end)
end

function WareHousePresentrs:__initUI()
    self.__showAnim = false

    self.__randomRewardPanelState = {}

    self.__ui:setButtonBack(function()
        self.__ui:hideLayer(function()
            self.__ui:hideUI()
        end)
    end)

    self.__ui:setButtonRuleFunc(function()
        self:__showRule()
    end)

    self.__ui:setButtonSecretFunc(function()
        self:__showAccess()
    end)

    self.__ui:setButtonBatchFunc(function()
        self:__showBatch()
    end)

    self.__ui:setTextTitle(self.__model:getActionName())

    self.__ui:setTextDesc(self.__model:getActionDesc())

    self.__ui:setTextTitle(self.__model:getActionName())

    self.__ui:setText1Str("拥有密钥："..self.__model:getSecretNum1())

    self.__ui:setText2Str("已使用密钥："..self.__model:getSecretNum2())

    self.__ui:setTextFloorNum("当前地仓层数：第"..Helper:numberCast(self.__model:getFloorNum()).."层")

    self:__createProgressPanel()

    self:__initProgressPanel()

    self:__initRandomPanel()
end

function WareHousePresentrs:__createProgressPanel()
    local rewardNum = self.__model:getProgressAwardNum()
    local firstPosX = 1080/rewardNum - 80

    for i = 1, rewardNum, 1 do
        local posX = firstPosX + (i - 1) * (1080/rewardNum - 15)
        local posY = 1390
        self.__ui:createProgressPanel(i, cc.p(posX, posY))
    end
end

function WareHousePresentrs:__initProgressPanel()
    local rewardNum = self.__model:getProgressAwardNum()
    
    local states = self.__model:getProgressAwardStates()

    local progressIndex = 0
    
    for i = 1, rewardNum do
        local progressAwardRes = self.__model:getProgressAwardRes(i)
        local condition = progressAwardRes.condition
        local imageresources = progressAwardRes:getIcon()
        local state = states[i]

        local imageDiKuang = "Image/UI/ActionUI/wupingkuang-1.png"
        local panelDiViseble = true
        local imageStateViseble = true
        local text1 = ""
        local text2 = ""
        local func = EMPTY_FUNC

        if state == 0 then
            imageDiKuang = "Image/UI/ActionUI/wupingkuang-1.png"
            panelDiViseble = true
            imageStateViseble = false
            text1 = condition.."把密钥"
            text2 = "X"..progressAwardRes.num
            func = function()
                PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                    layer:showLayer({{id = progressAwardRes:getId()}})
                end)
            end
        elseif state == 1 then
            imageDiKuang = "Image/UI/ActionUI/wupingkuang-2.png"
            panelDiViseble = false
            imageStateViseble = false
            text1 = condition.."把密钥"
            text2 = "X"..progressAwardRes.num
            progressIndex = i
            func = function()
                local isEmail = self.__model:checkCanGetReward({{id = progressAwardRes:getId(), num = progressAwardRes.num}}) == false and 1 or 0

                local awardId = i

                self.__model:getAward({i}, 1, {awardId}, isEmail, function(result, awardIds, msg)
                    if result == true then
                        self:__initProgressPanel()

                        if msg then
                            self.__ui:popText(msg)
                        end
                    else
                        if msg then
                            self.__ui:popText(msg)
                        end
                    end
                end)
            end
        elseif state == 2 then
            imageDiKuang = "Image/UI/ActionUI/wupingkuang-1.png"
            panelDiViseble = true
            imageStateViseble = true
            progressIndex = i
            func = function()
                self.__ui:popText("已领取过该奖励")
            end
        end

        local retData = {
            Image_item = imageresources,
            Image_diKuang = imageDiKuang,
            Panel_diViseble = panelDiViseble,
            Image_stateViseble = imageStateViseble,
            text1 = text1,
            text2 = text2,
            func = func,
        }
        self.__ui:setProgressPanel(i,retData)
    end
    self.__ui:setLoadingBarPercent(progressIndex*(100 / rewardNum))
end

function WareHousePresentrs:__initRandomPanel()
    local awards = self.__model:getRandomAwards()
    for i = 1,9 do
        local buttonState = 0
        if awards[i].state == 0 then
            buttonState = 0
        else
            local awardId = awards[i].awardId
            local progressAwardRes = self.__model:getRandomAwardRes(awardId)
            if progressAwardRes.gifttype == 1 then
                buttonState = 1
            else
                buttonState = 2
            end 
        end
        local func = EMPTY_FUNC
        func = function()
            if self.__showAnim then
                return
            end

            local state = awards[i].state
            if state == 0 then
                if self.__model:getSecretNum1() < 1 then
                    self.__ui:popText("密钥数量不足，可点击【获取密钥】按钮查看密钥获取方式")
                    return
                end

                self.__model:drawLucky({i},function(result, awardIds, msg)
                    if result then
                        if msg then
                            self.__ui:popText(msg, 0.5)
                        end

                        local progressAwardRes = self.__model:getRandomAwardRes(awards[i].awardId)
                       
                        if progressAwardRes.gifttype == 1 then
                            self.__ui:playAnimHong(i)
                        elseif progressAwardRes.gifttype == 2 then
                            self.__ui:playAnimLan(i)
                        else
                            self.__ui:playAnimHui(i)
                        end

                        self.__randomRewardPanelState[i] = true
    
                        self.__ui:setText1Str("拥有密钥："..self.__model:getSecretNum1())
    
                        self.__ui:setText2Str("已使用密钥："..self.__model:getSecretNum2())

                        self:__initProgressPanel()
                    else
                        if msg then
                            self.__ui:popText(msg)
                        end
                    end
                end)
            else
                local awards = self.__model:getRandomAwards()
                local awardId = awards[i].awardId
                local progressAwardRes = self.__model:getRandomAwardRes(awardId)
                if progressAwardRes.gifttype == 1 then
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:hide()
                    dialog:show("进入下一层后将无法返回，是否确定进入下一层？")
                    dialog:setButton1("确定",function()
                        self:__enterNextFloor()
                    end)
                    dialog:setButton2("关闭",EMPTY_FUNC)
                    dialog:setWeChatVisible(false)
                else
                    self.__ui:popText("已领取过该奖励")
                end 
            end
        end

        local retData = {
            buttonState = buttonState,
            func = func,
        }

        self.__randomRewardPanelState[i] = buttonState ~= 0
        self.__ui:setAwardPanel(i,retData)
    end
end

function WareHousePresentrs:__showBatch()
    if self.__model:getSecretNum1() < 1 then
        self.__ui:popText("密钥数量不足，可点击【获取密钥】按钮查看密钥获取方式")
        return
    end

    local awards = self.__model:getRandomAwards()

    local indexList = {}

    for i = 1, 9, 1 do
        if self.__randomRewardPanelState[i] == false and awards[i].state == 0 then
            table.insert(indexList, i)
        end
    end

    local count = #indexList

    if count < 1 then
        self.__ui:popText("本层府库已全部开启，请进入下一层")
        return
    end

    local getCount = 9 - count

    if count > self.__model:getSecretNum1() then
        count = self.__model:getSecretNum1()

        for i = #indexList, count + 1, -1 do
            table.remove(indexList, i)
        end
    end

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:show("当前已开启"..getCount.."个府库，即将消耗"..count.."个密钥开启"..count.."个府库")
    dialog:setButton1("确定", function()
        if MapIsEmpty(indexList) == false then
            self.__showAnim = true

            self.__model:drawLucky(indexList,function(result, awardIds, msg)
                if result then
                    if MapIsEmpty(awardIds) == false then
                        for i = 1, #awardIds, 1 do
                            local reward = self.__model:getRandomAwardRes(awardIds[i])

                            if reward.gifttype == 1 then
                                self.__ui:playAnimHong(indexList[i])
                            elseif reward.gifttype == 2 then
                                self.__ui:playAnimLan(indexList[i])
                            else
                                self.__ui:playAnimHui(indexList[i])
                            end
                
                            self.__randomRewardPanelState[indexList[i]] = true
                        end
                    end
        
                    if msg then
                        self.__ui:popText(msg, 0.5)
                    end
        
                    self.__ui:setText1Str("拥有密钥："..self.__model:getSecretNum1())
        
                    self.__ui:setText2Str("已使用密钥："..self.__model:getSecretNum2())
        
                    self:__initProgressPanel()
                else
                    if msg then
                        self.__ui:popText(msg)
                    end
                end

                self.__ui:delayFunc(1, function()
                    self.__showAnim = false
                end)
            end)
        end
    end)
    dialog:setButton2("取消", function()
        dialog:hide()
    end)
    dialog:setWeChatVisible(false)
    
end

function WareHousePresentrs:__enterNextFloor()
    self.__model:enterNextFloor(function(result,text)
        if result then
            self.__randomRewardPanelState = {}

            self.__ui:setTextFloorNum("当前地仓层数：第"..Helper:numberCast(self.__model:getFloorNum()).."层")

            self:__initRandomPanel()
        else
            self.__ui:popText(text)
        end
    end)
end

function WareHousePresentrs:__showAccess()
    PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("密钥获取")
        layer:showPanel_1(self.__model:getAccess())
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

function WareHousePresentrs:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end


return class("WareHousePresentrs", {}, WareHousePresentrs)

000000