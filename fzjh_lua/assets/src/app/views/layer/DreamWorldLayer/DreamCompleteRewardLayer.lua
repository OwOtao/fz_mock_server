local DreamCompleteRewardLayer = class("DreamCompleteRewardLayer", LayerEx)

function DreamCompleteRewardLayer:create()
    local p = DreamCompleteRewardLayer:new()
    p:init()
    return p
end

function DreamCompleteRewardLayer:init()
    self._UI = require("Layer.DreamWorldUI.DreamCompleteRewardUI.lua").create()['root']
	self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.play_status = 0
    self.currIndex = 1
    self._ui_list = {}
end

function DreamCompleteRewardLayer:hideLayer()
    PopupLayerController:hideLayer("DreamCompleteRewardLayer",function (layer)
        layer:hide()
    end)
end

function DreamCompleteRewardLayer:showLayer(rewardList,eFloor,func)
    self.play_status = 0
    self.currIndex = 1
    self._ui_list = {}

    self:setTitleText()
    self:initUi(rewardList,eFloor)
    self:setPanelBack(func)
    self:show()
end

function DreamCompleteRewardLayer:setTitleText()
    self.Text_title:setString("周公解梦")
end

function DreamCompleteRewardLayer:initUi(rewardList,eFloor)
    local text1 = ""
    local text2 = ""
    local text3 = ""
    local text4 = ""
    
    if eFloor >= 11 then
        text1 = "浓睡品深梦，暮雨落栏杆。千帆沉浮，行顾细谨，浩瀚烟海新。"
        text4 = "YEL判曰：千朝唯君。NOR"
    elseif eFloor >= 6 then
        text1 = "悠然坠梦，残梦渐深。幽光映千里，运良策，细心行阡陌。"
        text4 = "YEL判曰：凤栖高崖。NOR"
    else
        text1 = "梦露初华，萤火三千。浅梦终须醒，闲步断桥，欲攀高。"
        text4 = "YEL判曰：潜龙未醒。NOR"
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
                            yiyuText = "梦尚缱绻，恍然间你耳边响起一声悠远的低语，直至初醒，仍在你脑海中萦绕不散。"
                        else
                            yiyuText = "梦尚缱绻，恍然间你耳边响起一声悠远的低语，但你思绪凌乱，无法记住更多梦内呓语了。"
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

function DreamCompleteRewardLayer:setPanelBack(func)
    local isFinish = false

    self.Panel_back:releaseFunc(function()
        if isFinish then
            return
        end

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

            isFinish = true
            
            self:hideLayer()
        end
	end)
end

function DreamCompleteRewardLayer:runFadeIn(ft,ui)
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

Helper:classDefNodeGetInstance(DreamCompleteRewardLayer)
return  DreamCompleteRewardLayer0000000000