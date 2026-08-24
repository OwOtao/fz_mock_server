--[[
    author:Seven
    time:2023-10-19 14:20:29
    desc:
]]
local class = require("third.class.NewClass")
local abstract = require("third.class.abstract")

local IBaseUI = {
    onInit = function(self)
    end,
    onUpdate = function(self, ft)
    end,
    onDestroy = function(self)
    end
}

local BaseViewUI = {}

function BaseViewUI:create(node)
    if node == nil then
        assert(false, "BaseViewUI create args is error : node is empty")
    end

    local p = self.new()
    p:bindUiNode(node)
    p:init()
    return p
end

function BaseViewUI:setMainView(mainView)
    --@RefType [FightMainView]
    self.__mainView = mainView
end

function BaseViewUI:init()
    self:onInit()
end

function BaseViewUI:getName()
    return self.__node:getName()
end

function BaseViewUI:getNode()
    return self.__node
end

function BaseViewUI:bindUiNode(node)
    self.__node = node

    local function _bindChildren(parent, children)
        if MapIsEmpty(children) == true then
            return
        end

        for i, child in ipairs(children) do
            parent[child:getName()] = child
            _bindChildren(child, child:getChildren())
        end
    end

    return _bindChildren(self, node:getChildren())
end

function BaseViewUI:destory()
    self:onDestroy()
    self.__node = nil
end

function BaseViewUI:onUpdate(dt)
end

function BaseViewUI:onDestroy()
end

return abstract("BaseViewUI", {IBaseUI}, BaseViewUI)
0000