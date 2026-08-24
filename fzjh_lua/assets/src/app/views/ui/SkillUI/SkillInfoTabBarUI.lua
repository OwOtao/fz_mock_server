local SkillInfoTabBarUI = {}

local Resource = require("app.Resource")

local SkillInfoTabBarUI = {}

function SkillInfoTabBarUI:create()
    local p = Resource:getUIByName("Panel_skillInfoTabBar")
    Helper:tableCover(p, SkillInfoTabBarUI)
    p:init()
    return p
end

function SkillInfoTabBarUI:init()
    Helper:convertUI(self)
    self:setTouchEnabled(true) -- 设置为可触摸

    self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)

    -- 设置Image_back九宫格拉伸
    self.Image_back:setScale9Enabled(true)
    self.Image_back:setCapInsets({x = -48, y = 7, width = 120, height = 11})

    -- self:setTextColor(cc.c4b(0, 0, 0, 255))
    -- self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    -- self.Text_dsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    -- self.Text_expDsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
end

function SkillInfoTabBarUI:setName(name)
    return self.Text_name:setString(name)
end

function SkillInfoTabBarUI:getName()
    return self.Text_name:getString()
end

function SkillInfoTabBarUI:light()
    self.Image_back:setVisible(true)
end

function SkillInfoTabBarUI:dark()
    self.Image_back:setVisible(false)
end

function SkillInfoTabBarUI:loadTexture(pic)
    if pic == nil then
        return
    end
    self.Image_back:loadTexture(pic, 0)
end

-- function SkillInfoTabBarUI:setDsc(dsc)
-- 	self.Text_dsc:setString(dsc)
-- end

-- function SkillInfoTabBarUI:setExpDsc(dsc)
-- 	self.Text_expDsc:setString(dsc)
-- end

return SkillInfoTabBarUI
0000000000