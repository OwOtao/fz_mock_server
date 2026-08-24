--[[
    author:Seven
    time:2022-11-02 19:32:37
    desc: 技能详情页面
]]
local SkillDetailUI = class("SkillDetailUI", LayerEx)

function SkillDetailUI:create()
    local p = SkillDetailUI:new()
    p:__init()
    return p
end

function SkillDetailUI:__init()
    self.__ui = require("Layer/TuJianUI/tujianSkillInfo.lua").create()["root"]
    self.__ui:addTo(self)

    Helper:convertUIByParent(self)
end

function SkillDetailUI:setVisible(bool)
    self:setVisible(bool)
end

function SkillDetailUI:setTitleName(name)
    self.Panel_1.Image_infoArea.Image_titleBack.Text_title:setString(name)
end

function SkillDetailUI:titleEnableOutline(c4b, outlineSize)
    self.Panel_1.Image_infoArea.Image_titleBack.Text_title:enableOutline(c4b, 5)
end

function SkillDetailUI:setSkillDetailText(text)
    self:__initRichText()

    local textColor = cc.c3b(167, 167, 167)
    self.RichText_print:pushBackText(Helper:getDef(text, ""), textColor, 255, Resource:getFontPath("HYCFS"), 42)
    self:delayFunc(
        0.1,
        function()
            self.RichText_print:jumpToTop()
        end
    )
end

function SkillDetailUI:__initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Panel_1.Image_infoArea.Text_detailDsc:getPosition()
    local size = self.Panel_1.Image_infoArea.Text_detailDsc:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Panel_1.Image_infoArea.Text_detailDsc:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)
end

function SkillDetailUI:setSecondTitleName(name)
    self.Panel_1.Image_infoArea.Text_detailDsc1:setString(name)
end

function SkillDetailUI:createNewSecondItemPanel()
    local itemPanel = self.Panel_1.Image_infoArea.Panel_2:clone()
    itemPanel:removeAllChildren()
    Helper:convertUIByParent(itemPanel)
    return itemPanel
end

function SkillDetailUI:createNewSecondItemDetailPanel()
    local itemPanel = self.Panel_1.Image_infoArea.Panel_2.Panel_4:clone()
    Helper:convertUIByParent(itemPanel)
    return itemPanel
end

function SkillDetailUI:addSecondDetailListItem(itemPanel)
    self.Panel_1.Image_infoArea.ListView_2:pushBackCustomItem(itemPanel)
end

function SkillDetailUI:clearSecondDetailList()
    self.Panel_1.Image_infoArea.ListView_2:removeAllChildren()
end

function SkillDetailUI:setThirdTitleName(name)
    self.Panel_1.Image_infoArea.Text_detailDsc1_0:setString(name)
end

function SkillDetailUI:setThirdTitleVisible(bool)
    self.Panel_1.Image_infoArea.Text_detailDsc1_0:setVisible(bool)
end

function SkillDetailUI:setThirdDetailText(text)
    self.Panel_1.Image_infoArea.Panel_6.Text_Auto:setString(text)
end

function SkillDetailUI:setThirdDetailVisible(bool)
    self.Panel_1.Image_infoArea.Panel_6:setVisible(bool)
end

function SkillDetailUI:setThirdDetailClickFunc(func)
    self.Panel_1.Image_infoArea.Panel_6:releaseFunc(
        function()
            func()
        end
    )
end

function SkillDetailUI:getNewAnimNode()
    local node = self.AnimNode_right:clone()

    return node
end

function SkillDetailUI:setAnimAreaBackground(path)
    if self.__backImgView then
        self.__backImgView:removeFromParent()
    end

    self.__backImgView = ccui.ImageView:create(path)

    self.__backImgView:setPositionY(0)

    self.__backImgView:setAnchorPoint(cc.p(0, 0))

    self.Panel_1.Image_infoArea.Panel_animFightArea:addChild(self.__backImgView)
end

function SkillDetailUI:setAnimAreaVisible(bool)
    self.Panel_1.Image_infoArea.Panel_animFightArea:setVisible(bool)
end

function SkillDetailUI:addAnimNode(node)
    self.Panel_1.Image_infoArea.Panel_animFightArea:addChild(node)
end

function SkillDetailUI:destory()
    self:clearSecondDetailList()
    self.Panel_1.Image_infoArea.Panel_animFightArea:removeAllChildren()
end

function SkillDetailUI:setPanelBackClickFunc(func)
    self.Panel_back:releaseFunc(
        function()
            func()
        end
    )
end

return SkillDetailUI
0000