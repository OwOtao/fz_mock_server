local IntelligenceResManager = {
    _qingBaoMoBanMap = {},
    _qingBaoKuMap = {},
    _activity_intelligenceArray = {},
    _plot_intelligenceArray = {},
    _technique_intelligenceMap = {},
    _all_mobanArray = {},
    _notTechnique_mobanArray = {}
}
local QingBaoMoBanRes = require("script.others.qingbaomoban")["Sheet1"]
local QingBaoKuRes = require("script.others.qingbaoku")["Sheet1"]
local Intelligence = require("app.models.intelligenceSystem.intelligence.Intelligence")
local IntelligenceMoBan = require("app.models.intelligenceSystem.intelligenceMoBan.IntelligenceMoBan")
local IntelligenceConstants = require("app.models.intelligenceSystem.IntelligenceConstants")

local function loadIntelligenceRes()
    IntelligenceResManager._qingBaoMoBanMap = QingBaoMoBanRes
    IntelligenceResManager._qingBaoKuMap = QingBaoKuRes

    for k,intelligenceData in pairs(IntelligenceResManager._qingBaoMoBanMap) do
        local intelligenceMoBan = IntelligenceMoBan:create(intelligenceData)
        if intelligenceMoBan:getTechniqueOpen() == IntelligenceConstants.TechniqueOpen.UnOpen then
            table.insert(IntelligenceResManager._notTechnique_mobanArray,intelligenceMoBan)
        end
        table.insert(IntelligenceResManager._all_mobanArray,intelligenceMoBan)
    end

    for k,intelligenceData in pairs(IntelligenceResManager._qingBaoKuMap) do
        local intelligence = Intelligence:create(intelligenceData)
        if intelligence:isOpen() == true then
            if intelligence:getType() == IntelligenceConstants.IntelligenceType.Activity then
                table.insert(IntelligenceResManager._activity_intelligenceArray,intelligence)
            elseif intelligence:getType() == IntelligenceConstants.IntelligenceType.Plot then
                table.insert(IntelligenceResManager._plot_intelligenceArray,intelligence)
            elseif intelligence:getType() == IntelligenceConstants.IntelligenceType.Technique then
                IntelligenceResManager._technique_intelligenceMap[intelligence:getId()] = intelligence
            else
                assert(nil,"未知类型"..type(intelligence:getType()).."  "..intelligence:getType())
            end
        end
    end
end

loadIntelligenceRes()

function IntelligenceResManager:getMoBanDataById(mobanId)
    return self._qingBaoMoBanMap[tostring(mobanId)]
end

function IntelligenceResManager:getIntelligenceDataById(intelligenceId)
    return self._qingBaoKuMap[tostring(intelligenceId)]
end

function IntelligenceResManager:getMoBanMap()
    return self._qingBaoMoBanMap
end

function IntelligenceResManager:get_activity_intelligenceArray()
    return self._activity_intelligenceArray
end

function IntelligenceResManager:get_plot_intelligenceArray()
    return self._plot_intelligenceArray
end

function IntelligenceResManager:get_technique_intelligenceMap()
    return self._technique_intelligenceMap
end

function IntelligenceResManager:get_all_mobanArray()
    return self._all_mobanArray
end

function IntelligenceResManager:get_notTechnique_mobanArray()
    return self._notTechnique_mobanArray
end

return IntelligenceResManager00