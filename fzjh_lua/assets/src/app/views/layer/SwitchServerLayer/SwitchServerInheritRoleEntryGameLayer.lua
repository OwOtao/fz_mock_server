local SwitchServerInheritRoleEntryGameLayer = class("SwitchServerInheritRoleEntryGameLayer", LayerEx)

function SwitchServerInheritRoleEntryGameLayer:create()
    local p = SwitchServerInheritRoleEntryGameLayer.new()
    p:init()
    return p
end

function SwitchServerInheritRoleEntryGameLayer:init()
    self._entryGameFunc = function() end
    
    
    self.UI = require("Layer/SwitchServerUI/InheritRoleEntryGameUI.lua").create()['root']
    self:addChild(self.UI)
    Helper:convertUIByParent(self)

    self:initButton()        
end

function SwitchServerInheritRoleEntryGameLayer:initButton()
    self.Button_1:releaseFunc(function()
        self._entryGameFunc()
    end)
end

function SwitchServerInheritRoleEntryGameLayer:setEntryGameFunc(func)    
    self._entryGameFunc = Helper:getDef(func, function()end)
end

Helper:classDefNodeGetInstance(SwitchServerInheritRoleEntryGameLayer)
return SwitchServerInheritRoleEntryGameLayer000000