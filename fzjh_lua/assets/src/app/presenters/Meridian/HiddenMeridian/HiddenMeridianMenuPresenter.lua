local HiddenMeridianMenuPresenter = class("HiddenMeridianMenuPresenter", LayerEx)

local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")

local HiddenMeridianEffect = require("app.models.Meridian.HiddenMeridianBuff.HiddenMeridianEffect")

local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")

local ChartPoint = require("app.models.Meridian.HiddenMeridianSprite.ChartPoint")

local ChartLine = require("app.models.Meridian.HiddenMeridianSprite.ChartLine")

function HiddenMeridianMenuPresenter:create()
    local p = HiddenMeridianMenuPresenter:new()
    p:init()
    return p
end

--@desc: 
--@author:LvBin
--@time:2025-01-21 11:16:11
--@Iinput: [src.app.models.Meridian.HiddenMeridianInteractor#HiddenMeridianInteractor]
--@return
function HiddenMeridianMenuPresenter:setInput(Iinput)
    self.__input = Iinput
end

function HiddenMeridianMenuPresenter:init()
    self.__ui = require("app.views.ui.Meridian.HiddenMeridian.HiddenMeridianMenuUI"):create()

    self.__ui:addTo(self)
    
    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    titleLayer:setImageRuleFunc(function()
        Audio:playEffect("xiaoAnNiu")
        self:__showRule()
    end)
end

function HiddenMeridianMenuPresenter:showPresenter()
    self.__selectAcupointId = nil --当前选中的窍关Id

    self.__acupointIndex = nil

    self.__sle_image_row = nil

    self.__role = self.__input:getRole()

    self.__sys = self.__role:getHiddenMeridianSystem()

    self:__initUIConfig()

    self.__ui:showUI()
end

function HiddenMeridianMenuPresenter:onDisable()
    self:unscheduleWithTag("updataSchedule")

    self.__ui:hideUI()
end

function HiddenMeridianMenuPresenter:__initUIConfig()
    self:__showHiddenMeridianChartLv()

    self:__showHiddenMeridianResouce()

    self:__setButtonBreakThrough()

    self:__setButtonYuQi()

    self:__setButtonCtrlMeridian()

    self:__showHiddenMeridianChart()

    self:__refreshPanelInfo()

    self:__refreshPanelBreakThrough()
end

function HiddenMeridianMenuPresenter:__refreshPanelInfo()
    self.__ui:setPanelAttrInfoVisible(false)
    
    self.__ui:setPanelAcupointInfoVisible(false)
    
    self.__ui:setPanelBuffInfoVisible(false)

    if self.__selectAcupointId == nil then
        self:__showAttrInfo()
    elseif self.__sys:getAcupointAttachBuffId(self.__selectAcupointId) then
        self:__showBuffInfo()
    else
        self:__showAcupointInfo()
    end
end

function HiddenMeridianMenuPresenter:__refreshPanelBreakThrough()
    if self.__sys:getBreakThroughState() then
        self:__showBreakthroughUI()
    elseif self.__sys:getAcupointActivateState() then
        self:__showAcupointActivateUI()
    else
        self.__ui:setPanelBreakthroughVisible(false)
    end
end

function HiddenMeridianMenuPresenter:__showHiddenMeridianChartLv()
    self.__ui:setTextLevel("玄络图等级:"..Helper:numberCast(self.__sys:getHiddenMeridianChartLv()))
end

function HiddenMeridianMenuPresenter:__showHiddenMeridianResouce()
    self.__ui:setTextResouce(Role:getCHAttrName(HiddenMeridianConstants.ResItemId)..":"..self.__sys:getYgpillCount())
end

function HiddenMeridianMenuPresenter:__showHiddenMeridianChart()
    if self.__panelChart then
        self.__ui:hideNodeAndAllChildren(self.__panelChart)
    end

    local imageIndex = self.__sys:getHiddenMeridianChart():getImageIndex()

    local panelChart = self.__ui:getPanelChart(imageIndex)

    self.__ui:hideNodeAndAllChildren(panelChart)

    panelChart:setVisible(true)

    panelChart.Image_di:setVisible(true)

    panelChart:setTouchAnimEnabled(false)

    panelChart:releaseFunc(function()
        if self.__selectAcupointId then
            self.__selectAcupointId = nil
    
            self:__initUIConfig()
        end
    end)

    self.__panelChart = panelChart

    self:__refreshAcupointUI()

    self:__refreshLineUI()
end

function HiddenMeridianMenuPresenter:__refreshAcupointUI()
    local acupointList = self.__sys:getHiddenMeridianChart():getAcupointList()

    for acupointIndex,acupoint in ipairs(acupointList) do
        local image_row = self.__panelChart["Image_acupoint"..acupointIndex]

        local sle_image_row = self.__panelChart["Image_sle_acupoint"..acupointIndex]

        if image_row and sle_image_row then
            image_row:ignoreContentAdaptWithSize(true)
            sle_image_row:ignoreContentAdaptWithSize(true)

            local chartPoint = ChartPoint:create(acupoint,acupointIndex)

            image_row:setVisible(true)
            
            image_row:loadTexture(chartPoint:getImage(),0)

            if acupoint:getId() == self.__selectAcupointId then
                sle_image_row:setVisible(true)

                sle_image_row:loadTexture(chartPoint:getSelectImage(),0)
            else
                sle_image_row:setVisible(false)
            end

            image_row:releaseFunc(function()
                if self.__sle_image_row then
                    self.__sle_image_row:setVisible(false)
                end
                sle_image_row:setVisible(true)

                sle_image_row:loadTexture(chartPoint:getSelectImage(),0)

                self.__sle_image_row = sle_image_row

                self.__selectAcupointId = acupoint:getId()

                self.__acupointIndex = acupointIndex

                self:__refreshPanelInfo()

                self:__setButtonCtrlMeridian()
            end)
        end
    end
end

function HiddenMeridianMenuPresenter:__refreshLineUI()
    local chartLine = ChartLine:create(self.__sys:getHiddenMeridianChart())

    local lineList = chartLine:getLineList()

    for i,line in ipairs(lineList) do
        local lineId = line:getId()

        local imagePath = line:getImagePath()

        local line_row = self.__panelChart[lineId]

        if line_row then
            line_row:setVisible(true)

            line_row:loadTexture(imagePath,0)
        end
    end
end

function HiddenMeridianMenuPresenter:__showAttrInfo()
    self.__ui:setPanelAttrInfoVisible(true)

    self.__ui:setPanelAttrChartName(self.__sys:getHiddenMeridianChart():getName())

    self.__ui:removeListViewAllItems()

    local buffAttrList = self.__input:getCurrHiddenMeridianBuffAttrList()

    if #buffAttrList == 0 then
        return
    end

    local maxPanelCount, isRemain = math.modf(#buffAttrList / 2)

    if isRemain > 0 then
        maxPanelCount = maxPanelCount + 1
    end

    for i = 1, maxPanelCount do
        local panel = self.__ui:createPanelAttr()

        self.__ui:insertPanelToListView(panel)

        for _i = 1, 2 do
            local index = (i-1) * 2 + _i

            if buffAttrList[index] then
                local attrName = buffAttrList[index].name

                local value = Helper:mathFloor(buffAttrList[index].value * HiddenMeridianConstants.BuffAttrMult)
                
                panel["Text_attr".._i]:setVisible(true)

                panel["Text_attr".._i]:setString(attrName.." "..value)
            else
                panel["Text_attr".._i]:setVisible(false)
            end 
        end
    end

    local effectTextList = self.__sys:getCurrHiddenMeridianActiveEffectAttrText()

    for i, text in ipairs(effectTextList) do
        local panel = self.__ui:getBuffDescPanel()
        panel.Text_1:setString(text)

        self.__ui:insertPanelToListView(panel)
    end
end

function HiddenMeridianMenuPresenter:__showBuffInfo()
    self.__ui:setPanelBuffInfoVisible(true)

    self.__ui:removeBuffListViewAllItems()

    local buffId = self.__sys:getAcupointAttachBuffId(self.__selectAcupointId)

    local buff = self.__sys:getHiddenMeridianBuff(buffId)

    local panel = self.__ui:getBuffTitlePanel()

    panel.Text_1:setString(buff:getName())

    self.__ui:insertBuffPanelToBuffListView(panel)

    local effects = buff:getProperty()

    local panel = self.__ui:getBuffAttrPanel()

    for attrIndex = 1,4 do
        local effectData = effects[attrIndex]
        if effectData then
            local effect = HiddenMeridianEffect:create(effectData)

            local name = effect:getDamageName()

            local value = Helper:mathFloor(effect:getValue() * HiddenMeridianConstants.BuffAttrMult)

            panel["Text_"..attrIndex]:setString(name..":"..value)
        else
            panel["Text_"..attrIndex]:setString("")
        end
    end

    self.__ui:insertBuffPanelToBuffListView(panel)

    local attrText = buff:getSpecialAttrText()

    if attrText ~= "" then
        local panel = self.__ui:getBuffTitlePanel()

        panel.Text_1:setString("特殊属性")

        self.__ui:insertBuffPanelToBuffListView(panel)

        local panel = self.__ui:getBuffDescPanel()

        panel.Text_1:setString(attrText)

        self.__ui:insertBuffPanelToBuffListView(panel)
    end

    local effectText = buff:getSpecialEffectText()

    if effectText ~= "" then
        local panel = self.__ui:getBuffTitlePanel()

        panel.Text_1:setString("特殊效果")

        self.__ui:insertBuffPanelToBuffListView(panel)

        local panel = self.__ui:getBuffDescPanel()

        panel.Text_1:setString(effectText)

        self.__ui:insertBuffPanelToBuffListView(panel)
    end
end

function HiddenMeridianMenuPresenter:__showAcupointInfo()
    self.__ui:setPanelAcupointInfoVisible(true)

    local texts = {}

    local acupoint = self.__sys:getAcupoint(self.__selectAcupointId)

    table.insert(texts, acupoint:getName())

    table.insert(texts, "窍关类型:"..self.__input:getAcupointTypeName(acupoint:getType()))

    table.insert(texts, "可使用玄络类型:")
    
    table.insert(texts, self.__input:getAcupointLvUseText(acupoint:getClass(),acupoint:getType()))

    self.__ui:setPanelAcupointInfoTexts(texts)
end

function HiddenMeridianMenuPresenter:__setButtonBreakThrough()
    local buttonIndex = 1

    self.__ui:setButtonName(buttonIndex,"破 境")
    
    self.__ui:setButtonVisible(buttonIndex,true)

    self.__ui:setButtonFunc(buttonIndex,function()
        Audio:playEffect("xiaoAnNiu")

        local isOk,msg = self.__input:canStartBreakThrough()
        if isOk then
            PopupLayerController:showLayer("HiddenMeridianBreakthroughPresenter",function(layer)
                local ui = require("app.views.ui.Meridian.HiddenMeridian.HiddenMeridianBreakthroughUI"):create()
                layer:setInput(self.__input)
                layer:setUI(ui)
                layer:setCallFunc(function()
                    self:__initUIConfig()
                end)
                layer:showPresenter()
            end)
        else
            PopText(msg)
        end 
    end)
end

function HiddenMeridianMenuPresenter:__setButtonYuQi()
    local buttonIndex = 2

    self.__ui:setButtonName(buttonIndex,"余 炁")
    
    self.__ui:setButtonVisible(buttonIndex,self.__sys:getYuQiState())

    self.__ui:setButtonFunc(buttonIndex,function()
        Audio:playEffect("xiaoAnNiu")
        PopupLayerController:showLayer("HiddenMeridianYuQiPresenter",function(layer)
            local ui = require("app.views.ui.Meridian.HiddenMeridian.HiddenMeridianYuQiUI"):create()
            layer:setInput(self.__input)
            layer:setUI(ui)
            layer:setCallFunc(function()
                self:__setButtonYuQi()
            end)
            layer:showPresenter()
        end)
    end)
end

function HiddenMeridianMenuPresenter:__setButtonCtrlMeridian()
    local buttonIndex = 3
    
    if self.__selectAcupointId == nil then
        self.__ui:setButtonVisible(buttonIndex,false)
        return
    end

    self.__ui:setButtonVisible(buttonIndex,true)

    local isActivated = self.__sys:getHiddenMeridianChart():isAcupointActivated(self.__selectAcupointId)

    if isActivated then
        self.__ui:setButtonName(buttonIndex,"调 脉")
        
        self.__ui:setButtonFunc(buttonIndex,function()
            Audio:playEffect("xiaoAnNiu")

            PopupLayerController:showLayer("HiddenMeridianBuffPresenter",function(layer)
                local ui = require("app.views.ui.Meridian.HiddenMeridian.HiddenMeridianBuffUI"):create()
                layer:setInput(self.__input)
                layer:setUI(ui)
                layer:setCallFunc(function()
                    self:__initUIConfig()
                end)
                layer:showPresenter(self.__selectAcupointId)
            end)
            
        end)
    else
        self.__ui:setButtonName(buttonIndex,"冲 脉")

        self.__ui:setButtonFunc(buttonIndex,function()
            Audio:playEffect("xiaoAnNiu")
            if self.__acupointIndex and self.__sys:isAcupointUnlocked(self.__acupointIndex) then
                PopupLayerController:showLayer("AcupointActivatePresenter",function(layer)
                    local ui = require("app.views.ui.Meridian.HiddenMeridian.AcupointActivateUI"):create()
                    layer:setInput(self.__input)
                    layer:setUI(ui)
                    layer:setCallFunc(function()
                        self:__initUIConfig()
                    end)
                    layer:showPresenter(self.__selectAcupointId)
                end)
            else
                PopText("前置窍关尚未冲脉，请先进行冲脉")
                return
            end
        end)
    end
end

function HiddenMeridianMenuPresenter:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("隐脉规则")
        layer:showPanel_1(self.__input:getRuleInfo())
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

--@desc: 显示破境ui
--@author:LvBin
--@time:2025-02-25 20:04:46
--@return
function HiddenMeridianMenuPresenter:__showBreakthroughUI()
    self.__ui:setPanelBreakthroughVisible(true)

    local nextLv = self.__sys:getHiddenMeridianChartLv() + 1

    self.__ui:setTextAcupointCount1(self.__input:getAcupointLvName(1)..":"..self.__input:getHiddenMeridianChartAcupointNum(nextLv,1))

    self.__ui:setTextAcupointCount2(self.__input:getAcupointLvName(2)..":"..self.__input:getHiddenMeridianChartAcupointNum(nextLv,2))

    self.__ui:setTextAcupointCount3(self.__input:getAcupointLvName(3)..":"..self.__input:getHiddenMeridianChartAcupointNum(nextLv,3))

    self.__ui:setTextAcupointDesc("")

    self.__ui:setTextBreakthroughTitle1(self.__sys:getHiddenMeridianChartByLv(nextLv):getName())

    self:__playAnim()

    self:scheduleUnique(
        function(ft)
            self:__updataBreakThroughUI(ft)
        end,
        0,
        "updataSchedule"
    )
end

--@desc: 显示冲脉ui
--@author:LvBin
--@time:2025-02-25 20:04:46
--@return
function HiddenMeridianMenuPresenter:__showAcupointActivateUI()
    self.__ui:setPanelBreakthroughVisible(true)

    local acupointId = self.__sys:getCurrAcupointActivateId()

    local acupoint = self.__sys:getAcupoint(acupointId)

    self.__ui:setTextBreakthroughTitle1(acupoint:getName())

    self.__ui:setTextAcupointCount1("")

    self.__ui:setTextAcupointCount2("")

    self.__ui:setTextAcupointCount3("")

    self.__ui:setTextAcupointDesc(acupoint:getTextIntroduction())

    self:__playAnim()
    
    self:scheduleUnique(
        function(ft)
            self:__updataAcupointActivateUI(ft)
        end,
        0,
        "updataSchedule"
    )
end

function HiddenMeridianMenuPresenter:__playAnim()
    self.__animator = self.__ui:initAnimator()

    self.__animator:play("jingmai", true)
end

function HiddenMeridianMenuPresenter:__updataBreakThroughUI(ft)
    local isFinish = self.__sys:isFinishBreakThrough()
    
    if isFinish then
        self.__ui:setTextBreakthroughTitle("破境完成")

        self.__ui:setTextBreakthroughTime("")

        self.__ui:setBreakthroughButton1PosY(624.5)

        self.__ui:setBreakthroughButton1(
            true,
            "完成",
            function()
                self.__sys:breakThroughFinish(function(isOk,msg)
                    if isOk then
                        self.__selectAcupointId = nil
                        
                        self:__initUIConfig()
                    else
                        PopText(msg)
                    end 
                end)
            end
        )

        self.__ui:setBreakthroughButton2(false)

        self:unscheduleWithTag("updataSchedule")
    else
        self.__ui:setTextBreakthroughTitle("破境中")

        self.__animator:update(ft)

        local time = math.max(self.__sys:getBreakThroughTime() - GetTime(),0)

        local hour, min, sec = Helper:sec2timeDsc(time)
        
        self.__ui:setTextBreakthroughTime(hour .. "时" .. min .. "钟" .. sec .. "秒")

        self.__ui:setBreakthroughButton1PosY(654.5)

        self.__ui:setBreakthroughButton1(
            true,
            "加速",
            function()
                PopupLayerController:showLayer(
                    "HiddenMeridianSpeedUpPresenter",
                    function(layer)
                        layer:setInput(self.__input)
                        layer:setTime(self.__sys:getBreakThroughTime())
                        layer:setConfirmFunc(function(cost)
                            self.__sys:speedUpBreakThrough(cost,function(isOk,msg)
                                if isOk then
                                    self:__initUIConfig()

                                    layer:hideLayer()
                                else
                                    PopText(msg)
                                end
                            end)
                        end)
                        layer:showLayer()
                    end
                )
            end
        )

        self.__ui:setBreakthroughButton2(
            true,
            "终止",
            function()
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:hide()
                dialog:show("是否终止破境？终止后经脉图会恢复到原来效果，且已消耗的破境资源、破境时间和加速资源不会返还。")
                dialog:setButton1(
                    "确定",
                    function()
                        self.__sys:stopBreakThrough(function(isOk,msg)
                            if isOk then
                                self.__selectAcupointId = nil

                                self:__initUIConfig()
                            else
                                PopText(msg)
                            end 
                        end)
                    end
                )
                dialog:setButton2(
                    "取消",
                    function()
                        dialog:hide()
                    end
                )
                dialog:setWeChatVisible(false)
            end
        )
    end
end

function HiddenMeridianMenuPresenter:__updataAcupointActivateUI(ft)
    local isFinish = self.__sys:isFinishAcupointActivate()
    
    if isFinish then
        self.__ui:setTextBreakthroughTitle("冲脉完成")

        self.__ui:setTextBreakthroughTime("")

        self.__ui:setBreakthroughButton1PosY(624.5)
        
        self.__ui:setBreakthroughButton1(
            true,
            "完成",
            function()
                self.__sys:acupointActivateFinish(
                    function(isOk,msg)
                    if isOk then
                        self:__initUIConfig()
                    else
                        PopText(msg)
                    end 
                end)
            end
        )

        self.__ui:setBreakthroughButton2(false)

        self:unscheduleWithTag("updataSchedule")
    else
        self.__ui:setTextBreakthroughTitle("冲脉中")

        self.__animator:update(ft)
        
        local time = math.max(self.__sys:getAcupointActivateTime() - GetTime(),0)

        local hour, min, sec = Helper:sec2timeDsc(time)
        
        self.__ui:setTextBreakthroughTime(hour .. "时" .. min .. "钟" .. sec .. "秒")

        self.__ui:setBreakthroughButton1PosY(654.5)

        self.__ui:setBreakthroughButton1(
            true,
            "加速",
            function()
                PopupLayerController:showLayer(
                    "HiddenMeridianSpeedUpPresenter",
                    function(layer)
                        layer:setInput(self.__input)
                        layer:setTime(self.__sys:getAcupointActivateTime())
                        layer:setConfirmFunc(function(cost)
                            self.__sys:speedUpAcupointActivate(cost,function(isOk,msg)
                                if isOk then 
                                    self:__initUIConfig()
                                    
                                    layer:hideLayer()
                                else
                                    PopText(msg)
                                end
                            end)
                        end)
                        layer:showLayer()
                    end
                )
            end
        )

        self.__ui:setBreakthroughButton2(
            true,
            "终止",
            function()
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:hide()
                dialog:show("是否终止冲脉？终止后窍关会恢复到未冲脉状态，且已消耗的冲脉资源、冲脉时间和加速资源不会返还。")
                dialog:setButton1(
                    "确定",
                    function()
                        self.__sys:stopAcupointActivate(function(isOk,msg)
                            if isOk then
                                self:__initUIConfig()
                            else
                                PopText(msg)
                            end 
                        end)
                    end
                )
                dialog:setButton2(
                    "取消",
                    function()
                        dialog:hide()
                    end
                )
                dialog:setWeChatVisible(false)
            end
        )
    end
end

Helper:classDefNodeGetInstance(HiddenMeridianMenuPresenter)
return HiddenMeridianMenuPresenter00000000000000