local DreamTalentModel = {}

local TalentGroup = {}

local TalentTab = require("script.dreamworld.dreamtfskill")["天赋表"]
local DreamConst = require("app.models.DreamWorldModel.DreamConst")
local OPERTION_EVENT_NAME = DreamConst.OpertionEventName

--@desc 根据天赋组初始化列表
local function initDreamTalentTabByGroupId( )
    for k,v in pairs(TalentTab) do
        if TalentGroup[v.tfgroupid] then
            table.insert( TalentGroup[v.tfgroupid],v)
        else
            TalentGroup[v.tfgroupid] = {}
            table.insert( TalentGroup[v.tfgroupid],v)
        end
    end
end

initDreamTalentTabByGroupId()

--获得天赋列表
function DreamTalentModel:getTalentList()
    local TalentList = {}
    for k,v in pairs(TalentTab) do
        table.insert(TalentList,v)
    end

    return TalentList
end

--获得准备界面需要显示的主动天赋列表
function DreamTalentModel:getZhuDongTalentList()
    local zhuDongTalent = {}
    local dreamTalent = User:getRole():getAttr("DreamTalent")
    for talentId ,v in pairs(dreamTalent) do
        local talentAttr = self:getTalentAttrById(talentId)
        if talentAttr.drtfuse == 1 then
            table.insert(zhuDongTalent,talentAttr)
        end
    end 
    return zhuDongTalent
end

--获得天赋组
function DreamTalentModel:getTalentGroup()
    return TalentGroup
end

--获得天赋组默认天赋(品级最低)
function DreamTalentModel:getDefaultTalent(groupId)
    local group = self:getTalentGroupById(groupId)
    for i,talent in ipairs(group) do
        if talent.tfleveLs == 1 then
            return talent
        end
    end

    assert(false,"DreamTalentModel:getDefaultTalent 天赋组没有品级为一的天赋")
end

--获得升级的天赋id
function DreamTalentModel:getUpgradeTalentId(talentId)
    local talent = self:getTalentAttrById(talentId)
    local groupId = talent.tfgroupid
    local currLevel = talent.tfleveLs
    local group = self:getTalentGroupById(groupId)
    for i,v in ipairs(group) do
        if v.tfleveLs == currLevel + 1 then
            return v.id
        end
    end

    assert(false,"DreamTalentModel:getUpgradeTalentId 没有更高品级的天赋")
end

--获得指定天赋组
function DreamTalentModel:getTalentGroupById(groupId)
    return TalentGroup[groupId]
end

--获得天赋资源配表
function DreamTalentModel:getTalentAttrById(talentId)
    if talentId == nil then
        return
    end
    for k,v in pairs(TalentTab) do
        if tostring(talentId) == tostring(v.id) then
            return v
        end
    end
end

--使用天赋技能
function DreamTalentModel:useTalentFunc(talentId,map,role,needSober,callback)
    if map == nil or talentId == nil or role == nil then
        return
    end

    local talentAttr = self:getTalentAttrById(talentId)
    if  MapIsEmpty(talentAttr) == true then
        print("没有这条天赋 talentId = ",talentId)
        return
    end
    if talentAttr.drtfuse ~= 1 then
        PopText("只能使用主动技能")
        return
    end
    
    if self:checkCanUse(role,talentId) == false then
        return
    end
 
    local value = talentAttr.value
    local result = switch(talentAttr.effectType,
    {
        [1] = function() --召唤师傅战斗
            return self:addNpcFight(map,value)
        end, 
        [2] = function() --回血回内力
            local qiMax = role:getAttr("qiMax")
            local neiliMax = role:getAttr("neiliMax")

            role:addAttr("qiPercent",value)
            role:addAttr("qi",qiMax*value)
            role:addAttr("neili",neiliMax*value)
            return true
        end,
        [3] = function() --添加一个门
            local drSystem = User:getRole():getDreamSystem()
            local floor = role.dreamWorld.cFloor
            local doorId = drSystem:createDoorByFloor(floor)
            local MapInfo = require("app.models.map.MapInfo")
            MapInfo:addMapRole(map, doorId)
            local addResult = MapInfo:addRoleToRoom(map,map:getCurrRoomId(),doorId)
            map.__MapLayer:delayRefreshMap()
            if addResult == false then
                PopText("当前房间已有相同的门")
            end
            return addResult
        end,
        [4] = function() --增加梦境货币
            role:addAttr("dreamPoints", value)
            return true
        end,
        [5] = function() --增加物品
            local items = {}
            local strList = string.split(value,";")
            for i,v in ipairs(strList) do
                local itemIdList = string.split(v,",")
                local itemId = itemIdList[math.random(1,#itemIdList)]

                if items[itemId] then
                    items[itemId] = items[itemId] + 1
                else
                    items[itemId] = 1
                end
            end

            if not MapIsEmpty(items) then
                for itemId ,count in pairs(items) do 
                    --判断背包空间
                    if not role:checkCanBuyThings(itemId,count) then
                        local currRoomId = map:getCurrRoomId()
                        map:dropItem(currRoomId,itemId,count)
                        map.__MapLayer:delayRefreshMap()
                    else
                        local itemAttr = Item:getOneItemByKey(itemId)
                        role:addItemCount(itemId,count)
                        PopText("获得"..itemAttr.name.."X"..count)
                    end
        
                end
            end
            
            return true
        end,
        [6] = function() --增加一个被动buff
            local buffId = value
            --@desc 添加一个buff
            role:addBuffV2(buffId)
            return true
        end,
        [7] = function() --随机更换自身情绪（不能是当前情绪）
            role.emotionMgr:randomChangeEmotion()
            return true
        end,
    })

    if callback then
        callback()
    end

    if result == false then
        print("使用失败")
        return
    else
        print("使用成功")
    end

    if type(talentAttr.useText) == "string" then
        RichPrint("main",talentAttr.useText) 
    end
    
    --消耗清醒值
    self:consumeSober(role,needSober)
end

--添加npc战斗
function DreamTalentModel:addNpcFight(map,npcId)
    if map == nil or npcId == nil then
        return false
    end
    local roomId = map:getCurrRoomId()
    local currRoom = map:getRoomAttr(roomId)

    local rolelist = map:getRoomRoleList(roomId)

    for i, roleId in ipairs(rolelist) do
        if roleId == npcId then
            PopText("高人已在，不需再次呼唤。")
            return false
        end
    end

    currRoom.npcFight = npcId --记录代打的npcId
    map:addRoomRole(roomId, npcId)
    map.__MapLayer:delayRefreshMap()
    return true
end

--清除代打的npc
function DreamTalentModel:clearNpcFight(map)
    if map == nil then
        return
    end
    local roomId = map:getCurrRoomId()
    local currRoom = map:getRoomAttr(roomId)
    if currRoom.npcFight then
        map:removeRoomRole(roomId,currRoom.npcFight)
        map.__MapLayer:delayRefreshMap()

        currRoom.npcFight = nil
    end
end

--检查能否使用
function DreamTalentModel:checkCanUse(role,talentId)
    if role == nil or talentId == nil then
        return false
    end
    local talentAttr = self:getTalentAttrById(talentId)

    if talentAttr == nil then
        return false
    end
    --判断使用条件
    local useCondition = talentAttr.useCondition
    local value = talentAttr.conditionValue
    local result = switch(useCondition,{
        [0] = function() --无条件
            return true
        end,
        [1] = function() --梦境货币（不是梦境币）
            local drmoney = role:getAttr("dreamPoints")
            if drmoney >= value then
                role:addAttr("dreamPoints",-value)
                PopText("消耗碎银"..value)
                return true
            else
                PopText("碎银不足。")
                return false
            end
        end,
    })
    return result
end

--检查能否升级
function DreamTalentModel:checkCanUpgrade(talentId)
    local talentAttr = self:getTalentAttrById(talentId) 
    if talentAttr.canAddLevel == 1 then
        return true
    else
        return false
    end 
end

--检查在当前天赋组品级是否最高
function DreamTalentModel:checkLevelIsMax(talentId)
    local talentAttr = self:getTalentAttrById(talentId)
    local groupId = talentAttr.tfgroupid
    local currLevel = talentAttr.tfleveLs
    local groupList = TalentGroup[groupId]
    if MapIsEmpty(groupList) then
        assert(false,"天赋组有误  groupId = "..groupId)
    end

    if currLevel < #groupList then
        return false
    else
        return true
    end
end

--消耗清醒值
function DreamTalentModel:consumeSober(role,needSober)
    local currSober = role:getAttr("sober")
    currSober = math.max(currSober - needSober,0)
    role:setAttr("sober",currSober)

    if currSober <= 0 then
        role.dreamStatus = 2 --梦醒状态
        RichPrint("main","眼前景象越来越混乱，像是梦境和现实的重叠，似乎随时可清醒。")
    end

end

--解锁天赋
function DreamTalentModel:unlockTalent(talentId,func)
    local talent = self:getTalentAttrById(talentId)
    local params = {
        {
            type = OPERTION_EVENT_NAME.Unlock_Talent, --事件类型
            id = talent.id, --解锁的天赋id
            count = 1,--数量
            currency = "dreamCoins", --消耗的货币
            cost = talent.drtfmoney --花费的金额
        }
    }
    HttpManagerEx:uploadEventRecord(params,function(status, errcode, errmsg, data)
        local result
        if status == 200 and errcode == 0 then
            print("-----------------HttpManagerEx:uploadEventRecord-----------------")
            Helper:print_lua_table(data)

            self:setCurrDreamCoins(self:getCurrDreamCoins()- talent.drtfmoney)
            self:addDreamTalent(talentId)
            
            result = true
        else
            result = false
        end
        if func then
            func(result,errmsg)
        end
    end, IS_SHOW_WAITING)
end

--升级天赋
function DreamTalentModel:upgradeTalent(talentId,func)
    local talent = self:getTalentAttrById(talentId)
    local nextTalentId = self:getUpgradeTalentId(talentId)
    local nextTalent = self:getTalentAttrById(nextTalentId)
    local params = {
        {
            type = OPERTION_EVENT_NAME.Upgrade_Talent, --事件类型
            id = talent.id, --升级的天赋id
            count = 1,--数量
            currency = "dreamCoins", --消耗的货币
            cost = nextTalent.drtfmoney --花费的金额
        }
    }
    HttpManagerEx:uploadEventRecord(params,function(status, errcode, errmsg, data)
        local result
        if status == 200 and errcode == 0 then
            print("-----------------HttpManagerEx:uploadEventRecord-----------------")
            Helper:print_lua_table(data)
            
            self:setCurrDreamCoins(self:getCurrDreamCoins()- nextTalent.drtfmoney)
            self:addDreamTalent(nextTalentId)
            self:deleteDreamTalent(talentId)
            self:changePrepareTalent(talentId,nextTalentId)
            result = true
        else
            result = false
        end
        if func then
            func(result,errmsg)
        end
    end, IS_SHOW_WAITING)
end

--@desc: 解锁天赋节能
--@author:Seven_L
--@time:2020-06-08 22:32:36
function DreamTalentModel:unlockActiveTalent(role)
    local dreamTalent = role:getAttr("DreamTalent")
    local zhudongTalentList = self:getZhuDongTalentList()
    local count = 0
    for i,zhudongTalent in ipairs(zhudongTalentList) do
        local talentId = zhudongTalent.id
        if self:checkTalentIdIsEmpty(dreamTalent,talentId) == true then
            count = count + 1
        end
    end

    print("解锁的主动天赋条数 = ",count)

    if count > 3 then
        PopupLayerController:showLayer("PrepareTalentLayer", function(layer)
            layer:showLayer(zhudongTalentList)
        end)
    elseif count <= 3 and count > 0 then
        for i,zhudongTalent in ipairs(zhudongTalentList) do
            local talentId = zhudongTalent.id
            if self:checkTalentIdIsEmpty(dreamTalent,talentId) == true then
                --解锁的主动天赋小于等于3条，自动准备
                self:addUserPrepareTalent(talentId)
            end
        end
    else
    end
end

--获得当前清醒值文本
function DreamTalentModel:getCurrSorbText(sorb)
    local text = ""
    if type(sorb) ~= "number" then
        return text
    end
    if sorb >= 75 then
        text = "你此刻已然酣睡如泥"
    elseif sorb >= 50 then
        text = "你此刻已然陷入熟睡"
    elseif sorb >= 25 then
        text = "你此刻已然半梦半醒"
    elseif sorb >= 0 then
        text = "你此刻已然梦意渐浅"
    end
    return text
end

--获得消耗清醒值文本
function DreamTalentModel:getConsumeSorbText(sorb)
    local text = ""
    if type(sorb) ~= "number" then
        return text
    end
    if sorb >= 26 then
        text = "这会让你极为清醒"
    elseif sorb >= 16 then
        text = "这会让你清醒颇多"
    elseif sorb >= 0 then
        text = "这会让你清醒些许"
    end
    return text
end

--获得清醒值警告文本
function DreamTalentModel:getWarnSorbText(sorb)
    local text = ""
    if type(sorb) ~= "number" then
        return text
    end
    if sorb >= 10 then
        text = "你可能从梦中醒来"
    elseif sorb > 0 then
        text = "你极有可能从梦中醒来"
    elseif sorb <= 0 then
        text = "你会从梦中醒来"
    end
    return text
end

function DreamTalentModel:getZhouGongZhiShuLv()
    local role = User:getRole()
    local id = "zhougongzhishu"
    
    local lv = Helper:getDef(role:getZhouGongZhiShuLv(id),0)
    return lv
end

function DreamTalentModel:getZhouGongZhiShuExp()
    local role = User:getRole()
    local id = "zhougongzhishu"
    
    local exp = Helper:getDef(role:getSkillExp(id),0)
    return exp
end

function DreamTalentModel:getUserPrepareTalent()
    return User:getRole():getAttr("PrepareTalent")
end

function DreamTalentModel:getUserDreamTalent()
    return User:getRole():getAttr("DreamTalent")
end

function DreamTalentModel:addUserDreamTalent(talentId)
    User:getRole():getAttr("DreamTalent")[tostring(talentId)] = true
end

function DreamTalentModel:deleteUserDreamTalent(talentId)
    User:getRole():getAttr("DreamTalent")[tostring(talentId)] = nil
end

function DreamTalentModel:addUserPrepareTalent(talentId)
    User:getRole():getAttr("PrepareTalent")[tostring(talentId)] = true
end

function DreamTalentModel:deleteUserPrepareTalent(talentId)
    User:getRole():getAttr("PrepareTalent")[tostring(talentId)] = nil
end

function DreamTalentModel:changeUserPrepareTalent(oldTalentId,newTalentId)
    if MapIsEmpty(self:getUserPrepareTalent()) == false and self:getUserPrepareTalent()[tostring(oldTalentId)] then
        self:deleteUserPrepareTalent(oldTalentId)
        self:addUserPrepareTalent(newTalentId)
    end
end

function DreamTalentModel:setPrepareTalent(prepareTalent)
    self.prepareTalent = prepareTalent
end

function DreamTalentModel:getPrepareTalent()
    return self.prepareTalent
end

function DreamTalentModel:changePrepareTalent(oldTalentId,newTalentId)
    if MapIsEmpty(self.prepareTalent) == false and self.prepareTalent[tostring(oldTalentId)] then
        self.prepareTalent[tostring(oldTalentId)] = nil
        self.prepareTalent[tostring(newTalentId)] = true
    end
end

function DreamTalentModel:setDreamTalent(dreamTalent)
    self.dreamTalent = dreamTalent
end

function DreamTalentModel:getDreamTalent()
    return self.dreamTalent
end

function DreamTalentModel:addDreamTalent(talentId)
    self.dreamTalent[tostring(talentId)] = true
end

function DreamTalentModel:deleteDreamTalent(talentId)
    self.dreamTalent[tostring(talentId)] = nil
end

--@desc 检查列表是否有这个天赋
function DreamTalentModel:checkTalentIdIsEmpty(tab,talentId)
    if MapIsEmpty(tab) or talentId == nil then
        return false
    end
    if tab[tostring(talentId)] then
        return true
    end

    return false
end

function DreamTalentModel:setCurrDreamCoins(coins)
    self.currDreamCoins = coins
end

function DreamTalentModel:getCurrDreamCoins()
    return self.currDreamCoins
end

function DreamTalentModel:getWebTalentData(callback)
    HttpManagerEx:getEventRecord(function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then           
                print("-----------------HttpManagerEx:getEventRecord----------------")
                Helper:print_lua_table(data)

                local evnetRecord = data.params
                self:setCurrDreamCoins(data.point)
                self:setPrepareTalent(clone(self:getUserPrepareTalent()))
                self:setDreamTalent(clone(self:getUserDreamTalent()))
        
                if MapIsEmpty(evnetRecord) == false then
                    for i,v in ipairs(evnetRecord) do
                        if v.type == OPERTION_EVENT_NAME.Unlock_Talent then
                            self:addDreamTalent(v.id)
                        elseif v.type == OPERTION_EVENT_NAME.Upgrade_Talent then
                            local nextId = self:getUpgradeTalentId(v.id)
                            --@desc 清除升级的天赋，新增升级后的天赋
                            self:deleteDreamTalent(v.id)
                            self:addDreamTalent(nextId)
                            self:changePrepareTalent(v.id,nextId)
                        end
                    end
                end

                if callback then
                    callback(data)
                end
            else
                PopText(errmsg)
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end


return DreamTalentModel000000000000