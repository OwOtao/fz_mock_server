local YiRongShuNoLayer = class("YiRongShuNoLayer", cc.Layer)

function YiRongShuNoLayer:create()
    local p = YiRongShuNoLayer:new()
    p:init()
    return p
end

function YiRongShuNoLayer:init()
    self._UI = require("Layer/YiRongshu/YiRongShuNoUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self:SetNoButton()
    self:SetYesButton()
    
    self.Panel_back:releaseFunc(function()
        self:hideLayer()
	end)

    if self.handle ~= nil then
        self:unschedule(self.handle)
        self.handle = nil
    end
end

function YiRongShuNoLayer:hideLayer()
	PopupLayerController:hideLayer("YiRongShuNoLayer", function(layer)
        if self.handle ~= nil then
            self:unschedule(self.handle)
            self.handle = nil
        end
		self:hide()
	end) 
end

function YiRongShuNoLayer:showLayer()
    self:show()
    self:setPage()

end

--设置界面显示
function YiRongShuNoLayer:setPage()
    local role = User:getRole()  
    local skillLv = role:getSkillLv("yirongshu")
    local  Cdtime = 86400-math.floor(skillLv/10)*576
    local  Keeptime= math.floor(skillLv/10)*144+14400

    local CdtimeText = self:minConversion(Cdtime)
    local KeeptimeText = self:minConversion(Keeptime)

    self.Text_Tital:setString("易容改貌")
    self.Text_Lv:setString("易容术等级:"..skillLv)
    self.Text_Keeptime:setString("维持时间:"..KeeptimeText)
    self.Text_cdtime:setString("冷却时间:"..CdtimeText)

    local endTime = role.polymorph.endTime    

    self.handle = self:schedule(
        function(ft)
        if not self._useTime then
            self._useTime = GetTime()
        end
        if GetTime() - self._useTime >=1 then
            local time = endTime - GetTime()
            local hour, min,sec = Helper:sec2timeDsc(time)
            local text = hour.."小时"..min.."分钟"..sec.."秒"
            self.Text_desc:setString("持续剩余时间:"..tostring(text))
            self._useTime = GetTime()
        end
    end, 0.1)

end

--@desc 时间转化
function YiRongShuNoLayer:minConversion(sec)  
    local min = sec / 60
    local hour = min / 60
    min = min % 60
    sec = sec % 60
    return math.floor(hour).."小时"..math.floor(min).."分钟".. math.floor(sec).."秒"
end

function YiRongShuNoLayer:SetNoButton()
    self.Button_NO:releaseFunc(function()
		self:hideLayer()
	end)

end

function YiRongShuNoLayer:SetYesButton()
    local role = User:getRole()
    self.Button_Yes:releaseFunc(function()
        self:hideLayer()
        local YiRongShuYesLayer = require("app.views.layer.YiRongShuLayer.YiRongShuYesLayer")
        local dialog = YiRongShuYesLayer:getInstance()
        dialog:showLayer()
        dialog:SetYesButton("确定",function()
            role:cancelPolymorph()

            RichPrint("main","你将薄膜从脸上撕了下来，用清水净了净面庞，你的面容恢复如新。")
        end) 	
    end)

end

Helper:classDefNodeGetInstance(YiRongShuNoLayer)

return YiRongShuNoLayer0000000