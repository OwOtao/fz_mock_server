--[[
    师门小团体
]]
local fgTemplate = require("script.others.fgTemplate")

local function initTemplateByFamilyName()
    local templates = fgTemplate["moban"]
    fgTemplate.familyIndex = {}
    for fqId, template in pairs(templates) do
        fgTemplate.familyIndex[template.family] = template.id
    end
end

initTemplateByFamilyName()

local FamilyGroup = {}

--@desc 每日更新 舍友相关FLAG前缀，规则：前缀+userid
FamilyGroup.FLAGS_PREFIX = {
    --@desc 舍友最期望礼物
    BEST_FLAG = "FGBITEM_",
    --@desc 今日送礼的物品ID
    GIFT_ITEMID_FLAG = "FGGIFT_",
    --@desc 舍友送礼列表
    GIFT_LIST_FLAG = "FGGLIST_",
    --@desc 舍友切磋每日限制
    DAY_FIGHT_FLAG = "DAYFIG_"
}

--@desc: 获取团队队员
--@author:Liang SongQiang
--@time:2019-01-22 15:21:29
--@callback: 获取回调
function FamilyGroup:getGroupMembers(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    local role = User:getRole()
    local familyId = role:getFamilyId()

    local user_id = User:getUserId()
    local FILE_NAME = user_id .. "familyGroup"

    local cache = DataBase:getLuaTable(FILE_NAME)

    local isCache = 0
    local cache_data = nil

    if MapIsEmpty(cache) == false then
        local create_time = cache.cr_time

        local now_time = GetTime()

        if Helper:diffWithDate(now_time, create_time) < 1 then
            isCache = 1
            cache_data = cache.data
        end
    end

    HttpManagerEx:getUserGroup(
        User:getUserId(),
        role:getAttr("teacherId"),
        familyId,
        isCache,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    --@desc 强制刷新
                    local n_time = GetTime()

                    --@desc 只要是下发的舍友，应该是同师傅和同门派，但因存档上传延迟可能导致数据不一致。
                    for i,userData in ipairs(data) do
                        userData.family = {
                            level = role:getFamilyLevel(),
                            name = role:getFamilyId()
                        }
                        userData.teacherName = role:getAttr("teacherName")
                        userData.teacherId = role:getAttr("teacherId")
                    end

                    cache = {
                        cr_time = n_time,
                        data = data
                    }

                    DataBase:setLuaTable(FILE_NAME, cache)

                    callback(data)

                    return true
                elseif errcode == 3 then
                    --@desc 使用客户端缓存
                    callback(cache_data)
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function FamilyGroup:clearCache()
    local user_id = User:getUserId()
    local FILE_NAME = user_id .. "familyGroup"

    local cache = DataBase:getLuaTable(FILE_NAME)

    if MapIsEmpty(cache) == false then
        DataBase:setLuaTable(FILE_NAME, {})
    end
end

--@desc: 刷新团体
--@author:Liang SongQiang
--@time:2019-02-15 16:43:06
function FamilyGroup:refreshGroupMember()
    return self:getGroupMembers(EMPTY_FUNC)
end

--@desc 亲密度描述
function FamilyGroup:getIntimacyDescAndNext(value)
    --[[
        0~1000	WHT泛泛之交NOR
        1001~3000	HIG患难之交NOR
        3001~6000	HIC莫逆之交NOR
        6001~10000	HIR生死之交NOR
        10001~	YEL管鲍之交NOR
    ]]
    local desc = ""
    local nextValue = 1000
    if value <= 1000 then
        desc = "WHT泛泛之交NOR"
        nextValue = 1000
    elseif value > 1000 and value <= 3000 then
        desc = "HIG患难之交NOR"
        nextValue = 3000
    elseif value > 3000 and value <= 6000 then
        -- body
        desc = "HIC莫逆之交NOR"
        nextValue = 6000
    elseif value > 6000 and value <= 10000 then
        desc = "HIR生死之交NOR"
        nextValue = 10000
    elseif value > 10000 then
        desc = "YEL管鲍之交NOR"
        nextValue = 20000
    end
    return desc,nextValue
end

--@desc: 获取舍友亲密度
--@author:Liang SongQiang
--@time:2019-02-15 16:59:51
--@user_id:舍友ID
function FamilyGroup:getUserIntimacy(user_id, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getUserIntimacy(
        user_id,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
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

function FamilyGroup:getAllMembersIntimacy(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getAllIntimacy(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local intimacyList = {}

                    for _, roleIntimacyData in ipairs(data) do
                        intimacyList[roleIntimacyData.userid] = roleIntimacyData.intimacy
                    end

                    callback(intimacyList)
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

--@desc: 更新舍友的亲密度
--@author:Liang SongQiang
--@time:2019-01-24 11:02:42
--@userId:用户ID
--@value: 服务器返回的值
function FamilyGroup:updateLocalUserIntimacy(user, totalIntimacy)
    if user.intimacy == nil then
        user.intimacy = 0
    end
    user.intimacy = totalIntimacy
end

--@desc: 通知服务器增加或减少人物亲密度
--@author:Liang SongQiang
--@time:2019-04-24 12:25:56
--@userId:用户ID
--@intimacy:增加的亲密度
--@event:亲密度变更的事件
function FamilyGroup:updateUserIntimacty(userId, intimacy, event, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:updateUserIntimacy(
        userId,
        intimacy,
        event,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
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

--@desc:送礼
--@author:Liang SongQiang
--@time:2019-02-15 16:08:42
--@user_id:用户ID
--@itemId:物品ID
function FamilyGroup:sendGift(user_id, item_id, itemCount, addIntimacy, addPrestige, succCallback, errCallback)
    succCallback = Helper:getDef(succCallback, EMPTY_FUNC)
    errCallback = Helper:getDef(errCallback, EMPTY_FUNC)
    HttpManagerEx:sendGift(
        user_id,
        item_id,
        itemCount,
        addIntimacy,
        addPrestige,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    succCallback(data)
                else
                    -- PopText(errmsg)
                    errCallback(errcode, errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 检查是否有对方是否有送礼给自己
--@author:Liang SongQiang
--@time:2019-04-24 11:18:38
--@user_id:玩家id
function FamilyGroup:checkHasGift(user_id, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:checkHasGift(
        user_id,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
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

--@desc: 收礼
--@author:Liang SongQiang
--@time:2019-02-15 16:10:13
--@user_id: 给你送礼的玩家id
function FamilyGroup:getGift(user, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)

    self:checkHasGift(
        user.userid,
        function(checkData)

            local userTemplate = self:getMemberTemplateByFamilyId(user.fgId)

            if userTemplate == nil then
                assert(false,"获取舍友模板出错："..tostring(user.fgId))
            end

            local player = User:getRole()
            local isCanGet = true
            if MapIsEmpty(checkData) == false then
                local list = {}

                --@desc 判断背包
                for _, temp in ipairs(checkData) do
                    if list[temp.gift] ~= nil then
                        list[temp.gift] = list[temp.gift] + temp.num
                    else
                        list[temp.gift] = temp.num
                    end
                end

                if player:checkCanBuyTwoOrMoreThings(list) == false then
                    isCanGet = false
                end
            else
                local noGifts = string.split(userTemplate.noGift,";")
                local desc = noGifts[math.random(1,#noGifts)]
                RichPrint("main","YEL"..user.name.."："..desc)
                return
            end

            if isCanGet == true then
                HttpManagerEx:getGift(
                    user.userid,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                local haveGift = string.split(userTemplate.haveGift,";")
                                local desc = haveGift[math.random(1,#haveGift)]
                                callback(data,desc)
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
        end
    )
end

--@desc: 获取玩家进境排行
--@author:Liang SongQiang
--@time:2019-02-15 16:11:14
function FamilyGroup:getGroupRank(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getGroupRank(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(data)
                else
                    print(errcode, errmsg)
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 生成地图中的舍友数据
--@author:Liang SongQiang
--@time:2019-04-20 11:37:43
--@roleData: 舍友数据
function FamilyGroup:initMapMember(roleData)
    local role = Role:create(roleData)

    -- role = Helper:tableCover(role, roleData)


    role.id = "fmg_" .. roleData.userid

    role.type = "role"

    role.type2 = "familyGroup"

    role.canSee = 1

    role._inMapInited = true

    role.fgId = self:getMemberTemplateIdByFamilyName(User:getRole():getFamilyName())

    role.isShowEquips = 1

    local currTitle = role:getCurrBasicTitle()

    role.title = currTitle:getColorName()
    
    role.operations = {}

    role:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()

    table.insert(
        role.operations,
        OperationFactory:createNoConditionBtnOperation("交谈", {OperationFactory:createResult("舍友交谈")})
    )
    table.insert(
        role.operations,
        OperationFactory:createNoConditionBtnOperation("送礼", {OperationFactory:createResult("舍友送礼")})
    )
    -- table.insert(
    --     role.operations,
    --     OperationFactory:createNoConditionBtnOperation("愿望", {OperationFactory:createResult("舍友期望")})
    -- )
    table.insert(
        role.operations,
        OperationFactory:createNoConditionBtnOperation("收礼", {OperationFactory:createResult("舍友收礼")})
    )
    table.insert(
        role.operations,
        OperationFactory:createNoConditionBtnOperation("切磋", {OperationFactory:createResult("舍友切磋")})
    )

    return role
end

function FamilyGroup:getMemberTemplateIdByFamilyName(familyName)
    return fgTemplate.familyIndex[familyName]
end

function FamilyGroup:getMemberTemplateByFamilyId(id)
    return fgTemplate["moban"][tostring(id)]
end

--@desc: 获取今天的礼物列表
--@author:Liang SongQiang
--@time:2019-04-23 14:30:18
function FamilyGroup:getGiftList(userId, templateId)
    local player = User:getRole()

    local groupTemplate = self:getMemberTemplateByFamilyId(templateId)

    if MapIsEmpty(groupTemplate) then
        print("数据有误，模板id：" .. templateId)
        return
    end

    local listFlag = self.FLAGS_PREFIX.GIFT_LIST_FLAG .. userId
    local itemList = player:getDayFlag(listFlag)

    if itemList == 0 or type(itemList) ~= "table" then
        --@desc 生成列表
        itemList = {}
        local index = 1
        while true do
            local itemId = groupTemplate["item" .. index]
            if itemId == nil then
                break
            end
            table.insert(itemList, itemId)
            index = index + 1
        end

        local MAX_LENGTH = 3

        local diffCount = math.max(#itemList - MAX_LENGTH, 0)

        if diffCount > 0 then
            for i = 1, diffCount do
                local removeIndex = math.random(1, #itemList)
                table.remove(itemList, removeIndex)
            end
        end

        player:setDayFlag(listFlag, itemList)
    end

    return itemList
end

--@desc: 获取当天舍友的期望物品id
--@author:Liang SongQiang
--@time:2019-04-23 12:56:00
function FamilyGroup:getBestGiftItemId(userId, templateId)
    local player = User:getRole()
    local groupTemplate = self:getMemberTemplateByFamilyId(templateId)
    if MapIsEmpty(groupTemplate) then
        print("数据有误，模板id：" .. templateId)
        return
    end

    local bestItemId = player:getDayFlag(self.FLAGS_PREFIX.BEST_FLAG .. userId)

    if bestItemId == 0 then
        local list = self:getGiftList(userId, templateId)
        if MapIsEmpty(list) then
            print("获取列表错误：", userId, templateId)
            return
        end
        bestItemId = list[math.random(1, #list)]
        player:setDayFlag(self.FLAGS_PREFIX.BEST_FLAG .. userId, bestItemId)
    end

    return bestItemId
end

--@desc:根据bestId获取交谈列表
--@author:Liang SongQiang
--@time:2019-04-23 14:36:51
function FamilyGroup:getTalkWordsByBestItemId(itemId, templateId)
    local groupTemplate = self:getMemberTemplateByFamilyId(templateId)

    local unGiftWords = {}

    local bestGiftWords = {}

    local index = 0
    for i = 1, 20 do
        if groupTemplate["item" .. i] == itemId then
            index = i
            break
        end
    end

    if index > 0 then
        unGiftWords = string.split(groupTemplate["words" .. index], ";")
        bestGiftWords = string.split(groupTemplate["getWords" .. index], ";")
    end

    return unGiftWords, bestGiftWords
end

return FamilyGroup
000000000