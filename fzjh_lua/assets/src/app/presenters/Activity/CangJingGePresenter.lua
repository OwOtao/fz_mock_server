local CangJingGePresenter = class("CangJingGePresenter", cc.Layer)

function CangJingGePresenter:create()
    local p = CangJingGePresenter:new()
    p:init()
    return p
end

local InitEvent = {
    GetInfo = 0,    --初始化信息
    Refresh = 1     --元宝刷新
}

function CangJingGePresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.CangJingGeUI"):create()

    self._actionUI:addTo(self)

    local CangJingGe = require("app.models.Action.CangJingGe")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    self._interactor = CangJingGe:create()
end

function CangJingGePresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function CangJingGePresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)

    self._level = 1
    
    self:__initData()
end

function CangJingGePresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function CangJingGePresenter:__initData()
    self._interactor:init(InitEvent.GetInfo, self._level,
        function()
            self._actionUI:setTextTitle(self._interactor:getActionName())

            self._actionUI:setDesc(self._interactor:getActionDesc())

            self._actionUI:setText1Color({r = 255, g = 235, b = 57})
            
            self:refreshUI()

            self:__initPanelButtonFunc()

            self:__initPanelButtonTexture()

            self._actionUI:showInfoListView(self._interactor:getRewardPoolList())

            self._actionUI:setPanelInfoFunc(function()
                self._actionUI:setPanelInfoVisible(false)
            end)

            self._actionUI:setPanelInfoBtnFunc(function()
                self._actionUI:setPanelInfoVisible(true)
            end)

            if self._interactor:checkIsMaxBuyTimes() then
                self._actionUI:setButton1TouchEnable(false)
                self._actionUI:setButton1Texture("Image/UI/TaskUI/anniuhui.png")
            end

            self._actionUI:setButton1Name("刷新")

            self._actionUI:showUI()
        end
    )
end

function CangJingGePresenter:refreshUI()
    self._actionUI:setText1("活动期间已购买道具："..self._interactor:getBuyTimes().."次")
    self:__setRefreshYuanBaoText()
    self:__setText3()
    self:__setText4()
    self:__yuanBaoRefreshFunc()
    self:__showListView()
end

function CangJingGePresenter:__setRefreshYuanBaoText()
    if self._interactor:isYaShi() and self._interactor:getRefreshCost() > 0 then
        self._actionUI:setText2("")
        self._actionUI:setText5("本次花费"..self._interactor:getRefreshCost()..self._interactor:getRefreshCostCNName())
    else
        if self._interactor:getRefreshCost() > 0 then
            self._actionUI:setText2("本次花费"..self._interactor:getRefreshCost()..self._interactor:getRefreshCostCNName())
        else
            self._actionUI:setText2("本次刷新免费")
        end
        self._actionUI:setText5("")
    end
end

function CangJingGePresenter:__setText3()
    if self._interactor:isYaShi() == false then
        self._actionUI:setText3("江湖雅士(未获得该身份)")
    else
        self._actionUI:setText3("江湖雅士特权已生效")
    end
end

function CangJingGePresenter:__setText4()
    local levelName = ""
    local levelInfo = self._interactor:getLevelInfo()
    for i = 1, #levelInfo, 1 do
        if self._level == levelInfo[i].id then
            levelName = Helper:getNoColorStr(levelInfo[i].name)
            break
        end
    end

    local str = ""

    if self._interactor:isYaShi() == false then
        str = "未获得使用【%s】残页降价10%%的特权"
        self._actionUI:setText4(string.format(str,levelName))
    else
        str = "已使用【%s】残页降价10%%的特权次数\n残页数量×5:%d/1次    残页数量×3:%d/1次    残页数量×1:%d/1次"
        local yaShiBuyInfo = self._interactor:getYaShiBuyInfo()
        local buyInfo = yaShiBuyInfo[tostring(self._level)]

        self._actionUI:setText4(string.format(str,levelName,buyInfo["5"],buyInfo["3"],buyInfo["1"]))
    end
end

function CangJingGePresenter:__initPanelButtonFunc()
    local levelInfo = self._interactor:getLevelInfo()
    for i = 1, #levelInfo, 1 do
        local info = levelInfo[i]
        self._actionUI:setPanelSelectBtnNameAndFunc(info.id, info.name, function()
            self._level = info.id
            self:__initPanelButtonTexture()
            self:refreshUI()
        end)
    end
end

function CangJingGePresenter:__initPanelButtonTexture()
    local levelInfo = self._interactor:getLevelInfo()

    for i = 1, #levelInfo, 1 do
        if self._level == levelInfo[i].id then
            self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue1-bg.png")
        else
            self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue2-bg.png")
        end
    end
end

function CangJingGePresenter:__showListView()
    local rewardList = self._interactor:getRewardListByLevel(self._level)
    
    for k,v in pairs(rewardList) do
        v.loadTexture = "Image/UI/TaskUI/anniu.png"
        
        if v.state == 2 or v.state == 3 then
            v.loadTexture = "Image/UI/TaskUI/anniuhui.png"
        end

        v.func = function()
            if v.state == 0 then
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:show()

                local str = "是否使用"..v.btnName2.."购买"..v.text1.."？"
  
                if v.yaShiBuy then
                    str = "本次购买使用江湖雅士专属折扣，"..str
                end

                dialog:setRichText(str)
                dialog:setButton1("确定", function()
                    if v.yaShiBuy and self._interactor:isYaShi() == false then
                        PopText("雅士权限已过期，本次购买失败")
                        self._interactor:init(InitEvent.GetInfo, self._level, function()
                            self:refreshUI()
                        end)
                        return
                    end

                    self._interactor:buyGoods(v.id,function()
                        self._interactor:init(InitEvent.GetInfo, self._level, function()
                            self:refreshUI()

                            if self._interactor:checkIsMaxBuyTimes() then
                                self._actionUI:setButton1TouchEnable(false)
                                self._actionUI:setButton1Texture("Image/UI/TaskUI/anniuhui.png")
                            end
                        end)
                    end)
                end)
                dialog:setButton2("取消", function()
                    dialog:hide()
                end)
                dialog:setWeChatVisible(false)
            elseif v.state == 1 then
                local isBagEnough = self._interactor:checkCanGetReward(v.rewards)
                local isEmail = isBagEnough == true and 0 or 1
                self._interactor:doReward(v.id, isEmail, function()
                    self._interactor:init(InitEvent.GetInfo, self._level, function()
                        self:refreshUI()
                    end)
                end)
            elseif v.state == 2 then
                PopText("该货架此商品已领取，刷新后可继续购买")
            elseif v.state == 3 then
                PopText("商品已售罄，请下次活动再次购买")
            end
        end
    end

    self._actionUI:showListView(rewardList)
end

function CangJingGePresenter:__yuanBaoRefreshFunc()
    local isYashi = self._interactor:isYaShi()
    
    self._actionUI:setButton1Func(function()
        if self._interactor:isCanRefresh() then
            local refreshFunc = function()
                if isYashi == true and self._interactor:isYaShi() == false then
                    PopText("雅士权限已过期，本次刷新失败")
                    self._interactor:init(InitEvent.GetInfo, self._level, function()
                        self:refreshUI()
                    end)
                    return
                end

                self._interactor:init(InitEvent.Refresh, self._level, function()
                    self:refreshUI()

                    if self._interactor:checkIsMaxBuyTimes() then
                        self._actionUI:setButton1TouchEnable(false)
                        self._actionUI:setButton1Texture("Image/UI/TaskUI/anniuhui.png")
                    end

                    local rewardList = self._interactor:getRewardListByLevel(self._level)
                    if MapIsEmpty(rewardList) == false then
                        PopText("刷新成功")
                    else
                        PopText("该货架已售空，刷新失败")
                    end
                end)
            end
            
            if self._interactor:getRefreshCost() > 0 and self._interactor:checkIsHideSelect() == false then
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:show()
                dialog:setRichText( "本次刷新需消耗"..self._interactor:getRefreshCost()..self._interactor:getRefreshCostCNName().."，是否继续？")
                dialog:setButton1("确定", function()
                    refreshFunc()
                end)
                dialog:setButton2("取消", function()
                    dialog:hide()
                end)

                dialog:setSelectVisible(true)
                dialog:setSelectFunc(function(isSelect)
                    self._interactor:setHideSelect(isSelect)
                end)
                dialog:setWeChatVisible(false)
            else
                refreshFunc()
            end
        end
    end)
end

function CangJingGePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "CangJingGePresenter",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function CangJingGePresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function CangJingGePresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function CangJingGePresenter:__showRule()
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

Helper:classDefNodeGetInstance(CangJingGePresenter)

return CangJingGePresenter
000000000