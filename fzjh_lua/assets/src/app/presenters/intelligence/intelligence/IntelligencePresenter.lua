local inherit = require("third.inherit.inherit")
local IIntelligenceOutput = require("app.presenters.intelligence.intelligence.IIntelligenceOutput")
local IIntelligenceInput = require("app.presenters.intelligence.intelligence.IIntelligenceInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")
local IntelligenceConstants = require("app.models.intelligenceSystem.IntelligenceConstants")
local IntelligenceResManager = require("app.models.intelligenceSystem.IntelligenceResManager")
local Intelligence = require("app.models.intelligenceSystem.intelligence.Intelligence")

local IntelligencePresenter = {}

function IntelligencePresenter:create(IOutput,intelligenceSystem,list)
    local p = inherit({}, IntelligencePresenter)
    p:init(IOutput,intelligenceSystem,list)
    return p
end

function IntelligencePresenter:init(IOutput,intelligenceSystem,list)
    self._IOutput = isImplement(IOutput, IIntelligenceOutput)
    self._System = intelligenceSystem
    self._List = self:listSort(list)
end

function IntelligencePresenter:showLayer()
    self:setBackButton()
    self:showListView()
    self:setDsec()
    self._IOutput:setShowLayer()
end

function IntelligencePresenter:listSort(list)
    if #list > 1 then
        table.sort(list,function(a,b)
            if a.is_read == IntelligenceConstants.UnRead and b.is_read == IntelligenceConstants.IsRead then
                return true
            elseif a.is_read == IntelligenceConstants.IsRead and b.is_read == IntelligenceConstants.UnRead then
                return false
            else
                return a.id < b.id
            end
        end)
    end
    return list
end

function IntelligencePresenter:setBackButton()
    self._IOutput:setBackButton(function()
        Audio:playEffect("fanHuiQuXiao")
        self._IOutput:hideLayer()
        if self._callback then
            self._callback()
        end
    end)
end

function IntelligencePresenter:setDsec()
    self._IOutput:setDsec("鄙人徐书生，每日为少侠献上最新的江湖情报")
end

function IntelligencePresenter:showListView()
    local retArray = {}
    for i,v in ipairs(self._List) do
        local retList = {
            name = "",
            new_isVisible = true,
            func = EMPTY_FUNC
        }

        local id = v.id
        local isRead = v.is_read
        
        if isRead == IntelligenceConstants.IsRead then
            retList["new_isVisible"] = false
        end
        local intelligenceData = IntelligenceResManager:getIntelligenceDataById(id)
        local intelligence = Intelligence:create(intelligenceData)
        local tital = intelligence:getTitle()
        local dsc = intelligence:getText()
        local type = intelligence:getType()
        retList["name"] = tital
        retList["func"] = function(node)
            Audio:playEffect("daAnNiu")
            self._System:readIntelligence(id,type,function()
                node:setVisible(false)
                v.is_read = IntelligenceConstants.IsRead
                self:showTextPopLayer(tital, dsc, function()
                end)
            end)
        end

        table.insert(retArray, retList)
    end

    self._IOutput:setListView(retArray)
end

function IntelligencePresenter:showTextPopLayer(tital, dsc, func)
    local TextPopLayer = require("app.views.layer.DialogLayer.TextPopLayer")
    local dialog = TextPopLayer:getInstance()
    dialog:hide()
    dialog:showLayer(tital, dsc, func)
end

isImplement(IntelligencePresenter, IIntelligenceInput)
return IntelligencePresenter
00000