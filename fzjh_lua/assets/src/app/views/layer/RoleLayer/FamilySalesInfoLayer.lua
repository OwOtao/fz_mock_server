--@SuperType [src.app.views.layer.RoleLayer.NpcFuncInfoLayer#NpcFuncInfoLayer]
local FamilySalesInfoLayer = class("FamilySalesInfoLayer", require("app.views.layer.RoleLayer.NpcFuncInfoLayer"))  
local TeacherTask = require("app.models.task.teacherTask.teacherTask")
function FamilySalesInfoLayer:create()
    local p = FamilySalesInfoLayer:new()
    p:init()
    return p
end

-- add by XiaoZhiWei 2017/03/30 17:11:30 需要添加交易按钮的NPC列表
local addList = {
    ["liuxiran"] = true,
    ["huayan"] = true,
    ["xuqianmo"] = true,
    ["hemingqing"] = true,
    ["gaochang"] = true,
    ["qinji"] = true,
    ["xiaoyan"] = true,
    ["zhongque"] = true,
    ["yuzhen"] = true,
    ["mingchangge"] = true,
    ["xumi"] = true,
    ["luoqiansang"] = true,
    ["duantianming"] = true,
    ["moli"] = true,
    ["sufu"] = true,
    ["duyan"] = true,
    ["murongjie"] = true,
    ["quandayou"] = true,
    ["tangshiba"] = true,
    ["yanfeng"] = true,
    ["shilong"] = true,
    ["qinming"] = true,
    ["miaoyan"] = true,
    ["jiangyi"] = true,
    ["liboyong"] = true,
    ["heishishangren"] = true
}

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/03/30 17:13:18
-- -- @desc 继承自父类, 增加按钮
-- function FamilySalesInfoLayer:addFuncButton(role)
--     print("FamilySalesInfoLayer:addFuncButton(role) == ", role.id)
--     if MapIsEmpty(role) == false and addList[role.id] == true then
--         -- add by XiaoZhiWei 2017/03/31 11:24:54 年龄描述和长相描述 策划已填写,不需要自动生成
--         self:setRoleDsc(role:getDsc(User:getRole(), false, false), role)

--         local functionButton = self:createFunctionButton()
--         self.ListView_bottom:pushBackCustomItem(functionButton)
--         functionButton.Text_buttonName:setString("交易")
--         functionButton:releaseFunc(function()
--             Audio:playEffect("xiaoAnNiu")
--             local TYPE_TEACHER = 1
--             HttpManagerEx:getDevoteList(TYPE_TEACHER, role:getFamilyId(), function(status, errcode, errmsg, data)
--                 if status == 200 then
--                     if errcode == 0 then
--                         if MapIsEmpty(data) == false then
--                             local SalesLayer = require("app.views.layer.SalesLayer.SalesLayer")
--                             local layer = SalesLayer:getInstance()
--                             layer:show()
--                             role.zhaoShuXiang = data.list
--                             layer:setRoles(User:getRole(), role, function()
--                                 self.teacherLayer:refreshGongXian()
--                             end)
--                             layer:setSellerType(TYPE_TEACHER)
--                             layer:setTextDesc(data.yuanbao)
--                             layer:setSallerMenPai(role:getFamilyId())
--                         end
--                     end
--                     return true
--                 end
--             end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
--         end)

--         functionButton = self:createFunctionButton()
--         self.ListView_bottom:pushBackCustomItem(functionButton)
--         functionButton.Text_buttonName:setString("送礼") -- gongxiandian100
--         functionButton:releaseFunc(function()
--             Audio:playEffect("xiaoAnNiu")

--             if User:getRole():getItemCount("gongxiandian100") <= 0 then
--                 RichPrint("main", "CYN我不接受你的物品")
--                 return
--             end

--             HttpManagerEx:addDevotePoint(4, 1000, function(status, errcode, errmsg, data)
--                 if status == 200 then
--                     if errcode == 0 then
--                         User:getRole():addItemCount("gongxiandian100", -1)
--                         local randText =
--                         {
--                             [1] = "YEL" .. tostring(role.name) .. "：此物甚合我心意，你有心了。",
--                             [2] = "YEL" .. tostring(role.name) .. "：你做的不错，这东西我十分喜欢，门派贡献那我会给你记上一笔的",
--                             [3] = "YEL" .. tostring(role.name) .. "：做的不错，这门派贡献我就给你记上了，日后还有此等物事还可送来。",
--                         }
--                         RichPrint("main", randText[math.random(1,3)])
--                         RichPrint("main", data.msg)
--                         PopText(data.msg)
--                         try(function() self.teacherLayer:refreshGongXian() end)
--                     else
--                         PopText(errmsg)
--                     end
--                 end
--             end, IS_SHOW_WAITING)
--         end)
--     end
-- end
-- local teacherList = {

-- }
-- function FamilySalesInfoLayer:addTeacherTaskFuncButton(role)
--     if TEACHER_TASK_IS_OPEN == true then
--     else
--         return
--     end
--     if TeacherTask:getFamilyDsc().awardnpc == role.id  then
--         self:setRoleDsc(role:getDsc(User:getRole(), false, false), role)
--         local functionButton = self:createFunctionButton()
--         self.ListView_bottom:pushBackCustomItem(functionButton)
--         functionButton.Text_buttonName:setString("交易")
--         functionButton:releaseFunc(function()
--             Audio:playEffect("xiaoAnNiu")
--             HttpManagerEx:getTeacherTaskShop("normal", User:getRole():getFamilyId(), function(status, errcode, errmsg, data)
--                 if status == 200 then
--                     if errcode == 0 then
--                         if MapIsEmpty(data) == false then
--                             local SalesLayer = require("app.views.layer.TeacherTaskLayer.TeacherTaskSales.TeacherTaskSalesLayer")
--                             local layer = SalesLayer:getInstance()
--                             layer:show()
--                             -- SalesLayer:setSellerItems(data.goods_list)
--                             role:setAttr("items",data.goods_list)
--                             -- role.items =
--                             layer:setRoles(User:getRole(), role, function()
--                                 -- self.teacherLayer:refreshGongXian()
--                             end)
--                             layer:setSellerType(TYPE_TEACHER)
--                             layer:setTextDesc(data.need_yuanbao)
--                             layer:setSallerMenPai(User:getRole():getFamilyId())
--                         end
--                     end
--                     return true
--                 end
--             end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
--         end)

--         local functionButton = self:createFunctionButton()
--         self.ListView_bottom:pushBackCustomItem(functionButton)
--         functionButton.Text_buttonName:setString("师门清规")
--         functionButton:releaseFunc(function()
--             Audio:playEffect("xiaoAnNiu")
--             local ControllLayer = require("app.views.layer.ControllLayer"):getInstance()
--             ControllLayer:pushLayer("ShiMenQingGuiLayer")
--             local ShiMenQingGuiLayer = ControllLayer:getLayer("ShiMenQingGuiLayer")
--             ShiMenQingGuiLayer:initLayer("师门清规")
--         end)
--     elseif TeacherTask:getFamilyDsc().tasknpc == role.id then
--         self:setRoleDsc(role:getDsc(User:getRole(), false, false), role)
--         local functionButton = self:createFunctionButton()
--         self.ListView_bottom:pushBackCustomItem(functionButton)
--         functionButton.Text_buttonName:setString("任务说明")
--         functionButton:releaseFunc(function()
--             Audio:playEffect("xiaoAnNiu")
--             local ControllLayer = require("app.views.layer.ControllLayer"):getInstance()
--             ControllLayer:pushLayer("ShiMenQingGuiLayer")
--             local ShiMenQingGuiLayer = ControllLayer:getLayer("ShiMenQingGuiLayer")
--             ShiMenQingGuiLayer:initLayer("任务说明")
--         end)
--     end
-- end

function FamilySalesInfoLayer:setTitle(role)
    local title = ""
    if role.chenghao then
        title = role.chenghao
    end
    local nickname = ""
    if role.nickname then
        nickname = role.nickname
    end
    title = tostring(title) .. tostring(nickname) .. " " .. tostring(role.name)

    self.Text_title:setString(title)
end

function FamilySalesInfoLayer:showBtnList(role)
    local functions = role:getAttr("functions")

    local functionList = {}

    if MapIsEmpty(functions) == false then
        local RoleFunctionButton = require("app.views.layer.RoleLayer.RoleFunctionButton")
        for i, v in ipairs(functions) do
            local functionBtn =
                RoleFunctionButton:createFunction(
                v.name,
                function()
                    self:hideLayer()
                    return v.func(role)
                end
            )
            table.insert(functionList, functionBtn)
        end
    end

    self:addMyTeacherFunc(role, functionList)

    self:addSalesFunc(role,functionList)

    self:createFuncBtnList(functionList)
end

function FamilySalesInfoLayer:addMyTeacherFunc(role, functionList)
    --@desc 请安按钮
    if role:getAttr("id") ~= User:getRole():getAttr("teacherId") then
        return
    end

    local RoleFunctionButton = require("app.views.layer.RoleLayer.RoleFunctionButton")

    local qingAnBtn =
        RoleFunctionButton:createFunction(
        "请安",
        function()
            self:hideLayer()
            if role:getTimeLimitFlag("请安点击时间") == 0 then
                HttpManagerEx:addDevotePoint(
                    1,
                    0,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                RichPrint("main", "你恭恭敬敬地向[" .. tostring(role.name) .. "]磕头请安，叫道：师傅在上，徒儿给您请安了！")
                                RichPrint("main", "[" .. tostring(role.name) .. "]对你微微点头并示意你起身。")
                                RichPrint("main", data.msg)
                            else
                                PopText("你今天已经请过安了！")
                            end
                            local teacherLayer = MainControllLayer:getLayer("TeacherLayer")
                            teacherLayer:refreshGongXian()
                        end
                    end,
                    IS_SHOW_WAITING
                )
                role:setTimeLimitFlag("请安点击时间", 1, 3)
            else
                PopText("请不要频繁点击！")
            end
        end
    )
    table.insert(functionList, qingAnBtn)

    local groupRankingBtn =
        RoleFunctionButton:createFunction(
        "进境排行",
        function()
            --@RefType [src.app.models.family.FamilyGroup#FamilyGroup]
            local FamilyGroup = require("app.models.family.FamilyGroup")

            FamilyGroup:getGroupMembers(
                function(group_data)
                    self:hideLayer()
                    if MapIsEmpty(group_data) then
                        return
                    end

                    FamilyGroup:getGroupRank(
                        function(rank)
                            -- Helper:print_lua_table(rank)

                            local rank_ui_data = {}

                            for rank_index, rank_data in ipairs(rank) do
                                local user_id = rank_data.userid
                                local rank_value = {
                                    name = nil,
                                    mpsw = nil,
                                    kongfu = nil
                                }
                                if tostring(user_id) == tostring(User:getUserId()) then
                                    local player = User:getRole()
                                    rank_value.name = player:getAttr("name")
                                else
                                    for i, role_data in ipairs(group_data) do
                                        if tostring(user_id) == tostring(role_data.userid) then
                                            rank_value.name = role_data.name
                                            break
                                        end
                                    end
                                end

                                if MapIsEmpty(rank_value) == false then
                                    Helper:tableCover(rank_value, rank_data)
                                    table.insert(rank_ui_data, rank_value)
                                end
                            end

                            Helper:print_lua_table(rank_ui_data)
                        end
                    )
                end
            )
        end
    )
    table.insert(functionList, groupRankingBtn)
end

function FamilySalesInfoLayer:addSalesFunc(role, functionList)
    --@desc 请安按钮
    if addList[role:getAttr("id")] == true then
        local RoleFunctionButton = require("app.views.layer.RoleLayer.RoleFunctionButton")

        local salesBtn =
            RoleFunctionButton:createFunction(
            "交易",
            function()
                self:hideLayer()
                local TYPE_TEACHER = 1
                HttpManagerEx:getDevoteList(
                    TYPE_TEACHER,
                    role:getFamilyId(),
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                if MapIsEmpty(data) == false then
                                    local SalesLayer = require("app.views.layer.SalesLayer.SalesLayer")
                                    local layer = SalesLayer:getInstance()
                                    layer:show()
                                    role.zhaoShuXiang = data.list
                                    layer:setRoles(
                                        User:getRole(),
                                        role,
                                        function()
                                            local currLayerName = MainControllLayer:getCurrLayer()
                                            if currLayerName == "TeacherLayer" then
                                                local teacherLayer = MainControllLayer:getLayer(currLayerName)
                                                teacherLayer:refreshGongXian()
                                            end
                                        end
                                    )
                                    layer:setSellerType(TYPE_TEACHER)
                                    layer:setTextDesc(data.yuanbao)
                                    layer:setSallerMenPai(role:getFamilyId())
                                end
                            end
                            return true
                        end
                    end,
                    IS_SHOW_WAITING,
                    HTTP_MANAGER_RETRY_TYPE_RETRY
                )
            end
        )
        table.insert(functionList, salesBtn)
    end
end

function FamilySalesInfoLayer:hideLayer()
    PopupLayerController:hideLayer(
        "FamilySalesInfoLayer",
        function(layer)
            layer:hide()
        end
    )
end

Helper:classDefNodeGetInstance(FamilySalesInfoLayer)
return FamilySalesInfoLayer
00000000000000