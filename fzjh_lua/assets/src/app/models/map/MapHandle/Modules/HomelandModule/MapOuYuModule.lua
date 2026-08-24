--@desc 管家相关功能

--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local MapOuYuModule = class("MapOuYuModule", require("app.models.map.MapHandle.Modules.BaseModule"))

--@RefType [src.app.models.HomelandModel.MapMeetModel.OuYuModel#OuYuModel]
local OuYuModel = require("app.models.HomelandModel.MapMeetModel.OuYuModel")

--@RefType [src.app.models.HomelandModel.MapMeetModel.ShenShiTask#ShenShiTask]
local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")

--@desc 条件结果的方法
MapOuYuModule.doResult = {
    ["偶遇文本输出"] = function(map, result, environment)
        --arg2 npcId
        --arg3 输出文本

        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        local ouYuTask = role:getAttr("ouYuTask")

        if MapIsEmpty(ouYuTask.npc) then
            if DEBUG_MODE == 1 then
                assert(false, "偶遇任务NPC列表出错或任务未生成导致，检查代码。")
            end
            return
        end

        local npcId = result.arg2
        local roomId = ouYuTask.npc[npcId]

        if roomId == nil then
            Helper:print_lua_table(ouYuTask.npc)
            assert(false, "此NPCID 没有对应的生成地点：" .. npcId)
        end

        local fbId = string.split(roomId, "_")[1]

        local fb = role:getMapById(fbId)
        local fbName = fb.name
        local roomName = fb:getRoomNameById(roomId)

        local text = result.arg3

        text = string.gsub(text, "#fn#", fbName)
        text = string.gsub(text, "#rn#", roomName)

        RichPrint("main", text)
    end,
    ["名字随机"] = function(map, result, environment)
        local randomName = Helper:getRandomName(environment.currRole.sex)

        environment.currRole.name = randomName

        map.__MapLayer:delayRefreshMap()
    end,
    ["身世概况"] = function(map, result, environment)
        local npc = environment.currRole

        --@RefType [src.app.models.HomelandModel.MapMeetModel.ShenShiTask#ShenShiTask]
        local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")

        local lifeStatus = ShenShiTask:getTaskStatus(npc)

        if lifeStatus == 1 then
            ShenShiTask:openTaskDialog(npc, map)
            return
        elseif lifeStatus == 2 then
            --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
            local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
            local text = HomelandDesc:getShenShiDescription(npc.shenShi, npc)

            RichPrint("main", text)
        end
    end,

    ["完成身世任务"] = function(map, result, environment)
        -- objId: 人物id
        -- mid: 副本id
        -- up_data: //1传’’（空字符串）, 2传 天数， 3传要更新的武功数组 [‘武功1’ => ‘武功值1’, ‘武功2’ =>’武功值2’]
        -- }
        -- Response:
        -- {errcode:0, data:{pay_base: {unit:yinpiao, val:20}}}
        -- {errcode:0,data:{pay_time:时间戳}}
        -- {errcode:0, data:{ mobanSkill: {武功1 :值1, 武功2：值2}}}
        -- {errcode:1, errmsg:领取身世人物失败}

        -- type : 1/2/3，//0普通完成 无服务器奖励 ，1薪资减半，2  n天无需发薪水，3 武功技能等级增加
        --@desc 解析出来-0的情况
        local reward_type = tonumber(math.abs(result.arg2)) or 0

        
        if reward_type == -0 then
            reward_type = 0
        end

        --@desc 要增加的武功等级 和 多少天无需发薪的天数
        local up_value = result.arg3

        --@desc 完成任务成功执行的条件结果集
        local successStr = result.arg4

        --@desc 完成任务失败执行的条件结果集
        local failStr = result.arg5

        local send_data =
            switch(
            tostring(reward_type),
            {
                ["0"] = function()
                    return {up_data = ""}
                end,
                ["1"] = function()
                    return {up_data = ""}
                end,
                ["2"] = function()
                    return {up_data = tonumber(up_value)}
                end,
                ["3"] = function()
                    --@TODO 2018-09-03 21:51:16 要增加等级
                    local add_skills = {}
                    return {up_data = add_skills}
                end
            }
        )

        send_data.type = reward_type

        send_data.mid = User:getRole():getHouseId()

        --@desc
        local role = User:getRole()

        local roleTask = role:getAttr("ssTask")

        send_data.npcId = roleTask.serId

        HttpManagerEx:getShenShiReward(
            send_data.type,
            send_data.npcId,
            send_data.mid,
            send_data.up_data,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        if successStr then
                            map:doNoRoleResults(successStr, environment)
                        end
                        
                        --@RefType [src.app.models.HomelandModel.MapMeetModel.ShenShiTask#ShenShiTask]
                        local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")
                        ShenShiTask:clearTask()
                    else
                        if failStr then
                            map:doNoRoleResults(failStr, environment)
                        end

                        PopText(errmsg)
                    end
                else
                    if failStr then
                        map:doNoRoleResults(failStr, environment)
                    end
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end
}

--@desc:
--@author:Liang SongQiang
--@time:2018-04-27 14:28:12
function MapOuYuModule:entryMap(map, currTime)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local leaveTime = role:getFlag(map.id)

    if leaveTime and leaveTime ~= 0 then
        local useTime = currTime - leaveTime
        -- 地图刷新时间设置为5分钟
        if useTime >= MAP_REFRESH_INTERVAL then
            -- OuYuModel:acceptTask(map)
            ShenShiTask:createTaskInMap(map)
        else
            -- OuYuModel:acceptTask(map)
        end
    else
        -- OuYuModel:acceptTask(map)
        ShenShiTask:createTaskInMap(map)
    end
end

return MapOuYuModule
000000000000000