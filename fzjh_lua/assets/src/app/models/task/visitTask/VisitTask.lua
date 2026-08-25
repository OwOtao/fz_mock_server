
local Item = require("app.models.item.Item")
local visitTaskInfo = assert(require("script.others.bfrw"))
local visitTaskContent = visitTaskInfo["拜访任务"]

local visitTaskNpc = visitTaskInfo["npc生成表"]

local taskRewardType={
    ["pot"]="潜能",
    ["money"]="碎银",
    ["exp"]="经验",
}

local VisitTask = 
{
	isFirstShow=false,   --是否第一次显示
    isComplete=false,--是否完成
    visitTask = nil,
    okText = "",    --接受文本
    cancelText = "",--取消文本
    finishText = "",--完成文本
    taskMoney="",
    randNpc="",
}


function VisitTask:createTask(taskId)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local nowTime = GetTime()
    role:setAttr("openVisitTaskTime",nowTime)
    
    local task = self:getVisitTask(taskId)

    local roleId=task.taskNpc

    if roleId == nil then
        local randId1=math.random(1,5)
        if task.type == "免费型" then 
            roleId="mflnpc"..tostring(randId1)
        else
            roleId="xflnpc"..tostring(randId1)
        end
    end

    role:setAttr("vtNpcId",roleId)

    role:setAttr("visitTaskId",task.id)
    
    role:setTimeLimitFlag(task.flag,1,900)

    role:setFlag("visitTaskTalk",1)

    local todayCount = role:getDayFlag("拜访任务每日限制")
    
    role:setDayFlag("拜访任务每日限制",todayCount + 1)
end

function VisitTask:getTaskById(taskId)
    return Helper:getDef(visitTaskContent[taskId],{})
end

-- --初始化相关信息
-- function VisitTask:initText(visitTask)
-- 	if visitTask then 
-- 		local name_strs = self:getVisitNpcName(visitTask.taskNpc) or "神秘人"
-- 		local function changeText(text, name)
-- 	        if not text then 
-- 	            return ""
-- 	        end
-- 	        local printText = text
-- 	        printText = string.gsub(printText, "￥N", name)
-- 	        return printText
-- 	    end
-- 		self.okText = changeText(visitTask.okText, name_strs)
--     	self.cancelText = changeText(visitTask.cancelText, name_strs)
--     	self.finishText = changeText(visitTask.finishText, name_strs)
-- 		if visitTask.spendType then 
-- 			local spendMoneys=string.split(visitTask.spendType,";") 
-- 	        for i,v in pairs(spendMoneys) do  
-- 	            local type_money=string.split(spendMoneys[i],",")
-- 	            if type_money[1]=="money" then 
-- 	               self.taskMoney=type_money[2]
-- 	            end
-- 	        end
-- 		end
-- 	end
-- end

-- --初始化特殊 拜访任务
-- function VisitTask:initSpecialTask()
--     self.visitTaskSpecial = {}

--     for i,v in pairs(visitTaskContent) do
--         if v ~= nil then
--             if v.type == "特殊型" then
--                 table.insert(self.visitTaskSpecial, v)
--             end
--         end
--     end
-- end

-- -- 初始化免费型 拜访任务
-- function VisitTask:initFreeRewardTask()
--     self.visitTaskFree = {}

--     for i,v in pairs(visitTaskContent) do
--         if v ~= nil then
--             if v.type == 0 then
--                 table.insert(self.visitTaskFree, v)
--             end
--         end
--     end
-- end


-- function VisitTask:startTask(func,taskid)
-- 	if func == nil then
--         func = function()
--         end
--     end
--     HttpManagerEx:isOpenVisitTask(function(status, errcode, errmsg, data)
--         if status == 200 then
--             if errcode == 0 then
--                 self:resetContent()
--                 -- 获得能出现的拜访任务
--                 self.visitTask = self:getVisitTask(taskid)
--                 self:initText(self.visitTask)
--                 print("*****************self.visitTask.id:"..self.visitTask.id) 
--                 func()
--                 RichPrint("main","HIC屋外传来一阵敲门声，应是有人前来拜访。")
--             else
--                 print("拜访任务未开启")
--             end
--         end
--     end, IS_SHOW_WAITING)
-- end

-- --获取NPC名字
-- function VisitTask:getVisitNpcName(npcid)
--     if not npcid  then 
--     	if self.randNpc=="" then 
-- 	    	local randId1=math.random(1,5)
-- 	    	if self.visitTask.type == "免费型" then 
-- 	    		npcid="mflnpc"..tostring(randId1)
-- 	    	else
-- 	    		npcid="xflnpc"..tostring(randId1)
-- 	    	end
-- 	    	self.randNpc=npcid
-- 	    	return visitTaskNpc[self.randNpc].name or "侠客"
-- 		else

-- 			return visitTaskNpc[self.randNpc].name or "侠客"
-- 		end
--     end
--     if visitTaskNpc[npcid] then 
--         return visitTaskNpc[npcid].name
--     end
--     return 
-- end
-----------------------------------------------------------------------------------------------------------
-- @desc 判断任务是否达到触发条件
function VisitTask:checkCanGetVisitTask(task)
    local result = true
    if task == nil then
        return false
    end
    local role = User:getRole()
    if result == true and((type(task.conType) == "string" and string.len(task.conType) > 0 and type(task.conArg) == "string" and string.len(task.conArg) > 0) or type(task.conType) == "number") then
        local typeList, argList = string.split(task.conType, ";"), string.split(task.conArg, ";")
        if type(task.conType) == "number" then 
            typeList[1]=task.conType
            if typeList[1]==0 then 
                return true
            end
        end
        for i=1,10 do
            if typeList[i] == nil or argList[i] == nil then
                break
            end
            if self.DEBUG_MODE==true then 
                print("*********typeList[i]:"..typeList[i])
                print("*********argList[i]:"..argList[i])
            end
            -- conType     {    
            --     [1]="威望",
            --     [2]="正气值",
            --     [3]="人物等级",
            --     [4]="门派",
            --     [5]="房屋户型",
            --	   [6]="政绩"
            -- }
            -- conArg     {
            --     [1]="威望",
            --     [2]="正气值",
            --     [3]="人物等级",
            --     [4]="门派",
            --     [5]="房屋户型",
            --	   [6]="政绩"
            -- }
            local args, list = argList[i], {}
            if type(args) == "string" and string.len(args) > 0 then
                list = string.split(args, ",")
            end

            result = switch(tonumber(typeList[i]), 
            {
                [2] = function()
                    local zhengqi = role:getFinalAttr("zhengqi")
                    local argZhengQi1=tonumber(list[1])
                    local argZhengQi2=tonumber(list[2])
                    if argZhengQi1==0 or argZhengQi1==nil then 
                        return true
                    elseif (argZhengQi1>0 and zhengqi>=argZhengQi1) and (argZhengQi2==nil or (argZhengQi2~=nil and zhengqi<=argZhengQi2)) then 
                        return true
                    elseif (argZhengQi1<0 and zhengqi<=argZhengQi1) and (argZhengQi2==nil or (argZhengQi2~=nil and zhengqi>=argZhengQi2)) then 
                        return true
                    else
                        return false
                    end
                    -- add by XiaoZhiWei 2017/10/21 17:47:23 规则: 0,200 可不填,不填代表无限大 都填写则代表 取范围值
                    -- if (tonumber(list[1]) == nil or (tonumber(list[1]) ~= nil and  zhengqi >= tonumber(list[1]))) and (tonumber(list[2]) == nil or (tonumber(list[2]) ~= nil and  zhengqi <= tonumber(list[2]))) then
                    --     return true
                    -- else
                    --     return false
                    -- end
                end,

                [1] = function()
                    local weiwang = User:getRoleAttr("weiwang")
                    if (tonumber(list[1]) == nil or (tonumber(list[1]) ~= nil and weiwang >= tonumber(list[1]))) and (tonumber(list[2]) == nil or (tonumber(list[2]) ~= nil and weiwang <= tonumber(list[2]))) then
                        return true
                    else
                        return false
                    end
                end,

                [3] = function()
                    local roleLv=role:getLv()
                    if (tonumber(list[1]) == nil or (tonumber(list[1]) ~= nil and roleLv >= tonumber(list[1]))) and (tonumber(list[2]) == nil or (tonumber(list[2]) ~= nil and roleLv <= tonumber(list[2]))) then
                        return true
                    else
                        return false
                    end
                end,

                -- ["官职"] = function()
                --     local guanzhi = role:getAttr("officialType")
                --     for i,v in ipairs(list) do
                --         if tonumber(v) ~= nil and guanzhi == tonumber(v) then
                --             return true
                --         elseif v ~= nil and tonumber(v) == nil then
                --             if PRINT_MODE == 1 then
                --                 assert("官职限制数值填写错误, 只能填写数字 task = ".. tostring(task.id) ", 数值 = "..tostring(v))
                --             end
                --         end
                --     end
                --     return false
                -- end,

                [4] = function()
                    local familyName, familyId = role:getFamilyName(), role:getFamilyId()
                    for i,v in ipairs(list) do
                        if familyName == v or familyId == v then
                            return true
                        end
                    end
                    return false
                end,

                [5] = function()
                    local fq =  role:getHomelandAttr("fq")
                    if MapIsEmpty(fq) then 
                        return false
                    end
                    local FangQiModel = require("app.models.HomelandModel.FangQiModel")
                    local huxingTemplate = FangQiModel:getFangQiTemplateById(fq.fqId)
                    local huxing=huxingTemplate.hxId
                    huxing=string.gsub(huxing,"huxing","")
                    huxing=tonumber(huxing)
 
                    local hxId=string.gsub(list[1],"huxing","")
                    hxId=tonumber(hxId)
                    hxId=hxId<=5 and hxId or 5
                    if hxId<huxing then 
                        return true
                    else
                        return false
                    end
                end,

                [6] = function()
                    local guanzhi = User:getRoleAttr("officialType")
                    if guanzhi==0 then 
                        return false
                    end
                    local zhengji=User:getRoleAttr("officialAchievement")  --政绩
                    if (tonumber(list[1]) == nil or (tonumber(list[1]) ~= nil and zhengji >= tonumber(list[1]))) and (tonumber(list[2]) == nil or (tonumber(list[2]) ~= nil and zhengji <= tonumber(list[2]))) then
                        return true
                    else
                        return false
                    end
                end
            })

            -- add by XiaoZhiWei 2017/10/21 18:08:15 如果有条件无法达到,则直接退出判断
            if result == false then
                break
            end
        end
    end

    if (task.operation == 3 or task.operation == 4) and task.mapId then
        if role:isMapCompleted(task.mapId) ~= true then
            result = false
        end
    end

    return result
end


-- 获取拜访任务
function VisitTask:getVisitTask(taskid) --(taskid)仅供快捷键使用
    -- 随机任务
    local taskTab = {}
    local visitTask
    self.DEBUG_MODE=false
    for i,v in pairs(visitTaskContent) do
        local result = self:checkCanGetVisitTask(v)
        if result then
            table.insert(taskTab, v)
        end
    end
    
    local prMax = 0
    for i,v in pairs(taskTab) do
        if v ~= nil then
            -- print("v.type = " .. v.type .. " id = " .. v.id .. " 概率" .. v.pr)
            prMax = prMax + v.pr
        end
    end

    local num = math.random(1,prMax)
    local count = 0
    for i,v in pairs(taskTab) do
        count = count + v.pr
        if num <= count then
            visitTask = v
            -- print("v.type = " .. v.type .. " 拜访任务id = " .. v.id)
            break
        end
    end

    --仅供快捷键使用
    if taskid then 
        visitTask=visitTaskContent[taskid]
        self.DEBUG_MODE=true
        if self:checkCanGetVisitTask(visitTask) ==true then 
            print("条件相符****************")
        else
            PopText("当前角色不符合该任务所需开启条件。 任务ID = "..taskid)
            print("条件不符****************")
        end
    end
    -- --获取任务时保存任务id
    -- if  User:getRole():getTimeLimitFlag("visitTaskId")==0 then 
    --     User:getRole():setTimeLimitFlag("visitTaskId", visitTask.id, 1799)
    --     User:getRole():setTimeLimitFlag("visitTaskIsOpen", 1, 900)
    --     self:addroleLimitFlag(visitTask)
    -- end
    ---------------
    return visitTask
end

-- -- 获取副本开启拜访任务
-- function VisitTask:getVisitTaskFromMapId(mapId)
--     for k,v in pairs(self.visitTaskSpecial) do
--         if v ~= nil then
--             if v.mapId == mapId then
--                 return v
--             end
--         end
--     end
-- end

-- --重置界面内容
-- function VisitTask:resetContent()
--     self.visitTask = nil
--     self.taskMoney=nil
--     self.isFirstShow=false   --第一次显示
--     self.isComplete=false  --是否完成
--     self.okText = ""
--     self.cancelText = ""
--     self.finishText = ""
--     self.randNpc=""
-- end


-- 获取免费拜访任务
function VisitTask:getFreeVisitTask()
    local prMax = 0
    for i,v in pairs(self.visitTaskFree) do
        if v ~= nil then
            print("id = " .. v.id .. " 奖励 = " .. v.rewardType .. " 奖励数量 = " .. v.rewardCount .. " 概率" .. v.pr)
            prMax = prMax + v.pr
        end
    end

    local num = math.random(1,prMax)
    local count = 0
    for i,v in pairs(self.visitTaskFree) do
        count = count + v.pr
        if num <= count then
            visitTask = v
            print("拜访任务id = " .. v.id .. " 奖励 = " .. v.rewardType .. v.rewardCount)
            break
        end
    end

    return visitTask
end

function VisitTask:changeText(text, name)
    if not text then 
        return ""
    end
    local printText = text
    printText = string.gsub(printText, "￥N", name)
    return printText
end

--接受
function VisitTask:ok(type,task,npcName)

    local okText = Helper:getDef(task.okText,"")

    okText = self:changeText(okText,npcName)

    if type == "元宝" then
        RichPrint("main",okText)
        self:getReward(task,npcName)
    elseif type == "碎银" then
        local costMoney = 0
        if task.spendType then 
			local spendMoneys=string.split(task.spendType,";") 
	        for i,v in pairs(spendMoneys) do  
	            local type_money=string.split(spendMoneys[i],",")
	            if type_money[1]=="money" then 
                    costMoney=type_money[2]
	            end
	        end
		end
        User:getRole():addAttr("money", -tonumber(costMoney))
        RichPrint("main",okText)
        self:getReward(task,npcName)
    elseif type == "免费" then
        RichPrint("main",okText)
        self:getReward(task,npcName)
    elseif type == "任务" then
        local role = User:getRole()
        role:setTimeLimitFlag(task.flag, 1, 900)
        
        --@desc 只有operation为4时才能传送
        if task.operation == 4 then
            if task.destination then  -- fb10;fb10_32
                local item = Item:getOneItemByKey("dundifu")
                if not item then
                    return
                end
                local destinationLocal=string.split(task.destination, ";")
                local map = Map:getMapById(destinationLocal[1])
                local room= map:getRoomById(destinationLocal[2])
                local roomList=map:getNearRoomsExceptSelf(room.id,math.random(1, 3))

                local TransmitRoomModel = require("app.models.transmitRoom.TransmitRoomModel")
                local filterList = TransmitRoomModel:getVisitTaskFilterRoomList()

                if MapIsEmpty(filterList) == false then
                    for i = #roomList,1,-1 do 
                        if filterList[roomList[i]] then
                            table.remove(roomList,i)
                        end
                    end
                end

                local roomId = roomList[math.random(1, #roomList)]
                local mapId = destinationLocal[1]
                local text = "选择前往HIY"..map.name..room.name.."NOR的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）"
                local backClick = false
                local callfunc = function(result, failureState)
                    if result == true then
                        if task.destinationText then 
                            RichPrint("main", task.destinationText)
                        end
                    end
                end

                local JumpMapStylePrensenter = require("app.presenters.JumpMapStyle.JumpMapStylePrensenter"):create()
                JumpMapStylePrensenter:showLayer(role, mapId, roomId, text, backClick, callfunc)
            end
        elseif task.operation == 3 then
            role:setTimeLimitFlag(task.flag,3,900)
        end
        RichPrint("main",okText)
    end

    --@desc 表示已经交谈过一次
    User:getRole():setFlag("visitTaskTalk",2)
end

--拒绝
function VisitTask:cancel(task,npcName)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local cancelText = self:changeText(Helper:getDef(task.cancelText,""),npcName)

    RichPrint("main", cancelText)

    local isZhengJiType=false

    local conTypeList = string.split(task.conType,";")

    if MapIsEmpty(conTypeList) == false then
        for i,v in ipairs(conTypeList) do
            if tonumber(v) == 6 then
                isZhengJiType=true
                break
            end
        end
    end

    if isZhengJiType==true then
        -- 官员拒绝减少政绩 5
        if role:getAttr("officialType") ~= 0 and role:getAttr("officialType") ~= nil then
            HttpManagerEx:uploadOfficialAchievement(-5, role:getAttr("officialType"), function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        if data then
                            local role = User:getRole()
                            if role:getAttr("officialType") ~= 0 then
                                PopText("政绩 - " .. 5)
                                role:setAttr("officialAchievement", data.zhengji)
                            end
                        end
                    else
                        PopText(errmsg)
                    end
                else
                    PopText(errmsg)
                end
            end, IS_SHOW_WAITING)
        end
    end

    role:updateTimeLimitFlag(task.flag, 0)

    self:removeVisitNPC()
end

-- 消耗元宝
function VisitTask:payYuanBao(func)
    PopYuanBaoBuyItemLayer("", function(eventType)
        if eventType == "success" then
            if func then
                func()
            end
        end
    end)
end

--rewardArray  ("money,50000" or "exp,5000" or "pot,5000" or "itemid,1")
function VisitTask:getRewardByType(rewardArray) 
    if not rewardArray or type(rewardArray)~="table" then
        print("奖励配置不对") 
    else
        if rewardArray[1]=="pot" or rewardArray[1]=="money" or rewardArray[1]=="exp" then 
            User:getRole():addAttr(rewardArray[1], tonumber(rewardArray[2]))
            PopText("获得了 " ..taskRewardType[rewardArray[1]]..rewardArray[2])
        else
            User:getRole():addItemCount(rewardArray[1], tonumber(rewardArray[2]))
            PopText("获得了 " .. Item:getOneItemByKey(rewardArray[1]).name)
        end
        print("获取成功")
    end
end

-- 获得奖励
function VisitTask:getReward(task,npcName)
    -- or self.visitTaskText == nil 
    if  task == nil then
        return
    end

    local role = User:getRole()

    local map = role:getCurrMap()

    local text = self:changeText(Helper:getDef(task.finishText,""),npcName)

    RichPrint("main",text)

    local rewardArray={}
    if task.rsid and task.rsid~="" and MainControllLayer:getCurrLayer() == "MapLayer" and map then    --策略奖励
        local player=User:getRole()

        local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")
        --@RefType [src.app.models.reward.OpenRewardGet#OpenRewardGet]
        local openRewardGet =
            require("app.models.reward.OpenRewardGet"):create(
            player,
            {task.rsid},
            ARewardRecord.RTYPE.VISITTASK,
            "rewardArrayWithRewardScheme",
            {
                mapid = map.id,
                taskid = task.id
            }
        )

        openRewardGet:doGetReward(function (rewardArray)
            for i, reward in ipairs(rewardArray) do
                if reward.type == "物品" then
                    if map:addItemCount(reward.id, reward.value) == false then
                        map:dropItem(map:getCurrRoomId(), reward.id)
                        return
                    end
                    User:getRole():addItemCount(reward.id, reward.value)
                    PopText("获得 " .. Item:getOneItemByKey(reward.id).name .. " x " .. reward.value)
                elseif reward.type == "属性" then
                    if type(User:getRole():getCHAttrName(reward.id)) == "string" then
                        PopText("获得" .. player:getCHAttrName(reward.id) .. tostring(reward.value))
                    end
                    User:getRole():addAttr(reward.id, reward.value) 
                    map:richPrintText(User:getRole(), reward.id, reward.value) -- 角色属性变化文本显示
                end
            end
        end)
    elseif task.reward then   --商品奖励   --visitTask.reward  ("money,50000" or "exp,5000" or "pot,5000" or "itemid,1")
        local taskReward=string.split(task.reward, ",")

        self:getRewardByType(taskReward)
    end


    --威望奖励  
    if task.prestigeReward then
    	local prestigeStr = ""  --visitTask.prestigeReward (4;5;6  or 3 )
	    local prestigeRewardArray
    	if type(task.prestigeReward)=="number" then
    		prestigeRewardArray=task.prestigeReward 
    	elseif type(task.prestigeReward)=="string" then 
    		prestigeRewardArray=string.split(task.prestigeReward,";")         
		    if #prestigeRewardArray>1 then 
		        prestigeRewardArray=prestigeRewardArray[math.random(1,#prestigeRewardArray)]
		    else
		        prestigeRewardArray=prestigeRewardArray
		    end
    	end
        if prestigeRewardArray and prestigeRewardArray~="" then 
            User:addRoleAttr("weiwang", tonumber(prestigeRewardArray))
            prestigeStr = " 江湖威望 + " .. prestigeRewardArray
            PopText(prestigeStr)
        end
    end

    --政绩奖励
    if task.zhengji then 
    	local prestigeStr = ""
    	local zhengjiRewardArray
    	if type(task.zhengji)=="number" then
    		zhengjiRewardArray=task.zhengji 
    	elseif type(task.zhengji)=="string" then 
    		zhengjiRewardArray=string.split(task.zhengji,";")         
		    if #zhengjiRewardArray>1 then 
		        zhengjiRewardArray=zhengjiRewardArray[math.random(1,#zhengjiRewardArray)]
		    else
		        zhengjiRewardArray=zhengjiRewardArray
		    end
    	end
		
	    if zhengjiRewardArray and zhengjiRewardArray~="" then 
	        prestigeStr = " 政绩 + " .. zhengjiRewardArray
        end
        
		local role = User:getRole()
		if role:getAttr("officialType") ~= 0 and role:getAttr("officialType") ~= nil then
	        HttpManagerEx:uploadOfficialAchievement(tonumber(zhengjiRewardArray), role:getAttr("officialType"), function(status, errcode, errmsg, data)
	            if status == 200 then
	                if errcode == 0 then
	                    if data then
	                        if role:getAttr("officialType") ~= 0 then
	                            PopText(prestigeStr)
	                            role:setAttr("officialAchievement", data.zhengji)
	                        end
	                    end
	                else
	                    PopText(errmsg)
	                end
	            else
	                PopText(errmsg)
	            end
	        end, IS_SHOW_WAITING)
	    end
	end

    User:getRole():setTimeLimitFlag(task.flag, 0, 0)

    self:removeVisitNPC()
end

-- 检测能否获得奖励
function VisitTask:checkCanGetReward(task)
    if task == nil  then
        return false
    end
     local taskReward=string.split(task.reward, ",")

    if taskReward[1] == "pot" or taskReward[1] == "money" or taskReward[1] == "exp" then
        return true
    end

    local role = User:getRole()
    if #role:getAttr("items") >= role:getAttr("weight") then
        PopText("背包已满，无法获得物品")
        return false
    end
    return true
end

-- 检测能否购买
function VisitTask:chekcCanBuy(type,task)
    if task == nil then
        return false
    end
    if type == "元宝" then
    elseif type == "碎银" then
        local costMoney = 0
        if task.spendType then 
			local spendMoneys=string.split(task.spendType,";") 
	        for i,v in pairs(spendMoneys) do  
	            local type_money=string.split(spendMoneys[i],",")
	            if type_money[1]=="money" then 
                    costMoney=type_money[2]
	            end
	        end
		end
        if User:getRoleAttr("money") < tonumber(costMoney) then
            PopText("碎银不足")
            return false
        end
    end

    return true
end

--添加任务npc标记
function VisitTask:addroleLimitFlag(visitTask,time)
    if type(time)~="number" then 
        time=0
    end
    if visitTask and visitTask.flag and (visitTask.operation==0 or visitTask.operation==2) then 
        local role = User:getRole()
        role:setTimeLimitFlag(visitTask.flag, 1, 900-time)
    end
end
--创建拜访NPC
function VisitTask:createVisitNPC(task,roleId)

    local role_data = visitTaskNpc[roleId]
    local role = Helper:tableCover(require("app.models.npc.BaseNpc"):create(), role_data)

    -- Npc:initRoleWithRandomAttr(role)
    -- Map:initNpcEquipsAndItems(role)
    -- Map:initNpcActiveZhao(role)
    
    Npc:initNpc(role)
    
    role.id="visitNpc"
    role.type="role"
    role.conditionAndResults = {
        {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家操作",
                    arg2 = "操作1"
                }
            },
            results = {
                {
                    arg1 = "拜访交谈",
                }
            }
        }, 
        {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家操作",
                    arg2 = "操作2"
                }
            },
            results = {
                {
                    arg1 = "拜访送礼"
                }
            }
        },
        {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家操作",
                    arg2 = "操作3"
                }
            },
            results = {
                {
                    arg1 = "拜访切磋"
                }
            }
        },
    }
    role.caozuo1 = 1
    role.caozuoName1 = "交谈"
    role.caozuo2 = 0
    role.caozuoName2 = "送礼"
    role.caozuo3 = 0
    role.caozuoName3 = "切磋"

    if task.operation==0 then 
        role.onlyTalk=1
        role.talkTimes=0
    elseif task.operation==1 then 
    elseif task.operation==2 then
        role.caozuo3 = 1
    elseif task.operation==3 then
        local player = User:getRole()
    	if player:getTimeLimitFlag(task.flag) == 3 then 
    		role.caozuo2 = 1
    		role.receivePresent=task.conditions
    	end
    elseif task.operation==4 then
    end
    return role
end

--移除npc
function VisitTask:removeVisitNPC(isRefresh)    --是否刷新
	local currMap=User:getRole():getCurrMap()
	if currMap and currMap:getMapType() == MAP_TYPE.MYHOME and currMap:checkRoleIsInRoom(currMap.entryRoom, "visitNpc")==true then 
        currMap:removeRoomRole(currMap.entryRoom,"visitNpc")
        currMap.__MapLayer:delayRefreshMap()
   	end
end

return VisitTask00000