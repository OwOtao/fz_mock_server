local SwitchServerSelectStartLayer = class("SwitchServerSelectStartLayer", LayerEx)

function SwitchServerSelectStartLayer:create()
    local p = SwitchServerSelectStartLayer.new()
    p:init()
    return p
end

function SwitchServerSelectStartLayer:init()
    self._itemFunc1 = function()end
    self._itemFunc2 = function()end

    self.UI = require("Layer/SwitchServerUI/SelectStartUI.lua").create()['root']
    self:addChild(self.UI)
    Helper:convertUIByParent(self)
    
    self:initButton()
end

function SwitchServerSelectStartLayer:initButton()
    self.Panel_back:releaseFunc(function()
        self:hide()
    end)

    --　继承老号
    self.Image_item1:releaseFunc(function()        
        self._itemFunc1()
    end)
    
    -- 玩新号
    self.Image_item2:releaseFunc(function()
        self._itemFunc2()        
    end)
end

function SwitchServerSelectStartLayer:setItemFunc1(func)
    self._itemFunc1 = Helper:getDef(func, function()end)    
end

function SwitchServerSelectStartLayer:setItemFunc2(func)
    self._itemFunc2 = Helper:getDef(func, function()end)    
end



Helper:classDefNodeGetInstance(SwitchServerSelectStartLayer)
return SwitchServerSelectStartLayer
0000