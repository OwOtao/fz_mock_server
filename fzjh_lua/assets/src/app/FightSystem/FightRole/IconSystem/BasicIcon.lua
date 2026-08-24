--[[
    author:Seven
    time:2023-02-11 15:35:35
    desc: 基础图标类
]]
local newClass = require("third.class.NewClass")

local BuffIconMap = require("script.newbattle.demo.buffIcon")["Buff图标"]

local BasicIcon = {}

function BasicIcon:create(iconId)
    return BasicIcon.new():__init(iconId)
end

function BasicIcon:__init(iconId)
    self.__res = BuffIconMap[tostring(iconId)]

    if self.__res == nil then
        error("图标类创建失败，图标资源未找到，id：" .. tostring(iconId))
    end

    self.__count = 1

    return self
end

function BasicIcon:setId(id)
    self.__id = id
end

function BasicIcon:getId()
    if self.__id == nil then
        error("BasicIcon:getId() 获取失败，id为空，检查代码")
    end
    return self.__id
end

function BasicIcon:setCount(count)
    if count < 1 then
        error("BasicIcon:setCount 参数不可小于1")
    end
    self.__count = count
end

function BasicIcon:getCount()
    return self.__count
end

function BasicIcon:getIconId()
    return self.__res.id
end

function BasicIcon:getImgPath()
    return self.__res.iconRes
end

--@desc: 创建一个新的图标对象
--@author:Seven
--@time:2023-03-15 15:22:58
--@iconId: 图标表中对应的id
--@return [src.app.FightSystem.FightRole.IconSystem.BasicIcon#BasicIcon]
function BasicIcon.createIcon(iconId)
    return BasicIcon:create(iconId)
end

return newClass("BasicIcon", {}, BasicIcon)
00