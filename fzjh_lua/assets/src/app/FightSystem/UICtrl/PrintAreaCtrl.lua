local BaseUICtrl = require("app.FightSystem.UICtrl.BaseUICtrl")

local class = require("third.class.NewClass")

--@SuperType [BaseUICtrl]
local PrintAreaCtrl = {}


function PrintAreaCtrl:create()
    local p = self.new()
    return p
end

function PrintAreaCtrl:init()
end


return class("PrintAreaCtrl", {BaseUICtrl}, PrintAreaCtrl)
000000000000000