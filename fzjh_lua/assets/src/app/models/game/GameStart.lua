--[[
    author:Seven
    time:2024-10-11 17:35:26
    desc:
]]
local ControllLayer = require("app.views.layer.ControllLayer")

local GameStart = {}

local __start_game = function()
    ControllLayer:getInstance():startGame()
end

local __show_create_role = function()
    local CreateRoleLayer = require("app.views.layer.CreateRoleLayer")
    local createRoleLayer = CreateRoleLayer:getInstance()
    createRoleLayer:show()
end

local __download_and_start_game = function()
    -- 尝试下载档案
    Account:downloadUserData(
        function(eventName, roleData)
            if eventName == "有存档" then
                -- 开始游戏
                DataBase:setRoleData(roleData)
                User:init()
                __start_game()
            elseif eventName == "无存档" then
                -- 创建角色界面
                __show_create_role()
            end
        end
    )
end

local __upload_and_start_game = function()
    Account:startGameUpload(
        function(eventName, errcode, errmsg)
            if eventName == "上传成功" then
                return __start_game()
            else
                PopText("上传存档失败, 请检查网络后重试 ! ! " .. "(" .. tostring(errcode) .. ")")
            end
        end
    )
end

local __normal_start_game = function()
    -- 显示菜单界面
    local roleData, data = DataBase:getRoleData()
    if roleData == nil then
        if data ~= nil then
            -- 一般是存档无法解密或者存档损坏，直接把存档内容上传,并重新从服务器下载
            HttpManagerEx:uploadUselessUserData(
                data,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            Account:deleteLocalData()

                            __download_and_start_game()
                        else
                            PopText("上传存档失败, 请检查网络后重试 ! ! " .. "(" .. tostring(errcode) .. ")")
                            return false
                        end
                        return true
                    else
                        return false
                    end
                end,
                IS_SHOW_WAITING,
                HTTP_MANAGER_RETRY_TYPE_RETRY
            )
        else 
            return __download_and_start_game()
        end
    else
        return __upload_and_start_game()
    end
end

local __upload_and_delete_user_data = function()
    -- 上传并且删除档案
    Account:uploadAndDeleteUserData(
        function()
            __download_and_start_game()
        end
    )
end

local __force_download_user_data
__force_download_user_data = function()
    -- 上传并且删除档案
    local roleData, ori_data = DataBase:getRoleData()
    if roleData == nil then
        roleData = ori_data -- 直接将文件内保存的内容,复制给RoleData并且上传
    end
    HttpManagerEx:uploadUselessUserData(
        roleData,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    Account:deleteLocalData()
                    __download_and_start_game()
                else
                    local buttonPopLayer =
                        ButtonPopLayer:createCustomInRunningScene(
                        "存档上传失败，请重试",
                        "重试",
                        function()
                            __force_download_user_data()
                        end
                    )
                    local userid = DataBase:getDataWithString("userid")
                    local err_text = "upload_user_file_4" .. ";" .. tostring(errcode) .. ";" .. tostring(userid)
                    buttonPopLayer:setErrorText(err_text)
                end
                return true
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

local __show_notice = function(data, errmsg)
    if data and data.title and data.body then
        local GongGaoLayer = require("app.views.layer.DialogLayer.GongGaoLayer")
        local dialog = GongGaoLayer:getInstance()
        dialog:show()
        dialog:setText(data.body)
        dialog:setTitle(data.title)
        dialog.Button_1:hide()
    else
        PopText("网络异常（201：" .. tostring(errmsg) .. ")")
    end
end

local __start 
__start = function ()
    Account:createAccount(
        function(eventName, errmsg, data)
            switch(
                eventName,
                {
                    ["开始游戏"] = function()
                        return __normal_start_game()
                    end,
                    ["上传并删除档案"] = function()
                        return __upload_and_delete_user_data()
                    end,
                    ["覆盖档案"] = function()
                        return __force_download_user_data()
                    end,
                    ["公告展示"] = function()
                        return __show_notice(data, errmsg)
                    end,
                    ["default"] = function()
                        PopText(tostring(errmsg) .. ", [ eventName = " .. tostring(eventName) .. " ]")

                        print("GameStart:start_game() eventName: ", eventName)
                    end
                }
            )
        end
    )
end

function GameStart:start_game()
    return __start()
end

return GameStart
000000