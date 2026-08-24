local GoodsPresenterFactory = {}
local Goods = require("app.models.Store.Goods")
local VIEWTYPE = Goods.Const.VIEWTYPE

function GoodsPresenterFactory:createGoodsPrensenter(goods)
    local goodsViewType = goods:getViewType()

    local prensenter = switch(goodsViewType,
            {
                [VIEWTYPE.MASK] = function()
                    return require("app.presenters.GoodsInfo.MaskInfoPresenter"):create(goods)
                end,
                [VIEWTYPE.APPEARANCE] = function()
                    return require("app.presenters.GoodsInfo.AppearanceInfoPresenter"):create(goods)
                end,
                [VIEWTYPE.SKILL] = function()
                    return require("app.presenters.GoodsInfo.SkillGoodsInfoPresenter"):create(goods)
                end,
                [VIEWTYPE.BOX] = function()
                    return require("app.presenters.GoodsInfo.BoxGoodsInfoPresenter"):create(goods)
                end,
                default = function()
                    return require("app.presenters.GoodsInfo.NormalGoodsInfoPresenter"):create(goods)
                end,
            }
        )

    return prensenter
end

return GoodsPresenterFactory
00000000