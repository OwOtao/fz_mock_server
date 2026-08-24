local EmployDataModel = {}

function EmployDataModel:setEmployModel(model)
    self._employModel = model
end


function EmployDataModel:getEmployData()
    return self._employModel:getList()
end

--@desc 删除列表数据
function EmployDataModel:pop(index)
    self._employModel:pop(index)
    self:setNeedRefresh(true)
end

function EmployDataModel:clearList()
    self._employModel:clear()
end

function EmployDataModel:getNpcId()
    return self._employModel:getNpcId()  
end

function EmployDataModel:setNeedRefresh(bool)
    self._isRefresh = bool
end

--@desc 给UI使用，判断是否需要刷新
function EmployDataModel:getNeedRefresh()
    return self._isRefresh or false
end


function EmployDataModel:refreshList(needCost,callback)
    self._employModel:refresh(needCost,function ()
        if callback then
            callback()
        end
        self:setNeedRefresh(true)
    end)
end

function EmployDataModel:employeeNpc(index,callback)
    -- self._employModel:employeeNpc(data,function()
    --     if callback then
    --         callback()
    --     end
    -- end)

    self._employModel:employeeNpc(index,callback)
end

function EmployDataModel:getDsc()
   return self._employModel:getDsc()
end


return EmployDataModel00000