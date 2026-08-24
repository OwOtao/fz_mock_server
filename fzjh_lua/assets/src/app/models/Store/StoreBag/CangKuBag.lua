local newClass = require("third.class.NewClass")
local BaseBag = require("app.models.Store.StoreBag.BaseBag")
local CangKuBag = {}

function CangKuBag:create(role)
    local p = CangKuBag.new()
    p:init(role)
    return p
end

return newClass("CangKuBag", {BaseBag}, CangKuBag)
0000000000000