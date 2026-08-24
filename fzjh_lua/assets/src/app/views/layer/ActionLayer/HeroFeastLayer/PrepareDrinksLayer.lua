local PrepareDrinksLayer = class("PrepareDrinksLayer", LayerEx)
local HeroFeastModel = require("app.models.Action.HeroFeast.HeroFeastModel")
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
function PrepareDrinksLayer:create()
	local p = PrepareDrinksLayer:new()
	p:init()
	return p
end
function PrepareDrinksLayer:init()
	local UI = require("Layer/ActionUI/HeroFeast/PrepareDrinksUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self:setPanelBack()
end

function PrepareDrinksLayer:showLayer()

    self:setButtonAndButtonDsc()
    self:setTextTitalAndDsc()
    self:show()
end

function PrepareDrinksLayer:setTextTitalAndDsc()
    local data = HeroFeastModel:getHeroFeastDataByTime()
    local text = "  #ch#，关于宴席的酒水您有什么想法吗？需要准备什么酒水？"

    text = HomelandDesc:subChengHuText(text)
    self.Text_Tital:setString("新春英雄宴")
    self.Text_desc:setString(text)
end

function PrepareDrinksLayer:setButtonAndButtonDsc()
    for i = 1,5 do
        local wineId = "wine"..tostring(i)
        local wineAttr = HeroFeastModel:getWineAttr(wineId)

        self["Button_"..i].Text_buttonName:setString(wineAttr.name)
        self["Text_Button"..i.."_dsc"]:setString(wineAttr.text)
        self["Button_"..i]:releaseFunc(function()
            if HeroFeastModel:checkIsActivityTime() == false then
                self:hideLayer()
                PopText("已经过了举办宴席的时间！")
                return
            end
            if HeroFeastModel:checkFoodNumIsEnough() == false then
                self:hideLayer()
                PopText("宴席需要的食材不足！")
                return
            end
            
            local role = User:getRole()
            local dayNum = HeroFeastModel:calCurrHeroFeastTimes()
            local HeroFeastData =HeroFeastModel:getHeroFeastDataByTime(dayNum)
            
            --记录英雄宴完成状态和使用的酒水，活动界面领取答谢礼需要用到
            local flagTab = role:getInheritFlag("2021英雄宴奖励")
            if flagTab == 0 then
                flagTab = {}
            end

            if flagTab[dayNum] then
                self:hideLayer()
                PopText("今日已经举办过宴席了")
                return 
            end

            --扣除宴席所需材料
            local FoodIdAndNumArry = HeroFeastModel:getFoodIdAndNumArry()
            for i,v in ipairs(FoodIdAndNumArry) do
                role:addItemCount(v.id,-v.num)
            end

            flagTab[dayNum] = {
                dayNum = dayNum,    --第几天的奖励
                wineId = wineAttr.wineHero, --使用的酒水关联英雄
                isReceive1 = false, --是否领取奖励1
                isReceive2 = false, --是否领取奖励2
                isReceive3 = false, --是否领取阶段3奖励
            }

            role:setInheritFlag("2021英雄宴奖励",flagTab)

            self:getBaseReward()

            local textIndex = wineAttr.wineText
            local Text = HeroFeastData[textIndex]
            local Anim1TextList = string.split(Text,",")
            local Anim1Text = ""
            for i,v in ipairs(Anim1TextList) do
                local textId = v
                local text = HeroFeastModel:getTextByTextId(textId)

                Anim1Text = Anim1Text..text
            end
            self:playAnim1(Anim1Text)
        end)
    end
end

function PrepareDrinksLayer:getBaseReward()
    local baseAwardId = HeroFeastModel:getBaseAwardId()
    local role = User:getRole()
    local map = role:getCurrMap()
    if baseAwardId and MainControllLayer:getCurrLayer() == "MapLayer" and map then
        local rewardArray=RewardManager:getRewardArrayWithRewardScheme(baseAwardId,role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())
        for i, reward in ipairs(rewardArray) do
            if reward.type == "物品" then
                if map:addItemCount(reward.id, reward.value) == false then
                    map:dropItem(map:getCurrRoomId(), reward.id)
                else
                    role:addItemCount(reward.id, reward.value)
                    PopText("获得 " .. Item:getOneItemByKey(reward.id).name .. " x " .. reward.value)
                end
            elseif reward.type == "属性" then
                if type(role:getCHAttrName(reward.id)) == "string" then
                    PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
                end
                role:addAttr(reward.id, reward.value) 
                map:richPrintText(role, reward.id, reward.value) -- 角色属性变化文本显示
            end
        end
    end
end
function PrepareDrinksLayer:setPanelBack()
    self.Panel_back:releaseFunc(function()
        self:hideLayer()
	end)
end

function PrepareDrinksLayer:hideLayer(func)
    PopupLayerController:hideLayer("PrepareDrinksLayer", function(layer)
        if func then
            func()
        end
        layer:hide()
    end)
end

function PrepareDrinksLayer:playAnim1(text)
    PopupLayerController:showLayer("TextAnimLayer",function(layer)
        layer:setAfterAnimCallback(function()
            PopupLayerController:hideLayer("PrepareHeroFeastLayer", function(layer)
                layer:hide()
            end, 0)
            self:hideLayer()
        end)
        layer:setHideCallbackFunc(
            function()
                PopText("宴席举办成功")
            end
        )
        layer:setShowAnimType(2)
        local text1 = "随着你一声令下，管家开始忙碌起来……|#AAAA屋子里很快响起了锅碗瓢盆的声音，虽然嘈杂，却透着一种喜悦。也许这就是过年的感觉吧……|#AAAA没过多久，食物的香气弥漫了起来，一盘盘珍馐佳肴烹饪完毕、被端上饭桌。|#AAAA看起来很不错呢……|#AAAA正出神中，管家走过来对你说：|#AAAA“#ch#，宴席准备好了，请入席吧……”"
        text1 = HomelandDesc:subChengHuText(text1)
        text = text1.."|||"..text
        layer:setMusicName("banjia")
        layer:showLayer(text)
    end)
end



Helper:classDefNodeGetInstance(PrepareDrinksLayer)

return PrepareDrinksLayer0000000000000000