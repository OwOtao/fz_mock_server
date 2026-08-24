local YaoQingHanModel = {}

--@desc:发送邀请函
--@author:Liang SongQiang
--@time:2018-06-09 10:54:57
--@userName: 对方的名字
function YaoQingHanModel:sendYaoQingHan(userName)
    if not Helper:isChinese(userName) then
        PopText("只能输入中文。")
        return
    end

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    if userName == role:getAttr("name") then
        PopText("无法发送给自己。")
        return
    end

    local fq = role:getHomelandAttr("fq")

    local mid = role:getHouseId()

    if mid == nil then
        if DEBUG_MODE == 1 then
            assert(false, "发送邀请函失败，没有mid。")
        end
        PopText("发送失败。")
        return
    end

    local AffairFactory = require("app.models.HomelandModel.AffairModel.AffairFactory")
    local push_data = AffairFactory:createYaoQingHanPushData(userName, fq.mapId, mid)
    HttpManagerEx:pushAffair(
        push_data,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    PopText("你给" .. userName .. "发送了一份邀请函。")

                    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

                    local text = HomelandDesc:getUseShuAnText()
                    RichPrint("main", text)
                else
                    print("errcode : ", errcode)
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end
    )
end

--@desc: 领取邀请函
--@author:Liang SongQiang
--@time:2018-06-09 12:02:50
--@data: {'name' = userName,mid = mid,toMapId}
function YaoQingHanModel:getYaoQingHan(data)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local role_yq_list = role:getHomelandAttr("yq")

    local yq = {}

    if role_yq_list[data.userName] then
        yq = role_yq_list[data.userName]
    end

    local time = 3600 * 24
    yq.name = "RED" .. data.userName .. "的邀请函NOR"
    -- yq.dsc = "这是" .. data.userName .. "送给你的一封邀请函。\n（可向车夫递邀请函前往拜访）"
    yq.userName = data.userName
    yq.mid = data.mid
    yq.toMapId = data.toMapId
    yq.from_id = data.from_id
    yq.timeend = time
    yq.type = "邀请函"

    if not yq.id then
        yq.id = "yq" .. Helper:getOnlyId()
        role_yq_list[data.userName] = yq
        role:addItemCount(yq.id, 1, GetTime() + time)
    else
        role_yq_list[data.userName] = yq
    end

    self:updateInfo(yq)
end

function YaoQingHanModel:getDesc(yaoQingHan)
    local desc = "这是" .. yaoQingHan.userName .. "送给你的一封邀请函。\n（可向车夫递邀请函前往拜访）"
    return desc
end

--@desc:
--@author:Liang SongQiang
--@time:2018-09-10 17:48:58
--@data: 要改变的邀请数据的相关值
function YaoQingHanModel:updateInfo(data)
    if data.id == nil then
        assert(false, "data 参数没有id字段")
        return
    end

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local yqInfo = role:getHomelandAttr("yq")

    if MapIsEmpty(yqInfo) then
        return
    end

    for k, yq in pairs(yqInfo) do
        if yq.id == data.id then
            local _yqCache = role:getOneItemByKey(data.id)
            for k1, value in pairs(data) do
                _yqCache[k1] = value
                yq[k1] = value
            end
            break
        end
    end
end

--@desc:删除邀请函信息和物品
--@author:Liang SongQiang
--@time:2018-06-09 13:44:21
function YaoQingHanModel:deleteInfoAndItem(id)
    self:deleteYaoQingHanInfo(id)
    self:deleteYaoQingHanItem(id)
end

--[[
    @desc: 删除邀请函信息
    author:tanqinjian
    time:2025-08-16 17:21:09
    --@id: 
    @return:
]]
function YaoQingHanModel:deleteYaoQingHanInfo(id)
    local role = User:getRole()

    local yqInfo = role:getHomelandAttr("yq")

    if MapIsEmpty(yqInfo) then
        return
    end

    for k, yq in pairs(yqInfo) do
        if yq.id == id then
            local name = yq.userName
            local mid = yq.mid
            local id = yq.id
            yqInfo[k] = nil

            print("你删除了：", name, mid, id)
            break
        end
    end
end

--[[
    @desc: 删除邀请函物品
    author:tanqinjian
    time:2025-08-16 17:21:20
    --@id: 
    @return:
]]
function YaoQingHanModel:deleteYaoQingHanItem(id)
    local role = User:getRole()
    role:addItemCount(id, -1)
end

return YaoQingHanModel
0000000000000