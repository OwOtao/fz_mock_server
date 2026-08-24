local interface = require("third.class.interface")
local abstract = require("third.class.abstract")

local IRoleInputInterface = {}

function IRoleInputInterface:setOutput(iRoleModelOutput)
end

function IRoleInputInterface:useItem(itemId,func,specialType,useItemNum)
end

local IRoleInputBody = {}

function IRoleInputBody:setOutput(iOutput)
    self._iOutput = iOutput
end

return abstract("IRoleInput", {IRoleInputInterface}, IRoleInputBody)
0