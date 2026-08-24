local textRes = require("script.newbattle.demo.textRes")["提示文本"]

local TextResManager = {}

function TextResManager:getText(id)
    local res = textRes[id]

    if res == nil then
        assert(false, string.format("无法找到 id：%s 的提示文本内容", tostring(id)))
    end

    return res.content
end

return TextResManager
00000000