local AddFoldItemCountExecutor = require("app.models.role.item.AddItem.AddFoldItemCountExecutor")
local AddNoFoldItemCountExecutor = require("app.models.role.item.AddItem.AddNoFoldItemCountExecutor")

local AddNoLimitItemExecutor = require("app.models.role.item.AddItem.AddNoLimitItemExecutor")

local AddItemCountExecutorFactory = {}

function AddItemCountExecutorFactory:getFoldAddItemCountExecutor()
    return AddFoldItemCountExecutor:create()
end

function AddItemCountExecutorFactory:getNoFoldAddItemCountExecutor()
    return AddNoFoldItemCountExecutor:create()
end

--@desc: 
--@author:Seven
--@time:2020-09-09 10:50:13
--@return [src.app.models.role.item.AddNoLimitItemExecutor#AddNoLimitItemExecutor]
function AddItemCountExecutorFactory:getAddKongFuBookCountExecutor()
    return AddNoLimitItemExecutor:create()
end

return AddItemCountExecutorFactory
000000000