--[[
    author:Seven
    time:2022-11-04 20:27:50
    desc: 主动技能详情页面
]]
local ActiveSkillDetailUI = class("ActiveSkillDetailUI", LayerEx)

function ActiveSkillDetailUI:create()
    local p = ActiveSkillDetailUI:new()
    p:__init()
    return p
end

function ActiveSkillDetailUI:__init()
    self.__ui = require("Layer/TuJianUI/tujianActiveZhaoInfoUI.lua").create()["root"]
    self.__ui:addTo(self)

    Helper:convertUIByParent(self)
    
    self.Panel_learn.ListView_condition_use:setClippingEnabled(true)
    self.Panel_learn.ListView_condition_use:setTouchEnabled(true)

end

function ActiveSkillDetailUI:__initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Panel_learn.Text_zhaoDesc_learn:getPosition()
    local size = self.Panel_learn.Text_zhaoDesc_learn:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Panel_learn.Text_zhaoDesc_learn:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)
end

function ActiveSkillDetailUI:setTitleName(name)
    self.Panel_learn.Text_zhaoName_learn:setString(name)
end

function ActiveSkillDetailUI:setActiveSkillDetailText(text)
    self:__initRichText()

    local textColor = cc.c3b(123, 123, 123)
    self.RichText_print:pushBackText(Helper:getDef(text, ""), textColor, 255, Resource:getFontPath("default"), 38)
    self:delayFunc(
        0.1,
        function()
            self.RichText_print:jumpToTop()
        end
    )
end

function ActiveSkillDetailUI:setSecondTitleName(name)
    self.Panel_learn.Text_learnCondition_learn:setString(name)
end

function ActiveSkillDetailUI:getNewItemRowUI()
    local itemUI = self.Text_Con:clone()
    itemUI:setVisible(true)
    
    itemUI:ignoreContentAdaptWithSize(true)

    itemUI:setTextAreaSize({width = 800, height = 0})

    return itemUI
end

function ActiveSkillDetailUI:clearSecondList()
    self.Panel_learn.ListView_condition_learn:removeAllItems()
end

function ActiveSkillDetailUI:addSecondItemUI(itemUI)
    self.Panel_learn.ListView_condition_learn:pushBackCustomItem(itemUI)
end

function ActiveSkillDetailUI:secondListJumpToTop()
    self.Panel_learn.ListView_condition_learn:jumpToTop()
end

function ActiveSkillDetailUI:setThirdTitleName(name)
    self.Panel_learn.Text_learnCondition_use:setString(name)
end

function ActiveSkillDetailUI:addThirdItemUI(itemUI)
    self.Panel_learn.ListView_condition_use:pushBackCustomItem(itemUI)
end

function ActiveSkillDetailUI:clearThirdList()
    self.Panel_learn.ListView_condition_use:removeAllItems()
end

function ActiveSkillDetailUI:setThirdListSize(w,h)
    self.Panel_learn.ListView_condition_use:setSize({width = w, height = h})
end

function ActiveSkillDetailUI:destory()
end

function ActiveSkillDetailUI:setPanelBackClickFunc(func)
    self.Panel_back:releaseFunc(
        function()
            func()
        end
    )
end

return ActiveSkillDetailUI
0000000000000