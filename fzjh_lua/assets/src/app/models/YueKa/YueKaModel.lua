local YueKaModel = {}

 function YueKaModel:canBuy(currDay)
    if currDay + 30 >= 760 then
        return false
    end
    return true
end

return YueKaModel00000000