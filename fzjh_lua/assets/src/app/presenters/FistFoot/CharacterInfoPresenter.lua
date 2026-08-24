local CharacterInfoPresenter = class("CharacterInfoPresenter", cc.Layer)

function CharacterInfoPresenter:create()
    local p = CharacterInfoPresenter:new()
    p:init()
    return p
end

function CharacterInfoPresenter:init()
    self.__ui = require("app.views.ui.FistFootUI.CharacterInfoUI"):create()

    self.__ui:addTo(self)
end

function CharacterInfoPresenter:showLayer()
    self.__index = 1

    self:showListViewCharacter()

    self:setPanelInfo()

    self.__ui:show()
end

function CharacterInfoPresenter:setRole(role)
    self.__role = role
end

function CharacterInfoPresenter:setCharacterLv(lv)
    self.__lv = lv
end

function CharacterInfoPresenter:setCharacterList(characterList)
    self.__characterList = characterList

    table.sort(self.__characterList, function(a,b)
        if a.state == b.state then
            return a.id < b.id
        else
            return b.state > a.state
        end
    end)
end

function CharacterInfoPresenter:setPanelInfo()
    local retData = {}
    local state = self.__characterList[self.__index].state
    local characterId = self.__characterList[self.__index].id
    local effect = self.__role:getFistFootSystem():getFistFootEffect(characterId,self.__lv)
    
    retData.name = effect:getName()
    if state == 0 then
        retData.level = "未解锁"
    else
        retData.level = "已解锁"
    end
    
    retData.desc = effect:getText()

    retData.condition = effect:getOpentext()
    
    self.__ui:setPanel2(retData)
end

function CharacterInfoPresenter:showListViewCharacter()
    local retArray = {}
    for i,v in ipairs(self.__characterList) do
        local retData = {}

        local effect = self.__role:getFistFootSystem():getFistFootEffect(v.id,self.__lv)
        
        retData.name = effect:getName()

        if v.state == 0 then --未解锁
            retData.color = {r = 103,g = 103,b = 103}
        else
            retData.color = {r = 255,g = 255,b = 255}
        end

        if i == self.__index then
            retData.imageVisible = true
            retData.func = EMPTY_FUNC
        else
            retData.imageVisible = false
            
            retData.func = function()
                self.__index = i
    
                self:showListViewCharacter()
    
                self:setPanelInfo()
            end
        end
        

        table.insert(retArray,retData)
    end

    self.__ui:setListViewCharacter(retArray)
end

Helper:classDefNodeGetInstance(CharacterInfoPresenter)
return CharacterInfoPresenter
00000