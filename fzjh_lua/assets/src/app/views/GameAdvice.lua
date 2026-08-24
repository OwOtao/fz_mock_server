local GameAdvice = class("GameAdvice", cc.Layer)

function GameAdvice:create()
	local p = GameAdvice:new()
	p:init()
	return p
end

function GameAdvice:init()
	self._round = require("Layer/GameAdvice.lua").create()['root']
	self._round:addTo(self)
	self:setSelfAndChildrenCascadeOpacityEnabled(true)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 给所有子节点调用方法
function GameAdvice:callAllChild(func)
    local children = self:getChildren()
    for k,child in pairs(children) do
        func(child)
        GameAdvice.callAllChild(child, func)        
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置所有子节点透明度是否级联变化
function GameAdvice:setSelfAndChildrenCascadeOpacityEnabled(b)
    self:setCascadeOpacityEnabled(b)
    self:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(b)
        end)
end

return GameAdvice0000000000