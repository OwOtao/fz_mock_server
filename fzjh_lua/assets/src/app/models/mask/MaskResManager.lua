local MaskResManager = {
    _maskGradeMap = {},
    _maskAttrMap = {},
    _maskTuJianMap = {},
}

local function loadMaskGradeMap()
    local MaskUpgradeRes = require("script.others.maskUpgrade")["Sheet1"]
    local MaskGrade = require("app.models.mask.MaskGrade")
    for k, v in pairs(MaskUpgradeRes) do
        if MaskResManager._maskGradeMap[v.maskId] == nil then
            MaskResManager._maskGradeMap[v.maskId] = {}
        end

        MaskResManager._maskGradeMap[v.maskId][v.maskLevel] = MaskGrade:create(v.id)
    end
end

local function loadMaskResMap()
    local maskRes = require("script.others.maskRes")["Sheet1"]
    local MaskAttr = require("app.models.mask.MaskAttr")
    for k, v in pairs(maskRes) do
        MaskResManager._maskAttrMap[tostring(k)] = MaskAttr:create(k)
    end
end

local function loadMaskTuJianMap()
    local maskTuJian = require("script.others.tujian")["面具"]
    for k, v in pairs(maskTuJian) do
        local items = string.split(v.demand, ";")
        for i, maskId in ipairs(items) do
            if MaskResManager._maskTuJianMap[maskId] == nil then
                MaskResManager._maskTuJianMap[maskId] = {}
            end

            table.insert(MaskResManager._maskTuJianMap[maskId], v)
        end
    end
end

loadMaskGradeMap()
loadMaskResMap()
loadMaskTuJianMap()

function MaskResManager:getMaskGradeMap(maskId)
    return assert(self._maskGradeMap[tostring(maskId)], "没有面具等级相关资源 maskId = " .. maskId)
end

function MaskResManager:getMaskGrade(maskId, lv)
    local mask = self._maskGradeMap[tostring(maskId)]
    assert(mask, "没有找到该面具相关数据maskId = " .. maskId)
    return assert(mask[lv], "没有找到面具等级相关数据maskId = " .. maskId .. " lv = " .. lv)
end

function MaskResManager:getMaskAttr(maskAttrId)
    return assert(self._maskAttrMap[tostring(maskAttrId)], "没有面具资源 maskAttrId = " .. maskAttrId)
end

function MaskResManager:getMaskTuJianInfo(maskId)
    return assert(self._maskTuJianMap[tostring(maskId)], "没有面具图鉴相关数据 maskId = " .. maskId)
end

--@return [src.app.models.mask.MaskAttr#MaskAttr]
function MaskResManager:getMaskAttrByMaskIdAndLv(maskId, lv)
    local maskGrade = self:getMaskGrade(maskId, lv)
    local maskAttrId = maskGrade:getCurrTimeArtsId()
    local maskAttr = self:getMaskAttr(maskAttrId)
    return maskAttr
end

function MaskResManager:getAllMaskIdAndMaxLv()
    local list = {}
    for id, lvInfo in pairs(self._maskGradeMap) do
        table.insert(list, {id = id, lv = #lvInfo})
    end
    return list
end

return MaskResManager
00000000000