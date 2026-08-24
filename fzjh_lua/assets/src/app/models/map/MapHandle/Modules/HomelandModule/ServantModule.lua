--@desc 仆人相关功能模块

--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local ServantModule = class("ServantModule", require("app.models.map.MapHandle.Modules.BaseModule"))
local MapInfo = require("app.models.map.MapInfo")
--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

--@desc 条件结果的方法
ServantModule.doResult = {
    ["闲聊"] = function(map, result, environment)
        local ChatModel = require("app.models.HomelandModel.ChatModel")
        ChatModel:chat(environment.currRole, map)
    end,
    ["仆人交谈"] = function(map, result, environment) --门客也用这个条件结果
        local currRole = environment.currRole
        local lv = HomelandRoleUtil:getFidelityLv(currRole.defaultZhongCheng)

        if DEBUG_MODE == 1 then
            print("------------技能等级---------------")

            for i= 1,20 do
                if currRole["skill"..i] then
                    local skillId = currRole["skill"..i]
                    local skill = Skill:getSkill(skillId)
                    print("基本暗器等级 = ",currRole:getSkillLv("jibenanqi"))
                    print("技能 "..skill.name.."等级为"..currRole["skillLv"..i] )
                else
                    break
                end
            end 
        
            print("----------------属性---------------------")
            print("气血最大值",currRole:getFinalAttr("qiMax"))
            print("气血最大值",currRole:getFinalAttr("neiliMax"))
            print("后天根骨",currRole:getFinalAttr("secCon"))
            print("后天臂力",currRole:getFinalAttr("secStr"))
            print("后天身法",currRole:getFinalAttr("secDex"))
            print("加力",currRole:getFinalAttr("jiaLi"))
            print("容貌",currRole:getFinalAttr("looks"))
            print("攻击力",currRole:getAtk())
            print("防御力",currRole:getDef())
            print("躲闪力",currRole:getDodge())
            print("招架力",currRole:getParry())
            print("-------------------结束-------------------")
        end
        local jobType = currRole.jobType
        local jobTypeAttr = HomelandRoleUtil:getRoleTypeData(jobType)
        local talkText
        --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        local mid = role:getHouseId()

        local isHome = false
        if map.mid and mid == map.mid then
            isHome = true
        end

        local currRoleStatus = HomelandRoleUtil:getRoleCurrStatus(currRole)

        if isHome then
            local randomOdds = math.random(1,100)
            if lv >= 4 and randomOdds <= 30 then
                if HomelandRoleUtil:isFinishLiftEvent(currRole) then
                    talkText = HomelandDesc:getTalkTextAfteLifeEvent(currRole)
                else
                    talkText = HomelandDesc:getTalkShenShiText(currRole)
                end
            else
                talkText = HomelandDesc:getFzTalkDesc(currRoleStatus, jobTypeAttr, currRole,map)
            end
        else
            local flag = map:getFlag("roleHouseStatus")
            if flag == 0 then
                --@desc 未入侵也未被邀请。
                talkText = HomelandDesc:getNorTalkDesc(currRoleStatus, jobTypeAttr,currRole,map)
            elseif flag == 1 then
                --@desc 入侵。
                talkText = "YEL" .. currRole.name .. "：" .. jobTypeAttr.talk4
            elseif flag == 2 then
                --@desc 被邀请。
                talkText = HomelandDesc:getKrTalkDesc(currRoleStatus, jobTypeAttr,currRole,map)
            end
        end

        RichPrint("main", talkText)

        -- HomelandRoleUtil:tieJiangInShenBingMain(currRole,map)
    end,
    ["副本仆人"] = function(map, result, environment)
        --@desc [src.app.models.role.Role#Role]
        local role = User:getRole()
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end

        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:isJobTypeFromFlag("guanjia001") == false then
            PopText("请先雇佣一个管家，再招募仆人！")
            return
        end
        local currRole = environment.currRole

        local roleData = {}
        local name = environment.currRole.name
        local sex = environment.currRole.sex
        local age = environment.currRole.age
        local looks = environment.currRole.looks
        local MobanId = result.arg2
        local jobType = result.arg3
        local characterId = result.arg4
        local trait = Helper:getDef(result.arg5,"")
        trait = string.split(trait, ";")
        local traitVal = Helper:getDef(result.arg6, 0)
        local price_unit = Helper:getDef(result.arg7, "yinpiao")
        local price = Helper:getDef(result.arg8, 0) * 14
        local defaultZhongCheng = Helper:getDef(result.arg9, 1)
        local shenShi = Helper:getDef(result.arg10, "shenshi001")
        local mobanSkill = HomelandRoleUtil:getUploadWebRoleSkillArray(MobanId)
        local speedZhongCheng, leave_day = HomelandRoleUtil:getSpeedZhongChengAndLeaveDay(jobType, characterId)

        roleData.name = name
        roleData.sex = sex
        roleData.age = age
        roleData.looks = looks
        roleData.modal = MobanId
        roleData.jobType = jobType
        roleData.character = characterId
        roleData.traitVal = traitVal
        roleData.trait1 = Helper:getDef(trait[1],"") 
        roleData.trait2 = Helper:getDef(trait[2],"")
        roleData.trait3 = Helper:getDef(trait[3],"")
        roleData.leave_day = leave_day
        roleData.price_unit = price_unit
        roleData.price = price
        roleData.speedZhongCheng = speedZhongCheng
        roleData.defaultZhongCheng = defaultZhongCheng
        roleData.shenShi = shenShi
        roleData.mobanSkill = mobanSkill

        roleData.extra = {
            npcId = environment.currRole.id
        }

        local role = User:getRole()
        local mid = role:getHouseId()
        local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")

        PuRenModel:clear()
        PuRenModel:setMid(mid)
        PuRenModel:setNpcId(0)
        PuRenModel:setZhongCheng(0)
        PuRenModel:push(roleData)

        PopupLayerController:showLayer(
            "EmployDscLayer",
            function(layer)
                layer:setButtonFunc(function ()
                    --@RefType [src.app.models.role.Role#Role]
                    local role = User:getRole()
                    local mid = role:getHouseId()
                    if mid == nil then
                        PopText("少侠，您还没自己的房子呢！")
                        return
                    end
                    PuRenModel:employeeNpc(1,function ()
                        role:setInheritFlag(environment.currRole.id,1)
                        layer:hideLayer()
                    end)
                end)

                layer:showLayer(roleData)
            end
        )
    end,
    ["做饭"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()
        if role:getTimeLimitFlag("做饭") > 0 then
            local time = math.floor(role:getTimeLimitFlagTime("做饭"))
            local hour = math.floor(time / 3600)
            local min = math.floor((time - hour * 3600) / 60)
            local sec = math.floor(time - hour * 3600 - min * 60)
            RichPrint("main", "您不要太心急了，厨子刚刚做过饭还要" .. tostring(hour) .. "小时"..tostring(min) .. "分" .. tostring(sec) .. "秒才能准备好进行下一次做饭。")
            return
        end

        local currRole = environment.currRole
        local zcLv = HomelandRoleUtil:getFidelityLv(currRole.defaultZhongCheng)

        local reduceCDFactor = currRole:getBuffAttr("zuofanCDReduce")

        local cdTime = math.max(60 - (zcLv - 1) * 9, 10) * 1900 * math.max((1 - reduceCDFactor),0)
        role:setTimeLimitFlag("做饭", 1, cdTime)
        local roleList = map:getRoomRoleList(map:getCurrRoomId())
        for i, v in ipairs(roleList) do
            local roleData = map:getRole(v)
            if roleData.iType == "灶台" then
                roleData.canUse1 = 0
                roleData.canUse3 = 1
                if zcLv >= 4 then
                    roleData.canUse2 = 1
                end
                break
            end
        end

        --@desc 可吃饭可装盒次数
        local times = math.max(zcLv - 3, 1)

        local rate = math.random(1, 100)

        local dinner = Helper:getDef(role:getHomelandAttr("dinner"), {})

        dinner.times = times
        dinner.rate = rate
        dinner.status = 1 --1为在炤台，2为已装盒
        dinner.lv = zcLv

        role:setHomelandAttr("dinner", dinner)

        PopupLayerController:showLayer(
            "GlobalShadeLayer",
            function(layer)
                layer:showLayer()
                layer:setPopText("厨子正在给您做饭呢，请稍等。")
            end
        )

        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        local textArr = HomelandDesc:getMakeDinnerText()
        local index = 0
        map:setSchedule(
            function(tag)
                index = index + 1
                RichPrint("main", textArr[index])

                if index == #textArr then
                    PopupLayerController:hideLayer(
                        "GlobalShadeLayer",
                        function(layer)
                            PopText("饭食制作完毕，已经端到灶台上了！")
                            layer:hideLayer()
                            map:unSchedule(tag)
                        end
                    )
                end
            end,
            2
        )
    end,
    --判断当前房间那些土地是处于收取状态，然后一次性收取
    ["老农收取"] = function(map, result, environment)
        --@RefType [src.app.models.HomelandModel.SeedModel#SeedModel]
        local SeedModel = require("app.models.HomelandModel.SeedModel")

        if SeedModel:checkFarmerCanHarvestLand(map, environment.currRole) == false then
            PopText("当前无田地可以收取")
            return
        end

        local currRoom = map:getRoomById(environment.currRoomId)

        local rolePlantInfo = User:getRole():getHomelandAttr("plant")
        for k, v in pairs(currRoom.roleList) do
            if rolePlantInfo[v] and rolePlantInfo[v].status==2 then 
                local npc = map:getRole(v)
                SeedModel:harvest(npc, environment.currRole, map)
            end
        end
    end,
    ["练习主动招式"] = function(map, result, environment)
        local currRole = environment.currRole
        
        local currRoleId = currRole.id

        local zhaoIdList = currRole.extra.zhaoIdList

        local ActiveSkillPracticeModel = require("app.models.ActiveSkillPractice.ActiveSkillPracticeModel"):create()
        ActiveSkillPracticeModel:setPlayer(User:getRole())
        ActiveSkillPracticeModel:setNpc(currRole)

        if MapIsEmpty(zhaoIdList) then
            PopText("你的陪练没有学习任何招式。")
            return
        end

        ActiveSkillPracticeModel:getZhaoPracticeInfo(
            currRoleId,
            function(isOk,errmsg,data)
                if isOk then
                    MainControllLayer:pushLayer("ActiveZhaoPracticePresenter")
                    local activeZhaoPracticePresenter = MainControllLayer:getLayer("ActiveZhaoPracticePresenter")
                    activeZhaoPracticePresenter:setModel(ActiveSkillPracticeModel)
                    activeZhaoPracticePresenter:setPlayer(User:getRole())
                    activeZhaoPracticePresenter:initData(data)
                    activeZhaoPracticePresenter:showLayer()
                else
                    PopText(errmsg)
                end
            end
        )
    end,
    ["重复饰品处理"] = function(map, result, environment)
        local sumMask = 0
        local sumFightAppearance = 0
        local caiLiaoNum = 0
        local role = User:getRole()
        local decorative = role:getAttr("decorative")

        for i, v in ipairs(decorative) do
            if v.count > 1 then
                local itemAttr = role:getOneItemByKey(v.itemId)

                if itemAttr.type == "挂饰" then
                    local count = v.count - 1
                    caiLiaoNum = caiLiaoNum + itemAttr.cailiao * count
                    sumFightAppearance = sumFightAppearance + count
                else
                    local canDeal = role:getMaskSystem():getMaskGrade(v.itemId,1):canDeal()
                    if canDeal then
                        local cailiao = role:getMaskSystem():getMaskGrade(v.itemId,1):getCaiLiao()
                        local count = v.count - 1
                        caiLiaoNum = caiLiaoNum + cailiao * count
                        sumMask = sumMask + count
                    end
                end
            end
        end

        --@RefType [src.app.models.role.Role#Role]
        local npc = environment.currRole

        local factor = npc:getBuffAttr("spchanliangAdd")

        if PRINT_MODE == 1 then
            print("提高重复饰品处理产量 ： " .. factor)
        end

        caiLiaoNum = math.floor(caiLiaoNum * (1 + factor))

        if caiLiaoNum <= 0 then
            PopText("你没有重复的饰品可兑换饰品材料。")
            return
        end

        local addZc = math.floor(caiLiaoNum*0.8)

        local str = ""
        
        if sumMask > 0 then
            str = str .. tostring(sumMask) .. "个重复的面具"
        end

        if sumFightAppearance > 0 then
            str = str .. tostring(sumFightAppearance) .. "个重复的挂饰"
        end

        if sumMask > 0 and sumFightAppearance > 0 then
            str = tostring(sumMask) .. "个重复的面具和".. tostring(sumFightAppearance) .. "个重复的挂饰"
        end

        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show("","可获得"..caiLiaoNum.."份饰品材料并增加绣女"..addZc.."点忠诚度")

        local text = "#ch#，您的饰品中有"..str.."，小的可以帮您将多余的饰品制作成为饰品材料。您意下如何？"
        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        text = HomelandDesc:subChengHuText(text)
        dialog:setText(text)
        dialog:setBack(false)
        dialog:setWeChatVisible(false)
        dialog:setButton1(
            "确定",
            function()
                HttpManagerEx:updateCurrencyByType(
                    "add",
                    "spcl",
                    caiLiaoNum,
                    nil,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                for k, v in ipairs(decorative) do
                                    if v.count >= 2 then
                                        local itemAttr = role:getOneItemByKey(v.itemId)

                                        if itemAttr.type == "挂饰" then
                                            v.count = 1
                                        else
                                            local canDeal = role:getMaskSystem():getMaskGrade(v.itemId,1):canDeal()
                                            if canDeal then
                                                v.count = 1
                                            end
                                        end
                                    end
                                end
                                
                                local addZc = math.floor(data.spcl*0.8)
                                HomelandRoleUtil:addFidelityFree(npc, map, addZc)

                                PopText("您获得了饰品材料 +" .. tostring(data.spcl))
                                RichPrint("main", environment.currRole.name .. "取出饰品，用一种特殊药材将饰品上所绘涂抹干净，饰品变成了碎片原料。")
                            else
                                PopText("制作失败，请重试")
                                print(errmsg, errcode)
                            end
                        else
                            PopText("制作失败，请重试")
                            print(errmsg, errcode)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            end
        )
        dialog:setButton2(
            "取消",
            function()
                RichPrint("main", "好的，您可以随时吩咐小的，有需要再来吧。")
            end
        )
    end,
    ["随机制作饰品"] = function(map, result, environment)
        local npc = environment.currRole

        local role = User:getRole()
        
        role:getMaskSystem():getMakeMaskInfo(function()
            PopupLayerController:showLayer(
                "MakeMaskPresenter",
                function(layer)
                    layer:showLayer(npc)
                end
            )
        end)

    end,
    ["招式指点"] = function(map, result, environment)
        local currRole = environment.currRole
        
        local ActiveSkillPracticeModel = require("app.models.ActiveSkillPractice.ActiveSkillPracticeModel"):create()
        ActiveSkillPracticeModel:setPlayer(User:getRole())
        ActiveSkillPracticeModel:setNpc(currRole)

        MainControllLayer:pushLayer("GiftPagePresenter")
        local giftPagePresenter = MainControllLayer:getLayer("GiftPagePresenter")
        giftPagePresenter:setModel(ActiveSkillPracticeModel)
        giftPagePresenter:setPlayer(User:getRole())
        giftPagePresenter:showLayer()
    end,
    ["生成黑市商人"] = function(map, result, environment)
        local roleId = "chapman1"
        local roomId = result.arg2
        local odds = result.arg3*100
        local randomNum = math.random( 1,100)

        if odds < randomNum then
            return
        end
        local role = Helper:tableCover(
		    require("app.models.npc.BaseNpc"):create(),
            {
                id = roleId,
                sex = "野兽",
                type = "role",
                name = "黑市商人",
                dsc = "他是黑市商人，看上去三四十来岁，生的尖嘴猴腮，浑身充满了铜臭味。",
                canSee = true,
                canTalk = true,
                canSale = true,
                canKill = false,
                conditionAndResults = {
                    {
                        conditionRelation = "and",
                        conditions = {
                            {
                                type = "玩家操作",
                                arg1 = "玩家操作",
                                arg2 = "交谈"
                            }
                        },
                        results = {
                            {
                                type = "文本输出",
                                arg1 = "文本输出",
                                arg2 = "YEL黑市商人：最近官府查的严，得经常挪地儿，唉，生意不好做啊。"
                            }
                        }
                    },
                    {
                        conditionRelation = "and",
                        conditions = {
                            {
                                type = "玩家进入房间",
                                arg1 = "玩家进入房间"
                            },
                            {
                                type = "地图标记大于",
                                arg1 = "地图标记大于",
                                arg2 = "黑市商人" .. roleId,
                                arg3 = 0
                            }
                        },
                        results = {
                            {
                                type = "删除人物",
                                arg1 = "删除人物",
                                arg2 = roleId
                            },
                            {
                                type = "文本输出",
                                arg1 = "文本输出",
                                arg2 = "你才一个转身，回头便发现黑市商人已不知所踪了。"
                            }
                        }
                    },
                    {
                        conditionRelation = "and",
                        conditions = {},
                        results = {
                            {
                                type = "地图标记变化",
                                arg1 = "地图标记变化",
                                arg2 = "黑市商人" .. roleId,
                                arg3 = 1
                            }
                        }
                    }
                }
            }
        )
        MapInfo:addMapRole(map,role)
        MapInfo:addRoleToRoom(map,roomId,roleId)
    end,
    ["第一次进入房间概率获得物品"] = function(map, result, environment)
        local odds = result.arg2*100
        local randomNum = math.random( 1,100)

        if odds < randomNum then
            return
        end

        --判断背包空间
        local role = User:getRole()
        
        local rewardList = {
            {   
                id = "dundifu",
                count = 1 
            },
            {   
                id = "fenshenfu",
                count = 1 
            },
            {   
                id = "jingxinwan",
                count = 2 
            },
        }
        
        local resultReward =  rewardList[math.random(1,#rewardList)]
        local itemId = resultReward.id
        local count = resultReward.count
        
        if not role:checkCanBuyTwoOrMoreThings({[itemId] = count}) then
            map:dropItem(environment.currRoomId,itemId,count)
            map.__MapLayer:delayRefreshMap()
            return
        end
        
        local itemAttr = Item:getOneItemByKey(itemId)
        role:addItemCount(itemId,count)
        PopText("获得"..itemAttr.name.."X"..count)

    end,
    ["第一次进入房间概率丢失物品"] = function(map, result, environment)
        local odds = result.arg2*100
        local randomNum = math.random( 1,100)

        if odds < randomNum then
            return
        end

        local rewardList = {
            {   
                id = "dundifu",
                count = -1 
            },
            {   
                id = "fenshenfu",
                count = -1 
            },
            {   
                id = "jingxinwan",
                count = -2 
            },
        }

        local resultReward =  rewardList[math.random(1,#rewardList)]
        local itemId = resultReward.id
        local count = resultReward.count

        local itemAttr = Item:getOneItemByKey(itemId)
        local role = User:getRole()
        role:addItemCount(itemId,count)
        PopText(itemAttr.name.."X"..count)

    end,
    ["第一次进入房间概率获得金钱"] = function(map, result, environment)
        local addMoneyValue = result.arg2

        --固定概率触发
        if 25 < math.random(1,100) then
            return
        end

        PopText("碎银"..addMoneyValue)
        local role = User:getRole()
        role:addAttr("money",addMoneyValue) 
    end,
    ["第一次进入房间获得金钱"] = function(map, result, environment)

        local role = User:getRole()
        local addMoneyValue = result.arg2

        PopText("碎银"..addMoneyValue)
        role:addAttr("money",addMoneyValue)        
    end,
    ["赏赐"] = function (map, result, environment)
        local currRole = environment.currRole
        PopupLayerController:showLayer("ServantRewardLayer",function (layer)
            layer:showLayer(currRole,map)
        end)
  --       local objId = environment.currRole.id
        
  --       local mid = map.mid

		-- local characterId = currRole.character

  --       local jobType = currRole.jobType
        
  --       local characterFactor = HomelandRoleUtil:getCharacterFactor(jobType)
  --       local characterAttr = HomelandRoleUtil:getCharacterAttr(characterId)

  --       local rewardjiage = characterFactor.rewardjiage1
        
		-- local rewardjiagexishu = characterAttr.rewardjiage

  --       local rewardzhongcheng = characterFactor.rewardzhongcheng1
        
		-- local rewardzhongcheng1 = characterAttr.rewardzhongcheng

		-- local value = rewardjiage*rewardjiagexishu --赏赐数值

  --       local addzhongcheng = rewardzhongcheng*rewardzhongcheng1  -- 每次赏赐获得的忠诚度
  --       addzhongcheng = addzhongcheng + currRole:getBuffAttr("fidelityAddByReward")
        
  --       local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
		-- local text = HomelandDesc:getGrowthText(addzhongcheng,currRole.name)
		
  --       local conf_cn = {
  --           ["ssyjf"] = "礼券"  --双十一
  --       }
		
  --       HttpManagerEx:viewCurrencyByType("yinpiao", function(status, errcode, errmsg, data)
  --           if status == 200 then
  --               if errcode == 0 then
  --                   local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
  --                   local dialog = DialogALayer:getInstance()
  --                   dialog:hide()
  --                   local commands = Resource:getColorTb()
  --                   dialog:show("你确定要花费"..value.."银票赏赐"..currRole.name.."吗？","当前拥有银票："..data.number)
  --                   dialog:setDescColor(commands["YEL"].color)
  --                   dialog:setButton1("确定", function()
  --                       HttpManagerEx:updateEmployRoleData(objId,mid,"give",addzhongcheng,value,function(status, errcode, errmsg, data)
  --                           if status == 200 then
  --                               if errcode == 0 then
  --                                   --Helper:print_lua_table(data)
  --                                   HomelandRoleUtil:setHomeLandRoleData(jobType,data.defaultZhongCheng)
  --                                   HomelandRoleUtil:updateFidelity(data.defaultZhongCheng,currRole)
  --                                   HomelandRoleUtil:DeblockRoleTrait(currRole,data.trait)
  --                                   --仆人特性
  --                                   HomelandRoleUtil:getItemInReward(currRole,map)

  --                                   local rewardText = HomelandDesc:getAwardText(currRole)

  --                                   text = rewardText.."\n"..text
  --                                   RichPrint("main",text)
  --                                   if MapIsEmpty(data.activity) == false then
  --                                       for k,v in pairs(data.activity) do
  --                                           if v > 0 then
  --                                               PopText(conf_cn[k].." +"..v)
  --                                           end
  --                                       end
  --                                   end
  --                               elseif errcode == 2 then
  --                                   PopText("你今日已经赏赐够多了，还是明日再说吧")
  --                               else
  --                                   PopText(errmsg)
  --                               end
  --                           else
  --                               PopText(errmsg)
  --                           end
  --                       end, IS_SHOW_WAITING)
                        
  --                   end)
  --                   dialog:setButton2("取消", function()
  --                       dialog:hide()
  --                   end)
  --                   dialog:setWeChatVisible(false) 
  --               else
  --                   PopText(errmsg)
  --               end
  --           else
  --               PopText(errmsg)
  --           end
  --       end, IS_SHOW_WAITING)
    end,
}

--@desc:
--@author:Liang SongQiang
--@time:2018-04-27 14:32:10
function ServantModule:entryMap(map, currTime)
    if PRINT_MODE == 1 then
        print("EntryMap(): id: " .. map.id, "name: " .. map.name)
    end
end

return ServantModule
000000