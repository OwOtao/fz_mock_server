local DialogDLayer = require("app.views.layer.DialogLayer.DialogDLayer")
local ControllLayer = require("app.views.layer.ControllLayer")
local BaseLayer = require("app.views.base.BaseLayer")
local CreateRoleLayer = class("CreateRoleLayer", BaseLayer)

function CreateRoleLayer:create()
    local p = CreateRoleLayer:new()
    return p
end

function CreateRoleLayer:ctor()
end

function CreateRoleLayer:show()
    local dialog = DialogDLayer:getInstance()
    dialog:show()
    local list = {
        func1 = function(sexFunc)
            local str = math.random(0, 10) + 20
            local dex = math.random(0, 10) + 20
            local int, con
            local num = 80 - str - dex - 20
            if num > 10 then
                int = math.random(num - 10, 10) + 10
            else
                int = math.random(0, num) + 10
            end
            con = 80 - str - dex - int

            local looks = math.random(16, 21)
            local luck = 40 - looks

            local skills = {
                jibenquanjiao = {id = "jibenquanjiao", exp = 121},
                jibenzhaojia = {id = "jibenzhaojia", exp = 121},
                jibenqinggong = {id = "jibenqinggong", exp = 121},
                jibenneigong = {id = "jibenneigong", exp = 121}
            }
            if PRINT_MODE == 1 then
                print("武学世家")
            end
            dialog:setText("Text_7", "你出生在武学世家，天生孔武有力，会一点三脚猫功夫。")
            dialog:setPanelHide(
                function()
                    self:createRoleAndEntryGame(str, dex, int, con, looks, luck, skills, money, sexFunc) -- 创建角色`
                end
            )
        end,
        func2 = function(sexFunc)
            local int = math.random(0, 10) + 20
            local con = math.random(0, 10) + 20
            local str, dex
            local num = 80 - int - con - 20
            if num > 10 then
                str = math.random(num - 10, 10) + 10
            else
                str = math.random(0, num) + 10
            end
            dex = 80 - int - con - str

            local looks = math.random(19, 24)
            local luck = 40 - looks

            local skills = {
                dushushizi = {id = "dushushizi", exp = 1876}
            }

            if PRINT_MODE == 1 then
                print("书香门第")
            end
            dialog:setText("Text_7", "你出生在书香门第，家族的熏陶使得你才思敏捷，聪明伶俐。")
            dialog:setPanelHide(
                function()
                    self:createRoleAndEntryGame(str, dex, int, con, looks, luck, skills, money, sexFunc) -- 创建角色
                end
            )
        end,
        func3 = function(sexFunc)
            local str = math.random(0, 7) + 18
            local dex = math.random(0, 7) + 18
            local int, con
            local num = 80 - str - dex - 30
            if num > 7 then
                int = math.random(num - 7, 7) + 15
            else
                int = math.random(0, num) + 15
            end
            con = 80 - str - dex - int

            local looks = math.random(18, 20)
            local luck = 40 - looks

            local money = 1000

            if PRINT_MODE == 1 then
                print("商贾之家")
            end
            dialog:setText("Text_7", "你出生在商贾之家，富甲一方的家底让你行事都万般便利。")
            dialog:setPanelHide(
                function()
                    self:createRoleAndEntryGame(str, dex, int, con, looks, luck, skills, money, sexFunc) -- 创建角色
                end
            )
        end,
        func4 = function(sexFunc)
            local int = math.random(0, 7) + 18
            local con = math.random(0, 7) + 18
            local str, dex
            local num = 80 - int - con - 30
            if num > 7 then
                str = math.random(num - 7, 7) + 15
            else
                str = math.random(0, num) + 15
            end
            dex = 80 - int - con - str

            local looks = math.random(18, 20)
            local luck = 45 - looks
            if PRINT_MODE == 1 then
                print("孤儿")
            end
            dialog:setText("Text_7", "你无父无母，你也不需要依靠，自己的未来由自己创造。")
            dialog:setPanelHide(
                function()
                    self:createRoleAndEntryGame(str, dex, int, con, looks, luck, skills, money, sexFunc) -- 创建角色
                end
            )
        end
    }

    dialog:showTheDialog(list.func1, list.func2, list.func3, list.func4)
end

function CreateRoleLayer:createRoleAndEntryGame(str, dex, int, con, looks, luck, skills, money, sexFunc)
    HttpManagerEx:createRole(
        function(status, errcode, errmsg, data, isEncrypted)
            if status == 200 and errcode == 0 and data and data.userid then
                local guanqiaLimit = User:getRoleAttr("guanqiaLimit")
                DataBase:resetRoleData()
                User:init()
                User:setRoleAttr("guanqiaLimit", guanqiaLimit)

                -- 设置性别
                if sexFunc then
                    sexFunc()
                end

                -- 设置人物属性
                if str then
                    User:setNaturalAttr("str", str)
                end
                if dex then
                    User:setNaturalAttr("dex", dex)
                end
                if int then
                    User:setNaturalAttr("int", int)
                end
                if con then
                    User:setNaturalAttr("con", con)
                end
                if looks then
                    User:setRoleAttr("looks", looks)
                end
                if luck then
                    User:setRoleAttr("luck", luck)
                end
                if skills then
                    User:setRoleAttr("skills", skills)
                end
                if money then
                    User:setRoleAttr("money", money)
                end

                -- 设置人物id
                User:setRoleAttr("userid", data.userid)

                -- 保存用户数据
                User:save()

                self:__uploadAndStartGame()

                return true
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function CreateRoleLayer:__uploadAndStartGame()
    Account:startGameUpload(
        function(eventName, errcode, errmsg)
            if eventName == "上传成功" then
                Helper:getDef(
                    self._successCallback,
                    function()
                        local ControllLayer = require("app.views.layer.ControllLayer")
                        ControllLayer:getInstance():startGame()
                    end
                )()
                return
            else
                PopText("上传存档失败, 请检查网络后重试 ! ! " .. tostring(errcode))
            end
        end
    )
end

-- 设置回调函数
function CreateRoleLayer:setSuccessCallBack(func)
    self._successCallback = func
end

Helper:classDefNodeGetInstance(CreateRoleLayer)

-- 加密标记
CreateRoleLayer.isEncrypted = true
return CreateRoleLayer
0