local MeridianSkillPeiYuanLayer = class("MeridianSkillPeiYuanLayer", cc.Layer)

function MeridianSkillPeiYuanLayer:create()
    local p = MeridianSkillPeiYuanLayer:new()
    p:init()
    return p
end

function MeridianSkillPeiYuanLayer:init()
    self.__ui = require("app.views.ui.SkillUI.MeridianSkillPeiYuanUI"):create()

    self.__ui:addTo(self)
end

function MeridianSkillPeiYuanLayer:showLayer()
    self.__selectId = nil

    self.__changeId = nil

    self:setTitle()

    self:setButtonBack()

    self:setTextLeftName()

    self:setTextRightName()

    self:initLeftListView()

    self:initRightListView()

    self:setTextLeftSpeed()

    self:setTextRightSpeed()

    self:setButtonLeft()

    self:setButtonRight()

    self:refreshImprintingDetail()

    self.__ui:showUI()
end

function MeridianSkillPeiYuanLayer:setModel(model)
    --@RefType [src.app.models.skill.MeridianSkillUtil#MeridianSkillUtil]
    self.__model = model
end

function MeridianSkillPeiYuanLayer:setTitle(text)
    self.__ui:setTitle("真气化元")
end

function MeridianSkillPeiYuanLayer:setButtonBack()
    self.__ui:setButtonBack(
        function()
            PopupLayerController:hideLayer("MeridianSkillPeiYuanLayer",function()
                self.__ui:hideUI()
            end)
        end
    )
end

function MeridianSkillPeiYuanLayer:setTextLeftName()
    local text = ""
    if self.__selectId then
        local imprinting = self.__model:getImprintingById(self.__selectId)

        text = imprinting:getName()
    end
    
    self.__ui:setTextLeftName(text)
end

function MeridianSkillPeiYuanLayer:setTextRightName()
    local text = ""
    if self.__changeId then
        local imprinting = self.__model:getImprintingById(self.__changeId)

        text = imprinting:getName()
    end
    
    self.__ui:setTextRightName(text)
end

function MeridianSkillPeiYuanLayer:initLeftListView()
    local array = self.__model:getLeftMeridianList()

    table.sort(
        array,
        function(a, b)
            return a:getIndexId() < b:getIndexId()
        end
    )

    local retArray = {}

    for i,v in ipairs(array) do
        v = v
        local retTab = {}

        retTab.name = v:getName()

        retTab.func = function()
            self.__selectId = v:getImprintingId()

            self:setTextLeftName()
        end

        table.insert(retArray, retTab)
    end

    self.__ui:setLeftListView(retArray)
end

function MeridianSkillPeiYuanLayer:initRightListView()
    local array = self.__model:getRightMeridianList()

    table.sort(
        array,
        function(a, b)
            return a:getIndexId() < b:getIndexId()
        end
    )
    
    local retArray = {}

    for i,v in ipairs(array) do
        local retTab = {}

        retTab.name = v:getName()

        retTab.func = function()
            self.__changeId = v:getImprintingId()

            self:setTextRightName()

            self:setTextLeftSpeed()

            self:setTextRightSpeed()

            self:refreshImprintingDetail()
        end

        table.insert(retArray, retTab)
    end

    self.__ui:setRightListView(retArray)
end

function MeridianSkillPeiYuanLayer:setTextLeftSpeed()
    local text = ""
    if self.__changeId then
        local speed = self.__model:getPeiYuanBreathVal(self.__changeId)
        text = "所需："..speed.."真气"
    end
    
    self.__ui:setTextLeftSpeed(text)
end

function MeridianSkillPeiYuanLayer:setTextRightSpeed()
    local text = ""
    if self.__changeId then
        local speed = self.__model:getPeiYuanZhenQiDanNum(self.__changeId)
        text = "所需："..speed.."颗真气丹"
    end
    
    self.__ui:setTextRightSpeed(text)
end

function MeridianSkillPeiYuanLayer:setButtonLeft()
    self.__ui:setButtonLeft("御气化元",function()
        if self.__selectId == nil then
            PopText("请选择需更换的经脉印记后再次尝试化元")
            return
        end

        if self.__changeId == nil then
            PopText("请选择更换的目标印记后再次尝试化元")
            return
        end
        
        self:showBreathValPopConfirmLayer()
    end)
end

function MeridianSkillPeiYuanLayer:setButtonRight()
    self.__ui:setButtonRight("施丹化元",function()
        if self.__selectId == nil then
            PopText("请选择需更换的经脉印记后再次尝试化元")
            return
        end

        if self.__changeId == nil then
            PopText("请选择更换的目标印记后再次尝试化元")
            return
        end

        self:showZhenQiDanPopConfirmLayer()
    end)
end

function MeridianSkillPeiYuanLayer:showBreathValPopConfirmLayer()
    local speed = self.__model:getPeiYuanBreathVal(self.__changeId)

    local currValue = Helper:mathFloor(self.__model:getBreathVal())

    local selectImprinting = self.__model:getImprintingById(self.__selectId)

    local selectName = selectImprinting:getName()

    local changeImprinting = self.__model:getImprintingById(self.__changeId)

    local changeName = changeImprinting:getName()

    local resetTimeText = ""

    if self.__model:isFirstUse() then
        resetTimeText = "首次化元开始计时"
    else
        local resetTime = self.__model:getMeridianSkillResetTime()

        local hour = math.ceil(resetTime / 3600)

        resetTimeText = math.floor(hour / 24).."天"..math.floor(hour % 24).."时"
    end

    PopupLayerController:showLayer(
        "MeridianSkillUseConfirmUI",
        function(layer)
            layer:setButton1(
                "是",
                function()
                    local result,msg = self.__model:breathValPeiYuan(self.__selectId,self.__changeId)

                    if result == false then
                        PopText(msg)
                        return
                    end

                    self.__selectId = nil

                    self.__changeId = nil

                    self:setTextLeftName()

                    self:setTextRightName()
                
                    self:initLeftListView()
                
                    self:initRightListView()
                
                    self:setTextLeftSpeed()
                
                    self:setTextRightSpeed()

                    self:refreshImprintingDetail()

                    layer:hideUI()

                    PopText("御气化元成功")
                end
            )

            layer:setButton2(
                "否",
                function()
                    layer:hideUI()
                end
            )

            layer:setTextDesc("是否消耗"..speed.."真气进行化元，把"..selectName.."更换为"..changeName.."？")
                
            layer:setTextBreathVal("当前真气："..currValue)

            layer:setTextUseTime("当前化元次数："..self.__model:getUseMeridianSkillTime() + 1)

            layer:setTextResetTime("消耗重置时间："..resetTimeText)

            layer:showLayer()
        end
    )
end

function MeridianSkillPeiYuanLayer:showZhenQiDanPopConfirmLayer()
    local speed = self.__model:getPeiYuanZhenQiDanNum(self.__changeId)

    local currValue = self.__model:getZhenQiDanNum()

    local selectImprinting = self.__model:getImprintingById(self.__selectId)

    local selectName = selectImprinting:getName()

    local changeImprinting = self.__model:getImprintingById(self.__changeId)

    local changeName = changeImprinting:getName()

    local resetTimeText = ""

    if self.__model:isFirstUse() then
        resetTimeText = "首次化元开始计时"
    else
        local resetTime = self.__model:getMeridianSkillResetTime()

        local hour = math.ceil(resetTime / 3600)

        resetTimeText = math.floor(hour / 24).."天"..math.floor(hour % 24).."时"
    end
    
    PopupLayerController:showLayer(
        "MeridianSkillUseConfirmUI",
        function(layer)
            layer:setButton1(
                "是",
                function()
                    local result, msg = self.__model:zhenQiDanPeiYuan(self.__selectId, self.__changeId)

                    if result == false then
                        PopText(msg)
                        return
                    end

                    self.__selectId = nil

                    self.__changeId = nil

                    self:setTextLeftName()

                    self:setTextRightName()

                    self:initLeftListView()

                    self:initRightListView()

                    self:setTextLeftSpeed()

                    self:setTextRightSpeed()

                    self:refreshImprintingDetail()

                    layer:hideUI()

                    PopText("施丹化元成功")
                end
            )

            layer:setButton2(
                "否",
                function()
                    layer:hideUI()
                end
            )

            layer:setTextDesc("是否消耗"..speed.."真气丹进行化元，把"..selectName.."更换为"..changeName.."？")
                
            layer:setTextBreathVal("当前真气丹："..currValue)

            layer:setTextUseTime("当前化元次数："..self.__model:getUseMeridianSkillTime() + 1)

            layer:setTextResetTime("消耗重置时间："..resetTimeText)

            layer:showLayer()
        end
    )
end

function MeridianSkillPeiYuanLayer:refreshImprintingDetail()
    if self.__changeId == nil then
        self.__ui:hideImprintingDetail()
    else
        self.__ui:showImprintingDetail()

        local changeImprinting = self.__model:getImprintingById(self.__changeId)
        
        local retData = {
            name = changeImprinting:getName(),
            type = changeImprinting:getType(),
            text = changeImprinting:getText(),
        }

        self.__ui:setImprintingDetail(retData)
    end
end

Helper:classDefNodeGetInstance(MeridianSkillPeiYuanLayer)
return MeridianSkillPeiYuanLayer
000000000