local UseTalentLayer = class("UseTalentLayer", LayerEx)
local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")

function UseTalentLayer:create()
    local p = UseTalentLayer:new()
    p:init()
    return p
end

function UseTalentLayer:init()
    self._UI = require("Layer.DreamWorldUI.UseTalentUI.lua").create()['root']
	self._UI:addTo(self)

    Helper:convertUIByParent(self)
    self:setShowAndHideAnimType(1)
    self:setPanelBack()
end

function UseTalentLayer:hideLayer()
    PopupLayerController:hideLayer("UseTalentLayer",function (layer)
        layer:hide()
    end)
end

function UseTalentLayer:showLayer(list,map)
    self:initUi(list,map)
    self:show()
end

function UseTalentLayer:initUi(list,map)
    self.ListView_1:removeAllItems()
    if MapIsEmpty(list) or MapIsEmpty(map) then
        return
    end
    local role = map:getPlayer()
    
    for k, v in pairs(list) do
        local panel = self.Panel_item:clone()
        Helper:convertUIByParent(panel)

        local talentId = k
        local talentAttr = DreamTalentModel:getTalentAttrById(talentId)
        if talentAttr == nil then
            assert(false,"没有这条天赋 talentId = "..talentId)
        end

        local needSorb = string.split(talentAttr.drtfvalue,";")
        needSorb = math.random(tonumber(needSorb[1]),tonumber(needSorb[2]))
        
        panel.Text_1:setString(talentAttr.drtfname)
        panel.Text_2:setString(talentAttr.drtftext)
        panel.Button_use.Text_buttonName:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
        panel.Button_use:releaseFunc(function()
            if role:getAttr("sober") <= 0 then
                PopText("当前处于梦醒状态，无法使用天赋技能")
                return
            end
            print("effectType = ",talentAttr.effectType)
            local currSorbText = DreamTalentModel:getCurrSorbText(role:getAttr("sober"))
            local consumeSorbText = DreamTalentModel:getConsumeSorbText(needSorb)
            local WarnSorbText = DreamTalentModel:getWarnSorbText(role:getAttr("sober") - needSorb)
            local titalText = talentAttr.drtftktext
            if titalText == nil or titalText == 0 then
                titalText = ""
            end
            PopupLayerController:showLayer("DialogUseLayer", function(layer)
                layer:show()
                layer:setTitle(titalText)
                layer:setTextUseGoods(currSorbText.."，"..consumeSorbText.."。")
                layer:setTextDesc(WarnSorbText)
                layer:setButton1(function()
                    DreamTalentModel:useTalentFunc(talentId,map,role,needSorb,function()
                        self:hideLayer()
                    end)
                end)
                layer:setButton2()
            end)
        end)
        
        self.ListView_1:pushBackCustomItem(panel)
    end
end

function UseTalentLayer:setPanelBack()
    self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)
end

Helper:classDefNodeGetInstance(UseTalentLayer)
return  UseTalentLayer00