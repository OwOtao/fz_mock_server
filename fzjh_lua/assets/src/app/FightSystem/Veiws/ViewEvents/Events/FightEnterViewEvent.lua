--[[
    author:Seven
    time:2023-10-24 16:07:59
    desc:
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local Actions = require("app.extends.NodeAction.Actions")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local FightEnterViewEvent = {}

function FightEnterViewEvent:create(...)
    return FightEnterViewEvent.new():__init(...)
end

function FightEnterViewEvent:__init(enterContext)
    self.__enterCharacters = enterContext.characterEnter

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function FightEnterViewEvent:doViewEvent(mainView)
    self:__startListViewNodeUIAction(mainView)
    self:__showStartText(mainView)
    self:__hideShadePanel(mainView)

    for id, v in pairs(self.__enterCharacters) do
        mainView:setCharacterAnimVisible(id, true)

        mainView:playCharacterEnterVictoryAnim(
            id,
            AnimResManager:getOtherAnimName(v.animId),
            false,
            nil,
            function()
                local v_character = mainView:getViewCharacter(id)
                mainView:playCharacterAnim(id, v_character:getIdleAnimName())
            end
        )
    end
end

--@mainView: [FightMainView]
function FightEnterViewEvent:__startListViewNodeUIAction(mainView)
    local leftInfoNode = mainView:getInfoListViewNode("left")
    mainView:runUINodeAction(
        leftInfoNode,
        Actions.Spawn:create(
            Actions.CallFunc:create(
                function()
                    leftInfoNode:setVisible(true)
                end
            ),
            Actions.MoveTo:create(0.5, cc.p(25.93, 464.14))
        )
    )

    local rightInfoNode = mainView:getInfoListViewNode("right")
    mainView:runUINodeAction(
        rightInfoNode,
        Actions.Spawn:create(
            Actions.CallFunc:create(
                function()
                    rightInfoNode:setVisible(true)
                end
            ),
            Actions.MoveTo:create(0.5, cc.p(1058.87, 464.14))
        )
    )
end

--@mainView: [FightMainView]
function FightEnterViewEvent:__showStartText(mainView)
    local uiNode = mainView:getUINode("BeginText")
    mainView:runUINodeAction(
        uiNode,
        Actions.Sequence:create(
            Actions.DelayTime:create(0.2),
            Actions.CallFunc:create(
                function()
                    uiNode:setVisible(true)
                    uiNode:setOpacity(255)
                    uiNode:setScale(0.8)
                    uiNode:setString("开始战斗")
                end
            ),
            Actions.ScaleTo:create(0.3, 1.2),
            Actions.ScaleTo:create(0.2, 1.0),
            Actions.FadeOut:create(0.1),
            Actions.CallFunc:create(
                function()
                    uiNode:setVisible(false)
                end
            )
        )
    )
end

--@mainView: [FightMainView]
function FightEnterViewEvent:__hideShadePanel(mainView)
    local uiNode = mainView:getUINode("Panel_Shade")
    uiNode:setOpacity(255)
    uiNode:setVisible(true)

    local action =
        Actions.Sequence:create(
        Actions.DelayTime:create(0.6),
        Actions.Spawn:create(
            Actions.Sequence:create(
                Actions.FadeOut:create(0.3),
                Actions.CallFunc:create(
                    function()
                        uiNode:setVisible(false)
                    end
                )
            )
        )
    )

    mainView:runUINodeAction(uiNode, action)
end

return newClass("FightEnterViewEvent", {IViewEvent}, FightEnterViewEvent)
00000000000000