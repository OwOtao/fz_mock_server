local recordAndLearnSKillsPresenters = class("recordAndLearnSKillsPresenters", cc.Layer)

function recordAndLearnSKillsPresenters:create()
    local p = recordAndLearnSKillsPresenters:new()
    p:init()
    return p
end

function recordAndLearnSKillsPresenters:init()
    self._actionUI = require("app.views.ui.recordAndLearnSKillsUI.recordAndLearnSKillsUI"):create()

    self._actionUI:addTo(self)

    self._actionUI:setButtonBackFunc(function()
        self._actionUI:hideUI()
        self:hideLayer()
    end)

    self._actionUI:setPanelInfoCloseFunc()

    local recordAndLearnSKills = require("app.models.recordAndLearnSKills.recordAndLearnSKills")

    self._interactor = recordAndLearnSKills:create()

    self.listType = recordAndLearnSKills:getListType()

    self.listTitle = recordAndLearnSKills:getListTitle()
end

function recordAndLearnSKillsPresenters:showLayer(showType)
    self._role = User:getRole()
    
    self._interactor:setRole(self._role)

    if showType == 1 then
        self:__initRecordData()
    elseif showType == 2 then
        self:__initLearnData()
    end
end

function recordAndLearnSKillsPresenters:__initRecordData()
    self._titleType = self.listType.RECORD_QUANJIAO
    self._interactor:initRecordSkills(function()
        self:__initRecordUI()
        self._actionUI:setTtitleBgLight(1)
        self._actionUI:setTtitleText({self.listTitle[self.listType.RECORD_QUANJIAO],self.listTitle[self.listType.RECORD_BINGQI],
        self.listTitle[self.listType.RECORD_QINGGONG],self.listTitle[self.listType.RECORD_NEIGONG]})
        self._actionUI:showUI()
    end)
end

function recordAndLearnSKillsPresenters:__initRecordUI()
    self:setTitleName("武学记录")
    self:showListInfos()
    self:setTitle_1Func(self.listType.RECORD_QUANJIAO)
    self:setTitle_2Func(self.listType.RECORD_BINGQI)
    self:setTitle_3Func(self.listType.RECORD_QINGGONG)
    self:setTitle_4Func(self.listType.RECORD_NEIGONG)
end

function recordAndLearnSKillsPresenters:__initLearnData()
    self._titleType = self.listType.LEARN_QUANJIAO
    self._interactor:initLearnSkills(function()
        self:__initLearnUI()
        self._actionUI:setTtitleBgLight(1)
        self._actionUI:setTtitleText({self.listTitle[self.listType.LEARN_QUANJIAO],self.listTitle[self.listType.LEARN_BINGQI],
        self.listTitle[self.listType.LEARN_QINGGONG],self.listTitle[self.listType.LEARN_NEIGONG]})
        self._actionUI:showUI()
    end)
end

function recordAndLearnSKillsPresenters:__initLearnUI()
    self:setTitleName("武学学习")
    self:showListInfos()
    self:setTitle_1Func(self.listType.LEARN_QUANJIAO)
    self:setTitle_2Func(self.listType.LEARN_BINGQI)
    self:setTitle_3Func(self.listType.LEARN_QINGGONG)
    self:setTitle_4Func(self.listType.LEARN_NEIGONG)
end

function recordAndLearnSKillsPresenters:__initExchangeData()
end

function recordAndLearnSKillsPresenters:__initExchangeUI()
end

function recordAndLearnSKillsPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "recordAndLearnSKillsPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function recordAndLearnSKillsPresenters:setTitleName(name)
    self._actionUI:setTitleName(name)
end

function recordAndLearnSKillsPresenters:setTipsVisible(visible)
	self._actionUI:setTipsVisible(visible)
end

function recordAndLearnSKillsPresenters:setTitle_1Func(titleType)
    self._actionUI:setTitle_1Func(function()
        self._titleType = titleType
        self:showListInfos()
    end)
end

function recordAndLearnSKillsPresenters:setTitle_2Func(titleType)
    self._actionUI:setTitle_2Func(function()
        self._titleType = titleType
        self:showListInfos()
    end)
end

function recordAndLearnSKillsPresenters:setTitle_3Func(titleType)
    self._actionUI:setTitle_3Func(function()
        self._titleType = titleType
        self:showListInfos()
    end)
end

function recordAndLearnSKillsPresenters:setTitle_4Func(titleType)
    self._actionUI:setTitle_4Func(function()
        self._titleType = titleType
        self:showListInfos()
    end)
end

function recordAndLearnSKillsPresenters:refreshUI()
    self:showListInfos()
end

function recordAndLearnSKillsPresenters:showListInfos()
    local list = self._interactor:getListByType(self._titleType)


    for k,v in pairs(list) do
        if self._titleType == self.listType.LEARN_BINGQI or self._titleType == self.listType.LEARN_QINGGONG or self._titleType == self.listType.LEARN_NEIGONG 
        or self._titleType == self.listType.LEARN_QUANJIAO then
            v.func = function()
                self._actionUI:setPanelInfoVisible(true)
                self._actionUI:setPanelInfoNameText("武学学习")
                self._actionUI:setPanelInfoDescText("是否确定消耗"..self._interactor:getCurrencyCost()..self._interactor:getCurrencyName().."学习"..v.name.."?")
                self._actionUI:setPanelInfoCloseFunc()
                self._actionUI:setPanelInfoConfirmFunc(function()
                    self._interactor:learnSkill(v.id,function()
                        PopText("消耗了"..self._interactor:getCurrencyCost()..self._interactor:getCurrencyName())
                        PopText("已学习"..v.name)
                        self._interactor:initLearnSkills(function()
                            self:__initLearnUI()
                        end)
                    end)
                end)
            end
        else
            v.func = function()
                self._actionUI:setPanelInfoVisible(true)
                self._actionUI:setPanelInfoNameText("武学记录")
                self._actionUI:setPanelInfoDescText("是否确定消耗"..self._interactor:getCurrencyCost()..self._interactor:getCurrencyName().."记录"..v.name.."?")
                self._actionUI:setPanelInfoCloseFunc()
                self._actionUI:setPanelInfoConfirmFunc(function()
                    self._interactor:recordSkill(v.id,function()
                        PopText("消耗了"..self._interactor:getCurrencyCost()..self._interactor:getCurrencyName())
                        PopText(v.name.."武学已记录到先贤书案中")
                        self._interactor:initRecordSkills(function()
                            self:__initRecordUI()
                        end)
                    end)
                end)
            end
        end
    end
    
    if MapIsEmpty(list) == false then
        self._actionUI:setTipsVisible(false) 
    else
        self._actionUI:setTipsVisible(true)
        if self._titleType == self.listType.LEARN_BINGQI or self._titleType == self.listType.LEARN_QINGGONG or self._titleType == self.listType.LEARN_NEIGONG 
        or self._titleType == self.listType.LEARN_QUANJIAO then
            self._actionUI:seTipsText("暂无可学习武学")
        else
            self._actionUI:seTipsText("暂无可记录武学")
        end
        
    end

    self._actionUI:showItemInfos(list)
end

Helper:classDefNodeGetInstance(recordAndLearnSKillsPresenters)

return recordAndLearnSKillsPresenters


0000000000000000