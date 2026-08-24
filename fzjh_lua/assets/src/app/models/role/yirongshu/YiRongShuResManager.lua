local yiRongShuEffectAttr = require("script.zhishiSkills.yiRongShuEffectAttr")["data"]

local yiRongShuSpecialHead = require("script.zhishiSkills.yiRongShuSpecialHead")["Sheet1"]

local yiRongShuLookMask = require("script.zhishiSkills.yiRongShuLookMask")["data"]

local YiRongShuResManager = {}

function YiRongShuResManager:getEffectAttrMap()
    return yiRongShuEffectAttr
end

function YiRongShuResManager:getEffectAttrById(id)
    return assert(yiRongShuEffectAttr[tostring(id)],"易容术资源找不到 id = "..id)
end

function YiRongShuResManager:getSpecialHeadMap()
    return yiRongShuSpecialHead
end

function YiRongShuResManager:getLookMaskMap()
    return yiRongShuLookMask
end

return YiRongShuResManager0000000000