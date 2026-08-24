local YiRongShuYesLayer = class("YiRongShuYesLayer", cc.Layer)

function YiRongShuYesLayer:create()
    local p = YiRongShuYesLayer:new()
    p:init()
    return p
end

function YiRongShuYesLayer:init()
    self._UI = require("Layer/YiRongshu/YiRongYesUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self:SetNoButton()
    self:SetYesButton()
    self.Panel_back:releaseFunc(function()
        self:hide()
	end)
end


function YiRongShuYesLayer:showLayer(list)
    self:show()
    self:initShowtext(list)

end

function YiRongShuYesLayer:initShowtext(list)
    Helper:print_lua_table(list)
    if MapIsEmpty(list) then
        self.Text_desc:setString("你确定要停止易容吗？")
    else
        local text1,text2,text3,text4 = "","","",""
        if list.age == 1 then
            text1 = "年轻"
        elseif list.age == 2 then
            text1 = "年老"
        end

        if list.looks == 1 then
            text2 = "漂亮"
        elseif list.looks == 2 then
            text2 = "丑陋"
        end

        if list.sex == 1 then
            text3 = "男"
        elseif list.sex == 2 then
            text3 = "女"
        end

        if list.qi == 1 then
            text4 = "受伤"
        end

        self.Text_desc:setString("你要易容成为一个"..text1..text2..text4.."的"..text3.."人吗？")
    end

end

function YiRongShuYesLayer:SetNoButton(buttonName,func)
    if buttonName then
        self.Button_NO.Text_buttonNoName:setString(buttonName)
    end
    self.Button_NO:releaseFunc(function()
        if func then
            func()
        end
		self:hide()
	end)

end

function YiRongShuYesLayer:SetYesButton(buttonName,func)
    if buttonName then
        self.Button_Yes.Text_buttonYesName:setString(buttonName)
    end
    self.Button_Yes:releaseFunc(function()
        if func then
            func()
        end
        self:hide()
    end)

end

Helper:classDefNodeGetInstance(YiRongShuYesLayer)

return YiRongShuYesLayer000000000