local inherit = require("third.inherit.inherit")
local IJiangHuSecretOutput = require("app.presenters.intelligence.jianghuSecret.IJiangHuSecretOutput")
local IJiangHuSecretInput = require("app.presenters.intelligence.jianghuSecret.IJiangHuSecretInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")
local IntelligenceConstants = require("app.models.intelligenceSystem.IntelligenceConstants")
local IntelligenceResManager = require("app.models.intelligenceSystem.IntelligenceResManager")
local Intelligence = require("app.models.intelligenceSystem.intelligence.Intelligence")

local JiangHuSecretPresenter = {}

function JiangHuSecretPresenter:create(IOutput,intelligenceSystem,list)
    local p = inherit({}, JiangHuSecretPresenter)
    p:init(IOutput,intelligenceSystem,list)
    return p
end

function JiangHuSecretPresenter:init(IOutput,intelligenceSystem,list)
    self._IOutput = isImplement(IOutput, IJiangHuSecretOutput)
    self._System = intelligenceSystem
    self._List = self:listSort(list)
end

function JiangHuSecretPresenter:showLayer()
    self:initData()
    self:setTextNum()
    self:setTextPageNum()
    self:setNotSecretVisible()
    self:setBackButton()
    self:showListView()
    self:setPageButton()
    
    self._IOutput:setShowLayer()
end

function JiangHuSecretPresenter:listSort(list)
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

function JiangHuSecretPresenter:initData()
    self._onePageNum = 7
    self._index = 1
    local mod, remainder = math.modf(#self._List/self._onePageNum)
    if math.ceil(remainder) == 1 then
        mod = mod + 1
    end
    self._minIndex = 1
    self._maxIndex = math.max(mod,1) 
end

function JiangHuSecretPresenter:setNotSecretVisible()
    local isVisible = true
    if #self._List > 0 then
        isVisible = false
    end
    self._IOutput:setNotSecretVisible(isVisible)
end

function JiangHuSecretPresenter:setBackButton()
    self._IOutput:setBackButton(function()
        Audio:playEffect("fanHuiQuXiao")
        self._IOutput:hideLayer()
    end)
end

function JiangHuSecretPresenter:setPageButton()
    self:initPageButtonState()
    self:setUpPageButton()
    self:setDownPageButton()
end

function JiangHuSecretPresenter:setTextNum()
    local textNum = "当前技巧："..#self._List
	self._IOutput:setTextNum(textNum)
end

function JiangHuSecretPresenter:setTextPageNum()
    local textPageNum = self._index.."/"..self._maxIndex
	self._IOutput:setTextPageNum(textPageNum)
end

function JiangHuSecretPresenter:setUpPageButton()
    self._IOutput:setUpPageButton(function()
        Audio:playEffect("xiaoAnNiu")
        self._index = self._index - 1
        self:setTextPageNum()
        self:initPageButtonState()
        self:showListView()
    end)
end

function JiangHuSecretPresenter:setDownPageButton()
    self._IOutput:setDownPageButton(function()
        Audio:playEffect("xiaoAnNiu")
        self._index = self._index + 1
        self:setTextPageNum()
        self:initPageButtonState()
        self:showListView()
    end)
end

function JiangHuSecretPresenter:initPageButtonState()
    if self._minIndex == self._maxIndex then
        self._IOutput:setUpPageButtonEnabled(false)
        self._IOutput:setDownPageButtonEnabled(false)
    else
        if self._index == self._minIndex then
            self._IOutput:setUpPageButtonEnabled(false)
            self._IOutput:setDownPageButtonEnabled(true)
        elseif self._index > self._minIndex and self._index < self._maxIndex then
            self._IOutput:setUpPageButtonEnabled(true)
            self._IOutput:setDownPageButtonEnabled(true)
        elseif self._index == self._maxIndex then
            self._IOutput:setUpPageButtonEnabled(true)
            self._IOutput:setDownPageButtonEnabled(false)
        end
    end
end

function JiangHuSecretPresenter:showListView()
    local retArray = {}
    local startIndex = (self._index - 1)*self._onePageNum + 1
    for i = startIndex,startIndex + self._onePageNum - 1 do
        local v = self._List[i]
        if v then
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
        else
            break
        end
    end

    self._IOutput:setListView(retArray)
end

function JiangHuSecretPresenter:showTextPopLayer(tital, dsc, func)
    local TextPopLayer = require("app.views.layer.DialogLayer.TextPopLayer")
    local dialog = TextPopLayer:getInstance()
    dialog:hide()
    dialog:showLayer(tital, dsc, func)
end

isImplement(JiangHuSecretPresenter, IJiangHuSecretInput)
return JiangHuSecretPresenter
0000000000