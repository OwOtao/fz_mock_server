local AffairFactory = {}

--@RefType [src.app.models.HomelandModel.AffairModel.Affair#Affair]
local Affair = require("app.models.HomelandModel.AffairModel.Affair")

--@desc: 创建阅读型事务
--@author:Liang SongQiang
--@time:2018-08-08 16:02:16
--@args:
function AffairFactory:createReadAffair(...)
    -- body
end

--@desc: 创建功能型事务
--@author:Liang SongQiang
--@time:2018-08-08 18:11:25
--@args:
function AffairFactory:createFuncAffair(...)
    -- body
end

--@desc: 进行闯门切磋的事务
--@author:Liang SongQiang
--@time:2018-08-22 14:17:17
--@targetId:对方的NPCID
--@my_role: 自己
function AffairFactory:createIntrudedPushData(targetId, my_role)
    local userid = User:getUserId()

    local push_data = {
        affair_id = 7,
        userid = targetId,
        affair_val = {
            from_name = my_role:getAttr("name")
        },
        biz_type = AFFAIR_TYPE_SHOW,
        from_id = userid,
        expired_time = GetTime() + 24 * 3600,
        objId = userid
    }

    return push_data
end

--@desc: 创建房屋升级事务
--@author:Liang SongQiang
--@time:2018-08-22 14:40:09
function AffairFactory:createHouseUpgradeAffair(npc)
    if npc == nil then
        return
    end

    --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")
    --@desc 房契模板ID
    local fqId = fq.fqId
    
    if PRINT_MODE == 1 then
        print("房契模板ID = ", fqId)
    end

    local FangQiModel = require("app.models.HomelandModel.FangQiModel")
    local fangqiMobanAttr = FangQiModel:getFangQiTemplateById(fqId)
    local affair = nil
    -- 房屋提升所需管家忠诚度;levelloyal	房屋升级id;levelid
    if fangqiMobanAttr.levelup == 1 and npc.defaultZhongCheng >= fangqiMobanAttr.levelloyal then
        affair = {
            userid = User:getUserId(),
            affair_id = 1,
            affair_val = {},
            biz_type = 1,
            from_id = "",
            objId = fqId,
            is_local = 1,
        }
    end
    return affair
end

--@desc: 邀请函事务
--@author:Liang SongQiang
--@time:2018-08-22 17:29:10
--@targetName:收件人的名字
--@toMapId:玩家自己房契上对应的副本id
--@my_mid: 玩家的副本id
function AffairFactory:createYaoQingHanPushData(targetName,toMapId,my_mid)
    local name = User:getRoleAttr("name")

    local push_data = {
        userid = "",
        affair_id = "8",
        affair_val = {
            from_name = name,
            name = targetName,
            mid = my_mid,
            toMapId = toMapId
        },
        biz_type = 3,
        from_id = User:getUserId(),
        expired_time = GetTime() + 3600 * 48,
        count = "",
        objId = my_mid
    }
    

    return push_data
end


return AffairFactory
000000000000000