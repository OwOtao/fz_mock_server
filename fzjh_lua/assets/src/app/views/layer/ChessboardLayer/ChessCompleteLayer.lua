local ChessCompleteLayer = class("ChessCompleteLayer", LayerEx)

function ChessCompleteLayer:create()
    local p = ChessCompleteLayer:new()
    p:init()
    return p
end

function ChessCompleteLayer:init()
    self._UI = require("Layer.DreamWorldUI.DreamCompleteRewardUI.lua").create()['root']
	self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.play_status = 0
    self.currIndex = 1
    self._ui_list = {}
end

function ChessCompleteLayer:showLayer(rewardList,floor,func)
    self.play_status = 0
    self.currIndex = 1
    self._ui_list = {}

    self:setTitleText()
    self:initUi(rewardList,floor)
    self:setPanelBack(func)
    self:show()
end

function ChessCompleteLayer:setTitleText()
    self.Text_title:setString("烂柯棋局")
end

function ChessCompleteLayer:initUi(rewardList,floor)
    local text1 = ""
    local text2 = ""
    local text3 = ""
    local text4 = ""
    
    if floor >= 6 then
        text1 = "拨云见日，曙光初现，成竹在胸，一子落定，胜券在握。"
        text4 = "YEL判曰：落子成局。NOR"
    else
        text1 = "云迷雾锁，进退维谷，举棋不定，不胜其耦。"
        text4 = "YEL判曰：当局者迷。NOR"
    end

    self.Panel_1.Text_4:setString(text4)
    
    if MapIsEmpty(rewardList) == false then
        local isShowYiyuText = false
        local yiyuText = ""
        if MapIsEmpty(rewardList.loc_attrTab) == false then
            for attrType,number in pairs(rewardList.loc_attrTab) do
                if RewardManager2:getAttrName(attrType) then
                    text2 = text2..tostring(number)..User:getRole():getCHAttrName(RewardManager2:getAttrName(attrType)).."\n"
                end
            end
        end  
        
        if MapIsEmpty(rewardList.net_attrTab) == false then
            for attrType,number in pairs(rewardList.net_attrTab) do
                if RewardManager2:getAttrName(attrType) then
                    text2 = text2..tostring(number)..User:getRole():getCHAttrName(RewardManager2:getAttrName(attrType)).."\n"

                    if RewardManager2:getAttrName(attrType) == "dreamYiYu"then
                        isShowYiyuText = true
                        if number > 0 then
                            yiyuText = "观棋入梦，缥缈若虚，你恍惚间听见声声低语，一梦初醒，仍在脑海中缭绕不去。"
                        else
                            yiyuText = "观棋入梦，缥缈若虚，你恍惚间听见声声低语，待梦醒时分，皆如过眼云烟，消散一空。"
                        end
                    end
                end
            end
        end
        
        if MapIsEmpty(rewardList.skillTab) == false then
            for i,v in ipairs(rewardList.skillTab) do
                local skillType = v.skillType
                if tonumber(skillType) == 1 then
                    local skillId = v.skillId
                    local skillName = Skill:getSkill(skillId).name

                    --@desc 替换技能文本颜色
                    for _, v in pairs(GetColorList()) do
                        local s, e = string.find(skillName, v.id)
                        if s ~= nil and e ~= nil then
                            skillName = string.gsub(skillName,v.id,"YEL")
                        end
                    end

                    if skillId == "zhougongzhishu" then
                        text2 = text2.."\n周公之术+"..v.skillValue.."经验"
                    else
                        text3 = text3..skillName.."\n"
                    end
                end     
            end
        end

        if isShowYiyuText == true then
            text2 = text2.."\n\n"..yiyuText
        end
    end

    local textList = {
        ["1"] = text1,
        ["2"] = text2,
        ["3"] = text3,
    }

    for i = 1,3 do
        local text = textList[tostring(i)]
        local ui = self["Panel_"..i]
        
        if not ui then
            return
        end
        
        ui:setOpacity(0)

        if text and text ~= "" then
            ui.Text_2:setString(text)
            table.insert(self._ui_list, ui)
        end
    end
end

function ChessCompleteLayer:setPanelBack(func)
    self.Panel_back:releaseFunc(function()
        local ui = self._ui_list[self.currIndex]
        if ui then
            if self.play_status ~= 1 then
                ui:scheduleUnique(
                    function(ft)
                        self:runFadeIn(ft,ui)

                        if self.play_status == 2 then
                            ui:unscheduleWithTag("panel_fadeIn")
                            self.currIndex = self.currIndex + 1
                        end
                    end,
                    1 / 30,
                    "panel_fadeIn"
                )
            else
                print("正在播放")
            end
        else
            if func then
                func()
            end
            self:hideLayer()
        end
	end)
end

function ChessCompleteLayer:hideLayer()
    PopupLayerController:hideLayer("ChessCompleteLayer",function (layer)
        layer:hide()
    end)
end


function ChessCompleteLayer:runFadeIn(ft,ui)
    local nowOpacity = ui:getOpacity()

    local isOpacityFish = false
    if nowOpacity >= 255 then
        isOpacityFish = true
    else
        ui:setOpacity(math.min(nowOpacity + (255 / 1) * ft, 255))
        isOpacityFish = false
    end

    if isOpacityFish then
        self.play_status = 2
    else
        self.play_status = 1
    end
end

Helper:classDefNodeGetInstance(ChessCompleteLayer)
return  ChessCompleteLayer00000000