local NewClass = require("third.class.NewClass")

local MaskAttr = require("app.models.mask.MaskAttr")
local IGoodsPresenter = require("app.presenters.GoodsInfo.IGoodsPresenter")

local MaskInfoPresenter = {}

function MaskInfoPresenter:create(goods)
    local o = MaskInfoPresenter.new()
    o:init(goods)
    return o
end

function MaskInfoPresenter:init(goods)
    self.__ui = require("app.views.ui.GoodsInfoUI.MaskInfoUI"):create()
    self.__goods = goods
    self.__item = Item:getOneItemByKey(self.__goods:getItemId())
    self.__maskSystem = User:getRole():getMaskSystem()
end

function MaskInfoPresenter:getUI()
    return self.__ui
end

function MaskInfoPresenter:showUI()
    self.__ui:setTextTital("面具信息")

    self.__ui:setTextDesc("")
    
    self:__initMaskPage()

    self:__initButtons()

    self.__ui:scrollToPage(0)

    self.__ui:showUI()
end

function MaskInfoPresenter:setButtonBackVisible(visible)
    self.__ui:setButtonBackVisible(visible)
end

function MaskInfoPresenter:setButtonBack(func)
    self.__ui:setButtonBack(function()
        if func then
            func()
        end
    end)
end

function MaskInfoPresenter:__initButtons()
    if self.__ui:getPageNum() > 1 then
        self.__ui:setButtonLeftVisible(true)

        self.__ui:setButtonRightVisible(true)

        self.__ui:setButtonLeft(function()
            if self.__ui:getCurrentPageIndex() > 0 then
                self.__ui:scrollToPage(self.__ui:getCurrentPageIndex() - 1)
            end
        end)
        
        self.__ui:setButtonRight(function()
            if self.__ui:getCurrentPageIndex() < self.__ui:getPageNum() - 1 then
                self.__ui:scrollToPage(self.__ui:getCurrentPageIndex() + 1)
            end
        end)
    else
        self.__ui:setButtonLeftVisible(false)

        self.__ui:setButtonRightVisible(false)
    end
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
    
    self:__showHeadUI(panel,maskAttr)

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

function MaskInfoPresenter:__showHeadUI(panel,maskAttr)
    local headUI = require("app.views.ui.HeadView.HeadView"):create()
    headUI:setPosition(cc.p(panel.Image_kuang:getPosition()))
    panel:addChild(headUI)
    local maskHeadViewPresenter = require("app.presenters.HeadView.MaskHeadViewPresenter"):create(maskAttr,headUI)
    maskHeadViewPresenter:showTheHead()
end

function MaskInfoPresenter:hide()
    self.__ui:hideUI()
end

return NewClass("MaskInfoPresenter", {IGoodsPresenter}, MaskInfoPresenter)0000000000000000