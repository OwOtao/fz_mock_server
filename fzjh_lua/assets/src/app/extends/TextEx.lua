local Trie = require("third.tree.Trie")
local Text = ccui.Text

local commands = GetColorTb() -- 字体颜色改变格式

local commandTrie = Trie:create()
for commandId, command in pairs(commands) do
    commandTrie:add(commandId)
end

-- 防止重新载入的时候反复替换 add by TangJian 2016/11/08 17:37:47
if Text.create_old == nil then
    Text.create_old = Text.create
    function Text:create(...)
        local p = Text:create_old(...)
        local arg1 = ...
        if arg1 then
            -- print("arg1 = "..tostring(arg1))
            p:setString(arg1)
        end
        return p
    end
end

-- 防止重新载入的时候反复替换 add by TangJian 2016/11/08 17:37:55
if Text.setString_old == nil then
    -- 方案一 剔除多余颜色标记
    Text.setString_old = Text.setString
    function Text:setString(__str)
        if not __str then
            __str = ""
        end

        local showStrs = {}
        local color = nil

        commandTrie:partitionWithCallback(
            __str,
            function(i, str)
                if commands[str] then
                    if color == nil then
                        color = commands[str].color
                    end
                else
                    table.insert(showStrs, str)
                end
            end
        )

        self:setString_old(table.concat(showStrs))
        if color then
            self:setColor(color)
        end
    end
end
000000000