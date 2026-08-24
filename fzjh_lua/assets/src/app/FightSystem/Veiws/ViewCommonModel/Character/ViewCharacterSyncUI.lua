--[[
    author:Seven
    time:2023-11-10 15:22:26
    desc: 角色UI同步类
]]
local newClass = require("third.class.NewClass")

local ViewCharacterSyncUI = {}

local syncAttr = {
    "qi",
    "qiMax",
    "qiLimitBattle",
    "neili",
    "neiliMax",
    "neiliLimit"
}

function ViewCharacterSyncUI:create(character)
    return ViewCharacterSyncUI.new():__init(character)
end

--@desc:
--@author:Seven
--@time:2023-11-10 15:26:40
--@charactr: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ViewCharacterSyncUI:__init(character)
    self.__attrValues = {}

    for i, attrName in ipairs(syncAttr) do
        self.__attrValues[attrName] = character:getAttr(attrName)
    end
    return self
end

--@desc:
--@author:Seven
--@time:2023-11-10 15:27:51
--@viewCharacter: [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
--@mainView: [FightMainView]
function ViewCharacterSyncUI:syncUI(viewCharacter, mainView)
    for i, v in ipairs(syncAttr) do
        viewCharacter:setAttr(v, self.__attrValues[v])
    end

    viewCharacter:updateAttrUI(mainView)
end

return newClass("ViewCharacterSyncUI", {}, ViewCharacterSyncUI)
000