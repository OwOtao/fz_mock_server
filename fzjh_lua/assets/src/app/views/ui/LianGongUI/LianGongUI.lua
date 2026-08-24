local LianGongUI = class("LianGongUI", LayerEx)

function LianGongUI:create()
	local p = LianGongUI:new()
	p:init()
	return p
end

function LianGongUI:init()
    self._UI = require("Layer/LianGongUI/LianGongPreUI.lua").create()['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)
end

function LianGongUI:showUI()
    self:setVisible(true)
end

function LianGongUI:hideUI()
    self:setVisible(false)
end

function LianGongUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function LianGongUI:setTextXinShenNum(text)
    self.Text_xinshenNum:setString(text)
end

function LianGongUI:setTextTiLiNum(text)
    self.Text_tiliNum:setString(text)
end

function LianGongUI:setTextSubTitle1(text)
    self.Image_kuang.Text_subTitle1:setString(text)
end

function LianGongUI:setTextSubTitle2(text)
    self.Image_kuang.Text_subTitle2:setString(text)
end

function LianGongUI:setTextSubTitle3(text)
    self.Image_kuang.Text_subTitle3:setString(text)
end

function LianGongUI:setListView(array)
    for i,v in ipairs(array) do
        local panel = self.Image_kuang.ListView_list:getItem(i - 1)
        if panel == nil then
            panel = self.Panel_row:clone()
            self.Image_kuang.ListView_list:pushBackCustomItem(panel)
        end

        Helper:convertUIByParent(panel)

        panel.Text_title:setString(v["title"])
        panel.Text_num:setString(v["content"])

        if v["tipVisible"] == true then
            panel.Panel_tip:setVisible(true)
            local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
            local dialog = DialogELayer:getInstance()
            panel.Panel_tip:addTouchEventListener(
            function(ref, eventType)
                if eventType == ccui.TouchEventType.began then
                    panel.Panel_tip.Image_7:setVisible(false)
                elseif eventType == ccui.TouchEventType.ended then
                    dialog:show(v["tipText"])
                    dialog:setPanelBack(function()
                        panel.Panel_tip.Image_7:setVisible(true)
                    end)
                elseif eventType == ccui.TouchEventType.canceled then
                    panel.Panel_tip.Image_7:setVisible(true)
                end
            end)
        else
            panel.Panel_tip:setVisible(false)
        end
    end

    for i = #array + 1, #self.Image_kuang.ListView_list:getItems() do
		self.Image_kuang.ListView_list:removeLastItem()
	end
end

function LianGongUI:setSelectLvText(text)
    self.Image_kuang.Text_selectLv:setString(text)
end

function LianGongUI:setSelectJingNum(text)
    self.Image_kuang.Text_selectJing:setString(text)
end

function LianGongUI:setSelectTiLiNum(text)
    self.Image_kuang.Text_selectTili:setString(text)
end

function LianGongUI:setButtonLv1(data)
    self.Image_kuang.Button_lv01:loadTextureNormal(data["image"])
    self.Image_kuang.Button_lv01:setTitleText(data["title"])
    self.Image_kuang.Button_lv01:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_lv01:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonLv2(data)
    self.Image_kuang.Button_lv02:loadTextureNormal(data["image"])
    self.Image_kuang.Button_lv02:setTitleText(data["title"])
    self.Image_kuang.Button_lv02:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_lv02:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonLv3(data)
    self.Image_kuang.Button_lv03:loadTextureNormal(data["image"])
    self.Image_kuang.Button_lv03:setTitleText(data["title"])
    self.Image_kuang.Button_lv03:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_lv03:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonLv4(data)
    self.Image_kuang.Button_lv04:loadTextureNormal(data["image"])
    self.Image_kuang.Button_lv04:setTitleText(data["title"])
    self.Image_kuang.Button_lv04:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_lv04:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonJing1(data)
    self.Image_kuang.Button_jing01:loadTextureNormal(data["image"])
    self.Image_kuang.Button_jing01:setTitleText(data["title"])
    self.Image_kuang.Button_jing01:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_jing01:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonJing2(data)
    self.Image_kuang.Button_jing02:loadTextureNormal(data["image"])
    self.Image_kuang.Button_jing02:setTitleText(data["title"])
    self.Image_kuang.Button_jing02:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_jing02:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonJing3(data)
    self.Image_kuang.Button_jing03:loadTextureNormal(data["image"])
    self.Image_kuang.Button_jing03:setTitleText(data["title"])
    self.Image_kuang.Button_jing03:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_jing03:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonJing4(data)
    self.Image_kuang.Button_jing04:loadTextureNormal(data["image"])
    self.Image_kuang.Button_jing04:setTitleText(data["title"])
    self.Image_kuang.Button_jing04:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_jing04:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonTiLi1(data)
    self.Image_kuang.Button_tili01:loadTextureNormal(data["image"])
    self.Image_kuang.Button_tili01:setTitleText(data["title"])
    self.Image_kuang.Button_tili01:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_tili01:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonTiLi2(data)
    self.Image_kuang.Button_tili02:loadTextureNormal(data["image"])
    self.Image_kuang.Button_tili02:setTitleText(data["title"])
    self.Image_kuang.Button_tili02:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_tili02:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonTiLi3(data)
    self.Image_kuang.Button_tili03:loadTextureNormal(data["image"])
    self.Image_kuang.Button_tili03:setTitleText(data["title"])
    self.Image_kuang.Button_tili03:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_tili03:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonTiLi4(data)
    self.Image_kuang.Button_tili04:loadTextureNormal(data["image"])
    self.Image_kuang.Button_tili04:setTitleText(data["title"])
    self.Image_kuang.Button_tili04:setTitleColor(data["titleColor"])
    self.Image_kuang.Button_tili04:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function LianGongUI:setButtonConfirm(name,func)
    self.Button_confirm.Text_ButtonName:setString(name)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function LianGongUI:setButtonBack(func)
    self.Button_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function LianGongUI:setButtonXinShen(name,func)
    self.Button_xinshen.Text_ButtonName:setString(name)
    self.Button_xinshen:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return LianGongUI0