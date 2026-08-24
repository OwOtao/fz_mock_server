local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local audioRes = require("script.newbattle.demo.audioRes")["sound"]

local AudioResManager = {}

local audioResGroup = {}

local function initAudioResGroup()
    for k, v in pairs(audioRes) do
        if audioResGroup[v.soundId] == nil then
            audioResGroup[v.soundId] = {}
        end

        table.insert(audioResGroup[v.soundId], v)
    end

    --@desc 需排序，涉及到随机调用
    for k, audioGroup in pairs(audioResGroup) do
        table.sort(
            audioResGroup,
            function(a, b)
                return a.id > b.id
            end
        )
    end
end

initAudioResGroup()

--@desc: 获取音效资源路径
--@author:Seven
--@time:2021-06-24 17:35:07
--@soundId: 音效ID
function AudioResManager:getSoundNameByRandom(soundId)
    local group = audioResGroup[soundId]
    assert(group, "找不到soundId: " .. tostring(soundId))

    local count = #group

    local rand = FightUtil:random(1, count)

    return group[rand].soundName
end

return AudioResManager
0000000000000000