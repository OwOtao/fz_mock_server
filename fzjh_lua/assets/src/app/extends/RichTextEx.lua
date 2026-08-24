local Trie = require("third.tree.Trie")

-- 放置重新载入的时候, 反复替换 add by TangJian 2016/11/08 17:37:14
if ExtRichTextScroll.create_old == nil then
    ExtRichTextScroll.create_old = ExtRichTextScroll.create
    ExtRichTextScroll.create = function(self, ...)
        local p = ExtRichTextScroll:create_old(...)
        p:setTextMaxHeight(1920)
        p:pushBackNewLine(0)
        return p
    end
end

--
local commands = GetColorTb() -- 字体颜色改变格式

local commandTrie = Trie:create()
for commandId, command in pairs(commands) do
    commandTrie:add(commandId)
end

local newLineTrie = Trie:create()
newLineTrie:add("\n")

-- 防止重新载入的时候反复替换 add by TangJian 2016/11/08 17:37:34
if ExtRichTextScroll.pushBackText_old == nil then
    ExtRichTextScroll.pushBackText_old = ExtRichTextScroll.pushBackText
    function ExtRichTextScroll:pushBackTextWithReturn(text, ...) -- 换行符处理
        if type(text) ~= "string" then
            return
        end

        local params = {...}
        newLineTrie:partitionWithCallback(
            text,
            function(i, str)
                -- print("pushBackTextWithReturn", i, str)
                if str == "\n" then
                    self:pushBackNewLine(0)
                elseif string.len(str) >= 1 then
                    self:pushBackText_old(str, unpack(params))
                end
            end
        )
    end
end

function ExtRichTextScroll:pushBackText(text, ...)
    local strings = commandTrie:partitionToArray(text)

    for i = 1, #strings do
        local str = strings[i]
        local lastStr = strings[i - 1]

        local command = commands[str]
        local lastCommand = commands[lastStr]
        if command then
            if str == "RAN" then -- 随机颜色
                local colors = {"RED", "GRN", "YEL", "BLU", "MAG", "CYN", "WHT", "HIR", "HIG", "HIY", "HIB", "HIM", "HIC", "HIW"}
                strings[i] = colors[math.random(1, #colors)]
            end
        else
            if lastCommand then
                if lastCommand.type == "颜色" then
                    local color, opacity, fontName, fontSize = ...
                    color = lastCommand.color
                    if lastCommand.opacity then
                        opacity = lastCommand.opacity
                    end
                    self:pushBackTextWithReturn(str, color, opacity, fontName, fontSize)
                elseif lastCommand.type == "结束符" then
                    self:pushBackTextWithReturn(str, ...)
                end
            else
                self:pushBackTextWithReturn(str, ...)
            end
        end
    end
end

-- 替换掉pushbacknewline, 给size增加默认值
Decorator:replace(
    ExtRichTextScroll,
    "pushBackNewLine",
    function(funcName, func, self, size)
        return func(self, size or 0)
    end
)
00000000000000