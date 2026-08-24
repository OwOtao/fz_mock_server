local DreamTalentLayer = class("DreamTalentLayer", LayerEx)
local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")
local OPERTION_EVENT_NAME = DreamConst.OpertionEventName

local DreamTalentPresenter = require("app.presenters.dream.talent.DreamTalentPresenter")
local IDreamTalentPresenterInput = require("app.presenters.dream.talent.IDreamTalentPresenterInput")
local IDreamTalentPresenterOutput = require("app.presenters.dream.talent.IDreamTalentPresenterOutput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function DreamTalentLayer:create()
    local p = DreamTalentLayer:new()
    p:init()
    return p
end

function DreamTalentLayer:init()
    self._UI = require("Layer/DreamWorldUI/DreamTalentUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)    

    self._iDreamTalentPresenterInput = isImplement(DreamTalentPresenter:create(self, DreamTalentModel), IDreamTalentPresenterInput)
end

function DreamTalentLayer:showLayer()
    self._iDreamTalentPresenterInput:showLayer()
end

function DreamTalentLayer:setShowLayer()
    self:show()
end

--设置梦境币数值
function DreamTalentLayer:setDreamCoinsText(text)
    self.Text_money:setString(text)
end

function DreamTalentLayer:setLvText(text)
    self.Text_lv:setString(text)
end

function DreamTalentLayer:setDescText(text)
    self.Text_dsc:setString(text)
end

function DreamTalentLayer:setListView(talentList)
    local mod, remainder = math.modf(#talentList / 3)
    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end

    for i = 1, mod do
        local panel = self.ListView_1:getItem(i - 1)
        if panel == nil then
            panel = self.Panel_1:clone()

            self.ListView_1:pushBackCustomItem(panel)
        end
        
        Helper:convertUIByParent(panel)

        for k = 1,3 do
            local index = (i-1)*3 + k
            local talent = talentList[index]
            if talent then
                panel["Panel_item"..k]:setVisible(true)
                panel["Panel_item"..k].Image_hongdian:setVisible(talent.hongdianVisible)
                panel["Panel_item"..k].dian:setVisible(talent.dianVisible)
                panel["Panel_item"..k].Image_5.Text_name:setString(talent.name)
                panel["Panel_item"..k].Image_5.Text_name:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
                panel["Panel_item"..k].Image_5.Text_name:setTextColor(talent.nameColor)
              
                panel["Panel_item"..k]:releaseFunc(function()
                    if type(talent.buttonFunc) == "function" then
                        talent.buttonFunc()
                    end
                end)
            else
                panel["Panel_item"..k]:setVisible(false)
            end
        end
    end
end

function DreamTalentLayer:showTalentInfo(data,buttonName,func)
    local tital = data.tital
    local typeDsc = data.typeDsc
    local talenDsc = data.talenDsc
    local tip3 = data.tip3
    local levelDsc = data.levelDsc

    PopupLayerController:showLayer("DreamTalentInfoLayer", function(layer)
        layer:setTitle(tital)
        layer:setTalentTypeText(typeDsc)
        layer:setTalentDsc(talenDsc)
        layer:setUnlockButton(buttonName,function()
            if func then
                func()
            end
            layer:hideLayer()
        end)
        layer:setDesc1(levelDsc)
        layer:setDesc3(tip3)
        layer:showLayer()
    end)
end

function DreamTalentLayer:popText(text)
    PopText(text)
end

function DreamTalentLayer:setShowConfirmLayer(text,func)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(text)
    dialog:setButton1("确定",function()
        if func then
            func()
        end
    end)
    dialog:setButton2("取消",function()
    end)
    dialog:setWeChatVisible(false)
end

isImplement(DreamTalentLayer,IDreamTalentPresenterOutput)
Helper:classDefNodeGetInstance(DreamTalentLayer)
return DreamTalentLayer
00000