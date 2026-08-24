local MaskInfoPresenter = class("MaskInfoPresenter", cc.Layer)

local MaskAttr = require("app.models.mask.MaskAttr")

function MaskInfoPresenter:create()
    local p = MaskInfoPresenter.new()
    p:__init()
    return p
end

function MaskInfoPresenter:__init()
    self.__ui = require("app.views.ui.GoodsInfoUI.MaskInfoUI"):create()

    self.__ui:addTo(self)

    self.__ui:setButtonBackVisible(true)

    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function MaskInfoPresenter:showLayer(itemId)
    self.__maskId = itemId

    self.__item = Item:getOneItemByKey(itemId)

    self.__role = User:getRole()

    self.__maskSystem = self.__role:getMaskSystem()

    self.__ui:setTextTital("面具预览")

    self.__ui:setTextDesc("")

    self:__initMaskPage()

    self:__initButtons()

    self:__scrollToPage(0)

    self.__ui:showUI()
end

function MaskInfoPresenter:__initMaskPage()
    self.__ui:clearPage()
    
    local maskGradeList = self.__maskSystem:getMaskGradeMap(self.__item.gradeId)

    if #maskGradeList > 1 then
        table.sort(
            maskGradeList,
            function(a, b)
                return a:getMaskLevel() < b:getMaskLevel()
            end
        )
    end

    for i, maskGrade in ipairs(maskGradeList) do
        local maskAttrIds = maskGrade:getMaskAttrIds()
        
        if maskGrade:isTimeMask() then
            local timeMask = maskGrade:getTimeMask()

            for i,v in ipairs(timeMask) do
                local startIndex = i

                local endIndex = i + 1

                if endIndex > #timeMask then
                    endIndex = 1
                end

                local startTime = tonumber(timeMask[startIndex])
                
                local startTimeText = startTime < 10 and "0"..tostring(startTime).."时" or tostring(startTime).."时"

                local endTime = tonumber(timeMask[endIndex])
                
                local endTimeText = endTime < 10 and "0"..tostring(endTime).."时" or tostring(endTime).."时"

                local timeText = startTimeText.."~"..endTimeText

                local maskAttrId = maskAttrIds[i]

                local maskAttr = MaskAttr:create(maskAttrId)

                self:__addPage(maskGrade,maskAttr,timeText)
            end
        else
            local maskAttrId = maskAttrIds[1]

            local maskAttr = MaskAttr:create(maskAttrId)

            self:__addPage(maskGrade,maskAttr,"")
        end
    end
end

function MaskInfoPresenter:__addPage(maskGrade,maskAttr,timeText)
    local panel = self.__ui:createMaskInfoPage()

    panel.Text_name:setString(maskGrade:getMaskName())

    panel.Text_maskDesc:setString(maskAttr:getMaskDesc() .. "。")

    self:__setDescText(panel,maskGrade)

    self:__setMaskTypeText(panel,maskGrade,timeText)
    
    self:__setInfoFramePath(panel,maskAttr:isShowInfoFramePath(),maskAttr:getInfoFramePath())
    
    self:__createHeadUI(panel,maskAttr)

    self.__ui:addPage(panel)
end

function MaskInfoPresenter:__setDescText(panel,maskGrade)
    local text1 = "成就名称(成就积分):"

    local maskTuJianInfo = self.__maskSystem:getMaskTuJianInfo(self.__item.gradeId)

    local text2 = ""

    for i,v in ipairs(maskTuJianInfo) do
        if i == 1 then
            text2 = v.achievement .. "(" .. v.point .. ") "
        else
            text2 = text2 .." 、".. v.achievement .. "(" .. v.point .. ") "
        end
    end

    local text3 = ""

    if maskGrade:canDeal() then
        local cailianNum = maskGrade:getCaiLiao()
        
        text3 = "可分解为饰品材料数:"..tostring(cailianNum)
    end

    local text = text1 .. "\n" .. text2 .. "\n" .. text3

    local wearCoditionText = ""

    if not MapIsEmpty(maskGrade:getWearCondition()) then
        wearCoditionText = "佩戴条件:\n"..self.__maskSystem:getConditionText(maskGrade:getWearCondition())
    end

    text = text .. "\n  \n" .. wearCoditionText

    panel.Text_desc:setString(text)
end

function MaskInfoPresenter:__setMaskTypeText(panel,maskGrade,timeText)
    local maskLevel = maskGrade:getMaskLevel()

    local maskTypeText = ""

    if maskGrade:getMaskType() == 1 then
        maskTypeText = "戏曲面具"
    elseif maskGrade:getMaskType() == 2 and not maskGrade:canUpgrcade() and maskGrade:isTimeMask() then
        maskTypeText = "时间面具"..timeText
    elseif maskGrade:getMaskType() == 2 and maskGrade:canUpgrcade() and not maskGrade:isTimeMask() then
        maskTypeText = "百花焕颜-"..tostring(maskLevel).."级"
    elseif maskGrade:getMaskType() == 2 and maskGrade:canUpgrcade() and maskGrade:isTimeMask() then
        maskTypeText = "百花焕颜-"..tostring(maskLevel).."级-"..timeText
    end

    panel.Text_type:setString(maskTypeText)
end

function MaskInfoPresenter:__createHeadUI(panel,maskAttr)
    local headUI = require("app.views.ui.HeadView.HeadView"):create()
    headUI:setPosition(cc.p(panel.Image_kuang:getPosition()))
    panel:addChild(headUI)
    local maskHeadViewPresenter = require("app.presenters.HeadView.MaskHeadViewPresenter"):create(maskAttr,headUI)
    panel.__maskHeadViewPresenter = maskHeadViewPresenter
end

function MaskInfoPresenter:__showHeadUI(pageIndex)
    local pagePanel = self.__ui:getPageUI(pageIndex)

    pagePanel.__maskHeadViewPresenter:showTheHead()
end

function MaskInfoPresenter:__setInfoFramePath(panel,isShow,framePath)
    if isShow and framePath then
        panel.Image_button:setVisible(true)

        panel.Image_button:releaseFunc(
            function()
                self:__showInfoFramePath(framePath)
            end
        )
    else
        panel.Image_button:setVisible(false)
    end
end

function MaskInfoPresenter:__showInfoFramePath(infoFramePath)
    PopupLayerController:showLayer(
        "MaskRoleInfoBorderPresenter",
        function(layer)
            layer:showLayer(infoFramePath)
        end
    )
end

function MaskInfoPresenter:__initButtons()
    if self.__ui:getPageNum() > 1 then
        self.__ui:setButtonLeftVisible(true)

        self.__ui:setButtonRightVisible(true)

        self.__ui:setButtonLeft(function()
            if self.__ui:getCurrentPageIndex() > 0 then
                self:__scrollToPage(self.__ui:getCurrentPageIndex() - 1)
            end
        end)
        
        self.__ui:setButtonRight(function()
            if self.__ui:getCurrentPageIndex() < self.__ui:getPageNum() - 1 then
                self:__scrollToPage(self.__ui:getCurrentPageIndex() + 1)
            end
        end)
    else
        self.__ui:setButtonLeftVisible(false)

        self.__ui:setButtonRightVisible(false)
    end
end

function MaskInfoPresenter:__scrollToPage(pageIndex)
    self:__showHeadUI(pageIndex)

    self.__ui:scrollToPage(pageIndex)
end

function MaskInfoPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "MaskInfoPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(MaskInfoPresenter)
return MaskInfoPresenter
00000000