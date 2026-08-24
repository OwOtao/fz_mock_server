local StateMachine = {}

function StateMachine:create(stateMap, stateSwitchMap, currStateId)
	local p = clone(StateMachine)
	p:init(stateMap, stateSwitchMap, currStateId)
	return p
end

function StateMachine:init(stateMap, stateSwitchMap, currStateId)
	self._currStateId = currStateId

	self._stateMap = clone(stateMap)
	self._stateSwitchMap = clone(stateSwitchMap)

	for k, state in pairs(self._stateMap) do
		state.id = k
	end
end

function StateMachine:setCurrStateId(stateId)
	self._currStateId = stateId
end

function StateMachine:getCurrStateId()
	return self._currStateId	
end

function StateMachine:getCurrState()
	return 
end

function StateMachine:getState(stateId)
	return self._stateMap[stateId]
end

function StateMachine:update()
	local a2oMap = self._stateSwitchMap[self:getCurrStateId()]
	for toStateId, a2b in pairs(a2oMap) do
		if a2b.cond() then
			self:setCurrStateId(toStateId) --先设置状态机,再刷新 add by LvBin 
			if a2b.act then
				a2b.act()
			end
			
		end
	end
end

return StateMachine0