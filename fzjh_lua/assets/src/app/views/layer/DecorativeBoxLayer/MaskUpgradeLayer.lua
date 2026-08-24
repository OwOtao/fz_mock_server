--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-08-05 15:18:01
--]]
local MaskUpgradeLayer = class("MaskUpgradeLayer", cc.Layer)

local MaskConst = require("app.models.mask.MaskConst")

local MaskResManager = require("app.models.mask.MaskResManager")

local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

function MaskUpgradeLayer:create()
    local p = MaskUpgradeLayer:new()
    p:init()
    return p
end

function MaskUpgradeLayer:init()
    self.__ui = require("app.views.ui.GoodsInfoUI.MaskInfoUI"):create()

    self.__ui:addTo(self)
    
    self.__role = User:getRole()
    
    self.__maskSystem = self.__role:getMaskSystem()
    
    self.__ui:setButtonBackVisible(true)

    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function MaskUpgradeLayer:setItem(item)
    self.__item = item
end

function MaskUpgradeLayer:setWearCallback(callback)
    self.__callback = callback
end

function MaskUpgradeLayer:setCostCurrencyUICallback(callback)
    self.__currencyUICallback = callback
end

function MaskUpgradeLayer:showLayer()
    self.__itemId = self.__item.id

    self.__name = self.__item.name
    
    self.__maskGradeList = self.__maskSystem:getMaskGradeMap(self.__item.gradeId)

    self:__initCurrIndex()

    self:__initMaskPage()

    self:setTextTital()

    self:setTextDesc()

    self:setButtonLeft()

    self:setButtonRight()
    
    self:__initCurrPagePanelUI()

    self:__scrollToPage()
    
    self.__ui:showUI()
end

function MaskUpgradeLayer:__initCurrIndex()
    local index
    if self.__role:getPortraitId() == self.__itemId then
        index = self.__role:getPortraitLv()
    end
    self.__currIndex = Helper:getDef(index, 1)
end

function MaskUpgradeLayer:setTextTital()
    self.__ui:setTextTital("百花换颜")
end

function MaskUpgradeLayer:setTextDesc()
    self.__ui:setTextDesc("白牡丹与百花杀皆是名动江湖的花旦，一直来难分伯仲。而今两人天都峰相遇，技痒难耐，决定斗戏一较高下。二人绘制的戏曲面具皆非凡品，还请少侠收集相应颜料，为二者面具浓妆淡抹，改头换面，为这出难得一遇的二人绝唱助力。")
end

function MaskUpgradeLayer:__initMaskPage()
    self.__ui:clearPage()

    if #self.__maskGradeList > 1 then
        table.sort(
            self.__maskGradeList,
            function(a, b)
                return a:getMaskLevel() < b:getMaskLevel()
            end
        )
    end

    for i, maskGrade in ipairs(self.__maskGradeList) do
        self:__addPage()
    end
end

function MaskUpgradeLayer:__addPage()
    local panel = self.__ui:createMaskUpgradePage()
    
    self.__ui:addPage(panel)
end

function MaskUpgradeLayer:__initCurrPagePanelUI()
    local pageIndex = self.__currIndex - 1

    local pagePanel = self.__ui:getPageUI(pageIndex)

    local maskGrade = self.__maskGradeList[self.__currIndex]

    local maskAttrId = maskGrade:getCurrTimeArtsId()

    local maskAttr = self.__maskSystem:getMaskAttr(maskAttrId)

    local wearCoditionText = ""

    if not MapIsEmpty(maskGrade:getWearCondition()) then
        wearCoditionText = "佩戴条件:\n"..self.__maskSystem:getConditionText(maskGrade:getWearCondition())
    end

    pagePanel.Text_wearCondition:setString(wearCoditionText)
    
    pagePanel.Text_name:setString(maskGrade:getMaskName())

    pagePanel.Text_maskDesc:setString(maskAttr:getMaskDesc() .. "。")

    pagePanel.Text_codition:setString("")
    
    self:__showHeadUI(pagePanel,maskAttr)

    self:__initPanelButton(pagePanel,maskGrade)
end

function MaskUpgradeLayer:__showHeadUI(panel,maskAttr)
    local headUI = require("app.views.ui.HeadView.HeadView"):create()
    headUI:setPosition(cc.p(panel.Image_kuang:getPosition()))
    panel:addChild(headUI)
    local maskHeadViewPresenter = require("app.presenters.HeadView.MaskHeadViewPresenter"):create(maskAttr,headUI)
    maskHeadViewPresenter:showTheHead()
end

function MaskUpgradeLayer:__initPanelButton(panel,maskGrade)
    local currMaskLv = self.__maskSystem:getMaskLv(self.__itemId)

    if self.__role:getPortraitId() == self.__itemId and self.__role:getPortraitLv() == self.__currIndex then
        panel.Button_open.Text_buttonName:setString("使用中")

        panel.Button_open:setEnabled(false)
    else
        panel.Button_open:setEnabled(true)
        
        if self.__currIndex <= currMaskLv then
            panel.Button_open.Text_buttonName:setString("佩戴")

            panel.Button_open:releaseFunc(
                function()
                    self:showWearAffirmLayer()
                end
            )
        else
            local affirmText = ""

            panel.Button_open.Text_buttonName:setString("解锁")

            local upgradeCoditionText = ""

            if not MapIsEmpty(maskGrade:getUpgradeCondition()) then
                upgradeCoditionText = "解锁条件:\n"..self.__maskSystem:getConditionText(maskGrade:getUpgradeCondition())
            end

            panel.Text_codition:setString(upgradeCoditionText)

            panel.Button_open:releaseFunc(
                function()
                    if self.__currIndex > currMaskLv + 1 then
                        PopText("尚未解锁前一等级面具。")
                        return
                    end

                    local isResult,msgList = self.__maskSystem:checkMaskConditions(maskGrade:getWearCondition())

                    if isResult then
                        self:__showUpgradeAffirmLayer(maskGrade)
                    else
                        self:__showWearConditionLayer(maskGrade,msgList)
                    end

                end
            )
        end
    end
end

function MaskUpgradeLayer:__showWearConditionLayer(maskGrade,msgList)
    local affirmText = "提示:当前角色不满足佩戴条件:"

    for i,msgText in ipairs(msgList) do
        affirmText = affirmText.."【"..msgText.."】"
    end 

    affirmText = affirmText..",是否继续进行解锁？"

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(affirmText)
    dialog:setBack(false)
    dialog:setButton2("取消", EMPTY_FUNC)
    dialog:setButton1(
        "确定",
        function()
            self:__showUpgradeAffirmLayer(maskGrade)
        end
    )
    dialog:setWeChatVisible(false)
end

function MaskUpgradeLayer:__showUpgradeAffirmLayer(maskGrade)
    local affirmText = "升级所需条件为:"..self.__maskSystem:getConditionText(maskGrade:getUpgradeCondition()).."是否升级"..self.__name.."？"

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(affirmText)
    dialog:setBack(false)
    dialog:setButton2("取消", EMPTY_FUNC)
    dialog:setButton1(
        "升级",
        function()
            local isResult,msgList = self.__maskSystem:checkMaskConditions(maskGrade:getUpgradeCondition())

            if isResult then
                self.__maskSystem:maskUpgrade(
                    maskGrade:getUpgradeCondition(),
                    function(isOk,msg)
                        if isOk then
                            self.__maskSystem:addMaskLv(self.__itemId)

                            self:__initCurrPagePanelUI()
                            
                            if self.__currencyUICallback then
                                self.__currencyUICallback()
                            end

                            PopText("解锁面具成功")
                        else
                            PopText(msg)
                        end
                    end
                )
            else
                for i,msgText in ipairs(msgList) do
                    PopText(msgText)
                end
                PopText("解锁面具失败!")
            end
        end
    )
    dialog:setWeChatVisible(false)
end

function MaskUpgradeLayer:setButtonLeft()
    self.__ui:setButtonLeftVisible(true)

    self.__ui:setButtonLeft(
        function()
            if self.__currIndex > 1 then
                self.__currIndex = self.__currIndex - 1

                self:__initCurrPagePanelUI()

                self:__scrollToPage()
            end
        end
    )
end

function MaskUpgradeLayer:setButtonRight()
    self.__ui:setButtonRightVisible(true)

    self.__ui:setButtonRight(
        function()
            if self.__currIndex < #self.__maskGradeList then
                self.__currIndex = self.__currIndex + 1

                self:__initCurrPagePanelUI()

                self:__scrollToPage()
            end
        end
    )
end

function MaskUpgradeLayer:__scrollToPage()
    local pageIndex = self.__currIndex - 1

    self.__ui:scrollToPage(pageIndex)
end

function MaskUpgradeLayer:hideLayer()
    PopupLayerController:hideLayer(
        "MaskUpgradeLayer",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function MaskUpgradeLayer:showWearAffirmLayer()
    local maskId = self.__itemId 

    local maskLv = self.__currIndex
	
    --@desc 有新框体需要更换时，弹出提示
	if self.__role:getMaskSystem():isChangeMaskBorder(maskId,maskLv) then
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		local text = "佩戴此面具会改变当前主界面头像框，排行榜头像框，个人简介背景框，是否确认更换？"
		dialog:show(text)
		dialog:setButton1("确定",
			function()
				self:changeMask()
			end
		)
		dialog:setButton2("取消")
		dialog:setWeChatVisible(false)
	else
		self:changeMask()
	end
end

function MaskUpgradeLayer:changeMask()
    local maskGrade = self.__maskGradeList[self.__currIndex]

    local isResult,msgList = self.__maskSystem:checkMaskConditions(maskGrade:getWearCondition())

    if isResult then
        self.__maskSystem:wearMask(self.__itemId, self.__currIndex)
    
        PopText("佩戴成功")
        
        self:__initCurrPagePanelUI()
        
        if self.__callback then
            self.__callback(self.__currIndex)
        end
    else
        for i,msgText in ipairs(msgList) do
			PopText(msgText)
		end
		PopText("佩戴面具失败!")
    end
end


Helper:classDefNodeGetInstance(MaskUpgradeLayer)
return MaskUpgradeLayer
0000000000000000