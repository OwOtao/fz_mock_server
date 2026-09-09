-- 测试界面
local TestEntryLayer = class("TestEntryLayer", LayerEx)
local LogSystem = require("app.models.LogSystem.LogSystem")

local s_testEntryLayer = nil

function TestEntryLayer:enable()
    if WConfig then
        return WConfig.enableTestEntryLayer
    end
    
    return false
end

function TestEntryLayer:getInstance()
    if s_testEntryLayer == nil then
        s_testEntryLayer = TestEntryLayer:create()
        cc.Director:getInstance():getRunningScene():addChild(s_testEntryLayer)
    end

    return s_testEntryLayer
end

function TestEntryLayer:destoryInstance()
    if s_testEntryLayer ~= nil then
        s_testEntryLayer:removeFromParent()
        s_testEntryLayer = nil
    end
end

function TestEntryLayer:create()
    local p = TestEntryLayer:new()
    p:init()
    return p
end

function TestEntryLayer:init()
    self._UI = require("Layer/DebugUI/TestUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function TestEntryLayer:showLayer()
    self:maxZ()
    self:setVisible(true)

    self:setTree(
        {
            name = "菜单",
            items = {
                {
                    type = "button",
                    name = "老版战斗",
                    func = function()
                        local FightLayer = require("app.views.layer.FightLayer.FightLayer")

                        local player = User:getRole()
                        -- player:setEquipByName("weapon", )

                        local target = player
                        FightLayer:startMapFight(
                            {player},
                            {target},
                            function(fightLayer, eventType, ...)
                                local fight = fightLayer:getFight()
                                if fight ~= nil then
                                    print("fight 存在")
                                end
                                if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
                                    local role1 = fight:getRoleByTeamIdAndInTeamId(1, 1)
                                    fight:setPlayer(role1)
                                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
                                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH or eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
                                    fightLayer:hide(
                                        function()
                                            fightLayer:destroyInstance()
                                        end
                                    )
                                    -- fightLayer:callUIMemFunc(
                                    --     "setFightEndTextAreaReleaseFunc",
                                    --     function()
                                    --         fightLayer:hide(
                                    --             function()
                                    --                 fightLayer:destroyInstance()
                                    --             end
                                    --         )
                                    --     end
                                    -- )
                                end
                            end,
                            3,
                            "",
                            function()
                            end,
                            function()
                            end
                        )
                    end
                }
            }
        }
    )
end

function TestEntryLayer:setTree(tree)
    self.ListView:removeAllItems()

    for i, item in ipairs(tree.items) do
        if item.type == "button" then
            self:addButton(item.name, item.func)
        elseif item.type == "tree" then
            self:addButton(
                item.name,
                function()
                    self:setTree(item)
                end
            )
        end
    end
end

function TestEntryLayer:addButton(name, func)
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

return TestEntryLayer