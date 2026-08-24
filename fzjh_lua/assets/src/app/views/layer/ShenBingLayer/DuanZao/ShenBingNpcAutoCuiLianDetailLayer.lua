local ShenBingNpcAutoCuiLianDetailLayer = class("ShenBingNpcAutoCuiLianDetailLayer", cc.Layer)

local ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")

local ShenBingCuiLianModel = require("app.models.ShenBing.CuiLian.ShenBingCuiLianModel")

local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")

local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

local StopType = {
    None = 0, --没停止
    ItemLimit = 1, --物品不足
    GoldLimit = 2, --黄金不足
    CuiLianCountLimit = 3 --淬炼次数限制
}

function ShenBingNpcAutoCuiLianDetailLayer:create()
    local p = ShenBingNpcAutoCuiLianDetailLayer.new()
    p:__init()
    return p
end

function ShenBingNpcAutoCuiLianDetailLayer:__init()
    self.__ui = require("app.views.ui.ShenBing.ShenBingAutoCuiLianDetailUI"):create()

    self.__ui:addTo(self)
end

function ShenBingNpcAutoCuiLianDetailLayer:showLayer()
    self:__initCuiLianItems()

    self:__initAutoCuiLianCount()

    self.__intervalTime = 0 --上次淬炼完成到下次淬炼开始中间间隔时间

    self.__onceFinishTime = 0 

    self.__results = {}

    self.__oneTimeCostGold = 0

    self.__costGold = 0

    self.__addExp = 0

    self.__currCuiLianCount = 0

    self.__addYinDu = 0

    self.__addRenDu = 0

    self.__addWeight = 0

    self.__addDamage = 0

    self.__addEffctNum = 0

    self.__isAutoCuiLianFinish = false --自动淬炼是否完成
    
    self.__isOnceCuiLianFinish = true  --单次淬炼是否完成

    self:setTextTitle()

    self:setButtonConfirm()

    self.__ui:initRichText()

    self.__schedule1 =
        self:schedule(
        function(ft)
            if self.__isOnceCuiLianFinish == true then
                self.__onceFinishTime = self.__onceFinishTime + ft
            end

            if self.__isOnceCuiLianFinish == true and self.__onceFinishTime >= self.__intervalTime then
                local isStop,sType = self:isStopAutoCuiLian()
            
                if isStop then
                    self:stopAutoCuiLian()

                    if sType == StopType.ItemLimit then
                        PopText("材料耗尽，淬炼结束")
                    elseif sType == StopType.GoldLimit then
                        PopText("黄金不足，淬炼结束")
                        self:printText("YEL"..self.__worker.name.."：少侠此次带的黄金不够呀！请带够盘缠再来淬炼。")
                        self:printText("HIR"..self.__worker.name.."一把将武器放下，递给了你。")
                        self:printText("HIR囊中羞涩，你因为黄金不足，本次淬炼停止了。")
                    elseif sType == StopType.CuiLianCountLimit then
                        PopText("该神兵已经淬炼300次了")
                    end
                else
                    self.__onceFinishTime = 0
    
                    self.__intervalTime = 1
            
                    if self.__currCuiLianCount ~= 0 then
                        self:printText("正在准备下一次淬炼...")
                    end
                    
                    print("开始第"..(self.__currCuiLianCount + 1).."淬炼")
            
                    self:startCuiLian()
    
                    self:refreshCuiLianInfoText()
                end
            end
        end,
        0
    )

    self.__ui:showUI()
end

function ShenBingNpcAutoCuiLianDetailLayer:__initCuiLianItems()
    self.__cuiLianItemList = {}

    local itemList = ShenBingCuiLianModel:getCuiLianItemList(self.__weapon.bType)

    for i,v in ipairs(itemList) do
        local itemId = v.Cuilianid

        local item = Item:getOneItemByKey(itemId)

        local itemName = Helper:getNoColorStr(item.name)

        local selectCount = self:__getSelectItemCount(itemId)

        table.insert(self.__cuiLianItemList, {name = itemName,itemId = itemId,count = selectCount,cuiLianData = v})
    end
end

function ShenBingNpcAutoCuiLianDetailLayer:setSelectCuiLianItemList(list)
    self.__selectCuiLianItemList = list
end

function ShenBingNpcAutoCuiLianDetailLayer:setPlayer(player)
    self.__player = player
end

function ShenBingNpcAutoCuiLianDetailLayer:setCallBack(callback)
    self.__callback = callback
end

function ShenBingNpcAutoCuiLianDetailLayer:setWorker(worker)
    self.__worker = worker
end

function ShenBingNpcAutoCuiLianDetailLayer:setWeapon(weapon)
    self.__weapon = weapon
end

function ShenBingNpcAutoCuiLianDetailLayer:getGold()
    return Helper:mathFloor(self.__player:getAttr("gold"))
end

function ShenBingNpcAutoCuiLianDetailLayer:__addResult(itemId,isSuc)
    if self.__results[itemId] == nil then
        self.__results[itemId] = {sucNum = 0,defNum = 0}
    end

    if isSuc then
        self.__results[itemId].sucNum = self.__results[itemId].sucNum + 1
    else
        self.__results[itemId].defNum = self.__results[itemId].defNum + 1
    end
end

function ShenBingNpcAutoCuiLianDetailLayer:__getCostItemCount(itemId)
    local count = 0

    if self.__results[itemId] then
        count = self.__results[itemId].sucNum + self.__results[itemId].defNum
    end

    return count
end

function ShenBingNpcAutoCuiLianDetailLayer:__getSelectItemCount(itemId)
    local count = 0
    for i,v in ipairs(self.__selectCuiLianItemList) do
        if v.itemId == itemId then
            count = count + v.num
        end
    end

    return count
end

function ShenBingNpcAutoCuiLianDetailLayer:__getCurrCuiLianData()
    local itemId = self:__getCurrCuiLianItemId()

    for i,v in ipairs(self.__cuiLianItemList) do
        if itemId == v.itemId then
            return v.cuiLianData
        end
    end

	self:__cuiLianError(itemId)
end

function ShenBingNpcAutoCuiLianDetailLayer:__getCurrCuiLianItemId()
    local itemCount = 0
    
    local itemId = nil 
    
    for i,v in ipairs(self.__selectCuiLianItemList) do
        itemCount = itemCount + v.num
        if itemCount >= self.__currCuiLianCount then
            itemId = v.itemId
            break
        end
    end

    return itemId
end

function ShenBingNpcAutoCuiLianDetailLayer:__initAutoCuiLianCount()
    local count = 0
    for i,v in ipairs(self.__selectCuiLianItemList) do
        count = count + v.num
    end

    self.__autoCuiLianCount = count
end

function ShenBingNpcAutoCuiLianDetailLayer:getCuiLianCount()
    return self.__weapon.cuilianCount + self:getSucCuiLianCount()
end

function ShenBingNpcAutoCuiLianDetailLayer:getSucCuiLianCount()
    local sucNum = 0

    if not MapIsEmpty(self.__results) then
        for itemId,v in pairs(self.__results) do
            sucNum = sucNum + v.sucNum
        end
    end

    return sucNum
end

function ShenBingNpcAutoCuiLianDetailLayer:getSkillName()
    return Skill:getSkill("duanzaozhishu").name
end

function ShenBingNpcAutoCuiLianDetailLayer:getCurrCuiLianLv()
    local skillLv = self.__player:getSkillLv("duanzaozhishu", self.__addExp)

    return skillLv
end

function ShenBingNpcAutoCuiLianDetailLayer:setTextTitle()
    if self.__isAutoCuiLianFinish then
        self.__ui:setTextTitle("自动淬炼已完成")
    else
        self.__ui:setTextTitle("自动淬炼中")
    end
end

function ShenBingNpcAutoCuiLianDetailLayer:startCuiLian()
    Audio:playMusic("DuanDa", true)
	
    self.__currCuiLianCount = self.__currCuiLianCount + 1

    local cuiLianData = self:__getCurrCuiLianData()

    if cuiLianData == nil then
        return 
    end

    local successRate = ShenBingCuiLianModel:getNpcCuiLianSuccessRate(self:getCuiLianCount(),self.__worker.skilv)

    local rate = math.random(1, 100)
    
    local isSuccess = false

    if successRate >= rate then
        isSuccess = true
    end

    self.__oneTimeCostGold = ShenBingCuiLianModel:getEverytimeCostGold(self.__worker.skilv,self:getCuiLianCount(),self.__worker._costFactor)

    self.__costGold = self.__costGold + self.__oneTimeCostGold

    local itemId = cuiLianData.Cuilianid

    self.__currItemId = itemId

    local weaponAttrList = {}

    local cuiLianTexts = {}

    local attrText = ""

    local expText = ""

    if isSuccess then
        local params = {
            hardness = self.__weapon.yindu + self.__addYinDu,
            Tenacity = self.__weapon.rendu + self.__addRenDu,
            weight = self.__weapon.weight + self.__addWeight,
            Hurt = self.__weapon.damage + self.__addDamage,
            special = self.__weapon.effctNum + self.__addEffctNum
        }
    
        weaponAttrList.yindu = Helper:GetValueFromScript(cuiLianData.Cuilianhardness, params)
        weaponAttrList.rendu = Helper:GetValueFromScript(cuiLianData.cuilianTenacity, params)
        weaponAttrList.weight = Helper:GetValueFromScript(cuiLianData.cuilianweight, params)
        weaponAttrList.damage = Helper:GetValueFromScript(cuiLianData.cuilianHurt, params)
        weaponAttrList.effctNum = Helper:GetValueFromScript(cuiLianData.cuilianspecial, params)

        self.__addYinDu = self.__addYinDu + weaponAttrList.yindu

        self.__addRenDu = self.__addRenDu + weaponAttrList.rendu
    
        self.__addWeight = self.__addWeight + weaponAttrList.weight
    
        self.__addDamage = self.__addDamage + weaponAttrList.damage
    
        self.__addEffctNum = self.__addEffctNum + weaponAttrList.effctNum
        
        self:__addResult(self.__currItemId,true)
        
        local sucTexts = ShenBingDesc:getShenBingCuiLianText(3)

        cuiLianTexts = sucTexts[math.random(1,#sucTexts)]

        attrText = "你的兵器在本次淬炼下"

        for attr,value in pairs(weaponAttrList) do 
            if value > 0 then
                attrText = attrText .. "，" ..ShenBingCuiLianModel:getCuiLianAttrName(attr)
            end
        end

        attrText = attrText.."似乎变得更强了。"

        for attr,value in pairs(weaponAttrList) do 
            value = Helper:preciseDecimal(value,3)

            if value >= 0 then
                attrText = attrText .. "\n" .. "HIW".. ShenBingCuiLianModel:getCuiLianAttrName(attr) .. "+".. value
            else
                attrText = attrText .. "\n" .. "HIW".. ShenBingCuiLianModel:getCuiLianAttrName(attr) .. tostring(value)
            end
        end
    else
        self:__addResult(self.__currItemId,false)
        
        local defTexts = ShenBingDesc:getShenBingCuiLianText(4)

        cuiLianTexts = defTexts[math.random(1,#defTexts)]
    end

    local skillLv = self:getCurrCuiLianLv()

    local MAX_ROLE_SKILL_EXP = self.__player:conversionSkillExpAndLv("exp", self.__player:getSkillLvLimit("duanzaozhishu"))
    if skillLv and skillLv > 0  then
        local addExp = 0

        local todayExp = self.__player:getDayFlag("淬炼经验") + self.__addExp

        local skillExp = self.__player:getSkillExp("duanzaozhishu") + self.__addExp
        
        if todayExp < MAX_CUILIAN_DAY_EXP then

            addExp = math.floor((skillLv^1.5)/6 + 500)
            
            if skillExp + addExp > MAX_ROLE_SKILL_EXP then
                addExp = MAX_ROLE_SKILL_EXP - skillExp
            end
            
            if addExp + todayExp > MAX_CUILIAN_DAY_EXP then
                addExp = MAX_CUILIAN_DAY_EXP - todayExp
            end

            if addExp > 0  then
                self.__addExp = self.__addExp + addExp

                local addExpText = ""

                if addExp < 1 then
                    addExpText = tostring(math.ceil(addExp))
                else
                    addExpText = tostring(math.floor(addExp))
                end

                expText = "你的 【"..self:getSkillName().."】 经验 +"..addExpText
            end
        end

        if self.__player:getSkillExp("duanzaozhishu") + self.__addExp >= MAX_ROLE_SKILL_EXP then
            expText = expText.."\n".."您的"..self:getSkillName().."已出神入化，无法再提升！"
        end

        if self.__player:getDayFlag("淬炼经验") + self.__addExp >= MAX_CUILIAN_DAY_EXP then
            expText = expText.."\n".."RED已达到每日淬炼可获得经验的上限，本日内淬炼无法再增加锻造之术经验"
        end
    end
    
    self.__showTime = 0

    self.__nextTime = 0

    self.__textCount = 0

    self.__isOnceCuiLianFinish = false

    self.__schedule2 =
        self:schedule(
        function(ft)
            if self.__showTime >= self.__nextTime then
                
                self.__showTime = 0

                self.__nextTime = 1
        
                self.__textCount = self.__textCount + 1
                
                if cuiLianTexts[self.__textCount] then
                    local cuiLianText = string.gsub(cuiLianTexts[self.__textCount], "#name#", self.__worker.name)
                    cuiLianText = string.gsub(cuiLianText, "#nickName#", self.__worker.nickName)

                    self:printText(cuiLianText)
                else
                    self:unschedule(self.__schedule2)

                    self.__schedule2 = nil

                    if attrText ~= "" then
                        self:printText(attrText)
                    end

                    if expText ~= "" then
                        self:printText(expText)
                    end

                    self.__isOnceCuiLianFinish = true
                end
            end
            
            self.__showTime = self.__showTime + ft
        end,
        0
    )
end

function ShenBingNpcAutoCuiLianDetailLayer:printText(str,verticalSpace)
    self.__ui:printText(str, verticalSpace)
end

function ShenBingNpcAutoCuiLianDetailLayer:refreshCuiLianInfoText()
    local currItem = Item:getOneItemByKey(self.__currItemId)

    local currItemName = Helper:getNoColorStr(currItem.name)

    local retList = {
        "      当前神兵淬炼材料："..currItemName,

        "      当前神兵已淬炼："..self.__currCuiLianCount.."次",

        "      当前淬炼所需黄金："..self.__oneTimeCostGold,

        "      "..self.__cuiLianItemList[1].name.."数量："..self.__cuiLianItemList[1].count - self:__getCostItemCount(self.__cuiLianItemList[1].itemId),
    
        "      "..self.__cuiLianItemList[2].name.."数量："..self.__cuiLianItemList[2].count - self:__getCostItemCount(self.__cuiLianItemList[2].itemId),
    
        "      "..self.__cuiLianItemList[3].name.."数量："..self.__cuiLianItemList[3].count - self:__getCostItemCount(self.__cuiLianItemList[3].itemId),
    }
    
    local attrList = {
        {
            name = "weight",
            value = Helper:preciseDecimal(math.max(self.__weapon.weight + self.__addWeight,0),1),
            addValue = Helper:roundPreciseDecimal(self.__addWeight,3)
        },
        {   
            name = "yindu",
            value = Helper:preciseDecimal(math.max(self.__weapon.yindu + self.__addYinDu,0),1),
            addValue = Helper:roundPreciseDecimal(self.__addYinDu,3)
        },
        {   
            name = "damage",
            value = Helper:preciseDecimal(math.max(self.__weapon.damage + self.__addDamage,0),1),
            addValue = Helper:roundPreciseDecimal(self.__addDamage,3)
        },
        {   
            name = "effctNum",
            value = Helper:preciseDecimal(math.max(self.__weapon.effctNum + self.__addEffctNum,0),1),
            addValue = Helper:roundPreciseDecimal(self.__addEffctNum,3)
        },
        {   
            name = "rendu",
            value = Helper:preciseDecimal(math.max(self.__weapon.rendu + self.__addRenDu,0),1),
            addValue = Helper:roundPreciseDecimal(self.__addRenDu,3)
        },
    }

    for i, v in ipairs(attrList) do
        local text = ""
        if v.addValue >= 0 then
            text = "      "..ShenBingCuiLianModel:getCuiLianAttrName(v.name).."："..v.value.."RED (+"..v.addValue..")"
        else
            text = "      "..ShenBingCuiLianModel:getCuiLianAttrName(v.name).."："..v.value.."GRN ("..tostring(v.addValue)..")"
        end

        table.insert(retList, text)
    end

    self.__ui:setContentListView(retList)
end

function ShenBingNpcAutoCuiLianDetailLayer:isStopAutoCuiLian()
    if self.__currCuiLianCount >= self.__autoCuiLianCount then
        return true,StopType.ItemLimit
    end

    local costGold = ShenBingCuiLianModel:getEverytimeCostGold(self.__worker.skilv,self:getCuiLianCount(),self.__worker._costFactor)

    if self:getGold() < self.__costGold + costGold then
        return true,StopType.GoldLimit
    end

    if self:getCuiLianCount() >= 300 then
        return true,StopType.CuiLianCountLimit
    end

    return false,StopType.None
end

function ShenBingNpcAutoCuiLianDetailLayer:stopAutoCuiLian()
    if self.__isAutoCuiLianFinish ~= true then
        self.__isAutoCuiLianFinish = true

        Audio:stopMusic("DuanDa")

        if self.__schedule1 then
            self:unschedule(self.__schedule1)
    
            self.__schedule1 = nil
        end

        self:setTextTitle()

        self:cuiLianDataSync()
    end
end

function ShenBingNpcAutoCuiLianDetailLayer:cuiLianDataSync()
    HttpManagerEx:incrWeaponCuilianNum(self.__weapon.id,self.__results,self.__weapon.cuilianCount, function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self.__player:addAttr("gold",- self.__costGold)

                if self.__worker.roleType == 2 then
                    self.__player:setDayFlag("欧冶子淬炼",self.__player:getDayFlag("欧冶子淬炼") + self.__currCuiLianCount)
                end

                for itemId,v in pairs(self.__results) do
                    self.__player:addItemCount(itemId, -(v.sucNum + v.defNum))
                end

                self.__weapon.weight = math.max(self.__weapon.weight + self.__addWeight, 0)
                self.__weapon.yindu = math.max(self.__weapon.yindu + self.__addYinDu, 0)
                self.__weapon.damage = math.max(self.__weapon.damage + self.__addDamage, 0)
                self.__weapon.effctNum = math.max(self.__weapon.effctNum + self.__addEffctNum, 0)
                self.__weapon.rendu = math.max(self.__weapon.rendu + self.__addRenDu, 0)
                
                ShenBingCuiLianModel:weaponAttrRoundPreciseDecimal(self.__weapon)
                
                self.__weapon.cuilianCount = self:getCuiLianCount()
                
                if self.__weapon.effctNum >= 100 and self.__weapon.effctNum < 200 then
                    if self.__weapon.effct2 ~= nil and self.__weapon.effct2 == "" then
                        local specialid, key, name = ShenBingDuanZao:getWeapenSpecialId(self.__weapon)
                        self.__weapon[key] = specialid
                    end
                elseif self.__weapon.effctNum >= 200 then
                    if self.__weapon.effct3 ~= nil and self.__weapon.effct3 == "" then
                        local specialid, key, name = ShenBingDuanZao:getWeapenSpecialId(self.__weapon)
                        self.__weapon[key] = specialid
                    end
                end
                
                ShenBingDuanZao:updateShenBingInfo(self.__weapon)

                self.__player:addSkillExp("duanzaozhishu", self.__addExp)
                self.__player:setDayFlag("淬炼经验", self.__player:getDayFlag("淬炼经验") + self.__addExp)

                if self.__callback then
                    self.__callback()
                end

                self.__results = {}

                self:setButtonConfirm()

                return true
            else
                PopText(errmsg)
                return false
            end
        else
            PopText(errmsg)
            return false
        end
    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

function ShenBingNpcAutoCuiLianDetailLayer:setButtonConfirm()
    if self.__isAutoCuiLianFinish then
        self.__ui:setButtonConfirm(
            "完成淬炼",
            function()
                self:hideLayer()
            end
        )
    else
        self.__ui:setButtonConfirm(
            "停止淬炼",
            function()
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:hide()
                local text = "是否停止自动淬炼过程？停止淬炼将返还剩余材料和黄金，并退出自动淬炼。"
                dialog:show(text)
                dialog:setButton1(
                    "停止",
                    function()
                        self:stopAutoCuiLian()
                    end
                )
                dialog:setButton2("取消")
                dialog:setWeChatVisible(false)
            end
        )
    end
end

function ShenBingNpcAutoCuiLianDetailLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ShenBingNpcAutoCuiLianDetailLayer",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function ShenBingNpcAutoCuiLianDetailLayer:__cuiLianError(itemId)
	if self.__schedule1 then
		self:unschedule(self.__schedule1)

		self.__schedule1 = nil
	end

	self:hideLayer()
	
	PopText("自动淬炼异常，请联系客服")

	local msgStr = "NPC自动淬炼错误信息：" .."材料id："..tostring(itemId)..",次数："..self.__currCuiLianCount..",淬炼材料数据："..table.tostring(self.__selectCuiLianItemList)..",淬炼材料配置："..table.tostring(self.__cuiLianItemList)

	ErrmsgRecord:addErrmsg(msgStr)
end

Helper:classDefNodeGetInstance(ShenBingNpcAutoCuiLianDetailLayer)
return ShenBingNpcAutoCuiLianDetailLayer
00000