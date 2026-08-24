--[[
    author:Seven
    time:2025-04-02 14:10:50
    desc:
]]
local RoleStatusTagsTest = {}

local spit_str = function(str)
    return string.match(str, "([^;]+);(%d+)")
end

--@desc:
--@author:Seven
--@time:2025-04-02 14:12:52
--@layer: [src.app.views.layer.DebugLayer.TestLayer#TestFuncLayer]
function RoleStatusTagsTest:showTest(layer)
    layer:addButton(
        "针对状态标识1，生成旧版本标识",
        function()
            local role = User:getRole()

            if role.status_tags == nil then
                role.status_tags = {}
            end

            if role.status_tags.nsTags == nil then
                role.status_tags.nsTags = {}
            end

            role.status_tags.tlInhsTags["1"] = {
                value = 1,
                _rtime = "2025-08-07 14:59:59"
            }

            print("======================== 修改后玩家状态标识 ========================")
            Helper:print_lua_table(role.status_tags)
            print("===================== 玩家状态标识 end =======================")
        end
    )

    layer:addEditor(
        "修改玩家状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local tagId, tagValue = spit_str(text)

            local role = User:getRole()

            role:setRoleStatusTags(tagId, tonumber(tagValue))

            PopText("修改成功 : " .. tagId .. " : " .. tagValue)
        end
    )

    layer:addEditor(
        "修改玩家传承状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local tagId, tagValue = spit_str(text)

            local role = User:getRole()

            role:setInheritRoleStatusTags(tagId, tonumber(tagValue))

            PopText("修改成功 : " .. tagId .. " : " .. tagValue)
        end
    )

    layer:addEditor(
        "修改玩家时间状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local tagId, tagValue = spit_str(text)

            local role = User:getRole()

            role:setTimeStatusTags(tagId, tonumber(tagValue))

            PopText("修改成功 : " .. tagId .. " : " .. tagValue)
        end
    )

    layer:addEditor(
        "修改玩家时间传承状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local tagId, tagValue = spit_str(text)

            local role = User:getRole()

            role:setInheritTimeStatusTags(tagId, tonumber(tagValue))

            PopText("修改成功 : " .. tagId .. " : " .. tagValue)
        end
    )

    layer:addEditor(
        "删除玩家状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local tagId, tagValue = spit_str(text)

            local role = User:getRole()

            role:deleteRoleStatusTags(tagId, tonumber(tagValue))
        end
    )

    layer:addEditor(
        "修改NPC状态标识（仅验证资源是否配置成功使用）",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local tagId, tagValue = spit_str(text)

            --@RefType [src.app.models.role.Role#Role]
            local npc = Role:create()

            npc:setNpcStatusTags(tagId, tonumber(tagValue))

            PopText("测试修改成功 : " .. tagId .. " : " .. tagValue)
        end
    )

    layer:addEditor(
        "地图状态标识（仅验证资源是否配置成功使用）",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local tagId, tagValue = spit_str(text)

            local BaseMap = require("app.models.map.BaseMap")

            --@RefType [BaseMap]
            local map = BaseMap:create()

            map:setMapStatusTags(tagId, tonumber(tagValue))

            PopText("测试修改成功 : " .. tagId .. " : " .. tagValue)
        end
    )

    layer:addEditor(
        "时间标识验证（类型5和6）",
        "标识id;开始值;指定开始时间;指定结束时间",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local TimeLimitStatusTagHelper = require("app.models.RoleStatusTags.TimeLimitStatusTagHelper")

            local infos = string.split(text, ";")
            local tagId = infos[1]
            local startValue = tonumber(infos[2])
            local startTime = infos[3]
            local endTime = infos[4]

            local stimestamp = TimeLimitStatusTagHelper.format_timestr_to_timestamp(startTime)
            local etimestamp = TimeLimitStatusTagHelper.format_timestr_to_timestamp(endTime)

            if etimestamp < stimestamp then
                PopText("指定结束时间不可小于指定开始时间")
                return
            end

            local newTagObject = TimeLimitStatusTagHelper:newTimeLimitObject(tagId, stimestamp)
            newTagObject.value = startValue

            if TimeLimitStatusTagHelper:isExpired(tagId, newTagObject, etimestamp) then
                PopText("时间标识过期")
            else
                PopText("时间标识未过期 ：" .. tagId .. " : " .. startValue)
            end
        end
    )

    layer:addButton(
        "传承数据测试",
        function()
            local role = Role:create()

            local inhTagId = 65532

            local timeInhTagId = 65529

            role:setInheritRoleStatusTags(inhTagId, 1)
            role:setInheritTimeStatusTags(timeInhTagId, 1)

            local allInheritStatusTags = role:getAllInheritStatusTags(inhTagId)

            Helper:print_lua_table(allInheritStatusTags)

            if allInheritStatusTags.inhsTags[tostring(inhTagId)] == 1 and allInheritStatusTags.tlInhsTags[tostring(timeInhTagId)].value == 1 then
                PopText("传承数据测试成功")
            end
        end
    )

    layer:addButton(
        "打印玩家状态标识",
        function()
            local role = User:getRole()
            print("======================== 玩家状态标识 ========================")
            Helper:print_lua_table(role.status_tags)
            print("===================== 玩家状态标识 end =======================")
        end
    )
end

return RoleStatusTagsTest
0000000000