local FondDrOpenBoxLayer = class("FondDrOpenBoxLayer", cc.Layer)
local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")
local BasicActiveSkillManager = require("app.models.skill.BasicSkill.BasicActiveSkillManager")

local OpenBoxEvent = require("script.nanke.dreamworld.dreamOptionGeneration")["抽取事件"]
local OpenBoxText = require("script.nanke.dreamworld.dreamOptionDisplayed")["选项文本"]
local OpenBoxRewardEvent = require("script.nanke.dreamworld.dreamRewardEvents")["奖励内容"]

local TextMobanType = {
    Null = 0,
    Skill = 1,
    ActiveZhao = 2,
    Item = 3,
    Random = 4
}

function FondDrOpenBoxLayer:create()
	local p = FondDrOpenBoxLayer:new()
	p:init()
	return p
end

function FondDrOpenBoxLayer:init()
	self._UI = require("Layer/FondDrWorldUI/OpenBoxUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
    
    self:initRichText()
    -- self.Panel_back:releaseFunc(
    --     function()
    --         self:hideLayer()
    --     end
    -- )
end

function FondDrOpenBoxLayer:showLayer(boxId,role,map,drSystem)
    print("boxId = ",boxId)
    self:initData(boxId,role,map,drSystem)
    self:setTextDesc()
    self:setBoxListView()
	self:show()
end

function FondDrOpenBoxLayer:initData(boxId,role,map,drSystem)
    self._openBoxData = assert(OpenBoxEvent[tostring(boxId)],"开箱数据不存在，检查id = "..boxId) 
    self._role = role
    self._map = map
    self._floor = self._role.dreamWorld.cFloor
    self._drSystem = drSystem
    self._boxPool = {}
    self:initBoxRewardEvent()

    print("----------打印所有开箱池数据---------")
    Helper:print_lua_table(self._boxPool)
end

function FondDrOpenBoxLayer:setTextDesc()
    local desc = self._openBoxData.text
    self.Text_desc:setString(desc)
end

function FondDrOpenBoxLayer:initRichText()
	if self.rich_text ~= nil then
        self.rich_text:removeFromParent()
	end

	local x, y = self.Panel_kuang.Image_kuang.Text_rewardDesc:getPosition()
    local size = self.Panel_kuang.Image_kuang.Text_rewardDesc:getContentSize()

    self.rich_text = ExtRichTextScroll:create()

    self.Panel_kuang.Image_kuang.Text_rewardDesc:getParent():addChild(self.rich_text)
    self.rich_text:move(cc.p(x, y))
    self.rich_text:setSize(size)
    self.rich_text:setAnchorPoint(cc.p(0.0, 1))
    self.rich_text:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text:getRichText():setVerticalSpace(20)
end

function FondDrOpenBoxLayer:showRewardDesc(rewardDesc)
	self.Panel_kuang.Image_kuang.Text_rewardDesc:setString("")
	self:initRichText()

	local textColor = cc.c3b(255, 255, 255)
    self.rich_text:pushBackText(rewardDesc, textColor, 255, Resource:getFontPath("default"), 38)
    self:delayFunc(0.2,function ()
		self.rich_text:jumpToTop()
	end)
end

function FondDrOpenBoxLayer:setBoxListView()
    self.ListView_box:removeAllItems()
    self.ListView_box:setScrollBarEnabled(false)
    local boxListData = self:getBoxListData()
    for i,v in ipairs(boxListData) do
        local panel = self.Panel_box:clone()
        Helper:convertUIByParent(panel)
        panel.Text_boxDesc:setString(v.rewardText)
        panel:releaseFunc(function()
            self:showPanelKuang(v.reward,v.rewardDesc)
        end)

        self.ListView_box:pushBackCustomItem(panel)
    end
    self.ListView_box:jumpToTop()
end

function FondDrOpenBoxLayer:showPanelKuang(reward,rewardDesc)
    self.Panel_kuang:setVisible(true)
    self.Panel_kuang.Image_kuang.Text_boxDesc:setString("选取奖励后宝箱将消失，奖励基础内容如下，是否确认选择？")
    self:showRewardDesc(rewardDesc)
    self.Panel_kuang.Image_kuang.Text_rewardDesc:setString()
    self.Panel_kuang.Image_kuang.Button_linqu:releaseFunc(function()
        self.Panel_kuang:setVisible(false)
        self:hideLayer()
        self:openBox(reward)
    end)
    self.Panel_kuang.Image_kuang.Button_close:releaseFunc(function()
        self.Panel_kuang:setVisible(false)
    end)
end

function FondDrOpenBoxLayer:openBox(reward)
    if reward == nil then
        PopText("无奖励")
        return
    end

    print("--------------获得奖励--------------")
    Helper:print_lua_table(reward)
    if reward.skillId ~= 0 then
        local isNewSkill = false
        local skillData = string.split(reward.skillId,"|")
        for i,skillValue in ipairs(skillData) do
            local skillId = string.split(skillValue,"#")[1]
            local level = tonumber(string.split(skillValue,"#")[2])
            if isNewSkill == false and self._role:getSkillExp(skillId) <= 0 then
                isNewSkill = true
            end
            self._drSystem:addDreamSkillLevel(skillId,self._role,level)

            local skill = BasicSkillManager:getBasicSkill(skillId)
            local skillName = skill:getName()
            PopText("顿悟武道，" .. skillName .. "进境提升。")
        end
        if isNewSkill == true then
            self:showPrepareSkillLayer()
        end
    end
    if reward.activeId ~= 0 then
        local activeData = string.split(reward.activeId,"|")
        for i,activeValue in ipairs(activeData) do
            local zhaoId = string.split(activeValue,"#")[1]
            local addLv = tonumber(string.split(activeValue,"#")[2])
            self._drSystem:addDreamZhaoLv(zhaoId,self._role,addLv)
        end
    end
    if reward.itemsId ~= 0 then
        local itemData = string.split(reward.itemsId,"|")
        for i,itemValue in ipairs(itemData) do
            local itemId = string.split(itemValue,"#")[1]
            local num = tonumber(string.split(itemValue,"#")[2])

            --判断背包空间
            if not self._role:checkCanBuyThings(itemId,num) then
                local currRoomId = self._map:getCurrRoomId()
                self._map:dropItem(currRoomId,itemId,num)
                self._map.__MapLayer:delayRefreshMap()
            else
                self._role:addItemCount(itemId,num)
                PopText("获得"..Item:getOneItemByKey(itemId).name.."X"..num)
            end
        end
    end
end

function FondDrOpenBoxLayer:getBoxListData()
    local retData = {}
    for i = 1,4 do
        local index = "arg"..i
        local value = assert(self._openBoxData[index])
        local boxType
        if value ~= 0 then
            local boxArray = string.split(value,"|")
            if #boxArray > 1 then
                local randomArray = {}
                for i,v in ipairs(boxArray) do
                    local boxDataArray = string.split(v,"#")
                    local type = tonumber(boxDataArray[1])
                    local weight = tonumber(boxDataArray[2])
                    table.insert(randomArray,{weight = weight,type = type})
                end
                boxType = Helper:RandomByWeight(randomArray, "weight","type")

                local reward = self:getRewardData(boxType)
                local textType
                local rewardDesc = "一个神秘的包裹，包裹内有什么物品或许得打开之后才能知道。"
                if reward == nil then
                    textType = TextMobanType.Null
                    rewardDesc = "无奖励"
                else
                    textType = TextMobanType.Random
                end
                local rewardText = self:getRewardText(textType)
                table.insert(retData,{reward = reward,rewardText = rewardText,rewardDesc = rewardDesc})
            else
                boxType = value

                local reward = self:getRewardData(boxType)
                local rewardText,rewardDesc = "",""
                if reward == nil then
                    rewardText = self:getRewardText(TextMobanType.Null)
                    rewardDesc = "无奖励"
                else
                    if reward.skillId ~= 0 then
                        local skillData = string.split(reward.skillId,"|")
                        rewardDesc = rewardDesc.."YEL武学：NOR".."\n\n"
                        for i,skillValue in ipairs(skillData) do
                            local id = string.split(skillValue,"#")[1]
                            local value = tonumber(string.split(skillValue,"#")[2])
                            local text = self:getRewardText(TextMobanType.Skill,value)
                            
                            local skill = BasicSkillManager:getBasicSkill(id)
                            local skillName = skill:getName()
                            local skillDsc = skill:getDsc()
                            if rewardText == "" then
                                rewardText = self:subRewardText(text,skillName,value)
                            else
                                rewardText = rewardText.."  "..self:subRewardText(text,skillName,value)
                            end

                            rewardDesc = rewardDesc..skillName.."\n"..skillDsc.."\n \n"

                            local actId_list = skill:getActiveZhaos()

                            if #actId_list > 0 then
                                rewardDesc = rewardDesc.."特殊招式：\n"
                                for index, actId in ipairs(actId_list) do
                                    local activeZhao = BasicActiveSkillManager:getBasicActiveSkill(actId)
                                    local zhaoName = activeZhao:getActiveName()
                                    if index == #actId_list then
                                        rewardDesc = rewardDesc..zhaoName.."\n \n"
                                    else
                                        rewardDesc = rewardDesc..zhaoName.."\n"
                                    end
                                end
                            end
                        end
                    end
                    if reward.activeId ~= 0 then
                        rewardDesc = rewardDesc.."YEL主动技能：NOR".."\n"
                        local activeData = string.split(reward.activeId,"|")
                        for i,activeValue in ipairs(activeData) do
                            local actId = string.split(activeValue,"#")[1]
                            local value = tonumber(string.split(activeValue,"#")[2])
                            local text = self:getRewardText(TextMobanType.ActiveZhao,value)

                            local activeZhao = BasicActiveSkillManager:getBasicActiveSkill(actId)
                            local zhaoName = activeZhao:getActiveName()
                            local zhaoDsc = activeZhao:getDesc()
                            if rewardText == "" then
                                rewardText = self:subRewardText(text,zhaoName,value)
                            else
                                rewardText = rewardText.."  "..self:subRewardText(text,zhaoName,value)
                            end

                            rewardDesc = rewardDesc..zhaoName.."\n"..zhaoDsc.."\n \n"
                        end
                    end
                    if reward.itemsId ~= 0 then
                        rewardDesc = rewardDesc.."YEL道具：NOR".."\n"
                        local itemData = string.split(reward.itemsId,"|")
                        for i,itemValue in ipairs(itemData) do
                            local id = string.split(itemValue,"#")[1]
                            local value = tonumber(string.split(itemValue,"#")[2])
                            local text = self:getRewardText(TextMobanType.Item,value)

                            local item = Item:getOneItemByKey(id)
                            local itemName = item:getNcname(item.name)
                            local itemDsc = item:getDsc()
                            if rewardText == "" then
                                rewardText = self:subRewardText(text,itemName,value)
                            else
                                rewardText = rewardText.."  "..self:subRewardText(text,itemName,value)
                            end

                            rewardDesc = rewardDesc..itemName.."\n"..itemDsc.."\n"
                        end
                    end
                end

                table.insert(retData,{reward = reward,rewardText = rewardText,rewardDesc = rewardDesc})
            end
        end
    end
    return retData
end

function FondDrOpenBoxLayer:getRewardText(textType,value)
    local text = ""
    local function isRange(value,range)
        if value == nil or range == 0 or range == nil then
            return true
        end
        local rangeArray = string.split(range,"#")
        local minNum = tonumber(rangeArray[1])
        local maxNum = tonumber(rangeArray[2])
        if value >= minNum and value <= maxNum then
            return true
        end
        return false
    end
    for k,v in pairs(OpenBoxText) do
        if textType == v.type and isRange(value,v.arg) then
            text = v.text
        end
    end

    return text
end

function FondDrOpenBoxLayer:subRewardText(text,name,value)
    print("text = ",text,"name = ",name,"value = ",value)
    if name then
        text = string.gsub(text,"$s",name)
    end
    if value then
        text = string.gsub(text,"$d",value)
    end
    return text
end

function FondDrOpenBoxLayer:getRewardData(boxType)
    local boxRewardEvents = self:getBoxRewardEventsByType(boxType)
    if #boxRewardEvents <= 0 then
        return nil
    end
    local index = Helper:RandomByWeight(boxRewardEvents, "weight")
    return table.remove(boxRewardEvents, index)
end

function FondDrOpenBoxLayer:getBoxRewardEventsByType(boxType)
    return assert(self._boxPool[tostring(boxType)],"检查开箱奖励类型 boxType = "..boxType) 
end

--@desc 初始化开箱奖励事件数据
function FondDrOpenBoxLayer:initBoxRewardEvent()
    for k,v in pairs(OpenBoxRewardEvent) do
        if v.weight > 0 and self:checkSkillCon(v.con) and self:checkFloorIsRange(v.floor) then
            if self._boxPool[tostring(v.type)] == nil then
                self._boxPool[tostring(v.type)] = {}
            end
            table.insert(self._boxPool[tostring(v.type)],v)
        end
    end
end

--@desc 检查技能条件是否满足
function FondDrOpenBoxLayer:checkSkillCon(skillIdStr)
    if skillIdStr == 0 or skillIdStr == nil then
        return true
    end
    local skillIdArray = string.split(skillIdStr,"#")
    for i,skillId in ipairs(skillIdArray) do
        if self._role:getSkillLv(skillId) == 0 then
            return false
        end
    end
    return true
end

--@desc 检查楼层是否在范围内
function FondDrOpenBoxLayer:checkFloorIsRange(floorRange)
    if floorRange == 0 or floorRange == nil then
        return true
    end
    local floorRangeArray = string.split(floorRange,"#")
    local minFloor = tonumber(floorRangeArray[1])
    local maxFloor = tonumber(floorRangeArray[2])
    if self._floor >= minFloor and self._floor <= maxFloor then
        return true
    end
    return false
end

function FondDrOpenBoxLayer:showPrepareSkillLayer()
    PopupLayerController:showLayer("Dialog17Layer", function(layer)
        layer:setTextDesc("获得新武学，是否需要准备？")
        layer:setButtonClose("否",function()
            layer:hideLayer()
        end)
        layer:setButtonConfirm("是",function()
            layer:hideLayer()
            local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")		
            MapRoleLayer:clickStatusButton(true,EMPTY_FUNC,3)
        end)
        layer:showLayer()
    end)
end

function FondDrOpenBoxLayer:hideLayer()
    PopupLayerController:hideLayer("FondDrOpenBoxLayer",
        function(layer)
            self:hide()
        end
    )
end

Helper:classDefNodeGetInstance(FondDrOpenBoxLayer)
return FondDrOpenBoxLayer00