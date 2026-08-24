local MakeMaskPresenter = class("MakeMaskPresenter", cc.Layer)

local GoodsHelper = require("app.models.Store.GoodsHelper")

local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

function MakeMaskPresenter:create()
    local p = MakeMaskPresenter.new()
    p:__init()
    return p
end

function MakeMaskPresenter:__init()
    self.__ui = require("app.views.ui.MaskUI.MakeMaskUI"):create()

    self.__ui:addTo(self)

    self.__ui:setPanelBack(
        function()
            self:hideLayer()
        end
    )
end

function MakeMaskPresenter:showLayer(npc)
    self.__npc = npc

    self.__maskSystem = User:getRole():getMaskSystem()

    self.__titleIndex = 1

    self.__subTitle1Index = 1

    self.__subTitle2Index = 1

    self:showTextTitle()

    self:showTextSpNum()

    self:showTextPayNum()

    self:setSubTitle1()

    self:setSubTitle2()

    self:setPanelbgVisible()

    self:showRandomMask()

    self:setRuleFunc()

    self:setButton1()
    
    self:setButton2()

    self:setPanelRuleFunc()

    self.__ui:hidePanelRule()

    self.__ui:showUI()
end

function MakeMaskPresenter:showTextTitle()
    self.__ui:setTextTitle("面具制作")
end

function MakeMaskPresenter:showTextSpNum()
    self.__ui:setTextSpNum("饰品材料："..self.__maskSystem:getSpNum().."个")
end

function MakeMaskPresenter:showTextPayNum()
    self.__ui:setTextPayNum(Role:getCHAttrName("paymaskmake").."："..self.__maskSystem:getPayNum().."个")
end

function MakeMaskPresenter:setPanelbgVisible()
    if self.__titleIndex == 1 then
        self.__ui:setPanelbg1Visible(true)

        self.__ui:setPanelbg2Visible(false)

        self.__ui:setButton1Visible(true)
    else
        self.__ui:setPanelbg1Visible(false)
        
        self.__ui:setPanelbg2Visible(true)

        self.__ui:setButton1Visible(false)
    end
end

function MakeMaskPresenter:setSubTitle1()
    self.__ui:setTitle1Name("随机制作")
    
    self.__ui:setTitle1Func(function()
        if self.__titleIndex ~= 1 then
            self.__titleIndex = 1

            self:showRandomMask()

            self:setPanelbgVisible()
        end
    end)
end

function MakeMaskPresenter:setSubTitle2()
    self.__ui:setTitle2Name("特殊制作")
        
    self.__ui:setTitle2Func(function()
        if self.__titleIndex ~= 2 then
            self.__titleIndex = 2

            self:showPayMask()

            self:setPanelbgVisible()
        end
    end)
end

function MakeMaskPresenter:showRandomMask()
    self.__ui:removeAllTitleItems()

    local maskList = self.__maskSystem:getRandomMaskList()
    
    for i,v in ipairs(maskList) do
        local panelTitle = self.__ui:createPanelTitle()

        self.__ui:addItemToTitleList(panelTitle)

        panelTitle.Text_name:setString(v.name)

        panelTitle:releaseFunc(function()
            if self.__subTitle1Index == i then
                self.__subTitle1Index = nil
            else
                self.__subTitle1Index = i
            end

            self:showRandomMask()
        end)

        if i == self.__subTitle1Index then
            panelTitle.Image_row:setFlippedY(false)

            local panelListMask = self.__ui:creatPanelListMask()

            self.__ui:addItemToTitleList(panelListMask)

            self:initPanelListMask(panelListMask,v.list)
        else
            panelTitle.Image_row:setFlippedY(true)
        end
    end
end

function MakeMaskPresenter:initPanelListMask(panelListMask,list)
    panelListMask.ListView_Masks:removeAllItems()

    panelListMask.ListView_Masks:setItemsMargin(0)

    local maxPanelCount, isRemain = math.modf(#list / 4)

    if isRemain > 0 then
        maxPanelCount = maxPanelCount + 1
    end

    for i = 1, maxPanelCount do
        local panelMask = self.__ui:createPanelMask()

        for _i = 1,4 do
            local index = (i-1) * 4 + _i
            
            local goodsData = list[index]

            local goodsId = goodsData and goodsData.id or nil

            if goodsId then
                local goods = GoodsHelper:getGoodsResClass(goodsId)

                panelMask["Image_".._i]:setVisible(true)
                
                panelMask["Image_".._i].Text_name:setString(goods:getName())

                panelMask["Image_".._i]:releaseFunc(
                    function()
                        PopupLayerController:showLayer(
                            "MaskInfoPresenter",
                            function(layer)
                                layer:showLayer(goods:getItemId())
                            end
                        )
                    end
                )
            else
                panelMask["Image_".._i]:setVisible(false)
            end
        end

        panelListMask.ListView_Masks:pushBackCustomItem(panelMask)
    end
end

function MakeMaskPresenter:initPanelPayListMask(panelListMask,list)
    panelListMask.ListView_Masks:removeAllItems()

    panelListMask.ListView_Masks:setItemsMargin(10)

    self:__sortPayList(list)
    
    for i,v in ipairs(list) do
        local syntheticId = v.id

        local syntheticMask = self.__maskSystem:getSpecialSyntheticMask(syntheticId)

        local state = v.state

        local panelMask = self.__ui:createPanelPayMask()
        
        panelListMask.ListView_Masks:pushBackCustomItem(panelMask)
        
        local goodsId = syntheticMask:getGoodsId()

        local goods = GoodsHelper:getGoodsResClass(goodsId)
        
        local maskGrade = self:__getMaskGradeBySyntheticId(syntheticId)
        
        local makeCondition = syntheticMask:getMakeCondition()

        local makeConditionText = self.__maskSystem:getConditionText(makeCondition,self.__npc)

        panelMask.Text_name:setString(goods:getName())

        panelMask.Text_condition:setString("合成条件:" .. makeConditionText)

        panelMask.Panel_bg:releaseFunc(
            function()
                PopupLayerController:showLayer(
                    "MaskInfoPresenter",
                    function(layer)
                        layer:showLayer(goods:getItemId())
                    end
                )
            end
        )
        if state == 0 then
            panelMask.Text_make:setVisible(false)

            panelMask.Button_make:setVisible(true)

            panelMask.Button_make:releaseFunc(function()
                local isResult,msgList = self.__maskSystem:checkMaskConditions(maskGrade:getWearCondition())

                if isResult then
                    self:__showSyntheticAffirmLayer(syntheticId,panelMask)
                else
                    local affirmText = "提示:当前角色不满足佩戴条件:"

                    for i,msgText in ipairs(msgList) do
                        affirmText = affirmText.."【"..msgText.."】"
                    end 

                    affirmText = affirmText..",是否继续进行合成？"

                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:hide()
                    dialog:show(affirmText)
                    dialog:setBack(false)
                    dialog:setButton2("取消", EMPTY_FUNC)
                    dialog:setButton1(
                        "确定",
                        function()
                            self:__showSyntheticAffirmLayer(syntheticId,panelMask)
                        end
                    )
                    dialog:setWeChatVisible(false)
                end
            end)
        else
            panelMask.Text_make:setVisible(true)

            panelMask.Button_make:setVisible(false)

            panelMask.Text_make:setString("已制作")
        end
    end
end

function MakeMaskPresenter:__sortPayList(list)
    if MapIsEmpty(list) or #list < 2 then
        return
    end

    table.sort(
        list,
        function(a, b)
            local aMask = self.__maskSystem:getSpecialSyntheticMask(a.id)

            local bMask = self.__maskSystem:getSpecialSyntheticMask(b.id)

            return aMask:getSorts() < bMask:getSorts()
        end
    )
end

function MakeMaskPresenter:__showSyntheticAffirmLayer(syntheticId,panelMask)
    local syntheticMask = self.__maskSystem:getSpecialSyntheticMask(syntheticId)

    local makeCondition = syntheticMask:getMakeCondition()

    local affirmText = "合成所需条件为:"..self.__maskSystem:getConditionText(makeCondition,self.__npc).."是否制作特殊面具？"

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(affirmText)
    dialog:setBack(false)
    dialog:setButton2("取消", EMPTY_FUNC)
    dialog:setButton1(
        "确定",
        function()
            local isResult,msgList = self.__maskSystem:checkMaskConditions(makeCondition)

            if isResult then
                self.__maskSystem:makePayMask(
                    syntheticId,
                    self.__npc,
                    function(result,params)        
                        if result == 0 then
                            if params.errmsg then
                                PopText(params.errmsg)
                            end
                            PopText("制作面具失败!")
                            return
                        elseif result == 1 then
                            local goods = GoodsHelper:getGoodsResClass(params.goodsId)
                            PopText("已获得"..goods:getName())
                            PopText("发放至背包中，请注意查收!")
                        elseif result == 2 then
                            PopText("背包空间不足，奖励已发放至邮箱，请及时领取。")
                        else
                            error("未知状态  result = "..result)
                        end

                        self:showTextPayNum()

                        self:showTextSpNum()

                        panelMask.Text_make:setVisible(true)

                        panelMask.Button_make:setVisible(false)

                        panelMask.Text_make:setString("已制作")
                    end
                )
            else
                for i,msgText in ipairs(msgList) do
                    PopText(msgText)
                end
                PopText("制作面具失败!")
            end
        end
    )
    dialog:setWeChatVisible(false)
end

function MakeMaskPresenter:__getMaskGradeBySyntheticId(syntheticId)
    local syntheticMask = self.__maskSystem:getSpecialSyntheticMask(syntheticId)

    local goodsId = syntheticMask:getGoodsId()

    local goods = GoodsHelper:getGoodsResClass(goodsId)
        
    local maskGrade = self.__maskSystem:getMaskGrade(goods:getItemId(),1)

    return maskGrade
end

function MakeMaskPresenter:setRuleFunc()
    self.__ui:setRuleFunc(function()
        if self.__titleIndex == 1 then
            self:__showRule1()
        else
            self:__showRule2()
        end
    end)
end

function MakeMaskPresenter:showPayMask()
    self.__ui:removeAllTitleItems()

    local payMaskList = self.__maskSystem:getPayMaskList()
    
    for i,v in ipairs(payMaskList) do
        local panelTitle = self.__ui:createPanelTitle()

        self.__ui:addItemToTitleList(panelTitle)

        panelTitle.Text_name:setString(v.name)

        panelTitle:releaseFunc(function()
            if self.__subTitle2Index == i then
                self.__subTitle2Index = nil
            else
                self.__subTitle2Index = i
            end

            self:showPayMask()
        end)

        if i == self.__subTitle2Index then
            panelTitle.Image_row:setFlippedY(false)

            local panelListMask = self.__ui:creatPanelListMask()

            self.__ui:addItemToTitleList(panelListMask)

            self:initPanelPayListMask(panelListMask,v.list)
        else
            panelTitle.Image_row:setFlippedY(true)
        end
    end
end

function MakeMaskPresenter:__makeRandomMask()
    self.__maskSystem:makeRandomMask(
        self.__npc,
        function(result,params)        
            if result == 0 then
                PopText(params.errmsg)
                return
            elseif result == 1 then
                local goods = GoodsHelper:getGoodsResClass(params.goodsId)
                PopText("已获得"..goods:getName())
                PopText("发放至背包中，请注意查收!")
            elseif result == 2 then
                local goods = GoodsHelper:getGoodsResClass(params.goodsId)
                PopText("背包空间不足，"..goods:getName())
                PopText("已发放至邮箱，请及时领取!")
            else
                error("未知状态  result = "..result)
            end

            self:showTextSpNum()
        end
    )
end

function MakeMaskPresenter:setButton1()
    self.__ui:setButton1(
        "随机制作",
        function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            dialog:show("是否确认消耗"..self.__maskSystem:getRandomMakeCostNum(self.__npc).."饰品材料进行随机制作面具操作？")
            dialog:setButton1("确定",function()
                self:__makeRandomMask()
            end)
            dialog:setButton2("取消",function()
            end)
            dialog:setWeChatVisible(false)
        end
    )
end

function MakeMaskPresenter:setButton2()
    self.__ui:setButton2(
        "取消",
        function()
            self:hideLayer()
        end
    )
end

function MakeMaskPresenter:setPanelRuleFunc()
    self.__ui:setPanelRuleFunc(
        function()
            self.__ui:hidePanelRule()
        end
    )
end

function MakeMaskPresenter:__showRule1()
    local panelInfo = self.__ui:getPanelInfoBg()

    panelInfo.Text_title:setString("随机制作规则")

    local rulerInfoTextList = {
        "1.每次制作，基础消耗100饰品材料，若\n绣女有特性加成，则按照绣女特性数值\n降低。",
        "2.不同类别的面具价值不同。",
        "3.不定期某一类面具会随机新增一个面具。",
        "4.饰品材料可通过重复面具/挂饰放入饰\n品箱，通过绣女分解。",
        "5.可点击面具名字进行预览。",
        "6.面具的抽取概率如下："
    }

    self:__showRuleInfoText(rulerInfoTextList)

    panelInfo.ListView_rulerInfo:setVisible(true)
    
    panelInfo.ListView_rulerInfo:setSize({width = 988.0000, height = 857.0000})
    
    panelInfo.ListView_info:setVisible(true)
    
    self.__ui:removeAllRuleItems()

    local maskList = self.__maskSystem:getRandomMaskList()
    
    for i,v in ipairs(maskList) do
        local panelTitle = self.__ui:createPanelText()

        self.__ui:addItemToRuleList(panelTitle)

        panelTitle.Text_1:setString(v.name)

        panelTitle.Text_2:setString("")

        panelTitle.Text_3:setString("")

        local list = v.list
        
        local maxPanelCount, isRemain = math.modf(#list / 3)

        if isRemain > 0 then
            maxPanelCount = maxPanelCount + 1
        end

        for _i = 1, maxPanelCount do
            local panelText = self.__ui:createPanelText()

            for __i = 1,3 do
                local index = (_i-1) * 3 + __i
                
                local goodsData = list[index]

                local goodsId = goodsData and goodsData.id or nil

                if goodsId and goodsData.odds then
                    local goods = GoodsHelper:getGoodsResClass(goodsId)

                    panelText["Text_"..__i]:setVisible(true)
                    
                    panelText["Text_"..__i]:setString(goods:getName()..":"..tostring(goodsData.odds))
                else
                    panelText["Text_"..__i]:setVisible(false)
                end
            end

            self.__ui:addItemToRuleList(panelText)
        end
    end

	self.__ui:showPanelRule()
end

function MakeMaskPresenter:__showRule2()
    local panelInfo = self.__ui:getPanelInfoBg()

    panelInfo.Text_title:setString("特殊制作规则")
    
    local rulerInfoTextList = {
        "1.可点击面具名字进行预览。",
        "2.每次特殊制作需要消耗不同的材料，不\n同面具所需要的材料数不同。若绣女有特\n性加成，则饰品材料的消耗数量按照绣女\n特性数值降低，其他材料数量不受影响。",
        "3.有些特殊的面具合成和佩戴需要满足特\n定条件，具体请看面具列表界面。",
        "4.有些特殊的面具合成后，可以到墨千秋\n的赠礼活动，按对应奖励周期获得相应的\n道具。",
        "5.饰品材料可通过重复面具/挂饰放入饰\n品箱，通过绣女分解。",
        "6.鹿胶可通过招财进宝活动获得。"
    }

    self:__showRuleInfoText(rulerInfoTextList)

    panelInfo.ListView_rulerInfo:setVisible(true)
    
    panelInfo.ListView_rulerInfo:setSize({width = 988.0000, height = 1000.0000})

    panelInfo.ListView_info:setVisible(false)

    self.__ui:removeAllRuleItems()

	self.__ui:showPanelRule()
end

function MakeMaskPresenter:__showRuleInfoText(rulerInfoTextList)
    self.__ui:removeAllRuleInfoItems()

    for i,text in ipairs(rulerInfoTextList) do
        local textRow = self.__ui:createRulerInfoText()

        textRow:setString(text)

        self.__ui:addItemToRuleInfoList(textRow)
    end
end

function MakeMaskPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "MakeMaskPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(MakeMaskPresenter)
return MakeMaskPresenter
000000