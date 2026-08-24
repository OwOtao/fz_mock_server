local SheYanKuanDaiLayer = class("SheYanKuanDaiLayer", cc.Layer)
local Resource = require("app.Resource")
function SheYanKuanDaiLayer:create()
    local p = SheYanKuanDaiLayer:new()
    p:init()
    return p
end

function SheYanKuanDaiLayer:init()
    self._UI = require("Layer/Dialog/ItemSelectUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setBack()
    self:createButton()
end

function SheYanKuanDaiLayer:showLayer()
    self:show()
end

function SheYanKuanDaiLayer:hideLayer()
    self:hide()
end

function SheYanKuanDaiLayer:setTitle(text)
    if text == nil then
        text = ""
    end

    self.Text_Title:setString(text)
end


function SheYanKuanDaiLayer:setList(list)
    self.Item_List:removeAllItems()
    local mod, remainder = math.modf(#list / 2)
   	print("-------------------------------------------------mod ",mod,remainder)
    if math.ceil(remainder) == 1 then
    	print("--------------------------------------等于1")
        mod = mod + 1
    end

    local pList = {}
    for i = 1, mod do
        local panel = self.Panel_List:clone()
        Helper:convertUIByParent(panel)
        panel.Button_Left:setVisible(false)
        panel.Button_Right:setVisible(false)
        table.insert(pList, panel)
    end

    for index, data in ipairs(list) do
        local pListIndex = math.ceil(index / 2)
        local panel = pList[pListIndex]

        if index % 2 == 1 then
            panel.Button_Left:setVisible(true)
            panel.Button_Left.Text_name:setString(data.name)
            panel.Button_Left:releaseFunc(function ()               
                self.btnFucn(data.id)
            end)
        elseif index % 2 == 0 then
        	
            panel.Button_Right:setVisible(true)
            panel.Button_Right.Text_name:setString(data.name)
            panel.Button_Right:releaseFunc(function ()              
                self.btnFucn(data.id)
            end)
        else
            assert(false,"代码有问题！！")
        end
    end

    for i,panel in ipairs(pList) do
        self.Item_List:pushBackCustomItem(panel)
    end
end

--@desc: 给选择按钮点击事件
--@author:Liang SongQiang
--@time:2018-01-27 10:43:49
--@func:
function SheYanKuanDaiLayer:setBtnClickFunc(func)
    self.btnFucn = func
end

function SheYanKuanDaiLayer:setBack()
    self.Panel_back:releaseFunc(
        function()
            PopupLayerController:hideLayer(
                "SheYanKuanDaiLayer",
                function(layer)
                    layer:hideLayer()
                end
            )
        end
    )
end

function SheYanKuanDaiLayer:createButton()
	local roleButton = Resource:getUIByName("Button_4")
	self:addChild(roleButton)
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	roleButton:move(cc.p(550, 200))
	roleButton.Text_buttonName:setString("取消")
	roleButton:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
			self:hideLayer()	
	end)
end

Helper:classDefNodeGetInstance(SheYanKuanDaiLayer)
return SheYanKuanDaiLayer
0000000000