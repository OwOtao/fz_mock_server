local class = require("third.class.NewClass")
local Params = {}

function Params:create()
    return Params.new()
end

function Params:ctor()
    self.__params = {}
end

function Params:set(name, value)
    self.__params[name] = value
end

function Params:get(name)
    return self.__params[name]
end

function Params:printInfo()
    for k, v in pairs(self.__params) do
        print(k, v)
    end
end

return class("Params", {}, Params)
0000000000000000