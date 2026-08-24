local GlobalShadeLayer = class("GlobalShadeLayer", cc.Layer)

local FILE = cc.FileUtils:getInstance():getWritablePath().."luaTablePath/Shade"

function GlobalShadeLayer:create()
    local p = GlobalShadeLayer:new()
    p:init()
    return p
end

function GlobalShadeLayer:init()
    self._UI = require("Layer/PopUI/GlobalShadeUI.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setPopText("")
end

function GlobalShadeLayer:showLayer()
    if Game:isTesting() == true then
        local fp ,msg= io.open(FILE,"w")

        if fp == nil then
            print(msg)
            return
        end

        fp:write(debug.traceback())

        fp:close()
    end

    self.Shade:setTouchEnabled(true)
    self.Shade:setVisible(true)
end

function GlobalShadeLayer:setPopText(text)
    self.Shade:releaseFunc(function ()
        PopText(text)

        if Game:isTesting() == true then
            local fp = io.open(FILE,"r")

            if fp == nil then
                return 
            end

            local str = fp:read("*all")

            print(str)

            fp:close()
        end
    end)
end

function GlobalShadeLayer:hideLayer()
    if self._actionTag ~= nil then
        self:unscheduleAll()
    end

    self.Shade:setTouchEnabled(false)
    self.Shade:setVisible(false)
end

function GlobalShadeLayer:showTime(time)
    self:showLayer()

    if self._actionTag ~= nil then
        self:unscheduleAll()
    end

    self._actionTime = 0
    self._actionTag = self:schedule(function (ft)
        self._actionTime  = self._actionTime + ft

        if self._actionTime >= time then
            self:unscheduleAll()
            self._actionTag = nil
            self:hideLayer()
        end
    end)
end
Helper:classDefNodeGetInstance(GlobalShadeLayer)
return GlobalShadeLayer
0