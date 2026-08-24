local abstract = require("third.class.abstract")
local class = require("third.class.NewClass")
local interface = require("third.class.interface")

local IAddItemCountExecutor =
    abstract(
    "IAddItemCountExecutor",
    {
        {
            setItems = function(self, items)
            end,
            setAddCount = function(self, addCount)
            end,
            setItemId = function(self, itemId)
            end,
            execute = function(self)
            end,
            setMatchFunc = function(self, matchFunc)
            end,
            setItemCreateFunc = function(self, itemCreateFunc)
            end,
            getModifys = function(self)
            end,
            printItemsInfo = function(self)
            end,
            printModifysInfo = function(self)
            end
        }
    },
    {}
)

return IAddItemCountExecutor
000000000