local class = require("third.class.NewClass")
local Trie = require("third.tree.Trie")

local descTrie = Trie:create()

local Desc = {}

function Desc:create(text, replaces)
    local p = Desc.new()
    p:init(text, replaces)
    return p
end

function Desc:init(text, replaces)
    self.__text = text
    self.__reps = {}

    if replaces then
        for _, replace in ipairs(replaces) do
            self:setReplace(replace[1], replace[2])
        end
    end
end

function Desc:setReplace(from, to)
    self.__reps[from] = to
    descTrie:add(from)
end

function Desc:getString()
    local text = {}

    descTrie:partitionWithCallback(
        self.__text,
        function(i, str)
            if self.__reps[str] then
                table.insert(text, self.__reps[str])
            else
                table.insert(text, str)
            end
        end
    )

    return table.concat(text)
end

return class("Desc", {}, Desc)
00000000000