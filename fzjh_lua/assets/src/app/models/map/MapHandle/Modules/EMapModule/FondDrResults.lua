--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local FondDrResults = class("FondDrResults", require("app.models.map.MapHandle.Modules.BaseModule"))

local MapInfo = require("app.models.map.MapInfo")

local FightCommons = require("app.FightSystem.FightCommons")

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
FondDrResults.mapId = nil

--@desc 开启状态，默认开启
FondDrResults.status = 1

--@desc 子模块
FondDrResults.childModule = {}

--@desc 条件结果的方法
FondDrResults.doResult = {
    ["南柯梦境主角增加技能重数"] = function(map, result, environment)
        local player = map:getPlayer()
        local zhaoId = result.arg2
        local addLv = result.arg3
        local drSystem = User:getRole():getDreamSystem()
        drSystem:addDreamZhaoLv(zhaoId, player, addLv)
    end,
    ["南柯梦境主角增加武学品级"] = function(map, result, environment)
        local drSystem = User:getRole():getDreamSystem()
        local player = map:getPlayer()
        local skillId = result.arg2
        local addLevel = result.arg3
        --@RefType [BasicSkillManager]
        local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")
        local skill = BasicSkillManager:getBasicSkill(skillId)
        local skillName = skill:getName()
        drSystem:addDreamSkillLevel(skillId, player, addLevel)
        PopText("顿悟武道，" .. skillName .. "进境提升。")
    end,
    ["南柯梦境结算"] = function(map, result, environment)
        local drSystem = User:getRole():getDreamSystem()
        local dreamRole = map:getPlayer()
        local role = User:getRole()
        local drCompleteLevel = dreamRole.dreamWorld.eFloor
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show("是否要进行棋局结算？")
        dialog:setButton1(
            "确定",
            function()
                drSystem:mapComplete(
                    map,
                    function()
                        map.__MapLayer.TotalMapBtn_IsInit = false
                        map.__MapLayer:quit()
                    end
                )
            end
        )
        dialog:setButton2(
            "取消",
            function()
            end
        )
        dialog:setWeChatVisible(false)
    end,
    ["南柯梦境决斗"] = function(map, result, environment)
        local FondMapBattleRunner = require("app.models.FondDream.MapBattle.FondMapBattleRunner")

        FondMapBattleRunner:runBattle(environment.currRole.id, map, map:getPlayer(), environment)
    end,
    ["南柯梦境经验奖励"] = function(map, result, environment)
        local player = map:getPlayer()
        local drSystem = User:getRole():getDreamSystem()
        drSystem:addFondExpReward(player)
    end,
    ["南柯梦境开箱"] = function(map, result, environment)
        local boxId = result.arg2
        local player = map:getPlayer()
        local drSystem = User:getRole():getDreamSystem()
        PopupLayerController:showLayer(
            "FondDrOpenBoxLayer",
            function(layer)
                layer:showLayer(boxId, player, map, drSystem)
            end
        )
    end
}

function FondDrResults:entryMap(map, currTime)
    if map:getMapType() ~= MAP_TYPE.FONDDREAMMAP then
        return
    end

    -- 初始化副本观察者
    map:initObserver()

    map:setSchedule(
        function(tag)
            local player = map:getPlayer()
            if player._buffManager then
                player._buffManager:update()
            end
        end
    )
end

return FondDrResults
0