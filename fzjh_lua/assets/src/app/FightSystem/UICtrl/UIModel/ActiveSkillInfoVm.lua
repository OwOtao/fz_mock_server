local newClass = require("third.class.NewClass")

local BtnInfoVm = require("app.FightSystem.UICtrl.UIModel.BtnInfoVm")

--@SuperType [src.app.FightSystem.UICtrl.UIModel.BtnInfoVm#BtnInfoVm]
local ActiveSkillInfoVm = {
    __desc = "",
    __lv = 0,
    __conditionTexts = {},
    __costNeili = 0,
    __isEnable = false
}

function ActiveSkillInfoVm:create()
    return ActiveSkillInfoVm.new()
end

function ActiveSkillInfoVm:setId(id)
    self.__id = id
end

function ActiveSkillInfoVm:setDesc(desc)
    self.__desc = desc
end

function ActiveSkillInfoVm:getDesc()
    return self.__desc
end

function ActiveSkillInfoVm:setConditionTexts(texts)
    self.__conditionTexts = texts
end

function ActiveSkillInfoVm:getConditionTexts()
    return self.__conditionTexts
end

function ActiveSkillInfoVm:setLevel(lv)
    self.__lv = lv
end

function ActiveSkillInfoVm:getLevel()
    return self.__lv
end

function ActiveSkillInfoVm:setCostNeili(value)
    self.__costNeili = value
end

function ActiveSkillInfoVm:getCostNeili()
    return self.__costNeili
end

return newClass("ActiveSkillInfoVm", {BtnInfoVm}, ActiveSkillInfoVm)
000000