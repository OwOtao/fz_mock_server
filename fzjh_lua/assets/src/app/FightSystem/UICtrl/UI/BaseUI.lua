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

--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#IBaseUI]
local BaseUI = {}

function BaseUI:create(node)
    if node == nil then
        assert(false, "BaseUI create args is error : node is empty")
    end

    local p = self.new()
    p:bindUiNode(node)
    p:init()
    return p
end

function BaseUI:init()
    self:onInit()
end

function BaseUI:getName()
    return self.__node:getName()
end

function BaseUI:getNode()
    return self.__node
end

function BaseUI:bindUiNode(node)
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

function BaseUI:destory()
    self:onDestroy()
    self.__node = nil
end

return abstract("BaseUI", {IBaseUI}, BaseUI)
0000000