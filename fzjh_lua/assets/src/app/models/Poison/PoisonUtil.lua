local PoisonUtil = {}
--@RefType [app.models.Poison.Poison#Poison]
local Poison = require("app.models.Poison.Poison")

--@desc: 制作毒药
--@author:Liang SongQiang
--@time:2018-01-07 22:05:48
--@poisonId: 毒药ID
function PoisonUtil:makePoison(poisonId, factors)
    local formula = Poison:getPoisonFormula(poisonId)
    local poison = Item:getOneItemByKey(poisonId)
    factors = Helper:getDef(factors, 0)

    --@desc判断玩家是否解锁配方
    local userPoisonFormula = PoisonFormula:getUserPoisonFormulaByFId(formula.id)
    if userPoisonFormula == nil then
        PopText("你还未学习该毒药制作配方！")
        return
    end

    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    --@desc技能等级限制
    local skillId = formula.skillid

    local skillLv = role:getSkillLv(skillId)
    if skillLv < formula.level then
        PopText("你技能【" .. Skill:getSkill(skillId).name .. "】等级太低，无法制作该毒药")
        return false
    end

    --@desc 精力条件限制
    local roleJing = role:getAttr("jing")
    if roleJing < formula.jingshen then
        PopText("你的精力不够，无法制作毒药")
        return false
    end

    --@desc 材料拥有限制
    --@RefType [app.models.Poison.MedicinalBoxModel#MedicinalBoxModel]
    local MedicinalBoxModel = require("app.models.Poison.MedicinalBoxModel")
    local s_List = string.split(formula.stuff, ";")
    local needStuffList = {}
    if not MapIsEmpty(s_List) then
        for i, stuffCount in ipairs(s_List) do
            local stuff = string.split(stuffCount, ",")
            local sid = stuff[1]
            local count = stuff[2]
            local icount = MedicinalBoxModel:getHasStuffCount(sid)
            if icount < tonumber(count) then
                print(icount, count)
                print("材料不足")
                RichPrint("main", "你材料不足，无法制作材料")
                return false
            end
            needStuffList[sid] = count
        end
    else
        assert(false, "不需要材料就能制作" .. poison.name .. "？？？")
    end

    local successRate =
        (math.min(formula.succeed_rate + math.pow(skillLv / 1200, 1.5), 0.9) + formula.add_rate2 + factors) * 100
    local ranRate = math.random(1, 100)
    local isSuccess = true
    if DEBUG_MODE == 1 then
        print("==================")
        print("随机概率：", ranRate)
        print("制作概率：", successRate)
        print("==================")
    end
    if ranRate > successRate then
        isSuccess = false
    else
        isSuccess = true
    end

    local text = {
        "HIC生起炉火……",
        "HIY火光熊熊，映着你渴望的脸……",
        "HIC小心翼翼地将处理好的药材投入炉子中。",
        "HIC随着炉温上升，药力开始不断发散、混合。",
        "HIC炉子周围弥漫着一种异香，不知情的人走近，还以为在烹制什么美味佳肴。",
        "HIY随着出炉时间越来越近，你心中越发忐忑，生怕出了什么差池。",
        "HIM盯着一团氤氲的炉子，你竟有些出神，怔怔地想：江湖似炉，人心如火，为什么还要往里面添柴呢。",
        "HIM毒之道，道在何处？"
    }

    for sid, count in pairs(needStuffList) do
        local sname = Item:getOneItemByKey(sid).name
        role:addItemCount(sid, -tonumber(count))
        PopText("你使用了" .. sname .. " X" .. count .. Item:getOneItemByKey(sid).unit)
    end

    role:setAttr("jing", roleJing - formula.jingshen)
    PopText("精力 -" .. formula.jingshen)

    if isSuccess then
        local function successFun(printText)
            --@desc 制作需要的时间
            local needTime = #printText
            local printIndex = 1

            --@desc 制作成功逻辑
            return function()
                print("剩余次数" .. needTime)

                if needTime > 0 then
                    RichPrint("main", printText[printIndex])
                    printIndex = printIndex + 1
                    needTime = needTime - 1
                    print("--------------------------------------")
                    return false
                end

                local count = 1
                --@desc 制作双份的概率
                if skillLv > 150 then
                    local dobuleRate = math.pow(skillLv / 1500, 2.5)
                    local rate = math.random(1, 100)
                    if rate <= dobuleRate then
                        count = 2
                    end
                end

                if count == 2 then
                    -- RichPrint(
                    --     "main",
                    --     "YEL由于你的" .. skill.name .. "日益精湛，对材料的掌控更加炉火纯青，每一分药力都发挥到了极致，因此做出了双份" .. poison.name .. "！"
                    -- )
                    print("获得双份毒药" .. formula.name)
                else
                    RichPrint(
                        "main",
                        "YEL随着多种药力在炉中翻腾、融合，NOR" ..
                            poison.name .. "YEL渐渐成型。看着新鲜出炉的NOR" .. poison.name .. "YEL，你露出了邪魅的笑容。NOR"
                    )
                end

                RichPrint("main", "你的 【" .. Skill:getSkill(skillId).name .. "】 经验 +" .. tostring(formula.skillexp_1))
                role:addSkillExp(skillId, formula.skillexp_1)
                role:addItemCount(poisonId, count)
                PoisonFormula:unlockPoisonFormulaBySkillLvUp(skillId)
                PopText("你获得了" .. poison.name .. " X" .. count)
                return true
            end
        end
        return successFun(text)
    else
        --@desc 失败制作的执行
        local function failedFun(printText)
            local needTime = #printText
            local printIndex = 1
            return function()
                print("剩余次数" .. needTime)

                if needTime > 0 then
                    RichPrint("main", printText[printIndex])
                    printIndex = printIndex + 1
                    needTime = needTime - 1
                    return false
                end

                local failText = {
                    "RED也许是火候不够，或者是实在不走运，炼制失败了，炉子里只剩下一堆乌七八黑的药渣，还散发着一股熏人的臭味。  ",
                    "RED出炉了，但炉子里并没有你想要的NOR" .. poison.name .. "RED，看来这次是白费功夫了。想到投入到炉子里的珍贵药材和一番苦心，你气得直跳脚。NOR"
                }

                local i = math.random(1, 2)

                RichPrint("main", failText[i])

                return true
            end
        end

        return failedFun(text)
    end
end

--@desc: 是否已经淬毒
--@author:Liang SongQiang
--@time:2018-01-10 14:38:56
--@weaponId: 武器ID
function PoisonUtil:checkWeaponIsPoison(index,player)
    player = Helper:getDef(player,User:getRole())
    local rolePoison = player:getAttr("poison")

    if rolePoison[index] and rolePoison[tostring(index)] == nil then
        rolePoison[tostring(index)] = rolePoison[index]
        rolePoison[index] = nil
    end

    if rolePoison[tostring(index)] then
        local nowTime = GetTime()
        local endTime = rolePoison[tostring(index)].pEndtime
        if nowTime - endTime > 0 then
            self:clearPoisonWeapon(index,player)
            return false
        end

        return true
    end

    return false
end

--@desc: 给武器淬毒
--@author:Liang SongQiang
--@time:2018-01-07 20:19:21
--@poison: 毒药对象
--@return true or false
function PoisonUtil:PoisonWeapon(poisonId,callback)
    callback = Helper:getDef(callback,EMPTY_FUNC)
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
    if role:getInheritFlag("毒药系统") < 2 then
        PopText("你还未学会淬毒。")
        return
    end

    local formula = Poison:getPoisonFormula(poisonId)
    local poison = Item:getOneItemByKey(poisonId)
    --@RefType [app.models.role.Role#Role]
    local player = User:getRole()
    --@desc 获取当前装备的武器
    local weaponData = player:getEquipByName("weapon")
    
    local rolePoison = player:getAttr("poison")
    
    if not weaponData then
        PopText("请装备武器后再给武器淬毒。")
        return false
    end
    
    local weapon = player:getOneItemByKey(weaponData.itemId)
    if tonumber(poison.target_type) == 1 and weapon.type ~= "暗器" then
        PopText("该毒药只能在暗器上淬毒。")
        return false
    end

    local function doPoison()
        --@desc技能等级限制
        local skillId = formula.skillid
        local skill = Skill:getSkill(skillId)

        local roleSkill = player:getSkill(skillId)
        if roleSkill then
            RichPrint("main", "你的 【" .. skill.name .. "】 经验 +" .. tostring(formula.skillexp_2))
            player:addSkillExp(skillId, formula.skillexp_2)
            PoisonFormula:unlockPoisonFormulaBySkillLvUp(skillId)
        else
            print("你没有学习" .. skillId .. ",不加经验")
        end

        rolePoison[tostring(weaponData.id)] = {
            index = weaponData.id,
            poisonId = poison.id,
            pEndtime = GetTime() + poison.duration,
            fightCount = poison.battles
        }

        player:addItemCount(poison.id, -1)

        local name
        if weapon.wpType == "神兵" then
            local color = weapon.nameColor
            name = color .. weapon.name .. "NOR"
        else
            name = weapon.name
        end

        RichPrint(
            "main",
            "你将" .. poison.name .. "处理一番，然后均匀地涂抹到" .. name .. "上，随着药力渗入，" .. name .. "似乎也泛出一阵危险凛冽的光芒。"
        )

        PopText("你消耗了" .. poison.name .. " X1")
        PopText("淬毒成功")

        PopupLayerController:hideLayer(
            "ItemDetailLayer",
            function(hideLyaer)
                hideLyaer:hideLayer()
            end
        )

        callback()
        return true
    end

    --@desc 如果已经淬毒，会把之前的淬毒效果覆盖
    if self:checkWeaponIsPoison(weaponData.id) then
        PopupLayerController:showLayer(
            "PopConfirmLayer",
            function(layer)
                layer:setDsc("你的武器已经淬毒，再次淬毒会把之前效果覆盖，你确定吗？")
                layer:setButtonNameAndCallFunc(
                    "确定",
                    function()
                        doPoison()
                    end
                )

                layer:setCanelButtonNameAndCallFunc("取消")
                layer:showRefreshPannel()
            end
        )
    else
        return doPoison()
    end
end

--@desc: 获取武器的淬毒信息
--@author:Liang SongQiang
--@time:2018-01-13 20:01:04
function PoisonUtil:getPoisonOnWeapon(index,player)
    player = Helper:getDef(player,User:getRole())
    local rolePoison = {}
    if self:checkWeaponIsPoison(index,player) then
        
        local poisons = player:getAttr("poison")

        if MapIsEmpty(poisons) then
            print("你的武器没有淬毒")
            return
        end

        rolePoison = Helper:getDef(poisons[tostring(index)], {})
    end
    return rolePoison
end

--@desc: 更新淬毒武器的相关属性
--@author:Liang SongQiang
--@time:2018-01-10 15:12:20
--@index: 索引
--@role: [app.models.fight.FightRole#FightRole._role]
function PoisonUtil:reducePoisonFightCount(index,role)
    role = Helper:getDef(role,User:getRole())
    if not self:checkWeaponIsPoison(index) then
        assert(false, "你的武器没有淬毒，不应该减少战斗场次，检查代码")
        return
    end

    index = tostring(index)
    
    local rolePoison = role:getAttr("poison")

    rolePoison[index].fightCount = rolePoison[index].fightCount - 1

    if rolePoison[index].fightCount <= 0 then
        rolePoison[index] = nil
    end
end

--@desc: 删除武器的淬毒状态
--@author:Liang SongQiang
--@time:2018-01-09 10:18:28
function PoisonUtil:clearPoisonWeapon(index,player)
    --@RefType [app.models.role.Role#Role]
    player = Helper:getDef(player,User:getRole())
    local rolePoison = player:getAttr("poison")
    index = tostring(index)
    if rolePoison[index] then
        rolePoison[index] = nil
    end
end

--@desc: 通过学习门派技能学习开启毒药系统
--@author:Liang SongQiang
--@time:2018-03-26 23:29:33
--@role: [app.models.role.Role#Role]
function PoisonUtil:openPoisonSysFromSkill(role,skillId)
    if not self:checkIsFamilySkill(skillId) then
        return
    end

    local flag = role:getInheritFlag("毒药系统")

    if flag >= 2 then
        print("毒囊已经开启过了。")
        return
    end

    if flag >= 0 and flag < 2 then
        PopText("药囊已开启！")
        role:setInheritFlag("毒药系统", 2)
        return
    end
end

local familyPosSkillList = {
    ["tangmenmishu"] = true,
    ["xingxiududian"] = true,
    ["wuxianshu"] = true,
    ["xiyudujing"] = true,
    ["shengsibu"] = true,
    ["xingyunlu"] = true
}

function PoisonUtil:checkIsFamilySkill(skillId)
    if familyPosSkillList[skillId] then
        return true
    end

    return false
end

return PoisonUtil
000