--[[
	根据图片和特效名展示
]]
local newClass = require("third.class.NewClass")
local HVIPresent = {}

function HVIPresent:create(node,data)
    local p = HVIPresent.new()
	p:init(node,data)
    return p
end

function HVIPresent:init(node,data)
    if node:getChildByName("headView") then
        self._headView = node:getChildByName("headView")
    else
        local NewHeadView = require("app.views.ui.HeadView.NewHeadView")
        self._headView = NewHeadView:create(node)
    end
    self._path = data.path
    self._effect = data.effect
end

function HVIPresent:showHead()
    self._headView:showHead(self._path)
end

function HVIPresent:showAnim()
    local anim = self._path
    if string.find(anim, ".png") ~= nil then
        self._headView:showHead(anim)
    else
        self._headView:showAnim(anim)
    end
end

function HVIPresent:playEffect()
    local effect = self._effect
    self._headView:playEffect(effect)
end

return newClass("HVIPresent", {}, HVIPresent)0000000000