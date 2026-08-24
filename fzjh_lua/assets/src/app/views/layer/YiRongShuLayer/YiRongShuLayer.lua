local YiRongShuLayer = class("YiRongShuLayer", cc.Layer)

local YiRongShuYesLayer =  require("app.views.layer.YiRongShuLayer.YiRongShuYesLayer")

function YiRongShuLayer:create()
    local p = YiRongShuLayer:new()
    p:init()
    return p
end

function YiRongShuLayer:init()
    self._UI = require("Layer/YiRongshu/YiRongShuUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    
    self:setNoButton()
    self:setYesButton()

    self:recordSelectBtn()
    self.Panel_back:releaseFunc(function()
        self:hideLayer()
	end)
end

function YiRongShuLayer:showLayer()
    self:setPage()
    self:show()
    self:initSelectBtn()

    self.__list = {
        age = 0 ,   -- 年轻 = 1, 年老 =2
        looks = 0,	-- 漂亮 = 1, 丑陋 =2
        sex = 0,	-- 男 = 1, 女 =2
        qi = 0,		-- 受伤 = 1  未受伤 = 0
        luckNum = 0 --幸运值阈值,有概率变成特殊容貌
    }
end

function YiRongShuLayer:hideLayer()
	PopupLayerController:hideLayer("YiRongShuLayer", function(layer)
		self:hide()
	end) 
end
--设置界面显示
function YiRongShuLayer:setPage()
    local role = User:getRole()
    local skillLv = role:getSkillLv("yirongshu")
    local Cdtime = 86400-math.floor(skillLv/10)*576
    local Keeptime = math.floor(skillLv/10)*144+14400

    local CdtimeText = self:minConversion(Cdtime)
    local KeeptimeText = self:minConversion(Keeptime)

    self.Panel_attr.Text_Tital:setString("易容改貌")
    self.Panel_attr.Text_Lv:setString("易容术等级:"..skillLv)
    self.Panel_attr.Text_Keeptime:setString("维持时间:"..KeeptimeText)
    self.Panel_attr.Text_cdtime:setString("冷却时间:"..CdtimeText)

end

--@desc 时间转化
function YiRongShuLayer:minConversion(sec)  
    local min = sec / 60
    local hour = min / 60
    min = min % 60
    sec = sec % 60
    return math.floor(hour).."小时"..math.floor(min).."分钟".. math.floor(sec).."秒"
end



function YiRongShuLayer:initSelectBtn()
    self.Panel_age.CheckBox_1:setSelectedState(false)
    self.Panel_age.CheckBox_2:setSelectedState(false)
    self.Panel_look.CheckBox_3:setSelectedState(false)
    self.Panel_look.CheckBox_4:setSelectedState(false)
    self.Panel_sex.CheckBox_5:setSelectedState(false)
    self.Panel_sex.CheckBox_6:setSelectedState(false)
    self.Panel_hurt.CheckBox_7:setSelectedState(false)
end
-- @desc 记录选择的事件
function YiRongShuLayer:recordSelectBtn()
    local row1  = self.Panel_age.CheckBox_1
    local row2  = self.Panel_age.CheckBox_2
    local row3  = self.Panel_look.CheckBox_3
    local row4  = self.Panel_look.CheckBox_4
    local row5  = self.Panel_sex.CheckBox_5
    local row6  = self.Panel_sex.CheckBox_6
    local row7  = self.Panel_hurt.CheckBox_7
    local function selectedEvent(sender, eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            if sender == row1 then
                self.__list.age = 1
                row2:setSelectedState(false)
            elseif sender == row2 then
                self.__list.age = 2
                row1:setSelectedState(false)
            elseif sender == row3 then
                self.__list.looks = 2
                row4:setSelectedState(false)
            elseif sender == row4 then
                self.__list.looks = 1
                row3:setSelectedState(false)
            elseif sender == row5 then
                self.__list.sex = 1
                row6:setSelectedState(false)
            elseif sender == row6 then
                self.__list.sex = 2
                row5:setSelectedState(false)
            elseif sender == row7 then
                self.__list.qi = 1
            end          
        elseif eventType == ccui.CheckBoxEventType.unselected then
            if sender == row1 or sender == row2 then
                self.__list.age = 0
            elseif sender == row3 or sender == row4 then
                self.__list.looks = 0
            elseif sender == row5 or sender == row6 then
                self.__list.sex = 0
            elseif sender == row7 then
                self.__list.qi = 0
            end           
        end
    end
    row1:addEventListenerCheckBox(selectedEvent)
    row2:addEventListenerCheckBox(selectedEvent)
    row3:addEventListenerCheckBox(selectedEvent)
    row4:addEventListenerCheckBox(selectedEvent)
    row5:addEventListenerCheckBox(selectedEvent)
    row6:addEventListenerCheckBox(selectedEvent)
    row7:addEventListenerCheckBox(selectedEvent)
end

-- @desc 取消按钮
function YiRongShuLayer:setNoButton()
    self.Button_NO.Text_buttonNoName:setString("取消")
    self.Button_NO:releaseFunc(function()
		self:hideLayer(function()
		
		end)
	end)
end

-- @desc 易容按钮
function YiRongShuLayer:setYesButton()
    self.Button_Yes.Text_buttonYesName:setString("易容")
    self.Button_Yes:releaseFunc(function()
        if self.__list.age == 0 and self.__list.looks == 0 and self.__list.sex == 0 and self.__list.qi == 0 then
            PopText("你至少选择其中一项方可进行易容")
            return
        else
            local role = User:getRole()
            local luckNum = math.random(1,100)
            self.__list.luckNum = luckNum
            
            self:hideLayer()
            local dialog = YiRongShuYesLayer:getInstance()
            dialog:showLayer(self.__list)
            dialog:SetNoButton("取消",function()					
            end)
            dialog:SetYesButton("确定",function()
                role:doPolymorph(self.__list)
                self:richPrintYiRongText()
            end)
        end        
    end)
    
end

function YiRongShuLayer:richPrintYiRongText()
	--易容的文本输出  8秒输出完
	local text ={
		"你用清水将脸洗净，拿出诸多易容用具，放在一旁。",
		"你将易容用品一一涂抹在脸上，形成了一层薄薄的面膜。",
		"你按照你心中所想，揉捏着脸上的面膜，你的妆容越来越细致。", 
		"你深呼一口气，站在镜前，镜中的人与你原本的样貌相去甚远，你已改头换面，焕然一新。"
	}
	for i = 1, #text do
		self:delayFunc((i - 1) * 2,               
			function()
				RichPrint("main", text[i])		
			end
		)
	end
end

Helper:classDefNodeGetInstance(YiRongShuLayer)

return YiRongShuLayer000000000