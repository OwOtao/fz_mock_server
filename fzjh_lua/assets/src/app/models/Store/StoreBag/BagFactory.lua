local BagFactory = {}

local BagType = {
    Bag = "items", --背包
    CangKu = "ckitems", --仓库
    Decorative = "decorative",--装饰箱
    MedicinalBox = "medicinalBox",--药囊
    LiteraryBox = "literaryBox",--书匣
    Shuxiang = "shuxiang",--武功书箱
    ZhaoShuXiang = "zhaoShuXiang",--招式书箱
    XuJuan = "xuJuanXiang",--续卷
    SmeltBox = "smeltBox",--冶炼箱
}

local bagCreateSwitch = {
    [BagType.Bag] = require("app.models.Store.StoreBag.Bag"),
    [BagType.XuJuan] = require("app.models.Store.StoreBag.XuJuanBag"),
    [BagType.ZhaoShuXiang] = require("app.models.Store.StoreBag.ZhaoShuXiangBag"),
    default = function()
        error("BagFactory:create bag type is error")
    end
}

function BagFactory:create(bagType, role)
	return switch(bagType, bagCreateSwitch):create(role)
end

return BagFactory
0000000