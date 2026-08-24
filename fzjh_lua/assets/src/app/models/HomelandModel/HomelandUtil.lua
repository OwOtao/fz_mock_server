local HomelandUtil = {}

function HomelandUtil:sysIsOpen(isShowMsg)
    if isShowMsg == nil then
        isShowMsg = true
    end
    if JIAYUAN_SYSTEM_IS_OPEN == false then
        if isShowMsg == true then
            PopText("该系统暂未开放。")
        end
        return false
    end
    
    local role = User:getRole()
    if role:getInheritFlag("家园引导") <= 1 then
        if isShowMsg == true then
            PopText("需在扬州尤三处完成家园引导方可使用该功能")
        end
        return false
    end
    
    return true
end


--@desc: 更新人物身上的标记
--@author:Liang SongQiang
--@time:2018-09-30 11:23:44
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandUtil:updatePlayerFlag(map)
    if map == nil then
        return
    end

    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    self:updateRoomFlag(map)

    self:updateRoleFlag(map)
end


local FLAG_ROOM_CONFIG = {
    --[[
        roomType = flagName
    ]]
    --@desc 书房
    ["tsfangjian006"] = "bookroom",
    --@desc 练功房
    ["tsfangjian009"] = "practiceroom",
    --@desc 饰品房
    ["tsfangjian010"] = "decorroom",
    --@desc 调息室
    ["tsfangjian015"] = "pranayamaroom",
    --@desc 闭关室
    ["tsfangjian018"] = "retreatroom",
    --@desc 厨房
    ["tsfangjian014"] = "kitchen",
}

local FLAG_ROLE = {
    --@desc 管家
    ["guanjia001"] = "haveGj"
}

--@desc: 更新房间相关标记
--@author:Liang SongQiang
--@time:2018-09-30 14:19:05
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandUtil:updateRoomFlag(map)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    for roomType,flag_name in pairs(FLAG_ROOM_CONFIG) do
        local num = map:getRoomCountByType(roomType)

        if num > 0 then
            player:setInheritFlag(flag_name,1)
        else
            player:setInheritFlag(flag_name,nil)
        end
    end
end

--@desc: 更新仆人相关标记
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandUtil:updateRoleFlag(map)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    for jobType,flag_name in pairs(FLAG_ROLE) do
        local num = map:getPersonTypeCount(jobType)

        if num > 0 then
            player:setInheritFlag(flag_name,1)
        else
            player:setInheritFlag(flag_name,nil)
        end
    end
end


--@desc:清除房间相关人物标记 
--@author:Liang SongQiang
--@time:2018-10-08 10:26:51
function HomelandUtil:clearRoomFlag()
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    for roomType,flag_name in pairs(FLAG_ROOM_CONFIG) do
        player:setInheritFlag(flag_name,nil)
    end
end

--@desc: 根据flag判断是否拥有房间
--@author:Liang SongQiang
--@time:2018-10-08 16:19:22
--@roomType: 房间类型
function HomelandUtil:isRoomByTypeFromFlag(roomType)
    local bool = false
    
    local flag_name = FLAG_ROOM_CONFIG[roomType]
    if flag_name ~= nil then
        --@RefType [src.app.models.role.Role#Role]
        local player = User:getRole()
        local flag = player:getInheritFlag(flag_name)
        if flag == 1 then
            bool = true
        end
    end

    return bool
end

--@desc: 根据flag判断是否有指定职业的人物
--@jobType: 房间类型
function HomelandUtil:isJobTypeFromFlag(jobType)
    local bool = false
    
    local flag_name = FLAG_ROLE[jobType]
    if flag_name ~= nil then
        --@RefType [src.app.models.role.Role#Role]
        local player = User:getRole()
        local flag = player:getInheritFlag(flag_name)
        if flag == 1 then
            bool = true
        end
    end

    return bool
end

return  HomelandUtil0000000000000000