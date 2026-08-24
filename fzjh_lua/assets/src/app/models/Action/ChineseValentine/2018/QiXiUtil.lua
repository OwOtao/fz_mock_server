local QiXiUtil = {}

local qixi_res = require("script.others.xiqi")

--[[
	传承不断进度
]]
-- 表面年龄;info1	样貌;info2	衣着打扮;info3	表面健康;info4

local surfaceInfo = {
    info1 = 1,
    info2 = 3,
    info3 = 2,
    info4 = 4
}

-- 真实年龄;true1	性格;true2	家世;true3	武功;true4	真实健康;true5
local trueInfo = {
    true1 = 1,
    true2 = 5,
    true3 = 6,
    true4 = 7,
    true5 = 4
}

local infoDesc = {
    --@desc 年龄
    [1] = "",
    --@desc 身着
    [2] = "",
    --@desc 样貌
    [3] = "",
    --@desc 健康
    [4] = "",
    --@desc 性格
    [5] = "",
    --@desc 家世
    [6] = "",
    --@desc 武功
    [7] = ""
}

function QiXiUtil:getNpcInfo(roleId)
    local res = qixi_res.People

    local info = res[roleId]

    return info
end

--@desc: 获取人物隐藏真实信息的数组
--@author:Liang SongQiang
--@time:2018-08-11 17:18:18
--@roleId:人物ID
function QiXiUtil:getTrueInfo(roleId)
    local trueInfo = {}

    local npc_res = self:getNpcInfo(roleId)

    for i = 1, 5 do
        local trueId = "true" .. i
        trueInfo[trueId] = npc_res[trueId]
    end

    return trueInfo
end

--@desc: 获取指定指定字段的描述文本
--@author:Liang SongQiang
--@time:2018-08-12 19:35:34
function QiXiUtil:getRoleInfoDescArray(sex, info_key, info_id)
    local res_info = {}

    if sex == "男" then
        res_info = qixi_res.Minfo
    else
        res_info = qixi_res.Finfo
    end

    local role_info = res_info[tostring(info_id)]

    if role_info == nil then
        assert(false, sex .. "，" .. info_key .. "，" .. info_id .. "，")
    end

    local desc_array = string.split(role_info[info_key], ";")

    return desc_array
end

--@desc: 储存人物信息
--@author:Liang SongQiang
--@time:2018-08-12 19:55:34
--@npc_id: npc的ID
--@key_name:s_info(表面信息),t_info(真实信息)
--@info_key:信息的字段名（info1..4,true1..6)
--@v_str: 索引字符串“1,1”,前面是Minfo或者Finfo表的ID，后面是文本数组的索引
function QiXiUtil:saveNpcDescInfo(npc_id, key_name, info_key, v_str)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local npc_info_save_list = role:getDayFlag("qxnpcinfo")

    if npc_info_save_list == 0 then
        npc_info_save_list = {}
    end

    local npc_save_info = npc_info_save_list[npc_id]

    if npc_save_info == nil then
        npc_save_info = {
            s_info = {},
            t_info = {}
        }
    end

    npc_save_info[key_name][info_key] = v_str

    npc_info_save_list[npc_id] = npc_save_info

    role:setDayFlag("qxnpcinfo", npc_info_save_list)
end

--@desc: 获取NPC储存的信息
--@author:Liang SongQiang
--@time:2018-08-12 20:14:10
function QiXiUtil:getNpcDescInfo(npc_id, key_name, info_key)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local npc_info_save_list = role:getDayFlag("qxnpcinfo")

    if npc_info_save_list == 0 then
        return
    end

    local npc_save_info = npc_info_save_list[npc_id]

    if npc_save_info == nil then
        return
    end

    local info_str = npc_save_info[key_name][info_key]

    if info_str == nil then
        assert(false, "储存处有问题。")
    end

    return info_str
end

function QiXiUtil:saveNpcShowOrHideTrueKey(npc_id, showType, tb)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local npc_info_save_list = role:getDayFlag("qxnpcinfo")

    local npc_save_info = npc_info_save_list[npc_id]

    npc_save_info[showType] = tb

    npc_info_save_list[npc_id] = npc_save_info

    role:setDayFlag("qxnpcinfo", npc_info_save_list)
end

function QiXiUtil:getNpcShowOrHideTrueKey(npc_id, showType)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local npc_info_save_list = role:getDayFlag("qxnpcinfo")

    if npc_info_save_list == 0 then
        return
    end

    local npc_save_info = npc_info_save_list[npc_id]

    if npc_save_info == nil then
        return
    end

    local result_tb = npc_save_info[showType]

    if result_tb == nil then
        assert(false, "储存处有问题。")
    end

    return result_tb
end

function QiXiUtil:createRoleFormFile(npc_data)
    local info = clone(infoDesc)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local npc_info_list = role:getDayFlag("qxnpcinfo")[npc_data.id]

    local res_info
    if npc_data.sex == "男" then
        res_info = qixi_res.Minfo
    else
        res_info = qixi_res.Finfo
    end

    --@region 表面信息生成
    local surface_text = {}
    local sucrface_tb = npc_info_list["s_info"]
    for i = 1, 4 do
        local info_key = "info" .. i
        local v_str = sucrface_tb[info_key]

        local v_tb = string.split(v_str, ";")

        local info_id = v_tb[1]

        local random_index = v_tb[2]

        local desc_array = self:getRoleInfoDescArray(npc_data.sex, info_key, info_id)

        local text = desc_array[tonumber(random_index)]

        surface_text[info_key] = text
    end
    --@endregion

    --@region 真实信息生成
    local true_text = {}

    local show_key_list = {}
    local true_tb = npc_info_list["t_info"]
    for i = 1, 5 do
        local info_key = "true" .. i
        local v_str = true_tb[info_key]

        local v_tb = string.split(v_str, ";")

        local info_id = v_tb[1]

        local random_index = v_tb[2]

        local desc_array = self:getRoleInfoDescArray(npc_data.sex, info_key, info_id)

        local text = desc_array[tonumber(random_index)]

        true_text[info_key] = text
    end

    --@endregion

    local hide_key_list = npc_info_list["hide_key"] or {}

    local final_true_text = {}
    for true_key, text in pairs(true_text) do
        local isHide = false

        if not MapIsEmpty(hide_key_list) then
            for _, hide_index in ipairs(hide_key_list) do
                if true_key == "true" .. hide_index then
                    isHide = true
                    break
                end
            end
        end

        if isHide == false then
            final_true_text[true_key] = text
        end
    end

    for info_key, text in pairs(surface_text) do
        local index = surfaceInfo[info_key]
        info[index] = text
    end

    for true_key, text in pairs(final_true_text) do
        local index = trueInfo[true_key]
        info[index] = text
    end
    local npc = require("app.models.npc.BaseNpc"):create()
    Helper:tableCover(npc, npc_data)

    npc.id = npc_data.id
    npc.name = npc_data.name
    npc.sex = "野兽"
    npc.realSex = npc_data.sex
    npc.dsc = ""
    npc.hide_key_list = hide_key_list
    npc.infoDesc = info
    npc.surface_text = surface_text
    npc.true_text = true_text

    if npc_info_list.isTrue == 1 then
        npc.isTrue = 1
        npc.dsc = self:getAllTrueInfo(npc)
    else
        for _, text in ipairs(info) do
            npc.dsc = npc.dsc .. text
        end
    end

    local cr = self:getCR()
    Helper:tableCover(npc, cr)

    if npc.hidenum == 0 or npc_info_list.isTrue == 1 then
        npc.caozuo3 = 0
    end

    if tostring(npc.special) == "1" then
        npc.caozuo2 = 0
    end

    return npc
end

function QiXiUtil:createNewRole(npc_data)
    local info = clone(infoDesc)

    local res_info
    if npc_data.sex == "男" then
        res_info = qixi_res.Minfo
    elseif npc_data.sex == "女" then
        res_info = qixi_res.Finfo
    end

    --@region 表面信息处理
    local surface_text = {}
    for i = 1, 4 do
        local info_key = "info" .. i
        local info_id = npc_data[info_key]

        local desc_array = self:getRoleInfoDescArray(npc_data.sex, info_key, info_id)

        local random_key = math.random(1, #desc_array)

        local text = desc_array[random_key]

        self:saveNpcDescInfo(npc_data.id, "s_info", info_key, info_id .. ";" .. random_key)

        surface_text[info_key] = text
    end
    --@endregion

    --@region 真实信息的处理
    local hide_num = npc_data.hidenum
    local need_count = 5 - hide_num

    local true_text = {}

    local hide_key_list = {}

    local show_key_list = {}

    for i = 1, 5 do
        local true_key = "true" .. i

        local true_id = npc_data[true_key]

        local desc_array = self:getRoleInfoDescArray(npc_data.sex, true_key, true_id)

        local random_key = math.random(1, #desc_array)

        local text = desc_array[random_key]

        self:saveNpcDescInfo(npc_data.id, "t_info", true_key, true_id .. ";" .. random_key)

        true_text[true_key] = text
    end

    local randomArr = {}
    for i = 1, 5 do
        table.insert(randomArr, "true" .. i)
    end

    local result_id = {}
    for i = 1, need_count do
        local index = math.random(1, #randomArr)
        local true_key = randomArr[index]
        -- table.insert(show_key_list, string.split(true_key, "true")[2])
        table.remove(randomArr, index)
    end
    -- self:saveNpcShowOrHideTrueKey(npc_data.id,"show_key",show_key_list)

    if MapIsEmpty(randomArr) == false then
        for i = 1, #randomArr do
            local true_key = randomArr[i]
            table.insert(hide_key_list, string.split(true_key, "true")[2])
        end
        self:saveNpcShowOrHideTrueKey(npc_data.id, "hide_key", hide_key_list)
    end

    local final_true_text = {}

    for true_key, text in pairs(true_text) do
        local isHide = false

        if not MapIsEmpty(hide_key_list) then
            for _, hide_index in ipairs(hide_key_list) do
                if true_key == "true" .. hide_index then
                    isHide = true
                    break
                end
            end
        end

        if isHide == false then
            final_true_text[true_key] = text
        end
    end

    --@endregion

    --@region 描述拼接
    for info_key, text in pairs(surface_text) do
        local index = surfaceInfo[info_key]
        info[index] = text
    end

    for true_key, text in pairs(final_true_text) do
        local index = trueInfo[true_key]
        info[index] = text
    end

    --@endregion

    local role = require("app.models.npc.BaseNpc"):create()
    Helper:tableCover(role, npc_data)
    role.id = npc_data.id
    role.name = npc_data.name
    role.sex = "野兽"
    role.realSex = npc_data.sex
    role.dsc = ""
    for _, text in ipairs(info) do
        role.dsc = role.dsc .. text
    end
    role.infoDesc = info
    role.hide_key_list = hide_key_list
    role.surface_text = surface_text
    role.true_text = true_text

    local cr = self:getCR()
    Helper:tableCover(role, cr)

    if role.hidenum == 0 then
        role.caozuo3 = 0
    end

    if tostring(role.special) == "1" then
        role.caozuo2 = 0
    end
    return role
end

function QiXiUtil:createRole(npc_data)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local day_num = npc_data.day

    local today_hand_list = role:getDayFlag("handD" .. day_num)

    if today_hand_list ~= 0 then
        for i, npcId in ipairs(today_hand_list) do
            if npc_data.id == npcId then
                return
            end
        end
    end

    local npc_save_info_list = role:getDayFlag("qxnpcinfo")

    local npc
    if npc_save_info_list == 0 then
        npc = self:createNewRole(npc_data)
    else
        if npc_save_info_list[npc_data.id] then
            npc = self:createRoleFormFile(npc_data)
        else
            npc = self:createNewRole(npc_data)
        end
    end

    npc.__qxMark = 1
    return npc
end

function QiXiUtil:recordFinshTime(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local roleRecord = Helper:getDef(role:getAttr("qx2018"), {})

    local temp = {t = map.__createRoleTime}

    local lastTimeTb = roleRecord[#roleRecord]

    if lastTimeTb == nil then
        table.insert(roleRecord, temp)
    else
        local lastTime = lastTimeTb.t

        if Helper:diffWithDate(temp.t, lastTime) >= 1 then
            table.insert(roleRecord, temp)
        end
    end

    if #roleRecord >= 7 then
        role:setInheritFlag("qixi2018f", 1)
    end

    role:setAttr("qx2018", roleRecord)
end

function QiXiUtil:recordInHand(leftNpc, rightNpc)
    local day_num = 0

    local list = {}
    table.insert(list, leftNpc.id)
    table.insert(list, rightNpc.id)
    local npcInfo = self:getNpcInfo(leftNpc.id)
    local day_num = npcInfo.day

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local today_hand_list = Helper:getDef(role:getDayFlag("handD" .. day_num), {})

    for i, v in ipairs(list) do
        table.insert(today_hand_list, v)
    end

    role:setDayFlag("handD" .. day_num, today_hand_list)
end

function QiXiUtil:getCR()
    local cr = {}
    cr.canSee = true
    cr.type = "role"
    cr.caozuo1 = 1
    cr.caozuoName1 = "交谈"
    cr.caozuo2 = 1
    cr.caozuoName2 = "喜好"
    cr.caozuo3 = 1
    cr.caozuoName3 = "使用道具"
    cr.caozuo4 = 1
    cr.caozuoName4 = "牵线"
    cr.conditionAndResults = {
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
                    arg1 = "七夕剧情交谈"
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
                    arg1 = "七夕喜好"
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
                    arg1 = "七夕使用道具"
                }
            }
        },
        {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家操作",
                    arg2 = "操作4"
                }
            },
            results = {
                {
                    arg1 = "牵线"
                }
            }
        }
    }

    return cr
end

--@desc:获取交谈文本
--@author:Liang SongQiang
--@time:2018-08-12 16:17:04
function QiXiUtil:getTalkDesc(npc)
    local true_info_arr = self:getTrueInfo(npc.id)

    local random_list = {}
    for k, _ in pairs(true_info_arr) do
        table.insert(random_list, k)
    end

    local true_key = random_list[math.random(1, #random_list)]
    local minfo_index = npc[true_key]

    local talk_key_index = string.split(true_key, "true")[2]

    local minfo
    local text = ""
    if npc.realSex == "男" then
        minfo = qixi_res.Minfo
    else
        minfo = qixi_res.Finfo
    end

    local talk_res = minfo[tostring(minfo_index)]
    local textStr = talk_res["talk" .. talk_key_index] or ""

    local text_array = string.split(textStr, ";")

    text = text_array[math.random(1, #text_array)]

    return text
end

function QiXiUtil:getLikeInfoDescList(npc)
    local npc_like_list = {}

    local res_like_desc = {}

    if npc.realSex == "男" then
        res_like_desc = qixi_res.Mlike
    else
        res_like_desc = qixi_res.Flike
    end

    local desc_list = {}
    for i = 1, 7 do
        local like_key = "like" .. i

        local like_id = tonumber(npc[like_key]) or 0

        if like_id > 0 then
            local like_info = res_like_desc[tostring(like_id)]

            local text = like_info[like_key]

            table.insert(desc_list, text)
        end
    end

    return desc_list
end

--@desc:获取所有真实信息
--@author:Liang SongQiang
--@time:2018-08-12 18:42:46
function QiXiUtil:getAllTrueInfo(npc)
    local info_dsc_list = npc.infoDesc
    local true_text = npc.true_text
    local surface_text = npc.surface_text
    local hide_key_list = npc.hide_key_list

    local info_desc = clone(infoDesc)

    local final_true_text = {}

    for true_key, text in pairs(true_text) do
        final_true_text[true_key] = text
    end

    for info_key, text in pairs(surface_text) do
        local index = surfaceInfo[info_key]
        info_desc[index] = text
    end

    for true_key, text in pairs(final_true_text) do
        local index = trueInfo[true_key]
        info_desc[index] = text
    end

    local desc = ""

    for i, text in ipairs(info_desc) do
        desc = desc .. text
    end

    return desc
end

--@desc 计算最终的分数
function QiXiUtil:calResultStr(leftNpc, rightNpc)
    local leftInfo = self:getNpcInfo(leftNpc.id)

    local rightInfo = self:getNpcInfo(rightNpc.id)

    local dayNum = leftNpc.day

    if leftNpc.special == 1 and rightNpc.special == 1 then
        local level = 6

        local finNum = leftNpc.finnum and leftNpc.finnum or rightNpc.finnum

        if finNum == nil then
            assert(false, "获取特殊结局出错，检查资源，npcID：" .. leftNpc.id .. "，" .. rightNpc.id)
        end

        local res_text = qixi_res.final

        local text_array = res_text[tostring(level)]

        local text_key = "fin" .. finNum

        local uploadStr = dayNum .. ";" .. leftNpc.id .. ";" .. rightNpc.id .. ";" .. level .. ";" .. text_key

        return uploadStr
    end

    local rightToleft = self:calRightToLeft(leftInfo, rightInfo)

    local leftToRight = self:calRightToLeft(rightInfo, leftInfo)

    -- Helper:print_lua_table(rightToleft)
    -- print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
    -- Helper:print_lua_table(leftToRight)

    local finnalPoint = 0

    for k, point in pairs(rightToleft) do
        finnalPoint = finnalPoint + point
    end

    for k, point in pairs(leftToRight) do
        finnalPoint = finnalPoint + point
    end

    local level = self:getResultLevel(finnalPoint)

    local text_key = self:getTextRandomIndex(level)

    print(level, text_key)

    local uploadStr = dayNum .. ";" .. leftNpc.id .. ";" .. rightNpc.id .. ";" .. level .. ";" .. text_key

    return uploadStr
end

function QiXiUtil:getTextRandomIndex(level)
    local res_text = qixi_res.final

    local text_array = res_text[tostring(level)]

    local random_key_list = {}
    for k, v in pairs(text_array) do
        if k ~= "id" then
            table.insert(random_key_list, k)
        end
    end

    local index = math.random(1, #random_key_list)

    local key = random_key_list[index]

    return key
end

function QiXiUtil:getResultLevel(point)
    if point > 2.5 then
        return 1
    elseif point <= 2.5 and point > 2 then
        return 2
    elseif point <= 2 and point > 1 then
        return 3
    elseif point <= 1 and point > 0.5 then
        return 4
    elseif point <= 0.5 then
        return 5
    end
end

--@desc: 计算右边人物是否满足
--@author:Liang SongQiang
--@time:2018-08-13 15:54:40
function QiXiUtil:calRightToLeft(leftInfo, rightInfo)
    local result = {}

    local tb = {
        like1 = "true1",
        like2 = "true2",
        like3 = "info2",
        like4 = "true3",
        like5 = "true4",
        like6 = "true5",
        like7 = "info3"
    }

    --[[
        like1喜好年龄对应true1真实年龄
        like2喜好性格对应true2性格
        like3喜好样貌对应info2样貌
        like4喜好家世对应true3家世
        like5喜好武功对应true4武功
        like6喜好健康对应true5健康
        like7衣着气质对应info3衣着气质
    ]]
    for i = 1, 7 do
        local value = tonumber(leftInfo["like" .. i]) or 0

        local right_key = tb["like" .. i]

        local right_value = tonumber(rightInfo[right_key]) or 0

        if value ~= 0 then
            local logic = leftInfo["likelogic" .. i]
            switch(
                logic,
                {
                    ["小于等于"] = function()
                        if value >= right_value and right_value ~= 0 then
                            result["like" .. i] = 0.5
                        else
                            result["like" .. i] = -0.25
                        end
                        if DEBUG_MODE == 1 then
                            print("小于等于",leftInfo.name ,rightInfo.name,value,right_value,right_key,"like"..i,result["like" .. i])
                        end
                    end,
                    ["等于"] = function()
                        if value == right_value and right_value ~= 0 then
                            result["like" .. i] = 0.5
                        else
                            result["like" .. i] = -0.25
                        end
                        if DEBUG_MODE == 1 then
                            print("等于",leftInfo.name ,rightInfo.name,value,right_value,right_key,"like"..i,result["like" .. i])
                        end
                    end,
                    default = function()
                        result["like" .. i] = 0
                    end
                }
            )
        else
            result["like" .. i] = 0
        end
    end

    return result
end

--@desc 根据上传的字段获取等级
function QiXiUtil:getUploadLevel(str)
    local str_array = string.split(str, ";")

    local level = tonumber(str_array[4])

    return level
end

-- local list = {
--     {
--         {
--             day = 1,
--             info = "1;fb206r01_1;fb206r02_1;3;1",
--             ratio = 5
--         },
--         {
--             day = 1,
--             info = "1;fb206r03_1;fb206r04_1;3;3",
--             ratio = 5
--         }
--     },
--     {
--         {
--             day = 2,
--             info = "1;fb206r12_1;fb206r16_1;2;5",
--             ratio = 5
--         },
--         {
--             day = 2,
--             info = "1;fb206r18_1;fb206r19_1;1;3",
--             ratio = 5
--         }
--     }
-- }
function QiXiUtil:createResultDataList(data)
    if data == nil or MapIsEmpty(data) then
        return
    end

    local result = {}

    for day, day_info in ipairs(data) do
        local day_result_info = {}
        for _, result_info in ipairs(day_info) do
            local result_array = string.split(result_info.info, ";")
            local temp = {}
            temp.day = result_info.day
            temp.ratio = result_info.ratio
            temp.npcName1 = self:getNpcInfo(result_array[2]).name
            temp.npcName2 = self:getNpcInfo(result_array[3]).name
            temp.level = result_array[4]
            temp.textIndex = result_array[5]
            table.insert(day_result_info, temp)
        end

        table.insert(result, day_result_info)
    end

    return result
end

--@desc 获取结果文本
function QiXiUtil:getResultDesc(level, key)
    local desc = ""

    local desc_array = qixi_res.final[tostring(level)]

    desc = desc_array[key]

    return desc
end

--@desc: 清除所有数据
--@author:Liang SongQiang
--@time:2018-08-14 01:02:16
function QiXiUtil:clearAllData()
    HttpManagerEx:allQiXiDelete(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    --@RefType [src.app.models.role.Role#Role]
                    local role = User:getRole()

                    --@desc 今日生成的人物数据
                    role:setDayFlag("qxnpcinfo", nil)

                    --@desc 完成进度时间
                    role:setAttr("qx2018", nil)

                    --@desc 当日已配对的人物
                    for i = 1, 7 do
                        role:setDayFlag("handD" .. i, nil)
                    end

                    --@desc 是否完成七天
                    role:setInheritFlag("qixi2018f", nil)

                    --@desc 完成的配对数量
                    role:setInheritFlag("qixi2018p", nil)

                    --@desc 策划定义标记
                    role:setInheritFlag("qxjl", nil)

                    --@desc 策划定义标记
                    role:setDayFlag("qxdj", nil)

                    PopText("清除七夕相关所有数据")
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

--@map: [src.app.models.map.BaseMap#BaseMap]
function QiXiUtil:removeNpc(npc, map)
    local roomId = ""

    local clearList
    if npc.realSex == "男" then
        roomId = "fb210_03"
        clearList = map._malelist
    elseif npc.realSex == "女" then
        roomId = "fb210_04"
        clearList = map._fmalelist
    end

    for k, v in pairs(clearList) do
        if v == npc.id then
            table.remove(clearList, k)
            break
        end
    end

    map:removeRoomRole(roomId, npc.id)
    map.roles[npc.id] = nil
end

function QiXiUtil:getMatchRewardList(leftNpcId, rightNpcId)
    local left_npc_info = self:getNpcInfo(leftNpcId)

    local right_npc_info = self:getNpcInfo(rightNpcId)

    local result = {}
    if left_npc_info.special == 0  or right_npc_info.special == 0 then
        return result
    end


    if left_npc_info.item then
        result[left_npc_info.item] = 1
    end

    if right_npc_info.item then
        if result[right_npc_info.item] ~= nil then
            result[right_npc_info.item] = result[right_npc_info.item] + 1
        else
            result[right_npc_info.item] = 1
        end
    end

    return result
end

return QiXiUtil
0000