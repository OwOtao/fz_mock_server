local TeacherGuaJiTaskUtil = {}

-- TASK_STATE_NONE = 1      -- 无状态
-- TASK_STATE_DISABLE = 2   -- 不能用
-- TASK_STATE_IDLE = 3      -- 空闲
-- TASK_STATE_GUAJI = 4     -- 挂机
-- TASK_STATE_COOLDOWN = 5  -- 冷却
-- TASK_STATE_ACCEPT = 6	 -- 接受
-- TASK_STATE_TO_SUBMIT = 7 -- 待提交
-- TASK_STATE_DISPATCH = 8 -- 派遣中
-- TASK_STATE_COMPLETE = 9 -- 已完成


local TaskResource = clone(requireWithEncrypt("script.others.teamguaji"))
local FamilyPrestige = require("app.models.family.FamilyPrestige")

local Mission = TaskResource.mission --挂机任务表
local StepList = TaskResource.step  --任务具体步骤表
local TextList = TaskResource.text  --任务相关文本表

-- 接取任务 （只需要改变任务状态，然后保存,保存的任务不用删除，只需要改变状态就行了，下次接取再改变状态）
function TeacherGuaJiTaskUtil:receiveTask(taskId)
    if taskId == nil then
        assert(false,"检查参数")
    end
    local role = User:getRole()
    local task = self:getTaskAttr(taskId)
    local teacherGuaJiTask = role:getAttr("teacherGuaJiTask")

    teacherGuaJiTask[taskId] = task
    
    self:setTaskState(teacherGuaJiTask[taskId],TASK_STATE_ACCEPT)
end

-- 开始任务 （改变状态和保存开始时间,结束时间）
function TeacherGuaJiTaskUtil:startTask(task)
    if task == nil then
        assert(false,"检查参数")
    end
    local role = User:getRole()
    local needTime = task.needTime
    local currTime = GetTime()
    task.startTime = currTime
    task.endTime = currTime + needTime

    self:setTaskState(task,TASK_STATE_GUAJI)
    role:setRoleCurrState(ROLE_CURR_STATE_TEACHERGUAJI)
end

--中途取消任务
function TeacherGuaJiTaskUtil:cancelTask(task,callback)
    if task == nil then
        assert(false,"检查参数")
    end

    callback =  Helper:getDef(callback,EMPTY_FUNC)

    local rewards,duration = self:calculateBaseReward(task)

    self:getReward(rewards,duration,function (isSuceess)
        if isSuceess == true then
            task.startTime = nil --开始时间
            task.endTime = nil --结束时间
            task.submitTime = nil --提交时间
            task.teammate = nil --同行人列表
            task.knowlege = nil --选择的知识列表
            task.trendList = nil --记录的倾向列表
            task.estRewardList = nil --额外奖励列表
            self:setTaskState(task,TASK_STATE_ACCEPT) --设置为接取状态
            User:getRole():removeRoleCurrState(ROLE_CURR_STATE_TEACHERGUAJI)
        end
        
        callback(isSuceess)
    end)
end

-- 挂机完成，设置为完成未提交状态，移除人物正在进行师门挂机的状态
function TeacherGuaJiTaskUtil:completeTask(task)
    if task == nil then
        assert(false,"检查参数")
    end
    local role = User:getRole()
    self:setTaskState(task,TASK_STATE_TO_SUBMIT) --设置为完成状态
    role:removeRoleCurrState(ROLE_CURR_STATE_TEACHERGUAJI)
end

--提交任务
function TeacherGuaJiTaskUtil:submitTask(task,callback)
    if task == nil then
        assert(false,"检查参数")
    end

    local rewards,duration = self:calculateBaseReward(task)
    
    local extraRewads = self:getExtraReward(task)

    for rewardType,reward in pairs(extraRewads) do
        if rewards[rewardType] == nil then
            rewards[rewardType] = {}
        end

        if type(reward) == "table" then
            for attrName,attrValue in pairs(reward) do
                if rewards[rewardType][attrName] == nil then
                    rewards[rewardType][attrName] = attrValue
                else
                    rewards[rewardType][attrName] = rewards[rewardType][attrName] + attrValue
                end
            end
        end
    end

    self:getReward(rewards,duration,function (isSuccess)
        if isSuccess == true then
            self:setTaskSubmitTime(task) --设置任务提交时间
    
            self:recordTaskCount(task) --记录任务完成次数
            
            self:setTaskState(task,TASK_STATE_COMPLETE) --设置为已提交状态
        end

        callback(isSuccess)
    end)

end

-- 设置任务选择的知识技能
function TeacherGuaJiTaskUtil:setTaskKnowlege(task,knowlegeList)
    task.knowlege = knowlegeList
end

-- 获取任务选择的知识技能
function TeacherGuaJiTaskUtil:getTaskKnowlege(task)
    local knowlegeList = task.knowlege
    if knowlegeList == nil then
       knowlegeList = {}
    else
        local role = User:getRole()
        for skillId,v in pairs(knowlegeList) do
            if role:getSkillLv(skillId) <= 0 then
                knowlegeList[skillId] = nil
            end
        end
    end
    return knowlegeList
end

-- 设置任务选择的同伴
function TeacherGuaJiTaskUtil:setTaskTeammate(task,teammateList)
    task.teammate = teammateList
end

-- 获取任务选择的同伴
function TeacherGuaJiTaskUtil:getTaskTeammate(task)
    local teammate = task.teammate
    if teammate == nil then
       teammate = {}
    end
    return teammate
end

--[[任务状态改变时，执行的事件]]
local observers = {}
function TeacherGuaJiTaskUtil:registerObserver(name,func)
    observers[name] = func
end

function TeacherGuaJiTaskUtil:unRegisterObserver(name)
    observers[name] = nil
end

--设置任务状态
function TeacherGuaJiTaskUtil:setTaskState(task,state)
    task.state = state
    if MapIsEmpty(observers) == false then
        for k,v in pairs(observers) do
            if k == "updateBtn" and type(v) == "function" then
                v()
            end
        end
    end
end

--设置任务提交时间
function TeacherGuaJiTaskUtil:setTaskSubmitTime(task)
    local currTime = GetTime()
    task.submitTime = currTime
end

--记录任务已挂机次数
function TeacherGuaJiTaskUtil:recordTaskCount(task)
    local role = User:getRole()
    local taskCountList = role:getAttr("teacherGuaJiTaskCount")
    local taskId = task.id
    if type(taskCountList[taskId]) == "number" then
       taskCountList[taskId] = taskCountList[taskId] + 1
    else
        taskCountList[taskId] = 1
    end
end

--获取任务提交时间 ，目前用于任务刷新（任务刷新类型为2的任务）
function TeacherGuaJiTaskUtil:getTaskSubmitTime(task)
    local submitTime = task.submitTime
    if type(submitTime) ~= "number" then
        assert(false,"为什么任务提交时间不是数字")
    end

    if submitTime > GetTime() then
        assert(false,"为什么已经提交过的任务  提交时间比当前时间大")
    end

    return submitTime
end

--检查任务能否满足资源表里面的接取条件
-- return true/false
function TeacherGuaJiTaskUtil:checkTaskCondition(taskId)
    local role = User:getRole()
    local task = self:getTaskAttr(taskId)
    local taskCondition = task.condition
    if type(taskCondition) == "number" then
        if taskCondition == 0 then
            return true
        end
    elseif type(taskCondition) == "string" then
        local conditionList = string.split(taskCondition,";")
        if MapIsEmpty(conditionList) then
            return true
        end
        for i,v in ipairs(conditionList) do
            local conditionAttr = string.split(v,",")
            if conditionAttr == nil then
                print("TeacherGuaJiTaskUtil:checkTaskCanReceive(taskId)  检查任务接取条件")
                return false
            end
            local conditionType = tonumber(conditionAttr[1])
            local conditionValue = conditionAttr[2]
            if conditionType == 1 then
                local roleLv = role:getLv()
                if type(tonumber(conditionValue)) == "number" and roleLv >= tonumber(conditionValue) then
                else
                    return false
                end
            elseif conditionType == 2 then
                local valueAttr = string.split(conditionValue,"_")
                local mapId = valueAttr[1]
                local branchId = valueAttr[2]
                local nodeId = valueAttr[3]
                if mapId == nil or branchId == nil or nodeId == nil then
                    assert(false,"检查接取条件类型为2时的资源格式  conditionValue = "..conditionValue)
                end
                local nodeState = self:getMapNodeState(mapId,branchId,nodeId)
                if nodeState ~= NODE_COMPLETE then
                    return false
                end
            elseif conditionType == 3 then
                local items =
                        role:getItems(function(item)
                            return item.itemId == conditionValue
                        end
                    )
                    
                    if #items < 1 then
                        return false
                    end
            elseif conditionType == 4 then
                local valueAttr = string.split(conditionValue,"_")
                local mapId = valueAttr[1]
                local branchId = valueAttr[2]
                local nodeId = valueAttr[3]
                if mapId == nil or branchId == nil or nodeId == nil then
                    assert(false,"检查接取条件类型为4时的资源格式  conditionValue = "..conditionValue)
                end
                local nodeState = self:getMapNodeState(mapId,branchId,nodeId)
                if nodeState ~= NODE_WORKING then
                    return false
                end
            elseif conditionType == 5 then
                local role = User:getRole()
                if conditionValue == nil or conditionValue == "" then
                    assert(false,"检查接取条件类型为5时的资源格式  conditionValue = "..conditionValue)
                end
                if role:hasBasicTitle(conditionValue) == false then
                    return false
                end
            elseif conditionType == 6 then
                local guaJiTaskCountList = role:getAttr("teacherGuaJiTaskCount")
                local taskId = conditionValue
                if type(guaJiTaskCountList[taskId]) == "number" and guaJiTaskCountList[taskId] >= 1  then
                else
                    return false
                end
            elseif conditionType == 7 then
                local skillLv = role:getSkillLv(conditionValue)
                if skillLv == 0 then
                    return false
                end
            end 
        end

        return true
    else
        print("检查任务接取条件")
        return false
    end

end

--检查是否有足够的消耗道具，如果有，把道具消耗掉
function TeacherGuaJiTaskUtil:checkIsNeedItem(taskId)
    local role = User:getRole()
    local task = self:getTaskAttr(taskId)
    local taskNeedItem = task.needItem
    if type(taskNeedItem) == "number" then
        if taskNeedItem == 0 then
            return true
        end
    elseif type(taskNeedItem) == "string" then
        local needItemList = string.split(taskNeedItem,";")
        if MapIsEmpty(needItemList) then
            return false
        end
        local itemList = {}
        for i,v in ipairs(needItemList) do
            local needItemAttr = string.split(v,",")
            if needItemAttr == nil then
                print("TeacherGuaJiTaskUtil:checkIsNeedItem(taskId)  检查任务接取所需道具")
                return false
            end
            local itemId = needItemAttr[1]
            local itemCount = tonumber(needItemAttr[2])

            local haveCount = role:getItemCount(itemId)
            
            if haveCount < itemCount then
                print("物品数量不足，该任务不能接取 taskId = ",taskId,"itemId = ",itemId,"itemCount =",itemCount)
                return false
            end
            table.insert( itemList, {itemId = itemId,count = itemCount})
        end
        if not MapIsEmpty(itemList) then
            for k,v in pairs(itemList) do
                role:addItemCount(v.itemId, -v.count)
                local item = Item:getOneItemByKey(v.itemId)
                if item then
                    PopText("消耗"..item.name .. "X" .. v.count)
                else
                    print("物品不存在 itemId = ",v.itemId)
                end
            end
        end
        return true
    else
        print("检查任务接取所需道具")
        return false
    end
end

--获取物品所需文本
function TeacherGuaJiTaskUtil:getIsNeedItemText(taskId)
    local task = self:getTaskAttr(taskId)
    local taskNeedItem = task.needItem
    local text = ""
    if type(taskNeedItem) == "string" then
        local needItemList = string.split(taskNeedItem,";")
        if not MapIsEmpty(needItemList) then
            for i,v in ipairs(needItemList) do
                local needItemAttr = string.split(v,",")
                if needItemAttr then
                    local itemId = needItemAttr[1]
                    local itemCount = tonumber(needItemAttr[2])
                    local item = Item:getOneItemByKey(itemId)

                    if item and itemCount  then
                        if i == 1 then
                            text = text..itemCount.."个"..item.name
                        else
                            text = text.."，"..itemCount.."个"..item.name
                        end
                    end

                end
            
            end
        end
    end
    if text ~= "" then
        text = "需要消耗"..text.."才能接取此任务！"
    end

    return text
end

--检查任务门派限制
function TeacherGuaJiTaskUtil:checkTaskFamily(taskId)
    local role = User:getRole()
    if not role:hasFamily() then
        assert(false,"为什么没有入师门，能来接取师门任务")
    end

    local task = self:getTaskAttr(taskId)
    local taskFamily = task.family
    if type(taskFamily) == "number" then
        if taskFamily == 0 then
            return true
        end
    elseif type(taskFamily) == "string" then
        local familyList = string.split(taskFamily,";")
        if MapIsEmpty(familyList) then
            print("没有填门派")
            return false
        end
        for i,familyName in ipairs(familyList) do
            if familyName == role:getFamilyId()  then
                return true
            end
        end
        return false
    else
        print("检查任务门派限制")
        return false
    end
end

--因为策划改表，修复存档中的数据
function TeacherGuaJiTaskUtil:repairTaskData()
    local role = User:getRole()
    local teacherGuaJiTask = role:getAttr("teacherGuaJiTask") --存档里面有记录的任务
    local haveGjTask = false
    for taskId,task in pairs(teacherGuaJiTask) do
        if Mission[taskId] then
            Helper:tableCover(task, Mission[taskId])
        end
        
        --根据任务状态检查人物状态,修复数据不同步
        do
            local state = task.state
            if state == TASK_STATE_GUAJI then
                haveGjTask = true
            end
        end
    end
    if haveGjTask == true then
        role:setRoleCurrState(ROLE_CURR_STATE_TEACHERGUAJI)
    else
        role:removeRoleCurrState(ROLE_CURR_STATE_TEACHERGUAJI)     
    end
end

--获取挂机任务列表
function TeacherGuaJiTaskUtil:getTeacherGuaJiTaskList()
    local role = User:getRole()
    local taskList = {} --挂机任务列表
    local tasks = {} --资源表所有任务
    for taskId,task in pairs(Mission) do
        if self:checkTaskFamily(taskId) == true then
            tasks[taskId] = task
        else
        end
    end

    if MapIsEmpty(tasks) then
        return {}
    end
    
    local teacherGuaJiTask = role:getAttr("teacherGuaJiTask") --存档里面有记录的任务

    for taskId,task in pairs(teacherGuaJiTask) do
        self:refreshRoleTask(task)  --此处是否还有必要刷新！
        local state = task.state
        if state == TASK_STATE_IDLE or state == TASK_STATE_ACCEPT or state == TASK_STATE_GUAJI or state == TASK_STATE_TO_SUBMIT then
            table.insert(taskList, task)
        end
    end

    for taskId,task in pairs(tasks) do
        if teacherGuaJiTask[taskId] then
        else
            if self:checkTaskCondition(taskId) then
                task.state = TASK_STATE_IDLE
                table.insert( taskList, task)
            end
        end
    end

    return taskList
end

--检查是否有可以接取未接取的任务，或者能提交未提交的任务（用于任务按钮刷新）
-- return  true  or  false
function TeacherGuaJiTaskUtil:cheakTaskStateIsIdleOrSubMit()
    local taskList = self:getTeacherGuaJiTaskList()
    if MapIsEmpty(taskList) then
        return false
    end
    for i,task in ipairs(taskList) do
        local state = task.state
        if state and (state == TASK_STATE_IDLE or state == TASK_STATE_TO_SUBMIT) then
            return true
        end
    end

    return false
end

--检查是否有完成未提交的任务（用于判断是否能进行师门挂机）
-- return  true  or  false
function TeacherGuaJiTaskUtil:cheakTaskStateIsSubmit()
    local taskList = self:getTeacherGuaJiTaskList()
    if MapIsEmpty(taskList) then
        return false
    end
    for i,task in ipairs(taskList) do
        local state = task.state
        if state and state == TASK_STATE_TO_SUBMIT then
            return true
        end
    end

    return false
end

--检查存档记录的任务，根据规则刷新任务状态
function TeacherGuaJiTaskUtil:refreshRoleTask(task)
    if task == nil then
        return
    end
    local refreshType = task.refreshType
    local state = task.state
    local currTime = GetTime()
    local role = User:getRole()
    local teacherGuaJiTask = role:getAttr("teacherGuaJiTask") --存档里面有记录的任务
    if state == TASK_STATE_GUAJI then --检查挂机中的是否完成
        local endTime = task.endTime
        if type(endTime) == "number" then
            if currTime > endTime then
                self:completeTask(task) --挂机完成
                --更新角色年龄
                role:setGamingTime(endTime)
            else
                --更新角色年龄
                role:setGamingTime(currTime)
            end
        else
            assert(false,"为什么任务没有记录结束时间")
        end
    elseif state == TASK_STATE_COMPLETE then --已提交的任务，根据刷新类型 做相应处理
        if refreshType == 0 then
            self:setTaskState(task,TASK_STATE_DISABLE) --设置为不可用状态 
        elseif refreshType == 1 then
            teacherGuaJiTask[task.id] = nil --清除记录的任务，就能判断是否可以再次接取
        elseif refreshType == 2 then
            local submitTime = self:getTaskSubmitTime(task) --任务提交时间
            if Helper:diffWithDate(GetTime(), submitTime) >= 1 then
                --时间到了，清除记录的任务，就能判断是否可以再次接取
                teacherGuaJiTask[task.id] = nil
            end
        end
    end
end

--获取资源配表里任务属性
function TeacherGuaJiTaskUtil:getTaskAttr(taskId)
    if taskId == nil then
        assert(taskId,"任务id不存在")
        return 
    end
    return assert(Mission[taskId],"资源列表没有该任务 taskId = "..taskId)
end

--获取师门任务名字
function TeacherGuaJiTaskUtil:getTaskName(taskId)
    local task = self:getTaskAttr(taskId)
    local taskName = task.taskName

    return taskName
end

--获得任务步骤列表
function TeacherGuaJiTaskUtil:getTaskStepIdList(taskId)
    local task = self:getTaskAttr(taskId)
    local taskSteps = task.steps
    if taskSteps == nil or taskSteps == "" then
        assert(false,"TeacherGuaJiTaskUtil:getTaskStepIdList(taskId) 任务没有填步骤")
    end

    local stepIdList = string.split(taskSteps,",")
    
    return stepIdList
end

--获取步骤数量
function TeacherGuaJiTaskUtil:getStepNum(taskId)
    local stepIdList = self:getTaskStepIdList(taskId)

    return #stepIdList
end

--根据任务步骤id获取步骤资源配表
function TeacherGuaJiTaskUtil:getStepAttrByStepId(stepId)
    if stepId == nil then
        assert(false,"TeacherGuaJiTaskUtil:getStepAttrByStepId 参数为空")
    end

    return assert(StepList[stepId],"资源列表没有该任务步骤 stepId = "..stepId)
end

--计算任务一个步骤所需时间
function TeacherGuaJiTaskUtil:calOneStepNeedTime(taskId)
    local time = 1
    local task = self:getTaskAttr(taskId)
    local needTime = task.needTime
    local stepNum = self:getStepNum(taskId)

    time = math.floor(needTime / stepNum)
    return time
end

-- 任务开始的时候计算任务倾向契合情况和知识契合情况，然后保存下来
-- tongmenList 呼朋引伴时，选择的同伴数据（把亲密度也加进去，省的再获取一次）  menkeList 选择的门客数据
function TeacherGuaJiTaskUtil:calTrendCheck(task,tongmenList,menkeList)
    local trendList = {} --记录倾向契合情况list trendList[stepId] = 1 不契合 2 契合 3完美契合
    local stepIdList = self:getTaskStepIdList(task.id)
    for i,stepId in ipairs(stepIdList) do
        trendList[stepId] = {}

        local stepAttr = self:getStepAttrByStepId(stepId)
        local trendCheck = stepAttr.trendCheck
        if type(trendCheck) ~= "string" then
            assert(false,"TeacherGuaJiTaskUtil:getTrendCheck(task) 任务倾向有误 taskId = "..task.id) 
        end
        
        local trendCheckAttr = string.split(trendCheck,";")
        if trendCheckAttr == nil then
            assert(false,"TeacherGuaJiTaskUtil:getTrendCheck(task) 任务倾向有误 taskId = "..task.id.."stepId = ",stepId)
        end

        local trendType = tonumber(trendCheckAttr[1])
        local trendValue = tonumber(trendCheckAttr[2])

        if trendType == nil or trendValue == nil then
            assert(false,"TeacherGuaJiTaskUtil:getTrendCheck(task) 任务倾向有误 taskId = "..task.id)
        end
        switch(trendType,{
            [0] = function()
                local roleNum = #tongmenList + #menkeList + 1
                if roleNum < trendValue then
                    trendList[stepId].teammate = 1
                else
                    trendList[stepId].teammate = 2
                end
            end,
            [1] = function()
                if #menkeList < trendValue then
                    trendList[stepId].teammate = 1
                else
                    trendList[stepId].teammate = 2
                end
            end,
            [2] = function()
                if MapIsEmpty(tongmenList) then
                    --没有选择同门，默认为不契合
                    trendList[stepId].teammate = 1
                else
                    local ret = true 
                    for i,roleData in ipairs(tongmenList) do
                        local intimacy = roleData.intimacy
                        if intimacy < trendValue then
                            ret = false       
                        end
                    end
                    if ret == false then
                        trendList[stepId].teammate = 1
                    else
                        trendList[stepId].teammate = 2
                    end
                end
            end,
            [3] = function()
                if MapIsEmpty(menkeList) then
                    --没有选择门客，默认为不契合
                    trendList[stepId].teammate = 1
                else
                    local ret = true 
                    for i,roleData in ipairs(menkeList) do
                        local defaultZhongCheng = roleData.defaultZhongCheng
                        if defaultZhongCheng < trendValue then
                            ret = false       
                        end
                    end
                    if ret == false then
                        trendList[stepId].teammate = 1
                    else
                        trendList[stepId].teammate = 2
                    end
                end
            end,
            [4] = function()
                --考虑否掉
                -- 4=武器伤害力，值填最少需求数值，若队伍中无人装备的武器伤害力大于此数则不契合

                --暂时默认为不契合
                trendList[stepId].teammate = 1
            end,
            [5] = function()
                local ret = true
                local role = User:getRole()
                if role:getFinalAttr("looks") < trendValue then
                    ret = false
                end
                if not MapIsEmpty(tongmenList) then
                    for i,v in ipairs(tongmenList) do
                        if v.looks and v.looks < trendValue then
                            ret = false
                        end
                    end
                end
                if not MapIsEmpty(menkeList) then
                    for i,v in ipairs(menkeList) do
                        if v.looks and v.looks < trendValue then
                            ret = false
                        end
                    end
                end
                if ret == false then
                    trendList[stepId].teammate = 1
                else
                    trendList[stepId].teammate = 2
                end
            end,
            [6] = function()
                local ret = true
                local role = User:getRole()
                if role:getFinalAttr("age") < trendValue then
                    ret = false
                end
                if not MapIsEmpty(tongmenList) then
                    for i,v in ipairs(tongmenList) do
                        if v.age and v.age < trendValue then
                            ret = false
                        end
                    end
                end
                if not MapIsEmpty(menkeList) then
                    for i,v in ipairs(menkeList) do
                        if v.age and v.age < trendValue then
                            ret = false
                        end
                    end
                end
                if ret == false then
                    trendList[stepId].teammate = 1
                else
                    trendList[stepId].teammate = 2
                end
            end,
            [7] = function()
                local ret = true
                local role = User:getRole()
                if role:getFinalAttr("age") > trendValue then
                    ret = false
                end
                if not MapIsEmpty(tongmenList) then
                    for i,v in ipairs(tongmenList) do
                        if v.age > trendValue then
                            ret = false
                        end
                    end
                end
                if not MapIsEmpty(menkeList) then
                    for i,v in ipairs(menkeList) do
                        if v.age > trendValue then
                            ret = false
                        end
                    end
                end
                if ret == false then
                    trendList[stepId].teammate = 1
                else
                    trendList[stepId].teammate = 2
                end
            end,
            [8] = function()
                local ret = true
                local role = User:getRole()
                if role:getKongfu() < trendValue then
                    ret = false
                end
                if not MapIsEmpty(tongmenList) then
                    for i,v in ipairs(tongmenList) do
                        if v.kongfu and v.kongfu < trendValue then
                            ret = false
                        end
                    end
                end
                if not MapIsEmpty(menkeList) then
                    for i,v in ipairs(menkeList) do
                        if v.kongfu and v.kongfu < trendValue then
                            ret = false
                        end
                    end
                end
                if ret == false then
                    trendList[stepId].teammate = 1
                else
                    trendList[stepId].teammate = 2
                end
            end,
            [9] = function()
                local ret = true
                local role = User:getRole()
                if role:getFinalAttr("zhengqi") < trendValue then
                    ret = false
                end
                if not MapIsEmpty(tongmenList) then
                    for i,v in ipairs(tongmenList) do
                        if v.zhengqi and v.zhengqi < trendValue then
                            ret = false
                        end
                    end
                end
                if not MapIsEmpty(menkeList) then
                    for i,v in ipairs(menkeList) do
                        if v.zhengqi and v.zhengqi < trendValue then
                            ret = false
                        end
                    end
                end
                if ret == false then
                    trendList[stepId].teammate = 1
                else
                    trendList[stepId].teammate = 2
                end
            end,
        })
        
        local knowlegeCheck = stepAttr.knowledge
        if knowlegeCheck == 0 then
            trendList[stepId].knowledge = 3
        elseif type(knowlegeCheck) == "string" then
            local knowlegeCheckAttr = string.split(knowlegeCheck,";")
            if knowlegeCheckAttr == nil then
                assert(false,"TeacherGuaJiTaskUtil:getTrendCheck(task) 任务知识倾向有误 taskId = "..task.id.."stepId = ",stepId)
            end

            local knowlegeId = knowlegeCheckAttr[1]
            local knowlegeLv = tonumber(knowlegeCheckAttr[2])
            --选择的知识列表
            local knowlegeList = self:getTaskKnowlege(task)
            if MapIsEmpty(knowlegeList) then
                trendList[stepId].knowledge = 1 
            else
                if knowlegeList[knowlegeId] == true then
                    trendList[stepId].knowledge = 2
                    local skillLv = User:getRole():getSkillLv(knowlegeId)
                    if skillLv >= knowlegeLv then
                        trendList[stepId].knowledge = 3
                    end
                else
                    trendList[stepId].knowledge = 1
                end
            end
        end
        
        if trendList[stepId].teammate == nil or trendList[stepId].knowledge == nil then
            assert(false,"没有生成倾向  stepId = "..stepId)
        end
    end
    
    task.trendList = trendList
end

--获取任务步骤完成度
function TeacherGuaJiTaskUtil:getStepWanChengDu(task,stepId)
    local wanChengDu = 0
    if task == nil or stepId == nil then
        assert(false,"TeacherGuaJiTaskUtil:getStepDsc(task,stepId) 检查参数")
    end
    local trendList = task.trendList
    if MapIsEmpty(trendList) then
        assert(false,"任务开始时为什么没有保存 步骤倾向列表")
    end
    if not trendList[stepId] then
        assert(false,"没有这个任务步骤Id  stepId = "..stepId.."taskId = "..task.id)
    end

    if trendList[stepId].teammate == 1 then
        if trendList[stepId].knowledge == 1 then
            wanChengDu = 0.25
        elseif trendList[stepId].knowledge == 2 then
            wanChengDu = 0.4
        elseif trendList[stepId].knowledge == 3 then
            wanChengDu = 0.5
        else
            assert(false,"数据出错")
        end
    elseif trendList[stepId].teammate == 2 then
        if trendList[stepId].knowledge == 1 then
            wanChengDu = 0.6
        elseif trendList[stepId].knowledge == 2 then
            wanChengDu = 0.75
        elseif trendList[stepId].knowledge == 3 then
            wanChengDu = 1
        else
            assert(false,"数据出错")
        end
    else
        assert(false,"数据出错")
    end
    return wanChengDu
end

--根据任务步骤完成度获取步骤描述
function TeacherGuaJiTaskUtil:getStepDscByStepWanChengDu(stepWanChengDu)
    local stepDsc = ""
    local tab = {
        {wanChengDu = 0.25,stepDsc = "RED涉险过关"},
        {wanChengDu = 0.4,stepDsc = "HIR带水拖泥"},
        {wanChengDu = 0.5,stepDsc = "HIC差强人意"},
        {wanChengDu = 0.6,stepDsc = "GRN势如破竹"},
        {wanChengDu = 0.75,stepDsc = "HIY滴水不漏"},
        {wanChengDu = 1,stepDsc = "YEL完美达成"}
    }
    for i,v in ipairs(tab) do
        if v.wanChengDu == stepWanChengDu then
            stepDsc = v.stepDsc
        end
    end

    return stepDsc
end

--获得任务倾向描述和知识倾向描述
function TeacherGuaJiTaskUtil:getTaskTrendText(task,stepId)
    if task == nil or stepId == nil then
        assert(false,"检查参数")
    end
    local stepWanChengDu = self:getStepWanChengDu(task,stepId)
    local textId1,textId2 = "",""
    local stepAttr = TeacherGuaJiTaskUtil:getStepAttrByStepId(stepId)
    switch(stepWanChengDu,{
        [0.25] = function()
            local textId1Str = stepAttr.uncorrectText
            local textId1List = string.split(textId1Str,";")
            textId1 = textId1List[math.random(1,#textId1List)]

            local textId2Str = stepAttr.badText
            local textId2List = string.split(textId2Str,";")
            textId2 = textId2List[math.random(1,#textId2List)]
        end,
        [0.4] = function()
            local textId1Str = stepAttr.uncorrectText
            local textId1List = string.split(textId1Str,";")
            textId1 = textId1List[math.random(1,#textId1List)]
            
            local textId2Str = stepAttr.goodText
            local textId2List = string.split(textId2Str,";")
            textId2 = textId2List[math.random(1,#textId2List)]
        end,
        [0.5] = function()
            local textId1Str = stepAttr.uncorrectText
            local textId1List = string.split(textId1Str,";")
            textId1 = textId1List[math.random(1,#textId1List)]

            local textId2Str = stepAttr.bestText
            local textId2List = string.split(textId2Str,";")
            textId2 = textId2List[math.random(1,#textId2List)]
        end,
        [0.6] = function()
            local textId1Str = stepAttr.correctText
            local textId1List = string.split(textId1Str,";")
            textId1 = textId1List[math.random(1,#textId1List)]

            local textId2Str = stepAttr.badText
            local textId2List = string.split(textId2Str,";")
            textId2 = textId2List[math.random(1,#textId2List)]
        end,
        [0.75] = function()
            local textId1Str = stepAttr.correctText
            local textId1List = string.split(textId1Str,";")
            textId1 = textId1List[math.random(1,#textId1List)]

            local textId2Str = stepAttr.goodText
            local textId2List = string.split(textId2Str,";")
            textId2 = textId2List[math.random(1,#textId2List)]
        end,
        [1] = function()
            local textId1Str = stepAttr.correctText
            local textId1List = string.split(textId1Str,";")
            textId1 = textId1List[math.random(1,#textId1List)]

            local textId2Str = stepAttr.bestText
            local textId2List = string.split(textId2Str,";")
            textId2 = textId2List[math.random(1,#textId2List)]
        end
    })

    local textTrend1 = self:getTextByTextId(textId1)
    local textTrend2 = self:getTextByTextId(textId2)

    return textTrend1,textTrend2
end

--获取任务平均完成度
function TeacherGuaJiTaskUtil:getTaskAverageWCD(task)
    local trendList = task.trendList
    if MapIsEmpty(trendList) then
        assert(false,"任务开始时为什么没有保存 步骤倾向列表")
    end
    local finalWanChengDu = 0
    local stepNum = 0
    local stepWanChengDu = 0
    for stepId,v in pairs(trendList) do
        stepWanChengDu = self:getStepWanChengDu(task,stepId)
        stepNum = stepNum + 1
        finalWanChengDu = finalWanChengDu +  stepWanChengDu
    end
    local averageWanChengDu = finalWanChengDu/stepNum
    
    return averageWanChengDu
end

--@desc: 计算最终的基础奖励
--@author:Liang SongQiang
--@time:2019-07-19 15:33:28
function TeacherGuaJiTaskUtil:calculateBaseReward(task)
    local role = User:getRole()

    local rewards = {
        loc_attr = {},
        net_attr = {},
        items = {}
    }
    
    local currTime = GetTime()
    
    local startTime = task.startTime
    
    local duration = currTime - startTime
    
    if duration < 300 then
        return rewards,duration
    end

    local needTime = task.needTime

    local ratio = math.min(duration/needTime,1)
    
    local baseReward = self:getBaseReward(task)
    local wcd = self:getTaskAverageWCD(task)
    for rewardType,v in pairs(baseReward) do
        if rewards[rewardType] == nil then
            rewards[rewardType] = {}
        end

        if type(v) == "table" then
            for attrName,attrValue in pairs(v) do
                attrValue = math.floor(math.ceil(wcd*attrValue)*ratio)
                if rewards[rewardType][attrName] == nil then
                    rewards[rewardType][attrName] = attrValue
                else
                    rewards[rewardType][attrName] = rewards[rewardType][attrName] + attrValue
                end
            end
        end
    end

    return rewards,duration
end


local rewardAttr = {
    "exp","pot","prestige","yueli","weiwang","zhengqi","yinpiao","gongxiandian","money","gold"
}

local netAttr = {
    prestige = true,
    yinpiao = true,
    gongxiandian = true
}

--@desc: 基础奖励，目前只有属性奖励
--@author:Liang SongQiang
--@time:2019-07-19 10:56:43
function TeacherGuaJiTaskUtil:getBaseReward(task)
    local rewardstr = task.basicAwards

    if rewardstr == nil then
        assert(false,"检查任务基本奖励  taskId = "..task.id)
    end
    
    --@desc 区分网络属性及本地属性
    local rewards = {
        loc_attr = {},
        net_attr = {}
    }
    local reward_list = string.split(rewardstr,";")

    if MapIsEmpty(reward_list) == true then
        return rewards
    end

    for i,reward_str in ipairs(reward_list) do
        local reward_map = string.split(reward_str,",")

        if MapIsEmpty(reward_map) == true then
            assert(false,"检查奖励格式  taskId = "..task.id)
        end

        local attrIndex = tonumber(reward_map[1])

        local attrValue = tonumber(reward_map[2])

        if attrIndex == nil or attrValue == nil then
            assert(false,"检查奖励格式  taskId = "..task.id)
        end

        local attrName = rewardAttr[attrIndex]

        if attrName == nil then
            assert(false,"检查基本奖励类型Id  attrIndex = " .. attrIndex)
        end
        
        if netAttr[attrName] == true then
            rewards.net_attr[attrName] = attrValue
        else
            rewards.loc_attr[attrName] = attrValue
        end
    end

    return rewards
end

--@desc: 活动加成
--@author:Liang SongQiang
--@time:2019-07-22 15:05:00
--@rewards: 奖励列表
function TeacherGuaJiTaskUtil:actionBuff(rewards)
    local now_time = GetTime()
    --@desc 七夕活动 属性*1.5，物品*2
    if now_time >= Helper:getTimeStampWithStringDate("20190801", 0) and now_time < Helper:getTimeStampWithStringDate("20190815", 0) then
        for rewarType,reward in pairs(rewards) do
            if type(reward) == "table" then
                if rewarType == "items" then
                    for attrName,attrValue in pairs(reward) do
                        reward[attrName]= attrValue * 2
                    end
                else
                    for attrName,attrValue in pairs(reward) do
                        reward[attrName]= Helper:mathFloor(attrValue * 1.5)
                    end
                end

            end
        end
	end

    return rewards
end

--@desc: 领取奖励
--@author:Liang SongQiang
--@time:2019-07-19 11:50:41
--@rewards: 奖励列表
--@duration:持续时间
--@callback: 奖励结果回调
local isGetNetReward = true

function TeacherGuaJiTaskUtil:getReward(rewards,duration,callback)
    callback = Helper:getDef(callback,EMPTY_FUNC)

    rewards = self:actionBuff(rewards)

    local item_reward = rewards.items

    local loc_attr_reward = rewards.loc_attr

    local net_attr_reward = rewards.net_attr

    local role = User:getRole()

    if MapIsEmpty(item_reward) == false then
        if role:checkCanBuyTwoOrMoreThings(item_reward) == false then
            return callback(false)
        end
    end

    local loc_reward_func = function (locRewards,itemsReward)
        if MapIsEmpty(locRewards) == false then
            for attrName,attrValue in pairs(locRewards) do
                role:addAttr(attrName,attrValue)
                PopText("获得" .. role:getCHAttrName(attrName).. "：" ..tostring(attrValue))
            end
        end

        if MapIsEmpty(itemsReward) == false then
            for itemId,count in pairs(itemsReward) do
                local item = role:getOneItemByKey(itemId)
                if item then
                    role:addItemCount(itemId, count)
                    PopText("获得"..  item.name.." x " .. count)
                end
            end
        end

        callback(true)
    end

    local net_reward_func = function (net_rewards)
        
        if isGetNetReward then
            isGetNetReward = false
            HttpManagerEx:addCurrencyNumber(
                net_rewards,
                "guajiTask",
                duration,
                function(status, errcode, errmsg, data)
                    print("持续时间 = ",duration)
                    if status == 200 then
                        if errcode == 0 then
                            if MapIsEmpty(data.currency) == false then
                                for attrName,attr_value_tb in pairs(data.currency) do
                                    if attrName == "prestige" then
                                        --@desc 师门声望可能有额外加成
                                        if data.buff.shimenbuff1 ~= nil and data.buff.shimenbuff1 > 0 then
                                            PopText("掌门令生效，额外获得"..data.buff.shimenbuff1.."点师门声望！")
                                        end

                                        -- if data.buff.shimenbuff2 > 0 then
                                        --     PopText("江湖令生效，额外获得"..data.buff.shimenbuff2.."点师门声望！")
                                        -- end
                                    end

                                    if attr_value_tb.value ~= 0 then
                                        PopText("获得" .. role:getCHAttrName(attrName).. "：" ..tostring(attr_value_tb.value))
                                    end

                                    if attr_value_tb.desc ~= nil and attr_value_tb.desc ~= ""  then
                                        PopText(attr_value_tb.desc)
                                    end
                                end
                            end
                            loc_reward_func(loc_attr_reward,item_reward)
                            isGetNetReward = true
                        elseif errcode == 2 then
                            --@desc 师门挂机奖励有超出限制的的特殊情况（可能是回档，可能是SL）只发放本地奖励。
                            PopText(errmsg)
                            loc_reward_func(loc_attr_reward,item_reward)
                            isGetNetReward = true
                        else
                            callback(false)
                            PopText(errmsg)
                            print(errcode, errmsg)
                            isGetNetReward = true
                        end
                    else
                        isGetNetReward = true
                        callback(false)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
        
    end

    if MapIsEmpty(net_attr_reward) == false then
        --@desc 网络请求回调
        return net_reward_func(net_attr_reward)
    else
        return loc_reward_func(loc_attr_reward,item_reward)
    end
end

--@desc: 获取额外奖励
--@author:Liang SongQiang
--@time:2019-07-19 11:40:28
function TeacherGuaJiTaskUtil:getExtraReward(task)
    local extraRewards = {
        loc_attr = {},
        net_attr = {},
        items = {}
    }
    
    local extraAwardId = task.extraAward
    if extraAwardId == 0 then
        return extraRewards
    end
    
    local averageWCD = self:getTaskAverageWCD(task)
    if averageWCD * 100 < math.random(1,100) then
        return extraRewards
    end

    local role = User:getRole()
    local rewardArray =
        RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(
        extraAwardId,
        role:getAttr("exp"),
        role:getFinalAttr("luck"),
        role:getKongfu()
    )

    for i, reward in ipairs(rewardArray) do
        if reward.type == "物品" then
            extraRewards.items[reward.id] = tonumber(reward.value)
        elseif reward.type == "属性" then
            if netAttr[reward.id] == true then
                extraRewards.net_attr[reward.id] = tonumber(reward.value)
            else
                extraRewards.loc_attr[reward.id] = tonumber(reward.value)
            end
        else
            if DEBUG_MODE == 1 then
                assert(false, "奖励策略奖励类型填写错误")
            end
        end
    end

    return extraRewards
end

-- local transType = {
--     [1] = "经验",[2] = "潜能",[3] = "师门声望",[4] = "阅历",[5] = "江湖威望",
--     [6] = "侠义值",[7] = "银票",[8] = "师门贡献点",[9] = "碎银",[10] = "黄金"
-- }
-- --获取预计获得奖励
-- function TeacherGuaJiTaskUtil:getTaskBasicAwardMap(task)
--     local basicAwards = task.basicAwards
--     if basicAwards == nil then
--         assert(false,"检查任务基本奖励  taskId = "..task.id)
--     end
--     local rewardMap = {}
--     local basicAwardList = string.split(basicAwards,";")
--     if not MapIsEmpty(basicAwardList) then
--         for i,awardStr in ipairs(basicAwardList) do
--             local awardAttr = string.split(awardStr,",")
--             if awardAttr == nil then
--                 assert(false,"检查奖励格式  taskId = "..task.id)
--             end
--             local attrType = tonumber(awardAttr[1])
--             local attrValue = tonumber(awardAttr[2])
--             if type(attrType) ~= "number" or type(attrValue) ~= "number" then
--                 assert(false,"检查奖励格式  taskId = "..task.id)
--             end

--             local attrName = transType[attrType]
--             if attrName == nil then
--                 assert(false,"检查基本奖励类型Id  attrType = "..attrType)
--             end

--             rewardMap[attrName] = attrValue
--         end
--     end

--     return rewardMap
-- end

-- --设置额外奖励
-- function TeacherGuaJiTaskUtil:setEstRewardList(task,estRewardList)
--     task.estRewardList = estRewardList
-- end

-- -- 获取设置的额外奖励
-- function TeacherGuaJiTaskUtil:getEstRewardList(task)
--     local estRewardList = task.estRewardList
--     if estRewardList == nil then
--        estRewardList = {}
--     end
--     return estRewardList
-- end

-- --检查额外奖励map ，记得判断背包
-- function TeacherGuaJiTaskUtil:cheakExtraAwardMap(task)
--     local estRewardList = {}

--     local extraAwardId = task.extraAward
--     if extraAwardId == 0 then
--         self:setEstRewardList(task,estRewardList)
--         return true
--     end
--     local averageWCD = self:getTaskAverageWCD(task)
--     if averageWCD * 100 < math.random(1,100) then
--         self:setEstRewardList(task,estRewardList)
--         return true
--     end

--     local role = User:getRole()

--     local rewardArray =
--         RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(
--         extraAwardId,
--         role:getAttr("exp"),
--         role:getFinalAttr("luck"),
--         role:getKongfu()
--     )

--     estRewardList = {
--         ["属性"] = {},
--         ["物品"] = {}
--     }

--     for i, reward in ipairs(rewardArray) do
--         if reward.type == "物品" then
--             estRewardList["物品"][reward.id] = tonumber(reward.value)
--         elseif reward.type == "属性" then
--             estRewardList["属性"][reward.id] = tonumber(reward.value)
--         else
--             if DEBUG_MODE == 1 then
--                 assert(false, "奖励策略奖励类型填写错误")
--             end
--         end
--     end
--     self:setEstRewardList(task,estRewardList)
--     --@desc 判断背包是否已满
--     if not role:checkCanBuyTwoOrMoreThings(estRewardList["物品"]) then
--         return false
--     end
    
--     return true
-- end

-- --[[发放取消任务的奖励
-- 中途取消获得收益计算办法：
-- 1、	中途取消获得收益=预计奖励×（已挂机时间/任务时长），向下取整；
-- 2、	如果已挂机时间不足5分钟，则中途取消不会获得任何收益。]]
-- function TeacherGuaJiTaskUtil:sendCancelTaskReward(task)
--     if task == nil then
--         assert(false,"检查参数 TeacherGuaJiTaskUtil:sendCancelTaskReward(task)")
--     end
--     local currTime = GetTime()
--     local startTime = task.startTime
--     local duration = currTime - startTime
--     if duration < 5 * 60 then
--         return 
--     end

--     local role = User:getRole()
--     local needTime = task.needTime
--     local ratio = duration/needTime

--     local averageWCD = self:getTaskAverageWCD(task) --平均完成度
--     local baseRewardMap = self:getTaskBasicAwardMap(task)
--     if MapIsEmpty(baseRewardMap) then
--         return 
--     end
--     local addRatio=1   --相关加成系数
--     for attrName,attrValue in pairs(baseRewardMap) do
--         attrValue = math.floor(math.ceil(averageWCD*attrValue)*ratio) --中途取消获得收益=预计奖励×（已挂机时间/任务时长），向下取整；
--         if attrName == "师门声望" then
--             print("原声望值：",attrValue)
--             local originalVaule=attrValue
--             local isHave_shimenbuff1=false
--             local isHave_shimenbuff2=false
--             HttpManagerEx:checkGoodsValid({"shimenbuff1","shimenbuff2"}, function(status, errcode, errmsg, data)
--                 if status == 200 then
--                     if errcode == 0 then
--                         for k,v in ipairs(data) do 
--                             if v.itemId=="shimenbuff1" and v.number>0 then 
--                                 addRatio=addRatio+0.1
--                                 isHave_shimenbuff1=true
--                             end
--                             if v.itemId=="shimenbuff2" and v.number>0 then 
--                                 addRatio=addRatio+0.15
--                                 isHave_shimenbuff2=true
--                             end
--                         end
--                         attrValue = math.ceil(attrValue*addRatio)
--                             FamilyPrestige:addUserPrestige(
--                                 attrValue,
--                                 "guajiTask",
--                                 function(data)
--                                     local addPrestige = data.num
--                                     if tonumber(addPrestige)==tonumber(attrValue) then --未达到上限
--                                         if isHave_shimenbuff1 then 
--                                             local buffAddNum=math.ceil(originalVaule*0.1)
--                                             print("拥有掌门令，加成百分之10")
--                                             PopText("掌门令生效，额外获得"..buffAddNum.."点师门声望！")
--                                         end
--                                         if isHave_shimenbuff2 then 
--                                             local buffAddNum=math.ceil(originalVaule*0.15)
--                                             print("拥有江湖令，加成百分之15")
--                                             PopText("江湖令生效，额外获得"..buffAddNum.."点师门声望！")
--                                         end
--                                     end
--                                     if addPrestige ~= nil and addPrestige ~= 0 then
--                                         PopText("获得"..tostring(addPrestige)..attrName)
--                                     end
--                                 end
--                             )
--                     end     
--                 else
--                     PopText("网络请求出错,请换个网络环境再试!")
--                 end
--             end, IS_SHOW_WAITING)
            
--         elseif attrName == "银票" or attrName == "师门贡献点" then
--             HttpManagerEx:updateCurrencyByType("add",self:getENGAttrName(attrName),attrValue,nil, function(status, errcode, errmsg, data)
--                 if status == 200 then
--                     if errcode == 0 then
--                         PopText("获得"..attrName..tostring(attrValue))
--                     else
--                         print(errcode,errmsg)
--                     end
--                 end
--             end, IS_SHOW_WAITING)
--         else
--             local attr = self:getENGAttrName(attrName)
--             role:addAttr(attr,attrValue)
--             PopText("获得" .. attrName ..tostring(attrValue))
--         end
--     end
-- end

-- --发放提交任务奖励 
-- function TeacherGuaJiTaskUtil:sendSubmitTaskReward(task)
--     if task == nil then
--         assert(false,"检查参数 TeacherGuaJiTaskUtil:sendSubmitTaskReward(task)")
--     end
--     local role = User:getRole()
--     local baseRewardMap = self:getTaskBasicAwardMap(task)
--     local averageWCD = self:getTaskAverageWCD(task)

--     if MapIsEmpty(baseRewardMap) then
--     else
--         local addRatio=1  --相关加成系数
--         for attrName,attrValue in pairs(baseRewardMap) do
--             attrValue = math.ceil(attrValue*averageWCD) --任务基本奖励×完成度  取值向上取整；
--             if attrName == "师门声望" then
--                 print("原声望值：",attrValue)
--                 local originalVaule=attrValue
--                 local isHave_shimenbuff1=false
--                 local isHave_shimenbuff2=false
--                 HttpManagerEx:checkGoodsValid({"shimenbuff1","shimenbuff2"}, function(status, errcode, errmsg, data)
--                     if status == 200 then
--                         if errcode == 0 then
--                             for k,v in ipairs(data) do 
--                                 if v.itemId=="shimenbuff1" and v.number>0 then 
--                                     addRatio=addRatio+0.1
--                                     isHave_shimenbuff1=true
--                                 end
--                                 if v.itemId=="shimenbuff2" and v.number>0 then 
--                                     addRatio=addRatio+0.15
--                                     isHave_shimenbuff2=true
--                                 end
--                             end
--                             attrValue = math.ceil(attrValue*addRatio)
--                                 FamilyPrestige:addUserPrestige(
--                                     attrValue,
--                                     "guajiTask",
--                                     function(data)
--                                         local addPrestige = data.num
--                                         if tonumber(addPrestige)==tonumber(attrValue) then --未达到上限
--                                             if isHave_shimenbuff1 then 
--                                                 local buffAddNum=math.ceil(originalVaule*0.1)
--                                                 print("拥有掌门令，加成百分之10")
--                                                 PopText("掌门令生效，额外获得"..buffAddNum.."点师门声望！")
--                                             end
--                                             if isHave_shimenbuff2 then 
--                                                 local buffAddNum=math.ceil(originalVaule*0.15)
--                                                 print("拥有江湖令，加成百分之15")
--                                                 PopText("江湖令生效，额外获得"..buffAddNum.."点师门声望！")
--                                             end
--                                         end
--                                         if addPrestige ~= nil and addPrestige ~= 0 then
--                                             PopText("获得"..tostring(addPrestige)..attrName)
--                                         end
--                                     end
--                                 )
--                         end     
--                     else
--                         PopText("网络请求出错,请换个网络环境再试!")
--                     end
--                 end, IS_SHOW_WAITING)

--             elseif attrName == "银票" or attrName == "师门贡献点" then
--                 HttpManagerEx:updateCurrencyByType("add",self:getENGAttrName(attrName),attrValue,nil, function(status, errcode, errmsg, data)
--                     if status == 200 then
--                         if errcode == 0 then
--                             PopText("获得"..attrName..tostring(attrValue))
--                         else
--                             print(errcode,errmsg)
--                         end
--                     end
--                 end, IS_SHOW_WAITING)
--             else
--                 local attr = self:getENGAttrName(attrName)
--                 role:addAttr(attr,attrValue)
--                 PopText("获得" .. attrName ..tostring(attrValue))
--             end
--         end
--     end

--     local extraAwardMap = self:getEstRewardList(task)
--     local attrTab = extraAwardMap["属性"]
--     local itemTab = extraAwardMap["物品"]
--     if not MapIsEmpty(attrTab) then
--         for attr,attrValue in pairs(attrTab) do
--             role:addAttr(attr,attrValue)
--             PopText("获得" .. role:getCHAttrName(attr) ..tostring(attrValue))
--         end
--     end
--     if not MapIsEmpty(itemTab) then
--         for itemId,itemValue in pairs(itemTab) do
--             local item = Item:getOneItemByKey(itemId)
--             if item then
--                 local name = item.name
--                 role:addItemCount(itemId, itemValue)
--                 PopText("获得".. name.." x " .. itemValue)
--             else
--                 assert(false,"物品不存在  itemId = "..itemId)
--             end
--         end
--     end
-- end

-- --根据中文获取对应的英文属性名
-- function TeacherGuaJiTaskUtil:getENGAttrName(chaName)
--     if chaName == nil then
--         assert(false,"TeacherGuaJiTaskUtil:getENGAttrName(chaName) 检查参数")
--     end
--     local tab = {
--         ["经验"] = "exp",
--         ["潜能"] = "pot",
--         ["师门声望"] = "",
--         ["阅历"] = "yueli",
--         ["江湖威望"] = "weiwang",
--         ["侠义值"] = "zhengqi",
--         ["银票"] = "yinpiao",
--         ["师门贡献点"] = "gongxiandian",
--         ["碎银"] = "money",
--         ["黄金"] = "gold",
--     }

--     return assert(tab[chaName],"chaName"..chaName.."类型没有定义")
-- end

--根据文本id获取文本
function TeacherGuaJiTaskUtil:getTextByTextId(textId)
    if textId == nil then
        assert(false,"TeacherGuaJiTaskUtil:getTextByTextId(textId) 参数为空")
    end
    if TextList[textId] and type(TextList[textId]) == "table" then
        return TextList[textId].text
    else
        assert(false,"资源列表没有该文本 textId = "..textId)
    end
end

--设置刷新挂机列表函数
function TeacherGuaJiTaskUtil:setRefreshTaskListFunc(func)
    if type(func) ~= "function" then
        return 
    end
    self.refreshTaskListFunc = func
end

--获取刷新挂机列表函数
function TeacherGuaJiTaskUtil:getRefreshTaskListFunc()
    if type(self.refreshTaskListFunc) == "function" then
        return self.refreshTaskListFunc
    end
    return function() end
end

--获取副本节点状态 0未开启  1进行中  2已完成
function TeacherGuaJiTaskUtil:getMapNodeState(mapId,branchId,nodeId)
    if mapId == nil or branchId == nil or nodeId == nil then
        print("TeacherGuaJiTaskUtil:cheakMapNodeIsComplete 参数有误  mapId = ",mapId,"branchId = ",branchId,"nodeId = ",nodeId)
        return NODE_NOTOPEN
    end
    if DEBUG_MODE == 1 then
        print("mapId = ",mapId,"branchId = ",branchId,"nodeId = ",nodeId)
    end

    local role = User:getRole()
    local mapStore = role:getAttr("mapStore")
    
    if MapIsEmpty(mapStore) or MapIsEmpty(mapStore[mapId]) then
        return NODE_NOTOPEN
    end

    local currNodeId = mapStore[mapId][branchId]
    print("当前处于节点：currNodeId = ",currNodeId)
    if not currNodeId then
        return NODE_NOTOPEN
    end

    if currNodeId == nodeId then
        return NODE_WORKING
    else
        local map = role:getMapById(mapId)
        local branchMap = map.branchMap
        if not branchMap[branchId] then
            assert(false,"这个分支id不属于这个副本 mapId = ",mapId,"branchId = ",branchId)
        end

        local nodeMap = branchMap[branchId].nodeMap
        local node = nodeMap[currNodeId]
        if not node then
            assert(false,"这个节点id不属于这个分支 mapId = ",mapId,"branchId = ",branchId,"currNodeId = ",currNodeId)
        end

        local nodeId1 = node.id
        while true do
            local node1 = nodeMap[nodeId1]
            local parentId = node1.parentId
            if parentId == nil then
                return NODE_NOTOPEN
            else
                if parentId == nodeId then
                    return NODE_COMPLETE
                else
                    nodeId1 = parentId
                end
            end
        end
    end
    return NODE_NOTOPEN
end

return TeacherGuaJiTaskUtil0000000000000000