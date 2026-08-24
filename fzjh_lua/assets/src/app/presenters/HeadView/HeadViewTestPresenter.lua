local newClass = require("third.class.NewClass")

local IHeadViewPresenter = require("app.presenters.HeadView.IHeadViewPresenter")

local HeadViewTestPresenter = {}

function HeadViewTestPresenter:create(parent)
    local p = HeadViewTestPresenter.new()
    p:__init(parent)
    return p
end

function HeadViewTestPresenter:__init(parent)
    --@RefType [HeadView]
    local ui = require("app.views.ui.HeadView.HeadView"):create()
    ui:maxZ()
    ui:setPosition(cc.p(540, 960))
    parent:addChild(ui)

    self.__ui = ui

    self.__index = 1

    self.__time = 0

    self.__list = {
        "dingchunqiu",
        "taohuadaozhu",
        "yuelingwei",
        "huangrong",
        "dishuiqing",
        "dingdian",
        "zhaowude",
        "yufuren",
        "rongzhuanggongzhu",
        "zhaomin",
        "shipotian",
        "qiaofeng",
        "hushaoxia",
        "yuenv",
        "yinsusu",
        "zhangsanfeng",
        "xmcx",
        "linchaoying",
        "yangbuhui",
        "renwoxing",
        "huanhuaxiake",
        "fengbaoqishi",
        "youshenshi",
        "zuoshenshi",
        "shutong",
        "limotou",
        "quanshi",
        "kuilier",
        "danqingmiaoshou",
        "shenyexing",
        "zhangshengdai",
        "murongmi"
    }

    ui:setHeadImageVisible(false)

            self:showTheHead()
    -- parent:schedule(
    --     function(ft)
    --         self:showTheHead()
    --     end,
    --     1.5
    -- )
end

function HeadViewTestPresenter:showTheHead()
    local id = self.__list[self.__index]

    self.__ui:showTheHeadAnim("murongmi")

    self.__index = self.__index + 1
    if self.__index > #self.__list then
        self.__index = 1
    end
end

return newClass("HeadViewTestPresenter", {IHeadViewPresenter}, HeadViewTestPresenter)
0000