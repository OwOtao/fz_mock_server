local DispatchTaskLayer = class("DispatchTaskLayer", cc.Layer)

--@RefType [app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager#DispatchTaskManager]
local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")

function DispatchTaskLayer:create()
    local p = DispatchTaskLayer:new()
    p:init()
    return p
end

function DispatchTaskLayer:init()
    self._UI = require("Layer/TaskUI/ZhuXianUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.Text_BoxCount:setVisible(false)
    self.Image_kuang.Panel_rate:setVisible(false)
    self.Image_kuang.Text_desc:setVisible(false)
    self.Button_start:setVisible(false)
    self.Panel_Dispatch:setVisible(true)

    self.Button_GO.Text_GO:setString("确定")
    self.Button_cancel.Text_cancel:setString("取消")

    -- self.Text_SuccessRate_Desc:setVisible(true)

    self:setBack()
end

--@desc 用来记录页面打开时间，避免用户在0点前点开界面后，0点过后再派遣的情况。
local _showLayerTime = 0
local _map
local _dispatchTaskData
function DispatchTaskLayer:showLayer(role, taskId, map, func)
    -- 校准服务器时间
    HttpManagerEx:getTime(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 and data.time ~= nil then
                SetTime(tonumber(data.time))
                NETWORK_STATE = 1

                _showLayerTime = GetTime()
                _map = map
                _dispatchTaskData = DispatchTaskManager:initTaskData(role, taskId)

                if DEBUG_MODE == 1 then
                    print("------------------------------")
                    Helper:print_lua_table(_dispatchTaskData)
                    print("------------------------------\n")
                end

                self.Panel_title.Text_title:setString(
                    "派遣" .. role.name .. "完成" .. DispatchTaskManager:getDispatchTaskName(taskId)
                )

                self:setEstTime(_dispatchTaskData.estFinishTime)

                self:setEstCount(_dispatchTaskData.count)

                self:setEstReward(_dispatchTaskData.reward)

                -- self:setSuccessRate(_dispatchTaskData.successRate)

                self.Button_GO:releaseFunc(
                    function()
                        local nowTime = GetTime()

                        if Helper:diffWithDate(nowTime, _showLayerTime) >= 1 then
                            PopText("任务已刷新，请重新选择")
                            self:hideLayer()
                            return
                        end

                        local bool = DispatchTaskManager:dispatchTask(_dispatchTaskData, _map)

                        if bool then
                            self:hideLayer()
                            if func then
                                func()
                            end
                        end
                    end
                )

                self.Button_cancel:releaseFunc(
                    function()
                        self:hideLayer()
                    end
                )

                self:show()

                return true
            else
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end


--@desc: 设置预计完成时间
--@author:Liang SongQiang
--@time:2018-05-04 16:28:23
function DispatchTaskLayer:setEstTime(time)
    local hour, min, sec
    hour = math.floor(time / 3600)
    min = math.floor(math.mod(time / 60, 60))
    sec = math.floor(math.mod(time, 60))

    local text = ""
    if hour > 0 then
        text = text .. hour .. "小时" .. min .. "分" .. sec .. "秒"
    else
        text = text .. min .. "分" .. sec .. "秒"
    end

    self.Panel_Dispatch.Text_Time:setString("预计完成时间：" .. text)
end

--@desc 设置预计完成次数
function DispatchTaskLayer:setEstCount(count)
    self.Panel_Dispatch.Text_Count:setString("预计完成次数：" .. count .. "次")
end

--@desc: 设置预计奖励
--@author:Liang SongQiang
--@time:2018-05-04 16:27:59
function DispatchTaskLayer:setEstReward(reward)
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
    local attr = reward["属性"]

    local text = ""
    if not MapIsEmpty(attr) then
        for attrName, value in pairs(attr) do
            local name_cn = role:getCHAttrName(attrName)
            text = text .. value .. name_cn .. "，"
        end
    end

    local goods = reward["物品"]
    if not MapIsEmpty(goods) then
        for k, v in pairs(goods) do
            local item = Item:getOneItemByKey(k)
            text = text .. item.name .. "X" .. v .. "，"
        end
    end

    local activity_rewards = reward["activity"]
    if not MapIsEmpty(activity_rewards) then
        for _, reward in pairs(activity_rewards) do
            if reward.type == "属性" then
                local name_cn = role:getCHAttrName(reward.name)
                text = text .. reward.value .. name_cn .. "，"
            elseif reward.type == "物品" then
                local item = Item:getOneItemByKey(reward.name)
                text = text .. item.name .. "X" .. reward.value .. "，"
            end
        end
    end
    local resultText = string.sub(text, 1, -4)

    self.Panel_Dispatch.Text_Reward:setString("预计获得奖励：" .. resultText)
    self.Panel_Dispatch.Text_Reward:setTextColor({r = 255, g = 255, b = 255})
end

function DispatchTaskLayer:hideLayer()
    PopupLayerController:hideLayer(
        "DispatchTaskLayer",
        function(layer)
            layer:hide()
        end
    )
end

function DispatchTaskLayer:setBack()
    self.Panel_back:setTouchEnabled(true)
    self.Panel_back:releaseFunc(
        function()
            _map = nil
            _showLayerTime = nil
            self:hideLayer()
        end
    )
end

Helper:classDefNodeGetInstance(DispatchTaskLayer)
return DispatchTaskLayer
00