--[[
    author:Seven
    time:2023-02-17 15:46:51
    desc: 存放格挡每一击信息

    extend ：app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult
]]
local newClass = require("third.class.NewClass")
local OneAttackHitResult = require("app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult")

--@SuperType [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
local OneAttackParryResult = {}

function OneAttackParryResult:create()
    return OneAttackParryResult.new()
end

--@desc: 存放目标被打断的信息
--@author:Seven
--@time:2023-02-17 15:50:25
--@info: 击飞或打断信息
function OneAttackParryResult:setTargetWeaponFlyOrBlockInfo(info)
    self.__flyOrBlockInfo = info
end

--@desc: 获取打飞打断信息，可能为空
--@author:Seven
--@time:2023-02-17 15:51:22
--@return: nil | 打飞打断信息
function OneAttackParryResult:getTargetWeaponFlyOrBlockInfo()
    return self.__flyOrBlockInfo
end

return newClass("OneAttackParryResult", {OneAttackHitResult}, OneAttackParryResult)
00000