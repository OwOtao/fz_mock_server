local MaskWordsConfig = {}

function MaskWordsConfig:getBaseMaskWords()
    local maskWords = {} 

    for i = 1, 10, 1 do
        local officalMaskWord
        local luaPath = "script.others.officalMaskWords" .. i
        local isTrue = pcall(function()
            officalMaskWord = require(luaPath)
        end)

        if isTrue == false then
            break
        end

        local officalMaskWords = officalMaskWord["Sheet1"]
        if officalMaskWords then
            for i,v in pairs(officalMaskWords) do
                if v and v.word then
                    table.insert(maskWords, v.word)
                end
            end
        end
    end

    local gameMaskWords = require("script.others.gameMaskWords")["Sheet1"]
    for i,v in pairs(gameMaskWords) do
        if v and v.word then
            table.insert(maskWords, v.word)
        end
    end

    return maskWords
end

function MaskWordsConfig:getSelfCreateSkillMaskWords()
    local skillName = require("script.others.skillName")["Sheet1"]
    local skillMaskWords = {}

    for i,v in pairs(skillName) do
        if v and v.name then
            table.insert( skillMaskWords, v.name )
        end
    end

    return skillMaskWords
end

return MaskWordsConfig0000