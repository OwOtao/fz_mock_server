local class = require("third.class.NewClass")
local abstract = require("third.class.abstract")

local baseUICtrlAbstractFunc = {
    init = function(self)
    end,
    destroy = function(self)
    end
}

local BaseUICtrl = {}

function BaseUICtrl:create()
end

function BaseUICtrl:getName()
    return self.node:getName()
end

--@desc: UI帧更新
--@author:Seven_L
--@time:2020-04-25 14:24:52
--@dt: UI更新
function BaseUICtrl:update(dt)
end

function BaseUICtrl:bindUiNode(node)
    self._node = node

    local function _bindChildren(parent, children)
        if MapIsEmpty(children) == true then
            return
        end

        for i, child in ipairs(children) do
            parent[child:getName()] = child
            _bindChildren(child, child:getChildren())
        end
    end

    local children = node:getChildren()

    return _bindChildren(self, children)
end

return abstract("BaseUICtrl", {}, BaseUICtrl)
0000000000000000