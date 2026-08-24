local SelectButtonModel = {}

function SelectButtonModel:getUpList()
    return self._upList
end

function SelectButtonModel:getDownList()
    return self._downList
end

function SelectButtonModel:initUpList(list)
    self._upList = list or {}

    self:sortLeftList()
end

function SelectButtonModel:initDownList(list)
    self._downList = list or {}
end

function SelectButtonModel:addButtonToDownList(data)
    table.insert( self._downList,data)
end

function SelectButtonModel:removeButtonFromDownList(data)
    if MapIsEmpty(self._downList) then
        return
    end
    for i,v in ipairs(self._downList) do
        if v.id == data.id then
            table.remove(self._downList,i)
        end
    end
end

function SelectButtonModel:sortLeftList()
    
end

function SelectButtonModel:clear()
    self._rightList = {}
    self._leftList = {}
end

return SelectButtonModel
00