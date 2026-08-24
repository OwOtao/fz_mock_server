local PuzzleGameUI = class("PuzzleGameUI", LayerEx)

function PuzzleGameUI:create()
    local p = PuzzleGameUI:new()
    p:init()
    return p
end

function PuzzleGameUI:init()
    self._UI = require("Layer/MiniGame/PuzzleGameUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)
end

function PuzzleGameUI:showUI()
    self:show()
end

function PuzzleGameUI:hideUI()
    self:hide()
end

function PuzzleGameUI:setButtonBack(func)
    self.Panel_back:releaseFunc(
        function()
            func()
        end
    )
end

function PuzzleGameUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function PuzzleGameUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function PuzzleGameUI:setButtonEnable(index, enabled)
    self["Button_"..tostring(index)]:setTouchEnabled(enabled)
end

function PuzzleGameUI:setButtonVisible(index, visible)
    self["Button_"..tostring(index)]:setVisible(visible)
end

function PuzzleGameUI:setButtonText(index, text)
    self["Button_"..tostring(index)].Text_1:setString(text)
end

function PuzzleGameUI:setButtonFunc(index, func)
    self["Button_"..tostring(index)]:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function PuzzleGameUI:setButtonBackImgVisible(index, visible)
    self["Image_"..tostring(index)]:setVisible(visible)
end

return PuzzleGameUI
000000000000