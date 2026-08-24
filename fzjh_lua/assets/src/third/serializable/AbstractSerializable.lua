local inherit = require("third.inherit.inherit")
local class = require("third.class.NewClass")
local ISerializable = require("third.serializable.ISerializable")
local abstract = require("third.class.abstract")

local AbstractSerializable =
    abstract(
    "AbstractSerializable",
    {
        {
            getSerializeIgnoreMap = function(self)
                return {}
            end
        }
    },
    {
        getSerializedData = function(self)
            local ignoreMap = self:getSerializeIgnoreMap()

            local data = {}

            for k, v in pairs(self) do
                if ignoreMap[k] == true then
                    -- 排除一些描述性属性
                else
                    if type(v) == "table" and type(v.getSerializedData) == "function" then
                        v = v:getSerializedData()
                    end
                    data[k] = v
                end
            end

            return inherit({}, data)
        end,
        serialize = function(self)
            local serializedData = self:getSerializedData()
            return json.encode(serializedData)
        end
    }
)

return AbstractSerializable
0000000000000