--[[
    author:Seven
    time:2023-11-15 20:23:25
    desc: UI点击注册工具
]]
local newClass = require("third.class.NewClass")
local ViewUIClickRegister = {}

function ViewUIClickRegister:createWithReleaseFuncTotally(node)
    return ViewUIClickRegister.new():__init(node):__initWithReleaseFuncTotally()
end

function ViewUIClickRegister:__init(node)
    self.__node = node
    self.__isPress = false
    self.__prevClickTime = GetLocalTime()
    return self
end

function ViewUIClickRegister:__initWithReleaseFuncTotally()
    self.__node:releaseFuncTotally(
        function()
            local currTime = GetLocalTime()

            if currTime - self.__prevClickTime < 0.3 then
                return
            end

            self.__isPress = true

            if self.__beganPressFunc then
                self.__beganPressFunc()
            end

            self.__prevClickTime = currTime
        end,
        function()
            self.__isPress = false
            if self.__releasePressFunc then
                self.__releasePressFunc()
            end
        end,
        function()
            self.__isPress = false
            if self.__cancelPressFunc then
                self.__cancelPressFunc()
            end
        end
    )

    return self
end

function ViewUIClickRegister:createWithMoveChildren(node)
    return ViewUIClickRegister.new():__init(node):__initWithMoveChildren()
end

function ViewUIClickRegister:__initWithMoveChildren()
    self.__node:moveChildrenWithButton(
        function()
            local currTime = GetLocalTime()

            if currTime - self.__prevClickTime < 0.3 then
                return
            end

            self.__isPress = true

            if self.__beganPressFunc then
                self.__beganPressFunc()
            end

            self.__prevClickTime = currTime
        end,
        function()
            self.__isPress = false
            if self.__releasePressFunc then
                self.__releasePressFunc()
            end
        end,
        function()
            self.__isPress = false
            if self.__cancelPressFunc then
                self.__cancelPressFunc()
            end
        end
    )

    return self
end

function ViewUIClickRegister:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
    self.__beganPressFunc = beganFunc
    self.__releasePressFunc = releaseFunc
    self.__cancelPressFunc = canceledFunc
    self.__pressingUpdate = pressingUpdateFunc
end

function ViewUIClickRegister:isPress()
    return self.__isPress
end

function ViewUIClickRegister:cancelPress()
    self.__isPress = false
end

function ViewUIClickRegister:update(dt)
    if self.__isPress == false then
        return
    end

    if self.__pressingUpdate then
        self.__pressingUpdate(dt)
    end
end

return newClass("ViewUIClickRegister", {}, ViewUIClickRegister)
0000000