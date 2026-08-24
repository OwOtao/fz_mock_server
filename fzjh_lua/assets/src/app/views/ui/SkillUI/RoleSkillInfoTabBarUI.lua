local RoleSkillInfoTabBarUI = {}

local Resource = require("app.Resource")

local RoleSkillInfoTabBarUI = {}

function RoleSkillInfoTabBarUI:create()
    local p = Resource:getUIByName("Panel_roleSkillInfoTabBar")
    Helper:tableCover(p, RoleSkillInfoTabBarUI)
    p:init()
    return p
end

function RoleSkillInfoTabBarUI:init()
    Helper:convertUI(self)
    self:setTouchEnabled(true) -- 设置为可触摸

    self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)

    self.Image_back:setScale9Enabled(true)
    self.Image_back:setCapInsets({x = -48, y = 7, width = 120, height = 11})
    -- self:setTextColor(cc.c4b(0, 0, 0, 255))
    -- self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    -- self.Text_dsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    -- self.Text_expDsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
end

function RoleSkillInfoTabBarUI:setName(name)
    return self.Text_name:setString(name)
end

function RoleSkillInfoTabBarUI:getName()
    return self.Text_name:getString()
end

function RoleSkillInfoTabBarUI:light()
    self.Image_back:setVisible(true)
end

function RoleSkillInfoTabBarUI:dark()
    self.Image_back:setVisible(false)
end

function RoleSkillInfoTabBarUI:loadTexture(pic)
    if pic == nil then
        return
    end
    self.Image_back:loadTexture(pic, 0)
end

-- function RoleSkillInfoTabBarUI:setDsc(dsc)
-- 	self.Text_dsc:setString(dsc)
-- end

-- function RoleSkillInfoTabBarUI:setExpDsc(dsc)
-- 	self.Text_expDsc:setString(dsc)
-- end

return RoleSkillInfoTabBarUI
000000000000