--[[
    副本中，人物可以读书、调息等动作，在此处统一处理。
]]
local UserStatusMapRelation = {}

--@RefType [src.app.views.layer.RoleLayer.RoleTaskControllor#RoleTaskControllor]
local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

--@desc 地图中需要判断的人物状态
local MAP_ROLE_STATUS = {
    [ROLE_CURR_STATE_READ] = true,
    [ROLE_CURR_STATE_BIGUAN] = true,
    [ROLE_CURR_STATE_TIAOXI] = true,
    [ROLE_CURR_STATE_XIULIAN] = true,
}

--@desc: 检查人物状态
--@author:Liang SongQiang
--@time:2018-09-17 14:31:36
--@map:[src.app.models.map.BaseMap#BaseMap]
--@role: [src.app.models.role.Role#Role]
function UserStatusMapRelation:checkRoleStatus(map, role)
    local status_list = role:getRoleCurrStateMap()

    if MapIsEmpty(status_list) == false then
        for status, boole in pairs(status_list) do
            if MAP_ROLE_STATUS[status] then
                self:showStatusLogic(map, role, status)
                return false
            end
        end
    end

    return true
end

--@desc 处理地图中状态逻辑
function UserStatusMapRelation:showStatusLogic(map, role, status)
    switch(
        status,
        {
            [ROLE_CURR_STATE_BIGUAN] = function()
                RoleTaskControllor:cancelBiGuanLayer(
                    role,
                    function()
                        role:setFlag("PVP活动状态", "空闲中")
                    end
                )
            end,
            [ROLE_CURR_STATE_READ] = function()
                RoleTaskControllor:cancelYanDuLayer(
                    role,
                    function()
                        role:setFlag("PVP活动状态", "空闲中")
                    end
                )
            end,
            [ROLE_CURR_STATE_TIAOXI] = function()
                RoleTaskControllor:cancelTiaoXiLayer(
                    role,
                    function()
                        role:setFlag("PVP活动状态", "空闲中")
                    end,
                    function()
                        role:setFlag("PVP活动状态", "空闲中")
                    end
                )
            end,
            [ROLE_CURR_STATE_XIULIAN] = function()
                RoleTaskControllor:cancelXiuLianLayer(
                    role,
                    function()
                        role:setFlag("PVP活动状态", "空闲中")
                    end
                )
            end,
        }
    )
end

return UserStatusMapRelation
00000