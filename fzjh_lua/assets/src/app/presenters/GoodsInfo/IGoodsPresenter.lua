local interface = require("third.class.interface")
local IGoodsPresenter = {}

function IGoodsPresenter:getUI()
end

function IGoodsPresenter:showUI()
end

function IGoodsPresenter:setButtonBackVisible(visible)
end

function IGoodsPresenter:setButtonBack(func)
end

return interface("IGoodsPresenter", IGoodsPresenter)000