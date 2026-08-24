local WareHouseUI = class("WareHouseUI", LayerEx)

function WareHouseUI:create()
    local p = WareHouseUI:new()
    p:init()
    return p
end

function WareHouseUI:init()
    self._UI = require("Layer/ActionUI/WareHouseUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function WareHouseUI:showUI()
    self:setVisible(true)
    self:show()
end

function WareHouseUI:hideUI()
    self:setVisible(false)
    self:hide()
end

function WareHouseUI:showLayer(func)
    PopupLayerController:showLayer("WareHouseUI",function()
        if func then
            func()
        end
    end)
end

function WareHouseUI:hideLayer(func)
    PopupLayerController:hideLayer("WareHouseUI",function()
        if func then
            func()
        end
    end)
end

function WareHouseUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function WareHouseUI:setTextTitle(title)
    self.Text_title:setString(title)
end

function WareHouseUI:setTextDesc(desc)
    self.Text_desc:setString(desc)
end

function WareHouseUI:setText1Str(str)
    self.Button_1.Text_1:setString(str)
end

function WareHouseUI:setText2Str(str)
    self.Text_2:setString(str)
end

function WareHouseUI:setTextFloorNum(str)
    self.Text_floorNum:setString(str)
end

function WareHouseUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function WareHouseUI:setButtonSecretFunc(func)
    self.Button_secretTips:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function WareHouseUI:setButtonBatchFunc(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function WareHouseUI:setLoadingBarPercent(percent)
    self.LoadingBar_1:setPercent(percent)
end

function WareHouseUI:setProgressPanel(index,data)
    local panel = self["progressPanel_"..index]
    panel.Text_1:setString(data.text1)
    panel.Text_2:setString(data.text2)
    panel.Image_diKuang:loadTexture(data.Image_diKuang,0)
    panel.Image_item:loadTexture(data.Image_item,0)
    panel.Panel_di:setVisible(data.Panel_diViseble)
    panel.Image_state:setVisible(data.Image_stateViseble)
    panel:releaseFunc(function()
        if data.func then
            data.func()
        end
    end)
end

function WareHouseUI:createProgressPanel(index, pos)
    if self["progressPanel_"..index] then
    else
        local panel = self.Panel_1:clone()
        Helper:convertUIByParent(panel)
        panel:addTo(self)
        self["progressPanel_"..index] = panel
    end
    
    self["progressPanel_"..index]:setPosition(pos)
    self["progressPanel_"..index]:setVisible(true)
end

function WareHouseUI:setAwardPanel(index,data)
    local panel = self["Panel_award"..index]
    if data.buttonState == 0 then
        panel.Image_block1:setOpacity(255)
        panel.Image_block2:setOpacity(0)
        panel.Image_hongdi:setOpacity(0)
        panel.Image_landi:setOpacity(0)
        panel.Image_hongguang:setOpacity(0)
        panel.Image_languang:setOpacity(0)
        panel.Image_yu1:setOpacity(255)
        panel.Image_yu1:setRotation(0)
        panel.Image_yu2:setOpacity(0)
        panel.Image_yu2:setRotation(0)
        panel.Image_yu3:setOpacity(0)
        panel.Image_yu3:setRotation(0)
        panel.Image_yu4:setOpacity(0)
        panel.Image_yu4:setRotation(0)
        panel.Image_heizhezhao:setOpacity(0)
        panel.Image_hongkuang:setOpacity(0)
        panel.Image_lankuang:setOpacity(0)
        panel.Text_1:setVisible(false)
    elseif data.buttonState == 1 then
        panel.Image_block1:setOpacity(0)
        panel.Image_block2:setOpacity(255)
        panel.Image_hongdi:setOpacity(0)
        panel.Image_landi:setOpacity(0)
        panel.Image_hongguang:setOpacity(255)
        panel.Image_languang:setOpacity(0)
        panel.Image_yu1:setOpacity(0)
        panel.Image_yu2:setOpacity(0)
        panel.Image_yu3:setOpacity(255)
        panel.Image_yu3:setRotation(270)
        panel.Image_yu4:setOpacity(0)
        panel.Image_heizhezhao:setOpacity(0)
        panel.Image_hongkuang:setOpacity(0)
        panel.Image_lankuang:setOpacity(0)
        panel.Text_1:setVisible(true)
    elseif data.buttonState == 2 then
        panel.Image_block1:setOpacity(0)
        panel.Image_block2:setOpacity(255)
        panel.Image_hongdi:setOpacity(0)
        panel.Image_landi:setOpacity(0)
        panel.Image_hongguang:setOpacity(0)
        panel.Image_languang:setOpacity(0)
        panel.Image_yu1:setOpacity(0)
        panel.Image_yu2:setOpacity(0)
        panel.Image_yu3:setOpacity(0)
        panel.Image_yu4:setOpacity(255)
        panel.Image_heizhezhao:setOpacity(0)
        panel.Image_hongkuang:setOpacity(0)
        panel.Image_lankuang:setOpacity(0)
        panel.Text_1:setVisible(false)
    end

    panel:setTouchEnabled(true)
    panel:releaseFunc(function()
        if data.buttonState == 0 then
            self:setPanelAwardsTouchEnabled(false)
            self:delayFunc(0.5, function()
                self:setPanelAwardsTouchEnabled(true)
            end)
            data.func()
        else
            data.func()
        end
    end)
end

function WareHouseUI:setPanelAwardsTouchEnabled(boole)
    for i = 1,9 do
        local panel = self["Panel_award"..i]
        panel:setTouchEnabled(boole)
    end
end

function WareHouseUI:playAnimHui(index)
    local panel = self["Panel_award"..index]
    panel.Image_block1:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.25),
            cc.CallFunc:create(function()
                cc.FadeOut:create(0.25)
                panel.Image_block2:runAction(
                    cc.FadeIn:create(0.25)
                )
            end)
        )
    )

    panel.Image_yu1:runAction(
        cc.Spawn:create(
            cc.RotateBy:create(0.5, 360),
            cc.Sequence:create(
                cc.DelayTime:create(0.25),
                cc.FadeOut:create(0.25)
            )
        )
    )
   
    panel.Image_yu4:runAction(
        cc.Spawn:create(
            cc.RotateBy:create(0.5, 360),
            cc.Sequence:create(
                cc.DelayTime:create(0.25),
                cc.FadeIn:create(0.25)
            )
        )
    )
end

function WareHouseUI:playAnimHong(index)
    local panel = self["Panel_award"..index]
    panel.Image_block1:runAction(
        cc.Sequence:create(
            cc.FadeOut:create(0.25),
            cc.CallFunc:create(function()
                panel.Image_block2:runAction(
                    cc.FadeIn:create(0.25)
                )
                panel.Text_1:setVisible(true)
            end)
        )
    )
    panel.Image_hongdi:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.25),
            cc.FadeOut:create(0.25)
        )
    )
    panel.Image_hongguang:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.25),
            cc.FadeIn:create(0.25)
        )
    )
    panel.Image_yu1:runAction(
        cc.Spawn:create(
            cc.FadeOut:create(0.25),
            cc.Sequence:create(
                cc.RotateTo:create(0.25, 180),
                cc.RotateTo:create(0.25, 270)
            )
        )
    )
    panel.Image_yu2:runAction(
        cc.Spawn:create(
            cc.Sequence:create(
                cc.RotateTo:create(0.25, 180),
                cc.RotateTo:create(0.25, 270)
            ),
            cc.Sequence:create(
                cc.FadeIn:create(0.25),
                cc.FadeOut:create(0.25)
            )
        )
    )
    panel.Image_yu3:runAction(
        cc.Sequence:create(
            cc.RotateTo:create(0.25, 180),
            cc.Spawn:create(
                cc.RotateTo:create(0.25, 270),
                cc.FadeIn:create(0.25)
            )
        )
    )

    panel.Image_heizhezhao:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.25),
            cc.FadeOut:create(0.25)
        )
    )
    panel.Image_hongkuang:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.25),
            cc.FadeOut:create(0.25)
        )
    )
end

function WareHouseUI:playAnimLan(index)
    local panel = self["Panel_award"..index]
    panel.Image_block1:runAction(
        cc.Sequence:create(
            cc.FadeOut:create(0.25),
            cc.CallFunc:create(function()
                panel.Image_block2:runAction(
                    cc.FadeIn:create(0.25)
                )
            end)
        )
    )
    panel.Image_landi:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.25),
            cc.FadeOut:create(0.25)
        )
    )
    panel.Image_languang:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.25),
            cc.FadeOut:create(0.25)
        )
    )
    panel.Image_yu1:runAction(
        cc.Spawn:create(
            cc.FadeOut:create(0.25),
            cc.RotateBy:create(0.5, 360)
        )
    )
    panel.Image_yu2:runAction(
        cc.Spawn:create(
            cc.RotateBy:create(0.5, 360),
            cc.Sequence:create(
                cc.FadeIn:create(0.25),
                cc.FadeOut:create(0.25)
            )
        )
    )

    panel.Image_yu4:runAction(
        cc.Spawn:create(
            cc.Sequence:create(
                cc.DelayTime:create(0.25),
                cc.FadeIn:create(0.25)
            )
        )
    )

    panel.Image_heizhezhao:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.25),
            cc.FadeOut:create(0.25)
        )
    )
    panel.Image_lankuang:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(0.25),
            cc.FadeOut:create(0.25)
        )
    )
end

function WareHouseUI:popText(text,delayTime)
    if delayTime == nil then
        delayTime = 0
    end
    self:delayFunc(delayTime, function()
        PopText(text)
    end)
end

Helper:classDefNodeGetInstance(WareHouseUI)
return WareHouseUI
0000000