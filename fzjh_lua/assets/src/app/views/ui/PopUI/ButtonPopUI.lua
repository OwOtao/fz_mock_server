--[[
    author:Seven
    time:2024-03-29 17:34:05
    desc: 全屏弹窗提示界面UI
]]
local newClass = require("third.class.NewClass")

local ButtonPopUI = {}

function ButtonPopUI:create()
    return ButtonPopUI.new():__init()
end

function ButtonPopUI:__init()
    self.__ui = require("Layer.PopUI.ButtonPopUI").create()["root"]

    Helper:convertUIParent(self.__ui) -- 获得所有子节点

    return self
end

function ButtonPopUI:getUI()
    return self.__ui
end

function ButtonPopUI:show()
    self.__ui:setVisible(true)
end

function ButtonPopUI:hide()
    self.__ui:setVisible(false)
end

function ButtonPopUI:setText(text)
    self.__ui.Text_center:setString(tostring(text))
end

function ButtonPopUI:setButton1(name, func)
    if name == nil and func == nil then
        self.__ui.Button_1:setVisible(false)
        return
    end

    self.__ui.Button_1:setVisible(true)
    self.__ui.Button_1.Text_1:setString(tostring(name))
    self.__ui.Button_1:releaseFunc(func)
end

function ButtonPopUI:setButton2(name, func)
    if name == nil and func == nil then
        self.__ui.Button_2:setVisible(false)
        return
    end

    self.__ui.Button_2:setVisible(true)
    self.__ui.Button_2.Text_2:setString(tostring(name))
    self.__ui.Button_2:releaseFunc(func)
end

return newClass("ButtonPopUI", {}, ButtonPopUI)
000000000000