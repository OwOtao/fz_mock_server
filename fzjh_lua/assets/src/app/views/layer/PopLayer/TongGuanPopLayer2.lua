local TongGuanPopLayer2 = class("TongGuanPopLayer2", LayerEx)

function TongGuanPopLayer2:create()
    local p = TongGuanPopLayer2:new()
    p:init()
    return p
end

function TongGuanPopLayer2:init()
	self._UI = require("Layer/PopUI/TongGuanPopUI2.lua").create()['root']
	self._UI:addTo(self)
	
	Helper:convertUIByParent(self) -- 获得所有子节点
end

function TongGuanPopLayer2:hideLayer()
    PopupLayerController:hideLayer("TongGuanPopLayer2",function (layer)
        layer:hide()
    end)
end

function TongGuanPopLayer2:showLayer(desc,context)
    self:setContext(context)
    self:setDesc(desc)
    self:show()
end

function TongGuanPopLayer2:setDesc(desc)
    self.Text_desc:setTextColor({r = 144, g = 138, b = 71})
    
    desc = Helper:getDef(tostring(desc),"")
    
    self.Text_desc:setString(desc)
end

function TongGuanPopLayer2:setContext(context)
    self.Text_desc:setTextColor({r = 207, g = 207, b = 207})
    
    context = Helper:getDef(tostring(context),"")
    
    self.Text_context:setString(context)
end

function TongGuanPopLayer2:setLeftFunc(name,func)
    name = Helper:getDef(tostring(name),"停留")

    self.Button_left.Text_buttonName:setString(name)

    func = Helper:getDef(func,EMPTY_FUNC)
    self.Button_left:releaseFunc(function ()
        func()
    end)
end

function TongGuanPopLayer2:setRightFunc(name,func)
    name = Helper:getDef(tostring(name),"离开")
    
    self.Button_right.Text_buttonName:setString(name)
    
    func = Helper:getDef(func,EMPTY_FUNC)
    self.Button_right:releaseFunc(function ()
        func()
    end)
end

Helper:classDefNodeGetInstance(TongGuanPopLayer2)
return  TongGuanPopLayer2000000000000