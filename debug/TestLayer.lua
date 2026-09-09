-- 测试界面
local TestFuncLayer = class("TestFuncLayer", LayerEx)
local LogSystem = require("app.models.LogSystem.LogSystem")
local GameConst = require("app.models.game.GameConst")
local Inherit = require("app.models.inherit.Inherit")
local Meridian = require("app.models.Meridian.Meridian")
local MapResHelper = require("app.models.map.MapResHelper")
local SkillHelper = require("app.models.skill.SkillHelper")
local BiWu = require("app.models.BiWu.BiWu")
local DebugHelper = require("app.views.layer.DebugLayer.DebugHelper")
local shoplistRes = require("res.script.store.shoplist")["Sheet1"]
local GoodsHelper = require("app.models.Store.GoodsHelper") 
local Goods = require("app.models.Store.Goods")
--@RefType [MeridianResources]
local MeridianResources = require("app.models.Meridian.MeridianResources")
local CurrencyUtil = require("app.models.Currency.CurrencyUtil")

function TestFuncLayer:create()
    local p = TestFuncLayer:new()
    p:init()
    return p
end

function TestFuncLayer:init()
    self._UI = require("Layer/DebugUI/TestUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setButton()

    self:setVisible(false)
end

function TestFuncLayer:showLayer()
    self:setMainBtn()
    self:maxZ()
    self:setVisible(true)
end

function TestFuncLayer:setMainBtn()
    self.ListView:removeAllItems()

    self:addButton("论剑功能",function()
        self:lunJianHelper()
    end)

    self:addButton("防作弊辅助数据",function()
        self:cheatHelper()
    end)

    self:addButton("叛师相关",function()
        self:departFromFamily()
    end)

    self:addButton(
        "防沉迷验证",
        function()
            self.ListView:removeAllItems()

            self:addButton(
                "返回",
                function()
                    self:setMainBtn()
                end
            )

            self:addEditor(
                "测试当前时间是否开启防沉迷",
                "20231011;20;59(年月日;时;分)",
                function(editBox, text)
                    if text == nil or text == "" then
                        PopText("请输入正确参数" .. text)
                        return
                    end

                    local timeMap = string.split(text,";")
                    local hour = tonumber(timeMap[2])

                    local time = Helper:getTimeStampWithStringDate(timeMap[1], hour) + tonumber(timeMap[3]) * 60

                    local AntiAddictionSystem = require("app.models.AntiAddictionSystem.AntiAddictionSystem")

                    AntiAddictionSystem:setTime(time)

                    if AntiAddictionSystem:isOpen() then
                        PopText("当前时间需开启防沉迷")
                    else
                        PopText("当前时间不需开启防沉迷")
                    end

                    if Helper:isHoliday(time) then
                        PopText("当前时间为节假日")
                    end

                    if Helper:isForbidDay(time) then
                        PopText("当前时间为禁止游戏时间")
                    end

                    local dayName = {
                        ["0"] = "星期天",
                        ["5"] = "星期五",
                        ["6"] = "星期六",
                    }

                    local day = os.date("%w",time)
                    if dayName[tostring(day)] then
                        PopText("当天为"..dayName[tostring(day)])
                    end
                end
            )

            self:addEditor(
                "模拟测试防沉迷",
                "20231011;20;59(年月日;时;分)",
                function(editBox, text)
                    if text == nil or text == "" then
                        PopText("请输入正确参数" .. text)
                        return
                    end

                    local timeMap = string.split(text,";")
                    local hour = tonumber(timeMap[2])

                    local time = Helper:getTimeStampWithStringDate(timeMap[1], hour) + tonumber(timeMap[3]) * 60

                    local AntiAddictionSystem = require("app.models.AntiAddictionSystem.AntiAddictionSystem")
                    local currTime = time
                    AntiAddictionSystem:setTime(time)
                    local isShowRemainTime
                    
                    local isOpen = AntiAddictionSystem:isOpen()
                    if isOpen == false then
                        local Hour = tonumber(Helper:date("%H",currTime))
                        local Minute = tonumber(Helper:date("%M",currTime))
                        if Hour == 20 and Minute >= 50 then
                            PopupLayerController:showLayer("PopWindowsLayer", function(layer)
                                local title = "确定"
                                local text = "还有"..tostring(Helper:getRange(60 - Minute,1,10)).."分钟就到达21：00，根据未成年人防沉迷的规定，届时您将无法登录游戏，请合理安排游戏时间，享受健康生活。"
                                local canHide = true
                                local func = function()
                                    layer:hide()
                                end
                                layer:showLayer(title,text,canHide,func)
                            end)
                        else
                           PopText("正常游戏时间")     
                        end
                    else
                        PopupLayerController:showLayer("WarmPromptLayer", function(layer)
                            layer:showLayer()
                        end)
                    end
                end
            )
        end
    )

    self:addButton(
        "师门日常建设相关",
        function()
            self:teacherBuild()
        end
    )

    self:addButton(
        "修改人物属性",
        function()
            self:playerAttrModify()
        end
    )

    self:addButton(
        "修改物品",
        function()
            self:playerItems()
        end
    )

    self:addButton("状态标识系统",function ()
        self:statusTags()
    end)

    self:addButton(
        "修改人物标记",
        function()
            self:playerFlags()
        end
    )

    self:addButton(
        "武学相关",
        function()
            self:playerSkillButtons()
        end
    )

    self:addButton(
        "武学突破相关",
        function()
            self:breakSkillButtons()
        end
    )
    
    self:addButton(
        "武器相关",
        function()
            self:playerWeaponButtons()
        end
    )

    self:addButton(
        "货币和服务器道具相关",
        function()
            self:playerModify()
        end
    )

    self:addButton(
        "活动相关",
        function()
            self:activityButtons()
        end
    )

    self:addButton(
        "任务相关",
        function()
            self:taskButtons()
        end
    )

    self:addButton(
        "旧副本相关",
        function()
            self:mapButtons()
        end
    )

    self:addButton(
        "挑战副本",
        function()
            self:challengeMapButtons()
        end
    )

    self:addButton(
        "毒药相关",
        function()
            self:poison()
        end
    )

    self:addButton(
        "旧版战斗相关",
        function()
            self:oldFightButtons()
        end
    )

    self:addButton(
        "商人相关",
        function()
            self:merchantButtons()
        end
    )

    self:addButton(
        "拳脚系统",
        function()
            self:fistFoot()
        end
    )

    self:addButton(
        "新版练功相关",
        function()
            self:newLianGong()
        end
    )

    self:addButton(
        "新版挂机任务相关",
        function()
            self:hangUpTaskNewVersion()
        end
    )

    self:addButton(
        "游戏时间设定",
        function()
            self:gameTimeModify()
        end
    )

    self:addButton(
        "新版战斗相关",
        function()
            self:newBattle()
        end
    )

    self:addButton(
        "自创武学相关",
        function()
            self:addCreatedSkill()
        end
    )

    self:addButton(
        "梦境相关",
        function()
            self:addDreamVersion()
        end
    )

    self:addButton(
        "南柯梦境相关",
        function()
            self:addFondDreamVersion()
        end
    )

    self:addButton(
        "充值相关",
        function()
            self:setRecharge()
        end
    )

    self:addButton(
        "传承相关",
        function()
            self:setInheritBtn()
        end
    )

    self:addButton(
        "师门版本",
        function()
            self:shimenVersion()
        end
    )

    self:addButton(
        "家园相关",
        function()
            self:setJiaYuanButton()
        end
    )

    self:addButton(
        "进京赶考",
        function()
            self:setExamBtn()
        end
    )

    self:addButton(
        "官员系统",
        function()
            self:setOfficialBtn()
        end
    )

    self:addButton(
        "书籍系统",
        function()
            self:setLiteraryBtn()
        end
    )

    self:addButton(
        "经脉系统",
        function()
            self:setMeridianBtn()
        end
    )

    self:addButton(
        "副本功能",
        function()
            self:setMapBtn()
        end
    )

    self:addButton(
        "头衔相关",
        function()
            self:setChenHaoBtn()
        end
    )

    self:addButton(
        "策略奖励相关",
        function()
            self:addRewardManager()
        end
    )

    self:addButton("装饰箱功能",function ()
        self:decorativeBoxFunc()
    end)

    self:addButton("皮肤相关GM工具",function ()
        self:uiSkinTest()
    end)
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/21 18:59:48
-- @params
-- @desc 家园系统相关的按键
function TestFuncLayer:setJiaYuanButton()
    self.ListView:removeAllItems()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local mid = role:getHouseId()

    self:addButton(
        "银票 +1000",
        function()
            HttpManagerEx:updateCurrencyByType(
                "add",
                "yinpiao",
                1000,
                nil,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("银票" .. "+" .. tostring(1000))
                        else
                            PopText(errmsg)
                        end
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "银票 +10000",
        function()
            HttpManagerEx:updateCurrencyByType(
                "add",
                "yinpiao",
                10000,
                nil,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("银票" .. "+" .. tostring(10000))
                        else
                            PopText(errmsg)
                        end
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "家园系统开关",
        function()
            self.ListView:removeAllItems()
            self:addButton(
                "家园系统开关打开",
                function()
                    JIAYUAN_SYSTEM_IS_OPEN = true
                    PopText("打开")
                end
            )
            self:addButton(
                "家园系统开关关闭",
                function()
                    JIAYUAN_SYSTEM_IS_OPEN = false
                    PopText("关闭")
                end
            )
        end
    )

    self:addButton(
        "快速完成家园引导",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()
            HttpManagerEx:getHomeSwitch(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("获得了" .. data.yinpiao .. "银票")
                            role:setInheritFlag("家园引导", 2)
                            PopText("完成")
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
    )

    self:addButton(
        "删除家园相关数据）",
        function()
            local role = User:getRole()
            local fq = role:getHomelandAttr("fq")
            if MapIsEmpty(fq) then
                PopText("没有房契数据，删除失败")
                return
            end

            HttpManagerEx:testHomeland(
                4,
                {mid = fq.mid},
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            --@RefType [app.models.role.Role#Role]
                            local role = User:getRole()

                            local bagItems = role:getItems()

                            for i = #bagItems, 1, -1 do
                                local item = bagItems[i]

                                local itemAttr = Item:getOneItemByKey(item.itemId)

                                if itemAttr and (itemAttr.type == "房契" or itemAttr.type == "地契" or itemAttr.type == "邀请函") then
                                    table.remove(bagItems, i)
                                end
                            end

                            role:setAttr("fq", nil)
                            role:setAttr("dq", nil)
                            role:setAttr("yq", nil)
                            role:setHomelandAttr("fq", {})
                            role:setHomelandAttr("dq", {})
                            role:setHomelandAttr("yq", {})
                            role:setHomelandAttr("dinner", {})
                            role:setAttr("homeLandRoleData", {})
                            role:setAttr("DispatchTask", {})

                            PopText("删除成功")
                        else
                            print("errcode : ", errcode)
                            PopText(errmsg)
                        end
                    end
                end
            )
        end
    )

    self:addButton(
        "测试公共副本",
        function()
            HttpManagerEx:getCommonFuben(
                "fb304",
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        -- 进入玩家副本房间
                        -- self:initUserMap(data)
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    )

    self:addButton(
        "获取玩家副本信息",
        function()
            HttpManagerEx:getUserMap(
                "35",
                1012,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        -- 进入玩家副本房间
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    )

    self:addButton(
        "购房",
        function()
            PopupLayerController:showLayer(
                "BuyHouseLayer",
                function(layer)
                    layer:showLayer("yangzhou001", "fb10")
                end
            )
        end
    )

    self:addButton(
        "购地",
        function()
            PopupLayerController:showLayer(
                "BuyLandLayer",
                function(layer)
                    layer:showLayer("fb10", "yangzhou001")
                end
            )
        end
    )

    self:addButton(
        "购地查询",
        function()
            PopupLayerController:showLayer(
                "BiddingQueryLayer",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "地皮处于缴费状态(马上)",
        function()
            HttpManagerEx:testHomeland(
                7,
                {mid = role:getHouseId(), datime = 0},
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("你的地皮处于缴费状态。")
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
    )
    self:addButton(
        "地皮处于缴费状态(3分钟)",
        function()
            HttpManagerEx:testHomeland(
                7,
                {mid = role:getHouseId(), datime = 180},
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("你的3分钟后地皮处于缴费状态。")
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
    )

    self:addButton(
        "马上回收地皮",
        function()
            HttpManagerEx:testHomeland(
                8,
                {mid = role:getHouseId(), datime = 0},
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("你的地皮被回收，进入副本查看更新状态。")
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
    )

    self:addButton(
        "3分钟后回收地皮",
        function()
            HttpManagerEx:testHomeland(
                8,
                {mid = role:getHouseId(), datime = 180},
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("你的地皮将于3分钟后回收。")
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
    )

    self:addButton(
        "竞拍过期时间为0",
        function()
            HttpManagerEx:setAuctionTime(
                0,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("设置成功！")
                        else
                            print(errmsg, errcode)
                            PopText(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    )

    self:addButton(
        "竞拍过期时间为3分钟",
        function()
            HttpManagerEx:setAuctionTime(
                60 * 3,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("设置成功！")
                        else
                            print(errmsg, errcode)
                            PopText(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    )

    self:addButton(
        "邀请函-数据清除（测试）",
        function()
            local role = User:getRole()
            --@RefType [app.models.HomelandModel.YaoQingHanModel#YaoQingHanModel]
            local YaoQingHanModel = require("app.models.HomelandModel.YaoQingHanModel")

            local yq = role:getHomelandAttr("yq")
            for k, v in pairs(yq) do
                YaoQingHanModel:deleteInfoAndItem(v.id)
            end

            local items =
                role:getItems(
                function(obj)
                    if string.find(obj.itemId, "yq") then
                        return true
                    end
                end
            )

            if not MapIsEmpty(items) then
                for k, v in pairs(items) do
                    print("多余的...", v.itemId)
                    role:addItemCount(v.itemId, -1)
                end
            end
        end
    )

    self:addButton(
        "清除休息CD",
        function()
            local role = User:getRole()
            role:setDayFlag("bedrest", 0)
        end
    )

    self:addButton(
        "清除做饭CD",
        function()
            local role = User:getRole()
            role:setTimeLimitFlag("做饭", 0, 0)
        end
    )

    self:addButton(
        "打印dinner数据",
        function()
            local role = User:getRole()
            local dinner = role:getHomelandAttr("dinner")
            print("-------------------- dinner ---------------------")
            Helper:print_lua_table(dinner)
        end
    )

    self:addButton(
        "搬家",
        function()
            local role = User:getRole()
            local fq = role:getHomelandAttr("fq")
            if not fq then
                PopText("你没有房契数据，无法搬家")
                return
            end
            fq.status = 1 --@搬家状态
            PopText("搬家完成")
        end
    )
    self:addButton(
        "清除所有练功木人数据",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            role:setAttr("lianGongItems", {})
        end
    )
    self:addButton(
        "增加所有仆人忠诚度100",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local fq = role:getHomelandAttr("fq")
            if not fq then
                PopText("你没有房契数据，无法增加")
                return
            end

            HttpManagerEx:testHomeland(
                1,
                {mid = role:getHouseId(), loyal = 180},
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            role:setMapWithId("user_fb_" .. fq.mid, nil)
                            PopText("所有仆人忠诚度增加100")
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
    )
    self:addButton(
        "增加所有仆人忠诚度1000",
        function()
            HttpManagerEx:testHomeland(
                1,
                {mid = role:getHouseId(), loyal = 180},
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            role:setMapWithId("user_fb_" .. mid, nil)
                            PopText("所有仆人忠诚度增加1000")
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
    )

    self:addButton(
        "查看所有仆人",
        function()
            self:checkAllHomelandNpc()
        end
    )

    self:addButton(
        "删除所有仆人",
        function()
            HttpManagerEx:testHomeland(
                2,
                {mid = role:getHouseId()},
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            role:setAttr("homeLandRoleData", {})
                            role:setMapWithId("user_fb_" .. mid, nil)
                            PopText("成功删除所有仆人")
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
    )
    self:addButton(
        "种植时间减少30分钟",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local plant = role:getHomelandAttr("plant")

            if MapIsEmpty(plant) then
                return
            end

            for k, v in pairs(plant) do
                if v.endTime then
                    v.endTime = math.max(v.endTime - 60 * 30, GetTime())
                elseif v.reTime then
                    v.reTime = math.max(v.reTime - 60 * 30, 0)
                end
            end
            PopText("所有种植完成时间减少30分钟。")
        end
    )
    self:addButton(
        "种植所有种植完成",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local plant = role:getHomelandAttr("plant")

            if MapIsEmpty(plant) then
                return
            end

            for k, v in pairs(plant) do
                if v.endTime then
                    v.endTime = GetTime()
                elseif v.reTime then
                    v.reTime = 0
                end
                v.status = 2
            end

            PopText("所有种植完成。")
        end
    )

    self:addButton(
        "偶遇模块",
        function()
            self:setOuYuBtn()
        end
    )

    self:addButton(
        "派遣模块",
        function()
            self:setDispatchTaskBtn()
        end
    )

    self:addButton(
        "一键解锁所有仆人特性（随机）",
        function()
            local role = User:getRole()
            local fq = role:getHomelandAttr("fq")
            if not fq then
                PopText("你没有房契数据，无法解锁")
                return
            end

            HttpManagerEx:testHomeland(
                3,
                {mid = role:getHouseId(), loyal = 180},
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            role:setMapWithId("user_fb_" .. fq.mid, nil)
                            PopText("一键解锁所有仆人特性")
                        else
                            print("errcode : ", errcode)
                            PopText(errmsg)
                        end
                    end
                end
            )
        end
    )

    self:addButton(
        "特殊房间功能CD限制去除",
        function()
            role:setTimeLimitFlag("品书", 0)
            role:setTimeLimitFlag("晶台闭关", 0)
            role:setTimeLimitFlag("设宴CD", 0)
            role:setDayFlag("观景", 0)
            role:setDayFlag("打水", 0)

            PopText("清除成功")
        end
    )

    self:addEditor(
        "指定怪客id战斗",
        "怪客模板id(2805)",
        function(editBox, text)
            if tonumber(text) == nil then
                PopText("怪客id错误")
                return
            end

            local npcId = text

            local JHGKMoBan = require("script.others.guaike").Sheet1
            
            local npcRole = JHGKMoBan[npcId]

            if not npcRole then
                PopText("怪客id错误")
                return
            end

            npcRole.name = "测试怪客"

            Npc:initNpc(npcRole)
            npcRole = Role:create(npcRole)

            local FightLayer = require("app.views.layer.FightLayer.FightLayer")
            FightLayer:startMapFight({clone(User:getRole())}, {npcRole}, function(fightLayer, eventType,...)
                local fight = fightLayer:getFight()
                if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
                    -- 战斗开始的时候设置下玩家
                    local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
                    fight:setPlayer(role)
                    -- fight:start()
                    fightLayer:printRolePrologue(1, "切磋")
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
                    PopText("战斗开始!!!")
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
                    local winTeamId, teams = ...
                    -- 隐藏按钮区域
                    fightLayer:callUIMemFunc("setButtonAreaVisble", false)
                    -- 显示战斗结束文本区域
                    fightLayer:callUIMemFunc("showFightEndTextArea")

                    -- 设置战斗结束文本区域的文本
                    if winTeamId == 1 then
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你战胜了" .. npcRole.name)
                    else
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "失败")
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你被" .. npcRole.name .. "打趴在地")
                    end
                    
                    fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
                        fightLayer:hide(function()
                            fightLayer:destroyInstance()
                        end)
                    end)
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
                    fightLayer:hide(function()
                        fightLayer:destroyInstance()
                    end)
                end
            end)
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:npcFunc(npc)
    self.ListView:removeAllItems()

    local npc = npc

    local npcId = npc.rwId

    local mid = npc.mid

    local function addZc(npcId, value)
        HttpManagerEx:updateEmployRoleData(
            npcId,
            mid,
            "free",
            value,
            0,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        PopText("忠诚度增加 +" .. value)
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

    self:addButton(
        "忠诚度增加10 ",
        function()
            addZc(npcId, 10)
        end
    )
    self:addButton(
        "忠诚度增加50 ",
        function()
            addZc(npcId, 50)
        end
    )
    self:addButton(
        "忠诚度增加100 ",
        function()
            addZc(npcId, 100)
        end
    )
    self:addButton(
        "忠诚度增加500 ",
        function()
            addZc(npcId, 500)
        end
    )
    self:addButton(
        "忠诚度增加1000 ",
        function()
            addZc(npcId, 1000)
        end
    )

    self:addButton(
        "设置仆人进入闹事",
        function()
            print("mid =", mid, "npcId = ", npcId)
            HttpManagerEx:setPuRenStatus(
                mid,
                npcId,
                "naoshi",
                0,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("设置成功")
                        else
                            print("errcode : ", errcode)
                            PopText(errmsg)
                        end
                    end
                end
            )
        end
    )
    self:addButton(
        "设置仆人离开",
        function()
            HttpManagerEx:setPuRenStatus(
                mid,
                npcId,
                "leave",
                0,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("设置成功")
                        else
                            print("errcode : ", errcode)
                            PopText(errmsg)
                        end
                    end
                end
            )
        end
    )

    self:addButton(
        "设置门客进入云游状态",
        function()
            print("mid =", mid, "npcId = ", npcId)
            HttpManagerEx:setPuRenStatus(
                mid,
                npcId,
                "wild",
                0,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("设置成功")
                        else
                            print("errcode : ", errcode)
                            PopText(errmsg)
                        end
                    end
                end
            )
        end
    )

    self:addButton(
        "返回",
        function()
            self:checkAllHomelandNpc()
        end
    )
end

function TestFuncLayer:checkAllHomelandNpc()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")
    if MapIsEmpty(fq) then
        PopText("你没房子")
        return
    end

    HttpManagerEx:testHomeland(
        5,
        {mid = role:getHouseId()},
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if MapIsEmpty(data) then
                        return
                    end
                    self.ListView:removeAllItems()

                    for i, npc in ipairs(data) do
                        self:addButton(
                            npc.name,
                            function()
                                self:npcFunc(npc)
                            end
                        )
                    end
                    self:addButton(
                        "返回",
                        function()
                            self:setJiaYuanButton()
                        end
                    )
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

function TestFuncLayer:setDispatchTaskBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "完成所有派遣任务",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()
            --@RefType [app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager#DispatchTaskManager]
            local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")

            local tasks = role:getTasks()

            for taskId, task in pairs(tasks) do
                if task.state == TASK_STATE_DISPATCH then
                    task.endTime = GetTime()
                    DispatchTaskManager:finishTask(taskId, task)
                end
            end

            PopText("已完成所有派遣任务，进入玩家副本领取奖励。")
        end
    )

    self:addButton(
        "所有派遣任务加速30分钟",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()
            --@RefType [app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager#DispatchTaskManager]
            local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")

            local tasks = role:getTasks()

            for taskId, task in pairs(tasks) do
                if task.state == TASK_STATE_DISPATCH then
                    if task.endTime > GetTime() then
                        task.startTime = task.startTime - 1800
                        task.endTime = math.max(task.endTime - 1800, GetTime())
                    end
                    if task.endTime == GetTime() then
                        DispatchTaskManager:finishTask(taskId, task)
                    end
                end
            end

            PopText("所有派遣任务加速30分钟")
        end
    )

    self:addButton(
        "清除派遣列表数据",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()
            --@RefType [app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager#DispatchTaskManager]
            local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")

            local roleDispatchTask = role:getAttr("DispatchTask")

            roleDispatchTask.npcTaskList = {}

            PopText("已清除派遣列表数据。")
        end
    )

    self:addButton(
        "重置所有任务当日次数",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local tasks = role:getAttr("tasks")

            for k, v in pairs(tasks) do
                v.dCount = 0
            end

            PopText("重置所有任务当日次数")
        end
    )

    self:addButton(
        "返回",
        function()
            self:setJiaYuanButton()
        end
    )
end

function TestFuncLayer:setOuYuBtn()
    self.ListView:removeAllItems()

    --@RefType [app.models.HomelandModel.MapMeetModel.MapMeetUtil#MapMeetUtil]
    local MapMeetUtil = require("app.models.HomelandModel.MapMeetModel.MapMeetUtil")

    --@RefType [app.models.HomelandModel.MapMeetModel.OuYuModel#OuYuModel]
    local OuYuModel = require("app.models.HomelandModel.MapMeetModel.OuYuModel")

    local OUYUATTR = "ouYuTask"

    self:addButton(
        "查看偶遇信息",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local ouYuTask = role:getAttr(OUYUATTR)

            if not ouYuTask then
                PopText("你没有偶遇任务")
                return
            end

            local task = MapMeetUtil:getTaskById(ouYuTask.id)

            Helper:print_lua_table(ouYuTask)

            print("偶遇任务状态：", role:getFlag(task.mark))
        end
    )

    self:addButton(
        "设置当前偶遇任务为过期状态",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local ouYuTask = role:getAttr(OUYUATTR)

            if not ouYuTask then
                PopText("你没有偶遇任务")
                return
            end

            local task = MapMeetUtil:getTaskById(ouYuTask.id)

            ouYuTask.exTime = GetTime() - 10

            role:setAttr(OUYUATTR, ouYuTask)

            PopText("偶遇任务已过期")
        end
    )

    self:addButton(
        "设置偶遇任务标记2",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local ouYuTask = role:getAttr(OUYUATTR)

            if not ouYuTask then
                return
            end

            local task = MapMeetUtil:getTaskById(ouYuTask.id)

            role:setAttr(task.mark, 2)

            PopText("你的偶遇任务已完成。")
        end
    )

    self:addButton(
        "完成偶遇任务",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local ouYuTask = role:getAttr(OUYUATTR)

            if not ouYuTask then
                PopText("你没有偶遇任务")
                return
            end

            local task = MapMeetUtil:getTaskById(ouYuTask.id)

            role:setAttr(task.mark, 0)

            PopText("你的偶遇任务已完成。")
        end
    )

    self:addButton(
        "清除偶遇任务",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local ouYuTask = role:getAttr(OUYUATTR)

            role:setAttr(OUYUATTR, {})

            PopText("任务删除成功，进入副本前先刷新副本")
        end
    )

    self:addButton(
        "清除身世任务",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            local ssTask = role:getAttr("ssTask")

            if ssTask == nil or MapIsEmpty(ssTask) then
                PopText("你当前没有身世任务")
                return
            end

            local mid = role:getHouseId()

            local npcId = ssTask.serId

            local update_data = {
                {
                    rwId = npcId,
                    extra = {
                        shenshi_status = 0
                    }
                }
            }

            HttpManagerEx:updateEmployeeExtra(
                mid,
                update_data,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            role:setAttr("ssTask", {})
                            PopText("任务清除成功")
                        else
                            PopText("人物属性更改失败。")
                            print(errmsg, errcode)
                        end
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

function TestFuncLayer:shimenVersion()
    self.ListView:removeAllItems()

    self:addButton(
        "通关前二十章",
        function()
            local role = User:getRole()

            local v01 = Map:getMapIdListInVolume("volume_1")
            local v02 = Map:getMapIdListInVolume("volume_2")

            for _, mapId in ipairs(v01) do
                role:setMapCompleted(mapId)
            end
            for _, mapId in ipairs(v02) do
                role:setMapCompleted(mapId)
            end

            PopText("通关前20章")
        end
    )

    --@RefType [src.app.models.family.FamilyGroup#FamilyGroup]
    local FamilyGroup = require("app.models.family.FamilyGroup")
    self:addButton(
        "清除舍友缓存",
        function()
            FamilyGroup:clearCache()
        end
    )

    self:addButton(
        "清除今日舍友相关操作标记",
        function()
            FamilyGroup:getGroupMembers(
                function(data)
                    if MapIsEmpty(data) then
                        return
                    end

                    local player = User:getRole()

                    for i, roleData in ipairs(data) do
                        local roleId = roleData.userid
                        for _, prefix in pairs(FamilyGroup.FLAGS_PREFIX) do
                            player:setDayFlag(prefix .. roleId, nil)
                        end
                    end
                end
            )
        end
    )
    self:addButton(
        "清除舍友切磋记录",
        function()
            FamilyGroup:getGroupMembers(
                function(data)
                    if MapIsEmpty(data) then
                        return
                    end

                    local player = User:getRole()

                    for i, roleData in ipairs(data) do
                        local roleId = roleData.userid
                        player:setDayFlag(FamilyGroup.FLAGS_PREFIX.DAY_FIGHT_FLAG .. roleId, nil)
                    end
                end
            )
        end
    )

    self:addButton(
        "退出师门小团体",
        function()
            HttpManagerEx:removeManpaiTeam(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("退出成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "清除师门任务存档",
        function()
            local role = User:getRole()
            role:setAttr("teacherGuaJiTask", {})
            role:removeRoleCurrState(ROLE_CURR_STATE_TEACHERGUAJI)
        end
    )

    self:addButton(
        "解锁门派唯一头衔",
        function()
            HttpManagerEx:setSoleTitle(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("解锁成功")
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    )

    self:addButton(
        "重新检测头衔是否解锁",
        function()
            local FamilyPrestige = require("app.models.family.FamilyPrestige")
            FamilyPrestige:getUserPrestige(
                function(data)
                    Helper:print_lua_table(data)
                end
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

function TestFuncLayer:teacherBuild()
    self.ListView:removeAllItems()

    self:addEditor(
        "刷新师门日常建设任务",
        "任务id",
        function(editBox, text)
            local str = string.trim(text)

            HttpManagerEx:testTeacherBuildAction(
                3,
                str,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("刷新成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton("师门指点次数刷新",function()
        HttpManagerEx:testResetSectGuidance(function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                PopText("师门指点次数刷新成功！")
            else
                PopText(errmsg)
            end
        end,IS_SHOW_WAITING)
    end)

    self:addButton(
        "立即刷新门派昌盛度",
        function()
            HttpManagerEx:testTeacherBuildAction(
                6,
                1,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("刷新成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    local itemList = {
        reputation = 1,
        diligent = 2,
        sgbpoint = 4,
        gbpoint = 5,
        bmaterials1 = 7,
        bmaterials2 = 8,
        bmaterials3 = 9,
        bmaterials4 = 10,
        bmaterials5 = 11,
        bmaterials6 = 12,
        renown = 13,
        donate = 15,
        featscount = 16
    }
    for k,v in pairs(itemList) do
        self:addEditor(
            User:getRole():getCHAttrName(k).."数量修改",
            "增减值",
            function(editBox, text)
                local str = string.trim(text)
    
                if tonumber(str) == nil then
                    PopText("填写非数字")
                    return
                end
    
                HttpManagerEx:testTeacherBuildAction(
                    v,
                    tonumber(str),
                    function(status, errcode, errmsg, data)
                        if status == 200 and errcode == 0 then
                            PopText("添加成功")
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            end
        )
    end

    self:addButton(
        "重置每日捐献次数",
        function()
            HttpManagerEx:testTeacherBuildAction(
                14,
                0,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("重置每日捐献次数")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addEditor(
        "建筑建设值修改",
        "建筑类型id#增减值",
        function(editBox, text)
            local str = string.trim(text)

            local buildTypeId = string.split(text,"#")[1]

            local number = tonumber(string.split(text,"#")[2])

            if buildTypeId == nil or number == nil then
                PopText("检查填写参数格式 "..text)
                return
            end

            HttpManagerEx:testUpdateBuildingDegree(
                User:getRole():getFamilyId(),
                buildTypeId,
                number,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("添加成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "获得进入叛师挑战副本标记",
        function()
            User:getRole():setFlag("23defectstart",1)
            PopText("添加成功")
        end
    )

    self:addButton(
        "删除进入叛师挑战副本标记",
        function()
            User:getRole():setFlag("23defectstart",0)
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:addFondDreamVersion()
    self.ListView:removeAllItems()
    local role = User:getRole()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton(
        "棋局选择",
        function()
            PopupLayerController:showLayer(
                "ChessboardLayer",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "删除南柯梦境存档",
        function()
            HttpManagerEx:deleteFondDreamRoleData(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("删除成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "臂力+20",
        function()
            local map = Map:getCurrMap()
            local player = map:getPlayer()
            player:addAttr("str", 20)
            PopText("臂力+20")
        end
    )
    self:addButton(
        "根骨+20",
        function()
            local map = Map:getCurrMap()
            local player = map:getPlayer()
            player:addAttr("con", 20)
            PopText("根骨+20")
        end
    )

    self:addButton(
        "身法+20",
        function()
            local map = Map:getCurrMap()
            local player = map:getPlayer()
            player:addAttr("dex", 20)
            PopText("身法+20")
        end
    )

    self:addEditor(
        "战队对决",
        "战队id1;战队id2",
        function(editBox, text)
            local function getTeam(indexOffset, combatId)
                local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")
                local team_info = ChallengeMapResource:getInstance():getNpcTeamMapById(combatId)

                local rightTeam = {}

                if team_info.pos1NPCbgID and team_info.pos1NPCbgID ~= 0 then
                    local name = team_info.pos1NPCname
                    local baseAttrId = team_info.pos1NPCbgID
                    local attrId = team_info.pos1AttributeID

                    local npcAttrRes = assert(requireWithEncrypt("script.challengeMap.fightNpcAttrs")[team_info.pos1AttributeLevel])
                    --@RefType [src.app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder#ChallengeMapFightNpcBuilder]
                    local builder = require("app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder"):create()
                    local r_character1 = builder:setAttrRes(npcAttrRes):setAttrId(attrId):setBaseAttrId(baseAttrId):setName(name):setPosIndex(1 + indexOffset):build()
                    table.insert(rightTeam, r_character1)
                end

                if team_info.pos2NPCbgID and team_info.pos2NPCbgID ~= 0 then
                    local name = team_info.pos2NPCname
                    local baseAttrId = team_info.pos2NPCbgID
                    local attrId = team_info.pos2AttributeID

                    local npcAttrRes = assert(requireWithEncrypt("script.challengeMap.fightNpcAttrs")[team_info.pos2AttributeLevel])
                    --@RefType [src.app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder#ChallengeMapFightNpcBuilder]
                    local builder = require("app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder"):create()
                    local r_character2 = builder:setAttrRes(npcAttrRes):setAttrId(attrId):setBaseAttrId(baseAttrId):setName(name):setPosIndex(2 + indexOffset):build()
                    table.insert(rightTeam, r_character2)
                end

                if team_info.pos3NPCbgID and team_info.pos3NPCbgID ~= 0 then
                    local name = team_info.pos3NPCname
                    local baseAttrId = team_info.pos3NPCbgID
                    local attrId = team_info.pos3AttributeID

                    local npcAttrRes = assert(requireWithEncrypt("script.challengeMap.fightNpcAttrs")[team_info.pos3AttributeLevel])
                    --@RefType [src.app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder#ChallengeMapFightNpcBuilder]
                    local builder = require("app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder"):create()
                    local r_character3 = builder:setAttrRes(npcAttrRes):setAttrId(attrId):setBaseAttrId(baseAttrId):setName(name):setPosIndex(3 + indexOffset):build()
                    table.insert(rightTeam, r_character3)
                end

                return rightTeam
            end

            local leftTeamId, rightTeamId, playerIndex = unpack(string.split(text, ";"))
            leftTeamId = tonumber(leftTeamId)
            rightTeamId = tonumber(rightTeamId)
            playerIndex = tonumber(playerIndex)

            local leftTeam = getTeam(0, leftTeamId)
            local rightTeam = getTeam(3, rightTeamId)

            if playerIndex then
                if playerIndex <= 3 then
                    leftTeam[playerIndex]:setPlayer(true)
                else
                    rightTeam[playerIndex - 3]:setPlayer(true)
                end
            else
                leftTeam[1]:setPlayer(true)
            end

            LogSystem:log("leftTeam:", leftTeam)
            LogSystem:log("rightTeam:", rightTeam)

            local FightFinishCallback = require("app.FightSystem.Fight.FightFinishCallback")

            --@RefType[src.app.FightSystem.Fight.FightFinishCallback#FightFinishCallback]
            local finishCallback = FightFinishCallback:create()

            finishCallback:setWinCallbackFunc(
                function()
                    print("你赢了！！！！！！！！！！")
                end
            )

            finishCallback:setLoseCallbackFunc(
                function()
                    print("你输了！！！！！！！！！")
                end
            )

            local FightRunner = require("app.FightSystem.FightRunner")
            local fight = FightRunner:mapFightRun(leftTeam, rightTeam, finishCallback)
        end
    )

    self:addEditor(
        "进阶对战",
        '{leftTeamId = {}, rightTeamId = {}, buffId = ""}',
        function(editBox, text)
            if text == "" then
                text = "{}"
            end
            local function getTeam(indexOffset, combatId)
                if combatId == nil then
                    local leftTeam = {}

                    local FightCommons = require("app.FightSystem.FightCommons")
                    local ChallengeMapFightPlayerBuilder = require("app.FightSystem.Factory.CharacterFactory.ChallengeMapFightPlayerBuilder")
                    local builder = ChallengeMapFightPlayerBuilder:create(User:getRole())

                    local l_character = builder:getCharacter()

                    l_character:setAttr("id", tostring(indexOffset + 1))

                    local pos = FightCommons.CHARACTER_POSITION[indexOffset + 1]
                    l_character:setPosIndex(indexOffset + 1)
                    l_character:setPosition(pos.x, pos.y, 0)

                    table.insert(leftTeam, l_character)
                    return leftTeam
                end

                local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")
                local team_info = ChallengeMapResource:getInstance():getNpcTeamMapById(combatId)

                local rightTeam = {}

                if team_info.pos1NPCbgID and team_info.pos1NPCbgID ~= 0 then
                    local name = team_info.pos1NPCname
                    local baseAttrId = team_info.pos1NPCbgID
                    local attrId = team_info.pos1AttributeID

                    local npcAttrRes = assert(requireWithEncrypt("script.challengeMap.fightNpcAttrs")[team_info.pos1AttributeLevel])
                    --@RefType [src.app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder#ChallengeMapFightNpcBuilder]
                    local builder = require("app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder"):create()
                    local r_character1 = builder:setAttrRes(npcAttrRes):setAttrId(attrId):setBaseAttrId(baseAttrId):setName(name):setPosIndex(1 + indexOffset):build()
                    table.insert(rightTeam, r_character1)
                end

                if team_info.pos2NPCbgID and team_info.pos2NPCbgID ~= 0 then
                    local name = team_info.pos2NPCname
                    local baseAttrId = team_info.pos2NPCbgID
                    local attrId = team_info.pos2AttributeID

                    local npcAttrRes = assert(requireWithEncrypt("script.challengeMap.fightNpcAttrs")[team_info.pos2AttributeLevel])
                    --@RefType [src.app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder#ChallengeMapFightNpcBuilder]
                    local builder = require("app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder"):create()
                    local r_character2 = builder:setAttrRes(npcAttrRes):setAttrId(attrId):setBaseAttrId(baseAttrId):setName(name):setPosIndex(2 + indexOffset):build()
                    table.insert(rightTeam, r_character2)
                end

                if team_info.pos3NPCbgID and team_info.pos3NPCbgID ~= 0 then
                    local name = team_info.pos3NPCname
                    local baseAttrId = team_info.pos3NPCbgID
                    local attrId = team_info.pos3AttributeID

                    local npcAttrRes = assert(requireWithEncrypt("script.challengeMap.fightNpcAttrs")[team_info.pos3AttributeLevel])
                    --@RefType [src.app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder#ChallengeMapFightNpcBuilder]
                    local builder = require("app.FightSystem.Factory.CharacterFactory.ChallengeMapFightNpcBuilder"):create()
                    local r_character3 = builder:setAttrRes(npcAttrRes):setAttrId(attrId):setBaseAttrId(baseAttrId):setName(name):setPosIndex(3 + indexOffset):build()
                    table.insert(rightTeam, r_character3)
                end

                return rightTeam
            end

            local config = loadstring("return " .. text)()

            local leftTeamId, rightTeamId = config.leftTeamId, config.rightTeamId
            leftTeamId = tonumber(leftTeamId)
            rightTeamId = tonumber(rightTeamId)

            local leftTeam = getTeam(0, leftTeamId)
            local rightTeam = getTeam(3, rightTeamId)

            leftTeam[1]:setPlayer(true)

            local FightFinishCallback = require("app.FightSystem.Fight.FightFinishCallback")

            --@RefType[src.app.FightSystem.Fight.FightFinishCallback#FightFinishCallback]
            local finishCallback = FightFinishCallback:create()

            finishCallback:setWinCallbackFunc(
                function()
                    print("你赢了！！！！！！！！！！")
                end
            )

            finishCallback:setLoseCallbackFunc(
                function()
                    print("你输了！！！！！！！！！")
                end
            )

            local FightRunner = require("app.FightSystem.FightRunner")
            local fight = FightRunner:mapFightRun(leftTeam, rightTeam, finishCallback)
        end
    )

    self:addEditor(
        "南柯梦境角色增加物品",
        "物品id;数量|物品id;数量",
        function(editBox, text)
            local str = text
            print("str = ", str)
            local map = Map:getCurrMap()
            local player = map:getPlayer()

            local function addItem(str1)
                local itemId, count
                if string.find(str1, ";") then
                    itemId = string.split(str1, ";")[1]
                    count = tonumber(string.split(str1, ";")[2])
                else
                    itemId = str1
                    count = 1
                end
                print("itemId = ", itemId, "count = ", count)
                player:addItemCount(itemId, count)
            end

            if string.find(str, "|") then
                local list = string.split(str, "|")
                for i, v in ipairs(list) do
                    addItem(v)
                end
            else
                addItem(str)
            end
        end
    )

    self:addEditor(
        "人物经验设定",
        "经验值",
        function(editBox, text)
            local str = string.trim(text)

            if tonumber(str) == nil then
                PopText("填写非数字")
                return
            end

            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player:setAttr("exp", tonumber(str))
        end
    )

    self:addEditor(
        "当前房间添加NPC",
        "npcid",
        function(editBox, text)
            local str = string.trim(text)

            local map = Map:getCurrMap()

            local player = map:getPlayer()

            map:addRoomRole(map:getCurrRoomId(), str)
            map.__MapLayer:delayRefreshMap()
        end
    )

    self:addEditor(
        "南柯梦境角色设置技能经验",
        "技能id;经验值|技能id;经验值",
        function(editBox, text)
            local str = text

            local function setSkillExp(str1)
                local skillId, skillExp
                if string.find(str1, ";") then
                    skillId = string.split(str1, ";")[1]
                    skillExp = tonumber(string.split(str1, ";")[2])
                else
                    skillId = str1
                    skillExp = 1
                end
                local map = Map:getCurrMap()
                local player = map:getPlayer()

                skillExp = math.min(skillExp, player:conversionSkillExpAndLv("exp", player:getSkillLvLimit(skillId)))

                player:setSkill(skillId, {id = skillId, exp = tonumber(skillExp)})
                PopText("技能 ：" .. skillId .. " 经验设置为 " .. skillExp)
            end

            if string.find(str, "|") then
                local list = string.split(str, "|")
                for i, v in ipairs(list) do
                    setSkillExp(v)
                end
            else
                setSkillExp(str)
            end
        end
    )

    self:addEditor(
        "南柯梦境提升招式重数",
        "招式id;重数|招式id;重数",
        function(editBox, text)
            local str = text

            local function addZhaoLv(str1)
                local zhaoId, addLv
                if string.find(str1, ";") then
                    zhaoId = string.split(str1, ";")[1]
                    addLv = tonumber(string.split(str1, ";")[2])
                else
                    zhaoId = str1
                    addLv = 1
                end
                local map = Map:getCurrMap()
                local player = map:getPlayer()
                local currLv = player:getSkillZhaoLv(zhaoId)
                local maxLv = player:getZhaoLvLimit(zhaoId)
                if currLv >= maxLv then
                    PopText(zhaoId .. "已练至最高重数")
                    return
                end
                addLv = math.min(maxLv - currLv, addLv)
                currLv = currLv + addLv
                local exp = player:conversionZhaoExpAndLv("exp", currLv, player:getSkillZhaoPotEfficiency(zhaoId))

                local roleSkillZhao = {id = zhaoId, exp = exp}
                player:setSkillZhao(zhaoId, roleSkillZhao)
                PopText(zhaoId .. "提升了" .. addLv .. "重")
            end
            if string.find(str, "|") then
                local zhaoIdList = string.split(str, "|")
                for i, v in ipairs(zhaoIdList) do
                    addZhaoLv(v)
                end
            else
                addZhaoLv(str)
            end
        end
    )
end

function TestFuncLayer:addDreamVersion()
    self.ListView:removeAllItems()
    local role = User:getRole()

    local drSystem = require("app.models.DreamWorldModel.DreamSystem"):create(role)

    self:addEditor(
        "进入梦境",
        "梦境层数;门派模板;属性模板",
        function(editBox, text)
            local floorNum, sectMobanId, attrMobanId
            local Str = string.split(text, ";")
            floorNum = tonumber(Str[1])
            sectMobanId = tonumber(Str[2])
            attrMobanId = tonumber(Str[3])
            print("floorNum = ", floorNum, "sectMobanId = ", sectMobanId, "attrMobanId = ", attrMobanId)
            if floorNum == nil or floorNum <= 0 then
                PopText("请输入正确的层数")
                return
            end

            local addPijuanFunc = function(addValue)
                if addValue == 0 or type(addValue) ~= "number" then
                    return
                end
                local role = User:getRole()
                role:addAttr("pijuan", addValue)
                local text
                if addValue > 0 then
                    text = "随着梦境的深入，疲倦值增加" .. tostring(addValue) .. "点"
                else
                    text = "随着梦境的深入，疲倦值扣除" .. tostring(math.abs(addValue)) .. "点"
                end
                PopText(text)
            end

            local DreamRoleModel = require("app.models.DreamWorldModel.DreamRoleModel")
            PopupLayerController:showLayer(
                "DreamEntryLayer",
                function(layer)
                    local role = drSystem:createNewDreamRole(attrMobanId, sectMobanId)
                    role.dreamPoints = role.dreamPoints + User:getRole():getFinalAttr("drRoleMoneyAdd")
                    role.weight = role.weight + User:getRole():getFinalAttr("drRoleWeightAdd")
                    User:getRole():dispatchEvent("CreateNewDrPlayerEvent", {role = role})
                    layer:showLayer(
                        MAP_TYPE.FONDDREAMMAP,
                        function()
                            --上传服务器
                            DreamRoleModel:uploadDreamRole(
                                role:getTrimData(),
                                function(errcode, errmsg, data)
                                    if errcode == 0 then
                                        role.dreamWorld.eFloor = floorNum

                                        addPijuanFunc(data.addPijuan)
                                        if floorNum == 1 then
                                            drSystem:enterNewMap(role)
                                        else
                                            drSystem:enterMap(floorNum, role)
                                        end
                                        return true
                                    elseif errcode == 2 then
                                        --@desc 数据有变动，需重新创建
                                        role:destory()
                                        role = drSystem:createDreamRoleWithData(data)
                                        role.dreamWorld.eFloor = floorNum

                                        addPijuanFunc(data.addPijuan)
                                        if floorNum == 1 then
                                            drSystem:enterNewMap(role)
                                        else
                                            drSystem:enterMap(floorNum, role)
                                        end
                                        return true
                                    else
                                        PopText(errmsg)
                                        return false
                                    end
                                end
                            )
                        end
                    )
                    layer:setAfterFunc(
                        function()
                            local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
                            DreamTalentModel:unlockActiveTalent(User:getRole())

                            drSystem:showFloorSettleLayer(floorNum, User:getRole():getCurrMap())
                        end
                    )
                end
            )

            self:setVisible(false)
            -- self:hide()
        end
    )

    self:addEditor(
        "设置梦境门派模板权重",
        "门派1,权重1（emei,50）;门派2,权重2",
        function(editBox, text)
            local Str = string.split(text, ";")

            local debug_data = User:getRole():getDayFlag("DreamFamilyWeight")

            if debug_data == 0 then
                debug_data = {}
            end

            for k, v in pairs(Str) do
                local info = string.split(v, ",")

                local familyId = info[1]

                local weight = tonumber(info[2])

                debug_data[familyId] = weight
            end

            User:getRole():setDayFlag("DreamFamilyWeight", debug_data)
        end
    )

    self:addButton(
        "设置所有梦境门派模板权重为零",
        function()
            local dreamLeadrole = require("script.dreamworld.dreamLeadrole")

            local RoleSkillTab = dreamLeadrole["主角门派"]

            local debug_data = User:getRole():getDayFlag("DreamFamilyWeight")

            if debug_data == 0 then
                debug_data = {}
            end

            for k, v in pairs(RoleSkillTab) do
                debug_data[v.family] = 0
            end

            User:getRole():setDayFlag("DreamFamilyWeight", debug_data)
        end
    )

    self:addButton(
        "进入未完成梦境",
        function()
            local DreamRoleModel = require("app.models.DreamWorldModel.DreamRoleModel")
            DreamRoleModel:getDreamRoleFromWeb(
                function(roleData)
                    local role
                    local floorNum = 1
                    if roleData == nil then
                        PopText("没有未完成梦境")
                    else
                        --@desc 有数据，接上次数据继续未完梦境
                        role = drSystem:createDreamRoleWithData(roleData)
                        floorNum = Helper:getDef(role.dreamWorld.cFloor, 1)
                        PopupLayerController:showLayer(
                            "DreamEntryLayer",
                            function(layer)
                                layer:showLayer(
                                    MAP_TYPE.FONDDREAMMAP,
                                    function()
                                        drSystem:enterMap(floorNum, role)
                                    end
                                )
                            end
                        )
                    end
                    self:setVisible(false)
                    self:hide()
                end
            )
        end
    )

    self:addButton(
        "梦境币+10000",
        function()
            HttpManagerEx:updateCurrencyByType(
                "add",
                "dreamCoins",
                10000,
                nil,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("梦境币+" .. tostring(data.dreamCoins))
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
    self:addButton(
        "完成梦境前置",
        function()
            User:getRole():setFlag("drqianzhi", 1)
            PopText("完成梦境前置")
        end
    )
    self:addButton(
        "重置梦境前置任务进度",
        function()
            User:getRole():setFlag("drqianzhi", nil)
            PopText("重置梦境前置任务进度")
        end
    )
    self:addButton(
        "梦境流程开始按钮",
        function()
            local DreamWorldPreConditionUtils = require("app.models.DreamWorldModel.DreamWorldPreConditionUtils")
            if DreamWorldPreConditionUtils:checkCanOpenPreTask() then
                local state = DreamWorldPreConditionUtils:checkCanToHome()
                if state == 2 then
                    self:setVisible(false)
                    self:hide()
                    DreamWorldPreConditionUtils:goHome()
                elseif state == 0 then
                    self:setVisible(false)
                    self:hide()
                    DreamWorldPreConditionUtils:startPreTask()
                elseif state == 1 then
                    PopText("少侠尚且未有家园，听闻华山村北石室的石床亦可入梦。")
                end
            end
        end
    )

    self:addEditor(
        "梦境角色加buff",
        "buff id",
        function(editBox, text)
            local buffId = tonumber(text)
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player:addBuffV2(buffId)
        end
    )

    self:addButton(
        "梦境角色添加所有BUFF",
        function()
            local BuffData = require("script.Buff.BuffAll")["buff"]

            local map = Map:getCurrMap()

            local player = map:getPlayer()

            for k, v in pairs(BuffData) do
                player:addBuffV2(v.id)
            end
        end
    )

    self:addButton(
        "梦境角色删除所有buff",
        function()
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player._buffManager:removeAllBuff()
        end
    )

    self:addButton(
        "打印梦境角色buff信息",
        function()
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            print("=============== start print =========================")
            player._buffManager:printBuffsInfo()
            print("=============== end print ========================= \n")
        end
    )

    self:addButton(
        "打印玩家buff信息",
        function()
            local role = User:getRole()

            print("=============== start print =========================")
            role._buffManager:printBuffsInfo()
            print("=============== end print ========================= \n")
        end
    )
    self:addEditor(
        "添加入梦buff",
        "buff id",
        function(editBox, text)
            local buffId = tonumber(text)
            local role = User:getRole()
            local AsleepBuff = {
                {
                    id = buffId,
                    startTime = GetTime()
                }
            }
            role:setAttr("AsleepBuff", AsleepBuff)
            role:updateRoleBuff()

            Helper:print_lua_table(role._roleBuff)
        end
    )

    self:addEditor(
        "查询梦境主角最终属性",
        "属性代号",
        function(editBox, text)
            local attrId = tonumber(text)
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            local attrName = AttrName[attrId]

            local value
            if attrId > 1200 then
                value = player:getBaseAttr(attrName)
            else
                value = player:getFinalAttr(attrName)
            end

            print(value)

            PopText(attrName .. " : " .. value)
        end
    )

    self:addEditor(
        "查询玩家最终属性",
        "属性代号",
        function(editBox, text)
            local attrId = tonumber(text)

            local player = User:getRole()

            local attrName = AttrName[attrId]

            local value
            if attrId > 1200 then
                value = player:getAttr(attrName)
            else
                value = player:getFinalAttr(attrName)
            end

            print(value)

            PopText(attrName .. " : " .. value)
        end
    )

    self:addButton(
        "清除梦境入梦buff",
        function()
            User:getRole():setAttr("AsleepBuff", {})
            PopText("清除成功")
        end
    )
    self:addButton(
        "清除梦境天赋",
        function()
            User:getRole():setAttr("PrepareTalent", {})
            local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
            local DreamTalent = User:getRole():getAttr("DreamTalent")
            for talentId, v in pairs(DreamTalent) do
                local talent = DreamTalentModel:getTalentAttrById(talentId)
                if talent.drbuffid and talent.drbuffid ~= 0 and talent.talentType == 1 then
                    print("清除 buff = ", talent.drbuffid)
                    User:getRole():removeBuffV2(talent.drbuffid)
                end
            end
            User:getRole():setAttr("DreamTalent", {})
            PopText("清除成功")
        end
    )

    self:addButton(
        "梦境角色增加经验+100000",
        function()
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player:addAttr("exp", 100000)
        end
    )

    self:addButton(
        "梦境角色臂力20",
        function()
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player:addAttr("str", 20)
        end
    )

    self:addButton(
        "梦境角色根骨20",
        function()
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player:addAttr("con", 20)
        end
    )

    self:addButton(
        "梦境角色身法20",
        function()
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player:addAttr("dex", 20)
        end
    )

    self:addButton(
        "梦境角色清醒值加5",
        function()
            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player:addAttr("sober", 5)

            print("当前清醒值 = ", player:getAttr("sober"))
        end
    )

    self:addButton(
        "梦境角色增加neiLiLimit 1000",
        function()
            -- local map = Map:getMapById("drFloor_" .. 1)
            local map = Map:getCurrMap()
            local player = map:getPlayer()

            player:addAttr("neiLiLimit", 1000)
            player:addAttr("qiMax", 1000)
        end
    )

    self:addEditor(
        "疲倦值设定",
        "0",
        function(editBox, text)
            local value = tonumber(text)
            local player = User:getRole()
            player:setAttr("pijuan", value)
            PopText("疲倦值设定为" .. value)
        end
    )

    self:addButton(
        "玩家当前疲倦值打印",
        function()
            local role = User:getRole()
            local pijuan = role:getAttr("pijuan")
            print("当前疲倦值" .. pijuan)
            PopText("当前疲倦值" .. pijuan)
        end
    )

    self:addButton(
        "情绪切换",
        function()
            -- local map = Map:getMapById("drFloor_" .. 1)
            local map = Map:getCurrMap()
            local player = map:getPlayer()

            self.ListView:removeAllItems()

            local list = {}
            local DreamConst = require("app.models.DreamWorldModel.DreamConst")

            for k, v in pairs(DreamConst.EmotionType) do
                table.insert(list, v)
            end

            table.sort(
                list,
                function(a, b)
                    return a > b
                end
            )

            local Emotion = require("script.dreamworld.Emotion")
            local EmotionData = Emotion["emotion"]

            for i = 1, #list do
                local id = list[i]
                self:addButton(
                    EmotionData[tostring(id)].name,
                    function()
                        player.emotionMgr:changeEmotion(id)
                    end
                )
            end

            self:addButton(
                "返回",
                function()
                    self:addDreamVersion()
                end
            )
        end
    )

    self:addEditor(
        "梦境角色增加物品",
        "物品id;数量|物品id;数量",
        function(editBox, text)
            local str = text
            print("str = ", str)
            local map = Map:getCurrMap()
            local player = map:getPlayer()

            local function addItem(str1)
                local itemId, count
                if string.find(str1, ";") then
                    itemId = string.split(str1, ";")[1]
                    count = tonumber(string.split(str1, ";")[2])
                else
                    itemId = str1
                    count = 1
                end
                print("itemId = ", itemId, "count = ", count)
                player:addItemCount(itemId, count)
            end

            if string.find(str, "|") then
                local list = string.split(str, "|")
                for i, v in ipairs(list) do
                    addItem(v)
                end
            else
                addItem(str)
            end
        end
    )

    self:addEditor(
        "人物经验设定",
        "经验值",
        function(editBox, text)
            local str = string.trim(text)

            if tonumber(str) == nil then
                PopText("填写非数字")
                return
            end

            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player:setAttr("exp", tonumber(str))
        end
    )

    self:addEditor(
        "梦境相关效果触发",
        "效果编号",
        function(editBox, text)
            local str = string.trim(text)

            if tonumber(str) == nil then
                PopText("填写非数字")
                return
            end

            local map = Map:getCurrMap()

            local player = map:getPlayer()

            local DreamEffects = require("app.models.DreamWorldModel.DreamEffects")

            DreamEffects:triggerEffect(str, {role = player, map = map, roomId = map:getCurrRoomId()})
        end
    )

    self:addEditor(
        "当前房间添加NPC",
        "npcid",
        function(editBox, text)
            local str = string.trim(text)

            local map = Map:getCurrMap()

            local player = map:getPlayer()

            map:addRoomRole(map:getCurrRoomId(), str)
            map.__MapLayer:delayRefreshMap()
        end
    )

    self:addEditor(
        "直接触发随机事件",
        "事件id",
        function(editBox, text)
            local EmotionData = require("script.dreamworld.Emotion")

            local randomEvents = EmotionData.randomEvents

            local event = randomEvents[text]

            if event == nil then
                PopText("没有该事件")
                return
            end

            PopText("触发事件：" .. event.id)

            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player.emotionMgr:_triggerEffect(event.effects, {role = player, map = map, roomId = map:getCurrRoomId()})
            RichPrint("main", event.text)
        end
    )
    self:addEditor(
        "直接触发开箱事件",
        "事件id",
        function(editBox, text)
            local EmotionData = require("script.dreamworld.Emotion")

            local boxEvents = EmotionData.boxOpenEvents

            local event = boxEvents[text]

            if event == nil then
                PopText("没有该事件")
                return
            end

            PopText("触发事件：" .. event.id)

            local map = Map:getCurrMap()

            local player = map:getPlayer()

            player.emotionMgr:_triggerEffect(event.effects, {role = player, map = map, roomId = map:getCurrRoomId()})
            RichPrint("main", event.text)
        end
    )
    self:addButton(
        "梦境楼层生成npc重复检测",
        function()
            for i = 1, 50 do
                print("=============== 生成第" .. i .. " 层=================")

                local npc_dict = {}

                local map = drSystem:createMap(i)

                local rooms = map.room

                for roomId, room in pairs(rooms) do
                    local roleList = room.roleList
                    for i, npcId in ipairs(roleList) do
                        if npc_dict[npcId] == nil then
                            npc_dict[npcId] = {
                                count = 0,
                                roomIds = {},
                                roomTypes = {},
                                drEventIds = {}
                            }
                        end

                        npc_dict[npcId].count = npc_dict[npcId].count + 1
                        table.insert(npc_dict[npcId].roomIds, roomId)
                        table.insert(npc_dict[npcId].roomTypes, room.roomType)
                        table.insert(npc_dict[npcId].drEventIds, room.drEventId)
                    end
                end

                local repetitive_npc = {}
                for npcId, info in pairs(npc_dict) do
                    if info.count > 1 then
                        table.insert(repetitive_npc, {npcId, info})
                    end
                end

                if #repetitive_npc > 0 then
                    Helper:print_lua_table(repetitive_npc)
                else
                    print("没有重复NPC生成")
                end
            end
        end
    )

    self:addEditor(
        "梦境角色设置技能经验",
        "技能id;经验值|技能id;经验值",
        function(editBox, text)
            local str = text

            local function setSkillExp(str1)
                local skillId, skillExp
                if string.find(str1, ";") then
                    skillId = string.split(str1, ";")[1]
                    skillExp = tonumber(string.split(str1, ";")[2])
                else
                    skillId = str1
                    skillExp = 1
                end
                local map = Map:getCurrMap()
                local player = map:getPlayer()

                skillExp = math.min(skillExp, player:conversionSkillExpAndLv("exp", player:getSkillLvLimit()))

                player:setSkill(skillId, {id = skillId, exp = tonumber(skillExp)})
                PopText("技能 ：" .. skillId .. " 经验设置为 " .. skillExp)
            end

            if string.find(str, "|") then
                local list = string.split(str, "|")
                for i, v in ipairs(list) do
                    setSkillExp(v)
                end
            else
                setSkillExp(str)
            end
        end
    )

    self:addEditor(
        "梦境招式重数",
        "招式id;经验值|招式id;经验值",
        function(editBox, text)
            local str = text
            local function addZhaoExp(str1)
                local zhaoId, addExp
                if string.find(str1, ";") then
                    zhaoId = string.split(str1, ";")[1]
                    addExp = tonumber(string.split(str1, ";")[2])
                else
                    zhaoId = str1
                    addExp = 1
                end
                local map = Map:getCurrMap()
                local player = map:getPlayer()
                player:addSkillZhaoExp(zhaoId, addExp)
            end
            if string.find(str, "|") then
                local zhaoIdList = string.split(str, "|")
                for i, v in ipairs(zhaoIdList) do
                    addZhaoExp(v)
                end
            else
                addZhaoExp(str)
            end
        end
    )
end

function TestFuncLayer:addCreatedSkill()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton(
        "控制台查看已学自创武学数据",
        function()
            local role = User:getRole()

            local allSelfCreatedSkills = role:getSelfCreatedSkillSystem():getCreatedSkillData()

            if MapIsEmpty(allSelfCreatedSkills) == false then
                print("------------------------- 已学自创武学 ---------------------------")
                for skillId, skillInfo in pairs(allSelfCreatedSkills) do
                    print(" 技能id：" .. skillId .. "  名称：" .. skillInfo.name)
                end
                print("-------------------------------------------------------------\n")
            else
                PopText("你没有任何自创武学")
            end
        end
    )

    self:addButton(
        "查看正在创建的武学id",
        function()
            local role = User:getRole()
            local skill = role:getSelfCreatedSkillSystem():getSelfCreatingSkill()
            if skill:getId() ~= nil then
                print("正在自创的武学ID : " .. skill:getId())
            else
                PopText("你暂无自创中的武学")
            end
        end
    )

    self:addButton(
        "查看已创建完成的武学书籍",
        function()
            local role = User:getRole()
            local books = role:getSelfCreatedSkillSystem():getBooks()

            if MapIsEmpty(books) == false then
                print("------------------------- 已创建完成的书籍 ---------------------------")
                Helper:print_lua_table(books)
                print("-------------------------------------------------------------\n")
            else
                PopText("")
            end
        end
    )

    self:addEditor(
        "未完成武学或已完成书籍添加武学招式",
        "武学id;增加招式数量",
        function(editBox, text)
            local strs = string.split(text, ";")

            local skillId = strs[1]

            local num = strs[2]

            if skillId == nil or skillId == "" then
                PopText("技能ID填写错误")
                return
            end

            if tonumber(num) == nil or tonumber(num) <= 0 then
                PopText("招数数量填写错误")
                return
            end

            HttpManagerEx:testAddZhaoNum(
                skillId,
                num,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("添加成功。")
                    else
                        PopText(errmsg .. ":" .. errcode)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addEditor(
        "清除已学书籍的学习状态",
        "技能ID",
        function(editBox, text)
            local skillId = Helper:getDef(tonumber(text), 0)
            HttpManagerEx:testClearBook(
                skillId,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        local role = User:getRole()
                        local allSelfCreatedSkills = role:getSelfCreatedSkillSystem():getCreatedSkillData()

                        allSelfCreatedSkills[skillId] = nil

                        PopText("清除成功。")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "清除已学习的自创武学数据",
        function()
            local role = User:getRole()
            role:deleteSelfCreatedSkillData()
            role:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()
        end
    )

    self:addButton(
        "清除所有自创武学书籍",
        function()
            HttpManagerEx:testDeleteBook(
                3,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("删除成功")

                        return true
                    else
                        PopText(errmsg)
                        return false
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "开启神功系统",
        function()
            local role = User:getRole()
            role:getSelfCreatedSkillSystem():openSystem()
        end
    )

    self:addButton(
        "关闭自创武学系统",
        function()
            local role = User:getRole()
            role:getSelfCreatedSkillSystem():closeSystem()
        end
    )

    self:addButton(
        "地宫古迹任务修改",
        function()
            self:addDiGongTask()
        end
    )

    self:addButton(
        "添加自创武学道具",
        function()
            self:propBtn()
        end
    )

    self:addButton(
        "查看自创武学招式动画",
        function()
            self:selfCreatedZhaoAnim()
        end
    )
    self:addButton(
        "检查招式名称词库",
        function()
            local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
            local zhaoNameMap = SelfCreatedSkillManager:getZhaoNameMap()
            local randomResult = {
                {"words1", "words2"},
                {"words1", "words1", "words2"},
                {"words1", "words1", "words1", "words2"},
                {"words3", "words2"},
                {"words1", "words3", "words2"},
                {"words3", "words1", "words2"},
                {"words3", "words3", "words2"},
                {"words1", "words3"}
            }
            local maskOffList = {}
            for index, result in ipairs(randomResult) do
                local name1s, name2s, name3s, name4s = {}, {}, {}, {}
                if result[1] then
                    name1s = zhaoNameMap[result[1]]
                end
                if result[2] then
                    name2s = zhaoNameMap[result[2]]
                end
                if result[3] then
                    name3s = zhaoNameMap[result[3]]
                end
                if result[4] then
                    name4s = zhaoNameMap[result[4]]
                end
                local name = ""

                for i1, v1 in ipairs(name1s) do
                    name = v1
                    for i2, v2 in ipairs(name2s) do
                        name = v1 .. v2
                        if MapIsEmpty(name3s) == false then
                            for i3, v3 in ipairs(name3s) do
                                name = v1 .. v2 .. v3
                                if MapIsEmpty(name4s) == false then
                                    for i4, v4 in ipairs(name4s) do
                                        name = v1 .. v2 .. v3 .. v4
                                        print("规则 = ", result[1] .. result[2] .. result[3] .. result[4], "v1 = ", v1, "v2 = ", v2, "v3 = ", v3, "v4 = ", v4, "name = ", name)
                                        if Helper:isMaskOff(name) then
                                            table.insert(maskOffList, select(2, Helper:isMaskOff(name)))
                                        end
                                    end
                                else
                                    print("规则 = ", result[1] .. result[2] .. result[3], "v1 = ", v1, "v2 = ", v2, "v3 = ", v3, "name = ", name)
                                    if Helper:isMaskOff(name) then
                                        table.insert(maskOffList, select(2, Helper:isMaskOff(name)))
                                    end
                                end
                            end
                        else
                            print("规则 = ", result[1] .. result[2], "v1 = ", v1, "v2 = ", v2, "name = ", name)
                            if Helper:isMaskOff(name) then
                                table.insert(maskOffList, select(2, Helper:isMaskOff(name)))
                            end
                        end
                    end
                end
            end
            print("------------------招式名称屏蔽词-------------------")
            Helper:print_lua_table(maskOffList)
            print("------------------end-------------------")
        end
    )

    self:addButton(
        "检查武学名称词库",
        function()
            local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
            local skillNameMap = SelfCreatedSkillManager:getSkillNameMap()
            local randomResult = {
                {"words1", "words2"},
                {"words1", "words3"},
                {"words2", "words3"},
                {"words3", "words1", "words2"},
                {"words3"}
            }
            local maskOffList = {}
            for index, result in ipairs(randomResult) do
                local name1s, name2s, name3s = {}, {}, {}
                if result[1] then
                    name1s = skillNameMap[result[1]]
                end
                if result[2] then
                    name2s = skillNameMap[result[2]]
                end
                if result[3] then
                    name3s = skillNameMap[result[3]]
                end
                local name = ""

                for i1, v1 in ipairs(name1s) do
                    name = v1
                    if MapIsEmpty(name2s) == false then
                        for i2, v2 in ipairs(name2s) do
                            name = v1 .. v2
                            if MapIsEmpty(name3s) == false then
                                for i3, v3 in ipairs(name3s) do
                                    name = v1 .. v2 .. v3
                                    print("规则 = ", result[1] .. result[2] .. result[3], "v1 = ", v1, "v2 = ", v2, "v3 = ", v3, "name = ", name)
                                    if Helper:isMaskOff(name) then
                                        table.insert(maskOffList, select(2, Helper:isMaskOff(name)))
                                    end
                                end
                            else
                                print("规则 = ", result[1] .. result[2], "v1 = ", v1, "v2 = ", v2, "name = ", name)
                                if Helper:isMaskOff(name) then
                                    table.insert(maskOffList, select(2, Helper:isMaskOff(name)))
                                end
                            end
                        end
                    else
                        print("规则 = ", result[1], "v1 = ", v1, "name = ", name)
                        if Helper:isMaskOff(name) then
                            table.insert(maskOffList, select(2, Helper:isMaskOff(name)))
                        end
                    end
                end
            end
            print("------------------武学名称屏蔽词-------------------")
            Helper:print_lua_table(maskOffList)
            print("------------------end-------------------")
        end
    )

    self:addButton(
        "清除每日创作上限缓存",
        function()
            HttpManagerEx:deleteCreateBookDayLimit(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("删除成功")

                        return true
                    else
                        PopText(errmsg)
                        return false
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )
end

function TestFuncLayer:addDiGongTask()
    self.ListView:removeAllItems()
    local SelfCreatedSkillTaskModel = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillTask.SelfCreatedSkillTaskModel")
    local acceptConfig = {
        task_id = "task22",
        start_time = GetTime(),
        finish_time = 0,
        end_time = 0,
        state = TASK_STATE_ACCEPT,
        dcount = 0,
        extra = {
            gujiPoint = 0,
            roleLv = User:getRole():getLv(),
            luck = Helper:mathFloor(User:getRole():getFinalAttr("luck")),
            kongfu = Helper:mathFloor(User:getRole():getKongfu()),
            exp = Helper:mathFloor(User:getRole():getAttr("exp"))
        }
    }

    local completeConfig = {
        task_id = "task22",
        finish_time = GetTime(),
        end_time = 0,
        state = TASK_STATE_TO_SUBMIT,
        dcount = 0,
        extra = {
            gujiPoint = 0,
            roleLv = User:getRole():getLv(),
            luck = Helper:mathFloor(User:getRole():getFinalAttr("luck")),
            kongfu = Helper:mathFloor(User:getRole():getKongfu()),
            exp = Helper:mathFloor(User:getRole():getAttr("exp"))
        }
    }

    local submitConfig = {
        task_id = "task22",
        start_time = GetTime(),
        finish_time = GetTime(),
        end_time = GetTime(),
        state = TASK_STATE_COMPLETE,
        dcount = 1,
        extra = {
            gujiPoint = 100,
            roleLv = User:getRole():getLv(),
            luck = Helper:mathFloor(User:getRole():getFinalAttr("luck")),
            kongfu = Helper:mathFloor(User:getRole():getKongfu()),
            exp = Helper:mathFloor(User:getRole():getAttr("exp"))
        }
    }

    local updateTask = function(updateInfo)
        HttpManagerEx:testUpdateTask(
            "task22",
            updateInfo,
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    PopText("更新成功！")

                    SelfCreatedSkillTaskModel:__updateTaskInfo(updateInfo)

                    return true
                else
                    PopText(errmsg)
                    return false
                end
            end,
            IS_SHOW_WAITING
        )
    end

    self:addButton(
        "任务清零",
        function()
            local config = clone(acceptConfig)
            config.start_time = 0
            config.state = TASK_STATE_IDLE
            User:getRole():setFlag("digongguji", 0)
            updateTask(config)
        end
    )

    self:addButton(
        "接取任务",
        function()
            updateTask(acceptConfig)
        end
    )

    self:addButton(
        "接取任务（接取时间提前1天）",
        function()
            local config = clone(acceptConfig)
            config.start_time = GetTime() - 3600 * 24
            updateTask(config)
        end
    )

    self:addEditor(
        "完成任务并设置地宫积分",
        "0",
        function(editBox, text)
            local point = Helper:getDef(tonumber(text), 0)

            local role = User:getRole()

            local task = role:getTask("task22")

            if task.state == TASK_STATE_IDLE then
                PopText("先接取任务")
                return
            end

            local config = clone(completeConfig)

            config.extra.gujiPoint = point

            updateTask(config)
        end
    )

    self:addButton(
        "完成任务(完成时间提前1天)",
        function(editBox, text)
            local role = User:getRole()

            local task = role:getTask("task22")

            if task.state ~= TASK_STATE_ACCEPT then
                PopText("先接取任务")
                return
            end

            local config = clone(completeConfig)

            config.start_time = GetTime() - 3600 * 24 - 60

            config.finish_time = GetTime() - 3600 * 24

            config.extra.gujiPoint = 1

            updateTask(config)
        end
    )

    self:addButton(
        "提交任务",
        function()
            SelfCreatedSkillTaskModel:submitTask(
                function(result, taskInfo, rewards)
                    if result == 0 then
                        local clientReward = rewards.client
                        local role = User:getRole()
                        if MapIsEmpty(clientReward.attrs) == false then
                            for attrName, value in pairs(clientReward.attrs) do
                                if value > 0 then
                                    PopText(role:getCHAttrName(attrName) .. " +" .. value)
                                end
                            end
                        end

                        local serverReward = rewards.server

                        if MapIsEmpty(serverReward.currency) == false then
                            for currencyName, value in pairs(serverReward.currency) do
                                if value > 0 then
                                    PopText(role:getCHAttrName(currencyName) .. " +" .. value)
                                end
                            end
                        end

                        local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
                        if MapIsEmpty(serverReward.selfCreatedItems) == false then
                            for itemId, count in pairs(serverReward.selfCreatedItems) do
                                if tonumber(count) > 0 then
                                    PopText(SelfCreatedSkillManager:getPropMap(itemId).name .. " +" .. tostring(count))
                                end
                            end
                        end
                    elseif result == 1 then
                        PopText("任务已提交，无需重复提交。")
                    elseif result == 2 then
                        PopText("提交失败，任务未接取。")
                    elseif result == 3 then
                        PopText("提交失败，任务尚未完成。")
                    elseif result == 4 then
                        PopText("提交失败，该任务已超过提交时间。")
                    end
                end
            )
        end
    )

    self:addButton(
        "提交任务(时间提前1天，无奖励获得)",
        function()
            local config = clone(submitConfig)
            config.start_time = GetTime() - 3600 * 24 - 120
            config.finish_time = GetTime() - 3600 * 24 - 60
            config.end_time = GetTime() - 3600 * 24
            updateTask(config)

            PopText("提交时间设置为 ：" .. Helper:getTimeStrCNFormat(config.end_time))
        end
    )

    self:addButton(
        "返回",
        function()
            self:addCreatedSkill()
        end
    )
end

function TestFuncLayer:propBtn()
    self.ListView:removeAllItems()
    local PropMap = require("script.selfCreatedSkill.propMap")["Sheet1"]
    for k, v in pairs(PropMap) do
        self:addEditor(
            "修改" .. v.name.."数量",
            "数量",
            function(editBox, text)
                local num = tonumber(text)

                if not num then
                    PopText("数量异常！！！")
                    return
                end

                HttpManagerEx:addProp(
                    v.id,
                    num,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                PopText("添加成功")
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
        )
    end
end

function TestFuncLayer:newBattle()
    local FightUtil = require("app.FightSystem.FightUtil.FightUtil")
    self.ListView:removeAllItems()

    self:addEditor(
        "播放新版动画资源",
        "输入开始播放序号,默认为1",
        function(editBox, text)
            if text == nil or text == "" then
                text = 1
            end

            local animIndex = tonumber(text)

            PopupLayerController:showLayer(
                "AnimTestLayer",
                function(layer)
                    local animRes = require("script.newbattle.demo.animRes")["动画资源"]
                    local anims = {}

                    for k, v in pairs(animRes) do
                        if v.altlasPath == "Anim/gongfu1/gongfu" then
                            table.insert(anims, v)
                        end
                    end
                    table.sort(
                        anims,
                        function(a, b)
                            return tonumber(a.id) < tonumber(b.id)
                        end
                    )
                    
                    layer:setIndex(animIndex)
                    layer:setAnimList(anims)
                    layer:showLayer()
                end
            )
        end
    )

    self:addEditor(
        "播放旧版动画资源",
        "输入开始播放序号,默认为1",
        function(editBox, text)
            if text == nil or text == "" then
                text = 1
            end

            local animIndex = tonumber(text)

            PopupLayerController:showLayer(
                "AnimOldFightTestLayer",
                function(layer) 
                    local anims = require("app.views.layer.DebugLayer.testOldFightAnimRes")
                    layer:setIndex(animIndex)
                    layer:setAnimList(anims)
                    layer:showLayer()
                end
            )
        end
    )

    -- self:addButton(
    --     "检查被动招式动画资源",
    --     function()
    --         local skillRes = require("script.newbattle.demo.skillRes")["武学"]
    --         local AutoZhaoFactory = require("app.FightSystem.Factory.FightSkillFactory.AutoZhaoFactory")
    --         local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")
    --         local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")
    --         local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")
    --         local AnimResInfo = AnimResManager:getAnimResInfo()
    --         print("-----------------------检查开始---------------------")
    --         for k, v in pairs(skillRes) do
    --             local skillId = v.id
    --             local skill = SkillFactory:createSkill(skillId)
    --             if skill:isAttackSkill() == true then
    --                 local weaponTypes = skill:getWeaponTypes()

    --                 local autoZhaoCombs = skill:getAutoZhaoCombs()

    --                 for i, autoZhaoComb in ipairs(autoZhaoCombs) do
    --                     local animResIds = {}
    --                     local zhaoinfoList = autoZhaoComb:getAtkList()

    --                     for index, zhaoinfo in ipairs(zhaoinfoList) do
    --                         local animResId = zhaoinfo:getAnimResId()

    --                         for i, weaponType in ipairs(weaponTypes) do
    --                             local weaponInfo = WeaponTypesResManager:getWeaponInfo(weaponType)
    --                             local weaponModule = weaponInfo.weaponModule

    --                             local attack_anim_info = AnimResInfo.attack_anim[tostring(animResId) .. "|" .. weaponModule]
    --                             if attack_anim_info == nil then
    --                                 local text =
    --                                     "武学:" .. skillId .. " " .. autoZhaoComb:getZhaoIdText() .. " 第" .. index .. "段攻击" .. " 无动画资源ID：" .. animResId .. " 武器模组： " .. weaponModule .. " 所对应的攻击动画"

    --                                 print(text)
    --                             end
    --                         end
    --                     end
    --                 end
    --             end
    --         end
    --         print("-----------------------检查结束---------------------")
    --     end
    -- )

    -- self:addButton(
    --     "检查主动招式动画资源",
    --     function()
    --         local skillRes = require("script.newbattle.demo.skillRes")["武学"]
    --         local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")
    --         local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")
    --         local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")
    --         local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")
    --         local AnimResInfo = AnimResManager:getAnimResInfo()
    --         print("-----------------------检查主动招式开始---------------------")
    --         local function checkFunc(skillId, zhaoinfo, typeText)
    --             local animResId = zhaoinfo:getAnimResId()
    --             local attack_anim_info = AnimResInfo.other_anim[tostring(animResId)]
    --             if attack_anim_info == nil then
    --                 local text = "武学:" .. skillId .. typeText .. " 主动招式动作id :" .. zhaoinfo:getId() .. " 无动画资源：" .. animResId .. "所对应的攻击动画"

    --                 print(text)
    --             end
    --         end

    --         local function checkIsAttackFunc(skillId, zhaoinfo, weaponTypes, typeText)
    --             local animResId = zhaoinfo:getAnimResId()

    --             for i, weaponType in ipairs(weaponTypes) do
    --                 local weaponInfo = WeaponTypesResManager:getWeaponInfo(weaponType)
    --                 local weaponModule = weaponInfo.weaponModule

    --                 local attack_anim_info = AnimResInfo.attack_anim[tostring(animResId) .. "|" .. weaponModule]
    --                 if attack_anim_info == nil then
    --                     local text = "武学:" .. skillId .. typeText .. " 主动招式动作id :" .. zhaoinfo:getId() .. " 无动画资源：" .. animResId .. " 武器模组： " .. weaponModule .. " 所对应的攻击动画"

    --                     print(text)
    --                 end
    --             end
    --         end

    --         for k, v in pairs(skillRes) do
    --             local skillId = v.id
    --             local skill = SkillFactory:createSkill(skillId)
    --             local weaponTypes = skill:getWeaponTypes()
    --             local actId_list = skill:getActiveZhaos()

    --             for _, actId in ipairs(actId_list) do
    --                 for lv = 1, 11 do
    --                     local activeSkillComb = ActiveFactory:createActiveZhaoComb(actId, lv)
    --                     local zhaoinfoList = activeSkillComb:getAtkList()
    --                     local readyZhaoInfo = activeSkillComb:getReadyZhao()
    --                     local isAttck = false
    --                     if #(activeSkillComb:getHurtIDs()) > 0 then
    --                         isAttck = true
    --                     end

    --                     if isAttck == false then
    --                         if readyZhaoInfo then
    --                             checkFunc(skillId, readyZhaoInfo, "  主动准备招式动作  ")
    --                         end
    --                         if #zhaoinfoList > 0 then
    --                             for index, zhaoinfo in ipairs(zhaoinfoList) do
    --                                 checkFunc(skillId, zhaoinfo, "  主动攻击招式动作组  ")
    --                             end
    --                         end
    --                     else
    --                         if readyZhaoInfo then
    --                             checkFunc(skillId, readyZhaoInfo, "  主动准备招式动作  ")
    --                         end
    --                         if #zhaoinfoList > 0 then
    --                             for index, zhaoinfo in ipairs(zhaoinfoList) do
    --                                 checkIsAttackFunc(skillId, zhaoinfo, weaponTypes, "  主动攻击招式动作组  ")
    --                             end
    --                         end
    --                     end
    --                 end
    --             end
    --         end
    --         print("-----------------------检查结束---------------------")
    --     end
    -- )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:hangUpTaskNewVersion()
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    local TestHangUpTaskUtil = require("app.models.Task2.TestHangUpTaskUtil")
    self:addButton(
        "根据当前状态重置挂机系统",
        function()
            TestHangUpTaskUtil:resetAllTasks()
        end
    )

    self:addButton(
        "打印当前挂机版本号",
        function()
            local role = User:getRole()

            --@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
            local hangUpSystem = role:getHangUpSystem()

            print(hangUpSystem:getVersion())
        end
    )

    self:addButton(
        "模拟挂机版本号异常",
        function()
            local num1 = math.random(1,100)
            local num2 = math.random(1,100)
            local version = num1.."SASDKALDKSALKDAFKLAJDSA"..num2

            TestHangUpTaskUtil:setHangUpVersion(version)

            print("version:",version)
        end
    )

    self:addButton(
        "设置固定挂机版本号",
        function()
            TestHangUpTaskUtil:setHangUpVersion("SASDKALDKSALKDAFKLAJDSA")

            print("version:SASDKALDKSALKDAFKLAJDSA")
        end
    )

    self:addButton(
        "设置当前挂机最大时长",
        function()
            TestHangUpTaskUtil:finishCurrTaskByMaxTime()
        end
    )

    self:addEditor(
        "增加当前挂机时长",
        "秒",
        function(editBox, text)
            local sec = tonumber(text)

            TestHangUpTaskUtil:addHangUpTaskTime(sec)
        end
    )

    self:addButton(
        "重置点击任务单日次数",
        function()
            TestHangUpTaskUtil:resetWorkTasksDailyCount()
        end
    )

    local function getTime(timeList)
        local month = tonumber(timeList[1])
        local day = tonumber(timeList[2])
        local hour = tonumber(timeList[3])
        local min = tonumber(timeList[4])
        if month == nil or month < 1 or month > 12 then
            error("月份格式不对 month = " .. month)
        end
        if day == nil or day < 1 or day > 31 then
            error("日期格式不对 day = " .. day)
        end
        if hour == nil or hour < 1 or hour > 24 then
            error("小时格式不对 hour = " .. hour)
        end
        if min == nil or min < 1 or min > 60 then
            error("分钟格式不对 min = " .. min)
        end

        local retTime = (os.time({year = 2021, month = month, day = day, hour = hour, min = min, sec = 0}) - Helper:getTimeZone())

        if os.date("*t", retTime).isdst then
            return retTime + 3600
        else
            return retTime
        end
    end

    self:addEditor(
        "上传雅士开始和结束时间数据",
        "开始:月,日,时,分;结束:月,日,时,分|开始:月,日,时,分;结束:月,日,时,分",
        function(editBox, text)
            local timesList = string.split(text, "|")
            local timeCount = #timesList
            for i = 1, timeCount do
                local time_str = string.split(timesList[i], ";")
                local strat_time_str = time_str[1]
                local end_time_str = time_str[2]

                local strat_time = getTime(string.split(strat_time_str, ","))
                local end_time = getTime(string.split(end_time_str, ","))
                print("------" .. i .. "------" .. "strat_time_str = ", strat_time_str, "end_time_str = ", end_time_str, "开始时间戳 = ", strat_time, "结束时间戳 = ", end_time)

                HttpManagerEx:testSetUpdateYaShiTime(
                    strat_time,
                    end_time,
                    function(status, errcode, errmsg, data)
                        if status == 200 and errcode == 0 then
                            PopText("上传成功了第" .. i .. "条")

                            return true
                        else
                            PopText(errmsg)
                            return false
                        end
                    end,
                    IS_SHOW_WAITING
                )
            end
        end
    )

    local function addYaShiTime(dayNum)
        if type(dayNum) ~= "number" then
            PopText("天数有误 dayNum = " .. dayNum)
            return
        end
        HttpManagerEx:getYaShiExpiredTime(
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    local endTime = data.yashi
                    if endTime == nil or endTime == 0 then
                        endTime = GetTime()
                    end
                    local strat_time = GetTime()
                    local end_Time = endTime + (dayNum * 24 * 60 * 60)
                    HttpManagerEx:testSetUpdateYaShiTime(
                        strat_time,
                        end_Time,
                        function(status, errcode, errmsg, data)
                            if status == 200 and errcode == 0 then
                                PopText("上传成功,增加" .. dayNum .. "天雅士")
                                User:getRole():updateYaShiStatus(end_Time)
                                return true
                            else
                                PopText(errmsg)
                                return false
                            end
                        end,
                        IS_SHOW_WAITING
                    )
                else
                    PopText(errmsg)
                    return false
                end
            end,
            IS_SHOW_WAITING
        )
    end
    self:addEditor(
        "增加雅士天数",
        "填天数",
        function(editBox, text)
            local dayNum = tonumber(text)
            addYaShiTime(tonumber(text))
        end
    )

    self:addButton(
        "增加雅士1天",
        function()
            addYaShiTime(1)
        end
    )

    self:addButton(
        "增加雅士3天",
        function()
            addYaShiTime(3)
        end
    )

    self:addButton(
        "增加雅士7天",
        function()
            addYaShiTime(7)
        end
    )

    self:addButton(
        "打印当前版本挂机信息",
        function()
            TestHangUpTaskUtil:viewHangUpDetail()
        end
    )

    self:addButton(
        "打印测试奖励",
        function()
            TestHangUpTaskUtil:testRewards()
        end
    )

    self:addButton(
        "打印测试开始挂机后奖励",
        function()
            TestHangUpTaskUtil:testCalAfterStartInfo()
        end
    )

    self:addButton(
        "打印测试挂机奖励计算",
        function()
            TestHangUpTaskUtil:testPlayerHangUpReward()
        end
    )

    self:addEditor(
        "历练任务提交测试",
        "任务id",
        function(editBox, text)
            local taskId = text
            local role = User:getRole()
            role:getLiLianTaskSystem():submitZhuDongTask(taskId)
        end
    )
end

function TestFuncLayer:fistFoot()
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton("选择特性效果",function()
        self.ListView:removeAllItems()

        self:addButton(
            "返回",
            function()
                self:fistFoot()
            end
        )

        local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")
        local FistFootConst = require("app.models.FistFootSystem.FistFootConst")
        local role = User:getRole()
        local list = role:getFistFootSystem():getBranchInfo()

        for type, v in pairs(list) do
            local name = SkillClassifyManager:getClassifyInfo(tostring(type)).thirdTypeName
            self:addButton(
                name,
                function()
                    self.ListView:removeAllItems()

                    self:addButton(
                        "返回",
                        function()
                            self:fistFoot()
                        end
                    )
                    
                    local techniqueList = role:getFistFootSystem():getTechniqueList(tostring(type))
                    
                    for k, technique in pairs(techniqueList) do
                        local basicTechnique = role:getFistFootSystem():getBasicFistFootTechnique(technique.id,technique.lv)
                        if basicTechnique:isEffect() == FistFootConst.TechniqueType.Special and technique.lv > 0 then
                            local techniqueName = basicTechnique:getName()
                            local poolId = basicTechnique:getPapool()
                            self:addButton(
                                techniqueName,
                                function()
                                    self.ListView:removeAllItems()
    
                                    self:addButton(
                                        "返回",
                                        function()
                                            self:fistFoot()
                                        end
                                    )
                                    
                                    role:getFistFootSystem():getCharacterPoolInfo(
                                        poolId,
                                        function(isOk,msg,data)
                                            if isOk then
                                                local characterList = data.characterList
                                                for i, character in pairs(characterList) do
                                                    if character.state ~= 0 then
                                                        local effect = role:getFistFootSystem():getFistFootEffect(character.id,technique.lv)
                                                        local characterName = effect:getName()
                                                        self:addButton(characterName,function()
                                                            local dataVer = role:getServerActionSystem():getDataVersion()
                                                            local codeVer = role:getFistFootSystem():getCodeVersion()
                                                            HttpManagerEx:testUpdateTechniqueFeature(technique.id,character.id,dataVer, codeVer,
                                                                function(status, errcode, errmsg, data)
                                                                    if status == 200 then
                                                                        if data.dataVer then
                                                                            role:getServerActionSystem():setDataVersion(data.dataVer)
                                                                        end
                                                                        PopText("设置成功")
                                                                    else
                                                                        PopText(errmsg)
                                                                    end
                                                                end,
                                                            IS_SHOW_WAITING)
                                                        end)
                                                    end
                                                end
                                            else
                                                PopText(msg)
                                            end
                                        end
                                    )
                                end
                            )
                        end
                    end
                end
            )
        end

        
    end)

    self:addButton(
        "快速完成拳脚系统前置任务",
        function()
            User:getRole():getFistFootSystem():createFistInfo(
                function(isOk, msg)
                    if isOk then
                        User:getRole():getFistFootSystem():unlockSystem()
                        PopText("开启成功")
                    else
                        PopText(msg)
                    end
                end
            )
        end
    )
    self:addButton(
        "添加拳脚系统开启标记",
        function()
            local FistFootConst = require("app.models.FistFootSystem.FistFootConst")
            local unlockFlag = FistFootConst:getConf("unlockFlag")
            User:getRole():setInheritFlag(unlockFlag, 1)
            PopText("添加成功")
        end
    )
    self:addButton(
        "清除拳脚系统开启标记",
        function()
            local FistFootConst = require("app.models.FistFootSystem.FistFootConst")
            local unlockFlag = FistFootConst:getConf("unlockFlag")
            User:getRole():setInheritFlag(unlockFlag, nil)
            PopText("清除成功")
        end
    )
    self:addEditor(
        "添加修行任务解锁标记,可多个",
        "标记id#标记id",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end
            local flags = string.split(text, "#")
            User:getRole():getFistFootSystem():updataFistFlag(
                flags,
                {},
                function(isOk, msg)
                    if isOk then
                        PopText("添加成功")
                    else
                        PopText(msg)
                    end
                end
            )
        end
    )
    self:addEditor(
        "删除修行任务解锁标记,可多个",
        "标记id#标记id",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local flags = string.split(text, "#")
            User:getRole():getFistFootSystem():updataFistFlag(
                {},
                flags,
                function(isOk, msg)
                    if isOk then
                        PopText("删除成功")
                    else
                        PopText(msg)
                    end
                end
            )
        end
    )

    self:addEditor(
        "锻体经验调整",
        "调整分支类型#调整后的经验值",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end
            local itemList = string.split(text, "#")
            local bType = itemList[1]
            local exp = tonumber(itemList[2])
            if bType == nil or exp == nil or exp < 0 then
                PopText("请输入正确参数" .. text)
                return
            end
            local role = User:getRole()

            local dataVer = role:getServerActionSystem():getDataVersion()

            HttpManagerEx:testSetFistBranchExp(
                bType,
                exp,
                dataVer,
                role:getFistFootSystem():getCodeVersion(),
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if data.dataVer then
                            role:getServerActionSystem():setDataVersion(data.dataVer)
                        end

                        PopText("设置成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addEditor(
        "潜思经验调整",
        "调整后的经验值",
        function(editBox, text)
            if text == nil or tonumber(text) == nil or tonumber(text) < 0 then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()

            local dataVer = role:getServerActionSystem():getDataVersion()

            local codeVersion = role:getFistFootSystem():getCodeVersion()

            HttpManagerEx:testSetFistReflectExp(
                tonumber(text),
                dataVer,
                codeVersion,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if data.dataVer then
                            role:getServerActionSystem():setDataVersion(data.dataVer)
                        end

                        PopText("设置成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addEditor(
        "设置技巧等级",
        "技巧Id#等级",
        function(editBox, text)
            local list = string.split(text, "#")
            local techniqueId = tostring(list[1])
            local level = tonumber(list[2])
            if techniqueId == nil or level == nil or level < 1 or level > 10 then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()

            local dataVer = role:getServerActionSystem():getDataVersion()

            HttpManagerEx:testSetFistTechniqueLevel(
                techniqueId,
                level,
                dataVer,
                role:getFistFootSystem():getCodeVersion(),
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if data.dataVer then
                            role:getServerActionSystem():setDataVersion(data.dataVer)
                        end

                        PopText("设置成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addEditor(
        "增加固身元气点数",
        "增加值",
        function(editBox, text)
            local addCount = tonumber(text)
            if addCount == nil or addCount == "" or addCount <= 0 then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()

            role:getXinShenSystem():addItemCount(
                "accpoint",
                addCount,
                function(ok, recoverData)
                    if ok then
                        role:getFistFootSystem():setAccpoint(recoverData.count)
                        PopText("添加成功")
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )

    self:addEditor(
        "增加特性见解点数",
        "增加值",
        function(editBox, text)
            local addCount = tonumber(text)
            if addCount == nil or addCount == "" or addCount <= 0 then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()

            role:getXinShenSystem():addItemCount(
                "characterPoint",
                addCount,
                function(ok, recoverData)
                    if ok then
                        role:getFistFootSystem():setCharacterPoint(recoverData.count)
                        PopText("添加成功")
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )

    self:addEditor(
        "增加技巧感悟点数",
        "增加值",
        function(editBox, text)
            local addCount = tonumber(text)
            if addCount == nil or addCount == "" or addCount <= 0 then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()

            local dataVer = role:getServerActionSystem():getDataVersion()

            HttpManagerEx:testAddFeelPoint(
                addCount,
                dataVer,
                role:getFistFootSystem():getCodeVersion(),
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if data.dataVer then
                            role:getServerActionSystem():setDataVersion(data.dataVer)
                        end

                        PopText("增加成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "增加技巧心得页",
        function()
            local role = User:getRole()

            local dataVer = role:getServerActionSystem():getDataVersion()

            HttpManagerEx:testAddTalentPage(
                dataVer,
                role:getFistFootSystem():getCodeVersion(),
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        if data.dataVer then
                            role:getServerActionSystem():setDataVersion(data.dataVer)
                        end

                        PopText("添加成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "拳脚系统PVP系列化测试",
        function()
            local role = User:getRole()

            local fistFootSystem = role:getFistFootSystem()

            local data = fistFootSystem:serializationForPVP()

            local newRole = Role:create()

            local newFistFootSystem = require("app.models.FistFootSystem.FistFootSystem"):create(newRole)

            newFistFootSystem:initFromPVPData(data)
        end
    )
end

function TestFuncLayer:newLianGong()
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addEditor(
        "恢复指定心神值",
        "心神值",
        function(editBox, text)
            if text == nil or text == "" or tonumber(text) == nil then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()
            role:getXinShenSystem():recoverXinShenValue(
                tonumber(text),
                function(ok, recoverData)
                    if ok then
                        PopText("恢复心神" .. text)
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )

    self:addButton(
        "回满心神值",
        function()
            local role = User:getRole()
            role:getXinShenSystem():recoverXinShenValue(
                999999,
                function(ok, recoverData)
                    if ok then
                        PopText("恢复心神回满")
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )

    self:addEditor(
        "添加笃志值",
        "添加数量",
        function(editBox, text)
            local count = tonumber(text)
            if count == nil or count < 0 then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()

            local dataVer = role:getServerActionSystem():getDataVersion()

            HttpManagerEx:testAddLianGongTiLi(
                count,
                dataVer,
                role:getFistFootSystem():getCodeVersion(),
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            if data.dataVer then
                                role:getServerActionSystem():setDataVersion(data.dataVer)
                            end

                            PopText("添加笃志值成功")
                        else
                            PopText(errmsg)
                        end
                    end
                    return true
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "添加回复心神道具清心散+1",
        function()
            local role = User:getRole()
            role:getXinShenSystem():addItemCount(
                "minditem1",
                1,
                function(ok, recoverData)
                    if ok then
                        PopText("添加成功")
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )
    self:addButton(
        "添加回复心神道具谧心丸+1",
        function()
            local role = User:getRole()
            role:getXinShenSystem():addItemCount(
                "minditem2",
                1,
                function(ok, recoverData)
                    if ok then
                        PopText("添加成功")
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )
    self:addButton(
        "添加回复心神道具凝心露+1",
        function()
            local role = User:getRole()
            role:getXinShenSystem():addItemCount(
                "minditem3",
                1,
                function(ok, recoverData)
                    if ok then
                        PopText("添加成功")
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )
    self:addButton(
        "添加回复心神道具聚心丹+1",
        function()
            local role = User:getRole()
            role:getXinShenSystem():addItemCount(
                "minditem4",
                1,
                function(ok, recoverData)
                    if ok then
                        PopText("添加成功")
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )
    self:addEditor(
        "恢复指定道具",
        "道具id#数量",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end
            local itemList = string.split(text, "#")
            local id = itemList[1]
            local num = tonumber(itemList[2])
            if id == nil or num == nil then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()
            role:getXinShenSystem():addItemCount(
                id,
                num,
                function(ok, recoverData)
                    if ok then
                        PopText("添加成功")
                    else
                        local msg = recoverData
                        PopText(msg)
                    end
                end
            )
        end
    )
end

function TestFuncLayer:playerSkillModify()
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:playerSkillButtons()
        end
    )

    self:addButton(
        "增加所有技能",
        function()
            local role = User:getRole()
			local skills = Skill:getSkillMap()
            for k, skill in pairs(skills) do
                if not MapIsEmpty(skill) then
                    local roleSkill = role:getSkill(skill.id)
                    if roleSkill == nil then
                        roleSkill = {id = skill.id, exp = 1}
                        role:setSkill(skill.id, roleSkill)
                    end
                end
            end
            PopText("增加所有技能")
        end
    )
    self:addButton(
        "清除所有技能",
        function()
            User:getRole():setAttr("skills", {})
            PopText("清除所有技能")
        end
    )

    self:addButton(
        "所有已拥有武学满级",
        function()
            local role = User:getRole()
            local skills = role:getSkills()
            for k, skill in pairs(skills) do
                if skill then
                    local maxLv = SkillHelper:getSkillLvLimit(role, skill.id)
                    maxLv = math.min(role:getLv(), maxLv)
                    local exp = SkillHelper:getExp(skill.id, maxLv)
                    SkillHelper:setSkillExp(role, skill.id, exp)
                end
            end
            PopText("所有已拥有武学满级")
        end
    )

    self:addButton("打印自创武学对应id",function()
        local role = User:getRole()
        local selfCreatedSkillData = role:getSelfCreatedSkillSystem():getCreatedSkillData()
        print("--------自创武学id-------")
        for skillDataId, v in pairs(selfCreatedSkillData) do
            print(v.name, SkillHelper:selfCreatedSkillDataIdToSkillId(role:getAttr("userid"),skillDataId))
        end
    end)

    self:addEditor(
        "删除技能",
        "技能ID#技能ID",
        function(editBox, text)
            if text == "" then
                PopText("请输入正确字符！！")
                return
            end
            
            local player = User:getRole()

            local skillInfoArray = string.split(text, "#")

            for i, skillId in ipairs(skillInfoArray) do
                if player:getSkill(skillId) then 
                    local isTure = player:removeSkill(skillId)
                    if isTure then
                        PopText(skillId.."删除成功")
                    end
                else
                    PopText("没有技能"..skillId)
                end
            end
        end
    )
    self:addEditor(
        "设置玩家技能经验",
        "技能ID#技能经验",
        function(editBox, text)
            if text == "" then
                PopText("请输入正确字符！！")
                return
            end

            local skillInfoArray = string.split(text, "#")

            local skillId = skillInfoArray[1]

            local exp = tonumber(skillInfoArray[2])

            SkillHelper:setSkillExp(User:getRole(), skillId, exp)
        end
    )

    self:addEditor(
        "设置玩家技能等级",
        "技能ID#技能等级",
        function(editBox, text)
            if text == "" then
                PopText("请输入正确字符！！")
                return
            end

            local skillInfoArray = string.split(text, "#")

            local skillId = skillInfoArray[1]

            local lv = tonumber(skillInfoArray[2])

            SkillHelper:setSkillLv(User:getRole(), skillId, lv)
        end
    )

    self:addEditor(
        "增加玩家技能经验",
        "技能ID#增加技能经验",
        function(editBox, text)
            if text == "" then
                PopText("请输入正确字符！！")
                return
            end

            local skillInfoArray = string.split(text, "#")

            local skillId = skillInfoArray[1]

            local addExp = tonumber(skillInfoArray[2])

            if addExp < 0 then
                error("增加经验值不可小于0")
            end
            
            SkillHelper:addSkillExp(User:getRole(), skillId, addExp)
        end
    )
end

function TestFuncLayer:playerSkillZhaoModify()
    self.ListView:removeAllItems()
    
    self:addButton(
        "返回",
        function()
            self:playerSkillButtons()
        end
    )

    self:addEditor(
        "设置招式熟练度",
        "招式id;熟练度(为修改后的值，0代表删除)",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local str = string.split(text, ";")
            local zhaoId = str[1]
            local value = tonumber(str[2])
        
            if zhaoId == nil then
                PopText("请输入正确的招式id")
                return
            end

            Skill:getActiveZhao(zhaoId)

            if value == nil or value < 0 then
                PopText("请输入正确的熟练度值")
                return
            end

            local role = User:getRole()
            local activeZhaos = role:getAttr("activeZhaos")

            if value == 0 then
                activeZhaos[zhaoId] = nil
                PopText("成功删除当前招式！")
                return
            end

            local maxLv = role:getSkillBreakThroughSystem():getZhaoLvLimit(zhaoId)
            local maxExp = role:getZhaoExpLimit(zhaoId, maxLv)
            value = math.min(value, maxExp)
            value = math.max(value, 1)

            activeZhaos[zhaoId] = {id = zhaoId, exp = value}
            PopText("成功设置当前招式熟练度为"..tostring(value))
        end
    )

    self:addButton(
        "所有已拥有武学主动技能招式满级",
        function()
            local role = User:getRole()
            local skills = role:getSkills()
            for skillId,roleSkill in pairs(skills) do
                local zhaoList = Skill:getSkillZhaoList(skillId)
                local skill = Skill:getSkill(skillId)
                for i,zhao in ipairs(zhaoList) do
                    role:addSkillZhaoLv(zhao:getId(), 9)
                end
            end
            PopText("所有武学主动技能招式满级")
        end
    )
end


function TestFuncLayer:playerModify()
    self.ListView:removeAllItems()

    self:addButton(
        "功绩+10000",
        function()
            HttpManagerEx:updateCurrencyByType(
                "add",
                "zjjifen",
                10000,
                nil,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        if Helper:getDef(data.zjjifen, 0) == 0 then
                            PopText("您今日所得功绩已达上限")
                        else
                            PopText("功绩+" .. tostring(data.zjjifen))
                        end
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "功绩-10000",
        function()
            HttpManagerEx:updateCurrencyByType(
                "remove",
                "zjjifen",
                10000,
                nil,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        if Helper:getDef(data.zjjifen, 0) == 0 then
                            PopText("您今日所得功绩已达上限")
                        else
                            PopText("功绩-" .. tostring(data.zjjifen))
                        end
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "美容丸初始化记录清除",
        function()
            HttpManagerEx:testDeleteMeiRongWanInit(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("清除成功")
                    else
                        PopText("清除失败")
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "增加神照经道具",
        function()
            local role = User:getRole()
            if role:getAttr("weight") - #role:getItems() < 1 then
                PopText("背包已满，无法获取")
                return
            end
            HttpManagerEx:testExchangeGoods(
                "szjdj2", 1,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        role:addItemCount("szjdj2", 1)
                        PopText("获得信笺道具")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "一键增加武学突破相关货币各1000",
        function()
            HttpManagerEx:testAddMartialCurrency(User:getRole():getCurrencyVersion(),
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        if data.currencyVersion then
                            User:getRole():setCurrencyVersion(data.currencyVersion)
                        end
                        PopText("添加成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self:addButton(
        "一键增加招式突破相关道具各1000",
        function()
            HttpManagerEx:testAddZhaoBreItems(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("添加成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )

    local function addCurrency(id, num, action)
        local currencyVersion = User:getRole():getCurrencyVersion()
        HttpManagerEx:testCurrency(id, num, action, currencyVersion, function(status, errcode, errmsg, data, isEncrypted)
                if status == 200 and errcode == 0 then
                    if data.dataVer then
                        User:getRole():setCurrencyVersion(data.dataVer)
                    end

                    PopText("修改成功！")
                end
            end,
        IS_SHOW_WAITING)
    end

    self:addButton("货币管理资源",function()
        self.ListView:removeAllItems()

        self:addButton(
            "返回",
            function()
                self:playerModify()
            end
        )
        local list = CurrencyUtil:getCurrencyList()

        for __, currencyId in ipairs(list) do
            self:addEditor(
                "修改"..CurrencyUtil:getCurrencyName(currencyId).."数量",
                "数量#加（add）减(remove)（50#add、50#remove）",
                function(editBox, text)
                    if text == nil or text == "" then
                        PopText("请输入正确参数" .. text)
                        return
                    end

                    local info = string.split(text, "#")
                    if (tonumber(info[1]) == nil or tonumber(info[1]) == 0) or (info[2] ~= "add" and info[2] ~= "remove") then
                        PopText("请输入正确参数" .. text)
                        return
                    end

                    addCurrency(currencyId, tonumber(info[1]), info[2])
                end
            )
        end
    end)

    local currencyVersion = User:getRole():getCurrencyVersion()
    self:addEditor(
        "修改货币版本",
        "当前版本:"..tostring(currencyVersion),
        function(editBox, text)
            if text == nil or text == "" or tonumber(text) == nil then
                PopText("请输入正确参数" .. text)
                return
            end

            User:getRole():setCurrencyVersion(tonumber(text))
            PopText("货币版本修改成功！")
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:playerSkillButtons()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton("取消准备武学时师门相关限制条件",function()
        local role = User:getRole()
        local RolePrepareSkill = require("app.views.layer.DebugLayer.RolePrepareSkill.TestRolePrepareSkill")
		role.__prepareSkillModel = RolePrepareSkill:create(role)
        PopText("成功取消准备武学时师门相关限制条件")
    end)

    self:addButton("恢复准备武学时师门相关限制条件",function()
        local role = User:getRole()
        local RolePrepareSkill = require("app.models.RolePrepareSkill.RolePrepareSkill")
		role.__prepareSkillModel = RolePrepareSkill:create(role)
        PopText("成功恢复准备武学时师门相关限制条件")
    end)

    self:addButton(
        "清除基本武学修复标记",
        function()
            User:getRole():setInheritFlag("__repairRoleSkillData", nil)
        end
    )

    self:addButton("模拟自创武学旧版练功",function()
        local role = User:getRole()
        local isLianGong = role:getLianGongSystem():isLianGonging()
        if isLianGong then
            PopText("请先停止练功")
            return
        end
    
        self:simulateOldLianGong()
    end)
    
    self:addButton("模拟自创武学旧版修炼",function()
        local role = User:getRole()
        local isXiuLianing = role:getXiuLianSystem():isXiuLianing()
        if isXiuLianing then
            PopText("请先停止修炼")
            return
        end
        self:simulateOldXiuLian()
    end)

    local SkillConst = require("app.models.skill.SkillConst")
    local baseNaturalSkill = Skill:getSkill(SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch"))
    local naturalSkillName = baseNaturalSkill.name
    self:addButton(
        tostring(naturalSkillName) .. "相关",
        function()
            self.ListView:removeAllItems()

            self:addButton(
                "清除玩家存档方案",
                function()
                    local role = User:getRole()
                    role:setAttr("naturalAttrPlan", nil)
                    assert(role.naturalAttrPlan == nil, "清除失败")
                    PopText("清除成功")
                end
            )

            self:addButton(
                "先天属性分配方案UI展示",
                function()
                    local NaturalAttrUtil = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrUtil")
                    NaturalAttrUtil:showPlayerCurrentNaturalAdjustmentPlanLayer()
                end
            )

            self:addButton(
                "返回",
                function()
                    self:playerSkillButtons()
                end
            )
        end
    )


    self:addButton(
        "修改玩家武学",
        function()
            self:playerSkillModify()
        end
    )

    self:addButton(
        "修改玩家主动技能",
        function()
            self:playerSkillZhaoModify()
        end
    )

    self:addEditor(
        "武学详情界面测试",
        "武学id",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            PopupLayerController:showLayer(
                "BasicSkillDetailPresenter",
                function(layer)
                    layer:showLayer(User:getRole(), text)
                end
            )
        end
    )

    self:addButton(
        "学会周公之术",
        function()
            local role = User:getRole()
            local roleSkill = role:getSkill("zhougongzhishu")

            if MapIsEmpty(roleSkill) == false then
                PopText("已经学会周公之术")
                return
            end
            local success = role:addZhouGongZhiShuExp(1)
            if success then
                PopText("学会周公之术")
            else
                PopText("有问题")
            end
        end
    )

    self:addButton(
        "周公之术突破",
        function()
            local role = User:getRole()
            local success = role:breakZhouGongZhiShuLvLimit()
            if success then
                PopText("周公之术突破成功")
            else
                PopText("未满足周公之术突破条件")
            end
        end
    )

    self:addButton(
        "周公之术经验添加10000",
        function()
            local role = User:getRole()
            local success = role:addZhouGongZhiShuExp(10000)
            if success then
                PopText("周公之术经验添加成功")
            end
        end
    )

    self:addEditor(
        "周公之术经验增加",
        "exp",
        function(editBox, text)
            local exp = tonumber(text)

            local role = User:getRole()
            local success = role:addZhouGongZhiShuExp(exp)
            if success then
                PopText("周公之术经验添加成功")
            end
        end
    )

    self:addButton(
        "学会溯源诀",
        function()
            local role = User:getRole()
            local SkillConst = require("app.models.skill.SkillConst")
            local skillId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)
            local roleSkill = role:getSkill(skillId)

            if MapIsEmpty(roleSkill) == false then
                PopText("已经学会溯源诀")
            else
                roleSkill = {id = skillId, exp = 1}
                PopText("学会溯源诀")
            end
        end
    )

    self:addEditor(
        "溯源诀经验设置",
        "exp",
        function(editBox, text)
            local role = User:getRole()
            local SkillConst = require("app.models.skill.SkillConst")
            local skillId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)
            local roleSkill = role:getSkill(skillId)
            local exp = tonumber(text)

            roleSkill.exp = exp
        end
    )

    self:addButton(
        "易容术冷却时间置为0",
        function()
            local role = User:getRole()
            role.polymorph.cdTime = 0
            role.polymorph.endTime = 0
        end
    )

    self:addButton(
        "易容术阴阳嬗变冷却时间置为0",
        function()
            local role = User:getRole()
            role.polymorph.genderTransCdTime = 0
        end
    )

    
    self:addButton(
        "走穴十四经",
        function()
            self:setZouXue()
        end
    )

    self:addButton(
        "重置神照经",
        function()
            local role = User:getRole()
            role:setDayFlag("benrichuangong", 0)
            role:setInheritFlag("chuangongcishu", 0)
            role:setInheritFlag("szjqzrw", 0)
            role:setInheritFlag("jinbixiaomen", 0)
            role:setInheritFlag("szjwb", 0)
            role:setInheritFlag("szjhlel", 0)
            role:setInheritFlag("szjcgwc", 0)
            role:setInheritFlag("szjsw", 0)
            role:setInheritFlag("szjqzrwts", 0)
            role:setInheritFlag("szjtspd", 0)
            role:setInheritFlag("szjmrts", 0)
            role:removeSkill("shenzhaojing001")
            role:removeSkill("shenzhaojing002")
            role:removeSkill("shenzhaojing003")
            PopText("重置成功")
        end
    )

    self:addButton(
        "清除长生决阴阳交换CD",
        function()
            User:getRole():setFlag("阴阳交换时间", 0)
            PopText("清除成功")
        end
    )

    self:addButton(
        "清除技能系统版本",
        function()
            local role = User:getRole()
            role:setAttr("skillSysVer", 0)
        end
    )
end

function TestFuncLayer:simulateOldLianGong()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:playerSkillButtons()
        end
    )

    local role = User:getRole()
    local selfCreatedSkillData = role:getSelfCreatedSkillSystem():getCreatedSkillData()
    for id, v in pairs(selfCreatedSkillData) do
        self:addButton(
            v.name,
            function()
                self.ListView:removeAllItems()

                self:addButton(
                    "返回",
                    function()
                        self:simulateOldLianGong()
                    end
                )
                self:addEditor(
                    "设置练功时长",
                    "time",
                    function(editBox, text)
                        role:setFlag("当前武功", tostring(v.id))
                        role:setFlag("练功时间", GetTime() - tonumber(text))
                        role:setRoleCurrState(ROLE_CURR_STATE_LIANGONG)
                        role:setInheritFlag("stopOldLianGong", 0)

                        local selfCreatingSkill = role:getSelfCreatedSkillSystem():getCreatedSkillBySkillDataId(v.id)

                        if selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_QUANJIAO then
                            role.skillPrepare["quanjiao1"] =v.id
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_JIAN then
                            role.skillPrepare["jianfa"] =v.id
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_DAO then
                            role.skillPrepare["daofa"] =v.id
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_GUN then
                            role.skillPrepare["gunfa"] =v.id
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_ANQI then 
                            role.skillPrepare["anqi"] =v.id
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_BIANFA then 
                            role.skillPrepare["bianfa"] =v.id
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_SHUANGCHI then 
                            role.skillPrepare["shuangchi"] =v.id
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_QIN then 
                            role.skillPrepare["qinfa"] =v.id
                        end

                        PopText("设置成功，重启游戏即可结算")
                    end
                )

                self:addButton(
                    "模拟结束",
                    function()
                        SkillHelper:changeRoleSelfCreatedSkillId(role)
                        role:lianGong()
                        role:stopLianGong()
                        role:setInheritFlag("stopOldLianGong", 1)
                    end
                )

                self:addButton("生成BUG_1007885所需数据",function ()
                    local InitSomeOldRoleData = require("app.views.layer.DebugLayer.TestData.InitSomeOldRoleData")

                    InitSomeOldRoleData.initRoleData_Bug1007885(role,v.id)
                end)
            end
        )
    end
end

function TestFuncLayer:simulateOldXiuLian()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:playerSkillButtons()
        end
    )

    local role = User:getRole()
    local selfCreatedSkillData = role:getSelfCreatedSkillSystem():getCreatedSkillData()
    for id, v in pairs(selfCreatedSkillData) do
        self:addButton(
            v.name,
            function()
                self.ListView:removeAllItems()

                self:addButton(
                    "返回",
                    function()
                        self:simulateOldXiuLian()
                    end
                )
                self:addEditor(
                    "设置时长",
                    "time",
                    function(editBox, text)
                        local xiuLianData = {}
                        xiuLianData.skillId = v.id
                        xiuLianData.startTime = GetTime() - tonumber(text)
                        xiuLianData.endTime = GetTime() + 900000
                        xiuLianData.jjId = "jiaren005"
                        xiuLianData.durable = 9999
                        role:setAttr("xiuLianData", xiuLianData)
                        role:setRoleCurrState(ROLE_CURR_STATE_XIULIAN)

                        local selfCreatingSkill = role:getSelfCreatedSkillSystem():getCreatedSkillBySkillDataId(v.id)

                        if selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_QUANJIAO then
                            role:setFlag("武功修炼类型","quanjiao1")
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_JIAN then
                            role:setFlag("武功修炼类型","jianfa")
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_DAO then
                            role:setFlag("武功修炼类型","daofa")
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_GUN then
                            role:setFlag("武功修炼类型","gunfa")
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_ANQI then 
                            role:setFlag("武功修炼类型","anqi")
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_BIANFA then 
                            role:setFlag("武功修炼类型","bianfa")
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_SHUANGCHI then 
                            role:setFlag("武功修炼类型","shuangchi")
                        elseif selfCreatingSkill:getMethods() == SKILL_METHOD_TYPE_QIN then 
                            role:setFlag("武功修炼类型","qinfa")
                        end

                        PopText("设置成功，模拟结束即可结算")
                    end
                )

                self:addButton(
                    "模拟结束",
                    function()
                        role:setInheritFlag("stopOldXiuLian", 0)
                        SkillHelper:changeRoleSelfCreatedSkillId(role)
                        role:setInheritFlag("stopOldXiuLian", 1)
                        role:xiuLian()
                    end
                )
            end
        )
    end
end

function TestFuncLayer:breakSkillButtons()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addEditor(
        "清除武学突破数据",
        "武学id",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local role = User:getRole()

            local skillBreakData = role:getAttr("skillBreakData")

            skillBreakData[text] = nil
        end
    )
end

function TestFuncLayer:departFromFamily()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )



    self:addButton("开始叛师任务",function()
        local DepartFromFamily = require("app.models.departFromFamily.DepartFromFamily")
        local departFromFamily = DepartFromFamily:create()
        departFromFamily:setRole(User:getRole())
        departFromFamily:startLeaveTask()
        PopText("开始叛师任务")
    end)

    self:addButton("播放叛师任务结局动画",function()
        local DepartFromFamily = require("app.models.departFromFamily.DepartFromFamily")
        local departFromFamily = DepartFromFamily:create()
        departFromFamily:setRole(User:getRole())
        local anims = departFromFamily:getLeaveAnim()

        if MapIsEmpty(anims) == false then
            PopupLayerController:showLayer("DepartFromFamilyTextAnimLayer",function(layer)
                layer:setAnimInfo(anims)
                layer:showLayer()
            end)
        end
    end)

    self:addButton("重置叛师任务开始标记",function()
        local role = User:getRole()
        local flag = GameConst:getConfigValue("departFromFamilyTask_startFlag")
        role:setFlag(flag, nil)
        PopText("重置成功")
    end)

    self:addEditor(
                "设置叛师结局",
                "结局标记值（2,3,4,5...）",
                function(editBox, text)
                    if text == nil or text == "" then
                        PopText("请输入正确参数" .. text)
                        return
                    end

                    local role = User:getRole()
                    local flag = GameConst:getConfigValue("departFromFamilyTask_startFlag")
                    role:setFlag(flag, tonumber(text))
                    PopText("设置成功")
                end
            )
    
    
end

function TestFuncLayer:decorativeBoxFunc()
    self.ListView:removeAllItems()

    local MaskResManager = require("app.models.mask.MaskResManager")

    self:addButton(
        "一键添加所有面具",
        function()
            local role = User:getRole()
            local list = MaskResManager:getAllMaskIdAndMaxLv()
            local count = #list

            role:setAttr("decorativeLimit",count+1)

            for i,v in ipairs(list) do
                role:addDecorative(v.id,1)

                for i=1,v.lv - 1 do
                    if not role:getMaskSystem():addMaskLv(v.id) then
                        break
                    end
                end
            end

            PopText("添加成功 共添加"..count.."个面具")
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:cheatHelper()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton("角色潜能丹记录清空",function()
        local QianNengDanUseRecord = require("app.models.Record.QianNengDanUseRecord.QianNengDanUseRecord")
        QianNengDanUseRecord:testClearBaseData(User:getRole())
        PopText("成功清空！！！")
    end)

    self:addTimeEditor(
        "修改角色潜能丹调整节点时间",
        function(item)            
            local year = Helper:getDef(tonumber(item:getChildByTag(770):getText()), tonumber(item:getChildByTag(770):getPlaceHolder()))
            local month = Helper:getDef(tonumber(item:getChildByTag(771):getText()), tonumber(item:getChildByTag(771):getPlaceHolder()))
            local day = Helper:getDef(tonumber(item:getChildByTag(772):getText()), tonumber(item:getChildByTag(772):getPlaceHolder()))
            local hour = Helper:getDef(tonumber(item:getChildByTag(773):getText()), tonumber(item:getChildByTag(773):getPlaceHolder()))
            local minute = Helper:getDef(tonumber(item:getChildByTag(774):getText()), tonumber(item:getChildByTag(774):getPlaceHolder()))
            
            local time = {
                year = year,
                month = month,
                day = day,
                hour = hour,
                min = minute
            }

            local QianNengDanUseRecord = require("app.models.Record.QianNengDanUseRecord.QianNengDanUseRecord")
            QianNengDanUseRecord:testClearBaseData(User:getRole())
            QianNengDanUseRecord:testSetStartRecordTime(os.time(time))
            QianNengDanUseRecord:initBaseData(User:getRole())
            
            Helper:print_lua_table(time)
            print(os.time(time))
            
            PopText("角色潜能丹调整节点时间设置成功" .. Helper:date("%x %X", os.time(time)));
            PopText("角色潜能丹记录清空！")
        end
    )
end

function TestFuncLayer:lunJianHelper()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton("指定论剑锦囊",function()
        self.ListView:removeAllItems()

        self:addButton(
            "返回",
            function()
                self:lunJianHelper()
            end
        )
        local cards = BiWu:getCardTab()
        for i = 1, #cards, 1 do
            self:addButton(
                cards[i],
                function()
                    DebugHelper:setLunJianJinNangId(i)
                    PopText("已指定论剑锦囊"..cards[i])
                end
            )
        end
    end)

    self:addButton("取消指定论剑锦囊",function()
        DebugHelper:setLunJianJinNangId(nil)
        PopText("取消成功！")
    end)
end

function TestFuncLayer:playerAttrModify()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton(
        "一键增加人物属性",
        function()
            local role = User:getRole()
            role:setAttr("exp", 9999999) --经验
            role:setAttr("money", 9999999) --碎银
            role:setAttr("str", 10000) -- 臂力
            role:setAttr("int", 10000) -- 悟性
            role:setAttr("con", 10000) -- 根骨
            role:setAttr("dex", 10000) -- 身法
            role:setAttr("zhengqi", 1000) --正气
            role:setAttr("weiwang", 1000) --威望
            
            PopText("经验 " .. 99999999)
            PopText("金钱 " .. 99999999)
            PopText("臂力 " .. 10000)
            PopText("悟性 " .. 10000)
            PopText("根骨 " .. 10000)
            PopText("身法 " .. 10000)
            PopText("正气 " .. 1000)
            PopText("威望 " .. 1000)
        end
    )

    self:addButton(
        "修改门派",
        function()
            self.ListView:removeAllItems()

            self:addButton(
                "返回",
                function()
                    self:playerAttrModify()
                end
            )

            local Family = require("app.models.family.Family")
            local familys = Family:getFamilys() 
            local addMaps = {}
            for k, v in pairs(familys) do
                local familyName = v.name
                local familyId = v.id

                if not addMaps[familyId] and (familyId ~= "youxia" and familyId ~= GameConst:getDefaultValue("seclusion_family_id")) then
                    addMaps[familyId] = true
                    self:addButton(familyName,function()
                        local role = User:getRole()
    
                        local roleFamilyId = role:getFamilyId()
                        if not roleFamilyId then
                            PopText("当前未加入门派")
                            return
                        end
    
                        if roleFamilyId == "youxia" or roleFamilyId == GameConst:getDefaultValue("seclusion_family_id") then
                            PopText("当前未加入门派")
                            return
                        end
    
                        local defaultTeacherId = v.defaultTeacher
                        local teacher = Npc:getNpc(defaultTeacherId)
    
                        local tcFmlLv = assert(teacher:getFamilyLevel())
                        local tcFmlId = assert(teacher:getFamilyId())
    
                        local family = {
                            name = tcFmlId,
                            level = tcFmlLv + 1
                        }
    
                        HttpManagerEx:testUpdateUserFamily(familyId,function(status, errcode, errmsg, data, isEncrypted)
                                if status == 200 and errcode == 0 then
                                    role:setAttr("family", family)
                                    role:setAttr("teacherName", teacher:getName())
                                    role:setAttr("teacherId", teacher:getAttr("id"))
    
                                    PopText("成功更换为"..familyName)
                                end
                            end,
                        IS_SHOW_WAITING)
    
                    end)
                end
            end

        end
    )

    self:addEditor("修改角色名称（只涉及修改本地存档，谨慎使用）",User:getRole():getAttr("name"),function(editBox, text)
            if text == nil or text == "" then
                PopText("名字不能为空")
                return
            end

            if not Helper:isChinese(text) then
                PopText("名字必须是中文")
                return
            end

            if string.len(text) > 4 * 3 then
                PopText("名字最多四个字")
                return
            end

            if Helper:isMaskOff(text) then
                PopText(tostring(text) .. " 是非法词汇，请更换后再试。")
                return
            end
            
            local role = User:getRole()
            role:setAttr("name",text)

            local inheritHistory = role:getAttr("inheritHistory")

            for i,v in ipairs(inheritHistory) do
                if i == #inheritHistory then
                    v.inheritName = text
                end
            end
            
            PopText("姓名设置成功")
    end)


    local list = {"exp", "pot", "money", "str", "int", "con", "dex", "zhengqi", "weiwang", "looks", "luck", "qi", "jing", "pijuan", "gold" , "kill" , "meili"}
    for i = 1, 99 do
        if list[i] then
            local attrId = list[i]
            local name = User:getRole():getCHAttrName(attrId)
            local currValue = User:getRole():getAttr(attrId)
            self:addEditor(
                name,
                currValue,
                function(editBox, text)
                    text = tonumber(text)
                    if type(text) ~= "number" then
                        PopText("请输入正确参数" .. tostring(text))
                        return
                    end

                    local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")
                    if table.keyof(NaturalAttrAdjustmentConst.ATTR_TYPE, attrId) then
                        local NaturalAttrUtil = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrUtil")
                        local naturalAttrAdjustmentPlan = NaturalAttrUtil:getPlayerCurrentNaturalAdjustmentPlan()
                        local plan = naturalAttrAdjustmentPlan:getUsagePlan()
                        plan:setNaturalPlanAttr(attrId, text)
                        naturalAttrAdjustmentPlan:useAttrAdjustmentPlanType(plan:getNaturalPlanType())
                    else
                        User:getRole():setAttr(attrId, text)
                    end

                    PopText("【" .. name .."】修改成功")
                end
            )
        else
            break
        end
    end
end

function TestFuncLayer:playerFlags()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton(
        "清空人物标记",
        function()
            PopText("清空人物标记")
            User:setRoleAttr("_flags", {})
        end
    )

    self:addButton(
        "清除当天限制标记",
        function()
            local role = User:getRole()
            role._dayFlags.flags = {}
            PopText("清除限制成功")
        end
    )

    self:addEditor(
        "设置人物标记",
        "标记Id#标记值",
        function(editBox, text)
            if text == "" or text == nil then
                PopText("请输入正确参数" .. text)
                return
            end
            local name = string.split(text, "#")[1]
            local value = tonumber(string.split(text, "#")[2])

            if name == nil or value == nil then
                PopText("请输入正确参数" .. text)
                return
            end

            User:getRole():setFlag(name,value)
        end
    )

    self:addEditor(
        "设置人物当日标记",
        "标记Id#标记值",
        function(editBox, text)
            if text == "" or text == nil then
                PopText("请输入正确参数" .. text)
                return
            end
            local name = string.split(text, "#")[1]
            local value = tonumber(string.split(text, "#")[2])

            if name == nil or value == nil then
                PopText("请输入正确参数" .. text)
                return
            end

            User:getRole():setDayFlag(name,value)
        end
    )

    self:addEditor(
        "设置人物传承标记",
        "标记Id#标记值",
        function(editBox, text)
            if text == "" or text == nil then
                PopText("请输入正确参数" .. text)
                return
            end
            local name = string.split(text, "#")[1]
            local value = tonumber(string.split(text, "#")[2])

            if name == nil or value == nil then
                PopText("请输入正确参数" .. text)
                return
            end

            User:getRole():setInheritFlag(name,value)
        end
    )
end

function TestFuncLayer:playerItems()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton(
        "设置背包倒计时限时道具剩余时间",
        function()
            local role = User:getRole()
            local items = role:getItems()
            local limitItems = {}
            for i = 1, #items, 1 do
                if items[i].time then
                    local itemAttr = role:getOneItemByKey(items[i].itemId)
                    if type(itemAttr.timeend) == "number" then
                        table.insert(limitItems, items[i])
                    end
                end
            end

            if #limitItems == 0 then
                PopText("背包无倒计时限时道具！")
                return
            end

            self.ListView:removeAllItems()

            self:addButton(
                "返回",
                function()
                    self:playerItems()
                end
            )

            for i = 1, #limitItems, 1 do
                local itemAttr = role:getOneItemByKey(limitItems[i].itemId)
                self:addEditor(
                    itemAttr.name,
                    "设置剩余时间（单位为秒，如30）",
                    function(editBox, text)
                        if text == "" or text == nil or tonumber(text) == nil then
                            PopText("请输入正确参数" .. text)
                            return
                        end
                        local time = tonumber(text)
                        local isTrue = false
                        for j = 1, #items, 1 do
                            if items[j].id == limitItems[i].id then
                                items[j].time = GetTime() + time
                                PopText("修改成功！")
                                isTrue = true
                                break
                            end
                        end

                        if isTrue == false then
                            PopText("道具已消失，请重新进入")
                            self:playerItems()
                        end
                    end
                )
            end

        end
    )

    self:addButton(
        "清空背包物品",
        function()
            PopText("清空背包物品")
            User:setRoleAttr("items", {})
        end
    )

    self:addButton(
        "清空书箱",
        function()
            PopText("清空书箱")
            User:setRoleAttr("shuxiang", {})
        end
    )

    self:addButton(
        "清空残页",
        function()
            PopText("清空残页")
            User:setRoleAttr("zhaoShuXiang", {})
        end
    )

    self:addEditor(
        "修改物品数量",
        "物品Id#物品数量",
        function(editBox, text)
            if text == "" or text == nil then
                PopText("请输入正确参数" .. text)
                return
            end
            local itemId = string.split(text, "#")[1]
            local num = tonumber(string.split(text, "#")[2])

            if itemId == nil or num == nil or num == 0 then
                PopText("请输入正确参数" .. text)
                return
            end

            local item = User:getRole():getOneItemByKey(itemId)

            if item == nil then
                PopText("没有该物品的资源" .. tostring(itemId))
            else
                local role = User:getRole()

                if num > 0 then
                    if role:checkCanBuyTwoOrMoreThings({[itemId] = num},true) == false then
                        return
                    end
                else
                    local itemCount = role:getItemCount(itemId)
                    if itemCount + num < 0 then
                        PopText("背包道具数量不足")
                        return
                    end
                end
                
                local function roleAddItem(num)
                    if num > 0 then
                        PopText("获得"..item.name.."X"..tostring(num))
                    else
                        PopText("减少"..item.name.."X"..tostring(math.abs(num)))
                    end

                    role:addItemCount(itemId, num)
                end

                if Item:isServerOnlyCheckItem(itemId)then
                    if num > 0 then
                        HttpManagerEx:testExchangeGoods(
                            itemId, num,
                            function(status, errcode, errmsg, data)
                                if status == 200 and errcode == 0 then
                                    roleAddItem(num)
                                else
                                    PopText(errmsg)
                                end
                            end,
                            IS_SHOW_WAITING
                        )
                    else
                        HttpManagerEx:detectionGoods(itemId,
                            function(status, errcode, errmsg, data)
                                if status == 200 and errcode == 0 then
                                    if data and tonumber(data.numbers) > 0 then
                                        roleAddItem(num)
                                    else
                                        PopText("物品不曾购买")
                                    end
                                else
                                    PopText(errmsg)
                                end
                            end,
                        IS_SHOW_WAITING)
                    end
                elseif Item:isServerCheckAndUseItem(itemId) then
                    if num > 0 then
                        HttpManagerEx:testExchangeGoods(
                            itemId, num,
                            function(status, errcode, errmsg, data)
                                if status == 200 and errcode == 0 then
                                    roleAddItem(num)
                                else
                                    PopText(errmsg)
                                end
                            end,
                            IS_SHOW_WAITING
                        )
                    else
                        HttpManagerEx:checkItemIsCanUse(itemId, math.abs(num),function(status, errcode, errmsg, data)
                                if status == 200 then
                                    if errcode == 0 then
                                        roleAddItem(num)
                                    else
                                        PopText("物品未通过正品检测，请购买正品")
                                    end
                                else
                                    PopText(errmsg)
                                end
                            end,
                            IS_SHOW_WAITING
                        )
                    end
                else
                    roleAddItem(num)
                end
            end
        end
    )
end

function TestFuncLayer:selfCreatedZhaoAnim()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")

    local weapon_type_List = {
        [SelfCreatedSkillConstants.SkillThirdType.JIAN_FA] = {"jian", "jianfa", "剑"},
        [SelfCreatedSkillConstants.SkillThirdType.DAO_FA] = {"dao", "daofa", "刀"},
        [SelfCreatedSkillConstants.SkillThirdType.GUN_FA] = {"gun", "gunfa", "棍"},
        [SelfCreatedSkillConstants.SkillThirdType.BIAN_FA] = {"bian", "bianfa", "鞭"},
        [SelfCreatedSkillConstants.SkillThirdType.AN_QI] = {"anqi", "anqi", "暗器"},
        [SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI] = {"shuangchi", "shuangchi", "双持"},
        [SelfCreatedSkillConstants.SkillThirdType.QIN_FA] = {"qin", "qinfa", "乐器"}
    }

    self:addEditor(
        "招式id",
        "zhaoid",
        function(editBox, text)
            local zhaoTemplate = require("script.selfCreatedSkill.zhaoTemplates")["招式"]

            local zhaoMap = {}
            for zhaoId, zhaoData in pairs(zhaoTemplate) do
                zhaoMap[zhaoId] = zhaoData
            end

            for __index, zhao in pairs(zhaoMap) do
                if tonumber(text) == zhao.id then
                    PopupLayerController:showLayer(
                        "TuJianSkillInFoPopLayer",
                        function(layer)
                            local weapon, weaponName = weapon_type_List[zhao.type]
                            if not weapon then
                                weaponName = "拳脚"
                            else
                                weaponName = weapon[3]
                            end
                            layer:setName(zhao.id)
                            layer:setSkillDetailDsc("当前招式武器为" .. weaponName .. "  玩家准备武器为" .. User:getRole():getCurrWeaponType())
                            layer:setActiveZhaoList(nil)
                            layer:playZhaoAnim_GM(zhao)
                            layer:showLayer()
                        end
                    )
                end
            end
        end
    )
end

function TestFuncLayer:setVisitTaskBtn()
    self.ListView:removeAllItems()

    self:addEditor(
        "选择拜访任务",
        "任务ID",
        function(editBox, text)
            local VisitTask = require("app.models.task.visitTask.VisitTask")
            VisitTask:createTask(text)
        end
    )

    self:addButton(
        "任务型",
        function()
            local visitTaskInfo = assert(require("script.others.bfrw"))
            local visitTaskContent = visitTaskInfo["拜访任务"]
            local list = {}
            for k, v in pairs(visitTaskContent) do
                if v.type == "任务型" then
                    table.insert(list, k)
                end
            end

            table.sort(
                list,
                function(a, b)
                    local numA = tonumber(string.sub(a, 3))
                    local numb = tonumber(string.sub(b, 3))
                    return a < b
                end
            )

            self:setVisitTaskButtonList(list)
        end
    )
    self:addButton(
        "消费型",
        function()
            local visitTaskInfo = assert(require("script.others.bfrw"))
            local visitTaskContent = visitTaskInfo["拜访任务"]
            local list = {}
            for k, v in pairs(visitTaskContent) do
                if v.type == "消费型" then
                    table.insert(list, k)
                end
            end

            table.sort(
                list,
                function(a, b)
                    local numA = tonumber(string.sub(a, 3))
                    local numb = tonumber(string.sub(b, 3))
                    return a < b
                end
            )

            self:setVisitTaskButtonList(list)
        end
    )
    self:addButton(
        "免费型",
        function()
            local visitTaskInfo = assert(require("script.others.bfrw"))
            local visitTaskContent = visitTaskInfo["拜访任务"]
            local list = {}
            for k, v in pairs(visitTaskContent) do
                if v.type == "免费型" then
                    table.insert(list, k)
                end
            end

            table.sort(
                list,
                function(a, b)
                    local numA = tonumber(string.sub(a, 3))
                    local numb = tonumber(string.sub(b, 3))
                    return a < b
                end
            )

            self:setVisitTaskButtonList(list)
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:setVisitTaskButtonList(list)
    self.ListView:removeAllItems()

    for k, v in pairs(list) do
        self:addButton(
            v,
            function()
                local VisitTask = require("app.models.task.visitTask.VisitTask")
                VisitTask:createTask(v)
            end
        )
    end

    self:addButton(
        "返回",
        function()
            self:setVisitTaskBtn()
        end
    )
end

function TestFuncLayer:setZouXue()
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton(
        "走穴冷却时间置为0",
        function()
            local role = User:getRole()
            local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")
            XingZhen:setXingZhen("行针走穴CD时间", 0)
            XingZhen:setXingZhen("行针走穴结束时间", 0)
            XingZhen:setXingZhen("散针的效果CD", 0)
            XingZhen:setXingZhen("行针失败2分钟CD", 0)
            XingZhen:setXingZhen("停针10分钟CD", 0)
            role:setDayFlag("停针次数", 0)
        end
    )

    local xueweiTable = {
        {name = "头维穴"},
        {name = "发际穴"},
        {name = "阳白穴"},
        {name = "下关穴"},
        {name = "鸠尾穴"},
        {name = "水分穴"},
        {name = "天枢穴"},
        {name = "曲池穴"},
        {name = "阳池穴"},
        {name = "神门穴"},
        {name = "少冲穴"},
        {name = "天宗穴"},
        {name = "志室穴"},
        {name = "太溪穴"},
        {name = "伏兔穴"},
        {name = "长强穴"},
        {name = "照海穴"},
        {name = "灵道穴"},
        {name = "环跳穴"},
        {name = "然谷穴"}
    }

    for i, v in pairs(xueweiTable) do
        self:addButton(
            xueweiTable[i].name,
            function()
                self:setXueWeiEffect(xueweiTable[i].name)
            end
        )
    end
end

function TestFuncLayer:setXueWeiEffect(name)
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
    local XingZhen = require("app.models.XingZhenEffects.XingZhenEffects")
    local role = User:getRole()
    if name == nil then
        return
    end
    if name == "头维穴" then
        local effrct1 = {
            {name = "真气增加1000", effrctId = "effect1000"},
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "打坐速度略微增加", effrctId = "effect1014"},
            {name = "打坐速度略微降低", effrctId = "effect1015"},
            {name = "后天悟性略微增加", effrctId = "effect1018"},
            {name = "后天悟性略微降低", effrctId = "effect1019"}
        }
        local nums = table.nums(effrct1)
        for i = 1, nums do
            self:addButton(
                effrct1[i].name,
                function()
                    XingZhen:ceShiXingZhenEffects(role, effrct1[i].effrctId)
                end
            )
        end
    elseif name == "发际穴" then
        local effrct2 = {
            {name = "经脉经验增加1250", effrctId = "effect1006"},
            {name = "体力上限略微减少", effrctId = "effect1017"},
            {name = "后天悟性略微增加", effrctId = "effect1018"},
            {name = "后天臂力略微降低", effrctId = "effect1011"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"},
            {name = "无法进行打坐", effrctId = "effect1028"}
        }
        local nums = table.nums(effrct2)
        for i = 1, nums do
            self:addButton(
                effrct2[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct2[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct2[i].effrctId)
                end
            )
        end
    elseif name == "阳白穴" then
        local effrct3 = {
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "后天身法略微降低", effrctId = "effect1013"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "体力上限略微减少", effrctId = "effect1017"},
            {name = "下次自行淬炼时成功率略微增加", effrctId = "effect1021"},
            {name = "挂机获得的经验收益略微增加", effrctId = "effect1022"},
            {name = "后天臂力略微提高", effrctId = "effect1010"}
        }
        local nums = table.nums(effrct3)
        for i = 1, nums do
            self:addButton(
                effrct3[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct3[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct3[i].effrctId)
                end
            )
        end
    elseif name == "下关穴" then
        local effrct4 = {
            {name = "后天臂力略微降低", effrctId = "effect1011"},
            {name = "后天身法略微提高", effrctId = "effect1012"},
            {name = "后天身法略微降低", effrctId = "effect1013"},
            {name = "打坐速度略微增加", effrctId = "effect1014"},
            {name = "打坐速度略微降低", effrctId = "effect1015"},
            {name = "挂机获得的经验收益略微降低", effrctId = "effect1025"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"},
            {name = "后天臂力略微提高", effrctId = "effect1010"}
        }
        local nums = table.nums(effrct4)
        for i = 1, nums do
            self:addButton(
                effrct4[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct4[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct4[i].effrctId)
                end
            )
        end
    elseif name == "鸠尾穴" then
        local effrct5 = {
            {name = "体力上限略微增加", effrctId = "effect1016"},
            {name = "体力上限略微减少", effrctId = "effect1017"},
            {name = "后天悟性略微增加", effrctId = "effect1018"},
            {name = "后天悟性略微降低", effrctId = "effect1019"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"},
            {name = "无法进行打坐", effrctId = "effect1028"},
            {name = "挂机获得的经验收益略微降低", effrctId = "effect1026"}
        }
        local nums = table.nums(effrct5)
        for i = 1, nums do
            self:addButton(
                effrct5[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct5[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct5[i].effrctId)
                end
            )
        end
    elseif name == "水分穴" then
        local effrct6 = {
            {name = "下次自行淬炼时成功率略微增加", effrctId = "effect1021"},
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "潜能增加1000", effrctId = "effect1003"},
            {name = "经脉经验增加1250", effrctId = "effect1006"},
            {name = "精神微量回复", effrctId = "effect1007"},
            {name = "真气增加1000", effrctId = "effect1000"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"}
        }
        local nums = table.nums(effrct6)
        for i = 1, nums do
            self:addButton(
                effrct6[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct6[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct6[i].effrctId)
                end
            )
        end
    elseif name == "天枢穴" then
        local effrct7 = {
            {name = "后天臂力略微降低", effrctId = "effect1011"},
            {name = "后天身法略微提高", effrctId = "effect1012"},
            {name = "潜能增加1000", effrctId = "effect1003"},
            {name = "打坐速度略微增加", effrctId = "effect1014"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "后天悟性略微降低", effrctId = "effect1019"},
            {name = "体力上限略微增加", effrctId = "effect1016"},
            {name = "后天臂力略微提高", effrctId = "effect1010"}
        }
        local nums = table.nums(effrct7)
        for i = 1, nums do
            self:addButton(
                effrct7[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct7[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct7[i].effrctId)
                end
            )
        end
    elseif name == "曲池穴" then
        local effrct8 = {
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "经脉经验增加1250", effrctId = "effect1006"},
            {name = "精神微量回复", effrctId = "effect1007"},
            {name = "挂机获得的经验收益略微降低", effrctId = "effect1026"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"}
        }
        local nums = table.nums(effrct8)
        for i = 1, nums do
            self:addButton(
                effrct8[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct8[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct8[i].effrctId)
                end
            )
        end
    elseif name == "阳池穴" then
        local effrct9 = {
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "后天身法略微降低", effrctId = "effect1013"},
            {name = "潜能增加750", effrctId = "effect1004"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "无法进行打坐", effrctId = "effect1028"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"}
        }
        local nums = table.nums(effrct9)
        for i = 1, nums do
            self:addButton(
                effrct9[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct9[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct9[i].effrctId)
                end
            )
        end
    elseif name == "神门穴" then
        local effrct10 = {
            {name = "经脉经验增加1250", effrctId = "effect1006"},
            {name = "精神微量回复", effrctId = "effect1007"},
            {name = "后天悟性略微增加", effrctId = "effect1018"},
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "打坐速度略微降低", effrctId = "effect1015"},
            {name = "真气增加1000", effrctId = "effect1000"},
            {name = "潜能增加1000", effrctId = "effect1003"},
            {name = "后天臂力略微提高", effrctId = "effect1010"}
        }
        local nums = table.nums(effrct10)
        for i = 1, nums do
            self:addButton(
                effrct10[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct10[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct10[i].effrctId)
                end
            )
        end
    elseif name == "少冲穴" then
        local effrct11 = {
            {name = "打坐速度略微降低", effrctId = "effect1015"},
            {name = "打坐速度略微降低", effrctId = "effect1015"},
            {name = "后天臂力略微降低", effrctId = "effect1011"},
            {name = "潜能增加1000", effrctId = "effect1003"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "体力上限略微减少", effrctId = "effect1017"},
            {name = "无法进行打坐", effrctId = "effect1028"},
            {name = "挂机获得的经验收益略微降低", effrctId = "effect1026"}
        }
        local nums = table.nums(effrct11)
        for i = 1, nums do
            self:addButton(
                effrct11[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct11[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct11[i].effrctId)
                end
            )
        end
    elseif name == "天宗穴" then
        local effrct12 = {
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "打坐速度略微增加", effrctId = "effect1014"},
            {name = "经脉经验增加1250", effrctId = "effect1006"},
            {name = "消耗精神", effrctId = "effect1008"},
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "下次自行淬炼时成功率略微增加", effrctId = "effect1021"},
            {name = "挂机获得的经验收益略微增加", effrctId = "effect1022"}
        }
        local nums = table.nums(effrct12)
        for i = 1, nums do
            self:addButton(
                effrct12[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct12[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct12[i].effrctId)
                end
            )
        end
    elseif name == "志室穴" then
        local effrct13 = {
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "潜能增加1000", effrctId = "effect1003"},
            {name = "精神微量回复", effrctId = "effect1007"},
            {name = "后天身法略微提高", effrctId = "effect1012"},
            {name = "体力上限略微增加", effrctId = "effect1016"},
            {name = "挂机获得的经验收益略微增加", effrctId = "effect1023"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"},
            {name = "后天臂力略微提高", effrctId = "effect1010"}
        }
        local nums = table.nums(effrct13)
        for i = 1, nums do
            self:addButton(
                effrct13[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct13[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct13[i].effrctId)
                end
            )
        end
    elseif name == "太溪穴" then
        local effrct14 = {
            {name = "后天悟性略微增加", effrctId = "effect1018"},
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "后天身法略微降低", effrctId = "effect1013"},
            {name = "经脉经验增加1250", effrctId = "effect1006"},
            {name = "精神微量回复", effrctId = "effect1007"},
            {name = "挂机获得的经验收益略微降低", effrctId = "effect1025"},
            {name = "挂机获得的经验收益略微降低", effrctId = "effect1026"}
        }
        local nums = table.nums(effrct14)
        for i = 1, nums do
            self:addButton(
                effrct14[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct14[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct14[i].effrctId)
                end
            )
        end
    elseif name == "伏兔穴" then
        local effrct15 = {
            {name = "后天臂力略微降低", effrctId = "effect1011"},
            {name = "后天身法略微提高", effrctId = "effect1012"},
            {name = "后天身法略微降低", effrctId = "effect1013"},
            {name = "潜能增加750", effrctId = "effect1004"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "无法进行挂机", effrctId = "effect1027"},
            {name = "无法进行打坐", effrctId = "effect1028"}
        }
        local nums = table.nums(effrct15)
        for i = 1, nums do
            self:addButton(
                effrct15[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct15[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct15[i].effrctId)
                end
            )
        end
    elseif name == "长强穴" then
        local effrct16 = {
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "体力上限略微增加", effrctId = "effect1016"},
            {name = "体力上限略微减少", effrctId = "effect1017"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"},
            {name = "无法进行打坐", effrctId = "effect1028"},
            {name = "后天臂力略微提高", effrctId = "effect1010"}
        }
        local nums = table.nums(effrct16)
        for i = 1, nums do
            self:addButton(
                effrct16[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct16[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct16[i].effrctId)
                end
            )
        end
    elseif name == "照海穴" then
        local effrct17 = {
            {name = "真气增加1000", effrctId = "effect1000"},
            {name = "后天臂力略微降低", effrctId = "effect1011"},
            {name = "后天身法略微提高", effrctId = "effect1012"},
            {name = "潜能增加1000", effrctId = "effect1003"},
            {name = "潜能增加750", effrctId = "effect1004"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "下次自行淬炼时成功率略微增加", effrctId = "effect1021"},
            {name = "无法进行挂机", effrctId = "effect1027"}
        }
        local nums = table.nums(effrct17)
        for i = 1, nums do
            self:addButton(
                effrct17[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct17[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct17[i].effrctId)
                end
            )
        end
    elseif name == "灵道穴" then
        local effrct18 = {
            {name = "经脉经验增加1250", effrctId = "effect1006"},
            {name = "精神微量回复", effrctId = "effect1007"},
            {name = "消耗精神", effrctId = "effect1008"},
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "挂机获得的经验收益略微增加", effrctId = "effect1022"},
            {name = "挂机获得的经验收益略微降低", effrctId = "effect1026"},
            {name = "后天臂力略微提高", effrctId = "effect1010"}
        }
        local nums = table.nums(effrct18)
        for i = 1, nums do
            self:addButton(
                effrct18[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct18[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct18[i].effrctId)
                end
            )
        end
    elseif name == "环跳穴" then
        local effrct19 = {
            {name = "后天臂力略微降低", effrctId = "effect1011"},
            {name = "后天身法略微降低", effrctId = "effect1013"},
            {name = "经脉经验增加750", effrctId = "effect1005"},
            {name = "精神微量回复", effrctId = "effect1007"},
            {name = "精神上限增加", effrctId = "effect1009"},
            {name = "后天臂力略微提高", effrctId = "effect1010"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"},
            {name = "挂机获得的经验收益略微降低", effrctId = "effect1025"}
        }
        local nums = table.nums(effrct19)
        for i = 1, nums do
            self:addButton(
                effrct19[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct19[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct19[i].effrctId)
                end
            )
        end
    elseif name == "然谷穴" then
        local effrct20 = {
            {name = "真气增加750", effrctId = "effect1002"},
            {name = "打坐速度略微增加", effrctId = "effect1014"},
            {name = "经脉经验增加1250", effrctId = "effect1006"},
            {name = "后天悟性略微增加", effrctId = "effect1018"},
            {name = "真气增加1000", effrctId = "effect1000"},
            {name = "真气减少500", effrctId = "effect1001"},
            {name = "下次冲穴时成功率略微增加", effrctId = "effect1020"}
        }
        local nums = table.nums(effrct20)
        for i = 1, nums do
            self:addButton(
                effrct20[i].name,
                function()
                    -- XingZhen:setXingZhen("行针走穴Effects",effrct20[i].effrctId)
                    XingZhen:ceShiXingZhenEffects(role, effrct20[i].effrctId)
                end
            )
        end
    end
end

function TestFuncLayer:setChenHaoBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton("添加新版头衔",function()
        self.ListView:removeAllItems()
        self:addButton(
            "返回",
            function()
                self:setChenHaoBtn()
            end
        )

        local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
        local basicTitleGroupMap = RoleTitleResManager:getBasicTitleGroupMap()
        for k, group in pairs(basicTitleGroupMap) do
            self:addButton(
                group:getName(),
                function()
                    self.ListView:removeAllItems()
                    
                    self:addButton(
                        "返回",
                        function()
                            self:setChenHaoBtn()
                        end
                    )

                    for i, titleId in ipairs(group:getTitleIdList()) do
                        local title = RoleTitleResManager:getBasicTitleClassById(titleId)

                        self:addButton(
                            title:getText(),
                            function()
                                local titleId = title:getId()
                                local role =  User:getRole()
                                if role:hasBasicTitle(titleId) then
                                    PopText("已拥有当前称号")
                                else
                                    role:addBasicTitle(titleId)
                                    PopText(title:getColorName().."添加成功")
                                end
                            end
                        )
                    end
                end
        )
        end
    end)

    self:addButton("清空新版头衔",function()
        local role = User:getRole()
        role.basicTitleData = {
            titleId = nil,
            titleList = {}
        }
        
        PopText("清除成功！！")
    end)

    self:addButton("添加旧版头衔测试",function()
        self.ListView:removeAllItems()
        self:addButton(
            "返回",
            function()
                self:setChenHaoBtn()
            end
        )
        local role = User:getRole()
        local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

        self:addButton("声望称号添加", function()
            if role:hasFamily() == false then
                PopText("当前没有加入门派")
                return
            end

            self.ListView:removeAllItems()
            self:addButton(
                "返回",
                function()
                    self:setChenHaoBtn()
                end
            )

            local function addPrestigeTitle(titleId)
                local list = Helper:getDef(role:getAttr("extraTitle"), {}) 
                local prestigeTitles = list["16"]
                if not prestigeTitles then
                    prestigeTitles = {{}}
                    list["16"] = {{}}
                end
                local prestigeTitleIds = prestigeTitles[1].title
    
                if not prestigeTitleIds then
                    prestigeTitleIds = titleId
                else
                    prestigeTitleIds = prestigeTitleIds .. ";" .. titleId
                end
    
                list["16"][1].title = prestigeTitleIds

                role:setAttr("extraTitle",list)
    
                role:setInheritFlag("已转换称号相关结构", 0)

    
                role:getTitleSystem():__repair()
            end

            local prestigeTitles = assert(clone(RoleTitleResManager:getPrestigeTitle()))
            local roleFamilyId = role:getFamilyId()

            for k, v in pairs(prestigeTitles) do
                if v.family == roleFamilyId then
                    self:addButton(v.text, function()
                        local titleId= string.gsub(v.title, "touxian", "")
                        titleId = tostring(tonumber(titleId))

                        addPrestigeTitle(titleId)
                        PopText("获得"..v.text.."称号")
                    end)
                end
            end
        end)

        local function addTitle(titleType, titleId)
            local list = Helper:getDef(role:getAttr("extraTitle"), {}) 
            list[tostring(titleType)] = Helper:getDef(list[tostring(titleType)],{})

            local tab = {
                id = titleId
            }

            table.insert(list[tostring(titleType)],tab)

            role:setAttr("extraTitle",list)

            role:setInheritFlag("已转换称号相关结构", 0)

            role:getTitleSystem():__repair()
        end

        local titles = {
            {name ="HIW资深戏迷", id = 1,titleType = 11},
            {name ="RED侠骨丹心", id = 1,titleType = 12},
            {name ="HIR红尘一梦", id = 1,titleType = 13},
            {name ="PNK宴风尘", id = 1,titleType = 14},
            {name ="DWT不离不弃", id = 1,titleType = 15},
            {name ="BLU我武惟扬", id = 1,titleType = 17},
            {name ="PNK宴四海", id = 1,titleType = 19},
            {name ="YEL笑纳珍宝", id = 1,titleType = 20},
            {name ="BLU技会群英", id = 2,titleType = 20},
            {name ="HIG鲤含青钩", id = 3,titleType = 20},
            {name ="CYN绿野鸢飞", id = 4,titleType = 20},
            {name ="HIM神风铁面", id = 5,titleType = 20},
            {name ="HIR巧敏谜思", id = 6,titleType = 20},
            {name ="MAG秀字藏客", id = 7,titleType = 20},
            {name ="YEL以武会侠", id = 8,titleType = 20},
            {name ="PNK斗酒将行", id = 9,titleType = 20},
            {name ="MAG破军论剑", id = 10,titleType = 20},
            {name ="HIR名藏五岳", id = 11,titleType = 20},
            {name ="HIY侠心未济", id = 12,titleType = 20},
            {name ="HIB天涯不老", id = 13,titleType = 20},
            {name ="HIG碧木之息", id = 14,titleType = 20},
            {name ="HIB侠者无畏", id = 15,titleType = 20},
            {name ="HIB纵酒传灯", id = 1,titleType = 21},
            {name ="HIR一 线 牵", id = 1,titleType = 22},
            {name ="HIR宴岁暮", id = 1,titleType = 23},
            {name ="HIR戍卫中原", id = 1,titleType = 24},
            {name ="YEL良缘天赐", id = 2,titleType = 13},
            {name ="RED恭贺新春", id = 1,titleType = 25},
            {name ="HIM乱世枭雄", id = 1,titleType = 26},
            {name ="HIC巧夺天工", id = 2,titleType = 22},
            {name ="RED万家灯火", id = 1,titleType = 27},
            {name ="ALS天纵之才", id = 1,titleType = 28},
            {name ="PNK红尘鹊仙", id = 3,titleType = 22},
            {name ="HIY邪不犯正", id = 1,titleType = 29},
        }

        for i = 1, #titles, 1 do
            self:addButton(titles[i].name, function()
                addTitle(titles[i].titleType, titles[i].id)
                PopText("添加"..titles[i].name.."称号成功！")
            end)
        end
    end)

    self:addEditor(
        "添加称号",
        "称号id",
        function(editBox, text)
            local role = User:getRole()
            local id = text

            if role:hasBasicTitle(id) == false then
                role:addBasicTitle(id)
                PopText("添加成功")
            end
        end
    )

    self:addEditor(
        "删除称号",
        "称号id",
        function(editBox, text)
            local role = User:getRole()
            local id = text

            if role:hasBasicTitle(id) then
                role:deleteBasicTitle(id)
                PopText("删除成功")
            end
        end
    )

    self:addButton(
        "删除新版转换标记",
        function()
            local role = User:getRole()
            role:setInheritFlag("已转换称号相关结构", nil)
            PopText("删除成功")
        end
    )

    self:addButton(
        "删除转换标记",
        function()
            local role = User:getRole()
            role:setInheritFlag("已转换称号相关结构", nil)
            PopText("删除成功")
        end
    )

    self:addButton("添加八方游历称号标记",function()
        local role = User:getRole()
        role:setInheritFlag("weekbgsq_gameTimes",100)
        role:setInheritFlag("weekxqdm_gameTimes",100)
        role:setInheritFlag("weekslcd_gameTimes",100)
        role:setInheritFlag("weekxzzy_gameTimes",100)
        role:setInheritFlag("weekhztc_gameTimes",100)
        role:setInheritFlag("mijingtanxianchenghao",100)
        role:setInheritFlag("gushuzhixichenghao",100)
        role:setInheritFlag("wjss",100)
        role:setInheritFlag("zxccbj1",100)
        PopText("添加成功！！")
    end)

    self:addButton("添加八方游历称号",function()
        local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")

        self.ListView:removeAllItems()
        self:addButton(
            "返回",
            function()
                self:setChenHaoBtn()
            end
        )

        self:addButton(
            "侠纵纸鸢称号",
            function()
                ActivityCalendarUtils:getSpecialTitle("weekhztc")
            end
        )
        
        self:addButton(
            "汇字天成称号",
            function()
                ActivityCalendarUtils:getSpecialTitle("weekxzzy")
            end
        )

        self:addButton(
            "钓鱼称号",
            function()
                ActivityCalendarUtils:getSpecialTitle("weekslcd")
            end
        )

        self:addButton(
            "登门携宝称号",
            function()
                ActivityCalendarUtils:getSpecialTitle("weekdmxb")
            end
        )

        self:addButton(
            "灯谜称号",
            function()
                ActivityCalendarUtils:getSpecialTitle("weekxqdm")
            end
        )

        self:addButton(
            "宝阁失窃称号",
            function()
                ActivityCalendarUtils:getSpecialTitle("weekbgsq")
            end
        )

        self:addButton(
            "武境三试称号",
            function()
                ActivityCalendarUtils:getSpecialTitle("weekwjss")
            end
        )

        self:addButton(
            "无间会武称号",
            function()
                ActivityCalendarUtils:getSpecialTitle("weekwjhw")
            end
        )
    end)
end

function TestFuncLayer:setInheritBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "领养孩子",
        function()
            Inherit:LingYang()
        end
    )

    self:addButton(
        "传承",
        function()
            Inherit:testInherit()
        end
    )

    self:addButton(
        "添加上一代传承角色(华山村)",
        function()
            local role = User:getRole()
            role:setAttr("yueli", 99999)
            role:setAttr("jindu", 36)
            Inherit:insertInheritHistory()
        end
    )

    self:addButton(
        "小孩恢复疲劳",
        function()
            local role = User:getRole()

            local inherit = role:getAttr("inherit")
            inherit.endurance = 1000
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:setExamBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "乡试",
        function()
            PopupLayerController:showLayer(
                "VillageExamLayer",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "省试",
        function()
            PopupLayerController:showLayer(
                "ProvinceExamLayer",
                function(layer)
                    layer:showLayer(true)
                end
            )
        end
    )

    self:addButton(
        "殿试",
        function()
            PopupLayerController:showLayer(
                "PalaceExamLayer",
                function(layer)
                    layer:showLayer("1")
                end
            )
        end
    )

    self:addButton(
        "殿试跳转",
        function()
            PopupLayerController:showLayer(
                "PalaceExamJumpLayer",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "殿试入场",
        function()
            PopupLayerController:showLayer(
                "PalaceExamEntranceLayer",
                function(layer)
                    layer:showLayer("1")
                end
            )
        end
    )

    self:addButton(
        "乡试发榜",
        function()
            local role = User:getRole()
            if role:getTimeLimitFlag("乡试") == 0 then
                PopText("本周还未参加乡试")
            else
                PopupLayerController:showLayer(
                    "ExamScoreLayer",
                    function(layer)
                        layer:showLayer("乡试")
                    end
                )
            end
        end
    )

    self:addButton(
        "省试发榜",
        function()
            local role = User:getRole()
            HttpManagerEx:getExamPoint(
                1,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            if data and data.flag ~= nil then
                                if data.cheat == 0 then
                                    PopupLayerController:showLayer(
                                        "ExamScoreLayer",
                                        function(layer)
                                            layer:showLayer("省试", data)
                                        end
                                    )
                                elseif data.cheat == 1 then
                                    PopText("尔等考场作弊，有辱斯文，竟然还有脸来看发榜？")
                                end
                            end
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
    )

    self:addButton(
        "殿试发榜",
        function()
            local role = User:getRole()
            HttpManagerEx:getExamPoint(
                2,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            if data and data.flag ~= nil then
                                PopupLayerController:showLayer(
                                    "ExamScoreLayer",
                                    function(layer)
                                        layer:showLayer("殿试", data)
                                    end
                                )
                            end
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
    )

    self:addButton(
        "结算省试成绩奖励",
        function()
            HttpManagerEx:generateExamReward(
                1,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("结算成功")
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
    )

    self:addButton(
        "结算殿试成绩奖励",
        function()
            HttpManagerEx:generateExamReward(
                2,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("结算成功")
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
    )

    self:addButton(
        "重置乡试",
        function()
            local role = User:getRole()

            role:setTimeLimitFlag("乡试", 0, 0)
        end
    )

    self:addButton(
        "重置省试殿试",
        function()
            HttpManagerEx:delUserPoint(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            print("重置成功")
                        else
                            PopText(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )

            HttpManagerEx:delUserRankReward(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            print("重置成功")
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
    )

    self:addButton(
        "删除辞官记录",
        function()
            HttpManagerEx:delOfficialLimit(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            print("删除成功")
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
    )

    self:addButton(
        "删除所有记录(进京赶考 官员)",
        function()
            HttpManagerEx:delExamAllData(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            print("删除成功")
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
    )

    -- cankao1 cankao2
    self:addButton(
        "省试道具",
        function()
            local role = User:getRole()

            role:addItemCount("cankao1", 99)
            role:addItemCount("cankao2", 99)
            role:addItemCount("zuobi1", 99)
            role:addItemCount("zuobi2", 99)
            role:addItemCount("zuobi3", 99)
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:setOfficialBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "检测是否有官职",
        function()
            HttpManagerEx:getUserOfficial(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            if data then
                                local role = User:getRole()
                                role:setAttr("officialType", data.guanzhi)
                                role:setAttr("officialAchievement", data.zhengji)
                            end
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
    )

    self:addButton(
        "辞官",
        function()
            HttpManagerEx:officialResignation(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            local role = User:getRole()
                            role:setAttr("officialType", 0)
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
    )

    self:addButton(
        "添加政绩(50)",
        function()
            local role = User:getRole()
            local officialType = role:getAttr("officialType")
            if officialType ~= 0 and officialType ~= nil then
                HttpManagerEx:uploadOfficialAchievement(
                    50,
                    officialType,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                if data then
                                    local role = User:getRole()
                                    if role:getAttr("officialType") ~= 0 then
                                        role:setAttr("officialAchievement", data.zhengji)
                                    end
                                end
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
        end
    )

    self:addButton(
        "减少政绩(-50)",
        function()
            local role = User:getRole()
            local officialType = role:getAttr("officialType")
            if officialType ~= 0 and officialType ~= nil then
                HttpManagerEx:uploadOfficialAchievement(
                    -50,
                    officialType,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                if data then
                                    local role = User:getRole()
                                    if role:getAttr("officialType") ~= 0 then
                                        role:setAttr("officialAchievement", data.zhengji)
                                    end
                                end
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
        end
    )

    self:addButton(
        "结算政绩",
        function()
            HttpManagerEx:calaOfficialAchievement(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            if data then
                                print("结算成功")
                            end
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
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:setLiteraryBtn()
    self.ListView:removeAllItems()
    local BookLiterary = require("app.models.book.BookLiterary")

    self:addButton(
        "百家典籍",
        function()
            PopupLayerController:showLayer(
                "BookLiteraryLayer",
                function(layer)
                    layer:showLayer(true)
                end
            )
        end
    )

    self:addButton(
        "添加文学典籍(背包)",
        function()
            local role = User:getRole()
            for i = 1, 29 do
                role:addItemCount("yeshushuji" .. i, 1)
            end
            role:addItemCount("shenshu100", 1)
        end
    )

    self:addButton(
        "添加文学典籍(书箱)",
        function()
            local role = User:getRole()
            for i = 1, 29 do
                role:addLiteraryBox("yeshushuji" .. i, 1)
            end
            role:addLiteraryBox("shenshu100", 1)
        end
    )

    self:addButton(
        "文学典籍 100级",
        function()
            local role = User:getRole()

            local literaryBox = role:getAttr("literaryBox")

            for i, v in ipairs(literaryBox) do
                literaryBox[i].exp = BookLiterary:getExp(100)
            end
        end
    )

    self:addButton(
        "文学典籍 200级",
        function()
            local role = User:getRole()

            local literaryBox = role:getAttr("literaryBox")

            for i, v in ipairs(literaryBox) do
                literaryBox[i].exp = BookLiterary:getExp(200)
            end
        end
    )

    self:addButton(
        "文学典籍 300级",
        function()
            local role = User:getRole()

            local literaryBox = role:getAttr("literaryBox")

            for i, v in ipairs(literaryBox) do
                literaryBox[i].exp = BookLiterary:getExp(300)
            end
        end
    )

    self:addButton(
        "文学典籍 400级",
        function()
            local role = User:getRole()

            local literaryBox = role:getAttr("literaryBox")

            for i, v in ipairs(literaryBox) do
                literaryBox[i].exp = BookLiterary:getExp(400)
            end
        end
    )
    self:addButton(
        "文学典籍 500级",
        function()
            local role = User:getRole()

            local literaryBox = role:getAttr("literaryBox")

            for i, v in ipairs(literaryBox) do
                literaryBox[i].exp = BookLiterary:getExp(500)
            end
        end
    )

    self:addButton(
        "读书识字400级",
        function()
            local role = User:getRole()
            local skill = Skill:getSkill("dushushizi")
            role:setSkill("dushushizi", {id = "dushushizi", exp = skill:getExp(400)})
        end
    )

    self:addButton(
        "读书识字500级",
        function()
            local role = User:getRole()
            local skill = Skill:getSkill("dushushizi")
            role:setSkill("dushushizi", {id = "dushushizi", exp = skill:getExp(500)})
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end


function TestFuncLayer:hiddenMeridianSysTest()
    self.ListView:removeAllItems()
    self:addButton(
        "返回",
        function()
            self:setMeridianBtn()
        end
    )
    self:addButton(
        "清除隐脉数据(清除后重启)",
        function()
            local role = User:getRole()
            role:setAttr("hiddenMeridianData",nil)
        end
    )
    
    self:addEditor(
        "修改隐脉图等级(修改后重启)",
        "等级",
        function(editBox, text)
            text = tonumber(text)
            if text == nil then
                PopText("填写非数字")
                return
            end

            local role = User:getRole()
            
            local sys = role:getHiddenMeridianSystem()
            
            local chartId = sys:getHiddenMeridianChartByLv(text):getId()
            
            local roleHiddenMeridianData = role:getAttr("hiddenMeridianData")

            roleHiddenMeridianData.currHiddenMeridianChartId = chartId

            role:setAttr("hiddenMeridianData",roleHiddenMeridianData)
        end
    )
    self:addEditor(
        "修改养真丹数量(负数为减)",
        "数量",
        function(editBox, text)
            text = tonumber(text)
            if text == nil then
                PopText("填写非数字")
                return
            end
            
            HttpManagerEx:testTeacherBuildAction(
                17,
                text,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("修改成功")
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )
    self:addEditor(
        "获取玄络(多个用#隔开)",
        "玄络id#玄络id",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("填写不能为空")
                return
            end

            local buffIds = string.split(text, "#")

            local sys = User:getRole():getHiddenMeridianSystem()
            
            if not MapIsEmpty(buffIds) then
                for i,buffId in ipairs(buffIds) do
                    if sys.__buffMap[buffId] == nil then
                        sys.__buffMap[buffId] = {}
                    end
                end
    
                sys:__saveRoleData()
            end
        end
    )
end


-- 经脉系统
function TestFuncLayer:setMeridianBtn()
    self.ListView:removeAllItems()

    self:addButton(
        "20250306隐脉功能测试",
        function()
            self:hiddenMeridianSysTest()
        end
    )

    self:addButton(
        "左右互搏",
        function()
            PopupLayerController:showLayer(
                "LeftRightFightGameLayer",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "20250121版本经脉相关",
        function()
            local MeridianDebugLayer = require("app.views.layer.DebugLayer.MeridianDebug.MeridianDebugLayer")
            MeridianDebugLayer:showui(self, function ()
                self:setMeridianBtn()
            end)
        end
    )


    self:addButton(
        "经脉重置",
        function()
            local role = User:getRole()
            local meridian = {
                -- meridianCount 已经激活的经脉数量
                -- acupointCount 当前经脉已经激活的穴道数量
                -- alreadyDisease 当前穴道是否已经暗疾
                -- alreadyDisorder 当前穴道是否已经絮乱
                -- acupointState 0 未开启 1 待冲穴 2 待固本 3 完成 4 发现暗疾 5 真气紊乱 6 激活属性 7 培元
                meridianCount = 0,
                acupointCount = 0,
                acupointState = 1,
                alreadyDisease = 0,
                alreadyDisorder = 0,
                attrList = {},
                attrTotal = {
                    ["qiMax"] = 0, -- 气血上限
                    ["neiLiLimit"] = 0, -- 内力上限
                    ["atk"] = 0, -- 攻击力
                    ["dodge"] = 0, -- 闪躲力
                    ["def"] = 0, -- 防御力
                    ["damage"] = 0, -- 伤害力
                    ["protect"] = 0 -- 防护力
                }
            }
            role:setFlag("冲穴真气", 0)
            role:setAttr("meridian", meridian)
            role:setAttr("leftRightFightExp", 0)
            role:setFlag("左右互搏入门贴获取", 0)
            role:setAttr("m_meridianImprintings" , nil)
            role:reInitMeridianSystem()
        end
    )

    self:addButton(
        "增加真气值100000",
        function()
            local role = User:getRole()
            role:addAttr("breathVal", 100000)
        end
    )

    self:addEditor(
        "修改真气值",
        "数值",
        function(editBox, text)
            local bVal = tonumber(text)

            if type(bVal) ~= "number" then
                PopText("请输入正确参数")
                return
            end

            local role = User:getRole()

            role:addAttr("breathVal", bVal)

            if bVal > 0 then
                PopText("增加真气值"..bVal)
            else
                PopText("减少真气值"..bVal)
            end
        end
    )

    self:addButton(
        "清空真气值",
        function()
            local role = User:getRole()
            role:setAttr("breathVal", 0)
        end
    )

    self:addButton(
        "经脉印记",
        function()
            self:setImprinting()
        end
    )

    self:addButton(
        "增加经脉经验 1000",
        function()
            local role = User:getRole()
            role:addAttr("meridianExp", 1000)
        end
    )

    self:addButton(
        "增加经脉道具",
        function()
            local role = User:getRole()

            role:addItemCount("jingmai100", 99)
            role:addItemCount("jingmai101", 99)
            role:addItemCount("jingmai102", 99)
            role:addItemCount("jingmai103", 99)
            role:addItemCount("jingmai104", 99)
            role:addItemCount("jingmai105", 99)
            role:addItemCount("jingmai106", 99)
        end
    )

    self:addButton(
        "打通经脉",
        function()
            self:setMeridianOpen()
        end
    )

    self:addButton(
        "重置化元次数",
        function()
            local mSkillUseRecord = User:getRole():getMSkillUseRecord()
            mSkillUseRecord.time = 0
            PopText("重置成功")
        end
    )

    self:addButton(
        "重置化元CD时间",
        function()
            local mSkillUseRecord = User:getRole():getMSkillUseRecord()
            mSkillUseRecord.firstUseTime = Helper:mathFloor(GetTime())
            PopText("重置成功")
        end
    )

    self:addButton(
        "打印加成属性",
        function()
            local role = User:getRole()
            Helper:print_lua_table_ChunWai(role._roleBuff)
        end
    )

    self:addButton(
        "打印经脉数据",
        function()
            local role = User:getRole()
            local meridian = role:getAttr("meridian")
            local leftRightFightExp = role:getAttr("leftRightFightExp")

            Helper:print_lua_table_ChunWai(meridian)
            print("leftRightFightExp = " .. leftRightFightExp)
            role:getMeridianSystem():__printMeridianData()
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

-- 打通经脉
function TestFuncLayer:setMeridianOpen()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMeridianBtn()
        end
    )

    for i = 1, 8 do
        local MeridianAcupoint = Meridian:getAcupointList(i)
        self:addButton(
            "打通" .. MeridianAcupoint[1].meridian,
            function()
                local role = User:getRole()
                local meridian = role:getAttr("meridian")
                meridian.meridianCount = i - 1
                meridian.acupointCount = #MeridianAcupoint
                meridian.attrList = {}
                for acupointIndex, v in ipairs(MeridianAcupoint) do
                    table.insert(meridian.attrList, {meridianIndex = i, acupointIndex = acupointIndex, selectNum = 3})
                end
                meridian.acupointState = 7
                role:setAttr("meridian", meridian)
            end
        )
    end
end

-- 经脉印记
function TestFuncLayer:setImprinting()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMeridianBtn()
        end
    )

    self:addButton(
        "获取所有经脉印记",
        function()
            local role = User:getRole()
            --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
            local meridianSys = role:getMeridianSystem()
            meridianSys:clearAllMeridianImprinting()
            local resList = MeridianResources:getAllMeridianImprintingRes()
            for i, v in ipairs(resList) do
                meridianSys:addMeridianImprinting(v:getImprintingId())
            end
            role:updateRoleBuff()
            PopText("添加所有经脉印记成功")
        end
    )

    self:addButton(
        "清空经脉印记",
        function()
            local role = User:getRole()
            --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
            local meridianSys = role:getMeridianSystem()
            meridianSys:clearAllMeridianImprinting()
            role:updateRoleBuff()
            PopText("清空经脉印记成功")
        end
    )

    self:addButton("当前经脉页印记置换",function ()
        PopupLayerController:showLayer(
			"replaceMeridianImprintingDebugLayer",
			function(layer)
				layer:showLayer()
			end
		)
    end)

    self:addButton("添加经脉印记",function ()
        PopupLayerController:showLayer(
			"addMeridianImprintingDebugLayer",
			function(layer)
				layer:showLayer()
			end
		)
    end)





    -- local role = User:getRole()
    -- local allImprinting = MeridianResources:getAllMeridianImprintingRes()

    -- --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
    -- local sys = role:getMeridianSystem()

    -- for k, v in pairs(Meridian:getImprinting()) do
    --     local role = User:getRole()
    --     local meridianImprinting = role:getAttr("meridianImprinting")

    --     if role:isHaveImprintingId(v.imprintingId) ~= true then
    --         self:addButton(
    --             "添加" .. v.name,
    --             function()
    --                 table.insert(meridianImprinting, {imprintingId = v.imprintingId})
    --                 role:setAttr("meridianImprinting", meridianImprinting)
    --                 role:updateRoleBuff()
    --                 self:setImprinting()
    --             end
    --         )
    --     else
    --         self:addButton(
    --             "移除" .. v.name,
    --             function()
    --                 for i, imprinting in ipairs(meridianImprinting) do
    --                     if v.imprintingId == imprinting.imprintingId then
    --                         table.remove(meridianImprinting, i)
    --                         role:setAttr("meridianImprinting", meridianImprinting)
    --                         role:updateRoleBuff()
    --                         break
    --                     end
    --                 end
    --                 self:setImprinting()
    --             end
    --         )
    --     end
    -- end
end

-- 副本功能测试
function TestFuncLayer:setMapBtn()
    self.ListView:removeAllItems()

    self:addButton(
        "编辑器副本NPC拳脚准备检查",
        function()
            local failMap = {}

            local defaultMap = Map:getDefaultMapById("fb41")

            local mapInfos = require("script.newmap.map.mapInfo")

            for i, v in ipairs(mapInfos) do
                local mapId = v.id

                local mapData = require("script.newmap.map.maps." .. mapId)

                local skillRes = require("script.newbattle.demo.skillRes")["武学"]

                local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")

                if table.getn(mapData.unitList) > 0 then
                    for _, unitInfo in ipairs(mapData.unitList) do
                        if table.getn(unitInfo.behaviourStageList) > 0 then
                            for stageNum, stage in ipairs(unitInfo.behaviourStageList) do
                                if table.getn(stage.skillPrepare) > 0 then
                                    for k, v in pairs(stage.skillPrepare) do
                                        if v.preSkillType == 0 or v.preSkillType == 1 then
                                            local skillId = v.skillId
                                            if skillRes[skillId] ~= nil then
                                                local fightSkill = SkillFactory:createSkill(skillId, 1)

                                                if not fightSkill:isQuanJiaoSkill() then
                                                    table.insert(
                                                        failMap,
                                                        {
                                                            mapId = mapId,
                                                            name = unitInfo.name,
                                                            unitId = unitInfo.id,
                                                            stageId = unitInfo.stageId
                                                        }
                                                    )
                                                end
                                            else
                                                assert(false, "技能id不存在")
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if table.getn(failMap) > 0 then
                print(tabel.tostring(failMap))
            else
                PopText("检查完毕，无错误")
            end
        end
    )

    self:addButton(
        "选择通关章节",
        function()
            self.ListView:removeAllItems()
            self:addButton(
                "返回",
                function()
                    self:setMapBtn()
                end
            )
            self:addEditor(
                "章节序列（如第十章 填10）",
                40,
                function(editBox, text)
                    if text == nil or text == "" then
                        PopText("请输入正确参数")
                        return
                    end

                    local index = tonumber(text)

                    local role = User:getRole()
                    local MapList = Map:getMapListWithFilter()
                    for i, v in pairs(MapList) do
                        if i <= index then
                            role:setMapCompleted(v.id)
                        end
                    end
                    PopText("已通关前" .. text .. "章节")
                end
            )
        end
    )

    self:addButton(
        "清除章节通关记录",
        function()
            self.ListView:removeAllItems()
            self:addButton(
                "返回",
                function()
                    self:setMapBtn()
                end
            )
            self:addEditor(
                "章节序列（如第十章 填10）",
                40,
                function(editBox, text)
                    if text == nil or text == "" then
                        PopText("请输入正确参数")
                        return
                    end

                    local index = tonumber(text)

                    local role = User:getRole()
                    local MapList = Map:getMapListWithFilter()
                    for i, v in pairs(MapList) do
                        if i <= index then
                            local mapState = role:getMapState(v.id)
                            mapState.isCompleted = false
                        end
                    end
                    PopText("已清除前" .. text .. "章节通关记录")
                end
            )
        end
    )

    self:addButton(
        "赌场",
        function()
            PopupLayerController:showLayer(
                "GamblingHouseLayer",
                function(layer)
                    layer:showLayer(
                        function()
                        end,
                        ""
                    )
                end
            )
        end
    )

    self:addButton(
        "刘寻山洗髓",
        function()
            local AttrPointRemovePresenters = require("app.presenters.AttrPointRemove.AttrPointRemovePresenters"):create()
            local AttrPointRemoveLayer = PopupLayerController:getLayer("AttrPointRemoveLayer")
            local AttrPointRemove = require("app.models.AttrPointRemove.AttrPointRemove")
            AttrPointRemovePresenters:setDataModel(AttrPointRemove)
            AttrPointRemovePresenters:setViewModel(AttrPointRemoveLayer)
            AttrPointRemovePresenters:setRole(User:getRole())
            AttrPointRemovePresenters:showLayer()
        end
    )

    self:addButton(
        "赛龙舟",
        function()
            PopupLayerController:showLayer(
                "DragonBoatLayer",
                function(layer)
                    layer:showLayer(nil, false)
                end
            )
        end
    )

    self:addButton(
        "放风筝不刮风模式",
        function()
            PopupLayerController:showLayer(
                "KiteLayer",
                function(layer)
                    local data = User:getRole():getFlag("风筝刮风测试数据")
                    local height = User:getRole():getFlag("风筝刮风随机高度")
                    if data ~= 0 then
                        layer:setTestWindyLevel(data)
                    end

                    if height ~= 0 then
                        layer:setRandomHeight(height)
                    end

                    layer:setTestWindyClose()
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "放风筝正常模式",
        function()
            PopupLayerController:showLayer(
                "KiteLayer",
                function(layer)
                    local data = User:getRole():getFlag("风筝刮风测试数据")
                    local height = User:getRole():getFlag("风筝刮风随机高度")
                    if data ~= 0 then
                        layer:setTestWindyLevel(data)
                    end

                    if height ~= 0 then
                        layer:setRandomHeight(height)
                    end

                    layer:setTestWindyOpen()
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "设置放风筝刮风频率参数",
        function()
            self.ListView:removeAllItems()
            self:addButton(
                "返回",
                function()
                    self:setMapBtn()
                end
            )
            self:addEditor(
                "刮风频率参数",
                "5;5;4.5;4;3",
                function(editBox, text)
                    if text == nil or text == "" then
                        PopText("请输入正确参数")
                        return
                    end

                    local str = string.split(text, ";")
                    table.sort(
                        str,
                        function(a, b)
                            if a > b then
                                return true
                            else
                                return false
                            end
                        end
                    )

                    local data = {}
                    local index = 1
                    for k, v in pairs(str) do
                        data[index] = tonumber(v)
                        index = index + 1
                    end

                    User:getRole():setFlag("风筝刮风测试数据", data)
                end
            )
        end
    )

    self:addButton(
        "设置放风筝刮风随机高度",
        function()
            self.ListView:removeAllItems()
            self:addButton(
                "返回",
                function()
                    self:setMapBtn()
                end
            )
            self:addEditor(
                "刮风随机高度",
                20,
                function(editBox, text)
                    if text == nil or text == "" then
                        PopText("请输入正确参数")
                        return
                    end

                    local height = tonumber(text)

                    User:getRole():setFlag("风筝刮风随机高度", height)
                end
            )
        end
    )

    self:addButton(
        "清除放风筝测试数据",
        function()
            User:getRole():setFlag("风筝刮风测试数据", nil)
            User:getRole():setFlag("风筝刮风随机高度", nil)
        end
    )

    self:addButton(
        "控制副本状态",
        function()
            self:setMapState()
        end
    )

    self:addButton(
        "完成平安小镇前置",
        function()
            User:getRole():setFlag("完成平安前置", 1)
        end
    )

    self:addButton(
        "完成武林盟前置",
        function()
            User:getRole():setFlag("完成武林盟前置", 1)
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:setMapState()
    self.ListView:removeAllItems()
    local role = User:getRole()
    local MapList = Map:getMapListWithFilter()
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
    for i, v in pairs(MapList) do
        local mapId = v.id
        local mapState = role:getMapState(mapId)
        if mapState.isCompleted == false then
            self:addButton(
                "设置" .. v.name .. "通关",
                function()
                    mapState.isCompleted = true
                    PopText("通关成功")
                    self:setMapState()
                end
            )
        else
            self:addButton(
                "重置" .. v.name .. "副本",
                function()
                    mapState.isCompleted = false
                    PopText("重置成功")
                    self:setMapState()
                end
            )
        end
    end
end

function TestFuncLayer:setRecharge()
    self.ListView:removeAllItems()

    local function recharge(r_type)
        HttpManagerEx:testChongzhi(
            r_type,
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    PopText("充值成功")
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end

    self:addButton(
        "6元",
        function()
            recharge(1)
        end
    )

    self:addButton(
        "18元",
        function()
            recharge(2)
        end
    )

    self:addButton(
        "60元",
        function()
            recharge(3)
        end
    )

    self:addButton(
        "168元",
        function()
            recharge(4)
        end
    )

    self:addButton(
        "江湖名士",
        function()
            recharge(5)
        end
    )

    self:addButton(
        "珍品阁五连抽礼包",
        function()
            recharge("1/com.mkjump.fzjha.product103")
        end
    )

    self:addButton(
        "拳脚武学礼包",
        function()
            recharge("1/com.mkjump.fzjha.product104")
        end
    )

    self:addButton(
        "内功武学礼包",
        function()
            recharge("1/com.mkjump.fzjha.product111")
        end
    )

    self:addButton(
        "兵器武学礼包",
        function()
            recharge("1/com.mkjump.fzjha.product118")
        end
    )

    self:addButton(
        "轻功武学礼包",
        function()
            recharge("1/com.mkjump.fzjha.product125")
        end
    )

    self:addEditor(
        "充值礼包",
        "对应充值key",
        function(editBox, text)
            local key = "1/" .. text
            recharge(key)
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:gameTimeModify()
    self.ListView:removeAllItems()
    self:addTimeEditor(
        "修改时间",
        function(item)            
            local year = Helper:getDef(tonumber(item:getChildByTag(770):getText()), tonumber(item:getChildByTag(770):getPlaceHolder()))
            local month = Helper:getDef(tonumber(item:getChildByTag(771):getText()), tonumber(item:getChildByTag(771):getPlaceHolder()))
            local day = Helper:getDef(tonumber(item:getChildByTag(772):getText()), tonumber(item:getChildByTag(772):getPlaceHolder()))
            local hour = Helper:getDef(tonumber(item:getChildByTag(773):getText()), tonumber(item:getChildByTag(773):getPlaceHolder()))
            local minute = Helper:getDef(tonumber(item:getChildByTag(774):getText()), tonumber(item:getChildByTag(774):getPlaceHolder()))
            
            local time = {
                year = year,
                month = month,
                day = day,
                hour = hour,
                min = minute
            }

            local SyncWebTime = require("app.models.syncWebTime.SyncWebTime")
            SyncWebTime:setOpen(false)
            
            Helper:print_lua_table(time)
            print(os.time(time))
            WEB_TIME = os.time(time)
            print(WEB_TIME)
            PopText("时间设置成功" .. Helper:date("%x %X", WEB_TIME));
        end
    )

    self:addEditor(
        "提前游戏时间",
        "填写小时数（确定后游戏将重启）",
        function(editBox, text)
            local hour = tonumber(text)
            if hour == nil then
                PopText("请填写正确的数字")
                return
            end
            local time = hour * 3600

            local role = User:getRole()
            local currGameTime = role:getFlag("游戏时间")

            role:setFlag("游戏时间", math.max(currGameTime - time))

            Game:restart()
        end
    )

    self:addEditor(
        "设置游戏时间",
        "填秒（游戏时长6天为玩家角色1岁，初始为14岁）",
        function(editBox, text)
            local sec = tonumber(text)
            if sec == nil then
                PopText("请填写正确的数字")
                return
            end

            if sec <= 0 then
                PopText("请填写大于0的数字")
                return
            end

            local role = User:getRole()

            role:setAttr("gamingTime", sec)
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:shenBingGM()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:playerWeaponButtons()
        end
    )

    local godweaponTemplate = require("script.others.godweaponTemplate")
    if MapIsEmpty(godweaponTemplate) then
        PopText("不存在策划资源模板")
        return
    end

    local shenBingTemplateList = godweaponTemplate["Sheet1"]

    if MapIsEmpty(shenBingTemplateList) then
        PopText("暂无神兵模板")
        return
    end

    for k, data in pairs(shenBingTemplateList) do
        if data.open == 1 then
            self:addButton(
                data.name,
                function()
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:setWeChatVisible(false)
                    dialog:show("确定使用模板数据替换当前神兵数据？")
                    dialog:setButton1(
                        "确定",
                        function()
                            local role = User:getRole()
                            local shenBingweapons =
                                role:getItems(
                                function(item)
                                    return item.type == "神兵"
                                end
                            )

                            if MapIsEmpty(shenBingweapons) == false then
                                local shenBingweapon = role:getOneItemByKey(shenBingweapons[1].itemId)
                                shenBingweapon.typeDesc = string.gsub(shenBingweapon.typeDesc, shenBingweapon.bType, data.bType)

                                shenBingweapon.wanhaodu = data.wanhaodu
                                shenBingweapon.bType = data.bType
                                shenBingweapon.rendu = data.rendu
                                shenBingweapon.damage = data.damage
                                shenBingweapon.yindu = data.yindu
                                shenBingweapon.type = data.type
                                shenBingweapon.weight = data.weight
                                shenBingweapon.cuilianCount = data.cuilianCount
                                shenBingweapon.effctNum = data.effctNum
                                shenBingweapon.equipDescId = nil
                                shenBingweapon.equipDescId = ShenBingDesc:getRandomWeaponWeardes(shenBingweapon)

                                shenBingweapon.desc = ShenBingDesc:getShenBingDesc(shenBingweapon)
                                local effectList = ShenBingEffct:getShenBingTypeEffect(data.bType)
                                shenBingweapon.effct1 = effectList[1]
                                shenBingweapon.effct2 = effectList[2]
                                shenBingweapon.effct3 = effectList[3]

                                if data.effctNum < 100 then
                                    shenBingweapon.effct2 = ""
                                    shenBingweapon.effct3 = ""
                                elseif data.effctNum >= 100 and data.effctNum < 200 then
                                    shenBingweapon.effct3 = ""
                                end

                                local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
                                ShenBingDuanZao:updateShenBingInfo(shenBingweapon, role)

                                if role._shenbingCache and role._shenbingCache[shenBingweapons[1].itemId] then
                                    role._shenbingCache[shenBingweapons[1].itemId] = nil
                                end
                                PopText("转化成功！！")
                            else
                                PopText("当前无神兵！！")
                            end
                        end
                    )
                    dialog:setButton2(
                        "取消",
                        function()
                        end
                    )
                end
            )
        end
    end
end

--@desc: 奖励策略测试
--@author:Seven
--@time:2023-06-21 14:53:49
function TestFuncLayer:addRewardManager()
    self.ListView:removeAllItems()
    self:addEditor(
        "副本玩家属性变化测试",
        "属性名;属性值;func(add|set)",
        function(editBox, text)
            local tab = string.split(tostring(text),";")
            assert(tab[1] and tab[2] and tab[3],"输入格式错误")
            local attrName = tab[1]
            local addValue = tonumber(tab[2])
            local func = tab[3]
            local AttrRecord = require("app.models.Record.UserAttrRecord.AttrRecord")
            local AttrDoChange = require("app.models.role.attr.AttrDoChange")

            --@RefType [src.app.models.role.attr.AttrDoChange#AttrDoChange]
            local doChangeAttr =
                AttrDoChange:create(
                User:getRole(),
                AttrRecord.R_TYPE.MAP_RESULT,
                attrName,
                addValue,
                {
                    mapid = "fb01",
                    npcid = "dafda",
                    func = func,
                    rlt = "玩家属性变化"
                }
            )

            doChangeAttr:doAttrGet(function (attrName,value)
                PopText("属性变化记录成功，具体信息查看控制台")
            end)
        end
    )

    self:addEditor(
        "物品直接奖励测试",
        "请输入物品id",
        function(editBox, text)
            local itemid = tostring(text)
            local UseItemDirectRewardGet = require("app.models.reward.UseItemDirectRewardGet")
            local item = Item:getOneItemByKey(itemid)
            local role = User:getRole()

            local rewardGet = UseItemDirectRewardGet:create(item,role)
            rewardGet:doGetReward(function (rewardArray)
                PopText("物品直接奖励打开成功，具体信息查看控制台")
            end)
        end
    )

    self:addEditor(
        "副本打开奖励测试",
        "请输入奖励策略id",
        function(editBox, text)
            local rewardId = tostring(text)
            local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")
            local openRewardGet =
                require("app.models.reward.OpenRewardGet"):create(
                User:getRole(),
                string.split(rewardId, ";"),
                ARewardRecord.RTYPE.MAP_RESULT,
                "mapRewardArrayWithRewardSchemeArray",
                {
                    mapid = "fb01",
                    npcid = "dddd",
                    rlt = "策略奖励"
                }
            )

            openRewardGet:doGetReward(
                function(rewards)
                    PopText("副本奖励打开成功，具体信息查看控制台")
                end
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

function TestFuncLayer:playerWeaponButtons()
    self.ListView:removeAllItems()

    self:addButton(
        "神兵",
        function()
            self:shenBingWeapon()
        end
    )

    self:addButton(
        "神兵模板",
        function()
            local role = User:getRole()
            local shenBingItems = role:getAttr("shenBingItems")
            if #shenBingItems < 1 then
                PopText("背包中暂无神兵，无法使用该功能！")
                return
            end

            self:shenBingGM()
        end
    )

    self:addButton(
        "神兵重铸",
        function()
            PopupLayerController:showLayer(
                "ShenBingRemakeLayer",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "干将莫邪",
        function()
            local Item = require("app.models.item.Item")
            local item = Item:getOneItemByKey("dundifu")
            User:getRole():initMapById("fb18")
            User:getRole():setFlag("fb18", User:getRole():getFlag("fb18") - MAP_REFRESH_INTERVAL)
            item:useDunDiFu(
                User:getRole(),
                "fb18",
                "fb18_82",
                function()
                    self:setVisible(false)
                end
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

function TestFuncLayer:activityButtons()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton(
        "大侠成长之路进度清空",
        function()
            local role = User:getRole()
            for i = 1, 100, 1 do
                role:setInheritFlag("jhhyl" .. i, nil)
            end

            PopText("清空成功！")
        end
    )

    self:addButton("商品预览查看",function()
        self:viewGoodsList()
    end)

    self:addEditor(
        "多个商品组合预览查看",
        "商品表id;商品表id;......",
        function(editBox, text)
            if text == nil then
                PopText("请输出参数！！")
                return
            end

            local goodsList = {}
            local list = string.split(text, ";")
            for i, v in ipairs(list) do
                if not shoplistRes[tostring(v)] then
                    PopText("商品id异常, id:"..tostring(v))
                    return
                end

                table.insert(goodsList, {id = v})
            end

            PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                layer:showLayer(goodsList)
            end)
        end
    )
end

function TestFuncLayer:viewGoodsList()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:activityButtons()
        end
    )

    local maskList = {}
    local appearanceList = {}
    local normalList = {}
    local skillList = {}
    local boxList = {}

    for id, goodsInfo in pairs(shoplistRes) do
        local goodsViewType = goodsInfo.viewtype
        switch(goodsViewType,
                {
                    [Goods.Const.VIEWTYPE.MASK] = function()
                        table.insert(maskList, id)
                    end,
                    [Goods.Const.VIEWTYPE.APPEARANCE] = function()
                        table.insert(appearanceList, id)
                    end,
                    [Goods.Const.VIEWTYPE.SKILL] = function()
                        table.insert(skillList, id)
                    end,
                    [Goods.Const.VIEWTYPE.BOX] = function()
                        table.insert(boxList, id)
                    end,
                    default = function()
                        table.insert(normalList, id)
                    end,
                }
            )
    end

    self:addButton(
        "查看面具类商品预览",
        function()
            self.ListView:removeAllItems()

            self:addButton(
                "返回",
                function()
                    self:viewGoodsList()
                end
            )

            for i = 1, #maskList, 1 do
                local goods = GoodsHelper:getGoodsResClass(maskList[i])
                self:addButton(goods:getName(),function()
                    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                        layer:showLayer({{id = maskList[i]}})
                    end)
                end)
            end
        end
    )

    self:addButton(
        "查看挂饰类商品预览",
        function()
            self.ListView:removeAllItems()

            self:addButton(
                "返回",
                function()
                    self:viewGoodsList()
                end
            )

            for i = 1, #appearanceList, 1 do
                local goods = GoodsHelper:getGoodsResClass(appearanceList[i])
                self:addButton(goods:getName(),function()
                    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                        layer:showLayer({{id = appearanceList[i]}})
                    end)
                end)
            end
        end
    )

    self:addButton(
        "查看武学类商品预览",
        function()
            self.ListView:removeAllItems()

            self:addButton(
                "返回",
                function()
                    self:viewGoodsList()
                end
            )

            for i = 1, #skillList, 1 do
                local goods = GoodsHelper:getGoodsResClass(skillList[i])
                self:addButton(goods:getName(),function()
                    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                        layer:showLayer({{id = skillList[i]}})
                    end)
                end)
            end
        end
    )

    self:addButton(
        "查看宝箱类商品预览",
        function()
            self.ListView:removeAllItems()

            self:addButton(
                "返回",
                function()
                    self:viewGoodsList()
                end
            )

            for i = 1, #boxList, 1 do
                local goods = GoodsHelper:getGoodsResClass(boxList[i])
                self:addButton(goods:getName(),function()
                    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                        layer:showLayer({{id = boxList[i]}})
                    end)
                end)
            end
        end
    )

    self:addButton(
        "查看普通类商品预览",
        function()
            self.ListView:removeAllItems()

            self:addButton(
                "返回",
                function()
                    self:viewGoodsList()
                end
            )

            for i = 1, #normalList, 1 do
                local goods = GoodsHelper:getGoodsResClass(normalList[i])
                self:addButton(goods:getName(),function()
                    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                        layer:showLayer({{id = normalList[i]}})
                    end)
                end)
            end
        end
    )
end

function TestFuncLayer:taskButtons()
    self.ListView:removeAllItems()

    self:addButton(
        "主动任务",
        function()
            self:setTakBtn()
        end
    )

    self:addButton(
        "拜访任务",
        function()
            self:setVisitTaskBtn()
        end
    )

    self:addButton(
        "师门任务",
        function()
            self:setTeacherTaskBtn()
        end
    )

    self:addButton(
        "神书任务",
        function()
            self:setShenShuBtn()
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:setTeacherTaskBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "重置刷新任务次数",
        function()
            TeacherTask:setTeacherTaskAttr("refreshCount", 0)
             --任务刷新次数
            PopText("任务刷新次数已重置")
            print("refreshCount", tonumber(TeacherTask:getTeacherTaskAttr("refreshCount")))
        end
    )
    self:addButton(
        "重置任务完成次数",
        function()
            HttpManagerEx:resetTeacherTask(
                5,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            TeacherTask:setTeacherTaskAttr("dCount", 0)
                            PopText("师门任务接取次数已重置")
                        end
                    end
                end
            )
        end
    )
    self:addButton(
        "放弃任务时间",
        function()
            TeacherTask:setTeacherTaskAttr("giveUpTime", GetTime())
            PopText("放弃任务时间已重置")
        end
    )
    self:addButton(
        "重置贡献点",
        function()
            HttpManagerEx:resetTeacherTask(
                4,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("师门任务获得的贡献点已经重置")
                            TeacherTask:setTeacherTaskAttr("ContributionPoint", 0)
                        end
                    end
                end
            )
        end
    )
    self:addButton(
        "重置刷新指派次数",
        function()
            TeacherTask:setTeacherTaskAttr("appointRefreshCount", 0)
             --指派任务刷新次数
            HttpManagerEx:resetTeacherTask(
                2,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("师门任务指派次数已重置")
                        end
                    end
                end
            )
        end
    )
    self:addButton(
        "重置指派次数",
        function()
            TeacherTask:setTeacherTaskAttr("appointCount", 0)
             --指派任务刷新次数
            HttpManagerEx:resetTeacherTask(
                3,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("师门任务指派次数已重置")
                        end
                    end
                end
            )
        end
    )
    self:addButton(
        "重置领取次数",
        function()
            -- TeacherTask:setTeacherTaskAttr("appointRefreshCount",0)--指派任务刷新次数
            HttpManagerEx:resetTeacherTask(
                1,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("指派奖励领取次数")
                        end
                    end
                end
            )
        end
    )
    self:addButton(
        "重置领取状态",
        function()
            -- TeacherTask:setTeacherTaskAttr("appointRefreshCount",0)--指派任务刷新次数
            HttpManagerEx:resetTeacherTask(
                0,
                function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 then
                        if errcode == 0 then
                            PopText("重置指派奖励领取状态")
                        end
                    end
                end
            )
        end
    )
    self:addButton(
        "重置领取任务",
        function()
            TeacherTask:setTeacherTaskAttr("receiveTask", 0)
        end
    )
    self:addButton(
        "重置接取次数",
        function()
            TeacherTask:setTeacherTaskAttr("count", 0)
        end
    )
    self:addButton(
        "返回",
        function()
            self:taskButtons()
        end
    )
end

--主动任务
function TestFuncLayer:setTakBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "完成飞贼一次",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task16"]
            User:getRole():setAttr("currTaskId", "task16")
            task_task16.state = Helper:getDef(task_task16.state, TASK_STATE_ACCEPT)
            task_task16.state = TASK_STATE_TO_SUBMIT
            task["task16"] = task_task16
            User:setRoleAttr("tasks", task)
            PopText("飞贼任务完成一次")
        end
    )
    self:addButton(
        "重置飞贼任务",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task16"]
            User:getRole():setAttr("currTaskId", nil)
            task_task16.dCount = Helper:getDef(task_task16.dCount, 0)
            task_task16.cCount = Helper:getDef(task_task16.cCount, 50)
            task_task16.dCount = 0
            task_task16.cCount = 50
            task_task16.state = TASK_STATE_ACCEPT
            task["task16"] = task_task16
            User:setRoleAttr("tasks", task)
            User:getRole():setDayFlag("飞贼任务奖励", 0)
            PopText("飞贼任务次数已重置")
        end
    )
    self:addButton(
        "重置南阳次数",
        function()
            local role = User:getRole()
            local roleTask = role:getTask("task17")
            roleTask.dCount = 0
            if roleTask.state == TASK_STATE_COMPLETE then
                roleTask.state = TASK_STATE_IDLE
            end
        end
    )
    self:addButton(
        "完成历练一次",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task15"]
            User:getRole():setAttr("currTaskId", "task15")
            task_task16.state = Helper:getDef(task_task16.state, TASK_STATE_ACCEPT)
            task_task16.state = TASK_STATE_TO_SUBMIT
            task["task15"] = task_task16
            User:setRoleAttr("tasks", task)
            PopText("历练任务完成一次")
        end
    )
    self:addButton(
        "重置历练任务",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task15"]
            User:getRole():setAttr("currTaskId", nil)
            task_task16.dCount = Helper:getDef(task_task16.dCount, 0)
            task_task16.cCount = Helper:getDef(task_task16.cCount, 5)
            task_task16.dCount = 0
            task_task16.cCount = 5
            task_task16.state = TASK_STATE_ACCEPT
            task["task15"] = task_task16
            User:setRoleAttr("tasks", task)
            PopText("历练任务次数已重置")
        end
    )
    self:addButton(
        "完成匪乱一次",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task17"]
            User:getRole():setAttr("currTaskId", "task17")
            task_task16.state = Helper:getDef(task_task16.state, TASK_STATE_ACCEPT)
            task_task16.state = TASK_STATE_TO_SUBMIT
            task["task17"] = task_task16
            User:setRoleAttr("tasks", task)
            PopText("匪乱任务完成一次")
        end
    )
    self:addButton(
        "重置匪乱任务",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task17"]
            User:getRole():setAttr("currTaskId", nil)
            task_task16.dCount = Helper:getDef(task_task16.dCount, 0)
            task_task16.cCount = Helper:getDef(task_task16.cCount, 3)
            task_task16.dCount = 0
            task_task16.cCount = 3
            task_task16.state = TASK_STATE_ACCEPT
            task["task17"] = task_task16
            User:setRoleAttr("tasks", task)
            User:getRole():setDayFlag("南阳匪贼任务奖励", 0)
            PopText("匪乱任务次数已重置")
        end
    )
    self:addButton(
        "完成送信一次",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task19"]
            User:getRole():setAttr("currTaskId", "task19")
            task_task16.state = Helper:getDef(task_task16.state, TASK_STATE_ACCEPT)
            task_task16.state = TASK_STATE_TO_SUBMIT
            task["task19"] = task_task16
            User:setRoleAttr("tasks", task)
            PopText("送信任务完成一次")
        end
    )
    self:addButton(
        "重置送信任务",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task19"]
            User:getRole():setAttr("currTaskId", nil)
            task_task16.dCount = Helper:getDef(task_task16.dCount, 0)
            task_task16.cCount = Helper:getDef(task_task16.cCount, 50)
            task_task16.dCount = 0
            task_task16.cCount = 50
            task_task16.state = TASK_STATE_ACCEPT
            task["task19"] = task_task16
            User:setRoleAttr("tasks", task)
            User:getRole():setDayFlag("信使任务奖励", 0)
            PopText("送信任务次数已重置")
        end
    )
    self:addButton(
        "完成缉拿一次",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task20"]
            User:getRole():setAttr("currTaskId", "task20")
            task_task16.state = Helper:getDef(task_task16.state, TASK_STATE_ACCEPT)
            task_task16.state = TASK_STATE_TO_SUBMIT
            task["task20"] = task_task16
            User:setRoleAttr("tasks", task)
            PopText("缉拿任务完成一次")
        end
    )
    self:addButton(
        "重置缉拿任务",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task20"]
            User:getRole():setAttr("currTaskId", nil)
            task_task16.dCount = Helper:getDef(task_task16.dCount, 0)
            task_task16.cCount = Helper:getDef(task_task16.cCount, 50)
            task_task16.dCount = 0
            task_task16.cCount = 50
            task_task16.state = TASK_STATE_ACCEPT
            task["task20"] = task_task16
            User:setRoleAttr("tasks", task)
            User:getRole():setDayFlag("缉拿任务奖励", 0)
            PopText("缉拿任务次数已重置")
        end
    )
    self:addButton(
        "完成限时任务一次",
        function()
            User:getRole():setInheritFlag("腊八施粥", 2)
            PopText("限时任务完成一次")
        end
    )
    self:addButton(
        "完成古寺一次",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task21"]
            User:getRole():setAttr("currTaskId", "task20")
            task_task16.state = Helper:getDef(task_task16.state, TASK_STATE_ACCEPT)
            task_task16.state = TASK_STATE_TO_SUBMIT
            task["task21"] = task_task16
            User:setRoleAttr("tasks", task)
            PopText("古寺任务完成一次")
        end
    )
    self:addButton(
        "重置古寺任务",
        function()
            local task = User:getRoleAttr("tasks")
            local task_task16 = task["task21"]
            User:getRole():setAttr("currTaskId", nil)
            task_task16.dCount = Helper:getDef(task_task16.dCount, 0)
            task_task16.cCount = Helper:getDef(task_task16.cCount, 50)
            task_task16.dCount = 0
            task_task16.cCount = 1
            task_task16.state = TASK_STATE_ACCEPT
            task["task21"] = task_task16
            User:setRoleAttr("tasks", task)
            PopText("古寺任务次数已重置")
        end
    )
    self:addButton(
        "重置师门孝敬次数",
        function()
            HttpManagerEx:resetDailyRecord(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("师门孝敬每日次数已重置")
                    else
                        PopText("网络异常")
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )
    self:addButton(
        "重置限时任务腊八次数",
        function()
            local player = User:getRole()
            local roletask = player:getTask("task18")
            roletask.dCount = 0
            roletask.zCount = 0
            roletask.cCount = 1
            roletask.state = 3
            PopText("重置限时任务完成")
        end
    )
    self:addButton(
        "返回",
        function()
            self:taskButtons()
        end
    )
end

function TestFuncLayer:setShenShuBtn()
    self.ListView:removeAllItems()
    self:addButton(
        "添加神书",
        function()
            for i = 1, 42 do
                User:getRole():addItemCount("shenshu" .. tostring(i), 1)
            end
            PopText("添加神书")
        end
    )
    self:addButton(
        "重置神书任务",
        function()
            local role = User:getRole()
            local ShenShuHelper = require("app.models.shenshu.shenshu")
            ShenShuHelper:resetTask(role)
            PopText("重置神书任务成功")
        end
    )

    self:addButton("使用旧版神书",function()
        DebugHelper:setShenShuVersion(0)
        PopText("设置成功，已设置为旧版神书")
    end)

    self:addButton("使用新版神书",function()
        DebugHelper:setShenShuVersion(1)
        PopText("设置成功，已设置为新版神书")
    end)

    self:addButton(
        "结束神书任务",
        function()
            local role = User:getRole()
            local shenShuTask = role:getAttr("shenShuTask")
            local task = shenShuTask.task
            if task.startTime == -1 then
                PopText("未开启神书任务")
                return
            end

            task.startTime = task.startTime - 3600
            PopText("结束神书任务成功")
        end
    )

    self:addButton(
        "结束神书送礼",
        function()
            local role = User:getRole()
            local shenShuSongLiInfo = role:getAttr("shenShuSongLiInfo")
            
            if shenShuSongLiInfo.startTime == -1 then
                PopText("未开启神书送礼")
                return
            end

            shenShuSongLiInfo.startTime = shenShuSongLiInfo.startTime - 3600 * 24
            PopText("结束神书送礼成功")
        end
    )

    self:addEditor(
        "设置灵石开始时间",
        "格式20250613",
        function(editBox, text)
            local stringDate = text

            if stringDate == nil or string.len(stringDate) ~= 8 or tonumber(stringDate) == nil then
                PopText("请输入正确的时间格式")
                return
            end

            local time = Helper:getTimeStampWithStringDate(stringDate, 0)
            local role = User:getRole()
            local shenShuTask = role:getAttr("shenShuTask")
            if shenShuTask.startTime == -1 then
                PopText("未开启神书任务")
                return
            end

            shenShuTask.startTime = time

            PopText("设置成功")
        end
    )

    self:addEditor(
        "自定义时间检测是否满足周重置",
        "自定义当前时间#自定义周期第一次开启神书时间，例：20250613;01#20250613;12",
        function(editBox, text)
            local stringDate = text

            local stringList = string.split(stringDate, "#")
            if #stringList ~= 2 then
                PopText("请输入正确的时间格式")
                return
            end

            local currentTime = stringList[1]
            local firstTime = stringList[2]

            local currentTimeList = string.split(currentTime, ";")
            local firstTimeList = string.split(firstTime, ";")

            if #currentTimeList ~= 2 or #firstTimeList ~= 2 then
                PopText("请输入正确的时间格式")
                return
            end

            local currentDate = currentTimeList[1]
            local currentHour = tonumber(currentTimeList[2])

            local firstDate = firstTimeList[1]
            local firstHour = tonumber(firstTimeList[2])
            
            -- local time = Helper:getTimeStampWithStringDate(stringDate, 0)
            local curretnt_timestamp = Helper:getTimeStampWithStringDate(currentDate, currentHour)
            local first_timestamp = Helper:getTimeStampWithStringDate(firstDate, firstHour)

            if curretnt_timestamp == nil or first_timestamp == nil then
                PopText("请输入正确的时间格式")
                return
            end

            if first_timestamp > curretnt_timestamp then
                PopText("自定义的第一次神书时间不能大于当前时间")
                return 
            end

            local ShenShuVersionFuncHelper = require("app.models.shenshu.ShenShuVersionFuncHelper")
            local isTrue = ShenShuVersionFuncHelper:checkNeedResetTask(
                curretnt_timestamp,
                first_timestamp,
                1
            )
            
            if isTrue then
                PopText("当前时间神书周信息需刷新")
            else
                PopText("当前时间神书周信息不需刷新")
            end
        end
    )

    self:addButton(
        "重置神书传承与神书移除修复标记",
        function()
            local role = User:getRole()
            role.repairShenShu = 2
            PopText("重置成功！")
        end
    )
    
    self:addButton(
        "返回",
        function()
            self:taskButtons()
        end
    )
end

function TestFuncLayer:shenBingWeapon()
    self.ListView:removeAllItems()
    local role = User:getRole()
    self:addButton(
        "清空神兵",
        function()
            local shenBingItems = role:getAttr("shenBingItems")
            for k, weapon in pairs(shenBingItems) do
                role:addItemCount(weapon.id, -1)
            end
            role:setAttr("shenBingItems", {})
        end
    )
    self:addButton(
        "清空补领标记",
        function()
            User:getRole():setFlag("神兵锻造", 0)
        end
    )

    self:addButton(
        "清空暗器修复标记",
        function()
            User:getRole():setAttr("repairXuanBingDong", 1)
        end
    )

    self:addButton(
        "清除神兵淬炼属性异常修复标记",
        function()
            if User:getRole():getAttr("repairXuanBingDong") > 7 then
                User:getRole():setAttr("repairXuanBingDong", 7)
            end
        end
    )

    self:addButton(
        "读书识字等级+10",
        function()
            User:getRole():addSkillLv("dushushizi", 10)
            PopText("读书识字等级+10")
        end
    )
    self:addButton(
        "清空服务器玄兵洞数据",
        function()
            HttpManagerEx:delCkItems(
                "xuanbingdong",
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        User:getRole():setAttr("weaponScore", 0)
                        User:getRole():setAttr("collectScore", 0)
                        PopText("悬兵洞数据已经清空")
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    )

    self:addButton(
        "清空服务器藏衣阁数据",
        function()
            HttpManagerEx:delCkItems(
                "cangyige",
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        User:getRole():setAttr("armorScore", 0)
                        User:getRole():setAttr("collectScore", 0)
                        PopText("藏衣阁数据已经清空")
                    else
                        PopText(errmsg)
                    end
                end
            )
        end
    )

    self:addButton(
        "增加每日淬炼锻造熔炼上限经验",
        function()
            --@RefType [app.models.role.Role#Role]
            local role = User:getRole()

            role:setDayFlag("ronglian", RONGLIAN_EXP_MAX_DAY - 100)
            role:setDayFlag("淬炼经验", MAX_CUILIAN_DAY_EXP - 100)
            role:setDayFlag("duanzao", DUANZAO_EXP_MAX_DAY - 100)

            PopText("今日熔炼经验设置为" .. RONGLIAN_EXP_MAX_DAY - 100)
            PopText("今日淬炼经验设置为" .. MAX_CUILIAN_DAY_EXP - 100)
            PopText("今日锻造经验设置为" .. DUANZAO_EXP_MAX_DAY - 100)
        end
    )

    self:addButton(
        "解锁特性二",
        function()
            local items =
                User:getRole():getItems(
                function(item)
                    if item.type == "神兵" then
                        return true
                    else
                        return false
                    end
                end
            )
            if MapIsEmpty(items) == true then
                PopText("背包中没有神兵")
                return
            end
            local weapon = Item:getOneItemByKey(items[1].itemId)
            if weapon ~= nil then
                weapon.effctNum = 101
            end
            weapon.effct2 = ShenBingDuanZao:getWeapenSpecialId(weapon)
            local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
            ShenBingDuanZao:updateShenBingInfo(weapon)
        end
    )
    self:addButton(
        "解锁特性三",
        function()
            local items =
                User:getRole():getItems(
                function(item)
                    if item.type == "神兵" then
                        return true
                    else
                        return false
                    end
                end
            )
            if MapIsEmpty(items) == true then
                PopText("背包中没有神兵")
                return
            end
            local weapon = Item:getOneItemByKey(items[1].itemId)
            if weapon ~= nil then
                weapon.effctNum = 201
            end
            weapon.effct3 = ShenBingDuanZao:getWeapenSpecialId(weapon)
            local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
            ShenBingDuanZao:updateShenBingInfo(weapon)
        end
    )
    self:addButton(
        "清除开始神兵任务标记",
        function()
            User:getRole():setInheritFlag("开始神兵任务", 0)
            User:getRole():setInheritFlag("可进入苏州水底", 0)
        end
    )
    self:addButton(
        "完成开始神兵任务标记",
        function()
            User:getRole():setInheritFlag("开始神兵任务", 2)
            User:getRole():setInheritFlag("可进入苏州水底", 1)
        end
    )
    self:addButton(
        "锻造知识",
        function()
            local role = User:getRole()
            for i = 1, 30 do
                role:addItemCount("duanzaotupu" .. i, 1)
            end
            PopText("锻造图谱添加至背包")
        end
    )
    self:addButton(
        "锻造之术等级 + 100级",
        function()
            local role = User:getRole()
            role:addSkillLv("duanzaozhishu", 100)
            PopText("锻造之术等级 + 100级")
        end
    )
    self:addButton(
        "当前神兵属性调整",
        function()
            self:setShenBingAttrBtn()
        end
    )
    self:addButton(
        "普通兵器完好度设为0",
        function()
            local weaponData = role:getEquipByName("weapon")
            if weaponData == nil then
                return
            end
            local weapon = role:getOneItemByKey(weaponData.itemId)
            if weapon == nil then
                return
            end
            role:getItemWithOnlyId(weaponData.id).wanhaodu = 0
            role:setEquipByName("weapon", nil)
            PopText("普通兵器完好度设为0")
        end
    )
    self:addButton(
        "普通兵器完好度设为100",
        function()
            local weaponData = role:getEquipByName("weapon")
            if weaponData == nil then
                return
            end
            local weapon = role:getOneItemByKey(weaponData.itemId)
            if weapon == nil then
                return
            end
            role:getItemWithOnlyId(weaponData.id).wanhaodu = 0
            role:setEquipByName("weapon", nil)
            PopText("普通兵器完好度设为100")
        end
    )
    self:addButton(
        "淬炼材料添加",
        function()
            local role = User:getRole()
            for i = 1, 14 do
                local item = Item:getOneItemByKey("cuiliancailiao" .. i)
                if item ~= nil then
                    role:addItemCount(item.id, 1)
                    print("-------------------------:", item.name)
                end
            end
            PopText("添加材料成功")
        end
    )
    self:addButton(
        "黄金 + 500",
        function()
            User:addRoleAttr("gold", 500)
            PopText("黄金 + 500")
        end
    )
    self:addButton(
        "内力上限 + 1000",
        function()
            local role = User:getRole()
            print("neiLiLimit=", role:getAttr("neiLiLimit"), "neiliMax=", role:getAttr("neiliMax"))
            role:addAttr("neiLiLimit", 2000)
            role:addAttr("neiliMax", 1000)
            PopText("内力上限 + 1000")
        end
    )
    self:addButton(
        "每日锻造经验设为 11000",
        function()
            role:setDayFlag("duanzao", 11000)
            PopText("设置成功")
        end
    )
    self:addButton(
        "每日熔炼经验设为 11000",
        function()
            role:setDayFlag("ronglian", 11000)
            PopText("设置成功")
        end
    )
    self:addButton(
        "每日淬炼经验设为 39000",
        function()
            role:setDayFlag("淬炼经验", 39000)
            PopText("设置成功")
        end
    )
    self:addButton(
        "返回",
        function()
            self:weaponButtons()
        end
    )
end

function TestFuncLayer:mapButtons()
    self.ListView:removeAllItems()

    self:addButton(
        "通关所有章节",
        function()
            local role = User:getRole()
            local MapList = Map:getMapListWithFilter()
            for i, v in pairs(MapList) do
                role:setMapCompleted(v.id)
            end
            PopText("已通关所有章节")
        end
    )

    self:addButton(
        "开通所有分组",
        function()
            local role = User:getRole()
            local group = Map:getMapVolume()
            Helper:print_lua_table(group)

            local m_volume = role:getAttr("m_volume")

            for i,v in ipairs(group) do
                local volumeId = v.id

                m_volume[volumeId] = true
            end
        end
    )

    self:addButton("副本npc武学验证日志",function()
        local mapRoleBase = require("script.map.mapRoleBase")
        for mapId, roleBaseInfo in pairs(mapRoleBase) do
            for roleId, roleInfo in pairs(roleBaseInfo) do
                local npcRole = roleInfo

                local prepareList = {"quanjiao1","quanjiao2", "neigong", "qinggong", "zhaojia", "jianfa", "daofa", "gunfa", "anqi", "shuangchi","bianfa","qinfa"}
                
                for i, v in ipairs(prepareList) do
                    if npcRole[v] then
                        local skill = Skill:getSkill(npcRole[v])
                        if not skill then
                            print(mapId, roleId, v, npcRole[v])
                        end
                    end
                end

                for i = 1, 20 do
                    if npcRole["skill" .. tostring(i)] ~= nil then
                        local skill = Skill:getSkill(npcRole["skill" .. tostring(i)])
                        if not skill then
                            print(mapId, roleId, "skill" .. tostring(i), npcRole["skill" .. tostring(i)])
                        end
                    end
                end
            end
        end
    end)

    self:addEditor(
        "NPC测试",
        "npcId#副本id",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end
            local npcId = string.split(text, "#")[1]

            local mapId = string.split(text, "#")[2]

            if npcId == nil or mapId == nil then
                PopText("请输入正确参数" .. text)
                return
            end

            local mapRoleBase = MapResHelper:getMapNpcBaseRes(mapId)

            if mapRoleBase == nil then
                PopText("请输入正确副本id" .. mapId)
                return
            end
            
            if mapRoleBase[npcId] == nil then
                PopText("请输入正确npcId" .. npcId)
                return
            end
            
            local npcRole = mapRoleBase[npcId]

            local mapRole_fb = MapResHelper:getMapRoleRes(mapId)
            for k,v in pairs(mapRole_fb) do 
                if v.baseId == npcRole.id then
                    npcRole = Helper:tableCover(npcRole,v)
                end
            end
            local map = User:getRole():getMapById(mapId)
            local maplayer = MainControllLayer:getLayer("MapLayer")
            if map ~= nil then
                local entryRoomId = map:getDefaultRoomId()
                if entryRoomId ~= nil then
                    map = User:getRole():initMapById(map.id)
                    map:setCallBackAndConnect(function()
                        -- map:enterMap()
                        map._isComingIn = true

                        local ControllLayer = MainControllLayer
                        local layer = ControllLayer:getLayer("MapLayer")
                        layer:setMap(map)
                        map:setCurrRoomId(entryRoomId) -- 遁地符传送到指定的房间
                        layer:replaceRoom(entryRoomId)
                        ControllLayer:pushLayer("MapLayer")

                        User:setRoleAttr("currMapId", map.id)
                        local role = npcRole
                        role.type = "role"
                        map:createRole(role)
                        map:addRoomRole(entryRoomId,role.id)
                        layer:setNeedRefreshMap()
                        local titleLayer = ControllLayer:getLayer("TitleLayer")
                        titleLayer:hide(true)

                        local MapRoleLayer = ControllLayer:getLayer("MapRoleLayer")
                        MapRoleLayer:show()
                        MapRoleLayer:onResume()
                        MapRoleLayer:maxZ()

                        local layer = ControllLayer:getLayer("PrintLayer")
                        layer:show(true)
                        layer:setLocalZOrder(10)
                        Audio:stopMusic()
                        self:hide()
                        self:destroyInstance()
                    end)
                end
            end	
        end
    )

    self:addEditor(
        "NPC战斗测试",
        "npcId#副本id",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end
            local npcId = string.split(text, "#")[1]

            local mapId = string.split(text, "#")[2]

            if npcId == nil or mapId == nil then
                PopText("请输入正确参数" .. text)
                return
            end

            local mapRoleBase = MapResHelper:getMapNpcBaseRes(mapId)

            if mapRoleBase == nil then
                PopText("请输入正确副本id" .. mapId)
                return
            end
            
            if mapRoleBase[npcId] == nil then
                PopText("请输入正确npcId" .. npcId)
                return
            end
            
            local npcRole = mapRoleBase[npcId]
            local FightLayer = require("app.views.layer.FightLayer.FightLayer")
            FightLayer:startMapFight({clone(User:getRole())}, {npcRole}, function(fightLayer, eventType,...)
                local fight = fightLayer:getFight()
                if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
                    -- 战斗开始的时候设置下玩家
                    local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
                    fight:setPlayer(role)
                    -- fight:start()
                    fightLayer:printRolePrologue(1, "切磋")
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
                    PopText("战斗开始!!!")
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
                    local winTeamId, teams = ...
                    -- 隐藏按钮区域
                    fightLayer:callUIMemFunc("setButtonAreaVisble", false)
                    -- 显示战斗结束文本区域
                    fightLayer:callUIMemFunc("showFightEndTextArea")

                    -- 设置战斗结束文本区域的文本
                    if winTeamId == 1 then
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你战胜了" .. npcRole.name)
                    else
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "失败")
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你被" .. npcRole.name .. "打趴在地")
                    end
                    
                    fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
                        fightLayer:hide(function()
                            fightLayer:destroyInstance()
                        end)
                    end)
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
                    fightLayer:hide(function()
                        fightLayer:destroyInstance()
                    end)
                end
            end)
        end
    )

    self:addButton(
        "副本寻宝重置宝藏信息",
        function()
            local role = User:getRole()
            role:setTimeLimitFlag("BaoZangXinXiList", 0)
            role:setFlag("BaoZangOpenTime", GetTime() - 8 * 3600)
            PopText("重置成功")
        end
    )

    self:addButton(
        "重阳酆都玩法",
        function()
            self:fengduButton()
        end
    )

    self:addButton(
        "佣兵测试",
        function()
            self:yongbing()
        end
    )

    self:addButton(
        "无间林活动",
        function()
            self:addWuJianLin()
        end
    )

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:fengduButton()
    self.ListView:removeAllItems()

    self:addButton(
        "清除抓鬼次数限制",
        function()
            User:getRole():setFlag("捉鬼奖励", 0)
            PopText("抓鬼限制已清除")
        end
    )
    self:addButton(
        "清除奈何桥次数限制",
        function()
            User:getRole():setFlag("奈何桥玩法", 0)
            PopText("奈何桥限制已清除")
        end
    )
    self:addButton(
        "清除生死簿次数限制",
        function()
            User:getRole():setFlag("生死簿玩法", 0)
            PopText("生死簿限制已清除")
        end
    )
    self:addButton(
        "返回",
        function()
            self:mapButtons()
        end
    )
end

function TestFuncLayer:addWuJianLin()
    self.ListView:removeAllItems()
    self:addButton(
        "添加名单道具",
        function()
            local role = User:getRole()
            role:addItemCount("znq3wj1", 1)
            role:setInheritFlag("znq3bj1", role:getInheritFlag("znq3bj1") + 1)
        end
    )
    self:addButton(
        "添加地图道具",
        function()
            local role = User:getRole()
            role:addItemCount("znq3wj2", 1)
            role:setInheritFlag("znq3bj2", role:getInheritFlag("znq3bj2") + 1)
        end
    )
    self:addButton(
        "添加玉佩道具",
        function()
            local role = User:getRole()
            role:addItemCount("znq3wj3", 1)
            role:setInheritFlag("znq3bj3", role:getInheritFlag("znq3bj3") + 1)
        end
    )
    self:addButton(
        "添加令牌道具",
        function()
            local role = User:getRole()
            role:addItemCount("znq3wj4", 1)
            role:setInheritFlag("znq3bj4", role:getInheritFlag("znq3bj4") + 1)
        end
    )
    self:addButton(
        "添加钥匙道具",
        function()
            local role = User:getRole()
            role:addItemCount("znq3wj5", 1)
            role:setInheritFlag("znq3bj5", role:getInheritFlag("znq3bj5") + 1)
        end
    )
    self:addButton(
        "清除无间林道具相关标记",
        function()
            local role = User:getRole()
            role:setInheritFlag("znq3bj1", 0)
            role:setInheritFlag("znq3bj2", 0)
            role:setInheritFlag("znq3bj3", 0)
            role:setInheritFlag("znq3bj4", 0)
            role:setInheritFlag("znq3bj5", 0)
        end
    )
    self:addButton(
        "返回",
        function()
            self:mapButtons()
        end
    )
end

function TestFuncLayer:oldFightButtons()
    self.ListView:removeAllItems()

    self:addButton("生成战斗测试配置文件",function ()
        if device.platform ~= "windows" then
            PopText("该功能仅限于windows平台使用")
            return 
        end

        local fileName = "FightTestGMConfig.json"
        local fileUtil = cc.FileUtils:getInstance()
        local fullPath = fileUtil:getWritablePath() .. fileName

        -- 检查完整路径的文件是否存在
        if fileUtil:isFileExist(fullPath) then
            PopText("战斗系数测试配置文件已存在，若需重新生成，请先删除该文件")
            return
        end

        local FightConfig = require("app.models.fight.FightConfig")

        FightConfig:clearTestServerGMConfig()

        local template = {
            ["战斗GM系数"]=  {
                ["enabled"]= false,
                ["目标战斗闪躲值扩大倍数"] = 1,
                ["目标战斗招架值扩大倍数"] = 1
            }
        }

        local str = json.encode(template)

        local file = io.open(fullPath, "w+b")
        if file then
            file:write(str)
            file:close()
            PopText("生成战斗系数测试配置文件成功，路径：" .. fullPath)
        else
            PopText("生成战斗系数测试配置文件失败")
        end
        
    end)

    self:addButton("删除战斗测试配置文件",function ()
        if device.platform ~= "windows" then
            PopText("该功能仅限于windows平台使用")
            return 
        end

        local fileName = "FightTestGMConfig.json"
        local fileUtil = cc.FileUtils:getInstance()
        local fullPath = fileUtil:getWritablePath() .. fileName

        -- 检查完整路径的文件是否存在
        if not fileUtil:isFileExist(fullPath) then
            PopText("战斗系数测试配置文件不存在，无需删除")
            return
        end

        local success = os.remove(fullPath)
        
        if success then
            local FightConfig = require("app.models.fight.FightConfig")
            
            FightConfig:clearTestServerGMConfig()
            PopText("删除战斗测试配置文件成功")
        else
            PopText("删除战斗测试配置文件失败，请手动删除：" .. fullPath)
        end
    end)

    self:addButton("重新加载",function ()
        local FightConfig = require("app.models.fight.FightConfig")

        FightConfig:clearTestServerGMConfig()

        PopText("重新加载战斗测试配置文件成功")
    end)

    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )
end

function TestFuncLayer:challengeMapButtons()
    self.ListView:removeAllItems()
    local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")
    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
    local StatusTagsResourceHelper = require("app.models.RoleStatusTags.StatusTagsResourceHelper")

    self:addEditor(
        "修改轶闻副本玩家状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local mapLayer = MainControllLayer:getLayerWithoutCreate("NewMapLayer")

            if not mapLayer then
                PopText("非轶闻副本内不能使用！")
                return
            end

            local role = mapLayer:getPlayer()

            local values = string.split(text, ";")

            role:setRoleStatusTags(values[1], tonumber(values[2]))

            PopText("修改成功 : " .. values[1] .. " : " .. values[2])
        end
    )

    self:addEditor(
        "修改轶闻副本玩家传承状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local mapLayer = MainControllLayer:getLayerWithoutCreate("NewMapLayer")

            if not mapLayer then
                PopText("非轶闻副本内不能使用！")
                return
            end

            local role = mapLayer:getPlayer()

            local values = string.split(text, ";")

            role:setInheritRoleStatusTags(values[1], tonumber(values[2]))

            PopText("修改成功 : " .. values[1] .. " : " .. values[2])
        end
    )

    self:addEditor(
        "修改轶闻副本玩家时间状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local mapLayer = MainControllLayer:getLayerWithoutCreate("NewMapLayer")

            if not mapLayer then
                PopText("非轶闻副本内不能使用！")
                return
            end

            local role = mapLayer:getPlayer()

            local values = string.split(text, ";")

            role:setTimeStatusTags(values[1], tonumber(values[2]))

            PopText("修改成功 : " .. values[1] .. " : " .. values[2])
        end
    )

    self:addEditor(
        "修改轶闻副本玩家时间传承状态标识",
        "id;value",
        function(editBox, text)
            if text == nil or text == "" then
                PopText("请输入正确参数" .. text)
                return
            end

            local mapLayer = MainControllLayer:getLayerWithoutCreate("NewMapLayer")

            if not mapLayer then
                PopText("非轶闻副本内不能使用！")
                return
            end

            local role = mapLayer:getPlayer()

            local values = string.split(text, ";")

            role:setInheritTimeStatusTags(values[1], tonumber(values[2]))

            PopText("修改成功 : " .. values[1] .. " : " .. values[2])
        end
    )

    self:addButton("轶闻副本通关结算",function()
        local mapLayer = MainControllLayer:getLayerWithoutCreate("NewMapLayer")

        if not mapLayer then
            PopText("非轶闻副本内不能使用！")
            return
        end

        ChallengeMapSystem:getInstance():clearTheMap(mapLayer._currMap,
            function(ok, arg1, arg2)
                if ok then
                    local itemList = arg1
                    local tips = arg2 or "若背包已满，则可通过江湖邮驿获取此次奖励。"
                    PopupLayerController:showLayer(
                        "ChallengeMapFinishPresenter",
                        function(layer)
                            layer:setRole(mapLayer._currMap:getPlayer())
                            layer:setButtonLeave(
                                "离开",
                                function()
                                    mapLayer._currMap:quit()
                                    layer:hideLayer()
                                end
                            )
                            layer:showLayer(itemList)
                            layer:setTextTips(tips)
                        end
                    )
                else
                    local errmsg = arg1
                    PopText(errmsg)
                end
            end)
    end)

    self:addButton(
        "通关轶闻副本标记(重启失效)",
        function ()
            local all = ChallengeMapResource:getInstance():getMapInfosByType(1)
            local list = {}
            for id,_ in pairs(all) do
                table.insert( list,id )
            end

            for i,v in ipairs(all) do
                ChallengeMapSystem:getInstance():initCompletedMapIds(list)
            end

            PopText("通关轶闻副本标记设置成功")
        end
    )

    self:addEditor(
        "通关指定轶闻副本标记(重启失效)",
        "副本id",
        function(editBox, text)
            local mapId = text
            if mapId == nil then
                PopText("请输入正确的副本ID")
                return
            end

            local mapInfo = ChallengeMapResource:getInstance():getMapInfoById(mapId)
            if mapInfo.type ~= 1 then
                PopText("该副本非轶闻副本类型")
                return
            end

            ChallengeMapSystem:getInstance():setCompletedMapId(mapId)

            PopText("【".. mapInfo.name .."(".. mapInfo.gradeName.. ")】通关标记设置成功")
        end
    )

    self:addButton(
        "恢复轶闻值",
        function()
            HttpManagerEx:revertAnecdote(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        PopText("恢复轶闻值成功")
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

function TestFuncLayer:merchantButtons()
    self.ListView:removeAllItems()

    self:addEditor("商品重复购买检测测试","输入商品id",function (editBox, text)
        local goodsId = text
        if not goodsId then
            PopText("商品ID无效")
            return
        end
        local GoodsHelper = require("app.models.Store.GoodsHelper")

        local isDuplicate = GoodsHelper:checkDuplicatePurchase(User:getRole(), goodsId)
        
        if isDuplicate then
            PopText("商品重复购买检测：条件通过，不可被购买")
        else
            PopText("商品重复购买检测：条件不通过，可以被购买")
        end
    end)

    self:addButton(
        "功绩商人",
        function()
            local Chapman = require("app.models.Chapman.Chapman")
            local npc = Role:create()
            npc.canSale = 1
            npc.baseId = "zjsr"
            Chapman:getNpcChapman(npc)
        end
    )

    self:addButton(
        "获取声望商人列表",
        function()
            self.ListView:removeAllItems()
            self:addButton(
                "返回",
                function()
                    self:merchantButtons()
                end
            )
            for i = 1, 26 do
                self:addButton(
                    "声望商人" .. tostring(i),
                    function()
                        local Chapman = require("app.models.Chapman.Chapman")
                        local npc = Role:create()
                        npc.canSale = 1
                        local npcIndex = tostring(i)
                        if i < 10 then
                            npcIndex = "0" .. tostring(i)
                        end
                        npc.id = "shengwang" .. npcIndex
                        Chapman:getPrestigeChapmanStoreList(npc)
                    end
                )
            end
        end
    )

    self:addButton(
        "梦呓商人",
        function()
            PopupLayerController:showLayer(
                "DreamStoreLayer",
                function(layer)
                    layer:showLayer()
                end
            )
        end
    )

    self:addButton(
        "黑市商人",
        function()
            PopupLayerController:showLayer("BlackStorePresenter",function(layer)
                layer:setRole(User:getRole())
                layer:showLayer()
            end)
        end
    )
    self:addButton(
        "冥币商人",
        function()
            local Chapman = require("app.models.Chapman.Chapman")
            local npc = Role:create()
            npc.canSale = 1
            npc.baseId = "npc201_65"
            Chapman:getNpcChapman(npc)
        end
    )

    self:addButton(
        "银票商人",
        function()
            local Chapman = require("app.models.Chapman.Chapman")
            local npc = Role:create()
            npc.canSale = 1
            npc.baseId = "npc201_999"
            Chapman:getNpcChapman(npc)
        end
    )

    self:addButton(
        "周年礼券商人",
        function()
            local Chapman = require("app.models.Chapman.Chapman")
            local npc = Role:create()
            npc.canSale = 1
            npc.baseId = "zhounianqingsc"
            Chapman:getNpcChapman(npc)
        end
    )

    self:addButton(
        "香囊商人",
        function()
            local Chapman = require("app.models.Chapman.Chapman")
            local npc = Role:create()
            npc.canSale = 1
            npc.baseId = "21xiangnangnpc"
            Chapman:getNpcChapman(npc)
        end
    )

    self:addButton(
        "续卷商人",
        function()
            PopupLayerController:showLayer(
                "XuJuanStorePresent",
                function(layer)
                    layer:showLayer()
                    layer:setNpcName("墨无锋")
                end
            )
        end
    )

    self:addButton(
        "续卷回收商人1",
        function()
            local Chapman = require("app.models.Chapman.Chapman")
            local npc = Role:create()
            npc.canSale = 1
            npc.baseId = "22breakyichusrnpc"
            Chapman:getNpcChapman(npc)
        end
    )

    self:addButton(
        "续卷回收商人2",
        function()
            local Chapman = require("app.models.Chapman.Chapman")
            local npc = Role:create()
            npc.canSale = 1
            npc.baseId = "22breakyichusrnpc02"
            Chapman:getNpcChapman(npc)
        end
    )

    self:addButton(
        "选择新商人",
        function()
            self:addEditor(
                "输入新商人id",
                "商店表中的npcId",
                function(editBox, text)
                    local npcId = text
                    if npcId == nil then
                        PopText("请输入正确的npcid")
                        return
                    end
                    local Chapman = require("app.models.Chapman.Chapman")
                    local npc = Role:create()
                    npc.canSale = 1
                    npc.baseId = npcId

                    Chapman:getNpcChapman(npc)
                end
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

function TestFuncLayer:setShenBingAttrBtn()
    self.ListView:removeAllItems()

    -- damage = 0,		-- 伤害值
    -- yindu = 0, 		-- 硬度值
    -- rendu = 0, 		-- 韧度值
    -- weight = 0,		-- 重量值
    -- wanhaodu         -- 完好度
    local role = User:getRole()
    local items =
        role:getItems(
        function(item)
            if item.type == "神兵" then
                return true
            else
                return false
            end
        end
    )
    if MapIsEmpty(items) == true then
        PopText("背包中没有神兵")
        return
    end
    Helper:print_lua_table(items)
    local weapon = Item:getOneItemByKey(items[1].itemId)
    if weapon == nil then
        return
    end
    local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
    self:addButton(
        "神兵伤害值 + 10",
        function()
            weapon.damage = weapon.damage + 10
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            PopText("神兵伤害值 + 10")
        end
    )
    self:addButton(
        "神兵硬度值 + 10",
        function()
            weapon.yindu = weapon.yindu + 10
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            PopText("神兵硬度值 + 10")
        end
    )
    self:addButton(
        "神兵韧度值 + 10",
        function()
            weapon.rendu = weapon.rendu + 10
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            PopText("神兵韧度值 + 10")
        end
    )
    self:addButton(
        "神兵重量值 + 10",
        function()
            weapon.weight = weapon.weight + 10
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            PopText("神兵重量值 + 10")
        end
    )
    self:addButton(
        "神兵完好度设为100",
        function()
            weapon.wanhaodu = 100
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            PopText("神兵完好度设为100")
        end
    )
    self:addButton(
        "神兵完好度设为0",
        function()
            weapon.wanhaodu = 0
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            role:setEquipByName("weapon", nil)
            PopText("神兵完好度设为0")
        end
    )
    self:addButton(
        "淬炼次数次数 + 50",
        function()
            weapon.cuilianCount = weapon.cuilianCount + 50
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            PopText("淬炼次数 + 50")
        end
    )
    self:addButton(
        "淬炼次数次数 + 20",
        function()
            weapon.cuilianCount = weapon.cuilianCount + 20
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            PopText("淬炼次数 + 20")
        end
    )
    self:addButton(
        "淬炼次数次数 + 1",
        function()
            weapon.cuilianCount = weapon.cuilianCount + 1
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            PopText("淬炼次数 + 1")
        end
    )
    self:addButton(
        "神兵特性值 + 10",
        function()
            weapon.effctNum = weapon.effctNum + 10
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            print("神兵特性值 = ", weapon.effctNum)
            PopText("神兵特性值 + 10")
        end
    )
    self:addButton(
        "神兵特性值 + 1",
        function()
            weapon.effctNum = weapon.effctNum + 1
            ShenBingDuanZao:updateShenBingInfo(weapon, role)
            print("神兵特性值 = ", weapon.effctNum)
            PopText("神兵特性值 + 1")
        end
    )
    self:addButton(
        "收藏积分-100",
        function()
            User:getRole():addAttr("collectScore", -100)
        end
    )
    self:addButton(
        "返回",
        function()
            self:weapon()
        end
    )
end

--@desc 毒药相关
function TestFuncLayer:poison()
    self.ListView:removeAllItems()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
    
    self:addButton(
        "返回",
        function()
            self:setMainBtn()
        end
    )

    self:addButton(
        "开启药囊",
        function()
            local flag = role:getInheritFlag("毒药系统")
            if flag < 1 then
                role:setInheritFlag("毒药系统", 1)
            end
            PopText("开启药囊")
        end
    )

    self:addButton(
        "关闭药囊",
        function()
            local flag = role:getInheritFlag("毒药系统")
            if flag >= 1 then
                role:setInheritFlag("毒药系统", 0)
            end
            PopText("关闭药囊")
        end
    )

    self:addButton(
        "开启淬毒",
        function()
            local flag = role:getInheritFlag("毒药系统")
            if flag < 2 then
                role:setInheritFlag("毒药系统", 2)
            end
            PopText("开启淬毒")
        end
    )

    self:addButton(
        "关闭淬毒",
        function()
            local flag = role:getInheritFlag("毒药系统")
            if flag >= 2 then
                role:setInheritFlag("毒药系统", 1)
            end
            PopText("关闭淬毒")
        end
    )
    self:addButton(
        "制药材料添加",
        function()
            local role = User:getRole()
            for i = 1, 59 do
                local item = {}
                if i < 10 then
                    item = Item:getOneItemByKey("duyaoyc00" .. i)
                else
                    item = Item:getOneItemByKey("duyaoyc0" .. i)
                end
                if item ~= nil then
                    role:addItemCount(item.id, 10)
                end
            end
            PopText("制药材料添加成功")
        end
    )
end

function TestFuncLayer:yongbing()
    self.ListView:removeAllItems()

    self:addButton(
        "返回",
        function()
            self:mapButtons()
        end
    )

    self:addButton(
        "清空技能熟练度",
        function()
            local role = User:getRole()
            local mapNpcAttrModify = Helper:getDef(role:getAttr("mapNpcAttrModify"), {})
            for k, v in pairs(mapNpcAttrModify) do
                v.activeZhaos = {}
            end
            role:setAttr("mapNpcAttrModify", mapNpcAttrModify)
            PopText("清空技能熟练度")
        end
    )

    self:addButton(
        "熟练度加100",
        function()
            local role = User:getRole()
            local mapNpcAttrModify = Helper:getDef(role:getAttr("mapNpcAttrModify"), {})
            for k, v in pairs(mapNpcAttrModify) do
                role:addMapNpcZhaoExp(v.npcId, 100)
            end
            role:setAttr("mapNpcAttrModify", mapNpcAttrModify)
            PopText("熟练度加100")
        end
    )

    self:addButton(
        "熟练度加1000",
        function()
            local role = User:getRole()
            local mapNpcAttrModify = Helper:getDef(role:getAttr("mapNpcAttrModify"), {})
            for k, v in pairs(mapNpcAttrModify) do
                role:addMapNpcZhaoExp(v.npcId, 1000)
            end
            role:setAttr("mapNpcAttrModify", mapNpcAttrModify)
            PopText("熟练度加1000")
        end
    )

    self:addButton(
        "熟练度加10000",
        function()
            local role = User:getRole()
            local mapNpcAttrModify = Helper:getDef(role:getAttr("mapNpcAttrModify"), {})
            for k, v in pairs(mapNpcAttrModify) do
                role:addMapNpcZhaoExp(v.npcId, 1000)
            end
            role:setAttr("mapNpcAttrModify", mapNpcAttrModify)
            PopText("熟练度加10000")
        end
    )
end

function TestFuncLayer:uiSkinTest()
    self.ListView:removeAllItems()

    self:addButton(
        "删除所有已购买皮肤",
        function()
            HttpManagerEx:testDeleteAllUiThemes(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")
                        HouseSkin:setSkinId("default")
                        PopText("删除成功")
                    else
                        print(status, errcode, errmsg)
                        PopText("删除失败")
                    end
                end
            )
        end
    )
    
    self:addButton("返回", function()
        self:setMainBtn()
    end)
end

function TestFuncLayer:addEditor(name, defaultText, btnFunc)
    if name then
		if GameChannelContext:checkGMIsOpen(name) == false then
			return
		end
	else
		return 
	end

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

function TestFuncLayer:addTextEditor(name, defaultText)
    if name then
		if GameChannelContext:checkGMIsOpen(name) == false then
			return
		end
	else
		return 
	end

    local panel = self.Panel_2:clone()

    Helper:convertUIByParent(panel)

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

    panel.editBox = editBox

    self.ListView:pushBackCustomItem(panel)
end

function TestFuncLayer:addButton(name, func)
    if name then
		if GameChannelContext:checkGMIsOpen(name) == false then
			return
		end
	else
		return 
	end

    local panel = self.Panel:clone()
    Helper:convertUIByParent(panel)

    if func == nil then
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

function TestFuncLayer:addTimeEditor(name, func)
    local row = self.Panel_time:clone()
	Helper:convertUIByParent(row)

    self:createTimeEditBox(row)
    self.ListView:pushBackCustomItem(row)

	row.Text_desc:setString(name)
	row.Button_ok:releaseFunc(
        function()
            func(row)
        end
    )
end

function TestFuncLayer:statusTags()
    self.ListView:removeAllItems()

    local RoleStatusTagsTest = require("app.views.layer.DebugLayer.RoleStatusTag.RoleStatusTagsTest")

    RoleStatusTagsTest:showTest(self)

    self:addButton("返回", function()
        self:setMainBtn()
    end)
end

function TestFuncLayer:createTimeEditBox(row)
	local size = row.Image_year:getContentSize()
	local year = ccui.EditBox:create(size, os.date("%Y", os.date(WEB_TIME)))
	year:setInputMode(1)
	year:setInputFlag(3)
	year:setReturnType(1)
	year:setFontSize(48)
	year:setTag(770)
	year:addTo(row)
	year:setPosition(row.Image_year:getPositionX(), row.Image_year:getPositionY())
	
	local size = row.Image_mon:getContentSize()
	local month = ccui.EditBox:create(size, os.date("%m", os.date(WEB_TIME)))
	month:setInputMode(1)
	month:setInputFlag(3)
	month:setReturnType(1)
	month:setFontSize(48)
	month:setTag(771)
	month:addTo(row)
	month:setPosition(row.Image_mon:getPositionX(), row.Image_mon:getPositionY())
	
	local size = row.Image_date:getContentSize()
	local day = ccui.EditBox:create(size, os.date("%d", os.date(WEB_TIME)))
	day:setInputMode(1)
	day:setInputFlag(3)
	day:setReturnType(1)
	day:setFontSize(48)
	day:setTag(772)
	day:addTo(row)
	day:setPosition(row.Image_date:getPositionX(), row.Image_date:getPositionY())
	
	local size = row.Image_hour:getContentSize()
	local hour = ccui.EditBox:create(size, os.date("%H", os.date(WEB_TIME)))
	hour:setInputMode(1)
	hour:setInputFlag(3)
	hour:setReturnType(1)
	hour:setFontSize(48)
	hour:setTag(773)
	hour:addTo(row)
	hour:setPosition(row.Image_hour:getPositionX(), row.Image_hour:getPositionY())
	
	local size = row.Image_min:getContentSize()
	local minute = ccui.EditBox:create(size, os.date("%M", os.date(WEB_TIME)))
	minute:setInputMode(1)
	minute:setInputFlag(3)
	minute:setReturnType(1)
	minute:setFontSize(48)
	minute:setTag(774)
	minute:addTo(row)
	minute:setPosition(row.Image_min:getPositionX(), row.Image_min:getPositionY())
end

function TestFuncLayer:setButton()
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

Helper:classDefNodeGetInstance(TestFuncLayer)

return TestFuncLayer