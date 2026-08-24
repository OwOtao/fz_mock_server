local newClass = require("third.class.NewClass")

local FightLayerBuilder = {}

function FightLayerBuilder:create()
    return FightLayerBuilder.new()
end

function FightLayerBuilder:setBtnAreaCtrlClassFile(btnAreaCtrlClass)
    self.__btnAreaCtrlClass = btnAreaCtrlClass
end

function FightLayerBuilder:setBattleSceneId(fightBackground)
    self.__fightBackground = fightBackground
end

function FightLayerBuilder:build()
    local currLayer

    PopupLayerController:showLayer(
        "Fight2Layer",
        function(layer)
            layer:setBtnAreaCtrlClass(self.__btnAreaCtrlClass)

            layer:setBattleSceneId(self.__fightBackground)

            currLayer = layer
        end
    )

        
    currLayer:initLayer()

    return currLayer
end

return newClass("FightLayerBuilder", {}, FightLayerBuilder)
00000