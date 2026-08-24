--[[
    程序用测试界面
]]
local GMTestLayer = class("GMTestLayer", LayerEx)
local TeacherTask = require("app.models.task.teacherTask.teacherTask")
local Inherit = require("app.models.inherit.Inherit")
local Meridian = require("app.models.Meridian.Meridian")
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
local ForgeSkill = require("app.models.ShenBing.ForgeSkill.ForgeSkill")

function GMTestLayer:create()
    local p = GMTestLayer:new()
    p:init()

    return p
end

function GMTestLayer:init()
    self._UI = require("Layer/DebugUI/TestUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)
    self:setButton()
end

function GMTestLayer:showLayer()
    self:setMainBtn()
    self:show()
end

function GMTestLayer:sysButtons()
    self.ListView:removeAllItems()

    self:addButton(
        "PVP触发型经脉打开",
        function()
            PopText("打开成功")
            IS_OPEN_PVP_JINGMAI = true
        end
    )
    self:addButton(
        "PVP触发型经脉关闭",
        function()
            PopText("关闭成功")
            IS_OPEN_PVP_JINGMAI = false
        end
    )

    self:addButton(
        "武器子类型打开",
        function()
            PopText("打开成功")
            WEAPONSUBTYPE_IS_OPEN = true
        end
    )
    self:addButton(
        "武器子类型关闭",
        function()
            PopText("关闭成功")
            WEAPONSUBTYPE_IS_OPEN = false
        end
    )

    self:addButton(
        "PVP神兵特性打开",
        function()
            PopText("打开成功")
            PVP_SHENBINGSYS = true
        end
    )
    self:addButton(
        "PVP神兵特性关闭",
        function()
            PopText("关闭成功")
            PVP_SHENBINGSYS = false
        end
    )

    self:addButton(
        "PVP毒药效果打开",
        function()
            PopText("打开成功")
            PVP_POISONSYS = true
        end
    )
    self:addButton(
        "PVP毒药效果关闭",
        function()
            PopText("关闭成功")
            PVP_POISONSYS = false
        end
    )

    self:addButton(
        "开启AI",
        function()
            NPC_AI = true
        end
    )
    self:addButton(
        "关闭AI",
        function()
            NPC_AI = false
        end
    )
    self:addButton(
        "开启神兵特性",
        function()
            SHENBINGSYS = true
        end
    )
    self:addButton(
        "关闭神兵特性",
        function()
            SHENBINGSYS = false
        end
    )
    self:addButton(
        "开启毒药系统",
        function()
            POISONSYS = true
        end
    )
    self:addButton(
        "关闭毒药系统",
        function()
            POISONSYS = false
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function GMTestLayer:setMainBtn()
    self.ListView:removeAllItems()

    self:addButton(
        "生命周期测试",
        function()
            local node = cc.Node:create()

            function node:onAwake()
                print("testNode : onAwake")
                HttpManagerEx:viewCurrencyByType(
                    "zongheng", User:getRole():getCurrencyVersion(),
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            print("viewCurrencyByType", errmsg, errcode)
                        end
                    end,
                    IS_SHOW_WAITING
                )

                print("testNode : onAwake end")
            end
            function node:onEnable()
                print("testNode : onEnable")
            end

            function node:onDisable()
                print("testNode : onDisable")
            end
            function node:onDestroy()
                print("testNode : onDestroy")
            end

            self:addChild(node)

            node:removeFromParent()
        end
    )

    self:addButton(
        "游戏检测相关",
        function()
            self:showCheckUtil()
        end
    )

    self:addButton(
        "系统开关",
        function()
            self:sysButtons()
        end
    )

    self:addButton(
        "性能测试按钮",
        function()
            self:setTestBtn()
        end
    )

    self:addButton(
        "存档保存方式相关",
        function()
            self:setSaveRoleData()
        end
    )

    self:addButton(
        "记录系统",
        function()
            self:recordSystem()
        end
    )

    self:addButton(
        "测试接口调整",
        function()
            self:changePort()
        end
    )

    self:addButton(
        "报错日志测试",
        function()
            self:errmsgTest()
        end
    )

    self:addButton(
        "Http测试",
        function()
            self:httpTest()
        end
    )

    self:addButton(
        "称号转化测试",
        function()
            self:titleChangeTest()
        end
    )

    self:addButton(
        "版本经脉天赋页202501",
        function()
            self:meridianImprintingTest()
        end
    )

    self:addButton("武学相关测试", function()
        self:skillTest()
    end)
end

function GMTestLayer:skillTest()
    self.ListView:removeAllItems()

    self:addButton("主动技能残页学习提示配置测试",function ()
        print("============== 主动技能残页学习提示配置测试 ==============")
        print("根据(\"script.skill.activeZhao\")[\"skillRelation\"] 配置，对所有主动技能所对应的残页学习条件文本进行测试")
        print("测试过程不报错即可")
        local BookSkillsHelper = require("app.models.book.BookSkillsHelper")
        local skill_relation = require("script.skill.activeZhao")["skillRelation"]
        local has_error= false
        local error_msgs = {}
        for active_id,skill_id in pairs(skill_relation) do
            local isOK, res = pcall(function ()
                BookSkillsHelper:getActiveSkillLearnForBookText(active_id)
            end)

            if not isOK then
                has_error = true
                table.insert(error_msgs, res)
            end
        end

        if not has_error then
            PopText("测试完成")
        else
            PopText("测试失败，错误信息请查看控制台")
        end
    end)

    self:addButton("返回", function()
        self:setMainBtn()
    end)
end

function GMTestLayer:meridianImprintingTest()
    self.ListView:removeAllItems()

    local MeridianHelper = require("app.models.Meridian.MeridianHelper")

    --@desc:
    --@author:Seven
    --@time:2025-01-17 12:09:42
    --@return [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
    local function __getMeridianSystem()
        local player = User:getRole()

        local role = Role:create()

        local clone_meridianImprinting = clone(player:getAttr("meridianImprinting"))

        role:setAttr("meridianImprinting", clone_meridianImprinting)

        local systemImpl = require("app.models.Meridian.System.MeridianRoleSystemImpl"):create(role)

        return systemImpl
    end

    self:addButton(
        "经脉天赋页新增转换测试",
        function()
            local MeridianDebug = require("app.views.layer.DebugLayer.MeridianDebug.MeridianDebug")
            local player = Role:create()
            MeridianDebug:resetMerianImprintingsBefore20250121(player)

            local clone_meridianImprinting = clone(player:getAttr("meridianImprinting"))

            local role =
                Role:create(
                {
                    meridianImprinting = clone_meridianImprinting
                }
            )

            role:getMeridianSystem():__printMeridianData()

            local m_meridianImprintings = role:getAttr("m_meridianImprintings")

            if m_meridianImprintings._MERIDATACOVERTVER_ ~= 1 then
                PopText("数据转换失败  _MERIDATACOVERTVER_ = " .. m_meridianImprintings._MERIDATACOVERTVER_)
                return false
            end

            local newImprMap = m_meridianImprintings.mImprintingMap
            local pageList = m_meridianImprintings.mPageList
            for i, v in ipairs(clone_meridianImprinting) do
                local imprintingId = v.imprintingId
                if not newImprMap[imprintingId] then
                    PopText("数据转换失败  mImprintingMap 未找到印记ID = " .. imprintingId)
                    return false
                end

                for index, vv in pairs(pageList) do
                    local isFind = false
                    for __, iid in ipairs(vv) do
                        if iid == imprintingId then
                            isFind = true
                            break
                        end
                    end
                    if not isFind then
                        PopText("数据转换失败  mPageList 未找到印记ID = " .. imprintingId .. " 页数 = " .. index)
                        return false
                    end
                end
            end

            print("======== 转换前数据：")
            Helper:print_lua_table(m_meridianImprintings.__convertBeforeTemp)

            PopText("数据转换成功")
        end
    )

    self:addButton(
        "解锁天赋页测试",
        function()
            local meridianRoleSystemImpl = __getMeridianSystem()
            local to, failmsg = meridianRoleSystemImpl:unlockMeridianImprintingPage()

            if to == -1 then
                PopText(tostring(failmsg))
                return
            end

            local from = 1

            local fromList = meridianRoleSystemImpl:getPageMeridianImprintings(from)
            local toList = meridianRoleSystemImpl:getPageMeridianImprintings(to)
            -- 判断两个列表内容是否相等

            for i, v in ipairs(fromList) do
                if v:getImprintingId() ~= toList[i]:getImprintingId() then
                    PopText("新增天赋页测试失败 , clone 数据不正确")
                    return
                end
            end

            PopText("新增天赋页测试成功")
        end
    )

    self:addButton(
        "经脉传承测试",
        function()
            local inheritRole = Role:create()

            MeridianHelper:meridianDoInherit(
                inheritRole,
                {
                    {"taixiyin", "danyinyin"},
                    {"taixiyin", "xiumingyin"}
                }
            )

            inheritRole:getMeridianSystem():__printMeridianData()

            local m_meridianImprintings = inheritRole.m_meridianImprintings

            local checkFucn = function(pageIndex, index, id)
                local page = m_meridianImprintings.mPageList[tostring(pageIndex)]
                if page[index] ~= id then
                    PopText("传承失败")
                    return false
                end

                return true
            end
            if checkFucn(1, 1, "taixiyin") and checkFucn(1, 2, "danyinyin") and checkFucn(2, 1, "taixiyin") and checkFucn(2, 2, "xiumingyin") then
                PopText("传承成功")
            end
        end
    )

    self:addButton(
        "经脉重筑测试",
        function()
            local role =
                Role:create(
                {
                    m_meridianImprintings = {
                        _MERIDATACOVERTVER_ = 1,
                        mCurrPage = 1,
                        mImprintingMap = {
                            taixiyin = {},
                            danyinyin = {},
                            xiumingyin = {}
                        },
                        mPageList = {
                            ["1"] = {"taixiyin", "danyinyin"},
                            ["2"] = {"taixiyin", "xiumingyin"}
                        }
                    }
                }
            )

            --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
            local sys = role:getMeridianSystem()

            local keepData = {
                {
                    "danyinyin"
                },
                {
                    "xiumingyin"
                }
            }

            MeridianHelper:doRebuildMeridian(role, keepData)

            sys:__printMeridianData()

            if role.m_meridianImprintings.mPageList["1"][1] == "danyinyin" and role.m_meridianImprintings.mPageList["2"][1] == "xiumingyin" then
                PopText("重筑成功")
            else
                PopText("重筑失败")
            end
        end
    )

    self:addButton(
        "定志丸培元测试",
        function()
            HttpManagerEx:testExchangeGoods(
                "dingzhiwan",
                1,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        local m_meridianImprintings = {
                            _MERIDATACOVERTVER_ = 0,
                            mCurrPage = 1,
                            mImprintingMap = {["taixiyin"] = {}},
                            mPageList = {
                                ["1"] = {"taixiyin"}
                            }
                        }

                        local role =
                            Role:create(
                            {
                                m_meridianImprintings = m_meridianImprintings
                            }
                        )

                        role:setAttr("inheritCount", 1)

                        role:addItemCount("dingzhiwan", 1)

                        local PeiYuanFactory = require("app.models.Meridian.PeiYuan.PeiYuanFactory")

                        local peiyuanFunImpl = PeiYuanFactory:getPeiYuanFactory(role, 1, "taixiyin", 3)

                        peiyuanFunImpl:peiyuan(
                            function(newImprId)
                                PopText("培元成功 : " .. newImprId)
                                role:getMeridianSystem():__printMeridianData()
                            end,
                            function(failmsg)
                                PopText("失败" .. failmsg)
                            end
                        )
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "印记随机角色全列表测试",
        function()
            --@RefType [MeridianHelper]
            local MeridianHelper = require("app.models.Meridian.MeridianHelper")

            local player = User:getRole()
            local sys = player:getMeridianSystem()
            local list = MeridianHelper:getAllRandomNewImprintList(sys)

            local isSuceess = true
            for i, v in ipairs(list) do
                print("随机列表", i, v:getIndexId(), v:getImprintingId())
                if sys:roleHasImpriting(v:getImprintingId()) then
                    isSuceess = false
                    break
                end
            end

            if isSuceess then
                PopText("测试通过")
            else
                PopText("测试失败")
            end
        end
    )

    self:addEditor(
        "印记随机指定页测试",
        "指定页数索引",
        function(editBox, text)
            assert(tonumber(text), "请输入数字")
            local pageIndex = tonumber(text)
            --@RefType [MeridianHelper]
            local MeridianHelper = require("app.models.Meridian.MeridianHelper")

            local player = User:getRole()

            local sys = player:getMeridianSystem()

            local list = MeridianHelper:getPeiYuanRandomList(pageIndex, sys)

            local isSuceess = true

            for i, v in ipairs(list) do
                print("随机列表", i, v:getIndexId(), v:getImprintingId())
                if sys:hasMeridianImprintingByPage(pageIndex, v:getImprintingId()) then
                    isSuceess = false
                    break
                end
            end

            if isSuceess then
                PopText("测试通过")
            else
                PopText("测试失败")
            end
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function GMTestLayer:setTestBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "暂停主界面",
        function()
            MainControllLayer:pauseUpdate()
        end
    )
    self:addButton(
        "开启主界面",
        function()
            MainControllLayer:resumeUpdate()
        end
    )
    self:addButton(
        "内存收集",
        function()
            collectgarbage("count")
            PopText("内存收集已执行")
        end
    )
    self:addButton(
        "分步收集",
        function()
            while true do
                if collectgarbage("step") then
                    PopText("分步收集已完成")
                    break
                end
            end
        end
    )
    self:addButton(
        "不锁帧",
        function()
            cc.Director:getInstance():setAnimationInterval(1 / 240)
        end
    )

    self:addButton(
        "开启性能测试",
        function()
            MainPerformanceAnalysisSystem:hook()
        end
    )

    self:addButton(
        "打印性能测试结果",
        function()
            MainPerformanceAnalysisSystem:printInfo("totalTime")
        end
    )

    self:addButton(
        "打印可见UI",
        function()
            local scene = cc.Director:getInstance():getRunningScene()

            local depth = -1

            local function printChildInfo(node)
                depth = depth + 1

                if node:isVisible() then
                    if node.class then
                        print(depth, string.rep(" ", depth) .. node.class.__cname)
                    else
                        print(depth, string.rep(" ", depth) .. node:getName())
                    end

                    local children = node:getChildren()
                    for i, child in ipairs(children) do
                        printChildInfo(child)
                    end
                end

                depth = depth - 1
            end

            printChildInfo(scene)
        end
    )
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function GMTestLayer:showCheckUtil()
    self.ListView:removeAllItems()
    self:addButton(
        "旧版武学转移新表检测",
        function()
            local SkillCheckUtil = require("app.views.layer.DebugLayer.CheckUtil.SkillChcekUtil")

            SkillCheckUtil.CheckOldSkillIdCompareNewSkillIdWithoutZhiShi()
        end
    )
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function GMTestLayer:setSaveStyle(type)
    local styleText = {
        ["auto"] = "自动存档",
        ["hand"] = "手动存档"
    }
    switch(
        type,
        {
            ["update"] = function()
                User:saveRoleStep()
                if self.Save_Time and GetTime() - self.Save_Time <= 300 then
                    PopText("上传太频繁了，服务器承载不过来")
                    return
                end
                Audio:playEffect("xiaoAnNiu")
                HttpManagerEx:uploadUserData(
                    "shangchuan",
                    function(status, errcode, errmsg, data, isEncrypted)
                        if status == 200 and errcode == 0 then
                            PopText("数据上传成功")
                            self.Save_Time = GetTime()
                            self:setMainBtn()
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            end,
            ["change"] = function()
                local str = styleText["auto"]
                if User:getRole():getFlag("用户存档方式") == 1 then
                    ROLE_DATA_SAVE_STYLE_AUTO = false
                    str = styleText["hand"]
                    User:getRole():setFlag("用户存档方式", 2)
                elseif User:getRole():getFlag("用户存档方式") == 2 then
                    ROLE_DATA_SAVE_STYLE_AUTO = true
                    User:getRole():setFlag("用户存档方式", 1)
                end
                PopText("已切换成" .. str)
                self:setMainBtn()
            end,
            ["auto"] = function()
                ROLE_DATA_SAVE_STYLE_AUTO = true
                PopText("已切换成" .. styleText[type])
                User:getRole():setFlag("用户存档方式", 1)
                self:setMainBtn()
            end,
            ["hand"] = function()
                ROLE_DATA_SAVE_STYLE_AUTO = false
                PopText("已切换成" .. styleText[type])
                User:getRole():setFlag("用户存档方式", 2)
                self:setMainBtn()
            end,
            default = function()
                ROLE_DATA_SAVE_STYLE_AUTO = true
            end
        }
    )
end

function GMTestLayer:setSaveRoleData()
    self.ListView:removeAllItems()
    if User:getRole():getFlag("用户存档方式") == 0 then
        self:addButton(
            "返回",
            function()
                self:setMainBtn()
            end
        )
        self:addButton(
            "自动存档",
            function()
                self:setSaveStyle("auto")
            end
        )
        self:addButton(
            "手动存档",
            function()
                self:setSaveStyle("hand")
            end
        )
    end

    if User:getRole():getFlag("用户存档方式") == 1 then --自动
        self:addButton(
            "返回",
            function()
                self:setMainBtn()
            end
        )

        self:addButton(
            "切换存档方式",
            function()
                self:setSaveStyle("change")
            end
        )
    end

    if User:getRole():getFlag("用户存档方式") == 2 then --手动
        self:addButton(
            "返回",
            function()
                self:setMainBtn()
            end
        )
        self:addButton(
            "手动上传存档",
            function()
                self:setSaveStyle("update")
            end
        )
        self:addButton(
            "切换存档方式",
            function()
                self:setSaveStyle("change")
            end
        )
    end
end

function GMTestLayer:recordSystem()
    self.ListView:removeAllItems()

    self:addEditor(
        "添加记录",
        "记录id",
        function(editBox, text)
            local recordId = tonumber(text)

            if not recordId then
                PopText("填写数字")
                return
            end

            local record = AchievementSystem:getRecordById(recordId)
            AchievementSystem:add(record)
            PopText("添加成功")
        end
    )

    self:addButton(
        "上传记录",
        function()
            AchievementSystem:updateRecord()
        end
    )

    self:addButton(
        "检测更新",
        function()
            AchievementSystem:update()
        end
    )

    self:addButton(
        "解锁图鉴记录点",
        function()
            AchievementSystem:updateTujianTypeRecord()
        end
    )

    self:addButton(
        "服务器已解锁记录点",
        function()
            AchievementSystem:printServerRecordData()
        end
    )

    self:addButton(
        "客户端已解锁记录点",
        function()
            AchievementSystem:printClientRecordData()
        end
    )

    self:addButton(
        "打印已解锁的解锁点",
        function()
            AchievementSystem:printUnlockPoints()
        end
    )

    self:addButton(
        "清除CD",
        function()
            AchievementSystem:clearCd()
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function GMTestLayer:changePort()
    self.ListView:removeAllItems()

    local DebugHelper = require("app.views.layer.DebugLayer.DebugHelper")
    local port = DebugHelper:getTestPort()
    if not port then
        if WConfig then
            port = WConfig.port
        end

        if not port then
            port = 1706
        end
    end

    self:addEditor(
        "网络请求地址端口调整",
        "当前端口：" .. port,
        function(editBox, text)
            local changePort = text
            if not changePort or changePort == "" then
                return
            end
            DOMAIN = string.gsub(DOMAIN, port, changePort)
            DebugHelper:setTestPort(changePort)
            PopText("端口成功替换为" .. changePort)
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function GMTestLayer:errmsgTest()
    self.ListView:removeAllItems()

    self:addButton(
        "常规报错",
        function()
            error("常规报错日志收集")
        end
    )

    self:addButton(
        "循环内报错",
        function()
            for i = 1, 10 do
                error("循环内测试报错日志收集")
            end
        end
    )

    self:addButton(
        "延时5秒报错",
        function()
            local hanle
            hanle =
                Game:schedule(
                function()
                    Game:unschedule(hanle)
                    error("延时报错日志收集")
                end,
                5
            )
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function GMTestLayer:httpTest()
    self.ListView:removeAllItems()

    self:addButton(
        "获取服务器时间",
        function()
            HttpManagerEx:testGetTime(
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 and errcode == 0 then
                        print("获取服务器时间", data.time)
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "获取服务器时间(支持异步)",
        function()
            HttpManagerEx:testGetTimeAsync(
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 and errcode == 0 then
                        print("获取服务器时间", data.time)
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "获取服务器时间(自定义请求文本)",
        function()
            HttpManagerEx:testGetTimeWaitText(
                "自定义请求文本",
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 and errcode == 0 then
                        print("获取服务器时间", data.time)
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "获取服务器时间(自定义请求文本并支持异步)",
        function()
            HttpManagerEx:testGetTimeWaitTextAsync(
                "自定义请求文本",
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 and errcode == 0 then
                        print("获取服务器时间", data.time)
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function GMTestLayer:titleChangeTest()
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addEditor(
        "旧版称号数据转化测试",
        "称号id;称号类型",
        function(editBox, text)
            local titleInfo = string.split(text, ";")
            if MapIsEmpty(titleInfo) then
                PopText("请出入正确数据！！")
                return
            end

            local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

            local basicTitleId = RoleTitleResManager:getChangeTitleBasicTitleId(titleInfo[2], titleInfo[1])

            if not basicTitleId then
                PopText("未找到对应输入称号，titleId:" .. titleInfo[1] .. ", titleType:" .. titleInfo[2])
            end

            local data = {
                titleId = basicTitleId,
                titleList = {basicTitleId}
            }

            local extraTitleList = {}

            if not extraTitleList[titleInfo[2]] then
                extraTitleList[titleInfo[2]] = {}
            end

            table.insert(extraTitleList[titleInfo[2]], {id = tonumber(titleInfo[1])})

            local role = Role:create()

            role:setInheritFlag("已转换称号相关结构", 0)

            role.extraTitle = extraTitleList

            local TitleHelper = require("app.models.role.titleSystem.TitleHelper")
            TitleHelper:changeTitle(role)

            local isTrue = true
            for i, titleId in ipairs(data.titleList) do
                if role:hasBasicTitle(titleId) == false then
                    isTrue = false
                end
            end

            if isTrue then
                PopText("转化成功！！！")
            else
                PopText("转化失败！！！")
            end

            Helper:print_lua_table(data.titleList)
            print("-----------------------")
            Helper:print_lua_table(role:getBasicTitleData())
        end
    )
end

function GMTestLayer:addButton(name, func)
    local panel = self.Panel:clone()
    Helper:convertUIByParent(panel)

    if func == nil then
        return
    end

    if name then
        if GameChannelContext:checkGMIsOpen(name) == false then
            return
        end
    else
        return
    end

    panel.Text_button_1:setString(name)
    panel.Button_1:releaseFunc(
        function()
            func()
        end
    )
    panel.Button_1:setSize(800, 100)

    self.ListView:pushBackCustomItem(panel)
end

function GMTestLayer:addEditor(name, defaultText, btnFunc)
    local panel = self.Panel_1:clone()

    Helper:convertUIByParent(panel)

    if btnFunc == nil then
        return
    end

    if defaultText == nil then
        defaultText = "请输入"
    end

    panel.Text_desc:setString(name)
    local size = panel.Image_num:getContentSize()
    local editBox = ccui.EditBox:create(size, defaultText)
    editBox:setInputMode(1)
    editBox:setInputFlag(3)
    editBox:setReturnType(1)
    editBox:setFontSize(48)
    editBox:addTo(panel)
    editBox:setPosition(panel.Image_num:getPositionX(), panel.Image_num:getPositionY())
    editBox:setTag(999)

    editBox:onEditHandler(
        function(event)
            if event.name == "return" then
            end
        end
    )

    panel.Button_back:releaseFunc(
        function()
            if btnFunc ~= nil then
                btnFunc(editBox, editBox:getText())
            end
        end
    )

    self.ListView:pushBackCustomItem(panel)

    return editBox
end

function GMTestLayer:setButton()
    self.Text_return:releaseFunc(
        function()
            self:hide(
                function()
                    self:removeFromParent(true)
                end
            )
        end
    )
end

Helper:classDefNodeGetInstance(GMTestLayer)

return GMTestLayer
0000