local ShenBingAutoCuiLianDetailLayer = class("ShenBingAutoCuiLianDetailLayer", cc.Layer)

local ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")

local ShenBingCuiLianModel = require("app.models.ShenBing.CuiLian.ShenBingCuiLianModel")

local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")

local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

function ShenBingAutoCuiLianDetailLayer:create()
    local p = ShenBingAutoCuiLianDetailLayer.new()
    p:__init()
    return p
end

function ShenBingAutoCuiLianDetailLayer:__init()
    self.__ui = require("app.views.ui.ShenBing.ShenBingAutoCuiLianDetailUI"):create()

    self.__ui:addTo(self)
end

function ShenBingAutoCuiLianDetailLayer:showLayer()
    self:__initCuiLianItems()

    self:__initAutoCuiLianCount()

    self.__intervalTime = 0 --上次淬炼完成到下次淬炼开始中间间隔时间

    self.__onceFinishTime = 0 

    self.__results = {}

    self.__costJing = 0

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
            local isStop,msg = self:isStopAutoCuiLian()
            if isStop then
                self:stopAutoCuiLian()

                PopText(msg)
                return
            end

            if self.__isOnceCuiLianFinish == true then
                self.__onceFinishTime = self.__onceFinishTime + ft
            end

            if self.__isOnceCuiLianFinish == true and self.__onceFinishTime >= self.__intervalTime then
                self.__onceFinishTime = 0

                self.__intervalTime = 1
        
                if self.__currCuiLianCount ~= 0 then
                    self:printText("正在准备下一次淬炼...")
                end
                
                print("开始第"..(self.__currCuiLianCount + 1).."淬炼")
        
                self:startCuiLian()

                self:refreshCuiLianInfoText()
            end
        end,
        0
    )

    self.__ui:showUI()
end

function ShenBingAutoCuiLianDetailLayer:__initCuiLianItems()
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

function ShenBingAutoCuiLianDetailLayer:setSelectCuiLianItemList(list)
    self.__selectCuiLianItemList = list
end

function ShenBingAutoCuiLianDetailLayer:__addResult(itemId,isSuc)
    if self.__results[itemId] == nil then
        self.__results[itemId] = {sucNum = 0,defNum = 0}
    end

    if isSuc then
        self.__results[itemId].sucNum = self.__results[itemId].sucNum + 1
    else
        self.__results[itemId].defNum = self.__results[itemId].defNum + 1
    end
end

function ShenBingAutoCuiLianDetailLayer:__getCostItemCount(itemId)
    local count = 0

    if self.__results[itemId] then
        count = self.__results[itemId].sucNum + self.__results[itemId].defNum
    end

    return count
end

function ShenBingAutoCuiLianDetailLayer:__getSelectItemCount(itemId)
    local count = 0
    for i,v in ipairs(self.__selectCuiLianItemList) do
        if v.itemId == itemId then
            count = count + v.num
        end
    end

    return count
end

function ShenBingAutoCuiLianDetailLayer:__getCurrCuiLianData()
    local itemId = self:__getCurrCuiLianItemId()

    for i,v in ipairs(self.__cuiLianItemList) do
        if itemId == v.itemId then
            return v.cuiLianData
        end
    end

	self:__cuiLianError(itemId)
end

function ShenBingAutoCuiLianDetailLayer:__getCurrCuiLianItemId()
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

function ShenBingAutoCuiLianDetailLayer:setWeapon(weapon)
    self.__weapon = weapon
end

function ShenBingAutoCuiLianDetailLayer:__initAutoCuiLianCount()
    local count = 0
    for i,v in ipairs(self.__selectCuiLianItemList) do
        count = count + v.num
    end

    self.__autoCuiLianCount = count
end

function ShenBingAutoCuiLianDetailLayer:getCuiLianCount()
    return self.__weapon.cuilianCount + self:getSucCuiLianCount()
end

function ShenBingAutoCuiLianDetailLayer:getSucCuiLianCount()
    local sucNum = 0

    if not MapIsEmpty(self.__results) then
        for itemId,v in pairs(self.__results) do
            sucNum = sucNum + v.sucNum
        end
    end

    return sucNum
end

function ShenBingAutoCuiLianDetailLayer:getSkillName()
    return Skill:getSkill("duanzaozhishu").name
end

function ShenBingAutoCuiLianDetailLayer:getCurrCuiLianLv()
    local skillLv = self.__player:getSkillLv("duanzaozhishu", self.__addExp)

    return skillLv
end

function ShenBingAutoCuiLianDetailLayer:setPlayer(player)
    self.__player = player
end

function ShenBingAutoCuiLianDetailLayer:setCallBack(callback)
    self.__callback = callback
end

function ShenBingAutoCuiLianDetailLayer:setTextTitle()
    if self.__isAutoCuiLianFinish then
        self.__ui:setTextTitle("自动淬炼已完成")
    else
        self.__ui:setTextTitle("自动淬炼中")
    end
end

function ShenBingAutoCuiLianDetailLayer:startCuiLian()
    Audio:playMusic("DuanDa", true)

    self.__currCuiLianCount = self.__currCuiLianCount + 1

    local cuiLianData = self:__getCurrCuiLianData()

	if cuiLianData == nil then
        return 
    end

    local successRate = ShenBingCuiLianModel:getSelfCuiLianSuccessRate(self:getCuiLianCount(),self:getCurrCuiLianLv())

    local rate = math.random(1, 100)
    
    local isSuccess = false

    if successRate >= rate then
        isSuccess = true
    end

    if self.__player:getBuffAttr("xingzhenCuiLian") ~= 0 then
        local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")
        XingZhen:removeZouxueEffectByKey("xingzhenCuiLian")
    end

    self.__costJing = self.__costJing + ShenBingCuiLianModel:getEverytimeCostJing()

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
        
        local sucTexts = ShenBingDesc:getShenBingCuiLianText(1)

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
        
        local defTexts = ShenBingDesc:getShenBingCuiLianText(2)

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
                    self:printText(cuiLianTexts[self.__textCount])
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

function ShenBingAutoCuiLianDetailLayer:printText(str,verticalSpace)
    self.__ui:printText(str, verticalSpace)
end

function ShenBingAutoCuiLianDetailLayer:refreshCuiLianInfoText()
    local currItem = Item:getOneItemByKey(self.__currItemId)

    local currItemName = Helper:getNoColorStr(currItem.name)

    local retList = {
        "      当前神兵淬炼材料："..currItemName,

        "      当前神兵已淬炼："..self.__currCuiLianCount.."次",
    
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

function ShenBingAutoCuiLianDetailLayer:isStopAutoCuiLian()
    if self.__currCuiLianCount >= self.__autoCuiLianCount then
        return true,"材料耗尽，淬炼结束"
    end

    if self:getCuiLianCount() >= 300 then
        return true,"该神兵已经淬炼300次了"
    end

    return false,""
end

function ShenBingAutoCuiLianDetailLayer:stopAutoCuiLian()
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

function ShenBingAutoCuiLianDetailLayer:cuiLianDataSync()
    HttpManagerEx:incrWeaponCuilianNum(self.__weapon.id,self.__results,self.__weapon.cuilianCount, function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self.__player:addAttr("jing",-self.__costJing)

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

function ShenBingAutoCuiLianDetailLayer:setButtonConfirm()
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
                local text = "是否停止自动淬炼过程？停止淬炼将返还剩余材料和精力，并退出自动淬炼。"
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

function ShenBingAutoCuiLianDetailLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ShenBingAutoCuiLianDetailLayer",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function ShenBingAutoCuiLianDetailLayer:__cuiLianError(itemId)
	if self.__schedule1 then
		self:unschedule(self.__schedule1)

		self.__schedule1 = nil
	end

	self:hideLayer()
	
	PopText("自动淬炼异常，请联系客服")

	local msgStr = "自动淬炼错误信息：" .."材料id："..tostring(itemId)..",次数："..self.__currCuiLianCount..",淬炼材料数据："..table.tostring(self.__selectCuiLianItemList)..",淬炼材料配置："..table.tostring(self.__cuiLianItemList)

	ErrmsgRecord:addErrmsg(msgStr)
end

Helper:classDefNodeGetInstance(ShenBingAutoCuiLianDetailLayer)
return ShenBingAutoCuiLianDetailLayer
00