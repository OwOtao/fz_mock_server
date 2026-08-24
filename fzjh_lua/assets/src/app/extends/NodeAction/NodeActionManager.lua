local NodeActionManager = {}

function NodeActionManager:create()
    local p = clone(NodeActionManager)
    p:__init()
    return p
end

function NodeActionManager:__init()
    self.__actions = {}
    self.__currIndex = 1
end

function NodeActionManager:getActionCount()
    return #self.__actions
end

function NodeActionManager:runAction(node, action)
    action:setTarget(node)
    table.insert(self.__actions, action)
    return action
end

function NodeActionManager:stopAllActions()
    self.__actions = {}
end

function NodeActionManager:update(dt)
    if #self.__actions > 0 then
        for _, action in ipairs(self.__actions) do
            if action:isRemoved() ~= true then
                action:update(dt)

                if action:isFinished() then
                    action:onFinish()
                    action:remove()
                end
            end
        end

        -- 移除完成的action
        for i = #self.__actions, 1, -1 do
            local action = self.__actions[i]
            if action:isRemoved() then
                table.remove(self.__actions, i)
            end
        end
    end
end

return NodeActionManager
000