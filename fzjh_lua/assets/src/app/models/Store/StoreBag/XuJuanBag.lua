local newClass = require("third.class.NewClass")
local BaseBag = require("app.models.Store.StoreBag.BaseBag")
local CurrencyUtil = require("app.models.Currency.CurrencyUtil")
local RoleBagCurrency = require("app.models.Store.StoreItem.RoleBagCurrency")
local XuJuanBag = {}

function XuJuanBag:create(role)
    local p = XuJuanBag.new()
    p:init(role)
    return p
end

function XuJuanBag:initList()
    HttpManagerEx:getZhaoBreakThroughItems(self.__role:getCurrencyVersion(),
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    if MapIsEmpty(data.matters_list) == false then
                        for k, v in ipairs(data.matters_list) do
                            table.insert(self.__sellList, {count = v.num, index = self.__index})
                            
                            local itemData = {
                                canSell = false,
                                isCurrency = true,
                                sellMsg = "此物过于珍贵，对方并不打算购买此物"
                            }

                            self.__listData[tostring(self.__index)] = RoleBagCurrency:create(v.id, itemData)

                            self.__index = self.__index + 1
                        end
                    end
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )

end

return newClass("XuJuanBag", {BaseBag}, XuJuanBag)
00000000000000