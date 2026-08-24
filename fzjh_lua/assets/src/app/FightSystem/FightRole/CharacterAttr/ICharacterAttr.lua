local interface = require("third.class.interface")

local ICharacterAttr = {}

--@desc: 添加属性
--@author:Seven
--@time:2021-07-05 18:00:16
--@name: 属性名
--@value: 添加值
--@return final add value
function ICharacterAttr:addAttr(name,value)
end

function ICharacterAttr:setAttr(name,value)
end

function ICharacterAttr:getAttr(name)
end


return interface("ICharacterAttr", ICharacterAttr)
00000000