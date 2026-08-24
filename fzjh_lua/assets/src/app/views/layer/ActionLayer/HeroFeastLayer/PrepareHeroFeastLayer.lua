local PrepareHeroFeastLayer = class("PrepareHeroFeastLayer", LayerEx)
local HeroFeastModel = require("app.models.Action.HeroFeast.HeroFeastModel")
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

function PrepareHeroFeastLayer:create()
	local p = PrepareHeroFeastLayer:new()
	p:init()
	return p
end
function PrepareHeroFeastLayer:init()
	local UI = require("Layer/ActionUI/HeroFeast/PrepareHeroFeastUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
end

function PrepareHeroFeastLayer:showLayer()
    self:initUi()
    self:show()
end

function PrepareHeroFeastLayer:setTextTitalAndDsc()
    local data = HeroFeastModel:getHeroFeastDataByTime()
    local text = "  #ch#，今天是"..data.day.."，是否要吩咐下人准备今晚的宴席了？"
    text = HomelandDesc:subChengHuText(text)
    self.Text_Tital:setString("新春英雄宴")
    self.Text_desc:setString(text)
    self.Text_Tital1:setString(data.name)
end

--初始化界面
function PrepareHeroFeastLayer:initUi()
    self.ListView_1:removeAllItems()
    local FoodIdAndNumArry = HeroFeastModel:getFoodIdAndNumArry()
    for i,v in ipairs(FoodIdAndNumArry) do
        local panel = self:createPanel(v)
        self.ListView_1:pushBackCustomItem(panel)
    end
    self:setlevelButton()
    self:setPrepareButton()
    self:setTextTitalAndDsc()
end

function PrepareHeroFeastLayer:createPanel(list)
    local panel = self.Panel_1:clone()
    Helper:convertUIByParent(panel)

    local role = User:getRole()
    local foodId = list.id
    local num = list.num
    local count = role:getItemCount(foodId)
    local foodItem = Item:getOneItemByKey(foodId)
    if foodItem == nil then
        assert(false,"物品不存在 Id= "..foodId)
    end
    local foodName = foodItem.name

    panel.Text_name:setString(foodName)
    panel.Text_num:setString(count.."/"..num)

    return panel
end


--设置准备宴席按钮
function PrepareHeroFeastLayer:setPrepareButton()
    self.Button_Prepare.Text_buttonNoName:setString("准备宴席")
    self.Button_Prepare:releaseFunc(function()
        if HeroFeastModel:checkIsActivityTime() == false then
            self:hideLayer()
            PopText("已经过了举办宴席的时间！")
            return
        end
        if HeroFeastModel:checkFoodNumIsEnough() == false then
            self:hideLayer()
            PopText("宴席需要的食材不足！")
            return
        end

        PopupLayerController:showLayer("PrepareDrinksLayer",function(layer)
            layer:showLayer()
        end
        )
    end)
end

--设置离开按钮
function PrepareHeroFeastLayer:setlevelButton()
    self.Button_Leave.Text_buttonNoName:setString("再考虑考虑")
    self.Button_Leave:releaseFunc(function()
        self:hideLayer()
    end)
end

function PrepareHeroFeastLayer:hideLayer(func)
    PopupLayerController:hideLayer("PrepareHeroFeastLayer",function(layer)
        if func then
            func()
        end 
        layer:hide()
    end)
end

Helper:classDefNodeGetInstance(PrepareHeroFeastLayer)

return PrepareHeroFeastLayer00