local HeroFeastThreePhaseLayer = class("HeroFeastThreePhaseLayer", LayerEx)
local HeroFeastModel = require("app.models.Action.HeroFeast.HeroFeastModel")

function HeroFeastThreePhaseLayer:create()
	local p = HeroFeastThreePhaseLayer:new()
	p:init()
	return p
end
function HeroFeastThreePhaseLayer:init()
	local UI = require("Layer/ActionUI/HeroFeast/HeroFeastAwardUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

	self:setPanelBack()
end

function HeroFeastThreePhaseLayer:showLayer()
    self.Text_desc:setString("活动期间，除夕至初六期间成功举办宴会，则可在此处领取对应宴会的额外奖励。七天全部举办成功，还可领取专有头衔。所有奖励将保留到2月24日，逾期将会自动移除。为防止奖励失效，请及时领取，详细规则请查看公告。")
    self:getQqRewards()
    self:initPanel()
    self:show()
end


function HeroFeastThreePhaseLayer:setPanelBack()
	self.Button_back:releaseFunc(function()
		PopupLayerController:hideLayer("HeroFeastThreePhaseLayer",function (layer)
            layer:hide()
        end)
	end)
end

function HeroFeastThreePhaseLayer:initPanel()
    local role = User:getRole()
    local flagTab = role:getInheritFlag("2021英雄宴奖励")
    if flagTab == 0 then
        flagTab = {}
    end
    for i = 1,7 do
        local panel = self.ListView_1:getItem(i - 1)
		if panel == nil then
			panel = self.Panel_1:clone()
			self.ListView_1:pushBackCustomItem(panel)
		end
        Helper:convertUIByParent(panel)
        
        panel.Text_desc2:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        panel.Text_desc3:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        panel.Button_Reward.Text_buttonName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
        
        local itemAward,attrAward = HeroFeastModel:getThirdStageAward(i)
        local Feastdata = HeroFeastModel:getHeroFeastDataByTime(i)
        local flagData = flagTab[tostring(i)]
        local text1 = Feastdata.day
        local text2 = ""

        if flagData then
            local wineId = flagData.wineId
            local heroIdStr = Feastdata[wineId]
            local heroIdList = string.split(heroIdStr,";")
            local heroId1 = heroIdList[1]
            local heroId2 = heroIdList[2]

            if heroId1 then
                local heroAttr = HeroFeastModel:getHeroAttr(heroId1)
                text2 = text2..heroAttr.name
            end

            if heroId2 then
                local heroAttr = HeroFeastModel:getHeroAttr(heroId2)
                text2 = text2.."、"..heroAttr.name
            end

            panel.Text_desc2:setString(text1..":宴请了")
            panel.Text_desc3:setString(text2)

            if flagData.isReceive3 == false then
                panel.Button_Reward.Text_buttonName:setString("领取奖励")
                panel.Button_Reward:setEnabled(true)
				panel.Button_Reward:releaseFunc(function()
					if self:checkBagIsEnough(itemAward) then --检测背包格子
                        local yinpiaoNum = attrAward["yinpiao"]
                        if yinpiaoNum and yinpiaoNum > 0 then
                            PopupLayerController:showLayer(
                                "GlobalShadeLayer",
                                function(layer)
                                    layer:showLayer()
                                    layer:setPopText("请稍后")
                                end
                            )
                            HttpManagerEx:updateCurrencyByType("add","yinpiao",yinpiaoNum,"HeroFeast", function(status, errcode, errmsg, data)
                                if status == 200 then
                                    if errcode == 0 then
                                        PopText("银票".." + "..tostring(yinpiaoNum))
                                        flagData.isReceive3 = true
                                        panel.Button_Reward:setEnabled(false)
                                        panel.Button_Reward.Text_buttonName:setString("已领取")
                                        self:getRewards(attrAward,itemAward)
                                    else
                                        PopText(errmsg)
                                    end
                                end
                                PopupLayerController:hideLayer(
                                    "GlobalShadeLayer",
                                    function(layer)
                                        layer:hideLayer()
                                    end
                                )
                            end, IS_SHOW_WAITING)
                        else
                            flagData.isReceive3 = true
                            panel.Button_Reward:setEnabled(false)
                            panel.Button_Reward.Text_buttonName:setString("已领取")
                            self:getRewards(attrAward,itemAward)
                        end
					end
				end)
            else
                panel.Button_Reward:setEnabled(false)
                panel.Button_Reward.Text_buttonName:setString("已领取")
            end
        else
            panel.Text_desc2:setString(text1..":本日无宴会")
            panel.Button_Reward.Text_buttonName:setString("未达成")
            panel.Button_Reward:setEnabled(false)
        end

    end
end

--检查背包能否放的下
function HeroFeastThreePhaseLayer:checkBagIsEnough(itemAward)
	if MapIsEmpty(itemAward) then
		return true
	end
	local role = User:getRole()

	if role:checkCanBuyTwoOrMoreThings(itemAward) == true then
		return true
	end

	return false
end

--领取奖励
function HeroFeastThreePhaseLayer:getRewards(attrAward,itemAward)
    local role = User:getRole()
    if not MapIsEmpty(attrAward) then
        for attr,num in pairs(attrAward) do
            if attr ~= "yinpiao" then
                role:addAttr(attr,num)
                PopText(role:getCHAttrName(attr) .. " + ".. num)
            end
        end
    end

    if not MapIsEmpty(itemAward) then
        for itemId,num in pairs(itemAward) do
            role:addItemCount(itemId, num)
            PopText("获得 " .. Item:getOneItemByKey(itemId).name .. " x " .. num)
        end
    end
end

--领取全勤奖
function HeroFeastThreePhaseLayer:getQqRewards()
    local haveTitle = false
    local role = User:getRole()
    local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
    if role:hasBasicTitle(RoleTitleConst.SpecialBasicTitleId.YanSuiMu) then
        haveTitle = true
    end

    if HeroFeastModel:checkCanGetHeroFeastTitle() == true and haveTitle == false then
        self.Button_quan:setEnabled(true)
        self.Button_quan:releaseFunc(function()
            self.Button_quan:setEnabled(false)
            HeroFeastModel:getHeroFeastTitle3()
        end)
    else
        self.Button_quan:setEnabled(false)
    end
end

Helper:classDefNodeGetInstance(HeroFeastThreePhaseLayer)

return HeroFeastThreePhaseLayer00000