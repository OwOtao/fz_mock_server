local newClass = require("third.class.NewClass")

local MaskResManager = require("app.models.mask.MaskResManager")

local IGetRoleViewBorder = require("app.models.HeadViewSystem.IGetRoleViewBorder")

local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")

local MaskConst = require("app.models.mask.MaskConst")

local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local GoodsHelper = require("app.models.Store.GoodsHelper")

local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

local SyntheticMask = require("app.models.mask.SyntheticMask")

local MaskSystem = {
    __spNum = 0,
    __randomMaskList = {},
    __payNum = 0,
    __payMaskList = {},
}

function MaskSystem:create(role)
    local p = MaskSystem.new()
    p.__isNotSerializable = true
    p:init(role)
    return p
end

function MaskSystem:init(role)
    self.__output = {}
    self:setRole(role)
    self:repairPortrait()
end

function MaskSystem:repairPortrait()
    local portrait = self.__role:getAttr("portrait")
    if type(portrait) == "string" then
        portrait = {id = portrait, lv = 1}
    end
    self.__role:setAttr("portrait", portrait)
end

function MaskSystem:addOutput(output)
    if self:cheackOutput(output) == false then
        table.insert(self.__output, output)
    end
end

function MaskSystem:deleteOutput(output)
    for i,v in ipairs(self.__output) do
        if v == output then
            table.remove(self.__output, i)
        end
    end
end

function MaskSystem:cheackOutput(output)
    if MapIsEmpty(self.__output) then
        return false
    end
    for i,v in ipairs(self.__output) do
        if v == output then
            return true
        end
    end
    return false
end

function MaskSystem:setRole(role)
    self.__role = role
end

function MaskSystem:getRole()
    return self.__role
end

--@desc 添加面具等级
function MaskSystem:addMaskLv(itemId)
    local decorative = self.__role:getAttr("decorative")
	if MapIsEmpty(decorative) == false then
		for k,v in pairs(decorative) do
			if v.itemId == itemId then
                if v.lv == nil then
                    v.lv = 1
                end
                local maskGradeRes = MaskResManager:getMaskGradeMap(itemId)
                local nextLv = v.lv + 1
                if nextLv > #maskGradeRes then
                    return false
                end
                v.lv = v.lv + 1
			end
		end
	end
	return true
end

--@desc 获取面具等级
function MaskSystem:getMaskLv(itemId)
    local decorative = self.__role:getAttr("decorative")
	if MapIsEmpty(decorative) == false then
		for k,v in pairs(decorative) do
			if v.itemId == itemId then
				return v.lv or 1
			end
		end
	end
	return 1
end

--@desc 佩戴面具
--@author:Seven
--@time:2021-11-30 17:18:46
--@maskId: 对应面具升级表maskId
--@lv: 面具等级
function MaskSystem:wearMask(maskId, lv)
    self:__setWearMask(maskId, lv)

    local maskAttr = MaskResManager:getMaskAttrByMaskIdAndLv(maskId,lv)

    if maskAttr:getFramePath() then
        self.__role:getRoleViewBorderSys():addShowClass("mask")
    else
        self.__role:getRoleViewBorderSys():removeShowClass("mask")
    end

    if MapIsEmpty(self.__output) == false then
        for i,output in ipairs(self.__output) do
            output:changWearMask(maskId, lv)
        end
    end
end

--@desc 脱下面具
function MaskSystem:unwearMask()
    local defaultMaskId = ""
    local defaultMaskLv = 1
    self:__setWearMask(defaultMaskId,defaultMaskLv)

    self.__role:getRoleViewBorderSys():removeShowClass("mask")
    
    if MapIsEmpty(self.__output) == false then
        for i,output in ipairs(self.__output) do
            output:changWearMask(defaultMaskId,defaultMaskLv)
        end
    end
end

function MaskSystem:__setWearMask(maskId, lv)
    self.__role:setAttr("portrait", {id = maskId, lv = lv})
end

--@desc 获取面具对象
function MaskSystem:getMaskGrade(maskId,lv)
    return MaskResManager:getMaskGrade(maskId,lv)
end

--@desc 获取面具阶段数组
function MaskSystem:getMaskGradeMap(maskId)
    return MaskResManager:getMaskGradeMap(maskId)
end

--@desc 获取面具资源对象
function MaskSystem:getMaskAttrByMaskIdAndLv(maskId, lv)
    return MaskResManager:getMaskAttrByMaskIdAndLv(maskId, lv)
end

--@desc 获取面具资源对象
function MaskSystem:getMaskAttr(maskAttrId)
    return MaskResManager:getMaskAttr(maskAttrId)
end

--@desc: 获取合成面具资源对象
--@author:LvBin
--@time:2024-11-20 15:27:30
--@syntheticId: 合成id
--@return
function MaskSystem:getSpecialSyntheticMask(syntheticId)
    return SyntheticMask:create(syntheticId)
end

--@desc: 检查面具条件能否通过(升级条件,佩戴条件,合成条件)
--@author:LvBin
--@time:2024-11-14 17:28:29
--@return
function MaskSystem:checkMaskConditions(conditions)
    if MapIsEmpty(conditions) then
        return true
    end

    local result = true

    local msgList = {}
    
    for i,condition in ipairs(conditions) do
        local conditionType = condition[1]

        if conditionType == MaskConst.Condition.Item then
            local itemId = condition[2]
            local num = condition[3]
            local itemName = Item:getOneItemByKey(itemId).name
            if self.__role:getItemCount(itemId) < tonumber(num) then
                result = false
                table.insert(msgList,itemName.."不足"..num)
            end
        elseif conditionType == MaskConst.Condition.Lv then
            local num = condition[2]
            if self.__role:getLv() < tonumber(num) then
                result = false
                table.insert(msgList,"角色等级不足"..num)
            end
        elseif conditionType == MaskConst.Condition.InheritCount then
            local num = condition[2]
            if self.__role:getAttr("inheritCount") < tonumber(num) then
                result = false
                table.insert(msgList,"传承次数不足"..num)
            end
        elseif conditionType == MaskConst.Condition.Money then
            local num = condition[2]
            if self.__role:getAttr("money") < tonumber(num) then
                result = false
                table.insert(msgList,"碎银不足"..num)
            end
        elseif conditionType == MaskConst.Condition.Sex then
            local sexStr = tonumber(condition[2]) == 1 and "男" or "女"
            if self.__role:getAttr("sex") ~= sexStr then
                result = false
                table.insert(msgList,"性别不符合"..sexStr)
            end
        elseif conditionType == MaskConst.Condition.Title then
            local titleList = condition[2]

            local isHas = false

            local titleText = ""
            
            for i,titleId in ipairs(titleList) do
                local title = RoleTitleResManager:getBasicTitleClassById(titleId)

                local titleName = title:getText()

                if self.__role:hasBasicTitle(titleId) then
                    isHas = true
                else
                    if titleText == "" then
                        titleText = titleName
                    else
                        titleText = titleText.."、"..titleName
                    end
                end
            end

            if isHas ~= true then
                result = false
                table.insert(msgList,"未拥有称号:"..titleText)
            end
        end
    end

    return result,msgList
end

function MaskSystem:getConditionText(conditions,npc)
    local text = ""
    if MapIsEmpty(conditions) then
        return text
    end

    for i, condition in ipairs(conditions) do
        local conditionType = condition[1]

        if conditionType == MaskConst.Condition.Item then
            local itemId = condition[2]
            local num = condition[3]
            local item = Item:getOneItemByKey(itemId)
            text = text .. "【消耗" .. item.name .. "*" .. num .. "】"
        elseif conditionType == MaskConst.Condition.Lv then
            local num = condition[2]
            text = text .. "【等级达到" .. num .. "】"
        elseif conditionType == MaskConst.Condition.InheritCount then
            local num = condition[2]
            text = text .. "【传承次数达到" .. num .. "】"
        elseif conditionType == MaskConst.Condition.Prestige then
            local num = condition[2]
            text = text .. "【师门声望达到" .. num .. "】"
        elseif conditionType == MaskConst.Condition.Sex then
            local sexStr = condition[2] == 1 and "男" or "女"
            text = text .. "【性别为:" .. sexStr .. "】"
        elseif conditionType == MaskConst.Condition.Title then
            local titleText = "【拥有头衔:"
            
            local titleList = condition[2]

            for i,titleId in ipairs(titleList) do
                local title = RoleTitleResManager:getBasicTitleClassById(titleId)

                local titleName = title:getText()
                
                if i ~= 1 then
                    titleName = "或" .. titleName
                end
                
                titleText = titleText .. titleName
            end

            text = text .. titleText.."】"
        elseif MaskConst.ConditionAttr[conditionType] then
            local attr = MaskConst.ConditionAttr[conditionType]

            local num = condition[2]
            
            if attr == "spcl" and npc then
                num = self:getPayMakeCostNum(npc, num)
            end

            local name = Role:getCHAttrName(attr)
            
            if name ~= "" then
                text = text .. "【消耗" .. name .. "*" .. num .. "】"
            end
        end
    end

    return text
end

--@desc 面具升级
function MaskSystem:maskUpgrade(conditions, callback)
    HttpManagerEx:maskUpgrade(conditions, self.__role:getCurrencyVersion(), function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self:consumeClientItems(conditions)

                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end

                callback(true,"解锁成功")
            else
                callback(false,errmsg)
            end
        else
            callback(false,errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc: 消耗本地所需道具
--@author:LvBin
--@time:2024-11-14 18:16:44
--@return
function MaskSystem:consumeClientItems(conditions)
    for i,condition in ipairs(conditions) do
        local conditionType = condition[1]

        if conditionType == MaskConst.Condition.Item then
            local itemId = condition[2]
            local num = tonumber(condition[3])
            self.__role:addItemCount(itemId,-num)
        elseif conditionType == MaskConst.Condition.Money then
            local num = tonumber(condition[2])
            self.__role:addAttr("money",-num)
        end
    end
end

--@desc: 当前佩戴的面具对象
--@author:Seven
--@time:2021-11-23 21:02:38
--@return [src.app.models.mask.MaskAttr#MaskAttr]
function MaskSystem:getWearMask()
    local protraitId = self:getPortraitId()

    if protraitId == nil then
        return nil
    end

    local protraitLv = self:getPortraitLv()
    return self:getMaskAttrByMaskIdAndLv(protraitId, protraitLv)
end

--@desc: 当前佩戴面具组id
--@author:Seven
--@time:2021-11-23 20:09:48
--@return
function MaskSystem:getPortraitId()
    local portraitId = self.__role:getAttr("portrait").id

    if portraitId == "" then
        --@desc 历史问题，存档中有空字符串的情况
        return nil
    end
    return portraitId
end

--@desc: 当前面具组等级
--@author:Seven
--@time:2021-11-23 20:11:48
function MaskSystem:getPortraitLv()
    return self.__role:getAttr("portrait").lv
end


function MaskSystem:getBorder()
    local mask = self:getWearMask()

    if mask == nil then
        return BorderConfigManager:getBorderConf(self:getDefaultBorderId()):getFramePath()
    end
    
    local borderId = mask:getBorderId()
    
    if borderId == nil then
        return BorderConfigManager:getBorderConf(self:getDefaultBorderId()):getFramePath()
    end

    return BorderConfigManager:getBorderConf(borderId):getFramePath()
end

function MaskSystem:getBorderId()
    local mask = self:getWearMask()

    if mask == nil then
        return self:getDefaultBorderId()
    end

    return mask:getBorderId() or self:getDefaultBorderId()
end

function MaskSystem:getDefaultBorderId()
    return 10000
end

function MaskSystem:getInfoViewBorder()
    local mask = self:getWearMask()

    if mask == nil then
        return BorderConfigManager:getBorderConf(self:getDefaultBorderId()):getInfoFramePath()
    end

    local borderId = mask:getBorderId()

    if borderId == nil then
        return BorderConfigManager:getBorderConf(self:getDefaultBorderId()):getInfoFramePath()
    end

    return BorderConfigManager:getBorderConf(borderId):getInfoFramePath()
end

function MaskSystem:isChangeMaskBorder(maskId,maskLv)
    local currBorderId = self.__role:getRoleViewBorderSys():getBorderId()
    local nextBorderId = nil
    
	local maskAttr = MaskResManager:getMaskAttrByMaskIdAndLv(maskId,maskLv)

    if maskAttr and maskAttr:getBorderId() then
        nextBorderId = maskAttr:getBorderId()
    end

    if nextBorderId and nextBorderId ~= currBorderId then
       return true 
    end

    return false
end

--@desc: 获取面具图鉴信息
--@author:LvBin
--@time:2024-08-23 16:01:04
--@maskId: 
--@return
function MaskSystem:getMaskTuJianInfo(maskId)
    return MaskResManager:getMaskTuJianInfo(maskId)
end


--@desc: 获取制作面具数据
--@author:LvBin
--@time:2024-07-04 11:50:36
--@callback: 
--@return
function MaskSystem:getMakeMaskInfo(callback)
    HttpManagerEx:getMakeMaskInfo(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__setSpNum(data.spNum)

                    self:__setRandomMaskList(data.randomList)

                    self:__setPayNum(data.payNum)

                    self:__setPayMaskList(data.payMaskList)

                    callback(data)
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 获取随机制作面具所需消耗材料数
--@author:LvBin
--@time:2024-08-27 11:02:04
--@npc: 
--@return
function MaskSystem:getRandomMakeCostNum(npc)
    local costNumFactor = npc:getBuffAttr("zhicuoCostReduce")

    costNumFactor = Helper:getRange(costNumFactor,0,1)
    
    local costNum = math.ceil(100 * (1 - costNumFactor))

    return costNum
end

--@desc: 设置随机制作面具列表
--@author:LvBin
--@time:2024-07-04 11:50:19
--@maskList: 
--@return
function MaskSystem:__setRandomMaskList(randomMaskList)
    self.__randomMaskList = randomMaskList
end

--@desc: 获取随机制作面具列表
--@author:LvBin
--@time:2024-07-04 11:50:09
--@return
function MaskSystem:getRandomMaskList()
    return self.__randomMaskList
end

--@desc: 获取付费制作面具所需饰品消耗材料数
--@author:LvBin
--@time:2024-10-27 11:02:04
--@npc: 
--@return
function MaskSystem:getPayMakeCostNum(npc, baseCost)
    local costNumFactor = npc:getBuffAttr("zhicuoCostReduce")

    costNumFactor = Helper:getRange(costNumFactor,0,1)
    
    local costNum = math.ceil(tonumber(baseCost) * (1 - costNumFactor))

    return costNum
end

--@desc: 设置付费制作面具列表
--@author:LvBin
--@time:2024-07-04 11:50:19
--@maskList: 
--@return
function MaskSystem:__setPayMaskList(payMaskList)
    self.__payMaskList = payMaskList
end

--@desc: 获取付费制作面具列表
--@author:LvBin
--@time:2024-07-04 11:50:09
--@return
function MaskSystem:getPayMaskList()
    return self.__payMaskList
end

--@desc: 设置付费制作面具状态
--@author:LvBin
--@time:2024-11-21 10:59:10
--@id: 
--@state: 0 未制作 1已制作
--@return
function MaskSystem:__setPayMaskState(id,state)
    for i,seriesData in ipairs(self.__payMaskList) do
        for _i,syntheticData in ipairs(seriesData.list) do
            if tostring(syntheticData.id) == tostring(id) then
                syntheticData.state = state
            end
        end
    end
end

--@desc: 设置饰品数量
--@author:LvBin
--@time:2024-07-04 11:50:00
--@spNum: 
--@return
function MaskSystem:__setSpNum(spNum)
    self.__spNum = spNum
end

--@desc: 获取饰品数量
--@author:LvBin
--@time:2024-07-04 11:49:43
--@return
function MaskSystem:getSpNum()
    return self.__spNum
end

--@desc: 设置付费材料数量
--@author:LvBin
--@time:2024-08-29 18:11:37
--@spNum: 
--@return
function MaskSystem:__setPayNum(payNum)
    self.__payNum = payNum
end

--@desc: 获取付费材料数量
--@author:LvBin
--@time:2024-08-29 18:12:16
--@return
function MaskSystem:getPayNum()
    return self.__payNum
end

--@desc: 制作随机面具
--@author:LvBin
--@time:2024-07-04 11:49:34
--@callback: 
--@return
function MaskSystem:makeRandomMask(npc,callback)
    local role = self:getRole()
    
    local grantType = 1 --1直接发,2邮箱发

    if role:getAttr("weight") - #role:getItems() < 1 then
        grantType = 2
    end

    local cost = self:getRandomMakeCostNum(npc)

    local msg = ""

    HttpManagerEx:makeRandomMask(
        cost,
        grantType,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__setSpNum(data.spNum)

                    if grantType == 1 then
                        local goodsList = {
                            {
                                id = data.goodsId,
                                num = 1
                            }
                        }
                    
                        GoodsHelper:fromClientGrantGoods(role,GrantGoodRequest:create({goodsList = goodsList}))

                        callback(1,data)
                    else
                        callback(2,data)
                    end
                else
                    callback(0,{errmsg = errmsg})
                end
            else
                callback(0,{errmsg = errmsg})
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 制作付费面具
--@author:LvBin
--@time:2024-08-29 18:06:29
--@makeCondition: 制作条件
	--@callback: 
--@return
function MaskSystem:makePayMask(syntheticId,npc,callback)
    local role = self:getRole()
    
    local grantType = 1 --1直接发,2邮箱发

    if role:getAttr("weight") - #role:getItems() < 1 then
        grantType = 2
    end

    local msg = ""

    local syntheticMask = self:getSpecialSyntheticMask(syntheticId)

    local makeCondition = syntheticMask:getMakeCondition()

    local spCostNum = 0

    for i, condition in ipairs(makeCondition) do
        local conditionType = condition[1]

        if conditionType == MaskConst.Condition.Spcl then
            local baseCost = condition[2]

            spCostNum = self:getPayMakeCostNum(npc, baseCost)
        end
    end

    HttpManagerEx:makePayMask(
        syntheticId,
        spCostNum,
        grantType,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:consumeClientItems(makeCondition)

                    self:__setSpNum(data.spNum)

                    self:__setPayNum(data.payNum)

                    self:__setPayMaskState(syntheticId,1)

                    if grantType == 1 then
                        local syntheticMask = self:getSpecialSyntheticMask(syntheticId)

                        local goodsId = syntheticMask:getGoodsId()

                        local goodsList = {
                            {
                                id = goodsId,
                                num = 1
                            }
                        }
                    
                        GoodsHelper:fromClientGrantGoods(role,GrantGoodRequest:create({goodsList = goodsList}))

                        callback(1,{goodsId = goodsId})
                    else
                        callback(2,{goodsId = goodsId})
                    end
                else
                    callback(0,{errmsg = errmsg})
                end
            else
                callback(0,{errmsg = errmsg})
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 获取付费制作面具赠品活动详情
--@author:LvBin
--@time:2024-11-21 16:32:17
--@callback: 
--@return
function MaskSystem:getPayMakeMaskGiftInfo(callback)
    HttpManagerEx:getPayMakeMaskGiftInfo(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__activityName = data.activityName

                    local desc = ""

                    if MapIsEmpty(data.activityDesc) == false then
                        for i, v in ipairs(data.activityDesc) do
                            desc = desc .. v .. "\n"
                        end
                    end

                    self.__activityDesc = desc

                    self.__giftList = data.giftList

                    callback(true)
                else
                    callback(false,errmsg)
                end
            else
                callback(false,errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 领取付费面具赠品
--@author:LvBin
--@time:2024-11-21 18:06:10
--@id:赠品id
	--@callback: 
--@return
function MaskSystem:receivePayMaskGift(id,callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    local currencyVersion = self.__role:getCurrencyVersion()

    HttpManagerEx:receivePayMaskGift(
        id,
        dataVer,
        currencyVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local goodsList = data.rewards

                    GoodsHelper:fromNetworkGrantGoods(self:getRole(),GrantGoodRequest:create({goodsList = goodsList,dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

                    self.__giftList = data.giftList

                    callback(true,{goodsList = goodsList,msg = data.msg})
                else
                    callback(false,{msg = errmsg})
                end
            else
                callback(false,{msg = errmsg})
            end
        end,
        IS_SHOW_WAITING
    )
end

function MaskSystem:getMakeMaskActivityName()
    return self.__activityName
end

function MaskSystem:getMakeMaskActivityDesc()
    return self.__activityDesc
end

function MaskSystem:getMakeMaskActivityGiftList()
    return self.__giftList
end

return newClass("MaskSystem", {IGetRoleViewBorder}, MaskSystem)
00000000