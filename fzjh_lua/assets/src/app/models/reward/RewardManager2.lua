local RewardManager2 = {
    rewardRuleList = {}, --抽取规则列表
    rewardList = {} --奖励表
}

local DreamUtil = require("app.models.DreamWorldModel.DreamUtil")

--获取奖励组id列表
function RewardManager2:getRewardGroupIdList(id)
    if id == nil then
        assert(nil,"奖励组抽取规则id有误")
        return
    end

    local function getRewardListByRule(rewardAttr)
        if  MapIsEmpty(rewardAttr) then
            print("id = ",id)
            assert(nil,"奖励id有误")
            return
        end

        local max = rewardAttr.max --上限
        local min = rewardAttr.limit --保底数
        local passOddsList = {} --通过概率的列表
        local canRandomList = {} --能抽取的列表
    
        for i = 1,5 do
            local odds = rewardAttr["probability"..i]
            local rewardId = rewardAttr["reward"..i]
            if DEBUG_MODE == 1 then
                print("odds = ",odds,"rewardId = ",rewardId)
            end
            if  type(odds) == "number" then
                if odds > 0 then
                    table.insert(canRandomList,rewardId)
                end
                if odds >= math.random(1,100) then
                    table.insert(passOddsList, rewardId)
    
                    if #passOddsList >= max then
                        break
                    end
                end
            else
                assert(nil,"检查odds数据类型")
            end
        end
    
        --小于保底个数
        if #passOddsList < min then
            local easterList = {}
            for i = 1, min - #passOddsList do
                table.insert(easterList, table.remove(canRandomList, math.random(1,#canRandomList)))
            end
            --追加数组
            table.appendArray(passOddsList,easterList)
        end
        if DEBUG_MODE == 1 then
            print("---------------抽取的列表----------------")
            Helper:print_lua_table(passOddsList)
        end

        return passOddsList
    end

    --类型小于50的,把抽取的id作为类型，重新到资源表随机抽取一份同类型的
    local retMap = {} --最终获得的奖励id列表
    local rewardAttr = RewardRuleTab[id]
    local rewardType = rewardAttr.type
    if rewardType <= 50 then
        local typeIdList = getRewardListByRule(rewardAttr)
        for i,typeId in ipairs(typeIdList) do
            if  DEBUG_MODE == 1 then
                print("typeId = ",typeId)
            end
            local randomList = self.rewardRuleList[typeId]

            if #randomList == 0 then
                assert(nil,"没有这个类型的奖励")
            else
                local randomId = randomList[math.random(1,#randomList)].id
                local attr = RewardRuleTab[tostring(randomId)]
                table.appendArray(retMap, getRewardListByRule(attr)) 
            end
        end
    else
        retMap = getRewardListByRule(rewardAttr)
    end

    return retMap
end

--获得奖励id
function RewardManager2:getRewardId(groupId)
    if groupId == nil then
        return
    end

    local groupIdList = self:getRewardGroupIdList(groupId)

    if  MapIsEmpty(groupIdList)  then
        print("没有抽取到奖励")
        return
    end

    local reward =  self.rewardList[id]

    if  MapIsEmpty(reward) then
        print("奖励表没有这个奖励组  groupId = ",groupId)
        return
    end

    local rewardId = reward[math.random(1,#reward)].id

    return rewardId
end

local attr_list = {
    ["1"] = "exp", --经验
    ["2"] = "pot", --潜能
    ["3"] = "weiwang",--威望
    ["4"] = "yueli",--阅历
    ["5"] = "money",--碎银
    ["6"] = "zhengqi", --正气
    ["7"] = "dreamCoins",--梦境币
    ["8"] = "sober", -- 清醒值
    ["9"] = "pijuan", -- 疲倦值
    ["10"] = "dreamYiYu", -- 梦内呓语
    ["20"] = "lv", --人物等级
    ["21"] = "dreamPoints", --梦境积分
    ["22"] = "qiMax", --气血最大值
    ["23"] = "neiliMax", --内力上限
    ["24"] = "qi", --气血
    ["25"] = "neili",--内力
    ["26"] = "str", --先天臂力
    ["27"] = "con", --先天根骨
    ["28"] = "dex", --先天身法
    ["29"] = "secStr", --后天臂力
    ["30"] = "secCon", --后天根骨
    ["31"] = "secDex",--后天身法
    ["32"] = "qiPercent", --气血上限
    ["40"] = "zhounianqin_jf",--原礼券商人货币
    ["41"] = "zhounianliquan", --周年礼券商人货币（徐念祖）
    ["42"] = "daily_point"
}

function RewardManager2:getAttrName(index)
    return attr_list[tostring(index)]
end

--获取奖励
function RewardManager2:getReward(data,role,map)
    if  MapIsEmpty(data) or MapIsEmpty(role) then
        print("参数有误，无奖励")
        return
    end 
    if DEBUG_MODE == 1 then
        print("----------------梦境奖励数据----------------")
        Helper:print_lua_table(data)
    end
    --本地属性奖励
    if MapIsEmpty(data.loc_attrTab) == false then
        local KTab = table.keys(data.loc_attrTab)
        --@desc 根据索引降序排列
        if #KTab > 1 then
            table.sort(KTab, function(a,b)
                return tonumber(a) > tonumber(b)
            end)
        end
        for i,index in ipairs(KTab) do
            local number = data.loc_attrTab[index]
            if self:getAttrName(index) and number ~= 0 then
                local symbol = ""
                if number >= 0 then
                    symbol = "+"
                end
                role:addAttr(self:getAttrName(index),number)
                if self:getAttrName(index) == "qiPercent" then
                    PopText(User:getRole():getCHAttrName(self:getAttrName(index)) .. " " .. symbol .. tostring(Helper:mathFloor(number*role:getFinalAttr("qiMax"))))
                else
                    PopText(User:getRole():getCHAttrName(self:getAttrName(index)) .. " " .. symbol .. tostring(number))
                end
            else
                print("未知属性奖励  index = ",index)
            end
        end
    end

    --服务器属性奖励
    if MapIsEmpty(data.net_attrTab) == false then
        for attrType,number in pairs(data.net_attrTab) do
            if self:getAttrName(attrType) and number ~= 0 then
                local symbol = ""
                if number >= 0 then
                    symbol = "+"
                end
                PopText(User:getRole():getCHAttrName(self:getAttrName(attrType)) .. " " .. symbol .. tostring(number))
            end
        end
    end

    --武学奖励
    if MapIsEmpty(data.skillTab) == false then
        for i,v in ipairs(data.skillTab) do
            local skillType = v.skillType
            local value = v.skillValue
            switch(skillType,{
                [1] = function()
                    --武学经验值增加
                    local skillId = v.skillId
                    if "zhougongzhishu" == skillId then
                        local currLv = role:getZhouGongZhiShuLv()
                        local isSuccess = role:addZhouGongZhiShuExp(value)
                        
                        if isSuccess == false then
                            PopText("周公之术已达瓶颈，可前往逍遥林酒家请教风天行")
                        else
                            local afterLv = role:getZhouGongZhiShuLv()
                            if afterLv - currLv > 0 then
                                PopText("你的 【周公之术】 等级 +"..tostring(afterLv - currLv))
                            end
                        end
                    else
                        role:addSkillExp(skillId, value)
                    end
                    
                end,
                [21] = function()
                    --梦境主角所有武学品级提升
                    local skills = role:getSkills()
                    if  MapIsEmpty(skills) == false then
                        for skillId,v in pairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [22] = function()
                    --梦境主角所有拳脚武学品级提升
                    local skills = DreamUtil:getSkillsByType(role:getSkills(),"quanjiao")
                    if  MapIsEmpty(skills) == false then
                        for i,skillId in ipairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [23] = function()
                    --梦境主角所有兵器武学品级提升
                    local skills = DreamUtil:getSkillsByType(role:getSkills(),"bingqi")
                    if  MapIsEmpty(skills) == false then
                        for i,skillId in ipairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [24] = function()
                    --梦境主角所有轻功武学品级提升
                    local skills = DreamUtil:getSkillsByType(role:getSkills(),"qinggong")
                    if  MapIsEmpty(skills) == false then
                        for i,skillId in ipairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [25] = function()
                    --梦境主角所有内功武学品级提升
                    local skills = DreamUtil:getSkillsByType(role:getSkills(),"neigong")
                    if  MapIsEmpty(skills) == false then
                        for i,skillId in ipairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [26] = function()
                    --梦境主角准备的兵器学位品级提升
                    local skills = DreamUtil:getSkillsByType(role:getPrepareSkills(),"bingqi")
                    if  MapIsEmpty(skills) == false then
                        for i,skillId in ipairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [27] = function()
                    --梦境主角准备的拳脚学位品级提升
                    local skills = DreamUtil:getSkillsByType(role:getPrepareSkills(),"quanjiao")
                    if  MapIsEmpty(skills) == false then
                        for i,skillId in ipairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [28] = function()
                    --梦境主角准备的轻功学位品级提升
                    local skills = DreamUtil:getSkillsByType(role:getPrepareSkills(),"qinggong")
                    if  MapIsEmpty(skills) == false then
                        for i,skillId in ipairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [29] = function()
                    --梦境主角准备的内功学位品级提升
                    local skills = DreamUtil:getSkillsByType(role:getPrepareSkills(),"neigong")
                    if  MapIsEmpty(skills) == false then
                        for i,skillId in ipairs(skills) do
                            if Skill:isBaseAutoSkill(skillId) == false then
                                User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                            end
                        end
                        PopText("顿悟武道，武功进境提升。")
                    end
                end,
                [30] = function()
                    --梦境主角指定武学品级提升
                    local skillId = v.skillId
                    User:getRole():getDreamSystem():addDreamSkillLevel(skillId,role,value)
                    local skillName = Skill:getSkill(skillId).name
                    PopText("顿悟武道，"..skillName.."进境提升。")
                end,
                default = function()
                    print("未知奖励  skillType = ",skillType)
                end
            })
        end
    end

    --物品奖励
    if MapIsEmpty(data.item1) == false then
        for itemId ,count in pairs(data.item1) do 
            --判断背包空间
            if not role:checkCanBuyThings(itemId,count) and MapIsEmpty(map) == false then
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

    --虚拟物品奖励
    if MapIsEmpty(data.item2) == false then
        for itemId ,count in pairs(data.item2) do 
            local itemAttr = Item:getOneItemByKey(itemId)
            PopText("获得"..itemAttr.name.."X"..count)
        end
    end
end

--@desc 领取梦境过期奖励
function RewardManager2:receiveRewardIsOverdue(data,role,map)
    if  MapIsEmpty(data) or MapIsEmpty(role) then
        print("参数有误，无奖励")
        return
    end 
    if DEBUG_MODE == 1 then
        print("----------------梦境奖励数据----------------")
        Helper:print_lua_table(data)
    end
    local text = ""
    --本地属性奖励
    if MapIsEmpty(data.loc_attrTab) == false then
        local KTab = table.keys(data.loc_attrTab)
        --@desc 根据索引降序排列
        if #KTab > 1 then
            table.sort(KTab, function(a,b)
                return tonumber(a) > tonumber(b)
            end)
        end
        for i,index in ipairs(KTab) do
            if self:getAttrName(index) then
                local number = data.loc_attrTab[index]
                role:addAttr(self:getAttrName(index),number)
                local symbol = ""
                if number >= 0 then
                    symbol = "+"
                end
                if i == 1 then
                    if self:getAttrName(index) == "qiPercent" then
                        text = User:getRole():getCHAttrName(self:getAttrName(index)) .. symbol .. tostring(Helper:mathFloor(number*role:getFinalAttr("qiMax")))
                    else
                        text = User:getRole():getCHAttrName(self:getAttrName(index)) .. symbol .. tostring(number)
                    end
                else
                    if self:getAttrName(index) == "qiPercent" then
                        text = text.."、"..User:getRole():getCHAttrName(self:getAttrName(index)) .. symbol .. tostring(Helper:mathFloor(number*role:getFinalAttr("qiMax")))
                    else
                        text = text.."、"..User:getRole():getCHAttrName(self:getAttrName(index)) .. symbol .. tostring(number)
                    end
                end
            else
                print("未知属性奖励  index = ",index)
            end
        end
    end

    --服务器属性奖励
    if MapIsEmpty(data.net_attrTab) == false then
        for attrType,number in pairs(data.net_attrTab) do
            if self:getAttrName(attrType) then
                local symbol = ""
                if number >= 0 then
                    symbol = "+"
                end
                if text == "" then
                    text = User:getRole():getCHAttrName(self:getAttrName(attrType)) .. symbol .. tostring(number)
                else
                    text = text.."、"..User:getRole():getCHAttrName(self:getAttrName(attrType)) .. symbol .. tostring(number)
                end
            end
        end
    end

    RichPrint("main",text)

    --武学奖励
    if MapIsEmpty(data.skillTab) == false then
        for i,v in ipairs(data.skillTab) do
            local skillType = v.skillType
            local value = v.skillValue
            switch(skillType,{
                [1] = function()
                    --武学经验值增加
                    local skillId = v.skillId
                    if "zhougongzhishu" == skillId then
                        local currLv = role:getZhouGongZhiShuLv()
                        local isSuccess = role:addZhouGongZhiShuExp(value)
                        
                        if isSuccess == false then
                            RichPrint("main","周公之术已达瓶颈，可前往逍遥林酒家请教风天行。")
                        else
                            RichPrint("main","周公之术 +"..value.."经验")
                        end
                    else
                        role:addSkillExp(skillId, value)
                    end
                    
                end,
                default = function()
                    print("未知奖励  skillType = ",skillType)
                end
            })
        end
    end

    --物品奖励
    if MapIsEmpty(data.item1) == false then
        for itemId ,count in pairs(data.item1) do 
            --判断背包空间
            if not role:checkCanBuyThings(itemId,count) and MapIsEmpty(map) == false then
                local currRoomId = map:getCurrRoomId()
                map:dropItem(currRoomId,itemId,count)
                map.__MapLayer:delayRefreshMap()
            else
                local itemAttr = Item:getOneItemByKey(itemId)
                role:addItemCount(itemId,count)
                RichPrint("main","获得"..itemAttr.name.."X"..count)
            end
    
        end
    end

    --虚拟物品奖励
    if MapIsEmpty(data.item2) == false then
        for itemId ,count in pairs(data.item2) do 
            local itemAttr = Item:getOneItemByKey(itemId)
            RichPrint("main","获得"..itemAttr.name.."X"..count)
        end
    end
end

--获取服务器奖励
function RewardManager2:getWebReward(context)
    if MapIsEmpty(context) then
        return
    end

    local params = context.params
    local role = context.role
    local map = context.map
    local callback = context.callback

    HttpManagerEx:getWebReward(params,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if DEBUG_MODE == 1 then
                    print("----------------服务器奖励----------------")
                    Helper:print_lua_table(data)
                end
                if callback then
                    callback(data)
                end
                self:getReward(data,role,map)
                return true
            else
                PopText(errmsg)
                return false
            end
        else
            PopText(errmsg)
            return false
        end
    end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
end

--南柯梦境获取服务器奖励
function RewardManager2:getFondWebReward(context)
    if MapIsEmpty(context) then
        return
    end

    local params = context.params
    local role = context.role
    local map = context.map
    local callback = context.callback

    HttpManagerEx:getFondWebReward(params,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if DEBUG_MODE == 1 then
                    print("----------------服务器奖励----------------")
                    Helper:print_lua_table(data)
                end
                if callback then
                    callback(data)
                end
                self:getReward(data,role,map)
                return true
            else
                PopText(errmsg)
                return false
            end
        else
            PopText(errmsg)
            return false
        end
    end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
end

return RewardManager2000000000