--[[
    author:Seven
    time:2024-01-11 17:14:24
    desc: 一个技能详情展示页
]]
local newClass = require("third.class.NewClass")

local SkillDetailInfoShowUI1 = {}

function SkillDetailInfoShowUI1:create()
    return SkillDetailInfoShowUI1:new():__init()
end

function SkillDetailInfoShowUI1:__init()
    self.__ui = require("Layer.SkillUI.SkillDetailInfoShowUI1").create()["root"]
    Helper:convertUIParent(self.__ui) -- 获得所有子节点
    self.__ui.Pnl_item1:setVisible(false)
    return self
end

function SkillDetailInfoShowUI1:getUINode()
    return self.__ui
end

function SkillDetailInfoShowUI1:setPanelBackClickFunc(func)
    self.__ui.Panel_back:releaseFunc(
        function()
            Helper:getDef(func, EMPTY_FUNC)()
        end
    )
end

function SkillDetailInfoShowUI1:show()
    self.__ui:setVisible(true)
end

function SkillDetailInfoShowUI1:hide()
    self.__ui:setVisible(false)
end

function SkillDetailInfoShowUI1:getPanelItem1()
    local node = self.__ui.Pnl_item1:clone()

    node:setVisible(true)

    Helper:convertUIParent(node)

    return node
end

function SkillDetailInfoShowUI1:setTitleName(name)
    self.__ui.Txt_Title:setString(name)
end

function SkillDetailInfoShowUI1:setExpText(txt)
    self.__ui.Txt_Exp:setString(Helper:getDef(txt, ""))
end

function SkillDetailInfoShowUI1:setSkillDetailText(text)
    self.__ui.Txt_DetailDsc:setString(text)
end

function SkillDetailInfoShowUI1:addPanelItem(item)
    self.__ui.ListView_Details:pushBackCustomItem(item)
end

function SkillDetailInfoShowUI1:removeAllItems()
    self.__ui.ListView_Details:removeAllItems()
end

function SkillDetailInfoShowUI1:removePanelItem(index)
    self.__ui.ListView_Details:removeItem(index)
end

return newClass("SkillDetailInfoShowUI1", {}, SkillDetailInfoShowUI1)
000000